package moonshine;

import com.as3mxml.vscode.ActionScriptLanguageServer;
import com.as3mxml.vscode.project.IProjectConfigStrategyFactory;

import org.eclipse.lsp4j.services.TextDocumentService;

public class MoonshineLanguageServer extends ActionScriptLanguageServer
{
    public MoonshineLanguageServer(IProjectConfigStrategyFactory factory)
    {
        super(factory);
	}

    @Override
    public TextDocumentService getTextDocumentService()
    {
        if (textDocumentService == null)
        {
            textDocumentService = new MoonshineTextDocumentService();
            if (workspaceService != null)
            {
                workspaceService.textDocumentService = textDocumentService;
            }
        }
        return textDocumentService;
    }
}