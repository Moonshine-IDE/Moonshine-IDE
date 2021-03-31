;NSIS Modern User Interface
;Basic Example Script
;Written by Joost Verburg

;--------------------------------
;Includes

	!include "MUI2.nsh"
	!include "FileFunc.nsh"
	!include "WinMessages.nsh"
	!include "FileAssociation.nsh"

;--------------------------------
;General

	;Name and file
	Name "${INSTALLERNAME}-IDE"
	OutFile "DEPLOY\${INSTALLERNAME}-${VERSION}.exe"

	;Default installation folder
	InstallDir "$PROGRAMFILES64\${INSTALLERNAME}"
	
	;Get installation folder from registry if available
	InstallDirRegKey HKCU "Software\${INSTALLERNAME}" ""

	;Request application privileges for Windows Vista and higher
	RequestExecutionLevel admin
	
;--------------------------------
;Start of running process check

!define APP_NAME find_close_terminate
!define WND_PROCESS_TITLE "Moonshine-IDE"
!define TO_MS 2000
!define SYNC_TERM 0x00100001

LangString termMsg 0 "An instance of ${WND_PROCESS_TITLE} is already running.$\nDo you want to terminate the instance and continue?"
LangString stopMsg 0 "Stopping ${WND_PROCESS_TITLE} Application"

!macro TerminateApp processName
 
    Push $0 ; window handle
    Push $1
    Push $2 ; process handle
    DetailPrint "$(stopMsg)"	
	ExecCmd::exec "%SystemRoot%\System32\tasklist /NH /FI $\"IMAGENAME eq ${processName}$\" | %SystemRoot%\System32\find /I $\"Console$\"" 
    Pop $0 ; The handle for the process
    ExecCmd::wait $0
    StrCmp $0 "0" 0 doneTerminateApp
    System::Call 'user32.dll::GetWindowThreadProcessId(i r0, *i .r1) i .r2'
    System::Call 'kernel32.dll::OpenProcess(i ${SYNC_TERM}, i 0, i r1) i .r2'
    SendMessage $0 ${WM_CLOSE} 0 0 /TIMEOUT=${TO_MS}
    System::Call 'kernel32.dll::WaitForSingleObject(i r2, i ${TO_MS}) i .r1'
    IntCmp $1 0 close
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(termMsg)" /SD IDYES IDYES terminate
    System::Call 'kernel32.dll::CloseHandle(i r2) i .r1'
    Quit
  terminate:
    ExecCmd::exec "%SystemRoot%\System32\taskkill /IM $\"${processName}$\" /F"
    ExecCmd::wait $0
  close:
    System::Call 'kernel32.dll::CloseHandle(i r2) i .r1'
  doneTerminateApp:
    Pop $2
    Pop $1
    Pop $0
 
!macroend

;--------------------------------
;End of running process check
	
;--------------------------------
;Start of StrContains
	
	Var STR_HAYSTACK
	Var STR_NEEDLE
	Var STR_CONTAINS_VAR_1
	Var STR_CONTAINS_VAR_2
	Var STR_CONTAINS_VAR_3
	Var STR_CONTAINS_VAR_4
	Var STR_RETURN_VAR
	 
	Function StrContains
	  Exch $STR_NEEDLE
	  Exch 1
	  Exch $STR_HAYSTACK
	  ; Uncomment to debug
	  ;MessageBox MB_OK 'STR_NEEDLE = $STR_NEEDLE STR_HAYSTACK = $STR_HAYSTACK '
		StrCpy $STR_RETURN_VAR ""
		StrCpy $STR_CONTAINS_VAR_1 -1
		StrLen $STR_CONTAINS_VAR_2 $STR_NEEDLE
		StrLen $STR_CONTAINS_VAR_4 $STR_HAYSTACK
		loop:
		  IntOp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_1 + 1
		  StrCpy $STR_CONTAINS_VAR_3 $STR_HAYSTACK $STR_CONTAINS_VAR_2 $STR_CONTAINS_VAR_1
		  StrCmp $STR_CONTAINS_VAR_3 $STR_NEEDLE found
		  StrCmp $STR_CONTAINS_VAR_1 $STR_CONTAINS_VAR_4 done
		  Goto loop
		found:
		  StrCpy $STR_RETURN_VAR $STR_NEEDLE
		  Goto done
		done:
	   Pop $STR_NEEDLE ;Prevent "invalid opcode" errors and keep the
	   Exch $STR_RETURN_VAR  
	FunctionEnd
	 
	!macro _StrContainsConstructor OUT NEEDLE HAYSTACK
	  Push `${HAYSTACK}`
	  Push `${NEEDLE}`
	  Call StrContains
	  Pop `${OUT}`
	!macroend
	 
	!define StrContains '!insertmacro "_StrContainsConstructor"'
	
;--------------------------------
;End of StrContains
	
Function .onInit
	!insertmacro TerminateApp "${INSTALLERNAME}.exe"
	
	ReadRegStr $R2 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"InstallLocation"
	${StrContains} $0 "(x86)" $R2
	StrCmp $0 "" check_timestamp 0
	MessageBox MB_YESNO|MB_ICONEXCLAMATION \
		"This will install 64-Bit Moonshine-IDE on your system.$\n$\nA 32-Bit version is currently installed. You will need to uninstall the 32-bit version before you can install the new version. \
		Your settings and open projects will still be available in the new version.$\n$\nDo you want to uninstall the old version now?" \
		IDYES run_x86_uninstaller IDNO quit_installation
	check_timestamp:
		ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
			"TimeStamp"
		StrCmp $R0 "" done
		StrCmp $R0 "${TIMESTAMP}" 0 done
		MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION \
			"This version of Moonshine-IDE is already installed. Do you want to run the current installation?$\n$\n \
			Yes - Start Moonshine-IDE now$\n \
			No - Do a fresh install$\n \
			Cancel - Cancel this installation" \
			IDYES run_application IDNO run_uninstaller
			Abort
	run_application:
		ClearErrors
		Exec "$INSTDIR\${INSTALLERNAME}.exe"
		Abort
	run_uninstaller:
		ClearErrors
		;look for the nsis uninstaller as a special case
		ReadRegStr $R1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
			"UninstallString64bit"
		StrCmp $R1 "$\"$INSTDIR\uninstall.exe$\"" 0 +3
			ExecWait '$R1 _?=$INSTDIR'
				Goto +2
				ExecWait '$R1'
	
		IfErrors uninstall_fail uninstall_success
		uninstall_fail:
			Quit
		uninstall_success:
			Delete "$INSTDIR\uninstall.exe"
			RmDir "$INSTDIR"
			Goto done
	run_x86_uninstaller:
		ClearErrors
		;x86 uninstaller path
		ReadRegStr $R3 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
			"UninstallString"
		ExecWait '$R3'
		IfErrors uninstall_fail_x86 uninstall_success_x86
		uninstall_fail_x86:
			Quit
		uninstall_success_x86:
			RmDir "$R2"
			Goto check_timestamp
	quit_installation:
		ClearErrors
		Quit
	done:
FunctionEnd

;--------------------------------
;Interface Settings

	!define MUI_HEADERIMAGE
	;!define MUI_HEADERIMAGE_BITMAP "header.bmp"
	;!define MUI_WELCOMEFINISHPAGE_BITMAP "wizard.bmp"
	!define MUI_FINISHPAGE_RUN "$INSTDIR\${INSTALLERNAME}.exe"
	!define MUI_FINISHPAGE_RUN_TEXT "Run ${INSTALLERNAME}-IDE"
	!define MUI_FINISHPAGE_NOAUTOCLOSE
	;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
	;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
	!define MUI_ABORTWARNING

;--------------------------------
;Pages

	!insertmacro MUI_PAGE_WELCOME
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_PAGE_FINISH
	
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES
	
;--------------------------------
;Languages
 
	!insertmacro MUI_LANGUAGE "English"
	
;--------------------------------
;Installer Sections

Section "Moonshine-IDE" SecMoonshineInstaller

	;copy all files
	SetOutPath "$INSTDIR"
	File /r "DEPLOY\${INSTALLERNAME}EXE\*"
	
	;File-type associations
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".as" "Moonshine.ActionScript.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".css" "Moonshine.CSS.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".txt" "Moonshine.Text.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".mxml" "Moonshine.MXML.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".xml" "Moonshine.XML.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".js" "Moonshine.JavaScript.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".htm" "Moonshine.HTML.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".html" "Moonshine.HTML.File.2"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".awd" "Moonshine.AwayBuilder.File"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".as3proj" "Moonshine.Project.Configuration.File.1"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".veditorproj" "Moonshine.Project.Configuration.File.2"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".javaproj" "Moonshine.Project.Configuration.File.3"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".grailsproj" "Moonshine.Project.Configuration.File.4"
	${registerExtension} "$INSTDIR\${INSTALLERNAME}.exe" ".ondiskproj" "Moonshine.Project.Configuration.File.5"
	
	;Store installation folder
	WriteRegStr HKCU "Software\${INSTALLERNAME}" "" $INSTDIR
	
	;Create uninstaller
	WriteUninstaller "$INSTDIR\uninstall.exe"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"DisplayName" "${INSTALLERNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"Publisher" "Prominic.NET, Inc."
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"URLInfoAbout" "https://moonshine-ide.com"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"DisplayVersion" "${VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"TimeStamp" "${TIMESTAMP}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"HelpLink" "https://moonshine-ide.com/faq/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"DisplayIcon" "$\"$INSTDIR\${INSTALLERNAME}.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"UninstallString64bit" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"NoModify" 0x1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"NoRepair" 0x1
	
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"EstimatedSize" "$0"
	
	;Create Start Menu entry
	CreateShortCut "$SMPROGRAMS\${INSTALLERNAME} (64-bit).lnk" "$INSTDIR\${INSTALLERNAME}.exe"

SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"

	RMDir /r "$INSTDIR\*"
	RMDir "$INSTDIR"
	
	Delete "$SMPROGRAMS\${INSTALLERNAME}.lnk"
	
	DeleteRegKey /ifempty HKCU "Software\${INSTALLERNAME}"
	
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"
SectionEnd