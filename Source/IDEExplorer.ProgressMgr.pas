(**
  
  This module contains a class which implements the IDIEProgressMgr interface for managing the diplsay of
  progress in the aplpication.

  @Author  David Hoyle
  @Version 1.454
  @Date    04 Jun 2020
  
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
Unit IDEExplorer.ProgressMgr;

Interface

Uses
  System.Classes,
  IDEExplorer.Interfaces,
  IDEExplorer.ProgressForm;

Type
  (** This classes implements the IDIEProgressMgr interface for displaying progress. **)
  TDIEProgressMgr = Class(TInterfacedObject, IDIEProgressMgr)
  Strict Private
    FProgressForm : TfrmDIEProgressForm;
  Strict Protected
    Procedure Hide;
    Procedure Initialise(Const iSteps: Integer);
    Procedure Show(Const strInitMsg: String);
    Procedure Update(Const strMsg: String);
  Public
    Constructor Create(Const AOwner : TComponent);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  Forms;

(**

  A constructor for the TDIEProgressMgr class.

  @precon  AOwner must be a valid instance.
  @postcon Creates a progress form to display the progress.

  @param   AOwner as a TComponent as a constant

**)
Constructor TDIEProgressMgr.Create(Const AOwner: TComponent);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{$ENDIF}
  FProgressForm := TfrmDIEProgressForm.Create(AOwner);
End;

(**

  A destructor for the TDIEProgressMgr class.

  @precon  None.
  @postcon Does nothing @note The form created is owned by the explorer form so destroyed with it.

**)
Destructor TDIEProgressMgr.Destroy;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{$ENDIF}
  Inherited Destroy;
End;

(**

  This method hides the progress.

  @precon  None.
  @postcon The progress form is hidden.

**)
Procedure TDIEProgressMgr.Hide;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Hide', tmoTiming);{$ENDIF}
  FProgressForm.Hide;
End;

(**

  This method intialise the progress for the number of steps given.

  @precon  iSteps needs to be 1 or graeter.
  @postcon The progress form is intialised.

  @param   iSteps as an Integer as a constant

**)
Procedure TDIEProgressMgr.Initialise(Const iSteps: Integer);

ResourceString
  strPleaseWait = 'Please wait...';

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Initialise', tmoTiming);{$ENDIF}
  FProgressForm.Caption := strPleaseWait;
  FProgressForm.ProgressBar.Min := 0;
  FProgressForm.ProgressBar.Position := 0;
  FProgressForm.ProgressBar.Max := iSteps;
  Application.ProcessMessages;
End;

(**

  This method shows the progress.

  @precon  None.
  @postcon The progress form is displayed.

  @param   strInitMsg as a String as a constant

**)
Procedure TDIEProgressMgr.Show(Const strInitMsg: String);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Show', tmoTiming);{$ENDIF}
  FProgressForm.Show;
  FProgressForm.Caption := strInitMsg;
  Application.ProcessMessages;
End;

(**

  This method updates the progress.

  @precon  None.
  @postcon Displays the messages and increments the progress position.

  @param   strMsg as a String as a constant

**)
Procedure TDIEProgressMgr.Update(Const strMsg: String);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Update', tmoTiming);{$ENDIF}
  FProgressForm.ProgressBar.Position := FProgressForm.ProgressBar.Position + 1;
  FProgressForm.Caption := strMsg;
  Application.ProcessMessages;
End;

End.


