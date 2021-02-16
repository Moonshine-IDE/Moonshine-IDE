package moonshine;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.nio.file.Path;

import com.as3mxml.vscode.project.IProjectConfigStrategy;
import com.as3mxml.vscode.project.IProjectConfigStrategyFactory;
import com.as3mxml.vscode.services.ActionScriptLanguageClient;

import org.eclipse.lsp4j.WorkspaceFolder;
import org.eclipse.lsp4j.jsonrpc.Launcher;

public class Main
{
    private static final String SYSTEM_PROPERTY_PORT = "moonshine.port";
    private static final String SYSTEM_PROPERTY_FRAMEWORK_LIB = "royalelib";
    private static final int ERROR_CODE_FRAMEWORK_LIB = 1001;
    private static final int ERROR_CODE_CONNECT = 1002;
    private static final String SOCKET_HOST = "localhost";

    public static void main(String[] args)
    {
        String frameworkLib = System.getProperty(SYSTEM_PROPERTY_FRAMEWORK_LIB);
        if(frameworkLib == null)
        {
            System.err.println("Error: Missing royalelib system property. Usage: -Droyalelib=path/to/frameworks");
            System.exit(ERROR_CODE_FRAMEWORK_LIB);
        }
        String portAsString = System.getProperty(SYSTEM_PROPERTY_PORT);
        try
        {
            InputStream inputStream = System.in;
            OutputStream outputStream = System.out;
            if (portAsString != null)
            {
                Socket socket = new Socket(SOCKET_HOST, Integer.parseInt(portAsString));
                inputStream = socket.getInputStream();
                outputStream = socket.getOutputStream();
            }

            MoonshineProjectConfigStrategyFactory factory = new MoonshineProjectConfigStrategyFactory();
            MoonshineLanguageServer server = new MoonshineLanguageServer(factory);
            Launcher<ActionScriptLanguageClient> launcher = Launcher.createLauncher(
                server, ActionScriptLanguageClient.class, inputStream, outputStream);
            server.connect(launcher.getRemoteProxy());
            launcher.startListening();
        }
        catch (Exception e)
        {
            System.err.println("ActionScript & MXML language server failed to connect.");
            e.printStackTrace(System.err);
            System.exit(ERROR_CODE_CONNECT);
        }
    }

    private static class MoonshineProjectConfigStrategyFactory implements IProjectConfigStrategyFactory
    {
        public IProjectConfigStrategy create(Path projectPath, WorkspaceFolder folder)
        {
            return new MoonshineProjectConfigStrategy(projectPath, folder);
        }
    }
}


