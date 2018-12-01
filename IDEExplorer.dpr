(**
  
  This module defines a Window DLL project for a RAD Studio IDE plug-in to display inforamtion about the
  IDE forms and components.

  @Author  David Hoyle
  @Version 1.0
  @Date    01 Dec 2018

  @nocheck EmptyBeginEnd
  
**)
Library IDEExplorer;

{$R 'IDEExplorerITHVerInfo.res' 'IDEExplorerITHVerInfo.RC'}
{$R 'SplashScreenIcon.res' 'SplashScreenIcon.RC'}

{$INCLUDE 'Source\CompilerDefinitions.inc'}
{$INCLUDE 'Source\LibrarySuffixes.inc'}

uses
  System.SysUtils,
  System.Classes,
  IDEExplorer.ExplorerForm in 'Source\IDEExplorer.ExplorerForm.pas' {DGHIDEExplorerForm},
  IDEExplorer.Wizard in 'Source\IDEExplorer.Wizard.pas',
  IDEExplorer.OLDRTTIFunctions in 'Source\IDEExplorer.OLDRTTIFunctions.pas',
  IDEExplorer.RTTIFunctions in 'Source\IDEExplorer.RTTIFunctions.pas',
  IDEExplorer.SplashScreen in 'Source\IDEExplorer.SplashScreen.pas',
  IDEExplorer.Functions in 'Source\IDEExplorer.Functions.pas',
  IDEExplorer.Types in 'Source\IDEExplorer.Types.pas',
  IDEExplorer.ResourceStrings in 'Source\IDEExplorer.ResourceStrings.pas',
  IDEExplorer.Constants in 'Source\IDEExplorer.Constants.pas',
  IDEExplorer.AboutBox in 'Source\IDEExplorer.AboutBox.pas';

{$R *.res}


Begin
End.
