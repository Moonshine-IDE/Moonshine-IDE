package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleElemenetBase;

	public class DominoRoyaleDrawerDataProvider extends RoyaleElemenetBase
	{
		public static function toCode(drawerLabel:String, drawerContent:String):String
		{
			var drawerObject:String = readTemplate("elements/templates/royaleDominoElements/elements/DrawerDataProvider.template");

			drawerObject = drawerObject.replace(/%DrawerLabel%/ig, drawerLabel);
			drawerObject = drawerObject.replace(/%DrawerContent%/ig, drawerContent);

			return drawerObject + "\n";
		}
	}
}
