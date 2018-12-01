(**
  
  This module contains code to install a splash screen entry into the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.0
  @Date    30 Nov 2018
  
**)
Unit IDEExplorer.SplashScreen;

Interface

  Procedure InstallSplashScreen;

Implementation

Uses
  ToolsAPI,
  SysUtils,
  Forms,
  Windows,
  IDEExplorer.Types,
  IDEExplorer.Functions,
  IDEExplorer.Constants,
  IDEExplorer.ResourceStrings;

(**

  This method installs a splash screen entry into the RAD Studio IDE splash screen.

  @precon  None.
  @postcon A splash screen entry is added and displayed on the IDE splash screen.

**)
Procedure InstallSplashScreen;

Const
  {$IFDEF D2005}
  strSplashScreenIcon = 'IDEExplorerSplashScreenBitMap48x48';
  {$ELSE}
  strSplashScreenIcon = 'IDEExplorerSplashScreenBitMap24x24';
  {$ENDIF}

Var
  VersionInfo : TVersionInfo;
  SSS : IOTASplashScreenServices;
  bmSplashScreen : HBITMAP;

Begin
  If Supports(SplashScreenServices, IOTASplashScreenServices, SSS) Then
    Begin
      BuildNumber(VersionInfo);
      bmSplashScreen := LoadBitmap(hInstance, strSplashScreenIcon);
      SSS.AddPluginBitmap(
        Format(strSplashScreenName, [
          VersionInfo.iMajor,
          VersionInfo.iMinor,
          Copy(strRevision, VersionInfo.iBugFix + 1, 1),
          Application.Title
        ]),
        bmSplashScreen,
        {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
        Format(strSplashScreenBuild, [
          VersionInfo.iMajor, 
          VersionInfo.iMinor, 
          VersionInfo.iBugfix, 
          VersionInfo.iBuild
        ])
      );
    End;
End;

End.
