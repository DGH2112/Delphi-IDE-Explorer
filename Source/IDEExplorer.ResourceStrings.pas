(**
  
  This module contains resource strings for use throughout the plug-in.

  @Author  David Hoyle
  @Version 1.117
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
Unit IDEExplorer.ResourceStrings;

Interface

ResourceString
  (** A resource string for to be displayed on the splash screen. **)
  strSplashScreenName = 'IDE Explorer %d.%d%s for %s';
  {$IFDEF DEBUG}
  (** A resource string for the build information on the splash screen **)
  strSplashScreenBuild = 'David Hoyle (c) %d License GNU GPL3 (DEBUG Build %d.%d.%d.%d)';
  {$ELSE}
  (** A resource string for the build information on the splash screen **)
  strSplashScreenBuild = 'David Hoyle (c) %d License GNU GPL3 (Build %d.%d.%d.%d)';
  {$ENDIF DEBUG}

Implementation

End.
