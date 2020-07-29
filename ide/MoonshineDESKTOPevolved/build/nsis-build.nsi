;NSIS Modern User Interface
;Basic Example Script
;Written by Joost Verburg

;--------------------------------
;Includes

	!include "MUI2.nsh"
	!include "FileFunc.nsh"

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
	ReadRegStr $R2 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"InstallLocation"
	${StrContains} $0 "(x86)" $R2
	StrCmp $0 "" +2 0
	MessageBox MB_YESNO|MB_ICONEXCLAMATION \
		"This will install Moonshine 64-Bit in your system.$\n$\nA 32-Bit version found already installed. Do you want to uninstall the 32-Bit version before proceed?$\n$\n \
		YES - to uninstall 32-Bit version.$\n \
		NO - to keep 32-Bit version." \
		IDYES run_x86_uninstaller IDNO +1
	ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}" \
		"TimeStamp"
	StrCmp $R0 "" done
	StrCmp $R0 "${TIMESTAMP}" 0 done
	MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION \
		"A same version of Moonshine-IDE found already installed. Do you want to run the installed version?$\n$\n \
		YES - to run the previous version.$\n \
		NO - to uninstall the previous version and install again.$\n \
		Cancel - to cancel this installation." \
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
			"UninstallString"
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
	CreateShortCut "$SMPROGRAMS\${INSTALLERNAME}.lnk" "$INSTDIR\${INSTALLERNAME}.exe"

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