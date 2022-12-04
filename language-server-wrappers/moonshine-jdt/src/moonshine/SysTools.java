////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
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
