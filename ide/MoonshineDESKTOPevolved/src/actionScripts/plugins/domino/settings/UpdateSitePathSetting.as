package actionScripts.plugins.domino.settings
{
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.domino.view.UpdateSitePathRenderer;
	
	public class UpdateSitePathSetting extends PathSetting
	{
		public static const EVENT_GENRATE_SITE:String = "generateUpdateSite";
		
		private var updateSiteRenderer:UpdateSitePathRenderer;
		
		public function UpdateSitePathSetting(provider:Object, name:String, label:String, directory:Boolean, path:String=null, isSDKPath:Boolean=false, isDropDown:Boolean=false, defaultPath:String=null)
		{
			super(provider, name, label, directory, path, isSDKPath, isDropDown, defaultPath);
		}
		
		override public function get renderer():IVisualElement
		{
			if (!updateSiteRenderer)
			{
				updateSiteRenderer = new UpdateSitePathRenderer();
				updateSiteRenderer.setting = this;
				updateSiteRenderer.enabled = _editable;
				updateSiteRenderer.isGenerateButton = _isGenerateButton; 
				updateSiteRenderer.setMessage(message, messageType);
			}
			
			return updateSiteRenderer;
		}
		
		private var _isGenerateButton:Boolean = true;
		public function set isGenerateButton(value:Boolean):void
		{
			_isGenerateButton = value;
			if (updateSiteRenderer)
			{
				updateSiteRenderer.isGenerateButton = value;
			}
		}
		
		private var _editable:Boolean = true;
		override public function set editable(value:Boolean):void
		{
			_editable = value;
			if (updateSiteRenderer) 
			{
				updateSiteRenderer.enabled = _editable;
			}
		}
		
		public function set path(value:String):void
		{
			if (updateSiteRenderer)
			{
				updateSiteRenderer.path = value;	
			}
		}
	}
}