(**

  This module contains the new RTTI code to extract information for fields, methods,
  properties and events for various objects pass to the single routine below.

  @Author  David Hoyle
  @Version 2.0
  @Date    01 Dec 2018

**)
Unit IDEExplorer.RTTIFunctions;

Interface

Uses
  RTTI,
  ComCtrls,
  Classes;

Type
  (** A record to encapsulate the new RTTi methods. **)
  TIDEExplorerNEWRTTI = Record
  Strict Private
    Class Procedure ProcessRTTICoreProperty(Const C : TObject; Const P : TRTTIProperty;
      Const View : TListView); Static;
    Class Procedure ProcessRTTIEvents(Const C : TObject; Const Ctx : TRTTIContext; 
      Const View : TListView); Static;
    Class Procedure ProcessRTTIFields(Const C : TObject; Const Ctx : TRTTIContext;
      Const View : TListView); Static;
    Class Procedure ProcessRTTIMethods(Const C : TObject; Const Ctx : TRTTIContext;
      Const View : TListView); Static;
    Class Procedure ProcessRTTIProperties(Const C : TObject; Const Ctx : TRTTIContext;
      Const View : TListView); Static;
    Class Procedure ProcessValue(Const Item : TListItem; Const Value : TValue;
      Const strType : String); Static;
    Class Function ValueToString(Const Value : TValue) : String; Static;
    Class Procedure ProcessCoreClass(Const tvTree : TTreeView; Const N : TTreeNode;
  Const V : TValue); Static;
  Public
    Class Procedure ProcessObject(Const C : TObject; Const FieldView, MethodView, PropertyView,
    EventView : TListView); Static;
    Class Procedure ProcessClass(Const tvTree : TTreeView; Const ParentNode : TTreeNode;
      Const C : TObject); Static;
  End; 

Var
  (** This class is used to store the addresses of all objects found so that we do not
      iterate though loops in the IDE when getting classes. **)
  FoundClasses : TList;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  TypInfo,
  Variants,
  Graphics,
  Controls,
  Windows,
  IDEExplorer.Functions;

ResourceString
  (** A resource string for RTTI Exceptions. **)
  strOops = '(%s): %s';

Const
  (** This is a constant array of string to describe the different visibility aspects
      of class members: private, protected, public and published. **)
  strVisibility : Array[Low(TMemberVisibility)..High(TMemberVisibility)] Of String = (
    'Private', 'Protected', 'Public', 'Published');

(**

  This procedure is design to recursively iterate through the classes and sub classes of a given object 
  and add them to the tree view.

  @precon  tvTree, ParentNode and C must be valid instances.
  @postcon Iterates through the classes subclasses adding them to the tree and then asking those classes
           for their sub-classes.

  @BUG     Using this code on the IDE (RAD Studio 10 Seattle) causes catastrophic failures: It is 
           assumed that when TValue extracts the value of an item it inadvertantly changes some of 
           those objects which cause various AV and a divide by zero error. DO NOT IMPLEMENT THIS 
           UNTIL THE REASONS FOR THE FAILURES ARE UNDERSTOOD OTHERWISE YOU WILL CRASH YOUR IDE.

  @param   tvTree     as a TTreeView as a constant
  @param   ParentNode as a TTreeNode as a constant
  @param   C          as a TObject as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessClass(Const tvTree : TTreeView; Const ParentNode : TTreeNode;
  Const C : TObject);

Var
  Ctx : TRttiContext;
  T   : TRttiType;
  F   : TRttiField;
  P   : TRttiProperty;
  V   : TValue;
  N   : TTreeNode;

Begin
  Exit;
  FoundClasses.Add(C);
  Ctx := TRttiContext.Create;
  Try
    T := Ctx.GetType(C.ClassType);
    For F In T.GetFields Do
      Begin
        OutputDebugString(PChar(F.ToString));
        If F.FieldType.TypeKind = tkClass Then
          Begin
            V := F.GetValue(C);
            N := tvTree.Items.AddChildObject(ParentNode, F.Parent.Name + '.' + F.Name + ' : ' +
              F.FieldType.ToString + ' ' + ValueToString(V), V.AsObject);
            ProcessCoreClass(tvTree, N, V);
          End;
      End;
    For P In T.GetProperties Do
      If P.PropertyType.TypeKind = tkClass Then
        Begin
          V := P.GetValue(C);
          N := tvTree.Items.AddChildObject(ParentNode, P.Parent.Name + '.' + P.Name + ' : ' +
            P.PropertyType.ToString + ' ' + ValueToString(V), V.AsObject);
          ProcessCoreClass(tvTree, N, V);
        End;
  Finally
    Ctx.Free;
  End;
End;

(**

  This method processes the Value of the class item and if found to be annother class, recursively
  processes the class.

  @precon  tvTree and N must be valid instances.
  @postcon Processes the Value of the class item and if found to be annother class, recursively
           processes the class.

  @param   tvTree as a TTreeView as a constant
  @param   N      as a TTreeNode as a constant
  @param   V      as a TValue as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessCoreClass(Const tvTree : TTreeView; Const N : TTreeNode;
  Const V : TValue);

Var
  iIndex: Integer;

Begin
  If Not V.IsEmpty Then
    Begin
      iIndex := FoundClasses.IndexOf(V.AsObject);
      If iIndex = -1 Then
        ProcessClass(tvTree, N, V.AsObject);
    End;
End;

(**

  This procedure processes the fields, methods, properties adn events for the given object.

  @precon  C, FieldView, MethodView, PropertyView and EventView must be valid instances.
  @postcon The fields, methods, properties and events of the object are output.

  @param   C            as a TObject as a constant
  @param   FieldView    as a TListView as a constant
  @param   MethodView   as a TListView as a constant
  @param   PropertyView as a TListView as a constant
  @param   EventView    as a TListView as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessObject(Const C : TObject; Const FieldView, MethodView,
  PropertyView, EventView : TListView);

Var
  Ctx  : TRTTIContext;

Begin
  Ctx := TRttiContext.Create;
  Try
    ProcessRTTIFields(C, Ctx, FieldView);
    ProcessRTTIMethods(C, Ctx, MethodView);
    ProcessRTTIProperties(C, Ctx, PropertyView);
    ProcessRTTIEvents(C, Ctx, EventView);
  Finally
    Ctx.Free;
  End;
End;

(**

  This procedure is called for properties and event as the output is the same they are just filtered 
  differently. This outputs a list view item for the given property/event in the object with the 
  following information: Scope; Fully Qualified Name; Property Type; Access; Value TypeKind; DataSize; 
  Value.

  @precon  C, P and View must be a valid instances.
  @postcon A list view item is create the property or event.

  @param   C    as a TObject as a constant
  @param   P    as a TRTTIProperty as a constant
  @param   View as a TListView as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTICoreProperty(Const C : TObject; Const P : TRTTIProperty;
  Const View : TListView);

  (**

    This procedure determines the acecss type for the property and outputs that to the listview.

    @precon  Item must be a valid instance.
    @postcon The properties access type is output.

    @param   Item as a TListItem as a constant

  **)
  Procedure PropertyAccess(Const Item : TListItem);

  ResourceString
    strReadWrite = 'Read/Write';
    strReadonly = 'Readonly';
    strWriteonly = 'Writeonly';
    strUnknown = '<Unknown>';

  Begin
    If P.IsReadAble And P.IsWritable Then
      Item.SubItems.Add(strReadWrite)
    Else If P.IsReadAble And Not P.IsWritable Then
      Item.SubItems.Add(strReadonly)
    Else If Not P.IsReadAble And P.IsWritable Then
      Item.SubItems.Add(strWriteonly)
    Else
      Item.SubItems.Add(strUnknown);
  End;

Const
  iNoOfFields = 8;
  
Var
  V    : TValue;
  Item : TListItem;

Begin
  Item := View.Items.Add;
  Item.Caption := strVisibility[P.Visibility];
  Item.StateIndex := Integer(P.Visibility);
  Item.SubItems.Add(P.Parent.Name + '.' + P.Name);
  If Assigned(P.PropertyType) Then
    Begin
      Item.SubItems.Add(P.PropertyType.ToString);
      PropertyAccess(Item);
      Item.SubItems.Add(GetEnumName(TypeInfo(TTypeKind), Ord(P.PropertyType.TypeKind)));
      Item.ImageIndex := Integer(P.PropertyType.TypeKind);
      Item.SubItems.Add(Format('%d ', [P.PropertyType.TypeSize]));
    End;
  Try
    If Not FatalValue(P.Name) And P.IsReadable Then
      Begin
        V := P.GetValue(C);
        If P.IsReadable Then
          ProcessValue(Item, V, P.PropertyType.ToString);
      End;
  Except
    On E : EInsufficientRtti Do
      Begin
        While Item.SubItems.Count < iNoOfFields Do
          Item.SubItems.Add('');
        Item.SubItems.Add(Format(strOops, [E.ClassName, E.Message]));
      End;
  End;
End;

(**

  This procedure iterates through the properties of the object and creates a list view item for each 
  property starting with "On" (i.e. an event).

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is created for each event.

  @param   C    as a TObject as a constant
  @param   Ctx  as a TRTTIContext as a constant
  @param   View as a TListView as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIEvents(Const C : TObject; Const Ctx : TRTTIContext; 
  Const View : TListView);

Const
  iFirst2Chars = 2;
  strOn = 'on';

Var
  T : TRTTIType;
  P : TRTTIProperty;

Begin
  View.Items.BeginUpdate;
  Try
    T := Ctx.GetType(C.ClassType);
    For P In T.GetProperties Do
      If CompareText(Copy(P.Name, 1, iFirst2Chars), strOn) = 0 Then
        ProcessRTTICoreProperty(C, P, View);
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure iterates through the properties of the given object outputting a list view item for each
  property containing the following information: Scope; Fully Qualified Name; Field Type; Offset of the 
  field in the VTable (I think); Value TypeKind; DataSize; Value.

  @precon  C, Ctx and View must be a valid instances.
  @postcon A list view item is created for the property.

  @param   C    as a TObject as a constant
  @param   Ctx  as a TRTTIContext as a constant
  @param   View as a TListView as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIFields(Const C : TObject; Const Ctx : TRTTIContext;
  Const View : TListView);

Const 
  iNoOfFields = 5;
  
Var
  T    : TRTTIType;
  F    : TRTTIField;
  V    : TValue;
  Item : TListItem;

Begin
  View.Items.BeginUpdate;
  Try
    T := Ctx.GetType(C.ClassType);
    For F In T.GetFields Do
      Begin
        Item := View.Items.Add;
        Item.Caption := strVisibility[F.Visibility];
        Item.StateIndex := Integer(F.Visibility);
        Item.SubItems.Add(F.Parent.Name + '.' + F.Name);
        If Assigned(F.FieldType) Then
          Begin
            Item.SubItems.Add(F.FieldType.ToString);
            Item.SubItems.Add(Format('$%x', [F.Offset]));
            Item.SubItems.Add(GetEnumName(TypeInfo(TTypeKind), Ord(F.FieldType.TypeKind)));
            Item.ImageIndex := Integer(F.FieldType.TypeKind);
            Item.SubItems.Add(Format('%d ', [F.FieldType.TypeSize]));
          End;
        Try
          V := F.GetValue(C);
          ProcessValue(Item, V, F.FieldType.ToString);
        Except
          On E : EInsufficientRtti Do
            Begin
              While Item.SubItems.Count < iNoOfFields Do
                Item.SubItems.Add('');
              Item.SubItems.Add(Format(strOops, [E.ClassName, E.Message]));
            End;
        End;
      End;
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure iterates through the methods associated with the given object and output a list view 
  item for each method showing the following information: Scope; Fully Qualified Name; Method Kind; 
  Method Signature.

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is creates for each method.

  @param   C    as a TObject as a constant
  @param   Ctx  as a TRTTIContext as a constant
  @param   View as a TListView as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIMethods(Const C : TObject; Const Ctx : TRTTIContext;
  Const View : TListView);

Const
  iNoOfFields = 2;
  
Var
  T : TRTTIType;
  M    : TRTTIMethod;
  Item : TListItem;

Begin
  View.Items.BeginUpdate;
  Try
    T := Ctx.GetType(C.ClassType);
    For M In T.GetMethods Do
      Begin
        Item := View.Items.Add;
        Item.Caption := strVisibility[M.Visibility];
        Item.StateIndex := Integer(M.Visibility);
        Item.SubItems.Add(M.Parent.Name + '.' + M.Name);
        Try
          Item.SubItems.Add(GetEnumName(TypeInfo(TMethodKind), Ord(M.MethodKind)));
          Item.ImageIndex := Integer(tkMethod);
          Item.SubItems.Add(M.ToString);
        Except
          On E : EInsufficientRtti Do
            Begin
              While Item.SubItems.Count < iNoOfFields Do
                Item.SubItems.Add('');
              Item.SubItems.Add(Format(strOops, [E.ClassName, E.Message]));
            End;
        End;
      End;
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure iterates through the properties of the object and creates a list view item for each 
  property not starting with "On" (i.e. an event).

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is created for each property.

  @param   C    as a TObject as a constant
  @param   Ctx  as a TRTTIContext as a constant
  @param   View as a TListView as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIProperties(Const C : TObject; Const Ctx : TRTTIContext;
  Const View : TListView);

Const
  iFirst2Chars = 2;
  strOn = 'on';

Var
  T    : TRTTIType;
  P    : TRTTIProperty;

Begin
  View.Items.BeginUpdate;
  Try
    T := Ctx.GetType(C.ClassType);
    For P In T.GetProperties Do
      If CompareText(Copy(P.Name, 1, iFirst2Chars), strOn) <> 0 Then
        ProcessRTTICoreProperty(C, P, View);
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure processes the retrieval of the value for fields and properties so that an integer return
  can be overridden for TColor and TCursor to return their colours, cursor names etc.

  @precon  Item must be a valid instance.
  @postcon The value of the field / property is added to the list view item.

  @param   Item    as a TListItem as a constant
  @param   Value   as a TValue as a constant
  @param   strType as a String as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessValue(Const Item : TListItem; Const Value : TValue;
  Const strType : String);

Const
  strTColor = 'TColor';
  strTCursor = 'TCursor';

Var
  strValue: String;

Begin
  strValue := ValueToString(Value);
  If CompareText(strType, strTColor) = 0 Then
    strValue := ColorToString(Value.AsInteger);
  If CompareText(strType, strTCursor) = 0 Then
    strValue := CursorToString(Value.AsInteger);
  Item.SubItems.Add(strValue);
End;

(**

  This function does all the conversion of a TValue passed to it into a text eqivalent.

  @precon  None.
  @postcon A striong representing the value is returned.

  @param   Value as a TValue as a constant
  @return  a String

**)
Class Function TIDEExplorerNEWRTTI.ValueToString(Const Value : TValue) : String;

  (**

    This function returns a square bracketed list of array values corresponding to the
    array stored in Value.

    @precon  None.
    @postcon Returns a square bracketed list of array values.

    @return  a String

  **)
  Function ArrayToString : String;

  Var
    iLength : Integer;
    i : Integer;

  Begin
    Result := Value.ToString;
    If Not Value.IsEmpty Then
      Begin
        Result := '';
        iLength := Value.GetArrayLength;
        For i := 0 To iLength - 1 Do
          Begin
            If Result <> '' Then
              Result := Result + ', ';
            Result := Result + ValueToString(Value.GetArrayElement(i));
          End;
        Result := '[' + Result + ']';
      End;
  End;

  (**

    This function returns the ordinal value of the character and if the character is
    greater than 32 also appeands the character.

    @precon  None.
    @postcon Returns an ordinal value for the character.

    @return  a String

  **)
  Function CharAsString : String;

  Const
    iSpaceChar = 32;

  Var
    iOrd : Integer;

  Begin
    iOrd := Value.AsOrdinal;
    Result := '#' + IntToStr(iOrd);
    If iOrd >= iSpaceChar Then
      Result := Result + ' (' + Chr(iOrd) + ')';
  End;

  (**

    This function return the value of the method is assigned else returns (unassigned).

    @precon  None.
    @postcon Return the value of the method is assigned else returns (unassigned).

    @return  a String

  **)
  Function MethodAsString : String;

  ResourceString
    strUnassigned = '(unassigned)';

  Begin
    If Value.IsEmpty Then
      Result := strUnassigned
    Else
      Result := Value.ToString;
  End;

ResourceString
  strUnknown = '<Unknown>';
  strNotHandled = '<Not handled>';

Begin
  Case Value.TypeInfo.Kind Of
    tkUnknown:     Result := strUnknown;
    tkInteger:     Result := Value.ToString;
    tkChar:        Result := CharAsString;
    tkEnumeration: Result := Value.ToString; // Boolean here
    tkFloat:       Result := Format('#,##0.000', [Value.AsExtended]);
    tkString:      Result := '''' + Value.AsString + '''';
    tkSet:         Result := Value.ToString;
    tkClass:       Result := Value.ToString;
    tkMethod:      Result := MethodAsString;
    tkWChar:       Result := CharAsString;
    tkLString:     Result := '''' + Value.ToString + '''';
    tkWString:     Result := '''' + Value.ToString + '''';
    tkVariant:     Result := VarToStr(Value.AsVariant) + ' (' + VarTypeAsText(Value.AsVariant) + ')';
    tkArray:       Result := ArrayToString;
    tkRecord:      Result := Value.ToString;
    tkInterface:   Result := Value.ToString;
    tkInt64:       Result := IntToStr(Value.AsInt64);
    tkDynArray:    Result := ArrayToString;
    tkUString:     Result := '''' + Value.ToString + '''';
    tkClassRef:    Result := Value.ToString;
    tkPointer:     Result := Value.ToString;
    tkProcedure:   Result := MethodAsString;
  Else
    Result := strNotHandled;
  End;
End;

(** This initialization section is used to create a global list of objects to store
    instances of found classes fir the ProcessClass method above. Its to prevent loops. **)
Initialization
  FoundClasses := TList.Create;
(** Frees the FoudnClasses list. **)
Finalization
  FoundClasses.Free;
End.
