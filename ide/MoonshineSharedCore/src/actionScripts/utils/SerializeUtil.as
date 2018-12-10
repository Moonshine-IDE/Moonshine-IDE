package actionScripts.utils
{
    public class SerializeUtil
    {
        /**
         * Serializes a Boolean value into True or False strings.
         */
        public static function serializeBoolean(b:Boolean):String
        {
            return b ? "True" : "False";
        }

        /**
         * Serialize a String value so it's empty when null
         */
        public static function serializeString(str:String):String
        {
            return str ? str : "";
        }

        /**
         * Serialize key-value pairs to FD-like XML elements using a template element
         *  Example:
         *		<option accessible="True" />
         *		<option allowSourcePathOverlap="True" />
         *		<option benchmark="True" />
         *		<option es="True" />
         *		<option locale="" />
         */
        public static function serializePairs(pairs:Object, template:XML):XMLList
        {
            var list:XML = <xml/>;
            for (var key:String in pairs) {
                var node:XML = template.copy();
                node.@[key] = pairs[key];
                list.appendChild(node);
            }
            return list.children();
        }

        public static function serializeObjectPairs(pairs:Object, template:XML):XMLList
        {
            var list:XML = <xml/>;

            var node:XML = template.copy();
            var hasProperties:Boolean = false;

            for (var key:String in pairs)
            {
                node.@[key] = pairs[key];
                hasProperties = true;
            }

            if (hasProperties)
            {
                list.appendChild(node);
            }

            return list.children();
        }

        /**
         * Deserializes True and False strings to true and false Boolean values.
         */
        public static function deserializeBoolean(o:Object):Boolean
        {
            var str:String = o.toString();
            return str.toLowerCase() == "true";
        }

        /**
         * Deserialize a String value so it's null when empty
         */
        public static function deserializeString(o:Object):String
        {
            var str:String = o.toString();
            if (str.length == 0) return null;
            if (str == "null") return null;
            return str;
        }
    }
}
