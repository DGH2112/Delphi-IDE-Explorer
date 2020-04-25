(**
  
  This module contains simple types for use throughout the plug-in.

  @Author  David Hoyle
  @Version 1.201
  @Date    25 Apr 2020
  
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

Implementation

End.
