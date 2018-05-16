package moonshine;

import java.io.IOException;
import java.lang.reflect.Type;
import java.net.URI;
import java.nio.BufferUnderflowException;
import java.nio.channels.ClosedChannelException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.nextgenactionscript.vscode.ActionScriptTextDocumentService;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.DidChangeTextDocumentParams;
import org.eclipse.lsp4j.DidOpenTextDocumentParams;
import org.eclipse.lsp4j.DocumentSymbolParams;
import org.eclipse.lsp4j.ExecuteCommandParams;
import org.eclipse.lsp4j.Hover;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.InitializeResult;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.RenameParams;
import org.eclipse.lsp4j.ServerCapabilities;
import org.eclipse.lsp4j.SignatureHelp;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;
import org.eclipse.lsp4j.TextDocumentItem;
import org.eclipse.lsp4j.TextDocumentPositionParams;
import org.eclipse.lsp4j.VersionedTextDocumentIdentifier;
import org.eclipse.lsp4j.WorkspaceEdit;
import org.eclipse.lsp4j.WorkspaceSymbolParams;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.eclipse.lsp4j.jsonrpc.json.MessageJsonHandler;
import org.xsocket.MaxReadSizeExceededException;
import org.xsocket.connection.IDataHandler;
import org.xsocket.connection.IDisconnectHandler;
import org.xsocket.connection.INonBlockingConnection;

public class xSocketDataHandler implements IDataHandler, IDisconnectHandler
{
    private ActionScriptTextDocumentService txtSrv;
    private String fileUrl = "";
    private MoonshineProjectConfigStrategy projectConfigStrategy;
    private MoonshineLanguageClient languageClient;
    private Gson gson;

    public xSocketDataHandler()
    {
        super();
        MessageJsonHandler messageJsonHandler = new MessageJsonHandler(new HashMap<>());
        gson = messageJsonHandler.getGson();
    }

    public String readTextFile(String filePath)
    {
        String content = "";
        try
        {
            content = new String(Files.readAllBytes(Paths.get(filePath)));
        }
        catch (IOException e)
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return content;
    }

    public boolean onDisconnect(INonBlockingConnection nbc)
    {
        System.exit(0);
        return true;
    }

    public boolean onData(INonBlockingConnection nbc) throws IOException, BufferUnderflowException, ClosedChannelException, MaxReadSizeExceededException
    {
        if(!nbc.isOpen())
        {
            return false;
        }
        try
        {
            int index = nbc.indexOf("\0");
            if(index == -1)
            {
                //the full data has not yet arrived -JT
                return false;
            }
            nbc.setAutoflush(true);
            String data = nbc.readStringByDelimiter("\0");

            JsonObject jsonObject = new JsonParser().parse(data).getAsJsonObject();

            int requestID = jsonObject.get("id").getAsInt();
            String method = jsonObject.get("method").getAsString();

            switch (method)
            {
                case "initialize":
                {
                    if(txtSrv == null)
                    {
                        InitializeParams initializeParams = gson.fromJson(jsonObject.getAsJsonObject("params"), InitializeParams.class);
                        txtSrv = new ActionScriptTextDocumentService();
                        Path workspaceRoot = Paths.get(URI.create(initializeParams.getRootUri()));
                        projectConfigStrategy = new MoonshineProjectConfigStrategy();
                        languageClient = new MoonshineLanguageClient();
                        languageClient.connection = nbc;
                        txtSrv.setProjectConfigStrategy(projectConfigStrategy);
                        txtSrv.setLanguageClient(languageClient);
                        txtSrv.setWorkspaceRoot(workspaceRoot);
                    }
                    String json = getJSONResponse(requestID, new InitializeResult(new ServerCapabilities()));
                    nbc.write(json + "\0");
                    break;
                }
                case "initialized":
                {
                    //this is a notification. send no response!
                    break;
                }
                case "shutdown":
                {
                    String json = getJSONResponse(requestID, null);
                    nbc.write(json + "\0");
                    break;
                }
                case "exit":
                {
                    Main.shutdownServer();
                    //this is a notification. send no response!
                    break;
                }
                case "textDocument/didOpen":
                {
                    try
                    {
                        DidOpenTextDocumentParams didOpenTextDocumentParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DidOpenTextDocumentParams.class);
                        txtSrv.didOpen(didOpenTextDocumentParams);
                    }
                    catch (Exception e)
                    {
                        e.printStackTrace();
                        System.err.println("Error didopen: " + e.getMessage());
                    }

                    //this is a notification. send no response!
                    break;
                }
                case "textDocument/didChange":
                {
                    try
                    {
                        DidChangeTextDocumentParams didChangeTextDocumentParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DidChangeTextDocumentParams.class);
                        txtSrv.didChange(didChangeTextDocumentParams);
                    }
                    catch (Exception e)
                    {
                        System.err.println("Error didchange: " + e.getMessage());
                    }

                    //this is a notification. send no response!
                    break;
                }
                case "workspace/didChangeConfiguration":
                {
                    JsonObject param = jsonObject.getAsJsonObject("params");
                    JsonObject config = param.getAsJsonObject("DidChangeConfigurationParams");
                    projectConfigStrategy.setChanged(true);
                    projectConfigStrategy.setConfigParams(config);
                    //this is a notification. send no response!
                    break;
                }
                case "textDocument/completion":
                {
                    try
                    {
                        TextDocumentPositionParams textDocumentPositionParams = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                        CompletableFuture<Either<List<CompletionItem>,CompletionList>> lst = txtSrv.completion(textDocumentPositionParams);
                        String json = getJSONResponse(requestID, lst.get());
                        //System.out.println("completion result : " + json);
                        nbc.write(json + "\0");

                    }
                    catch (Exception e)
                    {
                        System.err.println("Error completion: " + e.getMessage());
                    }
                    break;
                }
                case "textDocument/hover":
                {
                    TextDocumentPositionParams textDocumentPositionParams = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    CompletableFuture<Hover> hoverInfo = txtSrv.hover(textDocumentPositionParams);
                    String json = getJSONResponse(requestID, hoverInfo.get());
                    //System.out.println("hover result : " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "textDocument/signatureHelp":
                {
                    TextDocumentPositionParams textDocumentPositionParams = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    CompletableFuture<SignatureHelp> signatureInfo = txtSrv.signatureHelp(textDocumentPositionParams);
                    String json = getJSONResponse(requestID, signatureInfo.get());
                    //System.out.println("signature help result : " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "textDocument/definition":
                {
                    TextDocumentPositionParams txtPosParam = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    CompletableFuture<List<? extends Location>> signatureInfo = txtSrv.definition(txtPosParam);
                    String json = getJSONResponse(requestID, signatureInfo.get());
                    //System.out.println("definition result: " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "textDocument/documentSymbol":
                {
                    DocumentSymbolParams docSymbolParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DocumentSymbolParams.class);
                    CompletableFuture<List<? extends SymbolInformation>> symbolInfo = txtSrv.documentSymbol(docSymbolParams);
                    String json = getJSONResponse(requestID, symbolInfo.get());
                    //System.out.println("document symbol result: " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "workspace/symbol":
                {
                    WorkspaceSymbolParams workspaceSymbolParams = gson.fromJson(jsonObject.getAsJsonObject("params"), WorkspaceSymbolParams.class);
                    CompletableFuture<List<? extends SymbolInformation>> symbolInfo = txtSrv.workspaceSymbol(workspaceSymbolParams);
                    String json = getJSONResponse(requestID, symbolInfo.get());
                    //System.out.println("workspace symbol result: " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "textDocument/references":
                {
                    ReferenceParams refParams = gson.fromJson(jsonObject.getAsJsonObject("params"), ReferenceParams.class);
                    CompletableFuture<List<? extends Location>> refs = txtSrv.references(refParams);
                    String json = getJSONResponse(requestID, refs.get());
                    //System.out.println("references result: " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "textDocument/rename":
                {
                    RenameParams renameParams = gson.fromJson(jsonObject.getAsJsonObject("params"), RenameParams.class);
                    CompletableFuture<WorkspaceEdit> edits = txtSrv.rename(renameParams);
                    String json = getJSONResponse(requestID, edits.get());
                    //System.out.println("rename result: " + json);
                    nbc.write(json + "\0");
                    break;
                }
                case "workspace/executeCommand":
                {
                    ExecuteCommandParams executeCommandParams = gson.fromJson(jsonObject.getAsJsonObject("params"), ExecuteCommandParams.class);
                    CompletableFuture<Object> result = txtSrv.executeCommand(executeCommandParams);
                    String json = getJSONResponse(requestID, result.get());
                    //System.out.println("executeCommand result: " + json);
                    nbc.write(json + "\0");
                    break;
                }
                default:
                {
                    System.err.println("Unknown method: " + method);
                }
            }
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
            System.out.println(ex.getMessage() + "data handler " + ex.getStackTrace());
        }

        return true;
    }

    private String getJSONResponse(int id, Object result)
    {
        HashMap<String, Object> wrapper = new HashMap<>();
        wrapper.put("jsonrpc", "2.0");
        wrapper.put("id", id);
        wrapper.put("result", result);
        return gson.toJson(wrapper);
    }
}
