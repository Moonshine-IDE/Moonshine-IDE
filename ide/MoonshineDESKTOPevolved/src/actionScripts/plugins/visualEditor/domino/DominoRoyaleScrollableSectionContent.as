package actionScripts.plugins.visualEditor.domino
{
	import actionScripts.plugins.ondiskproj.crud.exporter.components.RoyaleElemenetBase;

	public class DominoRoyaleScrollableSectionContent extends RoyaleElemenetBase
	{
		public static function toCode(componentName:String, ambiguousName:String = ""):String
		{
			var scrollableSectionContent:String = readTemplate("elements/templates/royaleDominoElements/elements/ScrollableSectionContent.template");
			var viewComponent:String = readTemplate("elements/templates/royaleDominoElements/elements/ViewComponent.template");

			viewComponent = viewComponent.replace(/%ViewComponentName%/ig, componentName);
			viewComponent = viewComponent.replace(/%Namespace%/ig, componentName);

			scrollableSectionContent = scrollableSectionContent.replace(/%ViewComponentName%/ig, ambiguousName + componentName);
			scrollableSectionContent = scrollableSectionContent.replace(/%ViewComponent%/ig, viewComponent);

			return scrollableSectionContent;
		}
	}
}
