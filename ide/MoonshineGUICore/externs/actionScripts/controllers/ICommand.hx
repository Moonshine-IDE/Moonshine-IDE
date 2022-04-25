package actionScripts.controllers;

import flash.events.Event;

interface ICommand {

    function execute(event:Event):Void;
    
}