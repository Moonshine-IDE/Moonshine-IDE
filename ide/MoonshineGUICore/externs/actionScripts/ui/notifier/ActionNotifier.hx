package actionScripts.ui.notifier;

extern class ActionNotifier {

    public static function getInstance():ActionNotifier;

    public function notify(about:String):Void;

}