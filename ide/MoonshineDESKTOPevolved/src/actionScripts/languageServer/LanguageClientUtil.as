////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.languageServer
{
	import actionScripts.locator.IDEModel;

	public class LanguageClientUtil
	{
		public static function getSharedInitializeParams():Object
		{
			return {
				clientInfo: {
					name: "Moonshine IDE",
					version: IDEModel.getInstance().getVersionWithBuildNumber()
				},
				capabilities: {
					general: {
						markdown: {
							parser: "haxe-markdown-openfl-textfield"
						}
					},
					textDocument: {
						synchronization: {
							dynamicRegistration: false,
							willSave: true,
							willSaveWaitUntil: false,
							didSave: true
						},
						completion: {
							dynamicRegistration: true,
							completionItem: {
								snippetSupport: false,
								commitCharactersSupport: false,
								documentationFormat: ["markdown", "plaintext"],
								deprecatedSupport: false,
								preselectSupport: false,
								//tagSupport: { valueSet: []},
								insertReplaceSupport: false,
								resolveSupport: { properties: ["documentation", "detail", "additionalTextEdits"]},
								//insertTextModeSupport: { valueSet: []},
								labelDetailsSupport: false
							},
							completionItemKind: {
								valueSet: [
									1,
									2,
									3,
									4,
									5,
									6,
									7,
									8,
									9,
									10,
									11,
									12,
									13,
									14,
									15,
									16,
									17,
									18,
									19,
									20,
									21,
									22,
									23,
									24,
									25
								]
							},
							contextSupport: false
						},
						hover: {
							dynamicRegistration: true,
							contentFormat: ["plaintext", "markdown"]
						},
						signatureHelp: {
							dynamicRegistration: true,
							signatureInformation: {
								documentationFormat: ["plaintext", "markdown"],
								activeParameterSupport: true
							},
							contextSupport: false
						},
						// declaration: {
						// 	dynamicRegistration: false
						// },
						definition: {
							dynamicRegistration: true
						},
						typeDefinition: {
							dynamicRegistration: true
						},
						implementation: {
							dynamicRegistration: true
						},
						references: {
							dynamicRegistration: true
						},
						// documentHighlight: {
						// 	dynamicRegistration: false
						// },
						documentSymbol: {
							dynamicRegistration: true,
							hierarchicalDocumentSymbolSupport: true,
							symbolKind: {
								valueSet: [
									1,
									2,
									3,
									4,
									5,
									6,
									7,
									8,
									9,
									10,
									11,
									12,
									13,
									14,
									15,
									16,
									17,
									18,
									19,
									20,
									21,
									22,
									23,
									24,
									25,
									26
								]
							},
							//tagSupport: {valueSet: []},
							labelSupport: false
						},
						codeAction: {
							dynamicRegistration: true,
							/*codeActionLiteralSupport: {
								codeActionKind: { valueSet: [] },
							}*/
							isPreferredSupport: false,
							disabledSupport: false,
							dataSupport: false
							//resolveSupport: { properties: [] },
						},
						// codeLens: {
						// 	dynamicRegistration: false
						// },
						// documentLink: {
						// 	dynamicRegistration: false
						// },
						// colorProvider: {
						// 	dynamicRegistration: false
						// },
						// formatting: {
						// 	dynamicRegistration: false
						// },
						// rangeFormatting: {
						// 	dynamicRegistration: false
						// },
						// onTypeFormatting: {
						// 	dynamicRegistration: false
						// },
						rename: {
							dynamicRegistration: true
						},
						publishDiagnostics: {
							relatedInformation: false,
							//tagSupport: { valueSet: [] },
							versionSupport: false,
							codeDescriptionSupport: false,
							dataSupport: false
						}
						// foldingRange: {
						// 	dynamicRegistration: false
						// },
						// selectionRange: {
						// 	dynamicRegistration: false
						// },
						// linkedEditingRange: {
						// 	dynamicRegistration: false
						// },
						// callHierarchy: {
						// 	dynamicRegistration: false
						// },
						// semanticTokens: {
						// 	dynamicRegistration: false
						// },
						// moniker: {
						// 	dynamicRegistration: false
						// }
					},
					window: {
						workDoneProgress: false
					},
					workspace: {
						applyEdit: true,
						workspaceEdit: {
							documentChanges: true,
							resourceOperations: ["create", "delete", "rename"]
						},
						didChangeConfiguration: {
							dynamicRegistration: false
						},
						didChangeWatchedFiles: {
							dynamicRegistration: true
						},
						symbol: {
							dynamicRegistration: true
						},
						executeCommand: {
							dynamicRegistration: true
						},
						workspaceFolders: false,
						configuration: false
					}
				}
			};
		}
	}
}