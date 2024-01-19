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
package actionScripts.plugin.dominoInterface
{
    import flash.net.Socket;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.utils.ByteArray;
    import mx.controls.Alert;
    import actionScripts.events.GlobalEventDispatcher;
    import view.suportClasses.events.DominoLotusScriptCompileReturnEvent;
    import view.suportClasses.events.DominoLotusScriptCompileConnectedEvent;
    public class DominoObjectsViewLotusScriptCompile 
	{
        
        private static var _instance:DominoObjectsViewLotusScriptCompile;
        public var  connected:Boolean = false;
        private var port:int = 20007;
        private var host:String = "127.0.0.1";
        private  var socket:Socket =null;
        public function DominoObjectsViewLotusScriptCompile(enforcer:DominoSingletonEnforcer)
		{
            if (!(enforcer is DominoSingletonEnforcer)) {
                throw new Error("Use SingletonClass.getInstance() to access the instance.");
            }
            socket= new Socket();
            // Add event listeners
            socket.addEventListener(Event.CONNECT, onConnect);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
            socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
            socket.addEventListener(Event.CLOSE, onClose);
            // Replace with your actual port number
            //socket.connect(host, port);
        }

        public static function getInstance():DominoObjectsViewLotusScriptCompile {
            if (_instance == null) {
                _instance = new DominoObjectsViewLotusScriptCompile(new DominoSingletonEnforcer());
            }
            return _instance;
        }
        public function doConnectAction():void {
            if (socket.connected) {
            }else{
                socket.connect(host, port);
            }
            
        }

        public function onClose(event:Event):void {
            GlobalEventDispatcher.getInstance().dispatchEvent(new DominoLotusScriptCompileConnectedEvent(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, false, true,true))
        }
        
        public function onConnect(event:Event):void {
            connected=true;
            GlobalEventDispatcher.getInstance().dispatchEvent(new DominoLotusScriptCompileConnectedEvent(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, true, true,true))
           
        }
        public function closeSocket():void 
        {
            //close sokect server side
            //sendString("lotusscriptvaild stop");
            GlobalEventDispatcher.getInstance().dispatchEvent(new DominoLotusScriptCompileConnectedEvent(DominoLotusScriptCompileConnectedEvent.DOMINO_LOTUSSCRIPT_COMPILE_CONNECTED, false, true,true))
            if (socket.connected) {
                socket.close();
            } 
        }

        public function sendString(data:String):void {
            // Send data to the server
            
            socket.writeUTFBytes(data);
            socket.flush();
           
            
        }

        public function onData(event:ProgressEvent):void {
            // Read the received data
            var receivedData:String = socket.readUTFBytes(socket.bytesAvailable);
             //Alert.show("Received data from server: " + receivedData);
             GlobalEventDispatcher.getInstance().dispatchEvent(new DominoLotusScriptCompileReturnEvent(DominoLotusScriptCompileReturnEvent.DOMINO_LOTUSSCRIPT_COMPILE, receivedData, true,true))
        }

        public function onError(event:IOErrorEvent):void {
             Alert.show("Error connecting to server: " + event.text);
        }
    }
   
}