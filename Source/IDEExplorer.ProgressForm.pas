(**
  
  This module contains a class which represents a progress form on the screen.

  @Author  David Hoyle
  @Version 1.166
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
  {$IFDEF DXE104}
  ITS : IOTAIDEThemingServices;
  {$ELSE}
  ITS : IOTAIDEThemingServices250;
  {$ENDIF DXE104}
{$ENDIF DXE102}
  
Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'FormCreate', tmoTiming);{$ENDIF}
  {$IFDEF DXE102}
  {$IFDEF DXE104}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices, ITS) Then
  {$ELSE}
  If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
  {$ENDIF DXE104}
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
