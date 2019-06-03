@echo off

rem
rem  ADOBE CONFIDENTIAL
rem
rem  Copyright 2004-2012 Adobe Systems Incorporated
rem  All Rights Reserved.
rem
rem  NOTICE: All information contained herein is, and remains
rem  the property of Adobe Systems Incorporated and its suppliers,
rem  if any. The intellectual and technical concepts contained
rem  herein are proprietary to Adobe Systems Incorporated and its
rem  suppliers and are protected by trade secret or copyright law.
rem  Dissemination of this information or reproduction of this material
rem  is strictly forbidden unless prior written permission is obtained
rem  from Adobe Systems Incorporated.
rem

rem
rem mxmlc.bat script to launch mxmlc-cli.jar in Windows Command Prompt.
rem On OSX, Unix, or Cygwin, use the mxmlc shell script instead.
rem

setlocal

if "x%AIR_SDK_HOME%"=="x"  (set "AIR_SDK_HOME=%~dp0..") else echo Using AIR SDK: %AIR_SDK_HOME%

@java -Dsun.io.useCanonCaches=false -Xms32m -Xmx512m -Dflexlib="%AIR_SDK_HOME%\frameworks" -jar "%AIR_SDK_HOME%\lib\mxmlc-cli.jar" %*


