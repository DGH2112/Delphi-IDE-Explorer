(**

  This module contains a Delphi IDE wizard that displays a tree view of the
  Delphi IDEs published interface.

  @Date    19 Apr 2020
  @Version 2.077
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
  (** This is a Wizard/Menu Wizard to implement a simply menu under the IDEs help. **)
  TDGHIDEExplorer = Class(TNotifierObject, IOTAWizard, IOTAMenuWizard)
  Strict Private
    FAboutBoxIndex : Integer;
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
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  SysUtils,
  Forms,
  IDEExplorer.SplashScreen,
  IDEExplorer.ExplorerForm,
  IDEExplorer.Functions,
  IDEExplorer.Types,
  IDEExplorer.Constants,
  IDEExplorer.ResourceStrings,
  IDEExplorer.AboutBox;

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
  { $IFDEF CODESITE}CodeSite.TraceMethod('InitWizard', tmoTiming);{ $ENDIF}
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
  {$IFDEF CODESITE}CodeSite.TraceMethod('Register', tmoTiming);{$ENDIF}
  RegisterPackageWizard(TDGHIDEExplorer.Create);
End;

{ TDGHIDEExplorer Class Methods }

(**

  This is the constructor method for the TDGHIDEExplorer class.

  @precon  None.
  @postcon None.

**)
Constructor TDGHIDEExplorer.Create;

Begin
  { $IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{ $ENDIF}
  Inherited Create;
  InstallSplashScreen;
  FAboutBoxIndex := AddAboutBoxEntry;
End;

(**

  This is the destructor method for the TDGHIDEExplorer class.

  @precon  None.
  @postcon None.

**)
Destructor TDGHIDEExplorer.Destroy;

Begin
  { $IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{ $ENDIF}
  RemoveAboutBoxEntry(FAboutBoxIndex);
  Inherited Destroy;
End;

(**

  This method creates and displays the IDE Explorer form.

  @precon  None.
  @postcon the IDE Explorer is displayed in Modal form.

**)
Procedure TDGHIDEExplorer.Execute;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Execute', tmoTiming);{$ENDIF}
  TDGHIDEExplorerForm.Execute;
End;

(**

  This is a getter method for the IDString property.

  @precon  None.
  @postcon Returns the ID String for the wizard.

  @return  a String

**)
Function TDGHIDEExplorer.GetIDString : String;

Const
  strDGHIDEExplorer = '.DGH IDE Explorer';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'GetIDString', tmoTiming);{$ENDIF}
  Result := strDGHIDEExplorer;
End;

(**

  This method returns the Menu Text to appear in the Help menu of the IDE.

  @precon  None.
  @postcon Returns the help menu text.

  @return  a String

**)
Function TDGHIDEExplorer.GetMenuText: String;

ResourceString
  strIDEExplorer = 'IDE Explorer';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'GetMenuText', tmoTiming);{$ENDIF}
  Result := strIDEExplorer;
End;

(**

  This is a getter method for the Name property.

  @precon  None.
  @postcon Returns the name of the wizard.

  @return  a String

**)
Function TDGHIDEExplorer.GetName : String;

Const
  strDGHIDEExplorer = 'DGH IDE Explorer';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'GetName', tmoTiming);{$ENDIF}
  Result := strDGHIDEExplorer;
End;

(**

  This is a getter method for the State property.

  @precon  None.
  @postcon Returns the state enabled.

  @return  a TWizardState

**)
Function TDGHIDEExplorer.GetState: TWizardState;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'GetState', tmoTiming);{$ENDIF}
  Result := [wsEnabled];
End;

End.

