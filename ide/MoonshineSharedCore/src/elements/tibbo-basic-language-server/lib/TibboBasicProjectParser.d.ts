import { TBObject, TBEnum, TBFunction, TBConst, TBVariable, TBScope, TBSyscall, TBType, TBSyntaxError, TBEvent, TBSymbol } from './types';
import { CommonToken } from 'antlr4/Token';
import { TerminalNode } from 'antlr4/tree/Tree';
import { CommonTokenStream } from 'antlr4/CommonTokenStream';
export declare class TibboBasicProjectParser {
    objects: {
        [name: string]: TBObject;
    };
    syscalls: {
        [name: string]: TBSyscall;
    };
    tokens: {
        [name: string]: CommonTokenStream;
    };
    trees: {
        [name: string]: any;
    };
    events: {
        [name: string]: TBEvent;
    };
    errors: {
        [name: string]: Array<TBSyntaxError>;
    };
    enums: {
        [name: string]: TBEnum;
    };
    functions: {
        [name: string]: TBFunction;
    };
    consts: {
        [name: string]: TBConst;
    };
    types: {
        [name: string]: TBType;
    };
    comments: {
        [fileName: string]: CommonToken[];
    };
    variables: Array<TBVariable>;
    scopes: Array<TBScope>;
    symbolDeclarations: {
        [fileName: string]: number[];
    };
    references: {
        [symbolName: string]: TBSymbol[];
    };
    parseFile(filePath: string, fileContents?: string): void;
    getTokenAtPosition(filePath: string, offset: number): TerminalNode | undefined;
    findToken(offset: number, children: Array<any>): TerminalNode | undefined;
    getScope(filePath: string, offset: number): TBScope | undefined;
    getScopeVariables(scope: TBScope | undefined): Array<TBVariable>;
    constructComments(): void;
    findComments(location: CommonToken, startsInline?: boolean): Array<CommonToken>;
    addVariable(variable: TBVariable): void;
    resetFileSymbols(filePath: string): void;
}
