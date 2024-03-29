# IDE Explorer

Author:   David Hoyle (davidghoyle@gmail.com / [https://github.com/DGH2112](https://github.com/DGH2112))

Version:  2.4

Date:     04 Jan 2022

## Overview

This is a RAD Studio wizard / expert / plug-in which allows you to browse the fields, methods, properties and events of the internal elements of the IDE (forms and components as of now but possibly classes in the future).

## Usage

IDE Explorer can be accessed from the main IDE Help menu (since Delphi 10.0 Seattle there is a "Help Wizards" sub-menu)

## Current Limitations

Current this expert only runs once at start-up so any new windows created after
this point will not be adjusted however you can manually run the expert as described above.

## Source Code and Binaries

Please note that this project has changed from a BPL to a DLL to make maintenance of multiple version for different IDEs easier (single project for all versions).

You can download a binary of this project if you don't want to compile it yourself from the web page above.

## Miscellaneous

You can install [Delphinus package manager](https://github.com/Memnarch/Delphinus/wiki/Installing-Delphinus) and then install IDE Explorer there. (Delphinus-Support)
