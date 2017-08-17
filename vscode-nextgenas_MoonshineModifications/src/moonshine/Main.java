package moonshine;

import java.io.IOException;
import java.net.SocketException;
import java.net.UnknownHostException;

import org.xsocket.connection.IServer;
import org.xsocket.connection.Server;

public class Main
{
    private static final String SYSTEM_PROPERTY_PORT = "moonshine.port";
    private static final int ERROR_CODE_PORT = 1000;
    
    protected static IServer srv = null;

    public static void main(String[] args)
    {
        String portAsString = System.getProperty(SYSTEM_PROPERTY_PORT);
        if(portAsString == null)
        {
            System.err.println("Error: Missing moonshine.port");
            System.exit(ERROR_CODE_PORT);
        }
        int portAsInt = -1;
        try
        {
            portAsInt = Integer.parseInt(portAsString);
        }
        catch (NumberFormatException e)
        {
            System.err.println("Error: Invalid moonshine.port " + portAsString);
            e.printStackTrace();
            System.exit(ERROR_CODE_PORT);
        }
        try
        {
            srv = new Server(portAsInt, new xSocketDataHandler());
            srv.run();
        }
        catch (SocketException e)
        {
            e.printStackTrace();
        }
        catch (UnknownHostException e)
        {
            System.err.println("Error: " + e.toString());
            e.printStackTrace();

        }
        catch (IOException e)
        {
            // TODO Auto-generated catch block
            System.err.println("Error: " + e.toString());
            e.printStackTrace();
        }
        catch (Throwable e)
        {
            e.printStackTrace();
        }
    }

    protected static void shutdownServer()
    {
        try
        {
            srv.close();

        }
        catch (Exception ex)
        {
            System.err.println("Error: " + ex.toString());
            ex.printStackTrace();
        }

    }
}


