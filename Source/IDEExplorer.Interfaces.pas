(**
  
  This module contains interfaces for use throughout the application.

  @Author  David Hoyle
  @Version 1.057
  @Date    19 Apr 2020
  
**)
Unit IDEExplorer.Interfaces;

Interface

Type
  (** This interface defines a progress manager for displaying and updated programme on the screen. **)
  IDIEProgressMgr = Interface
  ['{912F0096-D722-4F5A-ACB0-89A84C54AFE3}']
    Procedure Initialise(Const iSteps : Integer);
    Procedure Show(Const strInitMsg : String);
    Procedure Update(Const strMsg : String);
    Procedure Hide();
  End;

Implementation

End.
