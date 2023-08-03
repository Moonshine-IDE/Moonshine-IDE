"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TibboBasicProjectParser = void 0;
/* eslint-disable @typescript-eslint/no-var-requires */
const fs = require("fs");
// import path = require('path');
// import ini = require('ini');
const TibboBasicErrorListener_1 = require("./TibboBasicErrorListener");
const antlr4 = require('antlr4');
const TibboBasicLexer = require('../language/TibboBasic/lib/TibboBasicLexer').TibboBasicLexer;
const TibboBasicParser = require('../language/TibboBasic/lib/TibboBasicParser').TibboBasicParser;
const TibboBasicParserListener = require('../language/TibboBasic/lib/TibboBasicParserListener').TibboBasicParserListener;
class TibboBasicProjectParser {
    constructor() {
        this.objects = {};
        this.syscalls = {};
        this.tokens = {};
        this.trees = {};
        this.events = {};
        this.errors = {};
        this.enums = {};
        this.functions = {};
        this.consts = {};
        this.types = {};
        this.comments = {};
        this.variables = [];
        this.scopes = [];
        this.symbolDeclarations = {};
        this.references = {};
    }
    parseFile(filePath, fileContents) {
        // const t1 = new Date().getTime();
        let deviceRootFile = '';
        if (fileContents != undefined) {
            deviceRootFile = fileContents;
        }
        else {
            deviceRootFile = fs.readFileSync(filePath, 'utf-8');
        }
        if (deviceRootFile == undefined) {
            return;
        }
        this.resetFileSymbols(filePath);
        // console.log(`Parsing ${filePath}`);
        const chars = new antlr4.InputStream(deviceRootFile);
        chars.name = filePath;
        const lexer = new TibboBasicLexer(chars);
        const tokens = new antlr4.CommonTokenStream(lexer);
        const parser = new TibboBasicParser(tokens);
        parser.buildParseTrees = true;
        const errorListener = new TibboBasicErrorListener_1.TibboBasicErrorListener();
        lexer.removeErrorListeners();
        // lexer.addErrorListener(errorListener);
        parser.removeErrorListeners();
        parser.addErrorListener(errorListener);
        const tree = parser.startRule();
        this.tokens[filePath] = tokens;
        this.trees[filePath] = tree;
        const listener = new ParserListener(this);
        antlr4.tree.ParseTreeWalker.DEFAULT.walk(listener, tree);
        if (errorListener.errors.length > 0) {
            // console.log(errorListener.errors);
        }
        this.errors[filePath] = errorListener.errors;
        // const t2 = new Date().getTime();
        // const secondsElapsed = (t2 - t1) / 1000;
        // console.log(`parsed file in ${secondsElapsed} s`);
    }
    getTokenAtPosition(filePath, offset) {
        let tree = this.trees[filePath];
        if (tree == undefined) {
            tree = this.trees[filePath.charAt(0).toUpperCase() + filePath.slice(1)];
        }
        if (tree != undefined) {
            return this.findToken(offset, tree.children);
        }
    }
    findToken(offset, children) {
        for (let i = 0; i < children.length; i++) {
            if (children[i].children == undefined) {
                if (children[i].symbol && children[i].symbol.start <= offset && children[i].symbol.stop >= offset) {
                    return children[i];
                }
            }
            else {
                const item = this.findToken(offset, children[i].children);
                if (item != undefined) {
                    return item;
                }
            }
        }
        return undefined;
    }
    getScope(filePath, offset) {
        for (let i = 0; i < this.scopes.length; i++) {
            if (this.scopes[i].file == filePath) {
                if (this.scopes[i].start.start <= offset && this.scopes[i].end.start >= offset) {
                    return this.scopes[i];
                }
            }
        }
        return undefined;
    }
    getScopeVariables(scope) {
        const variables = [];
        if (!scope) {
            return variables;
        }
        for (let i = 0; i < this.variables.length; i++) {
            const variable = this.variables[i];
            if (variable.location.startToken.source[1].name == scope.file) {
                if (variable.location.startToken.start >= scope.start.start
                    && variable.location.startToken.start < scope.end.start) {
                    variables.push(variable);
                }
            }
        }
        return variables;
    }
    constructComments() {
        this.comments = {};
        for (const key in this.tokens) {
            const tokens = this.tokens[key].tokens;
            for (let i = 0; i < tokens.length; i++) {
                if (tokens[i].channel == TibboBasicLexer.COMMENTS_CHANNEL) {
                    const token = tokens[i];
                    const fileName = token.source[1].name;
                    if (this.comments[fileName] == undefined) {
                        this.comments[fileName] = [];
                    }
                    this.comments[fileName].push(token);
                }
            }
        }
        for (const key in this.objects) {
            const items = [
                this.objects[key].properties,
                this.objects[key].functions,
                this.objects[key].events
            ];
            items.forEach(prop => {
                for (let i = 0; i < prop.length; i++) {
                    const item = prop[i];
                    item.comments = this.findComments(item.location.stopToken);
                }
            });
            this.objects[key].comments = this.findComments(this.objects[key].location.stopToken);
        }
        let queue = [
            this.enums,
            this.consts,
            this.functions,
            this.variables,
            this.types,
            this.syscalls
        ];
        queue.forEach((table) => {
            for (const key in table) {
                const item = table[key];
                if (!item.location) {
                    continue;
                }
                const fileName = item.location.startToken.source[1].name;
                if (this.symbolDeclarations[fileName] == undefined) {
                    this.symbolDeclarations[fileName] = [];
                }
                this.symbolDeclarations[fileName].push(item.location.startToken.line);
                if (item['members'] != undefined) {
                    for (let i = 0; i < item['members'].length; i++) {
                        this.symbolDeclarations[fileName].push(item['members'][i].location.startToken.line);
                    }
                }
            }
        });
        queue = [
            this.enums,
            this.consts,
            this.variables,
            this.types
        ];
        queue.forEach((table) => {
            for (const key in table) {
                const item = table[key];
                if (!item.location) {
                    continue;
                }
                const fileName = item.location.startToken.source[1].name;
                if (this.symbolDeclarations[fileName] == undefined) {
                    this.symbolDeclarations[fileName] = [];
                }
                item.comments = this.findComments(item.location.stopToken, true);
                if (item['members'] != undefined) {
                    for (let i = 0; i < item['members'].length; i++) {
                        if (item['members'][i].comments.length == 0) {
                            item['members'][i].comments =
                                this.findComments(item['members'][i].location.stopToken, true);
                        }
                    }
                }
            }
        });
        queue = [
            this.functions,
            this.syscalls
        ];
        queue.forEach((table) => {
            for (const key in table) {
                const item = table[key];
                if (!item.location) {
                    continue;
                }
                const fileName = item.location.startToken.source[1].name;
                if (this.symbolDeclarations[fileName] == undefined) {
                    this.symbolDeclarations[fileName] = [];
                }
                item.comments = this.findComments(item.location.stopToken);
            }
        });
    }
    findComments(location, startsInline = false) {
        const filePath = location.source[1].name;
        let line = location.line;
        const comments = [];
        const fileComments = this.comments[filePath];
        if (fileComments == undefined) {
            return comments;
        }
        for (let i = 0; i < fileComments.length; i++) {
            let found = false;
            if (comments.length == 0 && !startsInline) {
                if (line == fileComments[i].line || line + 1 == fileComments[i].line) {
                    found = true;
                    if (line + 1 == fileComments[i].line) {
                        line++;
                    }
                }
            }
            else if (line == fileComments[i].line) {
                found = true;
            }
            if (found) {
                if (this.symbolDeclarations[filePath] &&
                    this.symbolDeclarations[filePath].includes(line)) {
                    if (startsInline && line != location.line) {
                        break;
                    }
                }
                const comment = fileComments[i];
                comments.push(comment);
                line++;
            }
        }
        return comments;
    }
    addVariable(variable) {
        //TODO set scope of variable
        let found = false;
        for (let i = 0; i < this.variables.length; i++) {
            if (this.variables[i].name == variable.name) {
                if (this.variables[i].location.startToken.line == variable.location.startToken.line ||
                    Math.abs(variable.location.startToken.line - this.variables[i].location.startToken.line) < 3) {
                    found = true;
                }
            }
        }
        if (!found) {
            this.variables.push(variable);
        }
    }
    resetFileSymbols(filePath) {
        // enums: { [name: string]: TBEnum } = {};
        // functions: { [name: string]: TBFunction } = {};
        // subs: { [name: string]: TBSub } = {};
        // consts: { [name: string]: TBConst } = {};
        // types: { [name: string]: TBType } = {};
        // comments: { [fileName: string]: CommonToken[] } = {};
        // variables: Array<TBVariable> = [];
        // scopes: Array<TBScope> = [];
        // symbolDeclarations: { [fileName: string]: number[] } = {};
        for (const key in this.enums) {
            if (this.enums[key].location.startToken.source[1].name == filePath) {
                delete this.enums[key];
            }
        }
        for (const key in this.functions) {
            if (this.events[key] == undefined) {
                const location = this.functions[key].location;
                const func = this.functions[key];
                if (location != undefined) {
                    if (location.startToken.source[1].name == filePath) {
                        delete this.functions[key];
                    }
                }
                for (let i = 0; i < func.references.length; i++) {
                    if (func.references[i].startToken.source[1].name == filePath) {
                        func.references.splice(i, 1);
                        i--;
                    }
                }
            }
        }
        for (const key in this.consts) {
            if (this.consts[key].location.startToken.source[1].name == filePath) {
                delete this.consts[key];
            }
        }
        for (const key in this.types) {
            if (this.types[key].location.startToken.source[1].name == filePath) {
                delete this.types[key];
            }
        }
        for (let i = 0; i < this.scopes.length; i++) {
            if (this.scopes[i].file == filePath) {
                this.scopes.splice(i, 1);
                i--;
            }
        }
        for (let i = 0; i < this.variables.length; i++) {
            if (this.variables[i].location.startToken.source[1].name == filePath) {
                this.variables.splice(i, 1);
            }
        }
    }
}
exports.TibboBasicProjectParser = TibboBasicProjectParser;
class ParserListener extends TibboBasicParserListener {
    constructor(parser) {
        super();
        this.scopeStack = [];
        this.parser = parser;
    }
    enterObjectDeclaration(ctx) {
        const name = ctx.children[1].symbol.text;
        this.parser.objects[name] = {
            name: name,
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            properties: [],
            events: [],
            functions: [],
            comments: []
        };
    }
    enterEnumerationStmt(ctx) {
        const name = ctx.children[1].symbol.text.toLowerCase();
        this.parser.enums[name] = {
            name: name,
            members: [],
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            comments: []
        };
    }
    enterEnumerationStmt_Constant(ctx) {
        const enumName = ctx.parentCtx.children[1].symbol.text.toLowerCase();
        const name = ctx.children[0].symbol.text.toLowerCase();
        const value = (this.parser.enums[enumName].members.length).toString().toLowerCase();
        this.parser.enums[enumName].members.push({
            name: name,
            value: value,
            comments: [],
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
        });
    }
    enterSyscallDeclarationInner(ctx) {
        if (ctx.object != null) {
            const objectName = ctx.object.text;
            const functionName = ctx.property.text;
            if (this.parser.objects[objectName] != undefined) {
                this.parser.objects[objectName].functions.push({
                    name: functionName,
                    syscall: undefined,
                    location: {
                        startToken: ctx.start,
                        stopToken: ctx.start
                    },
                    parameters: [],
                    variables: [],
                    dataType: '',
                    comments: []
                });
            }
        }
        else {
            //non object syscall
            const name = ctx.property.text;
            let valueType = '';
            for (let i = 0; i < ctx.children.length; i++) {
                if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                    valueType = ctx.children[i].valueType.getText();
                }
            }
            this.parser.syscalls[name] = {
                name: name,
                parameters: [],
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                dataType: valueType,
                comments: []
            };
        }
    }
    enterPropertyDefineStmt(ctx) {
        const objectName = ctx.object.text;
        const propertyName = ctx.property.text;
        if (this.parser.objects[objectName] != undefined) {
            this.currentObject = objectName;
            this.currentProperty = propertyName;
            this.parser.objects[objectName].properties.push({
                name: propertyName,
                dataType: '',
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.start
                },
                comments: []
            });
        }
    }
    exitPropertyDefineStmt(ctx) {
        this.currentObject = undefined;
        this.currentProperty = undefined;
    }
    enterAsTypeClause(ctx) {
        if (ctx.parentCtx.ruleIndex == TibboBasicParser.RULE_propertyGetStmt && this.currentObject != undefined) {
            const valueType = ctx.valueType.getText();
            for (let i = 0; i < this.parser.objects[this.currentObject].properties.length; i++) {
                if (this.parser.objects[this.currentObject].properties[i].name == this.currentProperty) {
                    this.parser.objects[this.currentObject].properties[i].dataType = valueType;
                    break;
                }
            }
        }
    }
    enterSubStmt(ctx) {
        if (ctx.name) {
            const name = ctx.name.text;
            this.addFunction(name, {
                location: {
                    startToken: ctx.start,
                    stopToken: ctx.name
                },
            });
            const scope = {
                file: ctx.start.source[1].name,
                start: ctx.start,
                end: ctx.stop
            };
            this.parser.scopes.push(scope);
            this.scopeStack.push(scope);
        }
    }
    exitSubStmt(ctx) {
        this.scopeStack.pop();
    }
    enterFunctionStmt(ctx) {
        if (ctx.name) {
            const name = ctx.name.text;
            let length = '';
            let location = {
                startToken: ctx.start,
                stopToken: ctx.start
            };
            for (let i = 0; i < ctx.children.length; i++) {
                if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                    const valueType = ctx.children[i].valueType.getText();
                    if (ctx.children[i].children.length >= 4) {
                        length = ctx.children[i].children[2].getText();
                    }
                    location = {
                        startToken: ctx.start,
                        stopToken: ctx.children[i].stop
                    };
                    const variable = {
                        name: name,
                        value: '',
                        length: length,
                        dataType: valueType,
                        location: {
                            startToken: ctx.name,
                            stopToken: ctx.name
                        },
                        references: [],
                        comments: []
                    };
                    variable.parentScope = this.scopeStack[this.scopeStack.length - 1];
                    this.parser.addVariable(variable);
                }
            }
            this.addFunction(name, {
                dataType: ctx.returnType.children[1].getText(),
                location: location,
            });
            const scope = {
                file: ctx.start.source[1].name,
                start: ctx.start,
                end: ctx.stop
            };
            this.parser.scopes.push(scope);
            this.scopeStack.push(scope);
        }
    }
    enterConstSubStmt(ctx) {
        this.parser.consts[ctx.name.text] = {
            name: ctx.name.text,
            value: ctx.value.getText(),
            location: {
                startToken: ctx.start,
                stopToken: ctx.stop
            },
            comments: []
        };
    }
    enterVariableListItem(ctx) {
        if (ctx.parentCtx.variableType === null) {
            return;
        }
        const variableType = ctx.parentCtx.variableType.valueType.getText();
        let length = '';
        if (ctx.children.length >= 4) {
            length = ctx.children[2].getText();
        }
        const name = ctx.children[0].symbol.text;
        const variable = {
            name: name,
            value: '',
            length: length,
            dataType: variableType,
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            references: [],
            comments: []
        };
        variable.parentScope = this.scopeStack[this.scopeStack.length - 1];
        this.parser.addVariable(variable);
    }
    enterParam(ctx) {
        if (ctx.parentCtx.parentCtx.ruleIndex == TibboBasicParser.RULE_declareSubStmt ||
            ctx.parentCtx.parentCtx.ruleIndex == TibboBasicParser.RULE_declareFuncStmt) {
            return;
        }
        let valueType = 'void';
        let length = '';
        ctx.children.forEach((element) => {
            if (element.ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                valueType = element.valueType.getText();
                if (element.children.length >= 4) {
                    length = element.children[2].getText();
                }
            }
        });
        const variable = {
            name: ctx.name.text,
            value: '',
            length: length,
            dataType: valueType,
            location: {
                startToken: ctx.name,
                stopToken: ctx.name
            },
            references: [],
            comments: []
        };
        const param = {
            name: ctx.name.text,
            dataType: valueType,
            byRef: ctx.byref != null
        };
        this.parser.addVariable(variable);
        if (ctx.parentCtx.parentCtx.ruleIndex == TibboBasicParser.RULE_subStmt) {
            this.parser.functions[ctx.parentCtx.parentCtx.name.text].parameters.push(param);
        }
        if (ctx.parentCtx.parentCtx.ruleIndex == TibboBasicParser.RULE_functionStmt) {
            this.parser.functions[ctx.parentCtx.parentCtx.name.text].parameters.push(param);
        }
        if (ctx.parentCtx.parentCtx.ruleIndex == TibboBasicParser.RULE_syscallDeclarationInner) {
            const objName = ctx.parentCtx.parentCtx.object;
            if (objName) {
                const obj = this.parser.objects[ctx.parentCtx.parentCtx.children[0].symbol.text];
                const prop = ctx.parentCtx.parentCtx.children[2].symbol.text;
                for (let i = 0; i < obj.functions.length; i++) {
                    if (obj.functions[i].name == prop) {
                        obj.functions[i].parameters.push(param);
                        break;
                    }
                }
            }
            else {
                this.parser.syscalls[ctx.parentCtx.parentCtx.children[0].symbol.text].parameters.push(param);
            }
        }
    }
    enterBlockIfThenElse(ctx) {
        const scope = {
            file: ctx.start.source[1].name,
            start: ctx.start,
            end: ctx.stop,
            parentScope: this.scopeStack[this.scopeStack.length - 1]
        };
        this.parser.scopes.push(scope);
        this.scopeStack.push(scope);
    }
    exitBlockIfThenElse(ctx) {
        this.scopeStack.pop();
    }
    enterDeclareSubStmt(ctx) {
        const name = ctx.children[2].symbol.text;
        this.addFunction(name, {
            declaration: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
        });
    }
    enterDeclareFuncStmt(ctx) {
        const name = ctx.children[2].symbol.text;
        this.addFunction(name, {
            declaration: {
                startToken: ctx.start,
                stopToken: ctx.start
            }
        });
    }
    enterInlineIfThenElse(ctx) {
        const scope = {
            file: ctx.start.source[1].name,
            start: ctx.start.start,
            end: ctx.stop.stop,
            parentScope: this.scopeStack[this.scopeStack.length - 1]
        };
        this.parser.scopes.push(scope);
        this.scopeStack.push(scope);
    }
    exitInlineIfThenElse(ctx) {
        this.scopeStack.pop();
    }
    enterTypeStmt(ctx) {
        const name = ctx.children[1].getText();
        const members = [];
        for (let i = 0; i < ctx.children.length; i++) {
            if (ctx.children[i].ruleIndex == TibboBasicParser.RULE_typeStmtElement) {
                const item = ctx.children[i];
                const varName = item.children[0].getText();
                let dataType = '';
                const length = '';
                let asType = item.children[1];
                for (let j = 0; j < item.children.length; j++) {
                    if (item.children[j].ruleIndex && item.children[j].ruleIndex == TibboBasicParser.RULE_asTypeClause) {
                        asType = item.children[j];
                        break;
                    }
                }
                dataType = asType.children[1].getText();
                const variable = {
                    name: varName,
                    value: '',
                    length: length,
                    dataType: dataType,
                    location: {
                        startToken: item.start,
                        stopToken: item.start
                    },
                    references: [],
                    comments: []
                };
                members.push(variable);
            }
        }
        this.parser.types[name] = {
            name: name,
            members: members,
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            comments: []
        };
    }
    enterEventDeclaration(ctx) {
        const name = ctx.name.text;
        const params = [];
        this.parser.events[name] = {
            name: name,
            eventNumber: ctx.number,
            parameters: params,
            location: {
                startToken: ctx.start,
                stopToken: ctx.start
            },
            comments: []
        };
    }
    getComments(ctx) {
        let comments = '';
        if (ctx && ctx.children) {
            for (let i = 0; i < ctx.children.length; i++) {
                comments += ctx.children[i].getText().substring(1);
            }
        }
        return comments;
    }
    enterPrimaryExpression(ctx) {
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            if (item.ruleIndex == TibboBasicParser.RULE_literal && item.start.type == TibboBasicParser.IDENTIFIER) {
                const location = {
                    startToken: ctx.start,
                    stopToken: ctx.start
                };
                // let symbolName = item.start.text;
                // this.addSymbolReference(symbolName, location);
                // this.addFunction(symbolName, {});
                // this.parser.functions[symbolName].references.push(location);
            }
        }
    }
    enterExpression(ctx) {
        if (!ctx.children) {
            return;
        }
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            if (item.ruleIndex == TibboBasicParser.RULE_literal && item.start.type == TibboBasicParser.IDENTIFIER) {
                const symbolName = item.start.text;
                console.log(symbolName);
            }
            // console.log(ctx.getText());
        }
    }
    addFunction(name, func) {
        if (name != undefined) {
            if (this.parser.functions[name] == undefined) {
                this.parser.functions[name] = {
                    name: name,
                    parameters: [],
                    comments: [],
                    variables: [],
                    references: []
                };
            }
        }
        this.parser.functions[name] = {
            ...this.parser.functions[name],
            ...func,
        };
    }
}
//# sourceMappingURL=TibboBasicProjectParser.js.map