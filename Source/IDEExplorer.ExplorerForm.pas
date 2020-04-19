(**

  This module contains the explorer form interface.

  @Date    19 Apr 2020
  @Version 2.003
  @Author  David Hoyle

  @todo    Add a progress bar

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
  ImgList;

{$INCLUDE CompilerDefinitions.inc}

Type
  (** This class represent a form for displaying the internal published elements of the IDE. **)
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
    Procedure GetComponents(Const Node: TTreeNode; Const Component: TComponent);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure BuildComponentHeritage(Const Node : TTreeNode);
    Procedure BuildParentHeritage(Const Node : TTreeNode);
  Strict Protected
  Public
    Class Procedure Execute;
  End;

Implementation

{$R *.DFM}


Uses
  ToolsAPI,
  Registry,
  IDEExplorer.RTTIFunctions,
  IDEExplorer.OLDRTTIFunctions;

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

  @param   Node as a TTreeNode as a constant

**)
Procedure TDGHIDEExplorerForm.BuildComponentHeritage(Const Node : TTreeNode);

ResourceString
  strHeritage = 'Heritage';

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

    @param   ParentNode as a TTreeNode as a constant
    @param   ScreenForm as a TComponent as a constant
    @param   eTreeImage as a TIDEExplorerTreeImage as a constant

  **)
  Procedure IterateForms(Const ParentNode : TTreeNode; Const ScreenForm : TComponent;
    Const eTreeImage : TIDEExplorerTreeImage);

  Var
    Item: TTreeNode;

  Begin
    Item := tvComponentTree.Items.AddChildObject(ParentNode, ScreenForm.Name + ' : ' +
      ScreenForm.ClassName, ScreenForm);
    Item.ImageIndex := Integer(eTreeImage);
    Item.SelectedIndex := Integer(eTreeImage);
    TIDEExplorerNEWRTTI.ProcessClass(tvComponentTree, Item, ScreenForm);
    GetComponents(Item, ScreenForm);
  End;

ResourceString
  strApplication = 'Application';
  strScreen = 'Screen';
  strForms = 'Forms';
  strCustomForms = 'CustomForms';
  strDataModules = 'DataModules';

Var
  i: Integer;
  nApplication : TTreeNode;
  nScreen : TTreeNode;
  N: TTreeNode;

Begin
  tvComponentTree.Items.BeginUpdate;
  Try
    FoundClasses.Clear;
    nApplication := tvComponentTree.Items.AddChildObject(Nil, strApplication, Application);
    TIDEExplorerNEWRTTI.ProcessClass(tvComponentTree, nApplication, Application);
    nScreen := tvComponentTree.Items.AddChildObject(Nil, strScreen, Screen);
    TIDEExplorerNEWRTTI.ProcessClass(tvComponentTree, nScreen, Screen);
    N := tvComponentTree.Items.AddChild(nScreen, strForms);
    N.ImageIndex := Integer(tiForms);
    N.SelectedIndex := Integer(tiForms);
    For i := 0 To Screen.FormCount - 1 Do
      IterateForms(N, Screen.Forms[i], tiForm);
    N := tvComponentTree.Items.AddChild(nScreen, strCustomForms);
    N.ImageIndex := Integer(tiForms);
    N.SelectedIndex := Integer(tiForms);
    For i := 0 To Screen.CustomFormCount - 1 Do
      IterateForms(N, Screen.CustomForms[i], tiForm);
    N := tvComponentTree.Items.AddChild(nScreen, strDataModules);
    N.ImageIndex := Integer(tiDataModules);
    N.SelectedIndex := Integer(tiDataModules);
    For i := 0 To Screen.DataModuleCount - 1 Do
      IterateForms(N, Screen.DataModules[i], tiDataModule);
    nApplication.Expand(False);
    nScreen.Expand(False);
    tvComponentTree.AlphaSort(True);
  Finally
    tvComponentTree.Items.EndUpdate;
  End;
End;

(**

  This method outputs the parent hierarchy of the WinControl (if its a WinControl).

  @precon  Node must be a vldi instance.
  @postcon The parent hierarchy is outuput to the hierarchies tab.

  @param   Node as a TTreeNode as a constant

**)
Procedure TDGHIDEExplorerForm.BuildParentHeritage(Const Node : TTreeNode);

ResourceString
  strParentage = 'Parentage';

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
  Finally
    tvHierarchies.Items.EndUpdate;
  End;
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

  This method iterates the IDE structure and populates the tree view.

  @precon  Node and Component must be valid instances.
  @postcon Each component of the parent component is added to the given node.

  @param   Node      as a TTreeNode as a constant
  @param   Component as a TComponent as a constant

**)
Procedure TDGHIDEExplorerForm.GetComponents(Const Node: TTreeNode; Const Component: TComponent);

Var
  i: Integer;
  NewNode: TTreeNode;

Begin
  For i := 0 To Component.ComponentCount - 1 Do
    Begin
      NewNode := tvComponentTree.Items.AddChild(Node, Component.Components[i].Name + ' : ' +
        Component.Components[i].ClassName);
      NewNode.Data := Pointer(Component.Components[i]);
      NewNode.ImageIndex := Integer(tiPackage);
      NewNode.SelectedIndex := Integer(tiPackage);
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

Begin
  R := TRegIniFile.Create(RegKey);
  Try
    Self.Top := R.ReadInteger(SectionName, strTopKey, (Application.MainForm.Height - Height) Div iHalf);
    Self.Left := R.ReadInteger(SectionName, strLeftKey, (Application.MainForm.Width - Width) Div iHalf);
    Self.Width := R.ReadInteger(SectionName, strWidthKey, Width);
    Self.Height := R.ReadInteger(SectionName, strHeightKey, Height);
    tvComponentTree.Width := R.ReadInteger(SectionName, strTreeWidthKey, Width Div iQuarter);
    For i := 0 To ComponentCount - 1 Do
      If Components[i] Is TListView Then
        Begin
          lv := Components[i] As TListView;
          For j := 0 To lv.Columns.Count - 1 Do
            lv.Columns[j].Width := R.ReadInteger(lv.Name, lv.Column[j].Caption, iDefaultColumnWidth);
        End;
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

Begin
  R := TRegIniFile.Create(RegKey);
  Try
    R.WriteInteger(SectionName, strTopKey, Self.Top);
    R.WriteInteger(SectionName, strLeftKey, Self.Left);
    R.WriteInteger(SectionName, strWidthKey, Self.Width);
    R.WriteInteger(SectionName, strHeightKey, Self.Height);
    R.WriteInteger(SectionName, strTreeWidthKey, tvComponentTree.Width);
    For i := 0 To ComponentCount - 1 Do
      If Components[i] Is TListView Then
        Begin
          lv := Components[i] As TListView;
          For j := 0 To lv.Columns.Count - 1 Do
            R.WriteInteger(lv.Name, lv.Column[j].Caption, lv.Columns[j].Width);
        End;
  Finally
    R.Free;
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
      TIDEExplorerNEWRTTI.ProcessObject(Node.Data, lvFields, lvMethods, lvProperties, lvEvents);
      TIDEExplorerOLDRTTI.ProcessOldProperties(lvOldProperties, Node.Data);
    End;
  tvHierarchies.Items.Clear;
  BuildComponentHeritage(Node);
  BuildParentHeritage(Node);
  tvHierarchies.FullExpand;
End;

End.
