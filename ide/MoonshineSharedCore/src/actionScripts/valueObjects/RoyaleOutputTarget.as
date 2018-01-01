////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
    public class RoyaleOutputTarget
    {
        private var _name:String;
        private var _version:String;
        private var _airVersion:String;
        private var _flashVersion:String;

        public function RoyaleOutputTarget(name:String, version:String,
                                           airVersion:String = null, flashVersion:String = null)
        {
            _name = name;
            _version = version;
            _airVersion = airVersion;
            _flashVersion = flashVersion;
        }

        public function get name():String
        {
            return _name;
        }

        public function get version():String
        {
            return _version;
        }

        public function get airVersion():String
        {
            return _airVersion;
        }

        public function get flashVersion():String
        {
            return _flashVersion;
        }
    }
}
