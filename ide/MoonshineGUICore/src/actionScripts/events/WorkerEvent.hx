////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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

package actionScripts.events;

class WorkerEvent {
	public static final SEARCH_IN_PROJECTS:String = "SEARCH_IN_PROJECTS";
	public static final TOTAL_FILE_COUNT:String = "TOTAL_FILE_COUNT";
	public static final TOTAL_FOUND_COUNT:String = "TOTAL_FOUND_COUNT";
	public static final FILE_PROCESSED_COUNT:String = "FILE_PROCESSED_COUNT";
	public static final FILTERED_FILE_COLLECTION:String = "FILTERED_FILE_COLLECTION";
	public static final PROCESS_ENDS:String = "PROCESS_ENDS";
	public static final REPLACE_FILE_WITH_VALUE:String = "REPLACE_FILE_WITH_VALUE";
	public static final GET_FILE_LIST:String = "GET_FILE_LIST";
	public static final SET_FILE_LIST:String = "SET_FILE_LIST";
	public static final SET_IS_WINDOWS:String = "SET_IS_WINDOWS";
	public static final RUN_LIST_OF_NATIVEPROCESS:String = "RUN_LIST_OF_NATIVEPROCESS";
	public static final RUN_LIST_OF_NATIVEPROCESS_ENDED:String = "RUN_LIST_OF_NATIVEPROCESS_ENDED";
	public static final RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:String = "RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK";
	public static final RUN_NATIVEPROCESS_OUTPUT:String = "RUN_NATIVEPROCESS_OUTPUT";
	public static final CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:String = "CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT";
	public static final SEARCH_PROJECTS_IN_DIRECTORIES:String = "SEARCH_PROJECTS_IN_DIRECTORIES";
	public static final FOUND_PROJECTS_IN_DIRECTORIES:String = "FOUND_PROJECTS_IN_DIRECTORIES";
	public static final PROCESS_STDINPUT_WRITEUTF:String = "PROCESS_STDINPUT_WRITEUTF"; // can be use to write to stdInput for an already running process
}