(**
  
  This module contains methods to adding and removing the About Box Entry in the IDEs about dialogue.

  @Author  David Hoyle
  @Version 1.095
  @Date    02 May 2020
  
  @license

    IDE Explorer - an Opren Tools API plug-in for RAD Studio which allows you to
    browse the internals of the RAD Studio IDE.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/Delphi-IDE-Explorer)

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
Unit IDEExplorer.AboutBox;

Interface

  Function  AddAboutBoxEntry : Integer;
  Procedure RemoveAboutBoxEntry(Const iIndex : Integer);

Implementation

Uses
  ToolsAPI,
  SysUtils,
  DateUtils,
  Forms,
  Windows,
  IDEExplorer.Types,
  IDEExplorer.Functions,
  IDEExplorer.Constants,
  IDEExplorer.ResourceStrings;

(**

  This method adds an about box entry to the IDEs about dialogue.

  @precon  None.
  @postcon The integer returned is the index of the entry and should be used remove the entry from the
           IDE.

  @return  an Integer

**)
Function  AddAboutBoxEntry : Integer;

Const
  strIDEExplorerSplashScreenBitMap = 'IDEExplorerSplashScreenBitMap48x48';

ResourceString
  strSKUBuild = 'SKU Build %d.%d.%d.%d';
  strExpertsDescription = 'An RAD Studio IDE Expert to allow you to browse the IDE''s published ' +
    'elements.';

Var
  bmAboutBox : HBITMAP;
  VersionInfo : TVersionInfo;
  ABS : IOTAAboutBoxServices;

Begin
  Result := -1;
  bmAboutBox := LoadBitmap(hInstance, strIDEExplorerSplashScreenBitMap);
  BuildNumber(VersionInfo);
  If Supports(BorlandIDEServices, IOTAAboutBoxServices, ABS) Then
    Result := ABS.AddPluginInfo(
      Format(strSplashScreenName, [
        VersionInfo.iMajor, 
        VersionInfo.iMinor,
        Copy(strRevision, VersionInfo.iBugFix + 1, 1),
        Application.Title
      ]),
      strExpertsDescription,
      bmAboutBox,
      {$IFDEF DEBUG} True {$ELSE} False {$ENDIF},
      Format(strSplashScreenBuild, [
        YearOf(Now()),
        VersionInfo.iMajor, 
        VersionInfo.iMinor, 
        VersionInfo.iBugfix, 
        VersionInfo.iBuild
      ]),
      Format(strSKUBuild, [
        VersionInfo.iMajor, 
        VersionInfo.iMinor, 
        VersionInfo.iBugfix, 
        VersionInfo.iBuild
      ])
    );
End;

(**

  This method removed the indexed about box entry from the IDE.

  @precon  None.
  @postcon If the given index is greater than -1 the entry is removed from the IDE.

  @param   iIndex as an Integer as a constant

**)
Procedure RemoveAboutBoxEntry(Const iIndex : Integer);

Var
  ABS : IOTAAboutBoxServices;

Begin
  If Supports(BorlandIDEServices, IOTAAboutBoxServices, ABS) Then
    If iIndex > -1 Then
      ABS.RemovePluginInfo(iIndex);
End;

End.
