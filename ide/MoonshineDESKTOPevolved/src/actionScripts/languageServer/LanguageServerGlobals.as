package actionScripts.languageServer
{

    import flash.events.EventDispatcher;

    public class LanguageServerGlobals {

        private static const LANGUAGE_SERVER_INSTANCES:Array = [];
        
        private static var dispatcher:EventDispatcher;

        private static function init():void {

            if ( dispatcher != null ) return;

            dispatcher = new EventDispatcher();

        }

        public static function addLanguageServerManager( languageServerManager:ILanguageServerManager ):Boolean {

            if ( LANGUAGE_SERVER_INSTANCES.indexOf( languageServerManager ) == -1 ) {
                LANGUAGE_SERVER_INSTANCES.push( languageServerManager );
                return true;
            }

            return false;

        }

        public static function removeLanguageServerManager( languageServerManager:ILanguageServerManager ):Boolean {

            var i:int = LANGUAGE_SERVER_INSTANCES.indexOf( languageServerManager );

            if ( i > -1 ) {
                LANGUAGE_SERVER_INSTANCES.removeAt( i );
                return true;
            }

            return false;

        }

        public static function getEventDispatcher():EventDispatcher {

            init();
            return dispatcher;

        }

        public static function getLanguageServerInstances():Array {

            return LANGUAGE_SERVER_INSTANCES;

        }

    }
}