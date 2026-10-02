# AdaptiveUI beta: tester guide

Thanks for trying this. AdaptiveUI is my HUD for the World of Warcraft Classic "Forever" beta, built for playing on a
couch with a controller. Mouse and keyboard work too. It only changes how the game looks. It never replaces your keybinds,
your macros or the game's own controls.

This is a beta. Things will be rough. Your job is to tell me where, in plain words. You do not need to know anything technical.

## 1. Install (2 minutes)

1. Close the game.
2. Run `AdaptiveUI-Setup.exe` from the release page. Windows will say "Windows protected your PC" because I haven't
   signed it yet: click More info, then Run anyway. It finds your game folder, backs up any older copy, and installs.
   (Rather not run an exe? Unzip `AdaptiveUI-<version>.zip` and copy the `AdaptiveUI` folder into
   `World of Warcraft\_classic_beta_\Interface\AddOns\`, so the result is `...\AddOns\AdaptiveUI\AdaptiveUI.toc`.)
3. Start the game on the Classic beta, pick your character, and on the character screen click AddOns. Make sure AdaptiveUI is ticked
   and, if it says "out of date", tick "Load out of date AddOns".
4. Log in. You should see one line in chat starting `AdaptiveUI` (two if a controller is plugged in).
5. Open Edit Mode (Esc > Edit Mode) and drag the main action bar up a little. Blizzard's default puts it right on the
   bottom edge, with no room under it for my painted bar. Put the bags and menu wherever you like. Edit Mode remembers it.

To remove it: run the installer again and press Uninstall, or close the game and delete the `AdaptiveUI` folder. Your saved settings are a separate file and are harmless to leave.

## 2. First run (about 1 minute)

A short setup opens by itself. It asks how you play (controller or keyboard and mouse), your screen (monitor, TV or
handheld), which unit frames you want, and what look you want. Everything applies as you choose, so the game behind the
window is the preview. You can skip it ("Use the defaults", or X on a controller), and run it again any time.

- Controller: D-pad moves, A chooses, B goes back, LB/RB change pages.
- Keyboard and mouse: click. Esc closes.

Getting back to the options later:
- Best on a controller: bind a button to it once, in Key Bindings > AddOns > AdaptiveUI > "Open AdaptiveUI options".
- Any input: Esc > Options > AddOns > AdaptiveUI > Open AdaptiveUI options.
- Keyboard: type `/aui` and press Enter.

In the options window: Simple shows the settings most people want; Advanced shows every setting (there are over two
hundred) and says so. On a controller, LB/RB change section, LT/RT page, Y jumps to a topic.

If you play with a controller while the keyboard bars are on screen, a box in the bottom right tells you where Blizzard's
switch is: Esc > Options > Gamepad > Gamepad Mode. Blizzard keeps that setting for itself, so I don't flip it for you;
once you do, my HUD swaps to the controller bars by itself, and back again. You can turn the reminder off in Options >
Controls > Gamepad Mode reminder.

If the setup has not opened, type `/aui welcome`.

## 3. What to look at (please spend time on these)

You do not have to test everything. If you only have ten minutes, do the starred ones.

1. * **Does it look good on your screen, at your distance?** Screenshot your HUD in a fight and out of one. Tell me if any text
   is too small to read from where you sit.
2. * **Does it get in your way?** Cast something, take damage, target a mob, open your bags, use the map. Anything that flickers,
   overlaps, disappears or looks broken is a bug.
3. * **Controller users: play a whole session on the pad.** Can you reach every setting without a keyboard? Where did you get stuck?
4. * **Change the colour scheme** (Options > Look). Does every panel follow? Is one unreadable?
5. **Move something.** Options > Layout: nudge the minimap or the chat with its arrows, or press Move things and drag. Did it
   stay after `/reload`?
6. **Try both unit frames.** Options > Look > Unit frames: my AdaptiveUI plates, or Blizzard's, restyled. Which one is better?
7. **Controller users: the reminder.** Plug the controller in, or pick it up after using the keyboard. Did the box appear?
   Turn on Gamepad Mode where it says: did my HUD swap to the controller bars cleanly, and back when you turn it off?
8. **Resize.** Make the text and my plates bigger and smaller (Options), and the action bar bigger and smaller (Edit Mode).
   Does my art follow? Does anything overlap or get cut off?
9. **Go to Advanced** in the options window and change something you found interesting. Did it tell you what it changed? Did you
   feel lost?
10. **Log out and back in.** Are your settings still there?

I especially want to hear: "I could not find how to ...", "I did not know what this does", "this looks worse than the default game".

## 4. If something goes wrong (panic buttons)

These are safe. None of them touch your keybinds or the game's own settings.

| Problem | Type this (then `/reload`) |
|---|---|
| The HUD is broken and I just want my normal UI back | `/aui skin all off` |
| Go back to the game's own unit frames | `/aui units lite` |
| Hide AdaptiveUI's HUD for now | `/aui hide` (bring it back with `/aui show`) |
| Put everything back to how it started | `/aui reset`, then `/aui reset` again within 10 seconds (or Options > Help & tools > Reset) |
| The addon says it stood down / disabled something | `/aui quarantine clear` |
| Nothing I do helps | Close the game, delete the `AdaptiveUI` folder, start again. |

If the game shows a red Lua error box, take a screenshot of the whole thing before you close it. That is a real bug and very useful.

## 5. How to report a bug

Send me three things: what you did, what you expected, what happened. Then one of these.

**Easy:** open Options > Help & tools > Report a problem (or type `/aui report`). A box appears with text already
selected. Press Ctrl+C, paste it into your message. It also tells you the exact file that holds the full report; press
"Reload now" and send me that file if I ask for it.

**If that does not work:**
1. Take a screenshot (PrintScreen key, or the controller's share button). Send it.
2. Type `/aui status` in chat. It prints about forty lines. Chat text cannot be copied, so take a screenshot of the chat, or, before
   you type it, turn on chat logging with `/chatlog`. The game then saves everything that appears in chat to
   `World of Warcraft\_classic_beta_\Logs\WoWChatLog.txt`. Send me the last 60 lines of that file. Turn it off again with `/chatlog`.
3. If I ask for more: type `/aui inspect`, wait a few seconds, then type `/reload`. That writes a detailed report to your saved
   settings. Send me the file
   `World of Warcraft\_classic_beta_\WTF\Account\<YOUR ACCOUNT>\<Realm>\<Character>\SavedVariables\AdaptiveUI.lua`
   (the game only writes it when you `/reload` or log out). It contains your settings and character name and nothing else; do
   not edit it.

Tell me your input (controller or keyboard), your screen (monitor, TV, Legion Go or similar) and roughly how far you sit.

If you see the line "Your saved settings came up empty at login, so they were restored from this character's backup": that is a
bug I am still chasing. Send me `/aui status` straight away, exactly as it was.

## 6. Known rough edges (you can skip reporting these)

- Light colour schemes (Parchment, Porcelain) put dark text straight over the game world. Some of it is hard to read.
- Blizzard's action bars, unit frames, buffs, tooltips and quest tracker are placed only in Edit Mode. On this version
  of the game an addon moving them breaks their cooldowns, so my movers and size settings for those just point you there.
- With the action bar on the very bottom edge, my painted bar sits behind the buttons. Raise the bar in Edit Mode.
- With my plates on, Blizzard's own player and target frames are hidden but still take clicks wherever Edit Mode put them.
- The compass group sizes, the "carved" health fill and tiles at some sizes are new and I have only lightly tested them in the real client.
- Settings save when you `/reload` or log out, not the instant you change them.
- Long target names are cut short if you choose the "percent and current/max" health text.

## 7. What I do not need

Compliments are lovely, but complaints are more useful. "It is fine" tells me nothing; "I could not tell what Advanced did" tells me
what to fix.

Thank you.
