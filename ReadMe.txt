SimpleDrillDown

================================================================================
DESCRIPTION:

This application shows how to create a basic drill down interface. The first screen shows a list of plays. When the user selects a play, the application displays on a second screen a list of the main characters and other data about the play. Both screens use a table view. The first list is in the "plain" style to show a standard list; the second is in the grouped style that you can use to lay out detail information.

================================================================================
BUILD REQUIREMENTS:

Mac OS X 10.5.3, Xcode 3.1, iPhone OS 2.0

================================================================================
RUNTIME REQUIREMENTS:

Mac OS X 10.5.3, iPhone OS 2.0

================================================================================
PACKAGING LIST:

SimpleDrillDownAppDelegate.h
SimpleDrillDownAppDelegate.m
Application delegate that configures the root view controller.

RootViewController.h
RootViewController.m
Table view controller that sets up the initial table view.

DetailViewController.h
DetailViewController.m
Table view controller that sets up the detail table view.

DataController.h
DataController.m
A simple controller class responsible for managing the application's data.

main.m
Main source file for this sample.

MainWindow.xib
The xib file containing the application's main window.


================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 2.6
- Updated project to use nibs.

Version 2.5
- Updated for and tested with iPhone OS 2.0. First public release.
- Moved data controller to a separate object.

Version 2.4
- Updated for Beta 6
- Set detail view to scroll to top without animation on display.

Version 2.3
- Updated for Beta 5
- Changed order of presentation of detail view.

Version 2.1
- Updated for Beta 4
- Adopts the new pattern in the Cocoa Touch List project template.
- The application delegate serves as the controller for the application's data; the root table view controller retrieves data from the application delegate.

Version 2.0
- Updated for Beta 3
- The samples now use nib files and UITableViewController; they also adopt the new pattern for table cell reuse.

================================================================================
Copyright (C) 2008 Apple Inc. All rights reserved.