(**

  This module contains the explorer form interface.

  @Date    25 Apr 2020
  @Version 4.966
  @Author  David Hoyle

  @done    Add a progress bar
  @done    Add a filter for the treeview.
  @todo    Add a filter for the fileds, methods, properties, etc.

**)
Unit IDEExplorer.ExplorerForm;

Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  ExtCtrls,
  ImgList,
  System.ImageList,
  Vcl.StdCtrls,
  VirtualTrees,
  IDEExplorer.Interfaces;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** This class represent a form for displaying the internal published elements of the IDE. **)
  TDGHIDEExplorerForm = Class(TForm)
    ilTreeImages: TImageList;
    splSplitter1: TSplitter;
    ilTypeKindImages: TImageList;
    pgcPropertiesMethodsAndEvents: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    lvOldProperties: TListView;
    tvHierarchies: TTreeView;
    tabNewProperties: TTabSheet;
    tabFields: TTabSheet;
    tabEvents: TTabSheet;
    lvEvents: TListView;
    tabMethods: TTabSheet;
    ilScope: TImageList;
    vstComponentTree: TVirtualStringTree;
    pnlTreePanel: TPanel;
    edtComponentFilter: TEdit;
    tmFilterTimer: TTimer;
    vstFields: TVirtualStringTree;
    vstMethods: TVirtualStringTree;
    vstProperties: TVirtualStringTree;
    Procedure BuildFormComponentTree(Sender: TObject);
    procedure edtComponentFilterChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tmFilterTimerTimer(Sender: TObject);
    procedure vstComponentTreeCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column:
      TColumnIndex; var Result: Integer);
    procedure vstComponentTreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column:
      TColumnIndex);
    procedure vstComponentTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstComponentTreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure vstComponentTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure vstFieldsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstFieldsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure vstFieldsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType:
      TVSTTextType; var CellText: string);
    procedure vstMethodsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstMethodsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure vstMethodsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure vstPropertiesFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstPropertiesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
      Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure vstPropertiesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
  Strict Private
    FProgressMgr               : IDIEProgressMgr;
    FLastComponentFilterUpdate : Cardinal;
  Strict Protected
    Procedure GetComponents(Const Node: PVirtualNode; Const Component: TComponent);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure BuildComponentHeritage(Const Node : PVirtualNode);
    Procedure BuildParentHeritage(Const Node : PVirtualNode);
    Procedure FilterComponents;
  Public
    Class Procedure Execute;
  End;

Implementation

{$R *.DFM}


Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  ToolsAPI,
  Registry,
  RegularExpressions,
  RegularExpressionsCore,
  IDEExplorer.RTTIFunctions,
  IDEExplorer.OLDRTTIFunctions,
  IDEExplorer.ProgressMgr, IDEExplorer.Types;

Type
  (** An enumerate to define the tree images. **)
  TIDEExplorerTreeImage = (tiApplication, tiDataModule, tiForm, tiPackage, tiForms, tiDataModules);

Const
  (** This is the root registration jey for this applications settings. **)
  RegKey = '\Software\Seasons Fall';
  (** This is the section name for the applications settings in the registry **)
  SectionName = 'DGH IDE Explorer';
  (** An INI Key for the top position of the dialogue. **)
  strTopKey = 'Top';
  (** An INI Key for the left position of the dialogue. **)
  strLeftKey = 'Left';
  (** An INI Key for the width size of the dialogue. **)
  strWidthKey = 'Width';
  (** An INI Key for the height size of the dialogue. **)
  strHeightKey = 'Height';
  (** An INI Key for the width position of the tree view in the dialogue. **)
  strTreeWidthKey = 'TreeWidth';

(**

  This method builds a hierarchical list of the components heritage.

  @precon  Node must be a vldi instance.
  @postcon The heritage tree is output to the hierarchies tab.

  @param   Node as a PVirtualNode as a constant

**)
Procedure TDGHIDEExplorerForm.BuildComponentHeritage(Const Node : PVirtualNode);

ResourceString
  strHeritage = 'Heritage';

Var
  PNode: TTreeNode;
  NodeData : PDIEObjectData;
  ClassRef: TClass;
  strList: TStringList;
  i: Integer;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'BuildComponentHeritage', tmoTiming);{$ENDIF}
  tvHierarchies.Items.BeginUpdate;
  Try
    tvHierarchies.Items.Clear;
    If Assigned(Node) Then
      Begin
        NodeData := vstComponentTree.GetNodeData(Node);
        If Assigned(Nodedata.FObject) Then
          Begin
            ClassRef := TComponent(NodeData.FObject).ClassType;
            strList := TStringList.Create;
            Try
              While Assigned(ClassRef) Do
                Begin
                  strList.Insert(0, ClassRef.ClassName);
                  ClassRef := ClassRef.ClassParent;
                End;
              PNode := tvHierarchies.Items.AddChild(Nil, strHeritage);
              For i := 0 To strList.Count - 1 Do
                Begin
                  PNode := tvHierarchies.Items.AddChild(PNode, strList[i]);
                  PNode.ImageIndex := Integer(tiPackage);
                  PNode.SelectedIndex := Integer(tiPackage);
                End;
            Finally
              strList.Free;
            End;
          End;
      End;
  Finally
    tvHierarchies.Items.EndUpdate;
  End;
End;

(**

  This is the forms on show event. It initialises the tree view.

  @precon  None.
  @postcon Iterates through the forms and datamodules and adds them to the tree view.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.BuildFormComponentTree(Sender: TObject);

  (**

    This method adds a form/datamodule to a root node in the tree and then calls GetComponents to get the
    forms components.

    @precon  ParentNode and ScreenForm must be valid instances.
    @postcon Adds a form/datamodule to a root node in the tree and then calls GetComponents to get the 
             forms components.

    @param   ParentNode as a PVirtualNode as a constant
    @param   Component  as a TComponent as a constant
    @param   eTreeImage as a TIDEExplorerTreeImage as a constant

  **)
  Procedure IterateForms(Const ParentNode : PVirtualNode; Const Component : TComponent;
    Const eTreeImage : TIDEExplorerTreeImage);

  Var
    Node : PVirtualNode;
    NodeData : PDIEObjectData;

  Begin
    {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'BuildFormComponentTree/IterateForms', tmoTiming);{$ENDIF}
    Node := vstComponentTree.AddChild(ParentNode);
    NodeData := vstComponentTree.GetNodeData(Node);
    NodeData.FText := Format('%s: %s', [Component.Name, Component.ClassName]);
    NodeData.FObject := Component;
    NodeData.FImageIndex := Integer(eTreeImage);
    TIDEExplorerNEWRTTI.ProcessClass(vstComponentTree, Node, Component);
    GetComponents(Node, Component);
  End;

ResourceString
  strApplication = 'Application';
  strScreen = 'Screen';
  strForms = 'Forms';
  strCustomForms = 'CustomForms';
  strDataModules = 'DataModules';
  strGettingAppicationClasses = 'Getting Appication Classes...';
  strGettingScreenClasses = 'Getting Screen Classes...';
  strIteratingScreenForms = 'Iterating Screen Forms...';
  strIteratingScreenCustomForms = 'Iterating Screen Custom Forms...';
  strIteratingScreenDataModules = 'Iterating Screen Data Modules...';
  strExpandingAndSorting = 'Expanding and Sorting...';

Const
  iProgressSteps = 6;

Var
  i: Integer;
  ApplicationNode : PVirtualNode;
  ScreenNode : PVirtualNode;
  NodeData : PDIEObjectData;
  Node : PVirtualNode;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'BuildFormComponentTree', tmoTiming);{$ENDIF}
  FProgressMgr.Initialise(iProgressSteps);
  Try
    vstComponentTree.BeginUpdate;
    Try
      FProgressMgr.Show(strGettingAppicationClasses);
      FoundClasses.Clear;
      ApplicationNode := vstComponentTree.AddChild(Nil);
      NodeData := vstComponentTree.GetNodeData(ApplicationNode);
      NodeData.FText := strApplication;
      NodeData.FObject := Application;
      NodeData.FImageIndex := Integer(tiApplication);
      TIDEExplorerNEWRTTI.ProcessClass(vstComponentTree, ApplicationNode, Application);
      FProgressMgr.Update(strGettingScreenClasses);
      ScreenNode := vstComponentTree.AddChild(Nil);
      NodeData := vstComponentTree.GetNodeData(ScreenNode);
      NodeData.FText := strScreen;
      NodeData.FObject := Screen;
      NodeData.FImageIndex := Integer(tiApplication);
      TIDEExplorerNEWRTTI.ProcessClass(vstComponentTree, ScreenNode, Screen);
      FProgressMgr.Update(strIteratingScreenForms);
      Node := vstComponentTree.AddChild(ScreenNode);
      NodeData := vstComponentTree.GetNodeData(Node);
      NodeData.FText := strForms;
      NodeData.FObject := Nil;
      NodeData.FImageIndex := Integer(tiForms);
      For i := 0 To Screen.FormCount - 1 Do
        IterateForms(Node, Screen.Forms[i], tiForm);
      FProgressMgr.Update(strIteratingScreenCustomForms);
      Node := vstComponentTree.AddChild(ScreenNode);
      NodeData := vstComponentTree.GetNodeData(Node);
      NodeData.FText := strCustomForms;
      NodeData.FObject := Nil;
      NodeData.FImageIndex := Integer(tiForms);
      For i := 0 To Screen.CustomFormCount - 1 Do
        IterateForms(Node, Screen.CustomForms[i], tiForm);
      FProgressMgr.Update(strIteratingScreenDataModules);
      Node := vstComponentTree.AddChild(ScreenNode);
      NodeData := vstComponentTree.GetNodeData(Node);
      NodeData.FText := strDataModules;
      NodeData.FObject := Nil;
      NodeData.FImageIndex := Integer(tiDataModules);
      For i := 0 To Screen.DataModuleCount - 1 Do
        IterateForms(Node, Screen.DataModules[i], tiDataModule);
      FProgressMgr.Update(strExpandingAndSorting);
      vstComponentTree.Expanded[ApplicationNode] := True;
      vstComponentTree.Expanded[ScreenNode] := True;
      vstComponentTree.SortTree(0, sdAscending);
    Finally
      vstComponentTree.EndUpdate;
    End;
  Finally
    FProgressMgr.Hide;
  End;
End;

(**

  This method outputs the parent hierarchy of the WinControl (if its a WinControl).

  @precon  Node must be a vldi instance.
  @postcon The parent hierarchy is outuput to the hierarchies tab.

  @param   Node as a PVirtualNode as a constant

**)
Procedure TDGHIDEExplorerForm.BuildParentHeritage(Const Node : PVirtualNode);

ResourceString
  strParentage = 'Parentage';

Var
  PNode: TTreeNode;
  NodeData : PDIEObjectData;
  Parent: TWinControl;
  slList: TStringList;
  i: Integer;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'BuildParentHeritage', tmoTiming);{$ENDIF}
  tvHierarchies.Items.BeginUpdate;
  Try
    If Assigned(Node) Then
      Begin
        NodeData := vstComponentTree.GetNodeData(Node);
        If Assigned(NodeData.FObject) And (TObject(NodeData.FObject) Is TWinControl) Then
          Begin
            Parent := TWinControl(NodeData.FObject).Parent;
            slList := TStringList.Create;
            Try
              slList.Add(TWinControl(NodeData.FObject).Name + ' : ' + TWinControl(NodeData.FObject).ClassName);
              While Parent <> Nil Do
                Begin
                  slList.Insert(0, Parent.Name + ' : ' + Parent.ClassName);
                  Parent := Parent.Parent;
                End;
              PNode := tvHierarchies.Items.AddChild(Nil, strParentage);
              For i := 0 To slList.Count - 1 Do
                Begin
                  PNode := tvHierarchies.Items.AddChild(PNode, slList[i]);
                  PNode.ImageIndex := Integer(tiPackage);
                  PNode.SelectedIndex := Integer(tiPackage);
                End;
            Finally
              slList.Free;
            End;
          End;
      End;
  Finally
    tvHierarchies.Items.EndUpdate;
  End;
End;

(**

  This is an on change event handler for the ComponentFilter edit control.

  @precon  None.
  @postcon Updates the last time the filter was changed.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.edtComponentFilterChange(Sender: TObject);

Begin
  FLastComponentFilterUpdate := GetTickCount;
End;

(**

  This method displays the form modally.

  @precon  None.
  @postcon The form is displayed (theming is disabled as it causes an AV in the IDE).

**)
Class Procedure TDGHIDEExplorerForm.Execute;

Var
  F : TDGHIDEExplorerForm;
  {$IFDEF DXE102}
  ITS : IOTAIDEThemingServices250;
  {$ENDIF}
  
Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod('TDGHIDEExplorerForm.Execute', tmoTiming);{$ENDIF}
  F := TDGHIDEExplorerForm.Create(Application.MainForm);
  Try
    {$IFDEF DXE102}
    If Supports(BorlandIDEServices, IOTAIDEThemingServices250, ITS) Then
      If ITS.IDEThemingEnabled Then
        Begin
          ITS.RegisterFormClass(TDGHIDEExplorerForm);
          ITS.ApplyTheme(F);
        End;
    {$ENDIF}
    F.ShowModal;
  Finally
    F.Free;
  End;
End;

(**

  This method filters the component tree based on the regular expression in the ComponentFilter edit
  control.

  @precon  None.
  @postcon Only the nodes with matching text (and their parents) are visible.

**)
Procedure TDGHIDEExplorerForm.FilterComponents;

ResourceString
  strRegularExpressionError = 'Regular Expression Error';

Var
  FilterRegEx: TRegEx;
  N, P: PVirtualNode;
  NodeData : PDIEObjectData;
  strFilterText : String;

Begin
  strFilterText := edtComponentFilter.Text;
  Try
    If strFilterText.Length > 0 Then
      FilterRegEx := TRegEx.Create(strFilterText, [roIgnoreCase, roCompiled, roSingleLine]);
  Except
    On E : ERegularExpressionError Do
      Begin
        TaskMessageDlg(strRegularExpressionError, E.Message, mtError, [mbOK], 0);
        edtComponentFilter.SetFocus;
        Exit;
      End;
  End;
  vstComponentTree.BeginUpdate;
  Try
    N := vstComponentTree.GetFirst;
    While Assigned(N) Do
      Begin
        If strFilterText.Length > 0 Then
          Begin
            NodeData := vstComponentTree.GetNodeData(N);
            vstComponentTree.IsVisible[N] := FilterRegEx.IsMatch(NodeData.FText);
            If vstComponentTree.IsVisible[N] Then
              Begin
                P := vstComponentTree.NodeParent[N];
                While Assigned(P) Do
                  Begin
                    vstComponentTree.IsVisible[P] := True;
                    P := vstComponentTree.NodeParent[P];
                  End;
              End;
          End Else
            vstComponentTree.IsVisible[N] := True;
        N := vstComponentTree.GetNext(N);
      End;
  Finally
    vstComponentTree.EndUpdate;
  End;
End;

(**

  This is an OnFormCreate Event Handler for the TDGHIDEExplorerForm class.

  @precon  None.
  @postcon Loads the applications settings.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.FormCreate(Sender: TObject);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'FormCreate', tmoTiming);{$ENDIF}
  LoadSettings;
  FProgressMgr := TDIEProgressMgr.Create(Self);
  vstComponentTree.NodeDataSize := SizeOf(TDIEObjectData);
  vstFields.NodeDataSize := SizeOf(TDIEFieldData);
  vstMethods.NodeDataSize := SizeOf(TDIEMethodData);
  vstProperties.NodeDataSize := SizeOf(TDIEPropertyData);
End;

(**

  This is an OnFormDestroy Event Handler for the TDGHIDEExplorerForm class.

  @precon  None.
  @postcon Saves the applications settings.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.FormDestroy(Sender: TObject);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'FormDestroy', tmoTiming);{$ENDIF}
  SaveSettings;
End;

(**

  This is an on form show event handler for the form.

  @precon  None.
  @postcon Builds the forms component tree.

  @note    Its MUCH MORE responsive here in the OnShow event than in the OnCreate event.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.FormShow(Sender: TObject);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'FormShow', tmoTiming);{$ENDIF}
  BuildFormComponentTree(Sender);
  pgcPropertiesMethodsAndEvents.ActivePageIndex := 0;
End;

(**

  This method iterates the IDE structure and populates the tree view.

  @precon  Node and Component must be valid instances.
  @postcon Each component of the parent component is added to the given node.

  @param   Node      as a PVirtualNode as a constant
  @param   Component as a TComponent as a constant

**)
Procedure TDGHIDEExplorerForm.GetComponents(Const Node: PVirtualNode; Const Component: TComponent);

Var
  i: Integer;
  NewNode: PVirtualNode;
  NodeData : PDIEObjectData;
  

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'GetComponents', tmoTiming);{$ENDIF}
  For i := 0 To Component.ComponentCount - 1 Do
    Begin
      NewNode := vstComponentTree.AddChild(Node);
      NodeData := vstComponentTree.GetNodeData(NewNode);
      NodeData.FText := Format('%s: %s', [
        Component.Components[i].Name,
        Component.Components[i].ClassName
      ]);
      NodeData.FObject := Component.Components[i];
      NodeData.FImageIndex := Integer(tiPackage);
      GetComponents(NewNode, Component.Components[i]);
    End;
End;

(**

  This method loads the applications settings from the registry.

  @precon  None.
  @postcon The applications settings are loaded from the regsitry.

**)
Procedure TDGHIDEExplorerForm.LoadSettings;

Const
  iDefaultColumnWidth = 100;
  iQuarter = 4;
  iHalf = 2;

Var
  i : Integer;
  lv: TListView;
  j: Integer;
  R: TRegIniFile;
  VST: TVirtualStringTree;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'LoadSettings', tmoTiming);{$ENDIF}
  R := TRegIniFile.Create(RegKey);
  Try
    Self.Top := R.ReadInteger(SectionName, strTopKey, (Application.MainForm.Height - Height) Div iHalf);
    Self.Left := R.ReadInteger(SectionName, strLeftKey, (Application.MainForm.Width - Width) Div iHalf);
    Self.Width := R.ReadInteger(SectionName, strWidthKey, Width);
    Self.Height := R.ReadInteger(SectionName, strHeightKey, Height);
    pnlTreePanel.Width := R.ReadInteger(SectionName, strTreeWidthKey, Width Div iQuarter);
    For i := 0 To ComponentCount - 1 Do BEGIN
      If Components[i] Is TListView Then
        Begin
          lv := Components[i] As TListView;
          For j := 0 To lv.Columns.Count - 1 Do
            lv.Columns[j].Width := R.ReadInteger(lv.Name, lv.Column[j].Caption, iDefaultColumnWidth);
        End;
      If Components[i] Is TVirtualStringTree Then
        Begin
          VST := Components[i] As TVirtualStringTree;
          For j := 0 To VST.Header.Columns.Count - 1 Do
            VST.Header.Columns[j].Width := R.ReadInteger(
              VST.Name,
              VST.Header.Columns[j].Text, 
              iDefaultColumnWidth
            );
        End;
    END;
  Finally
    R.Free;
  End;
End;

(**

  This method saves the applications settings to the registry.

  @precon  None.
  @postcon The applications settings are saved to the registry.

**)
Procedure TDGHIDEExplorerForm.SaveSettings;

Var
  i, j : Integer;
  lv : TListView;
  R: TRegIniFile;
  VST: TVirtualStringTree;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'SaveSettings', tmoTiming);{$ENDIF}
  R := TRegIniFile.Create(RegKey);
  Try
    R.WriteInteger(SectionName, strTopKey, Self.Top);
    R.WriteInteger(SectionName, strLeftKey, Self.Left);
    R.WriteInteger(SectionName, strWidthKey, Self.Width);
    R.WriteInteger(SectionName, strHeightKey, Self.Height);
    R.WriteInteger(SectionName, strTreeWidthKey, pnlTreePanel.Width);
    For i := 0 To ComponentCount - 1 Do BEGIN
      If Components[i] Is TListView Then
        Begin
          lv := Components[i] As TListView;
          For j := 0 To lv.Columns.Count - 1 Do
            R.WriteInteger(lv.Name, lv.Column[j].Caption, lv.Columns[j].Width);
        End;
      If Components[i] Is TVirtualStringTree Then
        Begin
          VST := Components[i] As TVirtualStringTree;
          For j := 0 To VST.Header.Columns.Count - 1 Do
            R.WriteInteger(VST.Name, VST.Header.Columns[j].Text, VST.Header.Columns[j].Width);
        End;
    END;
  Finally
    R.Free;
  End;
End;

(**

  This is a timer event handler for filtering the component tree and pfields, method properties, etc.

  @precon  None.
  @postcon The Component tree and / or Fields, Method Properties, etc are filtered.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.tmFilterTimerTimer(Sender: TObject);

Const
  iUpdateInterval = 250;

Begin
  If (FLastComponentFilterUpdate > 0) And (GetTickCount > FLastComponentFilterUpdate + iUpdateInterval) Then
    Try
      tmFilterTimer.Enabled := False;
      Try
        FilterComponents;
      Finally
        tmFilterTimer.Enabled := True;
      End;
    Finally
      FLastComponentFilterUpdate := 0;
    End;
End;

(**

  This is an on compare event handler for the component treeview.

  @precon  None.
  @postcon Sorts the component tree by the text.

  @param   Sender as a TBaseVirtualTree
  @param   Node1  as a PVirtualNode
  @param   Node2  as a PVirtualNode
  @param   Column as a TColumnIndex
  @param   Result as an Integer as a reference

**)
Procedure TDGHIDEExplorerForm.vstComponentTreeCompareNodes(Sender: TBaseVirtualTree; Node1, Node2:
  PVirtualNode; Column: TColumnIndex; Var Result: Integer);

Var
  NodeData1, NodeData2 : PDIEObjectData;

Begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);
  Result := Comparetext(NodeData1.FText, NodeData2.FText);
End;

(**

  This is the tree views on change event handler. It gets the item selectds properties and displays them.

  @precon  None.
  @postcon Clears the list views and re-populates them with data for the new selected node.

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode
  @param   Column as a TColumnIndex

**)
Procedure TDGHIDEExplorerForm.vstComponentTreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);

ResourceString
  strClearingExistingData = 'Clearing existing data...';
  strFindingOLDProperties = 'Finding OLD properties...';
  strBuildingHierarachies = 'Building Hierarachies...';

Const
  iProgressSteps = 6;

Var
  NodeData: PDIEObjectData;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'tvComponentTreeChange', tmoTiming); {$ENDIF}
  FProgressMgr.Initialise(iProgressSteps);
  Try
    FProgressMgr.Show(strClearingExistingData);
    vstFields.Clear;
    vstMethods.Clear;
    vstProperties.Clear;
    lvEvents.Clear;
    lvOldProperties.Clear;
    If Assigned(Node) Then
      Begin
        NodeData := vstComponentTree.GetNodeData(Node);
        If Assigned(NodeData.FObject) Then
          Begin
            TIDEExplorerNEWRTTI.ProcessObjectFields(NodeData.FObject, vstFields, FProgressMgr);
            TIDEExplorerNEWRTTI.ProcessObjectMethods(NodeData.FObject, vstMethods, FProgressMgr);
            TIDEExplorerNEWRTTI.ProcessObjectProperties(NodeData.FObject, vstProperties, FProgressMgr);
            TIDEExplorerNEWRTTI.ProcessObject(NodeData.FObject, lvEvents, FProgressMgr);
            FProgressMgr.Update(strFindingOLDProperties);
            TIDEExplorerOLDRTTI.ProcessOldProperties(lvOldProperties, NodeData.FObject);
          End;
      End;
    FProgressMgr.Update(strBuildingHierarachies);
    BuildComponentHeritage(Node);
    BuildParentHeritage(Node);
    tvHierarchies.FullExpand;
  Finally
    FProgressMgr.Hide;
  End;
End;

(**

  This is an on free node event handler for the component treeview.

  @precon  None.
  @postcon Frees the memory used by the node (managed types like strings).

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode

**)
Procedure TDGHIDEExplorerForm.vstComponentTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);

Var
  NodeData : PDIEObjectData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Finalize(NodeData^);
End;

(**

  This is an on get image index event handler for the component treeview.

  @precon  None.
  @postcon Returns the image index for the node.

  @param   Sender     as a TBaseVirtualTree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a reference
  @param   ImageIndex as a TImageIndex as a reference

**)
Procedure TDGHIDEExplorerForm.vstComponentTreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);
  
Var
  NodeData : PDIEObjectData;
  
Begin
  If Kind In [ikNormal..ikSelected] Then
    Begin
      NodeData := Sender.GetNodeData(Node);
      ImageIndex := NodeData.FImageIndex;
    End;
End;

(**

  This is an on Get Text event handler for the Components treeview.

  @precon  None.
  @postcon Returns the text for the node.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
Procedure TDGHIDEExplorerForm.vstComponentTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column:
  TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Var
  NodeData : PDIEObjectData;

Begin
  NodeData := Sender.GetNodeData(Node);
  CellText := NodeData.FText;
End;

(**

  This is an on free event handler for the Fields treeview.

  @precon  None.
  @postcon Finalises the managed types in the treeview node.

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode

**)
Procedure TDGHIDEExplorerForm.vstFieldsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);

Var
  NodeData : PDIEFieldData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Finalize(NodeData^);
End;

(**

  This is an on Get Image Index event handler for the Fields treeview.

  @precon  None.
  @postcon Returns the indexes for the State and image indexes.

  @param   Sender     as a TBaseVirtualTree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a reference
  @param   ImageIndex as a TImageIndex as a reference

**)
Procedure TDGHIDEExplorerForm.vstFieldsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind:
  TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);

Var
  NodeData : PDIEFieldData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  If Column = 0 Then
    Case Kind Of
      ikNormal,
      ikSelected,
      ikOverlay:  ImageIndex := NodeData.FVisibilityIndex;
      ikState:    ImageIndex := NodeData.FImageIndex;
    End;
End;

(**

  This is an on get text event handler for the Fields treeview.

  @precon  None.
  @postcon Provide the correct text for the field from the nodes record.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
Procedure TDGHIDEExplorerForm.vstFieldsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column:
  TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Type
  TDIEFieldFields = (ffVisibility, ffQualifiedName, ffType, ffOffset, ffKind, ffSize, ffValue);
  
Var
  NodeData : PDIEFieldData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Case TDIEFieldFields(Column) Of
    ffVisibility:    CellText := NodeData.FVisibility;  
    ffQualifiedName: CellText := NodeData.FQualifiedName;
    ffType:          CellText := NodeData.FType;  
    ffOffset:        CellText := NodeData.FOffset;  
    ffKind:          CellText := NodeData.FKind;  
    ffSize:          CellText := NodeData.FSize;  
    ffValue:         CellText := NodeData.FValue;  
  End;
End;

(**

  This is an on free event handler for the Methods treeview.

  @precon  None.
  @postcon Finalises the managed types in the treeview node.

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode

**)
Procedure TDGHIDEExplorerForm.vstMethodsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);

Var
  NodeData : PDIEMethodData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Finalize(NodeData^);
End;

(**

  This is an on Get Image Index event handler for the Methods treeview.

  @precon  None.
  @postcon Returns the indexes for the State and image indexes.

  @param   Sender     as a TBaseVirtualTree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a reference
  @param   ImageIndex as a TImageIndex as a reference

**)
Procedure TDGHIDEExplorerForm.vstMethodsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);

Var
  NodeData : PDIEMethodData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  If Column = 0 Then
    Case Kind Of
      ikNormal,
      ikSelected,
      ikOverlay:  ImageIndex := NodeData.FVisibilityIndex;
      ikState:    ImageIndex := NodeData.FImageIndex;
    End;
End;

(**

  This is an on get text event handler for the Methods treeview.

  @precon  None.
  @postcon Provide the correct text for the method from the nodes record.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
Procedure TDGHIDEExplorerForm.vstMethodsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column:
  TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Type
  TDIEMethodFields = (mfVisibility, mfQualifiedName, mfType, mfSignature);
  
Var
  NodeData : PDIEMethodData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Case TDIEMethodFields(Column) Of
    mfVisibility:    CellText := NodeData.FVisibility;
    mfQualifiedName: CellText := NodeData.FQualifiedName;
    mfType:          CellText := NodeData.FType;
    mfSignature:     CellText := NodeData.FSignature;
  End;
End;

(**

  This is an on free event handler for the Properties treeview.

  @precon  None.
  @postcon Finalises the managed types in the treeview node.

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode

**)
Procedure TDGHIDEExplorerForm.vstPropertiesFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);

Var
  NodeData : PDIEPropertyData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Finalize(NodeData^);
End;

(**

  This is an on Get Image Index event handler for the Propeties treeview.

  @precon  None.
  @postcon Returns the indexes for the State and image indexes.

  @param   Sender     as a TBaseVirtualTree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a reference
  @param   ImageIndex as a TImageIndex as a reference

**)
Procedure TDGHIDEExplorerForm.vstPropertiesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);

Var
  NodeData : PDIEPropertyData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  If Column = 0 Then
    Case Kind Of
      ikNormal,
      ikSelected,
      ikOverlay:  ImageIndex := NodeData.FVisibilityIndex;
      ikState:    ImageIndex := NodeData.FImageIndex;
    End;
End;

(**

  This is an on get text event handler for the Properties treeview.

  @precon  None.
  @postcon Provide the correct text for the properties from the nodes record.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
Procedure TDGHIDEExplorerForm.vstPropertiesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column:
  TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Type
  TDIEPropertyFields = (pfVisibility, pfQualifiedName, pfType, pfAccess, pfKind, pfSize, pfValue);
  
Var
  NodeData : PDIEPropertyData;
  
Begin
  NodeData := Sender.GetNodeData(Node);
  Case TDIEPropertyFields(Column) Of
    pfVisibility:    CellText := NodeData.FVisibility;  
    pfQualifiedName: CellText := NodeData.FQualifiedName;
    pfType:          CellText := NodeData.FType;  
    pfAccess:        CellText := NodeData.FAccess;  
    pfKind:          CellText := NodeData.FKind;  
    pfSize:          CellText := NodeData.FSize;  
    pfValue:         CellText := NodeData.FValue;  
  End;
End;

End.
