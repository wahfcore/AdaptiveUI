# What AdaptiveUI does

A console-RPG / action-combat HUD for WoW Classic "Forever". Controller first, mouse and keyboard supported.
I built it to change how the game looks and nothing else, and every piece below can be switched off on its own.

## Unit plates
- You and your target get your own painted plates, big and calm, readable from across the room.
- Health always shows as a percent first, with the number after it if you want it. Never colour alone: a dead, ghosted or
  offline unit also says so in words.
- When you take a hit, the lost health lingers as a trail that catches up, so you can see how big the hit was.
- Healing coming in shows as a soft ghost on the bar.
- Low health is marked with a permanent line at the quarter mark, plus a warning that wakes up when you get there.
- Health and power bars take your class colour, the unit's reaction colour, or a single colour you pick.
- Target of target, focus and focus target get small plates of their own.
- Party and raid members get a matching tile style, so the group reads as one family.
- Click your plates to target, just like Blizzard's frames (out of combat, on a keyboard).
- Prefer Blizzard's frames? Pick "Blizzard's frames, restyled" and I only restyle them.
- Buffs and debuffs get the same quiet style (place them in Blizzard's Edit Mode).

## Cast bars
- Player, target and focus casts run as light along a seam inside the plate, instead of a bar stuck on top.
- The seam shows a glowing head while casting; an interrupt flashes twice, and a cast the game won't give details about
  still gets drawn.

## Keyboard action bar
- Blizzard's action bar stands on my painted bar, with a soft fade behind it and an experience bar that matches. The
  painting follows the bar wherever you put it in Edit Mode, and never goes off screen.
- The micro menu and bags wear the same tiles, wherever Edit Mode puts them.
- Empty slots fade back so the bar shows only what you use; hotkey labels can be kept or hidden on empties.
- Every other bar and the page block wear the same style. Nothing about how the buttons work changes.

## Gamepad compass
- When you play on a controller, Blizzard's controller bars become a compass: four arms around the centre, with the
  button glyphs on each slot.
- Painted tiles behind every button, with a notch pointing the way each button is pressed.
- LB and RB sit on my painted plaques and glow while you hold them.
- A divider under the arms lights from the trigger you are holding (LT or RT), so you always know which set you are on.
- Empty slots recede, so the bound arm is the only thing that draws your eye.
- Button prompts sit next to their arm, and the glyphs match your controller.
- You can drive the whole HUD with the pad, including the settings window and the colour picker.

## Map, chat, quest tracker and settings
- The minimap sits on my painted plaque, with the zone and coordinates set into it, kept clear of the quest tracker.
- Chat gets the same quiet style, and the input box only shows its frame while you are typing.
- The quest tracker is tidied: less clutter, same information.
- Blizzard's Settings window can wear the painted look too.
- The crest appears in the windows' headers, or not at all, your choice.
- Info strips (durability, bags, coordinates, clock) sit where you put them and never overlap the rest.
- A damage strip shows your own damage, if you want it.

## Themes and recolour
- Sixteen colour schemes, from warm Dusk (the default) to Frost, Bloodmoon, Sandstone, Mono, and a colour-blind-safe one.
- Build your own from a body colour and an accent; it refuses combinations that would be too hard to read.
- The painted art recolours to match every scheme, brass marks included, so the plates and bars always look like one
  piece.
- Motion level from "none" to full: how much the bars shimmer and glow is up to you, and it can be off entirely.
- Minimal or full console-RPG panels.
- Text never gets small: 14 px floor, larger presets for a TV or a handheld.
- A safe-zone margin keeps everything off the edge of a television.

## Movers and sizes
- Unlock the movers and drag my pieces: plates, cast bars, minimap, chat, info strips.
- Blizzard's own action bars, unit frames, buffs, tooltips and quest tracker are placed and sized in Blizzard's Edit Mode
  (Esc > Edit Mode). On this version of the game, an addon that moves them breaks their cooldowns, so I leave their
  position and size to Edit Mode; my art follows them wherever you put them.
- Every element of mine has its own size, fade and look setting.
- Position and size are remembered, out of combat only.
- A one-click reset per element or for everything.
- Monitor, TV and Handheld presets to start from.

## Profiles, per-spec, import and export
- Save your setup as a profile; keep different ones for different characters.
- Switch profiles automatically when you change spec.
- Export a profile as text to send to a friend or keep as a backup; import someone else's.
- Copy, rename and delete profiles from the settings window or from `/aui profile`.

## Settings you can trust
- Settings live in your normal WTF folder and survive game updates and addon updates.
- I keep a second copy per character, and if the main save ever comes up empty at login, it is restored from that copy
  and the addon tells you.
- `/aui save` writes a backup copy on demand.
- The settings window has six sections (Look, Layout, Combat, Controls, Profiles, Help & tools), search, and every
  label in plain words. Simple shows what most people want; Advanced shows every setting, and it says so.

## Adaptive input
- Button pictures: Controller, Keyboard, or Detect, which follows whichever device you touched last.
- Pick up a controller while the keyboard bar is showing and a small box in the bottom right tells you where
  Blizzard's Gamepad Mode switch is. Flip it and the HUD swaps to the compass by itself, and back again. The reminder
  can be turned off.
- The first-run welcome sets this up with the rest: how you play, your screen, your unit frames, your look.

## Also
- An optional "action camera" (off by default) that makes the camera feel more like an action game.
- A first-run welcome walkthrough, six screens, controller first, reachable again with `/aui welcome`.
- A build gate: on a new game patch the addon checks the frames it needs and stands down rather than break anything.
- Report a problem, from the settings window or `/aui report`, plus diagnostics you can paste into a bug report:
  `/aui status`, `/aui build`, `/aui inspect`.
