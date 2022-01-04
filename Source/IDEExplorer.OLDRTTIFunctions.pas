(**

  This module contains the old style RTTI information.

  @Author  David Hoyle
  @Version 1.721
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
Unit IDEExplorer.OLDRTTIFunctions;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  TypInfo,
  ComCtrls,
  VirtualTrees;

Type
  (** A record to encapsulate the OLD RTTI property methods. **)
  TIDEExplorerOLDRTTI = Record
  Strict Private
    Class Function PropertyValueEnumerate(Const ptrData  :Pointer;
      Const PropListItem : PPropInfo): String; Static;
    Class Function PropertyValueInteger(Const ptrData : Pointer;
      Const PropListItem : PPropInfo): String; Static;
    Class Function PropertyValueMethod(Const ptrData: Pointer;
      Const PropListItem: PPropInfo): String; Static;
    Class Function PropertyValueSet(Const ptrData: Pointer;
      Const PropListItem: PPropInfo): String; Static;
    Class Function  PropertyValue(Const PropListItem : PPropInfo;
      Const ptrData : TObject): String; Static;
  Public
    Class Procedure ProcessOldProperties(Const ptrData : Pointer;
      Const vstOLDProperties : TVirtualStringTree); Static;
  End;

Implementation

Uses
  SysUtils,
  Classes,
  Graphics,
  Controls,
  IDEExplorer.Functions, IDEExplorer.Types;

(**

  This procedure extracts the old published properties of the given object pointer and adds a treeview 
  item for each property.

  @precon  View and ptrData must be valid instances.
  @postcon A treeview item is added to the view for each published property of the object.

  @param   ptrData          as a Pointer as a constant
  @param   vstOLDProperties as a TVirtualStringTree as a constant

**)
Class Procedure TIDEExplorerOLDRTTI.ProcessOldProperties(Const ptrData : Pointer;
  Const vstOLDProperties : TVirtualStringTree);

ResourceString
  strUnknown = '< Unknown >';

Const
  strTColor = 'TColor';
  strTCursor = 'TCursor';

Var
  Node : PVirtualNode;
  NodeData : PDIEOLDPropertyData;
  i: Integer;
  PropList: PPropList;
  iNumOfProps: Integer;

Begin
  vstOLDProperties.BeginUpdate;
  Try
    GetMem(PropList, SizeOf(TPropList));
    Try
      iNumOfProps := GetPropList(TComponent(ptrData).ClassInfo, tkAny, PropList);
      For i := 0 To iNumOfProps - 1 Do
        Begin
          Node := vstOLDProperties.AddChild(Nil);
          NodeData := vstOLDProperties.GetNodeData(Node);
          NodeData.FQualifiedName := String(PropList[i].Name);
          NodeData.FType := String(PropList[i].PropType^.Name);
          NodeData.FImageIndex := Integer(PropList[i].PropType^.Kind);
          NodeData.FKind := GetEnumName(TypeInfo(TTypeKind), Ord(PropList[i].PropType^.Kind));
          If Not FatalValue(UTF8ToString(PropList[i].Name)) Then
            NodeData.FValue := PropertyValue(PropList[i], ptrData)
          Else
            NodeData.FValue := strUnknown;
          If NodeData.FType = strTColor Then
            NodeData.FValue := ColorToString(StrToInt(NodeData.FValue));
          If NodeData.FType = strTCursor Then
            NodeData.FValue := CursorToString(StrToInt(NodeData.FValue));
        End;
    Finally
      FreeMem(PropList, SizeOf(TPropList));
    End;
  Finally
    vstOLDProperties.EndUpdate;
  End;
End;

(**

  This method returns a string representation of the given property`s value.

  @precon  PropListItem, and ptrData must be valid instances.
  @postcon A string representation of the property is returned.

  @param   PropListItem as a PPropInfo as a constant
  @param   ptrData      as a TObject as a constant
  @return  a String

**)
Class Function TIDEExplorerOLDRTTI.PropertyValue(Const PropListItem : PPropInfo;
  Const ptrData : TObject): String;

ResourceString
  strUnknown = '< Unknown >';
  strUnhandled = '[== Unhandled ==]';
  strClass = '< Class >';
  strVariant = '< Variant >';
  strArray = '< Array >';
  strRecord = '< Record >';
  strInteface = '< Interface >';
  strClassRef = '< Class Ref >';
  strPointer = '< Pointer >';
  strProcedure = '< Procedure >';
  strMISSINGPROPERTYHANDLER = '< MISSING PROPERTY HANDLER >';

Begin
  Case PropListItem.PropType^.Kind Of
    tkUnknown:     Result := strUnknown;
    tkInteger:     Result := PropertyValueInteger(ptrData, PropListItem);
    tkChar:        Result := strUnhandled;
    tkEnumeration: Result := PropertyValueEnumerate(ptrData, PropListItem);
    tkFloat:       Result := FloatToStr(GetFloatProp(TObject(ptrData), PropListItem));
    tkString:      Result := GetStrProp(TObject(ptrData), PropListItem);
    tkSet:         Result := PropertyValueSet(ptrData, PropListItem);
    tkClass:       Result := strClass;
    tkMethod:      Result := PropertyValueMethod(ptrData, PropListItem);
    tkWChar:       Result := strUnhandled;
    tkLString:     Result := GetStrProp(TObject(ptrData), PropListItem);
    tkWString:     Result := GetWideStrProp(TObject(ptrData), PropListItem);
    tkVariant:     Result := strVariant;
    tkArray:       Result := strArray;
    tkRecord:      Result := strRecord;
    tkInterface:   Result := strInteface {GetInterfaceProp(TObject(ptrData), PropList[i])};
    tkInt64:       Result := IntToStr(GetInt64Prop(TObject(ptrData), PropListItem));
    tkDynArray:    Result := Format('%x', [GetDynArrayProp(TObject(ptrData), PropListItem)]);
    {$IFDEF RS102}
    tkUString:     Result := GetStrProp(TObject(ptrData), PropListItem);
    {$ELSE}
    tkUString:     Result := GetUnicodeStrProp(TObject(ptrData), PropListItem);
    {$ENDIF RS102}
    tkClassRef:    Result := strClassRef;
    tkPointer:     Result := strPointer;
    tkProcedure:   Result := strProcedure;
  Else
    Result := strMISSINGPROPERTYHANDLER;
  End
End;

(**

  This function returns the enumerate value name for the given pointer item.

  @precon  ptrData and PropListItem must be valid.
  @postcon Returns the name of the enumerate value.

  @param   ptrData      as a Pointer as a constant
  @param   PropListItem as a PPropInfo as a constant
  @return  a String

**)
Class Function TIDEExplorerOLDRTTI.PropertyValueEnumerate(Const ptrData  :Pointer;
  Const PropListItem : PPropInfo): String;

Begin
  Result := GetEnumName(PropListItem.PropType^, GetOrdProp(TObject(ptrData), PropListItem));
End;

(**

  This function returns the value of the integer.

  @precon  ptrData and PropListItem must be valid instances.
  @postcon Returns the value of the integer.

  @param   ptrData      as a Pointer as a constant
  @param   PropListItem as a PPropInfo as a constant
  @return  a String

**)
Class Function TIDEExplorerOLDRTTI.PropertyValueInteger(Const ptrData : Pointer;
  Const PropListItem : PPropInfo): String;

Begin
  Result := IntToStr(GetOrdProp(TObject(ptrData), PropListItem))
End;

(**

  This function returns the memory addresses of the method.

  @precon  ptrData and PropListItem must be valid.
  @postcon Returns the memory addresses of the method.

  @param   ptrData      as a Pointer as a constant
  @param   PropListItem as a PPropInfo as a constant
  @return  a String

**)
Class Function TIDEExplorerOLDRTTI.PropertyValueMethod(Const ptrData: Pointer;
  Const PropListItem: PPropInfo): String;

ResourceString
  strUnassigned = '(Unassigned)';

Const
  iDWordWidth = 8;

Var
  Method: TMethod;

Begin
  Method := GetMethodProp(TObject(ptrData), PropListItem);
  Result := '$' + IntToHex(Integer(Method.Data), iDWordWidth) + '::$' +
    IntToHex(Integer(Method.Code), iDWordWidth);
  If Result = '$00000000::$00000000' Then
    Result := strUnassigned;
End;

(**

  This function returns a text representation of the values that are contained in the set.

  @precon  ptrData and PropListItem must be valid instances.
  @postcon Returns a text representation of the values that are contained in the set.

  @param   ptrData      as a Pointer as a constant
  @param   PropListItem as a PPropInfo as a constant
  @return  a String

**)
Class Function TIDEExplorerOLDRTTI.PropertyValueSet(Const ptrData: Pointer;
  Const PropListItem: PPropInfo): String;

Var
  S: TIntegerSet;
  TypeInfo: PTypeInfo;
  j: Integer;

Begin
  TypeInfo := GetTypeData(PropListItem.PropType^)^.CompType^;
  Integer(S) := GetOrdProp(TObject(ptrData), PropListItem);
  Result := '[';
  For j := 0 To SizeOf(Integer) * 8 - 1 Do
    If j In S Then
      Begin
        If Length(Result) <> 1 Then
          Result := Result + ', ';
        Result := Result + GetEnumName(TypeInfo, j);
      End;
  Result := Result + ']';
End;

End.
