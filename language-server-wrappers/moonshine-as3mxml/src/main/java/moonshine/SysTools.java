package moonshine;

import java.lang.management.ManagementFactory;

public class SysTools {

    private static final String JAVA_VERSION = "java.version";

    public static int getJavaVersion() {

        String[] versionElements = System.getProperty(JAVA_VERSION).split("\\.");
        int discard = Integer.parseInt(versionElements[0]);
        int javaVersion;
        if (discard == 1) {
            javaVersion = Integer.parseInt(versionElements[1]);
        } else {
            javaVersion = discard;
        }
        return javaVersion;

    }

    private static long getPID8() {

        String jvmName = ManagementFactory.getRuntimeMXBean().getName();
        long pid = Long.parseLong(jvmName.split("@")[0]);

        // Since Java 9
        // pid = ProcessHandle.current().pid();

        // Since Java 10
        // pid = ManagementFactory.getRuntimeMXBean().getPid();

        return pid;

    }

    public static String getFormattedPID() {

        long pid;
        String spid;

        // int javaVersion = getJavaVersion();
        pid = getPID8();
        spid = Long.toString(pid);
        spid = "%%%" + spid + "%%%";
        return spid;

    }

    public static boolean isMac() {

        return System.getProperty("os.name").toLowerCase().contains("mac");

    }

    public static boolean isWindows() {

        return System.getProperty("os.name").toLowerCase().contains("windows");

    }

    public static boolean isLinux() {

        return System.getProperty("os.name").toLowerCase().contains("linux");

    }

}
