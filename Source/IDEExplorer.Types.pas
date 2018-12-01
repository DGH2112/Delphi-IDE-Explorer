(**
  
  This module contains simple types for use throughout the plug-in.

  @Author  David Hoyle
  @Version 1.0
  @Date    25 Nov 2018
  
**)
Unit IDEExplorer.Types;

Interface

Type
  (** A record to store the version information for the BPL. **)
  TVersionInfo = Record
    iMajor: Integer;
    iMinor: Integer;
    iBugfix: Integer;
    iBuild: Integer;
  End;

Implementation

End.
