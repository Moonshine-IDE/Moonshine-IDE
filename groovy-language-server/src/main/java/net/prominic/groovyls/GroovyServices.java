////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 Prominic.NET, Inc.
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
package net.prominic.groovyls;

import java.net.URI;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.google.common.io.Files;
import com.palantir.ls.groovy.GroovyWorkspaceCompiler;

import org.codehaus.groovy.control.CompilationUnit;
import org.eclipse.lsp4j.CodeActionParams;
import org.eclipse.lsp4j.CodeLens;
import org.eclipse.lsp4j.CodeLensParams;
import org.eclipse.lsp4j.Command;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.DidChangeConfigurationParams;
import org.eclipse.lsp4j.DidChangeTextDocumentParams;
import org.eclipse.lsp4j.DidChangeWatchedFilesParams;
import org.eclipse.lsp4j.DidCloseTextDocumentParams;
import org.eclipse.lsp4j.DidOpenTextDocumentParams;
import org.eclipse.lsp4j.DidSaveTextDocumentParams;
import org.eclipse.lsp4j.DocumentFormattingParams;
import org.eclipse.lsp4j.DocumentHighlight;
import org.eclipse.lsp4j.DocumentOnTypeFormattingParams;
import org.eclipse.lsp4j.DocumentRangeFormattingParams;
import org.eclipse.lsp4j.DocumentSymbolParams;
import org.eclipse.lsp4j.Hover;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.RenameParams;
import org.eclipse.lsp4j.SignatureHelp;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.TextDocumentPositionParams;
import org.eclipse.lsp4j.TextEdit;
import org.eclipse.lsp4j.WorkspaceEdit;
import org.eclipse.lsp4j.WorkspaceSymbolParams;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.eclipse.lsp4j.services.LanguageClient;
import org.eclipse.lsp4j.services.LanguageClientAware;
import org.eclipse.lsp4j.services.TextDocumentService;
import org.eclipse.lsp4j.services.WorkspaceService;

import net.prominic.groovyls.compiler.ast.ASTNodeVisitor;
import net.prominic.groovyls.providers.DefinitionProvider;
import net.prominic.groovyls.providers.DocumentSymbolProvider;
import net.prominic.groovyls.providers.HoverProvider;
import net.prominic.groovyls.providers.ReferenceProvider;
import net.prominic.groovyls.providers.WorkspaceSymbolProvider;

public class GroovyServices implements TextDocumentService, WorkspaceService, LanguageClientAware {
	private LanguageClient languageClient;
	private GroovyWorkspaceCompiler compiler;
	private ASTNodeVisitor astVisitor;

	public GroovyServices() {

	}

	public void setWorkspaceRoot(Path workspaceRoot) {
		Path targetDirectory = Files.createTempDir().toPath();
		compiler = GroovyWorkspaceCompiler.of(targetDirectory, workspaceRoot);
	}

	@Override
	public void connect(LanguageClient client) {
		languageClient = client;
	}

	// --- NOTIFICATIONS

	@Override
	public void didOpen(DidOpenTextDocumentParams params) {
		URI uri = URI.create(params.getTextDocument().getUri());
		compiler.handleFileOpened(uri, params.getTextDocument().getText());
		Set<PublishDiagnosticsParams> diagnostics = compiler.compile(ImmutableSet.of(uri));
		parseAllSymbols();
		diagnostics.stream().forEach(languageClient::publishDiagnostics);
	}

	@Override
	public void didChange(DidChangeTextDocumentParams params) {
		URI uri = URI.create(params.getTextDocument().getUri());
		compiler.handleFileChanged(uri, Lists.newArrayList(params.getContentChanges()));
		Set<PublishDiagnosticsParams> diagnostics = compiler.compile(ImmutableSet.of(uri));
		parseAllSymbols();
		diagnostics.stream().forEach(languageClient::publishDiagnostics);
	}

	@Override
	public final void didClose(DidCloseTextDocumentParams params) {
		URI uri = URI.create(params.getTextDocument().getUri());
		compiler.handleFileClosed(uri);
		Set<PublishDiagnosticsParams> diagnostics = compiler.compile(ImmutableSet.of(uri));
		parseAllSymbols();
		diagnostics.stream().forEach(languageClient::publishDiagnostics);
	}

	@Override
	public final void didSave(DidSaveTextDocumentParams params) {
		URI uri = URI.create(params.getTextDocument().getUri());
		compiler.handleFileSaved(uri, Optional.fromNullable(params.getText()));
		Set<PublishDiagnosticsParams> diagnostics = compiler.compile(ImmutableSet.of(uri));
		parseAllSymbols();
		diagnostics.stream().forEach(languageClient::publishDiagnostics);
	}

	@Override
	public final void didChangeWatchedFiles(DidChangeWatchedFilesParams params) {
		compiler.handleChangeWatchedFiles(params.getChanges());
		Set<URI> relevantFiles = params.getChanges().stream().map(fileEvent -> URI.create(fileEvent.getUri()))
				.collect(Collectors.toSet());
		Set<PublishDiagnosticsParams> diagnostics = compiler.compile(relevantFiles);
		parseAllSymbols();
		diagnostics.stream().forEach(languageClient::publishDiagnostics);
	}

	@Override
	public void didChangeConfiguration(DidChangeConfigurationParams didChangeConfigurationParams) {
	}

	// --- REQUESTS

	@Override
	public CompletableFuture<List<? extends DocumentHighlight>> documentHighlight(TextDocumentPositionParams position) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<CompletionItem> resolveCompletionItem(CompletionItem unresolved) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<Hover> hover(TextDocumentPositionParams params) {
		HoverProvider provider = new HoverProvider(astVisitor);
		return provider.provideHover(params.getTextDocument(), params.getPosition());
	}

	@Override
	public CompletableFuture<SignatureHelp> signatureHelp(TextDocumentPositionParams position) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<List<? extends Command>> codeAction(CodeActionParams params) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<List<? extends CodeLens>> codeLens(CodeLensParams params) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<CodeLens> resolveCodeLens(CodeLens unresolved) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<List<? extends TextEdit>> formatting(DocumentFormattingParams params) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<List<? extends TextEdit>> rangeFormatting(DocumentRangeFormattingParams params) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<List<? extends TextEdit>> onTypeFormatting(DocumentOnTypeFormattingParams params) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<WorkspaceEdit> rename(RenameParams params) {
		throw new UnsupportedOperationException();
	}

	@Override
	public CompletableFuture<Either<List<CompletionItem>, CompletionList>> completion(
			TextDocumentPositionParams params) {
		return CompletableFuture.completedFuture(Either.forLeft(Collections.emptyList()));
	}

	@Override
	public CompletableFuture<List<? extends Location>> definition(TextDocumentPositionParams params) {
		DefinitionProvider provider = new DefinitionProvider(astVisitor);
		return provider.provideDefinition(params.getTextDocument(), params.getPosition());
	}

	@Override
	public CompletableFuture<List<? extends Location>> references(ReferenceParams params) {
		ReferenceProvider provider = new ReferenceProvider(astVisitor);
		return provider.provideReferences(params.getTextDocument(), params.getPosition());
	}

	@Override
	public CompletableFuture<List<? extends SymbolInformation>> documentSymbol(DocumentSymbolParams params) {
		DocumentSymbolProvider provider = new DocumentSymbolProvider(astVisitor);
		return provider.provideDocumentSymbols(params.getTextDocument());
	}

	@Override
	public final CompletableFuture<List<? extends SymbolInformation>> symbol(WorkspaceSymbolParams params) {
		WorkspaceSymbolProvider provider = new WorkspaceSymbolProvider(astVisitor);
		return provider.provideWorkspaceSymbols(params.getQuery());
	}

	// --- INTERNAL

	public void parseAllSymbols() {
		CompilationUnit unit = compiler.get();

		astVisitor = new ASTNodeVisitor();

		unit.iterator().forEachRemaining(sourceUnit -> {
			astVisitor.setSourceUnit(sourceUnit);
			sourceUnit.getAST().getClasses().forEach(clazz -> {
				astVisitor.visitClass(clazz);
			});
		});
	}
}