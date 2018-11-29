package net.prominic;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.glassfish.embeddable.BootstrapProperties;
import org.glassfish.embeddable.Deployer;
import org.glassfish.embeddable.GlassFishRuntime;
import org.glassfish.embeddable.GlassFish;
import org.glassfish.embeddable.GlassFishException;
import org.glassfish.embeddable.GlassFishProperties;


/**
 *
 * @author Andrew Grabovetskyi
 */
public class PayaraEmbeddedLauncher {

    private static final Logger LOG = Logger.getLogger(PayaraEmbeddedLauncher.class.getName());


    public static void main(String[] args) throws IOException {
        try {
            System.out.println("[INFO] Starting embedded Payara...");
            System.out.println("[INFO] Project to be deployed: " + System.getProperty("net.prominic.project"));
            BootstrapProperties bootstrap = new BootstrapProperties();
            GlassFishRuntime runtime = GlassFishRuntime.bootstrap();
            GlassFishProperties glassfishProperties = new GlassFishProperties();
            glassfishProperties.setPort("http-listener", 8180);
            glassfishProperties.setPort("https-listener", 8183);
            GlassFish glassfish = runtime.newGlassFish(glassfishProperties);
            glassfish.start();
            Deployer deployer = glassfish.getDeployer();
            deployer.deploy(new File(System.getProperty("net.prominic.project")), "--name=app", "--contextroot=/", "--force=true");
            try (ServerSocket serverSocket = new ServerSocket(44444);
                 Socket clientSocket = serverSocket.accept();
                 BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));) {
                String inputLine;
                while ((inputLine = in.readLine()) != null) {
                    if (inputLine.equals("exit")) {
                        glassfish.stop();
                        glassfish.dispose();
                        break;
                    }
                }
            }
            System.out.println("[FINISHED] Starting embedded Payara server has been finished.");
        } catch (GlassFishException ex) {
            LOG.log(Level.SEVERE, null, ex);
            System.out.println("[ERROR] " + ex);
            System.out.println("[FAILED] Server failed to start");
        }
    }

}
