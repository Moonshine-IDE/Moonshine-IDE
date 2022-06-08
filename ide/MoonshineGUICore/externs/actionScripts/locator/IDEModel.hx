package actionScripts.locator;

import mx.collections.ArrayCollection;
import actionScripts.interfaces.IFileBridge;

extern class IDEModel {

    public static function getInstance():IDEModel;

    public var editors:ArrayCollection;
    public var fileCore:IFileBridge;

}