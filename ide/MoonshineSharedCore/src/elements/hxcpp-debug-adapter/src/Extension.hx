import vscode.*;
import Vscode.*;

class Extension {
	@:expose("activate")
	static function main(context:ExtensionContext) {
		commands.registerCommand("hxcpp-debugger.setup", function() {
			var terminal = window.createTerminal();
			terminal.sendText("haxelib dev hxcpp-debug-server \"" + context.asAbsolutePath("hxcpp-debug-server") + "\"");
			terminal.show();
			context.globalState.update("previousExtensionPath", context.extensionPath);
		});

		if (isExtensionPathChanged(context)) {
			commands.executeCommand("hxcpp-debugger.setup");
		}

		Vscode.debug.registerDebugConfigurationProvider("hxcpp", {resolveDebugConfiguration: resolveDebugConfiguration});
	}

	static function isExtensionPathChanged(context:ExtensionContext):Bool {
		var previousPath = context.globalState.get("previousExtensionPath");
		return (context.extensionPath != previousPath);
	}

	static function resolveDebugConfiguration(folder:Null<WorkspaceFolder>, config:DebugConfiguration,
			?token:CancellationToken):ProviderResult<DebugConfiguration> {
		if (config.type == null) {
			return null; // show launch.json
		}
		return config;
	}
}
