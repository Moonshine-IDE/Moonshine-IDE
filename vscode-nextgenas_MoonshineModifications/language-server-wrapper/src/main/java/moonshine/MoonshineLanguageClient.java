package moonshine;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.concurrent.CompletableFuture;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.nextgenactionscript.vscode.services.ActionScriptLanguageClient;
import org.eclipse.lsp4j.ApplyWorkspaceEditParams;
import org.eclipse.lsp4j.ApplyWorkspaceEditResponse;
import org.eclipse.lsp4j.DiagnosticSeverity;
import org.eclipse.lsp4j.MessageActionItem;
import org.eclipse.lsp4j.MessageParams;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ShowMessageRequestParams;
import org.eclipse.lsp4j.jsonrpc.json.MessageJsonHandler;
import org.xsocket.connection.INonBlockingConnection;

public class MoonshineLanguageClient implements ActionScriptLanguageClient
{
    public INonBlockingConnection connection;
    private int nextID = 1;
    private Gson gson;

    public MoonshineLanguageClient()
    {
        MessageJsonHandler messageJsonHandler = new MessageJsonHandler(new HashMap<>());
        gson = messageJsonHandler.getGson();
    }

    public void telemetryEvent(Object object)
    {
        if(connection == null)
        {
            return;
        }
    }

    public void publishDiagnostics(PublishDiagnosticsParams params)
    {
        if(connection == null)
        {
            return;
        }

        String json = getJSONNotification("textDocument/publishDiagnostics", params);
        //System.err.println("publish diagnostics : " + json);
        try
        {
            connection.write(json);
        }
        catch(IOException e)
        {
            System.err.println(e.getMessage() + "publish diagnostics");
            e.printStackTrace(System.err);
        }
    }

    public CompletableFuture<ApplyWorkspaceEditResponse> applyEdit(ApplyWorkspaceEditParams params)
    {
        if(connection == null)
        {
            return CompletableFuture.completedFuture(new ApplyWorkspaceEditResponse(false));
        }

        String json = getJSONNotification("workspace/applyEdit", params);
        //System.err.println("apply edit : " + json);
        try
        {
            connection.write(json);
        }
        catch(IOException e)
        {
            System.err.println(e.getMessage() + "apply edit");
            e.printStackTrace(System.err);
        }
        return CompletableFuture.completedFuture(new ApplyWorkspaceEditResponse(true));
    }

    public void showMessage(MessageParams messageParams)
    {
        if(connection == null)
        {
            return;
        }
    }

    @Override
    public CompletableFuture<MessageActionItem> showMessageRequest(ShowMessageRequestParams requestParams)
    {
        if(connection == null)
        {
            return CompletableFuture.completedFuture(null);
        }
        return CompletableFuture.completedFuture(null);
    }

    public void logMessage(MessageParams message)
    {
        if(connection == null)
        {
            return;
        }
    }

    public void logCompilerShellOutput(String message)
    {
        //does nothing since Moonshine doesn't use the compiler shell
    }

    public void clearCompilerShellOutput()
    {
        //does nothing since Moonshine doesn't use the compiler shell
    }

    public String getJSONNotification(String method, Object params)
    {
        int id = nextID;
        nextID++;
        HashMap<String, Object> wrapper = new HashMap<>();
        wrapper.put("jsonrpc", "2.0");
        wrapper.put("id", id);
        wrapper.put("method", method);
        wrapper.put("params", params);
        String json = gson.toJson(wrapper);

        StringBuilder builder = new StringBuilder();
        builder.append("Content-Length: ");
        builder.append(json.getBytes().length);
        builder.append("\r\n");
        builder.append("\r\n");
        builder.append(json);
        return builder.toString();
    }

    public static class DiagnosticSeveritySerializer implements JsonSerializer<DiagnosticSeverity>
    {
        public JsonElement serialize(DiagnosticSeverity severity, Type type, JsonSerializationContext jsc)
        {
            return new JsonPrimitive(severity.getValue());
        }
    }
}
