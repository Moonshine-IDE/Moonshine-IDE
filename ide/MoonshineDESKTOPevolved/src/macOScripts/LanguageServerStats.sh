#!/bin/bash
################################################################################
## Copyright 2016 Prominic.NET, Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
## http:##www.apache.org#licenses#LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License
##
## Author: Prominic.NET, Inc.
## No warranty of merchantability or fitness of any kind.
## Use this software at your own risk.
################################################################################
##
## Script to display the current running language server processess.
## Includes the corresponding project name (based on directory), process ID,
## and memory/CPU utilization.
## Created to help debug/brainstorm for #994

KEYWORD=language-server

# build a list of processes
LS_PROCESSES=$(ps -e -o pid,ppid,command | grep "$KEYWORD" | grep -v bash | grep -v grep | sed 's/^ *\([0-9][0-9]*\) *\([0-9][0-9]*\) *.*/\1/g')

echo "PROJECT			PID	%MEM	%CPU"
for process in ${LS_PROCESSES[*]}; do 
    TEMP_CWD=$(lsof -a -d cwd -p $process | grep -v COMMAND | sed 's:^.*/\([^/]*$\):\1:g');
    TEMP_STATS=$(ps -o pid,%mem,%cpu -p $process | grep -v PID);
    echo "$TEMP_CWD:  $TEMP_STATS";
done

