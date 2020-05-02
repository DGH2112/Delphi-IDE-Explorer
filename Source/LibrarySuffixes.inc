(**

  An include unit to define library suffixes for all the version of RAD Studio.

  @Version 1.019
  @Date    19 Apr 2020
  @Author  David Hoyle

**)

{$IFDEF DXE104}
  {$LIBSUFFIX 'XE104'}
{$ELSE}
  {$IFDEF DXE103}
    {$LIBSUFFIX 'XE103'}
  {$ELSE}
    {$IFDEF DXE102}
      {$LIBSUFFIX 'XE102'}
    {$ELSE}
      {$IFDEF DXE101}
        {$LIBSUFFIX 'XE101'}
      {$ELSE}
        {$IFDEF DXE100}
          {$LIBSUFFIX 'XE10'}
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

