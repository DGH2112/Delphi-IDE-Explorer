(**

  This module contains a Delphi IDE wizard that displays a tree view of the
  Delphi IDEs published interface.

  @Date    25 Nov 2018
  @Version 2.0
  @Author  David Hoyle

**)
Unit IDEExplorer.Wizard;

Interface

Uses
  Windows,
  Dialogs,
  Classes,
  ToolsAPI,
  Menus;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** A record to store the version information for the BPL. **)
  TVersionInfo = Record
    iMajor : Integer;
    iMinor : Integer;
    iBugfix : Integer;
    iBuild : Integer;
  End;

  (** This is a Wizard/Menu Wizard to implement a simply menu under the IDEs help. **)
  TDGHIDEExplorer = Class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  Strict Private
    {$IFDEF D2005}
    VersionInfo : TVersionInfo;
    {$IFDEF D2007}
    bmSplashScreen24x24 : HBITMAP;
    {$ENDIF}
    bmSplashScreen48x48 : HBITMAP;
    iAboutPluginIndex : Integer;
    {$ENDIF}
  Strict Protected
  Public
    Constructor Create;
    Destructor Destroy; Override;
    // IOTAWizard
    Procedure Execute;
    Function  GetIDString : String;
    Function  GetName : String;
    Function  GetState : TWizardState;
    // IOTAMenuWizard
    Function  GetMenuText: string;
  End;

  Procedure Register;
  Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices; RegisterProc : TWizardRegisterProc;
    var Terminate: TWizardTerminateProc) : Boolean; StdCall;

Exports
  InitWizard Name WizardEntryPoint;
  
Implementation

Uses
  SysUtils,
  DGHExplFrm,
  Forms;

{$IFDEF D2005}
Const
  (** A const to define the build bugfix letters. **)
  strRevision : String = ' abcdefghijklmnopqrstuvwxyz';

ResourceString
  (** A resource string for to be displayed on the splash screen. **)
  strSplashScreenName = 'IDE Explorer %d.%d%s for %s';
  (** A resource string for the build information on the splash screen **)
  strSplashScreenBuild = 'Freeware by David Hoyle (Build %d.%d.%d.%d)';
{$ENDIF}

(**

  This is a procedure to initialising the wizard interface when loading as a DLL wizard.

  @precon  None.
  @postcon Initialises the wizard.

  @nocheck MissingCONSTInParam
  @nohint  Terminate

  @param   BorlandIDEServices as an IBorlandIDEServices as a constant
  @param   RegisterProc       as a TWizardRegisterProc
  @param   Terminate          as a TWizardTerminateProc as a reference
  @return  a Boolean

**)
Function InitWizard(Const BorlandIDEServices : IBorlandIDEServices;
  RegisterProc : TWizardRegisterProc;
  var Terminate: TWizardTerminateProc) : Boolean; StdCall; //FI:O804

Begin
  Result := Assigned(BorlandIDEServices);
  If Result Then
    RegisterProc(TDGHIDEExplorer.Create);
End;

(**

  This method registers the wizard with the Delphi IDE when it is loaded.

  @precon  None.
  @postcon The wizard is registered with the IDE so that the IDE maintains the live of
           the wizard and destroys it on unloading.

**)
Procedure Register;

Begin
  RegisterPackageWizard(TDGHIDEExplorer.Create);
End;

{$IFDEF D2005}
(**

  This method extracts the build number from the executables resource.

  @precon  None.
  @postcon the build information is placed into the passed version record.

  @param   VersionInfo as a TVersionInfo as a reference

**)
Procedure BuildNumber(Var VersionInfo: TVersionInfo);

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: Array [0 .. MAX_PATH] Of Char;

Begin
  GetModuleFileName(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        With VerValue^ Do
          Begin
            VersionInfo.iMajor := dwFileVersionMS Shr 16;
            VersionInfo.iMinor := dwFileVersionMS And $FFFF;
            VersionInfo.iBugfix := dwFileVersionLS Shr 16;
            VersionInfo.iBuild := dwFileVersionLS And $FFFF;
          End;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End;
End;
{$ENDIF}

{ TDGHIDEExplorer Class Methods }

(**

  This is the constructor method for the TDGHIDEExplorer class.

  @precon  None.
  @postcon None.

**)
Constructor TDGHIDEExplorer.Create;

Begin
  Inherited Create;
  {$IFDEF D2005}
  iAboutPluginIndex := -1;
  BuildNumber(VersionInfo);
  // Add Splash Screen
  {$IFDEF D2007}
  bmSplashScreen24x24 := LoadBitmap(hInstance, 'IDEExplorerSplashScreenBitMap24x24');
  {$ELSE}
  bmSplashScreen48x48 := LoadBitmap(hInstance, 'IDEExplorerSplashScreenBitMap48x48');
  {$ENDIF}
  With VersionInfo Do
    (SplashScreenServices As IOTASplashScreenServices).AddPluginBitmap(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1), Application.Title]),
      {$IFDEF D2007}
      bmSplashScreen24x24,
      {$ELSE}
      bmSplashScreen48x48,
      {$ENDIF}
      False,
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild])
    );
  // Aboutbox plugin
  bmSplashScreen48x48 := LoadBitmap(hInstance, 'IDEExplorerSplashScreenBitMap48x48');
  With VersionInfo Do
    iAboutPluginIndex := (BorlandIDEServices As IOTAAboutBoxServices).AddPluginInfo(
      Format(strSplashScreenName, [iMajor, iMinor, Copy(strRevision, iBugFix + 1, 1), Application.Title]),
      'An RAD Studio IDE Expert to allow you to browse the IDE''s published elements.',
      bmSplashScreen48x48,
      False,
      Format(strSplashScreenBuild, [iMajor, iMinor, iBugfix, iBuild]),
      Format('SKU Build %d.%d.%d.%d', [iMajor, iMinor, iBugfix, iBuild])
    );
  {$ENDIF}
End;

(**

  This is the destructor method for the TDGHIDEExplorer class.

  @precon  None.
  @postcon None.

**)
Destructor TDGHIDEExplorer.Destroy;

Begin
  {$IFDEF D2005}
  // Remove Aboutbox Plugin Interface
  If iAboutPluginIndex > 0 Then
    (BorlandIDEServices As IOTAAboutBoxServices).RemovePluginInfo(iAboutPluginIndex);
  {$ENDIF}
  Inherited Destroy;
End;

(**

  This method creates and displays the IDE Explorer form.

  @precon  None.
  @postcon the IDE Explorer is displayed in Modal form.

**)
Procedure TDGHIDEExplorer.Execute;

Begin
  With TDGHIDEExplorerForm.Create(Nil) Do
    Try
      ShowModal;
    Finally
      Free;
    End;
End;

(**

  This is a getter method for the IDString property.

  @precon  None.
  @postcon Returns the IS String for the wizard.

  @return  a String

**)
Function TDGHIDEExplorer.GetIDString : String;

Begin
  Result := '.Delphi IDE Explorer';
End;

(**

  This method returns the Menu Text to appear in the Help menu of the IDE.

  @precon  None.
  @postcon Returns the help menu text.

  @return  a String

**)
Function TDGHIDEExplorer.GetMenuText: String;

Begin
  Result := 'IDE Explorer';
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
Function TDGHIDEExplorer.GetName : String;

Begin
  Result := 'Delphi IDE Explorer';
End;

(**

  This is a getter method for the State property.

  @precon  None.
  @postcon Returns the state enabled.

  @return  a TWizardState

**)
Function TDGHIDEExplorer.GetState: TWizardState;

Begin
  Result := [wsEnabled];
End;

End.
