package moonshine;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
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
import com.nextgenactionscript.vscode.ActionScriptLanguageServer;
import com.nextgenactionscript.vscode.ActionScriptTextDocumentService;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.DidChangeConfigurationParams;
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
import org.eclipse.lsp4j.services.TextDocumentService;
import org.eclipse.lsp4j.services.WorkspaceService;
import org.xsocket.MaxReadSizeExceededException;
import org.xsocket.connection.IDataHandler;
import org.xsocket.connection.IDisconnectHandler;
import org.xsocket.connection.INonBlockingConnection;

public class xSocketDataHandler implements IDataHandler, IDisconnectHandler
{
    private static final String MESSAGE_DELIMITER = "\r\n";
    private static final String END_OF_HEADER = "\r\n\r\n";
    private static final String HEADER_FIELD_CONTENT_LENGTH = "Content-Length: ";

    private ActionScriptLanguageServer languageServer;
    private MoonshineProjectConfigStrategy projectConfigStrategy;
    private MoonshineLanguageClient languageClient;
    private Gson gson;
    private int contentLength = -1;

    public xSocketDataHandler()
    {
        super();
        languageServer = new ActionScriptLanguageServer();
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
            boolean needsHeader = contentLength == -1;
            if(needsHeader && nbc.indexOf(END_OF_HEADER) == -1)
            {
                //header not complete yet
                return false;
            }
            while(needsHeader)
            {
                int index = nbc.indexOf(MESSAGE_DELIMITER);
                if(index == -1)
                {
                    System.err.println("Missing header delimiter.");
                }
                String headerField = nbc.readStringByDelimiter(MESSAGE_DELIMITER);
                if(index == 0)
                {
                    //this is the end of the header
                    needsHeader = false;
                }
                else if(headerField.startsWith(HEADER_FIELD_CONTENT_LENGTH))
                {
                    String contentLengthAsString = headerField.substring(HEADER_FIELD_CONTENT_LENGTH.length());
                    contentLength = Integer.parseInt(contentLengthAsString);
                }
            }
            if(contentLength == -1)
            {
                System.err.println("Language server failed to parse Content-Length header");
                return false;
            }
            if(nbc.available() < contentLength)
            {
                //the full content part has not yet arrived -JT
                return false;
            }

            nbc.setAutoflush(true);

            String data = nbc.readStringByLength(contentLength);
            
            //get ready for the next message
            contentLength = -1;

            JsonObject jsonObject = null;
            
            try
            {
                jsonObject = new JsonParser().parse(data).getAsJsonObject();
            }
            catch(Exception e)
            {
                StringWriter stackTrace = new StringWriter();
                e.printStackTrace(new PrintWriter(stackTrace));
                String json = getJSONError(null, -32600, "Invalid request. " + stackTrace.toString());
                nbc.write(json);
                return true;
            }

            int requestID = jsonObject.get("id").getAsInt();
            String method = jsonObject.get("method").getAsString();

            switch (method)
            {
                case "initialize":
                {
                    if(languageClient != null)
                    {
                        System.err.println("Error initialize: Already initialized.");
                        break;
                    }

                    String json = null;
                    InitializeParams initializeParams = null;
                    try
                    {
                        initializeParams = gson.fromJson(jsonObject.getAsJsonObject("params"), InitializeParams.class);
                    }
                    catch (Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    
                    if(json == null)
                    {
                        try
                        {
                            languageClient = new MoonshineLanguageClient();
                            languageClient.connection = nbc;
                            languageServer.connect(languageClient);
                            
                            projectConfigStrategy = new MoonshineProjectConfigStrategy();
    
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            ((ActionScriptTextDocumentService) txtSrv).setProjectConfigStrategy(projectConfigStrategy);

                            languageServer.initialize(initializeParams);
                            json = getJSONResponse(requestID, new InitializeResult(new ServerCapabilities()));
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }

                    nbc.write(json);
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
                    nbc.write(json);
                    break;
                }
                case "exit":
                {
                    try
                    {
                        Main.shutdownServer();
                    }
                    catch(Exception e)
                    {
                        //ignore
                    }
                    //this is a notification. send no response!
                    break;
                }
                case "textDocument/didOpen":
                {
                    String json = null;
                    DidOpenTextDocumentParams didOpenTextDocumentParams = null;
                    try
                    {
                        didOpenTextDocumentParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DidOpenTextDocumentParams.class);
                    }
                    catch (Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }

                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            txtSrv.didOpen(didOpenTextDocumentParams);
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }

                    //this is a notification. send no response unless there's
                    //an error!
                    if(json != null)
                    {
                        nbc.write(json);
                    }
                    break;
                }
                case "textDocument/didChange":
                {
                    String json = null;
                    DidChangeTextDocumentParams didChangeTextDocumentParams = null;
                    try
                    {
                        didChangeTextDocumentParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DidChangeTextDocumentParams.class);
                    }
                    catch (Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            txtSrv.didChange(didChangeTextDocumentParams);
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }

                    //this is a notification. send no response unless there's
                    //an error!
                    if(json != null)
                    {
                        nbc.write(json);
                    }
                    break;
                }
                case "workspace/didChangeConfiguration":
                {
                    String json = null;
                    DidChangeConfigurationParams didChangeConfigurationParams = null;
                    try
                    {
                        didChangeConfigurationParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DidChangeConfigurationParams.class);
                    }
                    catch (Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    
                    if(json == null)
                    {
                        try
                        {
                            WorkspaceService wkspSrv = languageServer.getWorkspaceService();
                            wkspSrv.didChangeConfiguration(didChangeConfigurationParams);
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }

                    //this is a notification. send no response unless there's
                    //an error!
                    if(json != null)
                    {
                        nbc.write(json);
                    }
                    break;
                }
                case "moonshine/didChangeProjectConfiguration":
                {
                    JsonObject param = jsonObject.getAsJsonObject("params");
                    projectConfigStrategy.setChanged(true);
                    projectConfigStrategy.setConfigParams(param);

                    TextDocumentService txtSrv = languageServer.getTextDocumentService();
                    ((ActionScriptTextDocumentService) txtSrv).checkForProblemsNow();

                    //this is a notification. send no response!
                    break;
                }
                case "textDocument/completion":
                {
                    String json = null;
                    TextDocumentPositionParams textDocumentPositionParams = null;
                    try
                    {
                        textDocumentPositionParams = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<Either<List<CompletionItem>,CompletionList>> lst = txtSrv.completion(textDocumentPositionParams);
                            json = getJSONResponse(requestID, lst.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("completion result: " + json);
                    nbc.write(json);
                    break;
                }
                case "textDocument/hover":
                {
                    String json = null;
                    TextDocumentPositionParams textDocumentPositionParams = null;
                    try
                    {
                        textDocumentPositionParams = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<Hover> hoverInfo = txtSrv.hover(textDocumentPositionParams);
                            json = getJSONResponse(requestID, hoverInfo.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("hover result: " + json);
                    nbc.write(json);
                    break;
                }
                case "textDocument/signatureHelp":
                {
                    String json = null;
                    TextDocumentPositionParams textDocumentPositionParams = null;
                    try
                    {
                        textDocumentPositionParams = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<SignatureHelp> signatureInfo = txtSrv.signatureHelp(textDocumentPositionParams);
                            json = getJSONResponse(requestID, signatureInfo.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("signature help result: " + json);
                    nbc.write(json);
                    break;
                }
                case "textDocument/definition":
                {
                    String json = null;
                    TextDocumentPositionParams txtPosParam = null;
                    try
                    {
                        txtPosParam = gson.fromJson(jsonObject.getAsJsonObject("params"), TextDocumentPositionParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<List<? extends Location>> definitionInfo = txtSrv.definition(txtPosParam);
                            json = getJSONResponse(requestID, definitionInfo.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("definition result: " + json);
                    nbc.write(json);
                    break;
                }
                case "textDocument/documentSymbol":
                {
                    String json = null;
                    DocumentSymbolParams docSymbolParams = null;
                    try
                    {
                        docSymbolParams = gson.fromJson(jsonObject.getAsJsonObject("params"), DocumentSymbolParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<List<? extends SymbolInformation>> symbolInfo = txtSrv.documentSymbol(docSymbolParams);
                            json = getJSONResponse(requestID, symbolInfo.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("document symbol result: " + json);
                    nbc.write(json);
                    break;
                }
                case "workspace/symbol":
                {
                    String json = null;
                    WorkspaceSymbolParams workspaceSymbolParams = null;
                    try
                    {
                        workspaceSymbolParams = gson.fromJson(jsonObject.getAsJsonObject("params"), WorkspaceSymbolParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            WorkspaceService wkspSrv = languageServer.getWorkspaceService();
                            CompletableFuture<List<? extends SymbolInformation>> symbolInfo = wkspSrv.symbol(workspaceSymbolParams);
                            json = getJSONResponse(requestID, symbolInfo.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("workspace symbol result: " + json);
                    nbc.write(json);
                    break;
                }
                case "textDocument/references":
                {
                    String json = null;
                    ReferenceParams refParams = null;
                    try
                    {
                        refParams = gson.fromJson(jsonObject.getAsJsonObject("params"), ReferenceParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<List<? extends Location>> refs = txtSrv.references(refParams);
                            json = getJSONResponse(requestID, refs.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("references result: " + json);
                    nbc.write(json);
                    break;
                }
                case "textDocument/rename":
                {
                    String json = null;
                    RenameParams renameParams = null;
                    try
                    {
                        renameParams = gson.fromJson(jsonObject.getAsJsonObject("params"), RenameParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            TextDocumentService txtSrv = languageServer.getTextDocumentService();
                            CompletableFuture<WorkspaceEdit> edits = txtSrv.rename(renameParams);
                            json = getJSONResponse(requestID, edits.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("rename result: " + json);
                    nbc.write(json);
                    break;
                }
                case "workspace/executeCommand":
                {
                    String json = null;
                    ExecuteCommandParams executeCommandParams = null;
                    try
                    {
                        executeCommandParams = gson.fromJson(jsonObject.getAsJsonObject("params"), ExecuteCommandParams.class);
                    }
                    catch(Exception e)
                    {
                        StringWriter stackTrace = new StringWriter();
                        e.printStackTrace(new PrintWriter(stackTrace));
                        json = getJSONError(requestID, -32602, "Invalid params. " + stackTrace.toString());
                    }
                    if(json == null)
                    {
                        try
                        {
                            WorkspaceService wkspSrv = languageServer.getWorkspaceService();
                            CompletableFuture<Object> result = wkspSrv.executeCommand(executeCommandParams);
                            json = getJSONResponse(requestID, result.get());
                        }
                        catch(Exception e)
                        {
                            StringWriter stackTrace = new StringWriter();
                            e.printStackTrace(new PrintWriter(stackTrace));
                            json = getJSONError(requestID, -32603, "Internal error. " + stackTrace.toString());
                        }
                    }
                    //System.out.println("executeCommand result: " + json);
                    nbc.write(json);
                    break;
                }
                default:
                {
                    String json = getJSONError(requestID, -32601, "Method not found: " + method);
                    nbc.write(json);
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
        String json = gson.toJson(wrapper);

        StringBuilder builder = new StringBuilder();
        builder.append("Content-Length: ");
        builder.append(json.getBytes().length);
        builder.append("\r\n");
        builder.append("\r\n");
        builder.append(json);
        return builder.toString();
    }

    private String getJSONError(Integer id, int code, String message)
    {
        HashMap<String, Object> error = new HashMap<>();
        error.put("code", code);
        error.put("message", message);
        HashMap<String, Object> wrapper = new HashMap<>();
        wrapper.put("jsonrpc", "2.0");
        wrapper.put("id", id);
        wrapper.put("error", error);
        String json = gson.toJson(wrapper);

        StringBuilder builder = new StringBuilder();
        builder.append("Content-Length: ");
        builder.append(json.getBytes().length);
        builder.append("\r\n");
        builder.append("\r\n");
        builder.append(json);
        return builder.toString();
    }
}
