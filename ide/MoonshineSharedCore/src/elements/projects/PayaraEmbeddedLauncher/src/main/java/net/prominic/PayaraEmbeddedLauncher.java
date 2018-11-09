package net.prominic;

import java.io.File;
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


    public static void main(String[] args) {
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
        } catch (GlassFishException ex) {
            LOG.log(Level.SEVERE, null, ex);
        }
    }

}
