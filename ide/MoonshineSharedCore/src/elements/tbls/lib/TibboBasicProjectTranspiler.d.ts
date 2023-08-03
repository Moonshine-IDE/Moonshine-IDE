import { TBObject, TBFunction, TBConst, TBVariable, TBSyscall, TBType, TBEvent } from './types';
export declare class TibboBasicProjectTranspiler {
    output: string;
    lines: string[];
    currentLine: string;
    functions: TBFunction[];
    variables: TBVariable[];
    lineMappings: number[];
    constants: {
        [name: string]: TBConst;
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
    transpile(files: any[]): any[];
}
