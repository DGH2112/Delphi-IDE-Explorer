(**
  
  This module contains a class which represents a progress form on the screen.

  @Author  David Hoyle
  @Version 1.075
  @Date    19 Apr 2020
  
**)
Unit IDEExplorer.ProgressForm;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls;

Type
  (** A form for displaying progress of long operations. **)
  TfrmDIEProgressForm = Class(TForm)
    ProgressBar: TProgressBar;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  Strict Private
  Strict Protected
  Public
  End;

Implementation

{$R *.dfm}

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  ToolsAPI;

(**

  This is an OnFormCreate Event Handler for the TfrmDIEProgressForm class.

  @precon  None.
  @postcon In 10.2 and above, themes the form int he IDE.

  @param   Sender as a TObject

**)
Procedure TfrmDIEProgressForm.FormCreate(Sender: TObject);

{$IFDEF DXE102}
Var
  ITS : IOTAIDEThemingServices250;
{$ENDIF DXE102}
  
Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'FormCreate', tmoTiming);{$ENDIF}
{$IFDEF DXE102}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
    If ITS.IDEThemingEnabled Then
      Begin
        ITS.RegisterFormClass(TfrmDIEProgressForm);
        ITS.ApplyTheme(Self);
      End;
{$ENDIF DXE102}
End;

(**

  This is an OnFormDestroy Event Handler for the TfrmDIEProgressForm class.

  @precon  None.
  @postcon Does nothing except used for CodeSite tracing.

  @nocheck EmptyMethod

  @param   Sender as a TObject

**)
Procedure TfrmDIEProgressForm.FormDestroy(Sender: TObject);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'FormDestroy', tmoTiming); {$ENDIF}
End;

End.
