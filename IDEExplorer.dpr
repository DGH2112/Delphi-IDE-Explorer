(**
  
  This module defines a Window DLL project for a RAD Studio IDE plug-in to display inforamtion about the
  IDE forms and components.

  @Author  David Hoyle
  @Version 1.011
  @Date    11 Sep 2021

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

  @nocheck EmptyBeginEnd
  
**)
Library IDEExplorer;

{$R 'IDEExplorerITHVerInfo.res' 'IDEExplorerITHVerInfo.RC'}
{$R 'SplashScreenIcon.res' 'SplashScreenIcon.RC'}

{$INCLUDE 'Source\CompilerDefinitions.inc'}
{$INCLUDE 'Source\LibrarySuffixes.inc'}

uses
  SysUtils,
  Classes,
  IDEExplorer.ExplorerForm in 'Source\IDEExplorer.ExplorerForm.pas' {DGHIDEExplorerForm},
  IDEExplorer.Wizard in 'Source\IDEExplorer.Wizard.pas',
  IDEExplorer.OLDRTTIFunctions in 'Source\IDEExplorer.OLDRTTIFunctions.pas',
  IDEExplorer.RTTIFunctions in 'Source\IDEExplorer.RTTIFunctions.pas',
  IDEExplorer.SplashScreen in 'Source\IDEExplorer.SplashScreen.pas',
  IDEExplorer.Functions in 'Source\IDEExplorer.Functions.pas',
  IDEExplorer.Types in 'Source\IDEExplorer.Types.pas',
  IDEExplorer.ResourceStrings in 'Source\IDEExplorer.ResourceStrings.pas',
  IDEExplorer.Constants in 'Source\IDEExplorer.Constants.pas',
  IDEExplorer.AboutBox in 'Source\IDEExplorer.AboutBox.pas',
  IDEExplorer.Interfaces in 'Source\IDEExplorer.Interfaces.pas',
  IDEExplorer.ProgressMgr in 'Source\IDEExplorer.ProgressMgr.pas',
  IDEExplorer.ProgressForm in 'Source\IDEExplorer.ProgressForm.pas' {frmDIEProgressForm};

{$R *.res}


Begin
End.
