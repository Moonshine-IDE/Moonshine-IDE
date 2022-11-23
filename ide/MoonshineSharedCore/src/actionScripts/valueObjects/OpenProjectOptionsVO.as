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
    public class OpenProjectOptionsVO
    {
        // usually in case of single project find it opens to
        // sidebar immediately, however to open the multi-project-selection
        // popup explicitly
        public var needProjectSelection:Boolean;

        // currently logical for multi-project-selection popup where
        // the workspace dropdown/input can be altered by
        // providing a workspace name
        public var needWorkspace:String;

        // in case of opening by workspace change
        // do not require to check multiple-project existence
        // but open by project path that was already opened in sidebar
        public var isLoadProjectAsWorkspaceChanged:Boolean;

        public function OpenProjectOptionsVO()
        {
        }
    }
}
