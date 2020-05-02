(**
  
  This module contains common functions to be used throughout the plug-in.

  @Author  David Hoyle
  @Version 1.091
  @Date    02 May 2020
  
  @license

    IDE Explorer - an Opren Tools API plug-in for RAD Studio which allows you to
    browse the internals of the RAD Studio IDE.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/Delphi-IDE-Explorer)

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
Unit IDEExplorer.Functions;

Interface

Uses
  IDEExplorer.Types;

  Procedure BuildNumber(Var VersionInfo: TVersionInfo);
  Function FatalValue(Const strPropertyName: String): Boolean;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  Windows;

(**

  This method extracts the build number from the executables resource.

  @precon  None.
  @postcon the build information is placed into the passed version record.

  @param   VersionInfo as a TVersionInfo as a reference

**)
Procedure BuildNumber(Var VersionInfo: TVersionInfo);

Const
  iShiftRight = 16;
  iWordMask = $FFFF;

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  strBuffer: Array [0 .. MAX_PATH] Of Char;

Begin
  GetModuleFileName(hInstance, strBuffer, MAX_PATH);
  VerInfoSize := GetFileVersionInfoSize(strBuffer, Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(strBuffer, 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        VersionInfo.iMajor := VerValue^.dwFileVersionMS Shr iShiftRight;
        VersionInfo.iMinor := VerValue^.dwFileVersionMS And iWordMask;
        VersionInfo.iBugfix := VerValue^.dwFileVersionLS Shr iShiftRight;
        VersionInfo.iBuild := VerValue^.dwFileVersionLS And iWordMask;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End;
End;

(**

  This function test whether the given name is one the the predetermined names that fail to return a
  value when queried.

  @precon  None.
  @postcon Returns true if the given name is one of the predetermined names that fail to return a value 
           in the IDE.

  @param   strPropertyName as a String as a constant
  @return  a Boolean

**)
Function FatalValue(Const strPropertyName: String): Boolean;

Const
  strFatalPropertyNames : Array[1..3] Of String = (
    'COMComponent',
    'COMObject',
    'InteropWindowHandle'
  );

Var
  iFirst, iMid, iLast : Integer;
  iCompareResult: Integer;

Begin
  Result := False;
  iFirst := Low(strFatalPropertyNames);
  iLast := High(strFatalPropertyNames);
  While iFirst <= iLast Do
    Begin
      iMid := (iFirst + iLast) Div 2;
      iCompareResult := CompareText(strPropertyName, strFatalPropertyNames[iMid]);
      Case iCompareResult Of
        -MaxInt..-1: iLast := Pred(iMid);
        0:
          Begin
            Result := True;
            Break;
          End;
        1..MaxInt: iFirst := Succ(iMid);
      End;

    End;
End;

End.
