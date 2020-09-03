# Hunted List Helper
## Install
* Download the addon [ZIP on github](https://github.com/banpower1/HuntedListHelper/archive/master.zip)
* Find the addon folder (`blizzard launcher -> WoW Classic -> options -> Show in Explorer -> _classic_ -> Interface -> AddOns`)
* Extract the zip to the addon folder (should be `AddOns/HuntedListHelper` folder with the files inside)  
## Settings
Output channel controls what channel the addon responds to most commands.

Guild, party and raid is self explanatory.

Debug is a channel only shared with yourself, that prints to the first tab in your chat window.
### Opening the settings
`ESC -> Interface Options -> AddOns -> Hunted List Helper`
## Triggers
* Raid warning starting with a purple (epic) item link by anyone, causes the addon to respond with the prios for that item in the Output channel (same as `/hlh <item>` command).
## Commands
* `/hlh` - Opens the HLH interface (currently only used for imports)
* `/hlh <item>` or `/hlh <item link>` - Asks the addon to tell the prio list for an item (both written and item link works). This is also triggered by purple (epic) items in raid warning. The result is posted to the output channel.
* `hlhp <player>` - Asks the addon to tell the known info for a specific person. The result is posted to the output channel.

## Importing the hunted list
* Open the HLH interface (`/hlh`) and go to the import tab
* Open the [**webview** Hunted List](https://docs.google.com/spreadsheets/d/e/2PACX-1vRuzcDVmq5M-gpi8m5OeTN0A4cxaa5xXwWHqBc5WlFMc9g4m91wUjjCtwSI98v7sJcgSObgJ9MuCrOP/pubhtml)
* Click anywhere on the hunted list in your browser, press CTRL+A then CTRL+C
* Click in the text box in the import tab and press CTRL+V
* Press the Update button - If successful the text dissapears and 'Huntedlist Updated' is written in the debug channel. If not successful the text doesn't dissapear, and 'Error parsin input' is written in the debug channel.