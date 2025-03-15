## A note about Swift scripts

Thanks to Cursor's help, I was able to wire up a build-on-save workflow.
It uses a plugin called RunOnSave (by emeraldwalk).

These scripts, and the rest of the scripts, can be wired to macOS automater
as Quick Actions that show up in Finder's UI and right-click menu.

Using Swift allows the scripts to use first-class macOS things such as
adding and removing tags, or moving something to the Trash instead of
immediately deleting it. And most-excitingly, it allows SwiftUI to be used
in the context of a script. Eg showing a popup alert after a script is
completed with a button to go to a URL.