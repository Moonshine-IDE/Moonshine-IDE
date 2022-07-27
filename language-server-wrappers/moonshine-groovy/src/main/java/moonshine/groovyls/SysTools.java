////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package moonshine.groovyls;

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
