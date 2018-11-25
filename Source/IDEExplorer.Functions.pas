(**
  
  This module contains common functions to be used throughout the plug-in.

  @Author  David Hoyle
  @Version 1.0
  @Date    25 Nov 2018
  
**)
Unit IDEExplorer.Functions;

Interface

Uses
  IDEExplorer.Types;

  Procedure BuildNumber(Var VersionInfo: TVersionInfo);

Implementation

Uses
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

End.
