package actionScripts.locator;

import mx.collections.ArrayCollection;

extern class IDEModel {

    public static function getInstance():IDEModel;

    public var editors:ArrayCollection;

}