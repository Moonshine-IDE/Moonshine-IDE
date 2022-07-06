package moonshine.data.preferences;

import haxe.DynamicAccess;
import haxe.Json;
import lime.system.System;

#if sys
import sys.io.File;
#end

#if flash
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
#end

/**
    Standardized way to access and store Moonshine preferences (previously stored in SharedObjects)
**/
class MoonshinePreferences {

    //
    // Static
    //

    static final CACHE:Map<String, MoonshinePreferences> = [];
    static final EXTENSION:String = ".prefs";
    static final HISTORY:String = "history";
    static final WORKSPACE:String = "workspace";
    static inline final DEFAULT:String = "default";

    static var prettyPrint:Bool = true;

    /**
        Get the desired preferences singleton object.
        It works as a SharedObject in AS3, it reads/writes data from/to a local file.
        @param name The name of the preferences object. Default is 'default'
    **/
    public static function getLocal( ?name:String = DEFAULT ):MoonshinePreferences {

        if ( CACHE.exists( name ) ) return CACHE.get( name );

        var mp = new MoonshinePreferences();
        mp._name = name;
        var dir = System.applicationStorageDirectory;
        var filePath = dir + "/" + name + EXTENSION;
        mp._loadFromFile( filePath );
        CACHE.set( name, mp );
        return mp;

    }

    //
    // Private properties
    //

    private final _defaultHistory:History = { previousCommands: [], numLines: 0, dockState: 0 };
    private final _defaultWorkspace:Workspace = { current: "None", workspaces: { "aaa": [] } };
    
    private var _autoFlush:Bool = true;
    private var _data:DynamicAccess<Dynamic>;
    private var _name:String;
    private var _path:String;

    //
    // Public properties
    //

    public var autoFlush( get, set ):Bool;
    public var history( get, never ):History;
    public var workspace( get, never ):Workspace;

    //
    // Getters, Setters
    //

    function get_autoFlush():Bool return _autoFlush;
    function get_history():History return cast _data.get( HISTORY );
    function get_workspace():Workspace return cast _data.get( WORKSPACE );

    function set_autoFlush( value:Bool ):Bool return _autoFlush = value;

    //
    // Private methods
    //

    function new() {

        _data = {};

        _data.set( HISTORY, _defaultHistory );
        _data.set( WORKSPACE, _defaultWorkspace );

    }

    function _loadFromFile( path:String ) {

        _path = path;

        var s = "";

        try {

            #if sys
            s = File.getContent( _path );
            #end

            #if flash
            var f = new File( _path );
            if ( f.exists ) {
                var fs = new FileStream();
                fs.open( f, FileMode.READ );
                s = fs.readUTFBytes( f.size );
                fs.close();
            }
            #end

        } catch ( e ) {}

        if ( s != "" ) {

            var o = Json.parse( s );
            if ( o.prefs != null ) _data = o.prefs;
            if ( _data.get( HISTORY ) == null ) _data.set( HISTORY, _defaultHistory );
            if ( _data.get( WORKSPACE ) == null ) _data.set( WORKSPACE, _defaultWorkspace );

        }

    }

    //
    // Public methods
    //

    /**
        Clears History
    **/
    public function clearHistory() {

        _data.set( HISTORY, _defaultHistory );

    }

    /**
        Disposes the resources.
    **/
    public function dispose( flush:Bool = false ) {

        if ( flush ) this.flush();
        CACHE.remove( _name );
        _data = null;

    }

    /**
        Call flush() to save data in the local filesystem.
    **/
    public function flush() {

        var o = { prefs: _data };
        var s = Json.stringify( o, ( prettyPrint ) ? "\t" : null );

        try {

            #if sys
            File.saveContent( _path, s );
            #end

            #if flash
            var f = new File( _path );
            var fs = new FileStream();
            fs.open( f, FileMode.WRITE );
            fs.writeUTFBytes( s );
            fs.close();
            #end

        } catch ( e ) {}

    }

}