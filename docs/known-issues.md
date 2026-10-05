# Known issues and what is not verified

What I know is rough, and what I have not been able to confirm in the live game yet. Every build passes my full
offline test suite; the list below is what only the live client can confirm.

## Player-facing

This is a beta on a beta client. Things I have tested a lot, and things I have not:

**Not yet confirmed in the live game**
- The painted minimap shelf and Settings window at real size, and how the map clears the quest tracker at other
  UI scales.
- The painted tiles and slabs at their real pixel size on very small or very large screens.
- Raid tiles on every raid layout; focus target plates when the focus has no target.
- The crest tidy-up on a profile that had the old "both" setting.
- A profile saved with one of the older looks (before the addon kept just Blizzard, AUI Dusk and AUI Oakborn) is moved
  to the nearest of the three when it loads, with one line in chat. I have tested this offline on every old setting.
- macOS: the manual zip should work, but I have not tried it on a Mac.

**Known small things**
- Blizzard's action bars, unit frames, buffs, tooltips and quest tracker are placed and sized only in Edit Mode
  (Esc > Edit Mode). On this version of the game an addon that moves them breaks their cooldowns and health, so the
  settings that used to do it now point you to Edit Mode. My painted art follows them wherever you put them.
- Blizzard's default puts the main action bar right on the bottom edge; there my painted bar sits behind the buttons.
  Raise the bar a little in Edit Mode and it stands on the art.
- With my plates on, Blizzard's own player and target frames are hidden but still take clicks wherever Edit Mode put them.
- The light colour schemes (Parchment, Porcelain) put dark text straight over the world in a few places.
- Combo points are hidden from addons on this client, so the optional legacy combo bar can show a bar with no number.
- The action camera is opt-in and changes camera settings (it restores them on toggle-off and logout). It is the one place
  the addon changes how the game behaves rather than how it looks, and it is off by default.
- Very rarely the account-wide settings file came up empty at login during development. A per-character backup copy
  restores it and the addon tells you; if you ever see "saved settings came up empty", run `/aui status` and send me
  the output.
- Another addon that restyles the same Blizzard frames will fight this one.

**Game patches.** The addon checks the game build. Builds I have read through run in full. A new build on the same
version line runs in full and stands down for that build the first time the game blocks something the addon tried
(`/aui build` shows it; `/aui quarantine clear` then `/reload` tries again). A different version line loads and touches
nothing until I have looked at it.
