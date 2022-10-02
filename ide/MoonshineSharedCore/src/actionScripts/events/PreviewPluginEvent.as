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
package actionScripts.events
{
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.Event;

    public class PreviewPluginEvent extends Event
    {
        public static const START_VISUALEDITOR_PREVIEW:String = "startVisualEditorPreview";
        public static const STOP_VISUALEDITOR_PREVIEW:String = "stopVisualEditorPreview";

        public static const PREVIEW_START_COMPLETE:String = "previewStartComplete";
        public static const PREVIEW_STARTING:String = "previewStarting";
        public static const PREVIEW_START_FAILED:String = "previewStartFailed";
        public static const PREVIEW_STOPPED:String = "previewStopped";

        public function PreviewPluginEvent(type:String, fileWrapper:Object = null, project:AS3ProjectVO = null)
        {
            super(type, false, false);

            _fileWrapper = fileWrapper;
            _project = project;
        }

        private var _fileWrapper:Object;

        public function get fileWrapper():Object
        {
            return _fileWrapper;
        }

        private var _project:AS3ProjectVO;

        public function get project():AS3ProjectVO
        {
            return _project;
        }
    }
}
