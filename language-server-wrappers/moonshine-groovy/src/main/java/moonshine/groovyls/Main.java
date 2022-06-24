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

import net.prominic.groovyls.GroovyLanguageServer;
import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.services.LanguageClient;

public class Main {
    public static void main(String[] args) {

        String spid = SysTools.getFormattedPID();
        System.out.println(spid);

        GroovyLanguageServer server = new GroovyLanguageServer(new GrailsProjectCompilationUnitFactory());
        Launcher<LanguageClient> launcher = Launcher.createLauncher(server, LanguageClient.class, System.in,
                System.out);
        server.connect(launcher.getRemoteProxy());
        launcher.startListening();
    }
}
