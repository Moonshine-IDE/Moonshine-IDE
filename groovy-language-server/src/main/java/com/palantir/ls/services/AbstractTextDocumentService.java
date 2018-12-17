/*
 * Copyright 2016 Palantir Technologies, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.palantir.ls.services;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;
import com.palantir.ls.api.LanguageServerState;
import com.palantir.ls.util.Ranges;
import com.palantir.ls.util.Uris;
import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.CodeActionParams;
import org.eclipse.lsp4j.CodeLens;
import org.eclipse.lsp4j.CodeLensParams;
import org.eclipse.lsp4j.Command;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.DidChangeTextDocumentParams;
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
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.RenameParams;
import org.eclipse.lsp4j.SignatureHelp;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.TextDocumentPositionParams;
import org.eclipse.lsp4j.TextEdit;
import org.eclipse.lsp4j.WorkspaceEdit;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.eclipse.lsp4j.services.TextDocumentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Provides a default implemented not dissimilar to to antlr generated visitors.
 * Markedly differs in throwing exceptions rather than more benign logs etc.
 */
public abstract class AbstractTextDocumentService implements TextDocumentService {

    private static final Logger LOG = LoggerFactory.getLogger(AbstractTextDocumentService.class);

    protected abstract LanguageServerState getState();

    @Override
    public final void didOpen(DidOpenTextDocumentParams params) {
        URI uri = Uris.resolveToRoot(getWorkspacePath(), params.getTextDocument().getUri());
        getState().getCompilerWrapper().handleFileOpened(uri, params.getTextDocument().getText());
        getState().publishDiagnostics(getState().getCompilerWrapper().compile(ImmutableSet.of(uri)));
    }

    @Override
    public final void didChange(DidChangeTextDocumentParams params) {
        URI uri = Uris.resolveToRoot(getWorkspacePath(), params.getTextDocument().getUri());
        if (params.getContentChanges() == null || params.getContentChanges().isEmpty()) {
            throw new IllegalArgumentException(
                    String.format("Calling didChange with no changes on uri '%s'", uri.toString()));
        }
        getState().getCompilerWrapper().handleFileChanged(uri, Lists.newArrayList(params.getContentChanges()));
        getState().publishDiagnostics(getState().getCompilerWrapper().compile(ImmutableSet.of(uri)));
    }

    @Override
    public final void didClose(DidCloseTextDocumentParams params) {
        URI uri = Uris.resolveToRoot(getWorkspacePath(), params.getTextDocument().getUri());
        getState().getCompilerWrapper().handleFileClosed(uri);
        getState().publishDiagnostics(getState().getCompilerWrapper().compile(ImmutableSet.of(uri)));
    }

    @Override
    public final void didSave(DidSaveTextDocumentParams params) {
        URI uri = Uris.resolveToRoot(getWorkspacePath(), params.getTextDocument().getUri());
        getState().getCompilerWrapper().handleFileSaved(uri, Optional.fromNullable(params.getText()));
        getState().publishDiagnostics(getState().getCompilerWrapper().compile(ImmutableSet.of(uri)));
    }

    final Path getWorkspacePath() {
        return Paths.get(getState().getCompilerWrapper().getWorkspaceRoot());
    }


    @Override
    public CompletableFuture<List<? extends DocumentHighlight>> documentHighlight(TextDocumentPositionParams position) {
        throw new UnsupportedOperationException();
    }

    @Override
    public CompletableFuture<CompletionItem> resolveCompletionItem(CompletionItem unresolved) {
        throw new UnsupportedOperationException();
    }

    @Override
    public CompletableFuture<Hover> hover(TextDocumentPositionParams position) {
        throw new UnsupportedOperationException();
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
            TextDocumentPositionParams position) {
        return CompletableFuture.completedFuture(Either.forRight(
                getState().getCompilerWrapper()
                        .getCompletion(
                                Uris.resolveToRoot(getWorkspacePath(), position.getTextDocument().getUri()),
                                position.getPosition())));
    }

    @Override
    public CompletableFuture<List<? extends Location>> definition(TextDocumentPositionParams position) {
        URI uri = Uris.resolveToRoot(getWorkspacePath(), position.getTextDocument().getUri());
        return CompletableFuture.completedFuture(getState().getCompilerWrapper()
                .gotoDefinition(uri, position.getPosition()).transform(Lists::newArrayList).or(Lists.newArrayList()));
    }

    @Override
    public CompletableFuture<List<? extends Location>> references(ReferenceParams params) {
        return CompletableFuture.completedFuture(
                getState().getCompilerWrapper().findReferences(params).stream()
                        .filter(location -> Ranges.isValid(location.getRange()))
                        .collect(Collectors.toList()));
    }

    @Override
    public CompletableFuture<List<? extends SymbolInformation>> documentSymbol(DocumentSymbolParams params) {
        URI uri = Uris.resolveToRoot(getWorkspacePath(), params.getTextDocument().getUri());
        List<SymbolInformation> symbols = Optional.fromNullable(getState().getCompilerWrapper().getFileSymbols()
                .get(uri).stream().collect(Collectors.toList())).or(Lists.newArrayList());
        return CompletableFuture.completedFuture(symbols);
    }
}
