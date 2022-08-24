package actionScripts.plugins.core;

import actionScripts.events.NewProjectEvent;
import actionScripts.valueObjects.FileWrapper;

extern class ProjectBridgeImplBase {

    function new();
    function createProject(event:NewProjectEvent):Void;
    function deleteProject(projectWrapper:FileWrapper, finishHandler:(FileWrapper)->Void, isDeleteRoot:Bool=false):Void;

}