
!include "EnvVarUpdate.nsh"

; The name of the installer
Name "opensc"

; The file to write
OutFile "${IMAGEROOT}/opensc-${CHOST}-${BUILD_VERSION}-setup.exe"

; The default installation directory
InstallDir $PROGRAMFILES\opensc

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\opensc" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

!define base_dir "${IMAGEROOT}"
!define opensc_files "opensc\*"
!define engine_pkcs11_files "engine_pkcs11\*"
!define openvpn_files "openvpn\*"

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "opensc (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r ${base_dir}\${opensc_files} 
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\opensc "Install_Dir" "$INSTDIR"
  WriteRegStr HKLM SOFTWARE\opensc "ConfigFile" "$INSTDIR\etc\opensc.conf"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\opensc" "DisplayName" "opensc"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\opensc" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\opensc" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\opensc" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  
  ; Add to PATH
  ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\bin"
  
  ; Run opensc-install.bat
  ExecWait '"$INSTDIR\bin\opensc-install.bat"' $0
  DetailPrint "opensc-install returned $0"
  
SectionEnd

Section "engine pkcs11"

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r ${base_dir}\${engine_pkcs11_files} 
  
SectionEnd

Section /o "openvpn"

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File /r ${base_dir}\${openvpn_files} 
  
SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"

  ; Remove from PATH
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\opensc"
  DeleteRegKey HKLM SOFTWARE\opensc

  ; Remove files and uninstaller
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\opensc\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\opensc"
  ; Should be rewrite to remove only installed file...
  RMDir /r "$INSTDIR"

SectionEnd
