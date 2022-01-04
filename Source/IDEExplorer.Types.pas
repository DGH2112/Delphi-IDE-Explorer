(**
  
  This module contains simple types for use throughout the plug-in.

  @Author  David Hoyle
  @Version 1.430
  @Date    04 Jan 2022
  
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
Unit IDEExplorer.Types;

Interface

Uses
  System.Classes,
  System.TypInfo;

Type
  (** A record to store the version information for the BPL. **)
  TVersionInfo = Record
    iMajor: Integer;
    iMinor: Integer;
    iBugfix: Integer;
    iBuild: Integer;
  End;

  (** A record to describe the data in the Explorer treeview. **)
  TDIEObjectData = Record
    FText       : String;
    FObject     : TObject;
    FImageIndex : Integer;
  End;
  (** A pointer to the above structure. **)
  PDIEObjectData = ^TDIEObjectData;

  (** A record to describe the data in the Fields treeview. **)
  TDIEFieldData = Record
    FVisibility      : String;
    FVisibilityIndex : Integer;
    FQualifiedName   : String;
    FType            : String;
    FOffset          : String;
    FKind            : String;
    FImageIndex      : Integer;
    FSize            : String;
    FValue           : String;
    FObject          : TObject;
  End;
  (** A pointer to the above structure. **)
  PDIEFieldData = ^TDIEFieldData;

  (** A record to describe the data in the Methods treeview. **)
  TDIEMethodData = Record
    FVisibility      : String;
    FVisibilityIndex : Integer;
    FQualifiedName   : String;
    FType            : String;
    FImageIndex      : Integer;
    FSignature       : String;
  End;
  (** A pointer to the above structure. **)
  PDIEMethodData = ^TDIEMethodData;

  (** A record to describe the data in the Property treeview. **)
  TDIEPropertyData = Record
    FVisibility      : String;
    FVisibilityIndex : Integer;
    FQualifiedName   : String;
    FType            : String;
    FAccess          : String;
    FKind            : String;
    FImageIndex      : Integer;
    FSize            : String;
    FValue           : String;
  End;
  (** A pointer to the above structure. **)
  PDIEPropertyData = ^TDIEPropertyData;

  (** A record to describe the data in the Property treeview. **)
  TDIEHierarchyData = Record
    FQualifiedName   : String;
    FImageIndex      : Integer;
  End;
  (** A pointer to the above structure. **)
  PDIEHierarchyData = ^TDIEHierarchyData;

  (** A record to describe the data in the Property treeview. **)
  TDIEOLDPropertyData = Record
    FQualifiedName   : String;
    FType            : String;
    FKind            : String;
    FImageIndex      : Integer;
    FValue           : String;
  End;
  (** A pointer to the above structure. **)
  PDIEOLDPropertyData = ^TDIEOLDPropertyData;

Implementation

End.
