(**

  This module contains the new RTTI code to extract information for fields, methods,
  properties and events for various objects pass to the single routine below.

  @Author  David Hoyle
  @Version 2.860
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
Unit IDEExplorer.RTTIFunctions;

Interface

Uses
  RTTI,
  ComCtrls,
  VirtualTrees,
  Classes,
  IDEEXplorer.Interfaces;

Type
  (** A record to encapsulate the new RTTi methods. **)
  TIDEExplorerNEWRTTI = Record
  Strict Private
    Class Var
      (** A class variable to hold a single instance of an RTTI Context. **)
      FContext : TRttiContext;
  Strict Private
    Class Procedure ProcessRTTICoreProperty(Const C : TObject; Const P : TRTTIProperty;
      Const vstView : TVirtualStringTree); Static;
    Class Procedure ProcessRTTIEvents(Const C : TObject; Const vstEvents : TVirtualStringTree); Static;
    Class Procedure ProcessRTTIFields(Const C : TObject; Const vstFields : TVirtualStringTree); Static;
    Class Procedure ProcessRTTIMethods(Const C : TObject; Const vstMethods : TVirtualStringTree); Static;
    Class Procedure ProcessRTTIProperties(Const C : TObject;
      Const vstProperties : TVirtualStringTree); Static;
    Class Function ProcessValue(Const Value : TValue; Const strType : String) : String; Static;
    Class Function ValueToString(Const Value : TValue) : String; Static;
    Class Procedure ProcessCoreClass(Const vstComponents : TVirtualStringTree; Const N : PVirtualNode;
      Const V : TValue); Static;
  Public
    Class Constructor Create;
    Class Procedure ProcessObjectEvents(Const C : TObject; Const vstEvents : TVirtualStringTree;
      Const ProgressMgr : IDIEProgressMgr); Static;
    Class Procedure ProcessObjectFields(Const C : TObject; Const vstFields : TVirtualStringTree;
      Const ProgressMgr : IDIEProgressMgr); Static;
    Class Procedure ProcessObjectMethods(Const C : TObject; Const vstMethods : TVirtualStringTree;
      Const ProgressMgr : IDIEProgressMgr); Static;
    Class Procedure ProcessObjectProperties(Const C : TObject; Const vstProperties : TVirtualStringTree;
      Const ProgressMgr : IDIEProgressMgr); Static;
    Class Procedure ProcessClass(
      Const vstComponents : TVirtualStringTree;
      Const ParentNode : PVirtualNode;
      Const C : TObject
    ); Static;
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
  IDEExplorer.Functions,
  IDEExplorer.Types;

ResourceString
  (** A resource string for RTTI Exceptions. **)
  strOops = '(%s): %s';

Const
  (** This is a constant array of string to describe the different visibility aspects
      of class members: private, protected, public and published. **)
  strVisibility : Array[TMemberVisibility] Of String = (
    'Private',
    'Protected',
    'Public',
    'Published'
  );

(**

  A constructor for the TIDEExplorerNEWRTTI record.

  @precon  None.
  @postcon Initialises an RTTI context class variable.

**)
Class Constructor TIDEExplorerNEWRTTI.Create;

Begin
  FContext := TRTTIContext.Create;
End;

(**

  This procedure is design to recursively iterate through the classes and sub classes of a given object 
  and add them to the tree view.

  @precon  vstComponents, ParentNode and C must be valid instances.
  @postcon Iterates through the classes subclasses adding them to the tree and then asking those classes
           for their sub-classes.

  @BUG     Using this code on the IDE (RAD Studio 10 Seattle) causes catastrophic failures: It is 
           assumed that when TValue extracts the value of an item it inadvertantly changes some of 
           those objects which cause various AV and a divide by zero error. DO NOT IMPLEMENT THIS 
           UNTIL THE REASONS FOR THE FAILURES ARE UNDERSTOOD OTHERWISE YOU WILL CRASH YOUR IDE.

  @param   vstComponents as a TVirtualStringTree as a constant
  @param   ParentNode    as a PVirtualNode as a constant
  @param   C             as a TObject as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessClass(
                  Const vstComponents : TVirtualStringTree;
                  Const ParentNode : PVirtualNode;
                  Const C : TObject
                );

Var
  Ctx : TRttiContext;
  T   : TRttiType;
  F   : TRttiField;
  P   : TRttiProperty;
  V   : TValue;
  N   : PVirtualNode;
  NodeData : PDIEObjectData;

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
            N := vstComponents.AddChild(ParentNode);
            NodeData := vstComponents.GetNodeData(N);
            NodeData.FText := Format('%s.%s: %s %s', [
              F.Parent.Name,F.Name,
              F.FieldType.ToString,
              ValueToString(V)
            ]);
            NodeData.FImageIndex := -1; //: @debug What to do with this.
            NodeData.FObject := V.AsObject;
            ProcessCoreClass(vstComponents, N, V);
          End;
      End;
    For P In T.GetProperties Do
      If P.PropertyType.TypeKind = tkClass Then
        Begin
          V := P.GetValue(C);
          N := vstComponents.AddChild(ParentNode);
          NodeData := vstComponents.GetNodeData(N);
          NodeData.FText := Format('%s.%s: %s %s', [
            P.Parent.Name,
            P.Name,
            P.PropertyType.ToString,
            ValueToString(V)
          ]);
          NodeData.FObject := V.AsObject;
          ProcessCoreClass(vstComponents, N, V);
        End;
  Finally
    Ctx.Free;
  End;
End;

(**

  This method processes the Value of the class item and if found to be another class, recursively 
  processes the class.

  @precon  vstComponents and N must be valid instances.
  @postcon Processes the Value of the class item and if found to be another class, recursively 
           processes the class.

  @param   vstComponents as a TVirtualStringTree as a constant
  @param   N             as a PVirtualNode as a constant
  @param   V             as a TValue as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessCoreClass(
                  Const vstComponents : TVirtualStringTree;
                  Const N : PVirtualNode;
                  Const V : TValue
                );

Var
  iIndex: Integer;

Begin
  If Not V.IsEmpty Then
    Begin
      iIndex := FoundClasses.IndexOf(V.AsObject);
      If iIndex = -1 Then
        ProcessClass(vstComponents, N, V.AsObject);
    End;
End;

(**

  This procedure processes the fields, methods, properties and events for the given object.

  @precon  C and vstEvents must be valid instances.
  @postcon The fields, methods, properties and events of the object are output.

  @param   C           as a TObject as a constant
  @param   vstEvents   as a TVirtualStringTree as a constant
  @param   ProgressMgr as an IDIEProgressMgr as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessObjectEvents(Const C : TObject;
  Const vstEvents : TVirtualStringTree; Const ProgressMgr : IDIEProgressMgr);

ResourceString
  strFindingEvents = 'Finding Events...';

Begin
  ProgressMgr.Update(strFindingEvents);
  ProcessRTTIEvents(C, vstEvents);
End;

(**

  This method processed the given objects fields and adds them to the given virtual treeview.

  @precon  C and vstFields must be valid instances.
  @postcon The fields of the object are added to the VTV control.

  @param   C           as a TObject as a constant
  @param   vstFields   as a TVirtualStringTree as a constant
  @param   ProgressMgr as an IDIEProgressMgr as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessObjectFields(Const C: TObject;
  Const vstFields: TVirtualStringTree; Const ProgressMgr: IDIEProgressMgr);

ResourceString
  strFindingFields = 'Finding Fields...';

Begin
  ProgressMgr.Update(strFindingFields);
  ProcessRTTIFields(C, vstFields);
End;

(**

  This method processed the given objects methods and adds them to the given virtual treeview.

  @precon  C and vstMethods must be valid instances.
  @postcon The methods of the object are added to the VTV control.

  @param   C           as a TObject as a constant
  @param   vstMethods  as a TVirtualStringTree as a constant
  @param   ProgressMgr as an IDIEProgressMgr as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessObjectMethods(Const C: TObject;
  Const vstMethods: TVirtualStringTree; Const ProgressMgr: IDIEProgressMgr);

ResourceString
  strFindingMethods = 'Finding Methods...';

Begin
  ProgressMgr.Update(strFindingMethods);
  ProcessRTTIMethods(C, vstMethods);
End;

(**

  This method processed the given objects properties and adds them to the given virtual treeview.

  @precon  C and vstProperties must be valid instances.
  @postcon The properties of the object are added to the VTV control.

  @param   C             as a TObject as a constant
  @param   vstProperties as a TVirtualStringTree as a constant
  @param   ProgressMgr   as an IDIEProgressMgr as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessObjectProperties(Const C: TObject;
  Const vstProperties: TVirtualStringTree; Const ProgressMgr: IDIEProgressMgr);

ResourceString
  strFindingProperties = 'Finding Properties...';

Begin
  ProgressMgr.Update(strFindingProperties);
  ProcessRTTIProperties(C, vstProperties);
End;

(**

  This procedure is called for properties and event as the output is the same they are just filtered 
  differently. This outputs a list view item for the given property/event in the object with the 
  following information: Scope; Fully Qualified Name; Property Type; Access; Value Type Kind; Data Size; 
  Value.

  @precon  C, P and View must be a valid instances.
  @postcon A list view item is create the property or event.

  @param   C       as a TObject as a constant
  @param   P       as a TRTTIProperty as a constant
  @param   vstView as a TVirtualStringTree as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTICoreProperty(Const C : TObject; Const P : TRTTIProperty;
  Const vstView : TVirtualStringTree);

  (**

    This procedure determines the access type for the property and outputs that to the list view.

    @precon  Item must be a valid instance.
    @postcon The properties access type is output.

    @param   NodeData as a PDIEPropertyData as a constant

  **)
  Procedure PropertyAccess(Const NodeData : PDIEPropertyData);

  ResourceString
    strReadWrite = 'Read/Write';
    strReadonly = 'Read only';
    strWriteonly = 'Write only';
    strUnknown = '<Unknown>';

  Begin
    If P.IsReadAble And P.IsWritable Then
      NodeData.FAccess := strReadWrite
    Else If P.IsReadAble And Not P.IsWritable Then
      NodeData.FAccess := strReadonly
    Else If Not P.IsReadAble And P.IsWritable Then
      NodeData.FAccess := strWriteonly
    Else
      NodeData.FAccess := strUnknown;
  End;

Var
  V    : TValue;
  Node : PVirtualNode;
  NodeData : PDIEPropertyData;

Begin
  Node := vstView.AddChild(Nil);
  NodeData := vstView.GetNodeData(Node);
  NodeData.FVisibility := strVisibility[P.Visibility];
  NodeData.FVisibilityIndex := Integer(P.Visibility);
  NodeData.FQualifiedName := P.Parent.Name + '.' + P.Name;
  If Assigned(P.PropertyType) Then
    Begin
      NodeData.FType := P.PropertyType.ToString;
      PropertyAccess(NodeData);
      NodeData.FKind := GetEnumName(TypeInfo(TTypeKind), Ord(P.PropertyType.TypeKind));
      NodeData.FImageIndex := Integer(P.PropertyType.TypeKind);
      NodeData.FSize := Format('%d ', [P.PropertyType.TypeSize]);
    End;
  Try
    If Not FatalValue(P.Name) And P.IsReadable Then
      Begin
        V := P.GetValue(C);
        If P.IsReadable Then
          NodeData.FValue := ProcessValue(V, P.PropertyType.ToString);
      End;
  Except
    On E : EInsufficientRtti Do
      NodeData.FValue := Format(strOops, [E.ClassName, E.Message]);
  End;
End;

(**

  This procedure iterates through the properties of the object and creates a list view item for each 
  property starting with "On" (i.e. an event).

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is created for each event.

  @param   C         as a TObject as a constant
  @param   vstEvents as a TVirtualStringTree as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIEvents(Const C : TObject;
  Const vstEvents : TVirtualStringTree);

Const
  iFirst2Chars = 2;
  strOn = 'on';

Var
  T : TRTTIType;
  P : TRTTIProperty;

Begin
  vstEvents.BeginUpdate;
  Try
    T := FContext.GetType(C.ClassType);
    For P In T.GetProperties Do
      If CompareText(Copy(P.Name, 1, iFirst2Chars), strOn) = 0 Then
        ProcessRTTICoreProperty(C, P, vstEvents);
  Finally
    vstEvents.EndUpdate;
  End;
End;

(**

  This procedure iterates through the properties of the given object outputting a list view item for each
  property containing the following information: Scope; Fully Qualified Name; Field Type; Offset of the 
  field in the Virtual Table (I think); Value Type Kind; Data Size; Value.

  @precon  C, Ctx and View must be a valid instances.
  @postcon A list view item is created for the property.

  @param   C         as a TObject as a constant
  @param   vstFields as a TVirtualStringTree as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIFields(Const C : TObject;
  Const vstFields : TVirtualStringTree);

Var
  Node : PVirtualNode;
  NodeData : PDIEFieldData;
  AType : TRTTIType;
  Field : TRTTIField;
  Value : TValue;

Begin
  vstFields.BeginUpdate;
  Try
    AType := FContext.GetType(C.ClassType);
    For Field In AType.GetFields Do
      Begin
        Node := vstFields.AddChild(Nil);
        NodeData := vstFields.GetNodeData(Node);
        NodeData.FVisibility := strVisibility[Field.Visibility];
        NodeData.FVisibilityIndex := Integer(Field.Visibility);
        NodeData.FQualifiedName := Field.Parent.Name + '.' + Field.Name;
        If Assigned(Field.FieldType) Then
          Begin
            NodeData.FType := Field.FieldType.ToString;
            NodeData.FOffset := Format('$%x', [Field.Offset]);
            NodeData.FKind := GetEnumName(TypeInfo(TTypeKind), Ord(Field.FieldType.TypeKind));
            NodeData.FImageIndex := Integer(Field.FieldType.TypeKind);
            NodeData.FSize := Format('%d ', [Field.FieldType.TypeSize]);
          End;
        Try
          Value := Field.GetValue(C);
          NodeData.FValue := ProcessValue(Value, Field.FieldType.ToString);
        Except
          On E : EInsufficientRtti Do
            NodeData.FValue := Format(strOops, [E.ClassName, E.Message]);
        End;
      End;
  Finally
    vstFields.EndUpdate;
  End;
End;

(**

  This procedure iterates through the methods associated with the given object and output a list view 
  item for each method showing the following information: Scope; Fully Qualified Name; Method Kind; 
  Method Signature.

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is creates for each method.

  @param   C          as a TObject as a constant
  @param   vstMethods as a TVirtualStringTree as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIMethods(Const C : TObject;
  Const vstMethods : TVirtualStringTree);

Var
  Node: PVirtualNode;
  NodeData : PDIEMethodData;
  AType : TRTTIType;
  Method    : TRTTIMethod;

Begin
  vstMethods.BeginUpdate;
  Try
    AType := FContext.GetType(C.ClassType);
    For Method In AType.GetMethods Do
      Begin
        Node := vstMethods.AddChild(Nil);
        NodeData := vstMethods.GetNodeData(Node);
        NodeData.FVisibility := strVisibility[Method.Visibility];
        NodeData.FVisibilityIndex := Integer(Method.Visibility);
        NodeData.FQualifiedName := Method.Parent.Name + '.' + Method.Name;
        Try
          NodeData.FType := GetEnumName(TypeInfo(TMethodKind), Ord(Method.MethodKind));
          NodeData.FImageIndex := Integer(tkMethod);
          NodeData.FSignature := Method.ToString;
        Except
          On E : EInsufficientRtti Do
            NodeData.FSignature := Format(strOops, [E.ClassName, E.Message]);
        End;
      End;
  Finally
    vstMethods.EndUpdate;
  End;
End;

(**

  This procedure iterates through the properties of the object and creates a list view item for each 
  property not starting with "On" (i.e. an event).

  @precon  C, Ctx and View must be valid instances.
  @postcon A list view item is created for each property.

  @param   C             as a TObject as a constant
  @param   vstProperties as a TVirtualStringTree as a constant

**)
Class Procedure TIDEExplorerNEWRTTI.ProcessRTTIProperties(Const C : TObject;
  Const vstProperties : TVirtualStringTree);

Const
  iFirst2Chars = 2;
  strOn = 'on';

Var
  T    : TRTTIType;
  P    : TRTTIProperty;

Begin
  vstProperties.BeginUpdate;
  Try
    T := FContext.GetType(C.ClassType);
    For P In T.GetProperties Do
      If CompareText(Copy(P.Name, 1, iFirst2Chars), strOn) <> 0 Then
        ProcessRTTICoreProperty(C, P, vstProperties);
  Finally
    vstProperties.EndUpdate;
  End;
End;

(**

  This procedure processes the retrieval of the value for fields and properties so that an integer return
  can be overridden for TColor and TCursor to return their colours, cursor names etc.

  @precon  Item must be a valid instance.
  @postcon The value of the field / property is added to the list view item.

  @param   Value   as a TValue as a constant
  @param   strType as a String as a constant
  @return  a String

**)
Class Function TIDEExplorerNEWRTTI.ProcessValue(Const Value : TValue; Const strType : String) : String;

Const
  strTColor = 'TColor';
  strTCursor = 'TCursor';

Begin
  Result := ValueToString(Value);
  If CompareText(strType, strTColor) = 0 Then
    Result := ColorToString(Value.AsInteger);
  If CompareText(strType, strTCursor) = 0 Then
    Result := CursorToString(Value.AsInteger);
End;

(**

  This function does all the conversion of a TValue passed to it into a text equivalent.

  @precon  None.
  @postcon A string representing the value is returned.

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
    greater than 32 also appends the character.

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
(** Frees the Found Classes list. **)
Finalization
  FoundClasses.Free;
End.
