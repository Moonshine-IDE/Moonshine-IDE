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

        String spid = SysTools.getFormattedPID();
        System.out.println(spid);

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


