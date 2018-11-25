(**
  
  This module defines a Window DLL project for a RAD Studio IDE plug-in to display inforamtion about the
  IDE forms and components.

  @Author  David Hoyle
  @Version 1.0
  @Date    25 Nov 2018

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
  DGHExplFrm in 'Source\DGHExplFrm.pas' {DGHIDEExplorerForm},
  DGHIDEExplorer in 'Source\DGHIDEExplorer.pas',
  DGHOLDRTTIFunctions in 'Source\DGHOLDRTTIFunctions.pas',
  DGHRTTIFunctions in 'Source\DGHRTTIFunctions.pas';

{$R *.res}


Begin
End.
