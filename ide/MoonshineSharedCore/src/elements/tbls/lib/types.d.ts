import { CommonToken } from "antlr4/Token";
export interface TBDefine {
    name: string;
    value: string;
    line: number;
}
export interface TBVariable {
    name: string;
    value?: string;
    dataType: string;
    length: string;
    location: TBRange;
    declaration?: TBRange;
    comments?: Array<CommonToken>;
    parentScope?: TBScope;
    references: Array<TBRange>;
}
export interface TBParameter {
    name: string;
    byRef: boolean;
    dataType: string;
}
export interface TBObject {
    name: string;
    properties: Array<TBObjectProperty>;
    functions: Array<TBFunction>;
    location: TBRange;
    comments: Array<CommonToken>;
    events: Array<TBEvent>;
}
export interface TBObjectProperty {
    name: string;
    dataType: string;
    get?: TBSyscall;
    set?: TBSyscall;
    location: TBRange;
    comments: Array<CommonToken>;
}
export declare enum TBSymbolType {
    ENUM = "enum",
    ENUM_MEMBER = "enum_member",
    TYPE = "type",
    TYPE_MEMBER = "type_member",
    FUNCTION = "function",
    SUB = "sub",
    DIM = "dim",
    CONST = "const",
    OBJECT = "object",
    OBJECT_PROPERTY = "object_property",
    SYSCALL = "syscall",
    DEFINE = "define"
}
export interface TBRange {
    startToken: CommonToken;
    stopToken: CommonToken;
}
export interface TBEvent {
    name: string;
    eventNumber: number;
    parameters: Array<TBParameter>;
    location: TBRange;
    comments: Array<CommonToken>;
}
export interface TBSyscall {
    name: string;
    syscallNumber?: number;
    tdl?: string;
    parameters: Array<TBParameter>;
    dataType: string;
    location: TBRange;
    comments: Array<CommonToken>;
}
export interface TBSyntaxError {
    symbol: CommonToken;
    line: number;
    column: number;
    message: string;
}
export interface TBEnum {
    name: string;
    members: Array<TBEnumEntry>;
    location: TBRange;
    comments: Array<CommonToken>;
}
export interface TBFunction {
    name: string;
    parameters: Array<TBParameter>;
    syscall?: TBSyscall;
    dataType?: string;
    location?: TBRange;
    declaration?: TBRange;
    comments?: Array<CommonToken>;
    variables: Array<TBVariable>;
    references?: Array<TBRange>;
}
export interface TBConst {
    name: string;
    value: string;
    location: TBRange;
    comments: Array<CommonToken>;
}
export interface TBSymbol {
    location: TBRange;
}
export interface TBScope {
    file: string;
    start: CommonToken;
    end: CommonToken;
    parentScope?: TBScope;
}
export interface TBType {
    name: string;
    members: Array<TBVariable>;
    location: TBRange;
    comments: Array<CommonToken>;
}
export interface TBEnumEntry {
    name: string;
    value: string;
    location: TBRange;
    comments: Array<CommonToken>;
}
