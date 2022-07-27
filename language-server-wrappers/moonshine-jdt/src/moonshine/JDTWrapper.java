package moonshine;

import org.eclipse.equinox.launcher.Main;

public class JDTWrapper extends Main {
    
    public static void main( String[] args ) {

        String spid = SysTools.getFormattedPID();
        System.out.println(spid);

        Main.main( args );

    }

}
