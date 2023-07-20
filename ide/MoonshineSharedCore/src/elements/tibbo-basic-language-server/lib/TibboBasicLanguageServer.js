"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/* eslint-disable @typescript-eslint/no-var-requires */
const vscode_languageserver_1 = require("vscode-languageserver");
const node_1 = require("vscode-languageserver/node");
const TibboBasicDocumentFormatter_1 = require("./TibboBasicDocumentFormatter");
const fs = require("fs");
const path = require("path");
const ini = require("ini");
const TibboBasicPreprocessor_1 = require("./TibboBasicPreprocessor");
const TibboBasicProjectParser_1 = require("./TibboBasicProjectParser");
const types_1 = require("./types");
const vscode_languageserver_textdocument_1 = require("vscode-languageserver-textdocument");
const rpc = require("vscode-jsonrpc");
const TibboBasicParser = require('../language/TibboBasic/lib/TibboBasicParser').TibboBasicParser;
// const turndownService = new TurndownService();
const supportedFileTypes = ['.tbs', '.tbh', '.tph'];
const html2markdown = require('./html2markdown');
// const TIBBOBASIC = 'tibbo-basic';
// Create a connection for the server. The connection uses Node's IPC as a transport.
// Also include all preview / proposed LSP features.
const connection = node_1.createConnection(vscode_languageserver_1.ProposedFeatures.all);
const tbFormatter = new TibboBasicDocumentFormatter_1.TibboBasicDocumentFormatter();
const VALIDATE_INTERVAL = 1500;
// Create a simple text document manager. The text document manager
// supports full document sync only
const documents = new vscode_languageserver_1.TextDocuments(vscode_languageserver_textdocument_1.TextDocument);
let hasConfigurationCapability = false;
let hasWorkspaceFolderCapability = false;
let workspaceRoot = '';
// let platformType: string = '';
let platformPreprocessor;
let platformProjectParser;
let preprocessor;
let projectParser;
const fileEdits = {};
let PLATFORMS_PATH = 'Platforms';
let tprPath = '';
let parsing = false;
let needsUpdate = false;
let platformsChanged = true;
const PROJECT_EXPLORER_EVENTS = 'Events';
const PROJECT_EXPLORER_PROJECT = 'Project';
const PROJECT_EXPLORER_LIBRARIES = 'Libraries';
const PROJECT_EXPLORER_PLATFORM = 'Platform';
let rootItems = [];
connection.onInitialize(async (params) => {
    const capabilities = params.capabilities;
    if (params.rootPath) {
        workspaceRoot = params.rootPath;
    }
    PLATFORMS_PATH = path.join(workspaceRoot, PLATFORMS_PATH);
    // Does the client support the `workspace/configuration` request?
    // If not, we will fall back using global settings
    hasConfigurationCapability = !!(capabilities.workspace && !!capabilities.workspace.configuration);
    hasWorkspaceFolderCapability = !!(capabilities.workspace && !!capabilities.workspace.workspaceFolders);
    if (!fs.existsSync(PLATFORMS_PATH)) {
        if (params.initializationOptions != undefined) {
            if (params.initializationOptions.platformsPath != undefined && params.initializationOptions.platformsPath != '') {
                PLATFORMS_PATH = params.initializationOptions.platformsPath;
            }
        }
    }
    if (workspaceRoot) {
        fs.readdirSync(workspaceRoot).forEach((file) => {
            const ext = path.extname(file);
            if (ext == '.tpr') {
                if (workspaceRoot) {
                    tprPath = path.join(workspaceRoot, file);
                }
            }
        });
    }
    if (tprPath == '') {
        return {
            capabilities: {}
        };
    }
    await new Promise((resolve, reject) => {
        preprocessor = new TibboBasicPreprocessor_1.TibboBasicPreprocessor(workspaceRoot, PLATFORMS_PATH);
        projectParser = new TibboBasicProjectParser_1.TibboBasicProjectParser();
        resolve();
    });
    setInterval(async () => {
        await new Promise((resolve, reject) => {
            validateTextDocument();
            resolve();
        });
    }, VALIDATE_INTERVAL);
    validateTextDocument();
    return {
        capabilities: {
            textDocumentSync: vscode_languageserver_1.TextDocumentSyncKind.Full,
            // Tell the client that the server supports code completion
            completionProvider: {
                resolveProvider: true,
                triggerCharacters: [
                    '.',
                    '=',
                    '(',
                    ','
                ]
            },
            documentFormattingProvider: true,
            hoverProvider: true,
            definitionProvider: true,
            documentSymbolProvider: true,
            renameProvider: {
                prepareProvider: true
            },
            declarationProvider: true,
            referencesProvider: true,
            signatureHelpProvider: {
                triggerCharacters: ['('],
                retriggerCharacters: [',']
            }
        }
    };
});
connection.onInitialized(async (params) => {
    if (hasConfigurationCapability) {
        // Register for all configuration changes.
        connection.client.register(vscode_languageserver_1.DidChangeConfigurationNotification.type, undefined);
    }
    if (hasWorkspaceFolderCapability) {
        connection.workspace.onDidChangeWorkspaceFolders((_event) => {
            // connection.console.log('Workspace folder change event received.');
        });
    }
});
// The example settings
// interface ExampleSettings {
// 	maxNumberOfProblems: number;
// }
// The global settings, used when the `workspace/configuration` request is not supported by the client.
// Please note that this is not the case when using this server with the client provided in this example
// but could happen with other clients.
// const defaultSettings: ExampleSettings = { maxNumberOfProblems: 1000 };
// let globalSettings: ExampleSettings = defaultSettings;
// Cache the settings of all open documents
// let documentSettings: Map<string, Thenable<ExampleSettings>> = new Map();
connection.onDidChangeConfiguration((change) => {
    if (hasConfigurationCapability) {
        // Reset all cached document settings
        // documentSettings.clear();
    }
    else {
        // globalSettings = <ExampleSettings>(
        // 	(change.settings.languageServerExample || defaultSettings)
        // );
    }
    // Revalidate all open text documents
    // documents.all().forEach(validateTextDocument);
});
// function getDocumentSettings(resource: string): Thenable<ExampleSettings> {
// 	if (!hasConfigurationCapability) {
// 		return Promise.resolve(globalSettings);
// 	}
// 	let result = documentSettings.get(resource);
// 	if (!result) {
// 		result = connection.workspace.getConfiguration({
// 			scopeUri: resource,
// 			section: 'tibbo-basic'
// 		});
// 		documentSettings.set(resource, result);
// 	}
// 	return result;
// }
// Only keep settings for open documents
documents.onDidClose((e) => {
    // documentSettings.delete(e.document.uri);
});
// The content of a text document has changed. This event is emitted
// when the text document first opened or when its content has changed.
documents.onDidChangeContent((change) => {
    try {
        const text = change.document.getText();
        const textDocument = change.document;
        const currentFilePath = getFileName(textDocument.uri);
        const ext = path.extname(currentFilePath);
        if (preprocessor.originalFiles[currentFilePath] != text) {
            fileEdits[currentFilePath] = text;
        }
        if (!platformsChanged && preprocessor && preprocessor.originalFiles) {
            if (ext == '.tpr') {
                platformsChanged = true;
                needsUpdate = true;
            }
        }
        if (platformsChanged) {
            needsUpdate = true;
        }
    }
    catch (ex) {
        if (ex instanceof Error) {
            connection.console.log(ex.message);
        }
    }
});
function validateTextDocument() {
    // In this simple example we get the settings for every validate run.
    // let settings = await getDocumentSettings(textDocument.uri);
    // The validator creates diagnostics for all uppercase words length 2 and more
    // let problems = 0;
    let updated = false;
    for (const key in fileEdits) {
        updated = true;
        const currentFilePath = key;
        const text = fileEdits[key];
        const dirName = path.dirname(currentFilePath);
        const tmpPreprocessor1 = new TibboBasicPreprocessor_1.TibboBasicPreprocessor(workspaceRoot, PLATFORMS_PATH);
        const tmpPreprocessor2 = new TibboBasicPreprocessor_1.TibboBasicPreprocessor(workspaceRoot, PLATFORMS_PATH);
        tmpPreprocessor1.originalFiles[currentFilePath] = preprocessor.originalFiles[currentFilePath];
        tmpPreprocessor2.originalFiles[currentFilePath] = text;
        tmpPreprocessor1.parseFile(dirName, path.basename(currentFilePath), true);
        tmpPreprocessor2.parseFile(dirName, path.basename(currentFilePath), true);
        if (JSON.stringify(tmpPreprocessor1.defines) != JSON.stringify(tmpPreprocessor2.defines)) {
            needsUpdate = true;
            preprocessor.originalFiles[currentFilePath] = text;
        }
        delete fileEdits[key];
        if (!needsUpdate) {
            preprocessor.originalFiles[currentFilePath] = text;
            preprocessor.parseFile(dirName, path.basename(currentFilePath), true);
            projectParser.parseFile(currentFilePath, text);
        }
    }
    if (updated) {
        notifyDiagnostics();
        getProjectStructure();
        projectParser.constructComments();
    }
    if (parsing || !needsUpdate) {
        return;
    }
    parsing = true;
    const timeStart = new Date().getTime();
    try {
        if (platformsChanged) {
            platformPreprocessor = new TibboBasicPreprocessor_1.TibboBasicPreprocessor(workspaceRoot, PLATFORMS_PATH);
            platformProjectParser = new TibboBasicProjectParser_1.TibboBasicProjectParser();
            platformPreprocessor.parsePlatforms();
            for (const filePath in platformPreprocessor.files) {
                const fileContents = platformPreprocessor.files[filePath];
                platformProjectParser.parseFile(filePath, fileContents);
            }
            platformsChanged = false;
        }
        copyProperties();
        //parse tpr file
        const tpr = ini.parse(fs.readFileSync(tprPath, 'utf-8'));
        const max = 999;
        const dirName = path.dirname(tprPath);
        for (let i = 1; i < max; i++) {
            const entryName = 'file' + i.toString();
            if (tpr[entryName] != undefined) {
                const originalFilePath = tpr[entryName]['path'].split('\\').join(path.sep);
                let filePath = originalFilePath;
                const ext = path.extname(filePath);
                if (!supportedFileTypes.includes(ext)) {
                    continue;
                }
                let directory = dirName;
                if (tpr[entryName]['location'] == 'commonlib') {
                    directory = PLATFORMS_PATH;
                }
                filePath = preprocessor.parseFile(directory, originalFilePath, needsUpdate);
                const fileContents = preprocessor.files[filePath];
                projectParser.parseFile(filePath, fileContents);
            }
            else {
                break;
            }
        }
        projectParser.constructComments();
    }
    catch (ex) {
        if (ex instanceof Error) {
            connection.console.log(ex.message);
        }
    }
    finally {
        parsing = false;
        needsUpdate = false;
        const timeEnd = new Date().getTime();
        const secondsElapsed = (timeEnd - timeStart) / 1000;
        notifyDiagnostics();
        connection.console.log(`parsed in ${secondsElapsed} s`);
    }
}
connection.onDidChangeWatchedFiles((_change) => {
    // Monitored files have change in VSCode
    // connection.console.log('We received an file change event');
});
connection.onDocumentFormatting((formatParams) => {
    const document = documents.get(formatParams.textDocument.uri);
    if (!document) {
        return;
    }
    return tbFormatter.formatDocument(document, formatParams);
});
connection.onCompletion((params) => {
    // const timeStart = new Date().getTime();
    const suggestions = [];
    const document = documents.get(params.textDocument.uri);
    const position = params.position;
    const textDocument = params.textDocument;
    let variableType = '';
    if (!document) {
        return suggestions;
    }
    let offset = document.offsetAt(position);
    const filePath = getFileName(textDocument.uri);
    const scope = projectParser.getScope(filePath, offset);
    const variables = projectParser.getScopeVariables(scope);
    parseFile(textDocument.uri);
    let triggerCharacter = '';
    let token = undefined;
    const MAX_ITERATIONS = 10;
    let index = MAX_ITERATIONS;
    while (token == undefined || index >= 0) {
        token = projectParser.getTokenAtPosition(filePath, offset);
        offset--;
        if (token != undefined) {
            triggerCharacter = token.getText();
            if (triggerCharacter != ')') {
                break;
            }
        }
        index--;
    }
    switch (triggerCharacter) {
        case '=':
            {
                let token = undefined;
                const MAX_ITERATIONS = 5;
                let index = MAX_ITERATIONS;
                while (token == undefined || index >= 0) {
                    token = projectParser.getTokenAtPosition(filePath, offset);
                    if (token != undefined) {
                        const obj = getObjectAtToken(token);
                        if (obj != undefined) {
                            const objProp = getObjectProperty(obj, token.symbol.text);
                            if (objProp != undefined) {
                                const dataType = objProp.dataType;
                                if (projectParser.enums[dataType.toLowerCase()] != undefined) {
                                    const members = projectParser.enums[dataType.toLowerCase()].members;
                                    for (let i = 0; i < members.length; i++) {
                                        suggestions.push({
                                            label: members[i].name.toUpperCase(),
                                            kind: vscode_languageserver_1.CompletionItemKind.EnumMember,
                                            data: getCommentString(members[i].comments)
                                        });
                                    }
                                    break;
                                }
                            }
                        }
                        const varD = getVariable(token.symbol.text, filePath, offset);
                        if (varD != undefined) {
                            variableType = varD.dataType;
                        }
                    }
                    offset--;
                    index--;
                }
            }
            break;
        case '.':
            {
                const token = projectParser.getTokenAtPosition(filePath, offset - 1);
                if (token != undefined) {
                    const obj = projectParser.objects[token.getText()];
                    if (obj != undefined) {
                        obj.functions.forEach((func) => {
                            suggestions.push({
                                label: func.name,
                                kind: vscode_languageserver_1.CompletionItemKind.Function,
                                data: getCommentString(func.comments)
                            });
                        });
                        obj.properties.forEach((prop) => {
                            suggestions.push({
                                label: prop.name,
                                kind: vscode_languageserver_1.CompletionItemKind.Property,
                                data: getCommentString(prop.comments)
                            });
                        });
                    }
                    const varD = getVariable(token.symbol.text, filePath, offset - 1);
                    if (varD != undefined) {
                        const dataType = varD.dataType;
                        if (projectParser.types[dataType] != undefined) {
                            const dType = projectParser.types[dataType];
                            for (let i = 0; i < dType.members.length; i++) {
                                suggestions.push({
                                    label: dType.members[i].name,
                                    kind: vscode_languageserver_1.CompletionItemKind.Property,
                                    data: getCommentString(dType.members[i].comments)
                                });
                            }
                        }
                    }
                }
            }
            break;
        case '(':
        case ')':
        case ',':
            {
                let commaCount = 0;
                const currentLine = params.position.line;
                offset = document.offsetAt(params.position);
                let cursor = document.positionAt(offset);
                while (cursor.line == currentLine) {
                    const tmpToken = projectParser.getTokenAtPosition(filePath, offset);
                    cursor = document.positionAt(offset);
                    if (tmpToken == undefined) {
                        break;
                    }
                    if ((tmpToken === null || tmpToken === void 0 ? void 0 : tmpToken.symbol.text) == ',') {
                        commaCount++;
                        offset--;
                    }
                    else if ((tmpToken === null || tmpToken === void 0 ? void 0 : tmpToken.symbol.text) == '(') {
                        offset--;
                        cursor = document.positionAt(offset);
                        token = projectParser.getTokenAtPosition(filePath, offset);
                        if (cursor.line != params.position.line || token == undefined) {
                            break;
                        }
                        const text = token.symbol.text;
                        if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                            const obj = getObjectAtToken(token);
                            if (obj != undefined) {
                                const objFunc = getObjectFunction(obj, token.symbol.text);
                                if (objFunc != undefined && objFunc.parameters[commaCount] != undefined) {
                                    variableType = objFunc.parameters[commaCount].dataType;
                                }
                            }
                        }
                        else if (projectParser.syscalls[text] != undefined) {
                            const syscall = projectParser.syscalls[text];
                            if (syscall.parameters[commaCount] != undefined) {
                                variableType = syscall.parameters[commaCount].dataType;
                            }
                        }
                        else if (projectParser.functions[text] != undefined) {
                            const func = projectParser.functions[text];
                            if (func.parameters[commaCount] != undefined) {
                                variableType = func.parameters[commaCount].dataType;
                            }
                        }
                        break;
                    }
                    else {
                        offset = (tmpToken === null || tmpToken === void 0 ? void 0 : tmpToken.symbol.start) - 1;
                    }
                }
            }
            break;
        default:
            break;
    }
    if (variableType != '') {
        for (let i = 0; i < variables.length; i++) {
            if (variables[i].dataType == variableType) {
                suggestions.push({
                    label: variables[i].name,
                    kind: vscode_languageserver_1.CompletionItemKind.Variable
                });
            }
        }
        if (projectParser.enums[variableType.toLowerCase()] != undefined) {
            const members = projectParser.enums[variableType.toLowerCase()].members;
            for (let i = 0; i < members.length; i++) {
                suggestions.push({
                    label: members[i].name.toUpperCase(),
                    kind: vscode_languageserver_1.CompletionItemKind.Enum,
                    data: getCommentString(members[i].comments)
                });
            }
        }
    }
    // const timeEnd = new Date().getTime();
    // const secondsElapsed = (timeEnd - timeStart) / 1000;
    // connection.console.log(`completion in ${secondsElapsed} s`);
    return suggestions;
});
// This handler resolves additional information for the item selected in
// the completion list.
connection.onCompletionResolve((item) => {
    if (item.data) {
        item.documentation = {
            kind: vscode_languageserver_1.MarkupKind.Markdown,
            value: html2markdown(item.data)
        };
    }
    return item;
});
connection.onHover(({ textDocument, position }) => {
    const document = documents.get(textDocument.uri);
    const result = {
        kind: vscode_languageserver_1.MarkupKind.Markdown,
        value: ''
    };
    if (!document) {
        return;
    }
    const offset = document.offsetAt(position);
    const filePath = getFileName(textDocument.uri);
    const token = projectParser.getTokenAtPosition(filePath, offset);
    if (token != undefined) {
        const text = token.symbol.text;
        // let context: ParserRuleContext | undefined;
        switch (token.symbol.type) {
            case TibboBasicParser.IDENTIFIER:
                //get scope
                if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                    const obj = getObjectAtToken(token);
                    if (obj != undefined) {
                        const func = getObjectFunction(obj, token.symbol.text);
                        const prop = getObjectProperty(obj, token.symbol.text);
                        if (func != undefined) {
                            result.value += '```tibbo-basic\n';
                            result.value += `${obj.name}.${func.name}\n`;
                            result.value += '```\n';
                            '';
                            result.value += getComments(func.comments);
                        }
                        else if (prop != undefined) {
                            result.value += '```tibbo-basic\n';
                            result.value += `${obj.name}.${prop.name}\n`;
                            result.value += '```\n';
                            result.value += getComments(prop.comments);
                        }
                    }
                }
                if (result.value == '') {
                    //TODO get correct variable at scope
                    const varD = getVariable(text, filePath, offset);
                    if (varD != undefined) {
                        let lengthField = '';
                        if (varD.length != undefined && varD.length != '') {
                            lengthField += '(' + varD.length + ')';
                        }
                        result.value = '```tibbo-basic\n';
                        result.value += `dim ${varD.name}${lengthField} as ${varD.dataType}`;
                        result.value += '\n```\n';
                        result.value += getComments(varD.comments);
                    }
                }
                if (result.value != '') {
                    //is object or complex type variable
                }
                else if (preprocessor.defines[text] != undefined) {
                    const define = preprocessor.defines[text];
                    result.value = '```tibbo-basic\n';
                    result.value += `#define ${define.name} ${define.value}\n`;
                    result.value += '```';
                }
                else if (projectParser.events[text.toLowerCase()] != undefined) {
                    const markdown = getComments(projectParser.events[text.toLowerCase()].comments);
                    result.value += markdown;
                }
                else if (projectParser.objects[text.toLowerCase()] != undefined) {
                    const obj = projectParser.objects[text.toLowerCase()];
                    result.value = '```tibbo-basic\n';
                    result.value += `object ${obj.name}`;
                    result.value += '\n```\n';
                    result.value += getComments(obj.comments);
                }
                else if (projectParser.functions[text] != undefined) {
                    const func = projectParser.functions[text];
                    if (func.location != undefined) {
                        result.value = '```tibbo-basic\n';
                        result.value += `sub ${func.name}(${func.parameters.map((param) => {
                            return `${param.byref ? 'byref' : ''} ${param.name} as ${param.dataType}`;
                        }).join(',')})`;
                        if (func.dataType != undefined) {
                            result.value += ` as ${func.dataType}`;
                        }
                        result.value += '\n```\n';
                        result.value += getComments(func.comments);
                    }
                }
                else if (projectParser.consts[text] != undefined) {
                    result.value = '```tibbo-basic\n';
                    result.value += `const ${text} = ${projectParser.consts[text].value}`;
                    result.value += '\n```';
                }
                else if (projectParser.enums[text.toLowerCase()] != undefined) {
                    result.value = '```tibbo-basic\n';
                    result.value += 'enum ' + text + '\n';
                    for (let i = 0; i < projectParser.enums[text].members.length; i++) {
                        result.value += `    ${projectParser.enums[text].members[i].name.toUpperCase()}(${projectParser.enums[text].members[i].value})\n`;
                    }
                    result.value += 'end enum';
                    result.value += '\n```';
                }
                else if (projectParser.syscalls[text] != undefined) {
                    const syscall = projectParser.syscalls[text];
                    result.value = '```tibbo-basic\n';
                    result.value += `syscall ${syscall.name}(${syscall.parameters.map((param) => {
                        return `${param.byref ? 'byref' : ''} ${param.name} as ${param.dataType}`;
                    }).join(',')})`;
                    if (syscall.dataType != '') {
                        result.value += ` as ${syscall.dataType}`;
                    }
                    result.value += '\n```\n';
                    result.value += getComments(syscall.comments);
                }
                else if (projectParser.types[text.toLowerCase()] != undefined) {
                    const type = projectParser.types[text.toLowerCase()];
                    result.value = '```tibbo-basic\n';
                    result.value += 'type ' + text + '\n';
                    for (let i = 0; i < type.members.length; i++) {
                        const member = type.members[i];
                        result.value += `    ${member.name} as ${member.dataType}`;
                        if (member.length) {
                            result.value += `(${member.length})`;
                        }
                        result.value += '\n';
                    }
                    result.value += 'end type';
                    result.value += '\n```\n';
                    result.value += getComments(type.comments);
                }
                if (result.value == '') {
                    //enums
                    for (const key in projectParser.enums) {
                        const enumItem = projectParser.enums[key];
                        for (let i = 0; i < enumItem.members.length; i++) {
                            if (text.toLowerCase() == enumItem.members[i].name.toLowerCase()) {
                                result.value = '```tibbo-basic\n';
                                result.value += 'enum ' + enumItem.name.toUpperCase() + '\n';
                                result.value += '```\n';
                                result.value += getComments(enumItem.members[i].comments);
                                break;
                            }
                        }
                    }
                }
                break;
        }
    }
    if (result.value != '') {
        return {
            contents: result
        };
    }
    return undefined;
});
connection.onDeclaration(({ textDocument, position }) => {
    const document = documents.get(textDocument.uri);
    if (!document) {
        return;
    }
    const offset = document.offsetAt(position);
    const filePath = getFileName(textDocument.uri);
    const token = projectParser.getTokenAtPosition(filePath, offset);
    if (token != undefined) {
        const text = token.symbol.text;
        let location = undefined;
        switch (token.symbol.type) {
            case TibboBasicParser.IDENTIFIER:
                if (projectParser.functions[text] != undefined) {
                    location = projectParser.functions[text].declaration;
                }
        }
        if (location != undefined) {
            const uri = getFileUrl(location.startToken.source[1].name);
            return {
                uri: uri,
                range: {
                    start: {
                        line: location.startToken.line - 1,
                        character: location.startToken.column
                    },
                    end: {
                        line: location.stopToken.line - 1,
                        character: location.stopToken.column
                    }
                }
            };
        }
    }
});
connection.onDefinition(({ textDocument, position }) => {
    const document = documents.get(textDocument.uri);
    if (!document) {
        return;
    }
    const offset = document.offsetAt(position);
    const filePath = getFileName(textDocument.uri);
    const token = projectParser.getTokenAtPosition(filePath, offset);
    if (token != undefined) {
        const text = token.symbol.text;
        let location = undefined;
        const varD = getVariable(text, filePath, offset);
        switch (token.symbol.type) {
            case TibboBasicParser.IDENTIFIER:
                if (projectParser.functions[text] != undefined) {
                    location = projectParser.functions[text].location;
                    for (let i = 0; i < projectParser.scopes.length; i++) {
                        if (location && location.startToken.start == projectParser.scopes[i].start.start) {
                            return {
                                uri: getFileUrl(location.startToken.source[1].name),
                                range: {
                                    start: { line: projectParser.scopes[i].start.line - 1, character: projectParser.scopes[i].start.column },
                                    end: { line: projectParser.scopes[i].end.line, character: projectParser.scopes[i].end.column },
                                }
                            };
                        }
                    }
                }
                if (projectParser.consts[text] != undefined) {
                    location = projectParser.consts[text].location;
                }
                if (projectParser.syscalls[text] != undefined) {
                    return;
                }
                if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                    return;
                }
                if (varD != undefined && varD.location != undefined) {
                    return {
                        uri: getFileUrl(varD.location.startToken.source[1].name),
                        range: {
                            start: { line: varD.location.startToken.line - 1, character: varD.location.startToken.column },
                            end: { line: varD.location.stopToken.line - 1, character: varD.location.stopToken.column },
                        }
                    };
                }
                break;
            case TibboBasicParser.STRINGLITERAL:
                if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_includeStmt) {
                    const dirName = path.dirname(tprPath);
                    let filePath = token.getText().replace(/"/g, '').split('\\').join(path.sep);
                    filePath = preprocessor.getFilePath(dirName, filePath);
                    return {
                        uri: getFileUrl(filePath),
                        range: {
                            start: { line: 0, character: 0 },
                            end: { line: 0, character: 0 },
                        }
                    };
                }
                break;
        }
        if (location != undefined) {
            const uri = getFileUrl(location.startToken.source[1].name);
            return {
                uri: uri,
                range: {
                    start: {
                        line: location.startToken.line - 1,
                        character: location.startToken.column
                    },
                    end: {
                        line: location.stopToken.line - 1,
                        character: location.stopToken.column
                    }
                }
            };
        }
    }
});
connection.onDocumentSymbol(({ textDocument }) => {
    const document = documents.get(textDocument.uri);
    if (!document) {
        return;
    }
    const symbols = [];
    const items = [
        {
            structure: projectParser.functions,
            kind: vscode_languageserver_1.SymbolKind.Function //Function
        },
        {
            structure: projectParser.functions,
            kind: vscode_languageserver_1.SymbolKind.Method //Method
        },
        {
            structure: projectParser.enums,
            kind: vscode_languageserver_1.SymbolKind.Enum,
        },
        {
            structure: projectParser.consts,
            kind: vscode_languageserver_1.SymbolKind.Constant,
        }
    ];
    const filePath = getFileName(textDocument.uri);
    for (let i = 0; i < items.length; i++) {
        for (const key in items[i].structure) {
            const location = items[i].structure[key].location;
            if (location != undefined && location.startToken.source[1].name == filePath) {
                const children = [];
                const scope = projectParser.getScope(filePath, location.startToken.start);
                if (scope && (items[i].kind == vscode_languageserver_1.SymbolKind.Function || items[i].kind == vscode_languageserver_1.SymbolKind.Method)) {
                    const variables = projectParser.getScopeVariables(scope);
                    for (let j = 0; j < variables.length; j++) {
                        const variable = variables[j];
                        children.push({
                            name: variable.name,
                            kind: vscode_languageserver_1.SymbolKind.Variable,
                            range: {
                                start: document.positionAt(variable.location.startToken.start),
                                end: document.positionAt(variable.location.stopToken.stop)
                            },
                            selectionRange: {
                                start: document.positionAt(variable.location.startToken.start),
                                end: document.positionAt(variable.location.stopToken.stop)
                            }
                        });
                    }
                }
                symbols.push({
                    name: items[i].structure[key].name,
                    kind: items[i].kind,
                    range: {
                        start: document.positionAt(location.startToken.start),
                        end: document.positionAt(location.stopToken.stop)
                    },
                    selectionRange: {
                        start: document.positionAt(location.startToken.start),
                        end: document.positionAt(location.stopToken.stop)
                    },
                    children: children
                });
            }
        }
    }
    symbols.sort((a, b) => {
        return a.range.start.line - b.range.start.line;
    });
    return symbols;
});
connection.onSignatureHelp((params) => {
    const help = {
        signatures: [],
        activeSignature: 0,
        activeParameter: 0
    };
    const document = documents.get(params.textDocument.uri);
    if (!document) {
        return null;
    }
    const currentLine = params.position.line;
    let offset = document.offsetAt(params.position);
    parseFile(params.textDocument.uri);
    const filePath = getFileName(params.textDocument.uri);
    let token = projectParser.getTokenAtPosition(filePath, offset);
    let commaCount = 0;
    let cursor = document.positionAt(offset);
    let found = false;
    while (cursor.line == currentLine && !found) {
        token = projectParser.getTokenAtPosition(filePath, offset);
        cursor = document.positionAt(offset);
        if ((token === null || token === void 0 ? void 0 : token.symbol.text) == ',') {
            commaCount++;
        }
        if (token != undefined) {
            offset = token.symbol.start - 1;
            const text = token.symbol.text;
            // let context: ParserRuleContext | undefined;
            switch (token.symbol.type) {
                case TibboBasicParser.IDENTIFIER:
                    {
                        //get scope
                        const info = {
                            label: '',
                            parameters: []
                        };
                        if (info.parameters == undefined) {
                            break;
                        }
                        let methodParams = [];
                        let returnValue = '';
                        let strIndex = 0;
                        if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                            const obj = getObjectAtToken(token);
                            if (obj != undefined) {
                                const objFunc = getObjectFunction(obj, token.symbol.text);
                                if (objFunc != undefined) {
                                    found = true;
                                    info.label = `syscall ${obj.name}.${objFunc.name}`;
                                    methodParams = objFunc.parameters;
                                    returnValue = objFunc.dataType;
                                    info.documentation = {
                                        kind: vscode_languageserver_1.MarkupKind.Markdown,
                                        value: getComments(objFunc.comments)
                                    };
                                }
                            }
                        }
                        else if (projectParser.syscalls[text] != undefined) {
                            found = true;
                            const syscall = projectParser.syscalls[text];
                            info.label = 'syscall ' + syscall.name;
                            methodParams = syscall.parameters;
                            info.documentation = {
                                kind: vscode_languageserver_1.MarkupKind.Markdown,
                                value: getComments(syscall.comments)
                            };
                        }
                        else if (projectParser.functions[text] != undefined) {
                            found = true;
                            const func = projectParser.functions[text];
                            info.label = 'sub ' + func.name;
                            methodParams = func.parameters;
                            if (func.dataType != undefined) {
                                returnValue = func.dataType;
                            }
                            info.documentation = {
                                kind: vscode_languageserver_1.MarkupKind.Markdown,
                                value: getComments(func.comments)
                            };
                        }
                        if (found) {
                            info.label += '(';
                            strIndex = info.label.length;
                            if (methodParams.length > 0) {
                                for (let i = 0; i < methodParams.length; i++) {
                                    const param = methodParams[i];
                                    const str = `${param.byRef ? 'byref ' : ''}${param.name} as ${param.dataType}`;
                                    info.label += str;
                                    info.parameters.push({
                                        label: [strIndex, strIndex + str.length],
                                        documentation: ''
                                    });
                                    strIndex += str.length;
                                    if (i < methodParams.length - 1) {
                                        info.label += ',';
                                        strIndex++;
                                    }
                                }
                            }
                            info.label += ')';
                            if (returnValue != '') {
                                info.label += ' as ' + returnValue;
                            }
                            help.signatures.push(info);
                        }
                    }
                    break;
            }
        }
        else {
            offset--;
        }
    }
    if (help.signatures.length > 0) {
        help.activeParameter = commaCount;
        return help;
    }
});
connection.onRenameRequest((params) => {
    const result = {
        changes: {}
    };
    const document = documents.get(params.textDocument.uri);
    let token = undefined;
    let tokenSymbolType = undefined;
    if (document != undefined) {
        const offset = document.offsetAt(params.position);
        const filePath = getFileName(params.textDocument.uri);
        token = projectParser.getTokenAtPosition(filePath, offset);
        if (token == undefined) {
            return result;
        }
        else {
            tokenSymbolType = getTokenSymbol(token);
        }
    }
    for (const fileName in preprocessor.originalFiles) {
        const contents = preprocessor.originalFiles[fileName];
        let index = 0;
        while (index >= 0) {
            if (token === null || token === void 0 ? void 0 : token.symbol.text) {
                let tmpIndex = index;
                tmpIndex = contents.indexOf(token === null || token === void 0 ? void 0 : token.symbol.text, index);
                if (tmpIndex == index || tmpIndex < 0) {
                    break;
                }
                const tmpToken = projectParser.getTokenAtPosition(fileName, tmpIndex);
                if (tmpToken != undefined) {
                    const tmpType = getTokenSymbol(tmpToken);
                    const fileUri = getFileUrl(fileName);
                    if (tmpType == tokenSymbolType && token.symbol.text == tmpToken.symbol.text && result.changes) {
                        if (result.changes[fileUri] == undefined) {
                            result.changes[fileUri] = [];
                        }
                        result.changes[fileUri].push({
                            range: {
                                start: getPosition(contents, tmpToken.symbol.start),
                                end: getPosition(contents, tmpToken.symbol.stop + 1)
                            },
                            newText: params.newName
                        });
                    }
                }
                index = tmpIndex + 1;
            }
            else {
                index = -1;
            }
        }
    }
    return result;
});
connection.onReferences((params) => {
    const result = [];
    const document = documents.get(params.textDocument.uri);
    let refs = [];
    if (document) {
        const offset = document.offsetAt(params.position);
        const filePath = getFileName(params.textDocument.uri);
        let token;
        let currentPosition = offset - 1;
        while (token == undefined) {
            token = projectParser.getTokenAtPosition(filePath, offset);
            currentPosition++;
            if (currentPosition > offset + 1) {
                break;
            }
        }
        if (token != undefined) {
            const text = token.getText();
            const varD = getVariable(text, token.symbol.source[1].name, token.symbol.start);
            if (varD != undefined) {
                refs = varD.references;
            }
            else if (projectParser.functions[text] != undefined) {
                refs = projectParser.functions[text].references;
            }
        }
    }
    for (let i = 0; i < refs.length; i++) {
        const ref = refs[i];
        result.push({
            uri: getFileUrl(ref.startToken.source[1].name),
            range: {
                start: { line: ref.startToken.line - 1, character: ref.startToken.column },
                // end: doc.positionAt(parserError.symbol.stop)
                end: { line: ref.stopToken.line - 1, character: ref.stopToken.column + (ref.stopToken.stop - ref.stopToken.start) + 1 }
            }
        });
    }
    return result;
});
connection.onPrepareRename((params) => {
    const document = documents.get(params.textDocument.uri);
    if (document != undefined) {
        const offset = document.offsetAt(params.position);
        const filePath = getFileName(params.textDocument.uri);
        const token = projectParser.getTokenAtPosition(filePath, offset - 1);
        if (token != undefined) {
            switch (token.symbol.type) {
                case TibboBasicParser.IDENTIFIER:
                    {
                        //get scope
                        const text = token.symbol.text.toLowerCase();
                        if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                            const obj = getObjectAtToken(token);
                            if (obj != undefined) {
                                return null;
                            }
                        }
                        if (preprocessor.defines[text] != undefined) {
                            return null;
                        }
                        if (projectParser.events[text] != undefined) {
                            return null;
                        }
                        if (projectParser.objects[text] != undefined) {
                            return null;
                        }
                        if (projectParser.functions[text] != undefined) {
                            const func = projectParser.functions[text];
                            if (func.location && func.location.startToken.source[1].name.indexOf(PLATFORMS_PATH) == 0) {
                                return null;
                            }
                        }
                        if (projectParser.consts[text] != undefined) {
                            const cc = projectParser.consts[text];
                            if (cc.location.startToken.source[1].name.indexOf(PLATFORMS_PATH) == 0) {
                                return null;
                            }
                        }
                        if (projectParser.syscalls[text] != undefined) {
                            return null;
                        }
                        if (projectParser.types[text] != undefined) {
                            const tt = projectParser.types[text];
                            if (tt.location.startToken.source[1].name.indexOf(PLATFORMS_PATH) == 0) {
                                return null;
                            }
                        }
                        if (projectParser.enums[text] != undefined) {
                            const enu = projectParser.enums[text];
                            if (enu.location.startToken.source[1].name.indexOf(PLATFORMS_PATH) == 0) {
                                return null;
                            }
                        }
                        for (const key in projectParser.enums) {
                            const enu = projectParser.enums[key];
                            for (let i = 0; i < enu.members.length; i++) {
                                if (enu.members[i].name == text) {
                                    if (enu.location.startToken.source[1].name.indexOf(PLATFORMS_PATH) == 0) {
                                        return null;
                                    }
                                }
                            }
                        }
                    }
                    break;
                default:
                    return null;
            }
            return {
                start: document.positionAt(token.symbol.start),
                end: document.positionAt(token.symbol.stop + 1)
            };
        }
    }
    return null;
});
function getFileName(uri) {
    let result = uri.replace('file://', '');
    if (uri.indexOf('%3A') >= 0) {
        result = uri.replace('file:///', '');
        result = result.replace('%3A', ':');
        // result = result.charAt(0).toUpperCase() + result.slice(1);
    }
    result = decodeURIComponent(result);
    result = result.split('/').join(path.sep);
    return result;
}
function getFileUrl(filePath) {
    let result = filePath.split(path.sep).join('/');
    if (result.charAt(0) != '/') {
        result = 'file:///' + result.replace(':', '%3A');
    }
    else {
        result = 'file://' + result;
    }
    return result;
}
function getVariable(variableName, filePath, offset) {
    const scope = projectParser.getScope(filePath, offset);
    let varD;
    for (let i = 0; i < projectParser.variables.length; i++) {
        if (projectParser.variables[i].name == variableName) {
            const tmp = projectParser.variables[i];
            if (scope != undefined && scope.start.start <= tmp.location.startToken.start && scope.end.start >= tmp.location.startToken.start) {
                //in same scope
                varD = tmp;
                break;
            }
            else {
                const declaredScope = projectParser.getScope(tmp.location.startToken.source[1].name, tmp.location.startToken.start);
                if (declaredScope == undefined) {
                    varD = tmp;
                }
            }
        }
    }
    return varD;
}
function getCommentString(comments) {
    const result = comments.map(comment => {
        return comment.text.substring(1);
    }).join('\n');
    return result;
}
function getComments(comments) {
    let result = comments.map(comment => {
        return comment.text.substring(1);
    }).join('\n');
    result = html2markdown(result);
    // result = turndownService.turndown(result);
    // result = mkconverter.makeMarkdown(result, dom.window.document);
    return result;
}
function parseFile(fileUri) {
    const doc = documents.get(fileUri);
    if (doc == undefined) {
        return;
    }
    const text = doc.getText();
    const currentFilePath = getFileName(fileUri);
    preprocessor.originalFiles[currentFilePath] = text;
    preprocessor.files[currentFilePath] = '';
    const filePath = getFileName(fileUri);
    const dirName = path.dirname(filePath);
    preprocessor.parseFile(dirName, path.basename(filePath));
    const fileContents = preprocessor.files[filePath];
    projectParser.parseFile(filePath, fileContents);
}
function notifyDiagnostics() {
    for (const filePath in preprocessor.files) {
        const fileURI = getFileUrl(filePath);
        const diagnostics = [];
        if (projectParser.errors[filePath] != undefined) {
            for (let i = 0; i < projectParser.errors[filePath].length; i++) {
                const parserError = projectParser.errors[filePath][i];
                const diagnostic = {
                    severity: vscode_languageserver_1.DiagnosticSeverity.Error,
                    range: {
                        start: { line: parserError.symbol.line - 1, character: parserError.symbol.column },
                        // end: doc.positionAt(parserError.symbol.stop)
                        end: { line: parserError.symbol.line - 1, character: parserError.symbol.column + (parserError.symbol.stop - parserError.symbol.start) + 1 }
                    },
                    message: parserError.message,
                    source: 'ex'
                };
                diagnostic.relatedInformation = [
                    {
                        location: {
                            uri: getFileUrl(filePath),
                            range: Object.assign({}, diagnostic.range)
                        },
                        message: parserError.message
                    }
                ];
                diagnostics.push(diagnostic);
            }
            // connection.sendDiagnostics({ uri: fileURI, diagnostics });
        }
        for (let i = 0; i < projectParser.variables.length; i++) {
            const variable = projectParser.variables[i];
            if (variable.references.length == 0) {
                const loc = variable.location;
                if (loc.startToken.source[1].name != filePath) {
                    continue;
                }
                // const diagnostic: Diagnostic = {
                //     severity: DiagnosticSeverity.Warning,
                //     range: {
                //         start: { line: loc.startToken.line - 1, character: loc.startToken.column },
                //         // end: doc.positionAt(parserError.symbol.stop)
                //         end: { line: loc.stopToken.line - 1, character: loc.stopToken.column + loc.stopToken.text.length }
                //     },
                //     message: `${variable.name} is not used anywhere`,
                //     source: 'ex'
                // };
                // diagnostic.relatedInformation = [
                //     {
                //         location: {
                //             uri: getFileUrl(filePath),
                //             range: Object.assign({}, diagnostic.range)
                //         },
                //         message: `Unused variable`,
                //     }
                // ];
                // diagnostics.push(diagnostic);
            }
        }
        for (const funcName in projectParser.functions) {
            if (projectParser.functions[funcName].references.length == 0 && projectParser.functions[funcName].declaration != undefined) {
                if (projectParser.events[funcName] != undefined) {
                    continue;
                }
                const loc = projectParser.functions[funcName].location;
                if (loc) {
                    if (loc.startToken.source[1].name != filePath) {
                        continue;
                    }
                    const diagnostic = {
                        severity: vscode_languageserver_1.DiagnosticSeverity.Warning,
                        range: {
                            start: { line: loc.startToken.line - 1, character: loc.startToken.column },
                            // end: doc.positionAt(parserError.symbol.stop)
                            end: { line: loc.stopToken.line - 1, character: loc.stopToken.column + loc.stopToken.text.length }
                        },
                        message: `${funcName} is not called anywhere`,
                        source: 'ex'
                    };
                    diagnostic.relatedInformation = [
                        {
                            location: {
                                uri: getFileUrl(filePath),
                                range: Object.assign({}, diagnostic.range)
                            },
                            message: `${funcName} is not called anywhere`,
                        }
                    ];
                    // diagnostics.push(diagnostic);
                }
            }
        }
        // diagnostics = [];
        // let index = 0;
        // const oLines = preprocessor.originalFiles[filePath].split('\n');
        // const nLines = preprocessor.files[filePath].split('\n');
        // const contents = preprocessor.originalFiles[filePath];
        // for (let i = 0; i < oLines.length; i++) {
        //     if (oLines[i] != nLines[i]) {
        //         const range = {
        //             start: getPosition(contents, index),
        //             end: getPosition(contents, index + oLines[i].length)
        //         };
        //         diagnostics.push({
        //             range: range,
        //             severity: 4,
        //             message: 'not included',
        //             tags: [
        //                 DiagnosticTag.Unnecessary
        //             ]
        //         });
        //     }
        //     index += oLines[i].length + 1;
        // }
        connection.sendDiagnostics({ uri: fileURI, diagnostics });
    }
}
function copyProperties() {
    preprocessor.defines = JSON.parse(JSON.stringify(platformPreprocessor.defines));
    preprocessor.codes = JSON.parse(JSON.stringify(platformPreprocessor.codes));
    preprocessor.files = JSON.parse(JSON.stringify(platformPreprocessor.files));
    // preprocessor.originalFiles = JSON.parse(JSON.stringify(platformPreprocessor.originalFiles));
    projectParser.objects = platformProjectParser.objects;
    projectParser.syscalls = platformProjectParser.syscalls;
    projectParser.events = platformProjectParser.events;
    projectParser.errors = platformProjectParser.errors;
    // const props = ['tokens', 'trees', 'events', 'enums', 'functions',
    //     'subs', 'consts', 'types'];
    // props.forEach((prop) => {
    //     projectParser[prop] = {};
    //     const obj = platformProjectParser[prop];
    //     for (const key in obj) {
    //         projectParser[prop][key] = obj[key];
    //     }
    // });
    projectParser.tokens = {};
    let obj = platformProjectParser.tokens;
    for (const key in obj) {
        projectParser.tokens[key] = obj[key];
    }
    projectParser.trees = {};
    obj = platformProjectParser.trees;
    for (const key in obj) {
        projectParser.trees[key] = obj[key];
    }
    projectParser.events = {};
    obj = platformProjectParser.events;
    for (const key in obj) {
        projectParser.events[key] = obj[key];
    }
    projectParser.enums = {};
    obj = platformProjectParser.enums;
    for (const key in obj) {
        projectParser.enums[key] = obj[key];
    }
    projectParser.functions = {};
    obj = platformProjectParser.functions;
    for (const key in obj) {
        projectParser.functions[key] = obj[key];
    }
    projectParser.consts = {};
    obj = platformProjectParser.consts;
    for (const key in obj) {
        projectParser.consts[key] = obj[key];
    }
    projectParser.types = {};
    obj = platformProjectParser.types;
    for (const key in obj) {
        projectParser.types[key] = obj[key];
    }
    projectParser.variables = [];
    projectParser.scopes = [];
    projectParser.variables = projectParser.variables.concat(platformProjectParser.variables);
    projectParser.scopes = projectParser.scopes.concat(platformProjectParser.scopes);
}
function getObjectAtToken(token) {
    while (token.parentCtx != undefined) {
        token = token.parentCtx;
        if (token.ruleIndex == TibboBasicParser.RULE_unaryExpression) {
            const name = token.start.text;
            if (projectParser.objects[name] != undefined) {
                return projectParser.objects[name];
            }
        }
    }
    return undefined;
}
function getObjectFunction(obj, functionName) {
    for (let i = 0; i < obj.functions.length; i++) {
        if (obj.functions[i].name == functionName) {
            return obj.functions[i];
        }
    }
    return undefined;
}
function getObjectProperty(obj, propName) {
    for (let i = 0; i < obj.properties.length; i++) {
        if (obj.properties[i].name == propName) {
            return obj.properties[i];
        }
    }
    return undefined;
}
function getTokenSymbol(token) {
    let symbolType = undefined;
    const text = token.symbol.text;
    switch (token.symbol.type) {
        case TibboBasicParser.IDENTIFIER:
            //get scope
            if (token.parentCtx.ruleIndex == TibboBasicParser.RULE_postfixExpression) {
                const obj = getObjectAtToken(token);
                if (obj != undefined) {
                    const func = getObjectFunction(obj, token.symbol.text);
                    const prop = getObjectProperty(obj, token.symbol.text);
                    if (func != undefined) {
                        symbolType = types_1.TBSymbolType.OBJECT_PROPERTY;
                    }
                    else if (prop != undefined) {
                        symbolType = types_1.TBSymbolType.OBJECT_PROPERTY;
                    }
                }
            }
            else if (preprocessor.defines[text] != undefined) {
                symbolType = types_1.TBSymbolType.DEFINE;
            }
            else if (projectParser.events[text.toLowerCase()] != undefined) {
                //
            }
            else if (projectParser.objects[text.toLowerCase()] != undefined) {
                symbolType = types_1.TBSymbolType.OBJECT;
            }
            else if (projectParser.functions[text] != undefined) {
                if (projectParser.functions[text].dataType != undefined) {
                    symbolType = types_1.TBSymbolType.FUNCTION;
                }
                else {
                    symbolType = types_1.TBSymbolType.SUB;
                }
            }
            else if (projectParser.consts[text] != undefined) {
                symbolType = types_1.TBSymbolType.CONST;
            }
            else if (projectParser.enums[text.toLowerCase()] != undefined) {
                symbolType = types_1.TBSymbolType.ENUM;
            }
            else if (projectParser.syscalls[text] != undefined) {
                symbolType = types_1.TBSymbolType.SYSCALL;
            }
            else if (projectParser.types[text.toLowerCase()] != undefined) {
                symbolType = types_1.TBSymbolType.TYPE;
            }
            if (symbolType == undefined) {
                //enums
                for (const key in projectParser.enums) {
                    const enumItem = projectParser.enums[key];
                    for (let i = 0; i < enumItem.members.length; i++) {
                        if (text.toLowerCase() == enumItem.members[i].name.toLowerCase()) {
                            symbolType = types_1.TBSymbolType.ENUM_MEMBER;
                            break;
                        }
                    }
                }
            }
            if (symbolType == undefined) {
                //TODO get correct variable at scope
                const varD = getVariable(text, token.symbol.source[1].name, token.symbol.start);
                if (varD != undefined) {
                    symbolType = types_1.TBSymbolType.DIM;
                }
            }
            break;
    }
    return symbolType;
}
function getProjectStructure() {
    //TODO only send structure if changed
    const notification = new rpc.NotificationType('projectExplorer');
    const objects = [];
    const events = [];
    Object.keys(projectParser.objects).forEach((key) => {
        const object = projectParser.objects[key];
        const children = [];
        const item = {
            name: key,
            docs: getCommentString(object.comments),
            children: children,
        };
        for (let i = 0; i < object.properties.length; i++) {
            children.push({
                name: object.properties[i].name,
                docs: getCommentString(object.properties[i].comments)
            });
        }
        objects.push(item);
    });
    Object.keys(projectParser.events).forEach((key) => {
        const event = projectParser.events[key];
        const item = {
            name: key,
            docs: getCommentString(event.comments)
        };
        events.push(item);
    });
    const tmpRootItems = [
        {
            name: PROJECT_EXPLORER_EVENTS,
            children: events,
            docs: 'Platform Events. Double click on event to create or edit an event handler in the source code.'
        },
        {
            name: PROJECT_EXPLORER_PROJECT,
            children: [],
            docs: ''
        },
        {
            name: PROJECT_EXPLORER_LIBRARIES,
            children: [],
            docs: ''
        },
        {
            name: PROJECT_EXPLORER_PLATFORM,
            children: [
                {
                    name: 'Objects',
                    children: objects,
                    docs: 'Platform objects. Hover over an item name to get help.'
                }
            ],
            docs: ''
        }
    ];
    if (objects.length > 0) {
        if (JSON.stringify(rootItems) != JSON.stringify(tmpRootItems)) {
            rootItems = tmpRootItems;
        }
        sortProjectChildren(rootItems);
        connection.sendNotification(notification, JSON.stringify(rootItems));
    }
}
function sortProjectChildren(children) {
    children.sort((a, b) => {
        if (a.name < b.name)
            return -1;
        if (a.name > b.name)
            return 1;
        return 0;
    });
    for (let i = 0; i < children.length; i++) {
        const items = children[i].children;
        if (items != undefined) {
            sortProjectChildren(items);
        }
    }
}
function getPosition(text, offset) {
    const lines = text.split('\n');
    let index = 0;
    let lineNumber = 0;
    let column = 0;
    for (let i = 0; i < lines.length; i++) {
        const len = lines[i].length + 1; //include newline
        if (index + len < offset) {
            index += len;
        }
        else {
            lineNumber = i;
            column = offset - index;
            break;
        }
    }
    return {
        line: lineNumber,
        character: column
    };
}
connection.onDidOpenTextDocument((params) => {
    // A text document got opened in VSCode.
    // params.uri uniquely identifies the document. For documents store on disk this is a file URI.
    // params.text the initial full content of the document.
    connection.console.log(`${params.textDocument.uri} opened.`);
});
connection.onDidChangeTextDocument((params) => {
    // The content of a text document did change in VSCode.
    // params.uri uniquely identifies the document.
    // params.contentChanges describe the content changes to the document.
    connection.console.log(`${params.textDocument.uri} changed: ${JSON.stringify(params.contentChanges)}`);
});
connection.onDidCloseTextDocument((params) => {
    // A text document got closed in VSCode.
    // params.uri uniquely identifies the document.
    connection.console.log(`${params.textDocument.uri} closed.`);
});
// Make the text document manager listen on the connection
// for open, change and close text document events
documents.listen(connection);
// Listen on the connection
connection.listen();
//# sourceMappingURL=TibboBasicLanguageServer.js.map