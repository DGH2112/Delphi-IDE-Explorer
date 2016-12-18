(**

  This module contains the new RTTI code to extract information for fields, methods,
  properties and events for various objects pass to the single routine below.

  @Author  David Hoyle
  @Version 2.0
  @Date    18 Dec 2016

**)
Unit DGHRTTIFunctions;

Interface

Uses
  RTTI,
  ComCtrls,
  Classes;

  Procedure ProcessObject(C : TObject; FieldView, MethodView, PropertyView,
    EventView : TListView);
  Procedure ProcessClass(tvTree : TTreeView; ParentNode : TTreeNode; C : TObject);

Var
  (** This class is used to store the addresses of all objects found so that we do not
      iterate though loops in the IDE when getting classes. **)
  FoundClasses : TList;

Implementation

Uses
  SysUtils,
  TypInfo,
  Variants,
  Graphics,
  Controls;

Const
  (** This is a constant array of string to describe the different visibility aspects
      of class members: private, protected, public and published. **)
  strVisibility : Array[Low(TMemberVisibility)..High(TMemberVisibility)] Of String = (
    'Private', 'Protected', 'Public', 'Published');

(**

  This function does all the conversion of a TValue passed to it into a text eqivalent.

  @precon  None.
  @postcon A striong representing the value is returned.

  @param   Value as a TValue
  @return  a String

**)
Function ValueToString(Value : TValue) : String;

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

  Var
    iOrd : Integer;

  Begin
    iOrd := Value.AsOrdinal;
    Result := '#' + IntToStr(iOrd);
    If iOrd >= 32 Then
      Result := Result + ' (' + Chr(iOrd) + ')';
  End;

  (**

    This function return the value of the method is assigned else returns (unassigned).

    @precon  None.
    @postcon Return the value of the method is assigned else returns (unassigned).

    @return  a String

  **)
  Function MethodAsString : String;

  Begin
    If Value.IsEmpty Then
      Result := '(unassigned)'
    Else
      Result := Value.ToString;
  End;

Begin
  //Try
    Case Value.TypeInfo.Kind Of
      tkUnknown:     Result := '<Unknown>';
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
      Result := '<Not handled>';
    End;
  //Except
  //  On E : Exception Do
  //    Result := 'Oops (' + E.ClassName + '): ' + E.Message;
  //End;
End;

(**

  This procedure processes the retrieval of the value for fields and properties so that an
  integer return can be overridden for TColor and TCursor to return their colours, cursor
  names etc.

  @precon  Item must be a valid instance.
  @postcon The value of the field / property is added to the list view item.

  @param   Item    as a TListItem
  @param   Value   as a TValue
  @param   strtype as a String

**)
Procedure ProcessValue(Item : TListItem; Value : TValue; strType : String);

Var
  strValue: String;

Begin
  strValue := ValueToString(Value);
  If CompareText(strType, 'TColor') = 0 Then
    strValue := ColorToString(Value.AsInteger);
  If CompareText(strType, 'TCursor') = 0 Then
    strValue := CursorToString(Value.AsInteger);
  Item.SubItems.Add(strValue);
End;

(**

  This procedure iterates through the properties of the given object outputting a list
  view item for each property containing the following information:

    Scope;
    Fully Qualified Name;
    Field Type;
    Offset of the field in the VTable (I think);
    Value TypeKind;
    DataSize;
    Value.

  @precon  C, Ctx and View must be a valid instances.
  @postcon A list view item is created for the property.

  @param   C    as a TObject
  @param   Ctx  as a TRTTIContext
  @param   View as a TListView

**)
Procedure ProcessRTTIFields(C : TObject; Ctx : TRTTIContext; View : TListView);

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
        Try
          V := F.GetValue(C);
          Item.SubItems.Add(F.FieldType.ToString);
          Item.SubItems.Add(Format('$%x', [F.Offset]));
          Item.SubItems.Add(GetEnumName(TypeInfo(TTypeKind), Ord(V.TypeInfo.Kind)));
          Item.ImageIndex := Integer(V.TypeInfo.Kind);
          Item.SubItems.Add(Format('%d ', [V.DataSize]));
          ProcessValue(Item, V, F.FieldType.ToString);
        Except
          On E : EInsufficientRtti Do
            Begin
              While Item.SubItems.Count < 5 Do
                Item.SubItems.Add('');
              Item.SubItems.Add('Oops (' + E.ClassName + '): ' + E.Message);
            End;
        End;
      End;
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure iterates through the methods associated with the given object and output
  a list view item for each method showing the following information:

    Scope;
    Fully Qualified Name;
    Method Kind;
    Method Signature.

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is creates for each method.

  @param   C    as a TObject
  @param   Ctx  as a TRTTIContext
  @param   View as a TListView

**)
Procedure ProcessRTTIMethods(C : TObject; Ctx : TRTTIContext; View : TListView);

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
        Item.SubItems.Add(GetEnumName(TypeInfo(TMethodKind), Ord(M.MethodKind)));
        Item.ImageIndex := Integer(tkMethod);
        Item.SubItems.Add(M.ToString);
      End;
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure is called for properties and event as the output is the same they are
  just filtered differently. This outputs a list view item for the given property/event
  in the object with the following information:

    Scope;
    Fully Qualified Name;
    Property Type;
    Access;
    Value TypeKind;
    DataSize;
    Value.

  @precon  C, P and View must be a valid instances.
  @postcon A list view item is create the property or event.

  @param   C    as a TObject
  @param   P    as a TRTTIProperty
  @param   View as a TListView

**)
Procedure ProcessRTTICoreProperty(C : TObject; P : TRTTIProperty; View : TListView);

Var
  V    : TValue;
  Item : TListItem;

Begin
  Item := View.Items.Add;
  Item.Caption := strVisibility[P.Visibility];
  Item.StateIndex := Integer(P.Visibility);
  Item.SubItems.Add(P.Parent.Name + '.' + P.Name);
  Item.SubItems.Add(P.PropertyType.ToString);
  If P.IsReadAble And P.IsWritable Then
    Item.SubItems.Add('Read/Write')
  Else If P.IsReadAble And Not P.IsWritable Then
    Item.SubItems.Add('Readonly')
  Else If P.IsReadAble And Not P.IsWritable Then
    Item.SubItems.Add('Writeonly');
  Try
    V := P.GetValue(C);
    Item.SubItems.Add(GetEnumName(TypeInfo(TTypeKind), Ord(V.TypeInfo.Kind)));
    Item.ImageIndex := Integer(V.TypeInfo.Kind);
    Item.SubItems.Add(Format('%d ', [V.DataSize]));
    If P.IsReadable Then
      ProcessValue(Item, V, P.PropertyType.ToString);
  Except
    // Capture COM class registration errors
    On E : EComponentError Do
      Begin
        While Item.SubItems.Count < 5 Do
          Item.SubItems.Add('');
        Item.SubItems.Add('Oops (' + E.ClassName + '): ' + E.Message);
      End;
  End;
End;

(**

  This procedure iterates through the properties of the object and creates a list view
  item for each property not starting with "On" (i.e. an event).

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is created for each property.

  @param   C    as a TObject
  @param   Ctx  as a TRTTIContext
  @param   View as a TListView

**)
Procedure ProcessRTTIProperties(C : TObject; Ctx : TRTTIContext; View : TListView);

Var
  T    : TRTTIType;
  P    : TRTTIProperty;

Begin
  View.Items.BeginUpdate;
  Try
    T := Ctx.GetType(C.ClassType);
    For P In T.GetProperties Do
      If CompareText(Copy(P.Name, 1, 2), 'on') <> 0 Then
        ProcessRTTICoreProperty(C, P, View);
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure iterates through the properties of the object and creates a list view
  item for each property starting with "On" (i.e. an event).

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is created for each event.

  @param   C    as a TObject
  @param   Ctx  as a TRTTIContext
  @param   View as a TListView

**)
Procedure ProcessRTTIEvents(C : TObject; Ctx : TRTTIContext; View : TListView);

Var
  T : TRTTIType;
  P : TRTTIProperty;

Begin
  View.Items.BeginUpdate;
  Try
    T := Ctx.GetType(C.ClassType);
    For P In T.GetProperties Do
      If CompareText(Copy(P.Name, 1, 2), 'on') = 0 Then
        ProcessRTTICoreProperty(C, P, View);
  Finally
    View.Items.EndUpdate;
  End;
End;

(**

  This procedure processes the fields, methods, properties adn events for the given
  object.

  @precon  C, FieldView, MethodView, PropertyView and EventView must be valid instances.
  @postcon The fields, methods, properties and events of the object are output.

  @param   C            as a TObject
  @param   FieldView    as a TListView
  @param   MethodView   as a TListView
  @param   PropertyView as a TListView
  @param   EventView    as a TListView

**)
Procedure ProcessObject(C : TObject; FieldView, MethodView, PropertyView,
  EventView : TListView);

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

  This procedure is design to recursively iterate through the classes and sub classes of
  a given object and add them to the tree view.

  @BUG     Using this code on the IDE (RAD Studio 10 Seattle) causes catastrophic
           failures: It is assuemd that when TValue extracts the value of an item it
           inadvertantly changes some of those obejcts which cause various AV and a
           divide by zero error. DO NOT IMPLEMENT THIS UNTIL THE REASONS FOR THE FALIURES
           ARE UNDERSTOOD OTHERWISE YOU WILL CRASH YOUR IDE.

  @precon  tvTree, ParentNode and C must be valid instances.
  @postcon Iterates through the classes subclasses adding them to the tree and then asking
           those classes for their sub-classes.

  @param   tvTree     as a TTreeView
  @param   ParentNode as a TTreeNode
  @param   C          as a TObject

**)
Procedure ProcessClass(tvTree : TTreeView; ParentNode : TTreeNode; C : TObject);

Var
  Ctx : TRttiContext;
  T   : TRttiType;
  F   : TRttiField;
  P   : TRttiProperty;
  V   : TValue;
  N   : TTreeNode;
  iIndex: Integer;

Begin
  FoundClasses.Add(C);
  Ctx := TRttiContext.Create;
  Try
    //Try
      T := Ctx.GetType(C.ClassType);
      For F In T.GetFields Do
        If F.FieldType.TypeKind = tkClass Then
          Begin
            V := F.GetValue(C);
            N := tvTree.Items.AddChildObject(ParentNode, F.Parent.Name + '.' + F.Name + ' : ' +
              F.FieldType.ToString + ' ' + ValueToString(V), V.AsObject);
            If Not V.IsEmpty Then
              Begin
                iIndex := FoundClasses.IndexOf(V.AsObject);
                If iIndex = -1 Then
                  ProcessClass(tvTree, N, V.AsObject);
              End;
          End;
      For P In T.GetProperties Do
        If P.PropertyType.TypeKind = tkClass Then
          Begin
            V := P.GetValue(C);
            N := tvTree.Items.AddChildObject(ParentNode, P.Parent.Name + '.' + P.Name + ' : ' +
              P.PropertyType.ToString + ' ' + ValueToString(V), V.AsObject);
            If Not V.IsEmpty Then
              Begin
                iIndex := FoundClasses.IndexOf(V.AsObject);
                If iIndex = -1 Then
                  ProcessClass(tvTree, N, V.AsObject);
              End;
          End;
    //Except
    //  On E : Exception Do
    //    tvTree.Items.AddChild(ParentNode, '(' + E.ClassName + ')' + E.Message);
    //End;
  Finally
    Ctx.Free;
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
