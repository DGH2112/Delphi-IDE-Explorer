(**

  This module contains the old style RTTI information.

  @Author  David Hoyle
  @Version 1.588
  @Date    26 Apr 2020

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

  This procedure exrtacts the old published properties of the given object pointer and adds a treeview 
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
  iPropertyValueIndex = 2;

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

Class Function TIDEExplorerOLDRTTI.PropertyValue(Const PropListItem : PPropInfo;
  Const ptrData : TObject): String;

ResourceString
  strUnknown = '< Unknown >';
  strUnhandled = '[== Unhandled ==]';
  strClass = '< Class >';
  strVariant = '< Variant >';
  strArray = '< Array >';
  strRecord = '< Record >';
  strInteface = '< Inteface >';
  strClassRef = '< ClassRef >';
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
    {$IFDEF DXE102}
    tkUString:     Result := GetStrProp(TObject(ptrData), PropListItem);
    {$ELSE}
    tkUString:     Result := GetUnicodeStrProp(TObject(ptrData), PropListItem);
    {$ENDIF}
    tkClassRef:    Result := strClassRef;
    tkPointer:     Result := strPointer;
    tkProcedure:   Result := strProcedure;
  Else
    Result := strMISSINGPROPERTYHANDLER;
  End
End;

(**

  This function returns the enumerate valeu name for the given pointer item.

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

  This function returns the memoet addresses of the method.

  @precon  ptrData and PropListItem must be valid.
  @postcon Returns the memoet addresses of the method.

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

  This function returns a text represetnation of the values that are contained in the set.

  @precon  ptrData and PropListItem must be valid instances.
  @postcon Returns a text represetnation of the values that are contained in the set.

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
