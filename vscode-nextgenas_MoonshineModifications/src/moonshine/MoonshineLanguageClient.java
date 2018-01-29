package moonshine;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.concurrent.CompletableFuture;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import org.eclipse.lsp4j.ApplyWorkspaceEditParams;
import org.eclipse.lsp4j.ApplyWorkspaceEditResponse;
import org.eclipse.lsp4j.DiagnosticSeverity;
import org.eclipse.lsp4j.MessageActionItem;
import org.eclipse.lsp4j.MessageParams;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ShowMessageRequestParams;
import org.eclipse.lsp4j.services.LanguageClient;
import org.xsocket.connection.INonBlockingConnection;

public class MoonshineLanguageClient implements LanguageClient
{
    public INonBlockingConnection connection;

    public MoonshineLanguageClient()
    {

    }

    public void telemetryEvent(Object object)
    {
        if(connection == null)
        {
            return;
        }
    }

    public void publishDiagnostics(PublishDiagnosticsParams diagnostics)
    {
        if(connection == null)
        {
            return;
        }
        HashMap<String, Object> wrapper = new HashMap<>();
        wrapper.put("method", "textDocument/publishDiagnostics");
        wrapper.put("params", diagnostics);

        GsonBuilder builder = new GsonBuilder();
        builder.registerTypeAdapter(DiagnosticSeverity.class, new DiagnosticSeveritySerializer()).create();
        Gson gson = builder.create();
        String json = gson.toJson(wrapper);
        System.out.println("publish diagnostics : " + json);
        try
        {
            connection.write(json + "\0");
        }
        catch(IOException e)
        {
            e.printStackTrace();
            System.out.println(e.getMessage() + "publish diagnostics " + e.getStackTrace());
        }
    }

    public CompletableFuture<ApplyWorkspaceEditResponse> applyEdit(ApplyWorkspaceEditParams params)
    {
        if(connection == null)
        {
            return CompletableFuture.completedFuture(new ApplyWorkspaceEditResponse(false));
        }
        HashMap<String, Object> wrapper = new HashMap<>();
        wrapper.put("method", "workspace/applyEdit");
        wrapper.put("params", params);

        GsonBuilder builder = new GsonBuilder();
        Gson gson = builder.create();
        String json = gson.toJson(wrapper);
        System.out.println("apply edit : " + json);
        try
        {
            connection.write(json + "\0");
        }
        catch(IOException e)
        {
            e.printStackTrace();
            System.out.println(e.getMessage() + "apply edit " + e.getStackTrace());
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

    public static class DiagnosticSeveritySerializer implements JsonSerializer<DiagnosticSeverity>
    {
        public JsonElement serialize(DiagnosticSeverity severity, Type type, JsonSerializationContext jsc)
        {
            return new JsonPrimitive(severity.getValue());
        }
    }
}
