package moonshine;

import java.util.concurrent.CompletableFuture;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.nextgenactionscript.vscode.ActionScriptLanguageServer;
import com.nextgenactionscript.vscode.ActionScriptTextDocumentService;
import com.nextgenactionscript.vscode.project.IProjectConfigStrategyFactory;

import org.eclipse.lsp4j.jsonrpc.services.JsonNotification;

public class MoonshineLanguageServer extends ActionScriptLanguageServer
{
    public MoonshineLanguageServer(IProjectConfigStrategyFactory factory)
    {
        super(factory);
    }

	@JsonNotification(value="moonshine/didChangeProjectConfiguration")
	public void didChangeProjectConfiguration(Object rawData)
	{
        Gson gson = new Gson();
        JsonObject config = gson.toJsonTree(rawData).getAsJsonObject();
        ActionScriptTextDocumentService textDocumentService = (ActionScriptTextDocumentService) getTextDocumentService();
        MoonshineProjectConfigStrategy projectConfigStrategy = (MoonshineProjectConfigStrategy) textDocumentService.getProjectConfigStrategy();
        projectConfigStrategy.setConfigParams(config);
        textDocumentService.checkForProblemsNow();
	}
}