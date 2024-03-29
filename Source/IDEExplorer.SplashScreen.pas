(**
  
  This module contains code to install a splash screen entry into the RAD Studio IDE.

  @Author  David Hoyle
  @Version 1.203
  @Date    04 Jan 2022
  
  @license

    IDE Explorer - an Open Tools API plug-in for RAD Studio which allows you to
    browse the internals of the RAD Studio IDE.
    
    Copyright (C) 2020  David Hoyle (https://github.com/DGH2112/Delphi-IDE-Explorer)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit IDEExplorer.SplashScreen;

Interface

  Procedure InstallSplashScreen;

Implementation

{$INCLUDE CompilerDefinitions.inc}

Uses
  ToolsAPI,
  SysUtils,
  DateUtils,
  Forms,
  {$IFDEF RS110}
  Graphics,
  {$ELSE}
  Windows,
  {$ENDIF RS110}
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
  VerInfo : TVersionInfo;
  SSS : IOTASplashScreenServices;
  {$IFDEF RS110}
  SplashScreenBitMap : TBitMap;
  {$ELSE}
  bmSplashScreen : HBITMAP;
  {$ENDIF}

Begin
  If Supports(SplashScreenServices, IOTASplashScreenServices, SSS) Then
    Begin
      BuildNumber(VerInfo);
      {$IFDEF RS110}
      SplashScreenBitMap := TBitMap.Create;
      Try
        SplashScreenBitMap.LoadFromResourceName(hINstance, strSplashScreenIcon);
        SSS.AddPluginBitmap(
          Format(strSplashScreenName, [VerInfo.iMajor, VerInfo.iMinor, Copy(strRevision, VerInfo.iBugFix + 1, 1), Application.Title]),
          [SplashScreenBitMap],
          {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
          Format(strSplashScreenBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild])
        );
      Finally
        SplashScreenBitMap.Free;
      End;
      {$ELSE}
      bmSplashScreen := LoadBitmap(hInstance, strSplashScreenIcon);
      SSS.AddPluginBitmap(
        Format(strSplashScreenName, [VerInfo.iMajor, VerInfo.iMinor, Copy(strRevision, VerInfo.iBugFix + 1, 1), Application.Title]),
        bmSplashScreen,
        {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
        Format(strSplashScreenBuild, [VerInfo.iMajor, VerInfo.iMinor, VerInfo.iBugfix, VerInfo.iBuild])
      );
      {$ENDIF RS110}
    End;
End;

End.
