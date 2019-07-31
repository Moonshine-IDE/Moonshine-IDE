package moonshine;

import com.as3mxml.vscode.ActionScriptLanguageServer;
import com.as3mxml.vscode.project.IProjectConfigStrategyFactory;

import org.eclipse.lsp4j.services.TextDocumentService;
import org.eclipse.lsp4j.services.WorkspaceService;

public class MoonshineLanguageServer extends ActionScriptLanguageServer
{
    public MoonshineLanguageServer(IProjectConfigStrategyFactory factory)
    {
        super(factory);
	}

    @Override
    public TextDocumentService getTextDocumentService()
    {
        if (actionScriptServices == null)
        {
            actionScriptServices = new MoonshineActionScriptServices();
        }
        return actionScriptServices;
    }

    @Override
    public WorkspaceService getWorkspaceService()
    {
        if (actionScriptServices == null)
        {
            actionScriptServices = new MoonshineActionScriptServices();
        }
        return actionScriptServices;
    }
}