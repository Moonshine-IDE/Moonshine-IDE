////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
								documentationFormat: ["plaintext", "markdown"],
								deprecatedSupport: false,
								preselectSupport: false,
								//tagSupport: { valueSet: []},
								insertReplaceSupport: false,
								//resolveSupport: { properties: []},
								//insertTextModeSupport: { valueSet: []},
								labelDetailsSupport: false
							},
							completionItemKind: {
								// valueSet: []
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
								// valueSet: []
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
							dynamicRegistration: false
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