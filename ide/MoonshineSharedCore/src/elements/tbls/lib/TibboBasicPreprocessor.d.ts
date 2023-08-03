import { TBDefine } from './types';
import { TerminalNodeImpl } from 'antlr4/tree/Tree';
import { InputStream, ParserRuleContext } from 'antlr4';
declare const TibboBasicPreprocessorParserListener: any;
export declare class TibboBasicPreprocessor {
    projectPath: string;
    platformType: string;
    platformsPath: string;
    platformVersion: string;
    defines: {
        [name: string]: TBDefine;
    };
    codes: {
        [filename: string]: Array<TerminalNodeImpl>;
    };
    files: {
        [filename: string]: string;
    };
    filePriorities: string[];
    originalFiles: {
        [filename: string]: string;
    };
    constructor(projectPath: string, platformsPath: string);
    parsePlatforms(): void;
    getFilePath(currentDirectory: string, filePath: string): string;
    parseFile(currentDirectory: string, filePath: string, update?: boolean): string;
}
interface PreprocessorEvaluationBlock {
    parentBlock: PreprocessorEvaluationBlock | undefined;
    shouldEvaluate: boolean;
    blockStart: number;
    evaluationResults: Array<boolean>;
}
export declare class PreprocessorListener extends TibboBasicPreprocessorParserListener {
    preprocessor: TibboBasicPreprocessor;
    filePath: string;
    expressionStack: Array<number>;
    charStream: InputStream;
    lastLine: number;
    currentBlock: PreprocessorEvaluationBlock | undefined;
    constructor(filePath: string, preprocessor: TibboBasicPreprocessor, charStream: InputStream);
    enterCodeLine(ctx: any): void;
    enterPreprocessorDefine(ctx: any): void;
    enterPreprocessorInclude(ctx: any): void;
    enterPreprocessorDef(ctx: any): void;
    enterPreprocessorUndef(ctx: any): void;
    enterPreprocessorEndConditional(ctx: any): void;
    enterPreprocessorConditional(ctx: any): void;
    evaluateStatement(ctx: any): boolean;
    evaluate(items: any[]): boolean;
    getItemStatement(item: any): string;
    getDefineValue(name: string): any;
    addCode(context: ParserRuleContext): void;
    addEvaluationResult(result: boolean, ctx: ParserRuleContext): void;
    replaceRange(s: any, start: number, end: number, substitute: string): string;
    addBlock(ctx: any): void;
    addExpressionBlock(): void;
    getCurrentStack(block?: PreprocessorEvaluationBlock | undefined): boolean;
    addExpressionCount(): void;
}
export {};
