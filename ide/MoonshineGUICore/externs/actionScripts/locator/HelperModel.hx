package actionScripts.locator;

import actionScripts.valueObjects.ComponentVO;
import feathers.data.ArrayCollection;

extern class HelperModel {

	public var components:ArrayCollection<ComponentVO>;
    public var packages:ArrayCollection<ComponentVO>;

    public static function getInstance():HelperModel;

}