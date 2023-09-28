import { TBObject, TBScope, TBSyscall, TBType, TBEvent } from './types';
interface TibboVariable {
    name: string;
    dataType: string;
    size: string;
    global?: boolean;
    byRef?: boolean;
    scope?: TBScope;
}
interface TibboFunction {
    name: string;
    returnType: string;
    params: TibboVariable[];
    returnValues: string[];
}
interface TibboConstant {
    name: string;
    value: string;
    index: number;
}
export declare class TibboBasicJavascriptCompiler {
    output: string;
    lines: string[];
    currentLine: string;
    functions: TibboFunction[];
    variables: TibboVariable[];
    lineMappings: number[];
    constants: {
        [name: string]: TibboConstant;
    };
    types: {
        [name: string]: TBType;
    };
    objects: {
        [name: string]: TBObject;
    };
    events: {
        [name: string]: TBEvent;
    };
    syscalls: {
        [name: string]: TBSyscall;
    };
    compile(files: any[]): string;
    parseFile(contents: string): string;
    replaceDirective(content: string): string;
    addCode(code: string, line: number): void;
    writeLine(line: number): void;
    appendLine(code: string, line: number): void;
    setConstant(name: string, value: string): void;
}
export {};
