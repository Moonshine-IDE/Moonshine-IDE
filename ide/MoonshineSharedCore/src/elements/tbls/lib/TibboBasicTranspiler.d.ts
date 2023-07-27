import { TBObject, TBFunction, TBVariable } from './types';
export declare class TibboBasicTranspiler {
    output: string;
    lines: string[];
    currentLine: string;
    objects: {
        [name: string]: TBObject;
    };
    functions: {
        [name: string]: TBFunction;
    };
    variables: {
        [name: string]: TBVariable;
    };
    lineMappings: number[];
    parseFile(contents: string): string;
    replaceDirective(content: string): string;
    addCode(code: string, line: number): void;
    writeLine(line: number): void;
    appendLine(code: string, line: number): void;
}
