import js.lib.Promise;
import vscode.*;

class Extension {
	@:expose("activate")
	static function main(context:ExtensionContext) {
		Vscode.debug.registerDebugConfigurationProvider("hl", {resolveDebugConfiguration: resolveDebugConfiguration});
	}

	static function resolveDebugConfiguration(folder:Null<WorkspaceFolder>, config:DebugConfiguration,
			?token:CancellationToken):ProviderResult<DebugConfiguration> {
		var config:DebugConfiguration & Arguments = cast config;
		if (Sys.systemName() == "Mac") {
			final visitButton = "Visit GitHub Issue";
			Vscode.window.showErrorMessage("HashLink debugging on macOS is not supported yet.", visitButton).then(function(choice) {
				if (choice == visitButton) {
					Vscode.env.openExternal(Uri.parse("https://github.com/vshaxe/hashlink-debugger/issues/28"));
				}
			});
			return null;
		}
		if (config.type == null) {
			return null; // show launch.json
		}
		return new Promise(function(resolve:DebugConfiguration->Void, reject) {
			var vshaxe:Vshaxe = Vscode.extensions.getExtension("nadako.vshaxe").exports;
			vshaxe.getActiveConfiguration().then(function(haxeConfig) {
				switch haxeConfig.target {
					case Hl(file):
						if (config.program == null) {
							config.program = file;
						}
						config.classPaths = haxeConfig.classPaths.map(cp -> cp.path);
						resolve(config);

					case _:
						reject('Please use a Haxe configuration that targets HashLink (found target "${haxeConfig.target.getName().toLowerCase()}" instead).');
				}
			}, function(error) {
				reject("Unable to retrieve active Haxe configuration: " + error);
			});
		});
	}
}
