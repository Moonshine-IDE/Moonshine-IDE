package actionScripts.interfaces;

import actionScripts.events.NewProjectEvent;
import actionScripts.valueObjects.FileWrapper;

interface IProject {

    function createProject(event:NewProjectEvent):Void;

    /**
    *
    * @param projectWrapper
    * @param finishHandler - handler must return FileWrapper object
    */
    function deleteProject(projectWrapper:FileWrapper, finishHandler:(FileWrapper)->Void, isDeleteRoot:Bool=false):Void;

    function getCorePlugins():Array<Dynamic>;
    function getDefaultPlugins():Array<Dynamic>;
    function getPluginsNotToShowInSettings():Array<Dynamic>;

    var runtimeVersion(get, never):String;
    var version(get, never):String;

    //function get runtimeVersion():String;
    //function get version():String;

}