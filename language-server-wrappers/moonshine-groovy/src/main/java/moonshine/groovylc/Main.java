package moonshine.groovylc;

import net.prominic.groovyls.GroovyLanguageServer;
import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.services.LanguageClient;

public class Main
{
    public static void main(String[] args) {
        GroovyLanguageServer server = new GroovyLanguageServer();
        Launcher<LanguageClient> launcher = Launcher.createLauncher(server, LanguageClient.class, System.in,
                System.out);
        server.connect(launcher.getRemoteProxy());
        launcher.startListening();
    }
}


