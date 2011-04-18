Sorter
======

Experimental, getting to know the Cocoa Framework kind of thing:

* makes use of FSEvents to track events in the file system, even when the program is not running
* features some asynchronous processing thanks to libdispatch
* simple Core Data persistence
* uses the Spotlight API for rule matching based on contents

What it does
------------

It is a program that allows you to define rules for certain files in certain locations. Whenever a file matching the rule is detected (via adding, changing etc.) an action is triggered that moves (deletes, opens ...) the file to a location specified in the rule.


Why?
----
It tries to solve the problem that files start piling up in certain locations (e.g. the "Downloads" folder) even though some/most them of could be moved/archived automatically without any user interaction (e.g. bank statements, PDFs etc.) 