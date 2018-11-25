(**
  
  This module contains methods to adding and removing the About Box Entry in the IDEs about dialogue.

  @Author  David Hoyle
  @Version 1.0
  @Date    25 Nov 2018
  
**)
Unit IDEExplorer.AboutBox;

Interface

  Function  AddAboutBoxEntry : Integer;
  Procedure RemoveAboutBoxEntry(Const iIndex : Integer);

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
      False,
      Format(strSplashScreenBuild, [
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
