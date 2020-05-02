(**
  
  This module contains interfaces for use throughout the application.

  @Author  David Hoyle
  @Version 1.148
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
