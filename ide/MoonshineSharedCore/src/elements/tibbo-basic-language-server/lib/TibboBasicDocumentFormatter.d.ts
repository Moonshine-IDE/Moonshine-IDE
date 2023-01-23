import { TextDocument, DocumentFormattingParams, TextEdit } from 'vscode-languageserver';
export declare class TibboBasicDocumentFormatter {
    formatDocument(document: TextDocument, formatParams: DocumentFormattingParams): Thenable<TextEdit[]>;
}
