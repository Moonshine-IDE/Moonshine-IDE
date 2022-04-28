package com.moonshine.ls;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import org.eclipse.lsp4j.CodeActionParams;
import org.eclipse.lsp4j.CodeLens;
import org.eclipse.lsp4j.CodeLensParams;
import org.eclipse.lsp4j.Command;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionItemKind;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.CompletionParams;
import org.eclipse.lsp4j.Diagnostic;
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
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.Range;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.RenameParams;
import org.eclipse.lsp4j.SignatureHelp;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.TextDocumentPositionParams;
import org.eclipse.lsp4j.TextEdit;
import org.eclipse.lsp4j.WorkspaceEdit;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.eclipse.lsp4j.services.TextDocumentService;

public class BasicTextDocumentService implements TextDocumentService {
	BasicLanguageServer lanugageServer;

	public BasicTextDocumentService(BasicLanguageServer lanugageServer) {
		super();
		this.lanugageServer = lanugageServer;
	}

	@Override
	public CompletableFuture<Either<List<CompletionItem>, CompletionList>> completion(
			CompletionParams completionParams) {
		// Provide completion item.
		return CompletableFuture.supplyAsync(() -> {
			List<CompletionItem> completionItems = new ArrayList<>();
			try {
				// Sample Completion item for sayHello
				CompletionItem completionItem = new CompletionItem();
				// Define the text to be inserted in to the file if the completion item is
				// selected.
				completionItem.setInsertText("sayHello() {\n    print(\"hello\")\n}");
				// Set the label that shows when the completion drop down appears in the Editor.
				completionItem.setLabel("sayHellooooooo()");
				// Set the completion kind. This is a snippet.
				// That means it replace character which trigger the completion and
				// replace it with what defined in inserted text.
				completionItem.setKind(CompletionItemKind.Snippet);
				// This will set the details for the snippet code which will help user to
				// understand what this completion item is.
				completionItem.setDetail("sayHello()\n this will say hello to the people");

				// Add the sample completion item to the list.
				completionItems.add(completionItem);
			} catch (Exception e) {
				// TODO: Handle the exception.
			}

			// Return the list of completion items.
			return Either.forLeft(completionItems);
		});
	}

	@Override
	public CompletableFuture<CompletionItem> resolveCompletionItem(CompletionItem completionItem) {
		return null;
	}

	@Override
	public CompletableFuture<Hover> hover(TextDocumentPositionParams textDocumentPositionParams) {
		return null;
	}

	@Override
	public CompletableFuture<SignatureHelp> signatureHelp(TextDocumentPositionParams textDocumentPositionParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends Location>> definition(
			TextDocumentPositionParams textDocumentPositionParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends Location>> references(ReferenceParams referenceParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends DocumentHighlight>> documentHighlight(
			TextDocumentPositionParams textDocumentPositionParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends SymbolInformation>> documentSymbol(
			DocumentSymbolParams documentSymbolParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends Command>> codeAction(CodeActionParams codeActionParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends CodeLens>> codeLens(CodeLensParams codeLensParams) {
		return null;
	}

	@Override
	public CompletableFuture<CodeLens> resolveCodeLens(CodeLens codeLens) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends TextEdit>> formatting(DocumentFormattingParams documentFormattingParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends TextEdit>> rangeFormatting(
			DocumentRangeFormattingParams documentRangeFormattingParams) {
		return null;
	}

	@Override
	public CompletableFuture<List<? extends TextEdit>> onTypeFormatting(
			DocumentOnTypeFormattingParams documentOnTypeFormattingParams) {
		return null;
	}

	@Override
	public CompletableFuture<WorkspaceEdit> rename(RenameParams renameParams) {
		return null;
	}

	@Override
	public void didOpen(DidOpenTextDocumentParams didOpenTextDocumentParams) {
		// send notification
		CompletableFuture.runAsync(() -> lanugageServer.getClient().publishDiagnostics(new PublishDiagnosticsParams(
				didOpenTextDocumentParams.getTextDocument().getUri(), validate(didOpenTextDocumentParams.getText()))));
	}

	@Override
	public void didChange(DidChangeTextDocumentParams didChangeTextDocumentParams) {

		// send notification
		CompletableFuture.runAsync(() -> lanugageServer.getClient()
				.publishDiagnostics(new PublishDiagnosticsParams(didChangeTextDocumentParams.getTextDocument().getUri(),
						validate(didChangeTextDocumentParams.getContentChanges().get(0).getText()))));
	}

	@Override
	public void didClose(DidCloseTextDocumentParams didCloseTextDocumentParams) {
	}
  
	@Override
	public void didSave(DidSaveTextDocumentParams didSaveTextDocumentParams) {
		CompletableFuture.runAsync(() -> lanugageServer.getClient().publishDiagnostics(new PublishDiagnosticsParams(
				didSaveTextDocumentParams.getTextDocument().getUri(), validate(didSaveTextDocumentParams.getText()))));
	}

	private List<Diagnostic> validate(String changesText) {
		List<Diagnostic> res = new ArrayList<>();
		res.add(new Diagnostic(new Range(new Position(0, 0), new Position(1, 0)), "Test error message:" + changesText));
//		Route previousRoute = null;
//		for (Route route : model.getResolvedRoutes()) {
//			if (!EclipseConMap.INSTANCE.all.contains(route.name)) {
//				Diagnostic diagnostic = new Diagnostic();
//				diagnostic.setSeverity(DiagnosticSeverity.Error);
//				diagnostic.setMessage("This is not a Session");
//				diagnostic.setRange(new Range(
//						new Position(route.line, route.charOffset),
//						new Position(route.line, route.charOffset + route.text.length())));
//				res.add(diagnostic);
//			} else if (previousRoute != null && !EclipseConMap.INSTANCE.startsFrom(route.name, previousRoute.name)) {
//				Diagnostic diagnostic = new Diagnostic();
//				diagnostic.setSeverity(DiagnosticSeverity.Warning);
//				diagnostic.setMessage("'" + route.name + "' does not follow '" + previousRoute.name + "'");
//				diagnostic.setRange(new Range(
//						new Position(route.line, route.charOffset),
//						new Position(route.line, route.charOffset + route.text.length())));
//				res.add(diagnostic);
//			}
//			previousRoute = route;
//		}
		return res;
	}

}
