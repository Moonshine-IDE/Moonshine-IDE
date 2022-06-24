"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PreprocessorListener = void 0;
const fs = require("fs");
const path = require("path");
const ini = require("ini");
const TibboBasicErrorListener_1 = require("./TibboBasicErrorListener");
const antlr4 = require('antlr4');
const TibboBasicPreprocessorLexer = require('../language/TibboBasic/lib/TibboBasicPreprocessorLexer').TibboBasicPreprocessorLexer;
const TibboBasicPreprocessorParser = require('../language/TibboBasic/lib/TibboBasicPreprocessorParser').TibboBasicPreprocessorParser;
const TibboBasicPreprocessorParserListener = require('../language/TibboBasic/lib/TibboBasicPreprocessorParserListener').TibboBasicPreprocessorParserListener;
class TibboBasicPreprocessor {
    constructor(projectPath, platformsPath) {
        this.defines = {};
        this.codes = {};
        this.files = {};
        this.filePriorities = [];
        this.originalFiles = {};
        let tprPath = '';
        this.projectPath = projectPath;
        fs.readdirSync(projectPath).forEach(file => {
            const ext = path.extname(file);
            if (ext == '.tpr') {
                tprPath = path.join(projectPath, file);
            }
        });
        const tpr = ini.parse(fs.readFileSync(tprPath, 'utf-8'));
        this.platformType = tpr['project']['platform'];
        this.platformsPath = platformsPath;
        this.platformVersion = tpr['project']['src_lib_ver'];
    }
    parsePlatforms() {
        this.codes = {};
        this.defines = {};
        //parse platforms
        const currentPath = path.join(this.platformsPath, this.platformType);
        this.parseFile(currentPath, this.platformType + '.tph');
    }
    getFilePath(currentDirectory, filePath) {
        const platformLibs = path.join(this.platformsPath, 'src', this.platformVersion);
        if (fs.existsSync(path.join(platformLibs, filePath.toLowerCase()))) {
            filePath = filePath.toLowerCase();
        }
        if (fs.existsSync(path.join(this.projectPath, filePath.toLowerCase()))) {
            filePath = filePath.toLowerCase();
        }
        if (fs.existsSync(path.join(currentDirectory, filePath.toLowerCase()))) {
            filePath = filePath.toLowerCase();
        }
        if (fs.existsSync(path.join(platformLibs, filePath))) { //check platforms path
            filePath = path.join(platformLibs, filePath);
        }
        else if (fs.existsSync(path.join(this.projectPath, filePath))) {
            filePath = path.join(this.projectPath, filePath);
        }
        else { //check relative
            filePath = path.join(currentDirectory, filePath);
        }
        return filePath;
    }
    parseFile(currentDirectory, filePath, update = false) {
        filePath = this.getFilePath(currentDirectory, filePath);
        if (this.files[filePath] && !update) {
            return filePath;
        }
        let deviceRootFile = '';
        if (this.originalFiles[filePath] == undefined) {
            this.filePriorities.push(filePath);
            deviceRootFile = fs.readFileSync(filePath, 'utf-8');
            this.originalFiles[filePath] = deviceRootFile;
        }
        deviceRootFile = this.originalFiles[filePath];
        const chars = new antlr4.InputStream(deviceRootFile);
        chars.name = filePath;
        let blankFile = this.originalFiles[filePath];
        blankFile = blankFile.replace(/[^\r\n\t]/g, ' ');
        this.files[filePath] = blankFile;
        this.codes[filePath] = [];
        const lexer = new TibboBasicPreprocessorLexer(chars);
        const tokens = new antlr4.CommonTokenStream(lexer);
        const parser = new TibboBasicPreprocessorParser(tokens);
        parser.buildParseTrees = true;
        const errorListener = new TibboBasicErrorListener_1.default();
        lexer.removeErrorListeners();
        // lexer.addErrorListener(errorListener);
        parser.removeErrorListeners();
        parser.addErrorListener(errorListener);
        const tree = parser.preprocessor();
        const preprocessor = new PreprocessorListener(filePath, this, chars);
        antlr4.tree.ParseTreeWalker.DEFAULT.walk(preprocessor, tree);
        if (errorListener.errors.length > 0) {
            // console.log(errorListener.errors);
        }
        return filePath;
    }
}
exports.default = TibboBasicPreprocessor;
class PreprocessorListener extends TibboBasicPreprocessorParserListener {
    constructor(filePath, preprocessor, charStream) {
        super();
        this.expressionStack = [];
        this.preprocessor = preprocessor;
        this.filePath = filePath;
        this.charStream = charStream;
        this.lastLine = 0;
        this.currentBlock = undefined;
    }
    enterCodeLine(ctx) {
        if (this.currentBlock != undefined) {
            if (this.currentBlock.shouldEvaluate) {
                if (this.getCurrentStack()) {
                    this.addCode(ctx);
                }
                else {
                    if (ctx.start.line == this.lastLine) {
                        this.addCode(ctx);
                    }
                }
            }
        }
        else {
            this.addCode(ctx);
        }
    }
    enterPreprocessorDefine(ctx) {
        if (this.getCurrentStack()) {
            const name = ctx.children[2].symbol.text;
            if (ctx.children.length == 4) { //define has value
                this.preprocessor.defines[name] = {
                    name: name,
                    value: ctx.children[3].start.text.trim(),
                    line: ctx.start.line
                };
            }
            else { //define with no value
                this.preprocessor.defines[name] = {
                    name: name,
                    value: "",
                    line: ctx.start.line
                };
            }
            this.addCode(ctx);
        }
    }
    enterPreprocessorInclude(ctx) {
        if (this.getCurrentStack()) {
            const symbol = ctx.children[1].symbol.text;
            let filePath = symbol.substring(1, symbol.length - 1);
            filePath = filePath.split('\\').join(path.sep);
            this.addCode(ctx);
            if (path.basename(this.filePath) == filePath) {
                return;
            }
            if (filePath == 'global.tbh') {
                return;
            }
            this.preprocessor.parseFile(path.dirname(this.filePath), filePath, true);
        }
    }
    enterPreprocessorDef(ctx) {
        if (this.currentBlock == undefined || this.currentBlock && this.currentBlock.shouldEvaluate) {
            this.addBlock(ctx);
            const type = ctx.children[1].symbol.type;
            const name = ctx.children[2].symbol.text;
            switch (type) {
                case TibboBasicPreprocessorParser.IFDEF:
                    this.addEvaluationResult(this.preprocessor.defines[name] != undefined, ctx);
                    break;
                case TibboBasicPreprocessorParser.IFNDEF:
                    this.addEvaluationResult(this.preprocessor.defines[name] == undefined, ctx);
                    break;
            }
            this.addCode(ctx);
        }
        else {
            this.addBlock(ctx);
            this.addEvaluationResult(false, ctx);
        }
    }
    enterPreprocessorUndef(ctx) {
        if (this.getCurrentStack()) {
            const name = ctx.children[1].symbol.text;
            this.defines[name] = undefined;
            this.addCode(ctx);
        }
    }
    enterPreprocessorEndConditional(ctx) {
        if (this.currentBlock != undefined) {
            if (this.currentBlock.shouldEvaluate) {
                this.addCode(ctx);
            }
            this.currentBlock = this.currentBlock.parentBlock;
        }
        else {
            this.addCode(ctx);
        }
    }
    enterPreprocessorConditional(ctx) {
        let shouldEvaluate = false;
        switch (ctx.children[1].symbol.type) {
            case TibboBasicPreprocessorParser.IF:
                if (this.currentBlock == undefined || (this.currentBlock
                    && this.currentBlock.shouldEvaluate)) {
                    if (this.currentBlock) {
                        if (this.currentBlock.evaluationResults[0]) {
                            shouldEvaluate = true;
                        }
                    }
                    else {
                        shouldEvaluate = true;
                    }
                }
                this.addBlock(ctx);
                break;
            case TibboBasicPreprocessorParser.ELIF:
                {
                    let found = false;
                    if (this.currentBlock != undefined && this.currentBlock.shouldEvaluate) {
                        for (let i = 0; i < this.currentBlock.evaluationResults.length; i++) {
                            if (this.currentBlock.evaluationResults[i]) {
                                found = true;
                            }
                        }
                    }
                    if (!found) {
                        shouldEvaluate = true;
                    }
                    else {
                        this.addEvaluationResult(false, ctx);
                    }
                }
                break;
            case TibboBasicPreprocessorParser.ELSE:
                {
                    let found = false;
                    if (this.currentBlock != undefined && this.currentBlock.shouldEvaluate) {
                        for (let i = 0; i < this.currentBlock.evaluationResults.length; i++) {
                            if (this.currentBlock.evaluationResults[i]) {
                                found = true;
                            }
                        }
                    }
                    if (!found) {
                        this.addCode(ctx);
                        this.addEvaluationResult(true, ctx);
                        return;
                    }
                    else {
                        this.addEvaluationResult(false, ctx);
                    }
                }
                break;
        }
        this.addCode(ctx);
        if (shouldEvaluate) {
            const result = this.evaluate(ctx.children);
            this.addEvaluationResult(result, ctx);
        }
    }
    evaluateStatement(ctx) {
        let result = true;
        let evalString = '';
        for (let i = 0; i < ctx.children.length; i++) {
            const item = ctx.children[i];
            evalString += this.getItemStatement(item);
        }
        result = eval(evalString);
        return result;
    }
    evaluate(items) {
        let result = false;
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            if (item.ruleIndex == TibboBasicPreprocessorParser.RULE_preprocessor_expression && item.op == undefined) {
                const text = item.children[0].getText();
                // let definedValue = this.getDefineValue(text);
                result = this.preprocessor.defines[text] != undefined && Number(this.preprocessor.defines[text].value) != 0;
            }
            if (item.ruleIndex == TibboBasicPreprocessorParser.RULE_preprocessor_expression && item.op != undefined) {
                switch (item.op.type) {
                    case TibboBasicPreprocessorParser.AND:
                        result = this.evaluate([item.children[0]]) && this.evaluate([item.children[2]]);
                        break;
                    case TibboBasicPreprocessorParser.OR:
                        result = this.evaluate([items[i].children[0]]) || this.evaluate([items[i].children[2]]);
                        break;
                    default:
                        {
                            const name = item.children[0].start.text;
                            const evalValue = this.getDefineValue(item.children[2].start.text);
                            const definedValue = this.getDefineValue(name);
                            switch (item.op.type) {
                                case TibboBasicPreprocessorParser.EQUAL:
                                    result = evalValue == definedValue;
                                    break;
                                case TibboBasicPreprocessorParser.NOTEQUAL:
                                    result = evalValue != definedValue;
                                    break;
                                case TibboBasicPreprocessorParser.LT:
                                    result = evalValue < definedValue;
                                    break;
                                case TibboBasicPreprocessorParser.GT:
                                    result = evalValue > definedValue;
                                    break;
                                case TibboBasicPreprocessorParser.LE:
                                    result = evalValue <= definedValue;
                                    break;
                                case TibboBasicPreprocessorParser.GE:
                                    result = evalValue >= definedValue;
                                    break;
                            }
                        }
                        break;
                }
            }
        }
        return result;
    }
    getItemStatement(item) {
        let evalString = '';
        if (item.children) {
            for (let i = 0; i < item.children.length; i++) {
                evalString += this.getItemStatement(item.children[i]);
            }
        }
        else {
            switch (item.symbol.type) {
                case TibboBasicPreprocessorParser.EQUAL:
                    evalString += '==';
                    break;
                case TibboBasicPreprocessorParser.NOTEQUAL:
                    evalString += '!=';
                    break;
                case TibboBasicPreprocessorParser.AND:
                    evalString += '&&';
                    break;
                case TibboBasicPreprocessorParser.OR:
                    evalString += '||';
                    break;
                case TibboBasicPreprocessorParser.LT:
                    evalString += '<';
                    break;
                case TibboBasicPreprocessorParser.GT:
                    evalString += '>';
                    break;
                case TibboBasicPreprocessorParser.LE:
                    evalString += '<=';
                    break;
                case TibboBasicPreprocessorParser.GE:
                    evalString += '>=';
                    break;
                case TibboBasicPreprocessorParser.CONDITIONAL_SYMBOL:
                    evalString += '"' + this.getDefineValue(item.symbol.text) + '"';
                    break;
                case TibboBasicPreprocessorParser.DECIMAL_LITERAL:
                case TibboBasicPreprocessorParser.DIRECTIVE_STRING:
                    evalString += '"' + item.symbol.text + '"';
                    break;
            }
        }
        return evalString;
    }
    getDefineValue(name) {
        if (this.preprocessor.defines[name] != undefined) {
            const define = this.preprocessor.defines[name];
            if (define.value != '') {
                const nestedDefineValue = this.getDefineValue(define.value);
                if (nestedDefineValue != name) {
                    return nestedDefineValue;
                }
                else {
                    return define.value;
                }
            }
            else {
                return define.value;
            }
        }
        return name;
    }
    addCode(context) {
        if (this.currentBlock != undefined) {
            if (!this.currentBlock.shouldEvaluate) {
                return;
            }
        }
        const text = this.charStream.getText(context.start.start, context.stop.stop);
        // this.preprocessor.codes[this.filePath]
        this.preprocessor.files[this.filePath] = this.replaceRange(this.preprocessor.files[this.filePath], context.start.start, context.stop.stop, text);
        // if (context.children != undefined) {
        //     for (let i = 0; i < context.children.length; i++) {
        //         this.addCode(context.children[i]);
        //     }
        // }
        // else {
        //     this.preprocessor.codes[this.filePath].push(context);
        // }
    }
    addEvaluationResult(result, ctx) {
        this.lastLine = ctx.start.line;
        if (this.currentBlock != undefined) {
            this.currentBlock.evaluationResults.push(result);
        }
    }
    replaceRange(s, start, end, substitute) {
        return s.substring(0, start) + substitute + s.substring(end + 1);
    }
    addBlock(ctx) {
        let shouldEvaluate = false;
        if (this.currentBlock == undefined) {
            shouldEvaluate = true;
        }
        else {
            shouldEvaluate = this.getCurrentStack();
        }
        const currentBlock = {
            shouldEvaluate: shouldEvaluate,
            parentBlock: this.currentBlock,
            blockStart: ctx.start.line,
            evaluationResults: []
        };
        this.currentBlock = currentBlock;
    }
    addExpressionBlock() {
        this.expressionStack.push(0);
    }
    getCurrentStack(block = undefined) {
        let result = true;
        if (block == undefined) {
            block = this.currentBlock;
        }
        if (block != undefined) {
            result = block.evaluationResults[block.evaluationResults.length - 1];
        }
        return result;
    }
    addExpressionCount() {
        if (this.expressionStack.length == 0) {
            this.addExpressionBlock();
        }
        this.expressionStack[this.expressionStack.length - 1]++;
    }
}
exports.PreprocessorListener = PreprocessorListener;
//# sourceMappingURL=TibboBasicPreprocessor.js.map