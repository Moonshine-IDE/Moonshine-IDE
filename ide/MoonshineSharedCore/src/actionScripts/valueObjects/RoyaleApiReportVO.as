////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.valueObjects
{
    import actionScripts.factory.FileLocation;

    public class RoyaleApiReportVO
    {
        public function RoyaleApiReportVO(royaleSdkPath:String, flexSdkPath:String, libraries:Vector.<FileLocation>, mainAppFile:String,
                                          reportOutputPath:String, reportOutputLogPath:String, workingDirectory:String)
        {
            _royaleSdkPath = royaleSdkPath;
            _flexSdkPath = flexSdkPath;
            _libraries = libraries;
            _mainAppFile = mainAppFile;
            _reportOutputPath = reportOutputPath;
            _reportOutputLogPath = reportOutputLogPath;
            _workingDirectory = workingDirectory;
        }

        private var _royaleSdkPath:String;
        public function get royaleSdkPath():String
        {
            return _royaleSdkPath;
        }

        private var _flexSdkPath:String;
        public function get flexSdkPath():String
        {
            return _flexSdkPath;
        }

        private var _libraries:Vector.<FileLocation>;
        public function get libraries():Vector.<FileLocation>
        {
            return _libraries;
        }

        private var _mainAppFile:String;
        public function get mainAppFile():String
        {
            return _mainAppFile;
        }

        private var _reportOutputPath:String;
        public function get reportOutputPath():String
        {
            return _reportOutputPath;
        }

        private var _reportOutputLogPath:String;
        public function get reportOutputLogPath():String
        {
            return _reportOutputLogPath;
        }

        private var _workingDirectory:String;
        public function get workingDirectory():String
        {
            return _workingDirectory;
        }
    }
}
