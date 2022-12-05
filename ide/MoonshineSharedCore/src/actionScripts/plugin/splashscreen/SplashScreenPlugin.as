
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
package actionScripts.plugin.splashscreen
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.collections.ArrayCollection;
    import mx.resources.ResourceManager;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.MenuEvent;
    import actionScripts.plugin.IMenuPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.settings.ISettingsProvider;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectReferenceVO;
    import actionScripts.valueObjects.TemplateVO;
    
    import components.views.splashscreen.SplashScreen;

	public class SplashScreenPlugin extends PluginBase implements IMenuPlugin, ISettingsProvider
	{
		override public function get name():String			{ return "Splash Screen Plugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Shows artsy splashscreen"; }
		
		public static const EVENT_SHOW_SPLASH:String = "showSplashEvent";
		
		[Bindable]
		public var showSplash:Boolean = true;

		[Bindable]
		public var projectsTemplates:ArrayCollection = new ArrayCollection();

		override public function activate():void
		{
			super.activate();
			
			if (showSplash)
			{				
				showSplashScreen();
			}
			
			dispatcher.addEventListener(EVENT_SHOW_SPLASH, handleShowSplash);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(EVENT_SHOW_SPLASH, handleShowSplash);
		}
		
		public function getMenu():MenuItem
		{
			// Since plugin will be activated if needed we can return null to block menu
			if( !_activated ) return null;
			
			return UtilsCore.getRecentProjectsMenu();
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new BooleanSetting(this, 'showSplash', 'Show splashscreen at startup')
			])
		}

		protected function handleShowSplash(event:Event):void
		{
			showSplashScreen();
		}

        private function showSplashScreen():void
        {
            // Don't add another splash if one is up already
            for each (var tab:IContentWindow in model.editors)
            {
                if (tab is SplashScreen) return;
            }

			var splashScreen:SplashScreen = new SplashScreen();
			splashScreen.plugin = this;

            model.editors.addItem(splashScreen);
			
            // following will load template data from local for desktop
            if (ConstantsCoreVO.IS_AIR)
            {
                projectsTemplates = getProjectsTemplatesForSpashScreen();
            }
        }

		private function getProjectsTemplatesForSpashScreen():ArrayCollection
		{
			var templates:Array = ConstantsCoreVO.TEMPLATES_PROJECTS.source.filter(filterProjectsTemplates);
			var specialTemplates:Array = ConstantsCoreVO.TEMPLATES_PROJECTS_SPECIALS.source.filter(filterProjectsTemplates);

			var fullCollection:ArrayCollection = new ArrayCollection(templates.concat(specialTemplates));
			UtilsCore.sortCollection(fullCollection, ["homeTitle"]);
			
			return fullCollection;
		}

		private function filterProjectsTemplates(item:TemplateVO, index:int, arr:Array):Boolean
		{
			return item.displayHome;
        }
    }
}