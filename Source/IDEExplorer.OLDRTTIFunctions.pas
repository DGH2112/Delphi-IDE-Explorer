(**

  This module contains the old style RTTI information.

  @Author  David Hoyle
  @Version 1.0
  @Date    01 Dec 2018

**)
Unit IDEExplorer.OLDRTTIFunctions;

Interface

{$INCLUDE CompilerDefinitions.inc}

Uses
  TypInfo,
  ComCtrls;

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
  Public
    Class Procedure ProcessOldProperties(Const View : TListView; Const ptrData : Pointer); Static;
  End;

Implementation

Uses
  SysUtils,
  Classes,
  Graphics,
  Controls,
  IDEExplorer.Functions;

(**

  This procedure exrtacts the old published properties of the given object pointer and adds a list view 
  item for each property.

  @precon  View and ptrData must be valid instances.
  @postcon A list view item is added to the view for eac npublished property of the object.

  @nometric LongMethod

  @param   View    as a TListView as a constant
  @param   ptrData as a Pointer as a constant

**)
Class Procedure TIDEExplorerOLDRTTI.ProcessOldProperties(Const View : TListView;
  Const ptrData : Pointer);

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

Const
  strTColor = 'TColor';
  strTCursor = 'TCursor';
  iPropertyValueIndex = 2;

Var
  lvItem : TListItem;
  i: Integer;
  PropList: PPropList;
  iNumOfProps: Integer;

Begin
  View.Items.BeginUpdate;
  Try
    View.Items.Clear;
    GetMem(PropList, SizeOf(TPropList));
    Try
      iNumOfProps := GetPropList(TComponent(ptrData).ClassInfo, tkAny, PropList);
      For i := 0 To iNumOfProps - 1 Do
        Begin
          lvItem := View.Items.Add;
          lvItem.Caption := String(PropList[i].Name);
          lvItem.SubItems.Add(String(PropList[i].PropType^.Name));
          lvItem.ImageIndex := Integer(PropList[i].PropType^.Kind);
          lvItem.SubItems.Add(GetEnumName(TypeInfo(TTypeKind),
            Ord(PropList[i].PropType^.Kind)));
          If Not FatalValue(UTF8ToString(PropList[i].Name)) Then
            Case PropList[i].PropType^.Kind Of
              tkUnknown:     lvItem.SubItems.Add(strUnknown);
              tkInteger:     lvItem.SubItems.Add(PropertyValueInteger(ptrData, PropList[i]));
              tkChar:        lvItem.SubItems.Add(strUnhandled);
              tkEnumeration: lvItem.SubItems.Add(PropertyValueEnumerate(ptrData, PropList[i]));
              tkFloat:       lvItem.SubItems.Add(FloatToStr(GetFloatProp(TObject(ptrData), PropList[i])));
              tkString:      lvItem.SubItems.Add(GetStrProp(TObject(ptrData), PropList[i]));
              tkSet:         lvItem.SubItems.Add(PropertyValueSet(ptrData, PropList[i]));
              tkClass:       lvItem.SubItems.Add(strClass);
              tkMethod:      lvItem.SubItems.Add(PropertyValueMethod(ptrData, PropList[i]));
              tkWChar:       lvItem.SubItems.Add(strUnhandled);
              tkLString:     lvItem.SubItems.Add(GetStrProp(TObject(ptrData), PropList[i]));
              tkWString:     lvItem.SubItems.Add(GetWideStrProp(TObject(ptrData), PropList[i]));
              tkVariant:     lvItem.SubItems.Add(strVariant);
              tkArray:       lvItem.SubItems.Add(strArray);
              tkRecord:      lvItem.SubItems.Add(strRecord);
              tkInterface:   lvItem.SubItems.Add(strInteface {GetInterfaceProp(TObject(ptrData), PropList[i])});
              tkInt64:       lvItem.SubItems.Add(IntToStr(GetInt64Prop(TObject(ptrData), PropList[i])));
              tkDynArray:    lvItem.SubItems.Add(Format('%x', [GetDynArrayProp(TObject(ptrData), PropList[i])]));
              {$IFDEF DXE102}
              tkUString:     lvItem.SubItems.Add(GetStrProp(TObject(ptrData), PropList[i]));
              {$ELSE}
              tkUString:     lvItem.SubItems.Add(GetUnicodeStrProp(TObject(ptrData), PropList[i]));
              {$ENDIF}
              tkClassRef:    lvItem.SubItems.Add(strClassRef);
              tkPointer:     lvItem.SubItems.Add(strPointer);
              tkProcedure:   lvItem.SubItems.Add(strProcedure);
            Else
              lvItem.SubItems.Add(strMISSINGPROPERTYHANDLER);
            End
          Else
            lvItem.SubItems.Add(strUnknown);
          If lvItem.SubItems[0] = strTColor Then
            lvItem.SubItems[iPropertyValueIndex] :=
              ColorToString(StrToInt(lvItem.SubItems[iPropertyValueIndex]));
          If lvItem.SubItems[0] = strTCursor Then
            lvItem.SubItems[iPropertyValueIndex] :=
              CursorToString(StrToInt(lvItem.SubItems[iPropertyValueIndex]));
        End;
    Finally
      FreeMem(PropList, SizeOf(TPropList));
    End;
  Finally
    View.Items.EndUpdate;
  End;
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
