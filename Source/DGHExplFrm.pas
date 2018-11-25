(**

  This module contains the explorer form interface.

  @Date    11 Mar 2017
  @Version 2.0
  @Author  David Hoyle

**)
Unit DGHExplFrm;

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
  ImgList, System.ImageList;

Type
  (** This class represent a form for displaying the internal published elements of the
      IDE. **)
  TDGHIDEExplorerForm = Class(TForm)
    tvComponentTree: TTreeView;
    ilImageList1: TImageList;
    splSplitter1: TSplitter;
    ilTypeKindImages: TImageList;
    pgcPropertiesMethodsAndEvents: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    lvOldProperties: TListView;
    tvHierarchies: TTreeView;
    tabNewProperties: TTabSheet;
    lvProperties: TListView;
    tabFields: TTabSheet;
    lvFields: TListView;
    tabEvents: TTabSheet;
    lvEvents: TListView;
    tabMethods: TTabSheet;
    lvMethods: TListView;
    ilScope: TImageList;
    Procedure BuildFormComponentTree(Sender: TObject);
    Procedure tvComponentTreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  Strict Private
    {Private declarations}
    Procedure GetComponents(Node: TTreeNode; Component: TComponent);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure BuildComponentHeritage(Node : TTreeNode);
    Procedure BuildParentHeritage(Node : TTreeNode);
  Strict Protected
  Public
    {Public declarations}
  End;

Implementation

{$R *.DFM}


Uses
  Registry,
  DGHRTTIFunctions,
  DGHOLDRTTIFunctions;

Const
  (** This is the root registration jey for this applications settings. **)
  RegKey = '\Software\Seasons Fall';
  (** This is the section name for the applications settings in the registry **)
  SectionName = 'DGH IDE Explorer';

(**

  This is an OnFormCreate Event Handler for the TDGHIDEExplorerForm class.

  @precon  None.
  @postcon Loads the applications settings.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.FormCreate(Sender: TObject);

Begin
  LoadSettings;
End;

(**

  This is an OnFormDestroy Event Handler for the TDGHIDEExplorerForm class.

  @precon  None.
  @postcon Saves the applications settings.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.FormDestroy(Sender: TObject);

Begin
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
  BuildFormComponentTree(Sender);
  pgcPropertiesMethodsAndEvents.ActivePageIndex := 0;
End;

(**

  This is the forms on show event. It initialises the tree view.

  @precon  None.
  @postcon Iterates through the forms and datamodules and adds them to the tree view.

  @param   Sender as a TObject

**)
Procedure TDGHIDEExplorerForm.BuildFormComponentTree(Sender: TObject);

  (**

    This method adds a form/datamodule to a root node in the tree and then calls
    GetComponents to get the forms components.

    @precon  ParentNode and ScreenForm must be valid instances.
    @postcon Adds a form/datamodule to a root node in the tree and then calls
             GetComponents to get the forms components.

    @param   ParentNode as a TTreeNode
    @param   ScreenForm as a TComponent

  **)
  Procedure IterateForms(ParentNode : TTreeNode; ScreenForm : TComponent);

  Var
    Item: TTreeNode;

  Begin
    Item := tvComponentTree.Items.AddChildObject(ParentNode, ScreenForm.Name + ' : ' +
      ScreenForm.ClassName, ScreenForm);
    Item.ImageIndex := 2;
    Item.SelectedIndex := 2;
    ProcessClass(tvComponentTree, Item, ScreenForm);
    GetComponents(Item, ScreenForm);
  End;

Var
  i: Integer;
  nApplication : TTreeNode;
  nScreen : TTreeNode;
  N: TTreeNode;

Begin
  With tvComponentTree Do
    Begin
      Items.BeginUpdate;
      Try
        FoundClasses.Clear;
        nApplication := tvComponentTree.Items.AddChildObject(Nil, 'Application', Application);
        ProcessClass(tvComponentTree, nApplication, Application);
        nScreen := tvComponentTree.Items.AddChildObject(Nil, 'Screen', Screen);
        ProcessClass(tvComponentTree, nScreen, Screen);
        N := tvComponentTree.Items.AddChild(nScreen, 'Forms');
        For i := 0 To Screen.FormCount - 1 Do
          IterateForms(N, Screen.Forms[i]);
        N := tvComponentTree.Items.AddChild(nScreen, 'CustomForms');
        For i := 0 To Screen.CustomFormCount - 1 Do
          IterateForms(N, Screen.CustomForms[i]);
        N := tvComponentTree.Items.AddChild(nScreen, 'DataModules');
        For i := 0 To Screen.DataModuleCount - 1 Do
         IterateForms(N, Screen.DataModules[i]);
        nApplication.Expand(False);
        nScreen.Expand(False);
        tvComponentTree.AlphaSort(True);
      Finally
        Items.EndUpdate;
      End;
    End;
End;

(**

  This method iterates the IDE structure and populates the tree view.

  @precon  Node and Component must be valid instances.
  @postcon Each component of the parent component is added to the given node.

  @param   Node      as a TTreeNode
  @param   Component as a TComponent

**)
Procedure TDGHIDEExplorerForm.GetComponents(Node: TTreeNode; Component: TComponent);

Var
  i: Integer;
  NewNode: TTreeNode;

Begin
  For i := 0 To Component.ComponentCount - 1 Do
    Begin
      NewNode := tvComponentTree.Items.AddChild(Node, Component.Components[i].Name + ' : ' +
        Component.Components[i].ClassName);
      NewNode.Data := Pointer(Component.Components[i]);
      NewNode.ImageIndex := 3;
      NewNode.SelectedIndex := 3;
      GetComponents(NewNode, Component.Components[i]);
    End;
End;

(**

  This method loads the applications settings from the registry.

  @precon  None.
  @postcon The applications settings are loaded from the regsitry.

**)
Procedure TDGHIDEExplorerForm.LoadSettings;

Var
  i : Integer;
  lv: TListView;
  j: Integer;

Begin
  With TRegIniFile.Create(RegKey) Do
    Try
      Self.Top := ReadInteger(SectionName, 'Top', 200);
      Self.Left := ReadInteger(SectionName, 'Left', 200);
      Self.Width := ReadInteger(SectionName, 'Width', 450);
      Self.Height := ReadInteger(SectionName, 'Height', 300);
      tvComponentTree.Width := ReadInteger(SectionName, 'TreeWidth', 200);
      For i := 0 To ComponentCount - 1 Do
        If Components[i] Is TListView Then
          Begin
            lv := Components[i] As TListView;
            For j := 0 To lv.Columns.Count - 1 Do
              lv.Columns[j].Width := ReadInteger(lv.Name, lv.Column[j].Caption, 100);
          End;
    Finally
      Free;
    End;
End;

(**

  This method builds a hierarchical list of the components heritage.

  @precon  Node must be a vldi instance.
  @postcon The heritage tree is output to the hierarchies tab.

  @param   Node as a TTreeNode

**)
Procedure TDGHIDEExplorerForm.BuildComponentHeritage(Node : TTreeNode);

Var
  PNode: TTreeNode;
  ClassRef: TClass;
  strList: TStringList;
  i: Integer;

Begin
  tvHierarchies.Items.BeginUpdate;
  Try
    If (Node <> Nil) And (Node.Data <> Nil) Then
      Begin
        ClassRef := TComponent(Node.Data).ClassType;
        strList := TStringList.Create;
        Try
          While ClassRef <> Nil Do
            Begin
              strList.Insert(0, ClassRef.ClassName);
              ClassRef := ClassRef.ClassParent;
            End;
          PNode := tvHierarchies.Items.AddChild(Nil, 'Heritage');
          For i := 0 To strList.Count - 1 Do
            Begin
              PNode := tvHierarchies.Items.AddChild(PNode, strList[i]);
              PNode.ImageIndex := 3;
              PNode.SelectedIndex := 3;
            End;
        Finally
          strList.Free;
        End;
      End;
  Finally
    tvHierarchies.Items.EndUpdate;
  End;
End;

(**

  This method outputs the parent hierarchy of the WinControl (if its a WinControl).

  @precon  Node must be a vldi instance.
  @postcon The parent hierarchy is outuput to the hierarchies tab.

  @param   Node as a TTreeNode

**)
Procedure TDGHIDEExplorerForm.BuildParentHeritage(Node : TTreeNode);

Var
  PNode: TTreeNode;
  Parent: TWinControl;
  slList: TStringList;
  i: Integer;

Begin
  tvHierarchies.Items.BeginUpdate;
  Try
    If (Node <> Nil) And (Node.Data <> Nil) And (TObject(Node.Data) Is TWinControl) Then
      Begin
        Parent := TWinControl(Node.Data).Parent;
        slList := TStringList.Create;
        Try
          slList.Add(TWinControl(Node.Data).Name + ' : ' + TWinControl(Node.Data).ClassName);
          While Parent <> Nil Do
            Begin
              slList.Insert(0, Parent.Name + ' : ' + Parent.ClassName);
              Parent := Parent.Parent;
            End;
          PNode := tvHierarchies.Items.AddChild(Nil, 'Parentage');
          For i := 0 To slList.Count - 1 Do
            Begin
              PNode := tvHierarchies.Items.AddChild(PNode, slList[i]);
              PNode.ImageIndex := 3;
              PNode.SelectedIndex := 3;
            End;
        Finally
          slList.Free;
        End;
      End;
  Finally
    tvHierarchies.Items.EndUpdate;
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

Begin
  With TRegIniFile.Create(RegKey) Do
    Try
      WriteBool(SectionName, 'Visible', Visible);
      WriteInteger(SectionName, 'Top', Self.Top);
      WriteInteger(SectionName, 'Left', Self.Left);
      WriteInteger(SectionName, 'Width', Self.Width);
      WriteInteger(SectionName, 'Height', Self.Height);
      WriteInteger(SectionName, 'TreeWidth', tvComponentTree.Width);
      For i := 0 To ComponentCount - 1 Do
        If Components[i] Is TListView Then
          Begin
            lv := Components[i] As TListView;
            For j := 0 To lv.Columns.Count - 1 Do
              WriteInteger(lv.Name, lv.Column[j].Caption, lv.Columns[j].Width);
          End;
    Finally
      Free;
    End;
End;

(**

  This is the tree views on change event handler. It gets the item selecteds properties
  and displays them.

  @precon  None.
  @postcon Clears the list views and re-populates them with data for the new selected
           node.

  @param   Sender as a TObject
  @param   Node   as a TTreeNode

**)
Procedure TDGHIDEExplorerForm.tvComponentTreeChange(Sender: TObject; Node: TTreeNode);

Begin
  lvFields.Clear;
  lvMethods.Clear;
  lvProperties.Clear;
  lvEvents.Clear;
  lvOldProperties.Clear;
  If (Node <> Nil) And (Node.Data <> Nil) Then
    Begin
      ProcessObject(Node.Data, lvFields, lvMethods, lvProperties, lvEvents);
      ProcessOldProperties(lvOldProperties, Node.Data);
    End;
  tvHierarchies.Items.Clear;
  BuildComponentHeritage(Node);
  BuildParentHeritage(Node);
  tvHierarchies.FullExpand;
End;

End.
