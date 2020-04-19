(**
  
  This module contains simple types for use throughout the plug-in.

  @Author  David Hoyle
  @Version 1.032
  @Date    19 Apr 2020
  
**)
Unit IDEExplorer.Types;

Interface

Uses
  System.Classes;

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

Implementation

End.
