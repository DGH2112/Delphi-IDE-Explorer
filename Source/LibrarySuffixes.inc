(**

  An include unit to define library suffixes for all the version of RAD Studio.

  @Version 1.131
  @Date    04 Jan 2022
  @Author  David Hoyle

  @license

    IDE Explorer - an Open Tools API plug-in for RAD Studio which allows you to
    browse the internals of the RAD Studio IDE.

    Copyright (C) 2020 David Hoyle (https://github.com/DGH2112/Delphi-IDE-Explorer)

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

{$IFDEF RS110}
  {$LIBSUFFIX 'RS110'}
{$ELSE}
  {$IFDEF RS104}
    {$LIBSUFFIX 'RS104'}
  {$ELSE}
    {$IFDEF RS103}
      {$LIBSUFFIX 'RS103'}
    {$ELSE}
      {$IFDEF RS102}
        {$LIBSUFFIX 'RS102'}
      {$ELSE}
        {$IFDEF RS101}
          {$LIBSUFFIX 'RS101'}
        {$ELSE}
          {$IFDEF RS100}
            {$LIBSUFFIX 'RS100'}
          {$ELSE}
            {$IFDEF DXE80}
              {$LIBSUFFIX 'XE8'}
            {$ELSE}
              {$IFDEF DXE70}
                {$LIBSUFFIX 'XE7'}
              {$ELSE}
                {$IFDEF DXE60}
                  {$LIBSUFFIX 'XE6'}
                {$ELSE}
                  {$IFDEF DXE50}
                    {$LIBSUFFIX 'XE5'}
                  {$ELSE}
                    {$IFDEF DXE40}
                      {$LIBSUFFIX 'XE4'}
                    {$ELSE}
                      {$IFDEF DXE30}
                        {$LIBSUFFIX 'XE3'}
                      {$ELSE}
                        {$IFDEF DXE20}
                          {$LIBSUFFIX 'XE2'}
                        {$ELSE}
                          {$IFDEF DXE00}
                            {$LIBSUFFIX 'XE'}
                          {$ELSE}
                            {$IFDEF D2010}
                              {$LIBSUFFIX '2010'}
                            {$ELSE}
                              {$IFDEF D2009}
                                {$LIBSUFFIX '2009'}
                              {$ELSE}
                                {$IFDEF D2007}
                                  {$LIBSUFFIX '2007'}
                                {$ELSE}
                                  {$IFDEF D2006}
                                    {$LIBSUFFIX '2006'}
                                  {$ELSE}
                                    {$MESSAGE ERROR 'The Condition Definitions need to be updated!!!!!'}
                                  {$ENDIF}
                                {$ENDIF}
                              {$ENDIF}
                            {$ENDIF}
                          {$ENDIF}
                        {$ENDIF}
                      {$ENDIF}
                    {$ENDIF}
                  {$ENDIF}
                {$ENDIF}
              {$ENDIF}
            {$ENDIF}
          {$ENDIF}
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

