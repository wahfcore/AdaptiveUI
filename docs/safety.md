# Safety and Blizzard's addon rules

AdaptiveUI changes how the game looks. It does not change what the game does. These are the rules I hold it to, and
where they come from.

## The rules

1. **Appearance only.** It restyles Blizzard's frames (colours, textures, fonts) and draws its own pieces beside them.
   It never replaces a protected frame, and it never touches your keybinds or macros.
2. **No automation.** It never presses a button, casts, targets or moves you, and it gives no rotation help.
3. **Secret values stay secret.** On this client some health, power and cooldown numbers are hidden from addons in
   combat. AdaptiveUI never does arithmetic on them, compares them or prints them. Where the game will not tell it a
   number, it hands the raw value straight to the game's own bar to draw, or shows nothing.
4. **Hands off Blizzard's bars and frames.** It never moves, resizes or reparents Blizzard's action bars, unit frames,
   buffs, tooltips or quest tracker. On this version of the game an addon doing that breaks their cooldowns and
   health, so Edit Mode (Esc > Edit Mode) places them and my art follows wherever you put them.
5. **Nothing changes in combat.** Any change to a game frame waits until you are out of combat.
6. **Animation only on its own pieces.** Nothing of Blizzard's is animated.
7. **No network, no extra files.** It saves nothing but its own settings file.
8. **It stands down by itself.** It checks the game build. A build I have tested runs in full. A new build on the same
   version line runs in full, and the first time the game blocks something the addon tried, it stands down for that
   build and leaves Blizzard's UI as it was. A very different version loads and touches nothing. `/aui build` tells you
   which of these you are in; `/aui quarantine clear` then `/reload` lets it try again after a fix.

## Sources

- Blizzard, UI Add-On Development Policy: <https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534>
- Warcraft Wiki, Secret Values: <https://warcraft.wiki.gg/wiki/Secret_Values>
- Warcraft Wiki, Secure Execution and Tainting: <https://warcraft.wiki.gg/wiki/Secure_Execution_and_Tainting>
- Warcraft Wiki, InCombatLockdown: <https://warcraft.wiki.gg/wiki/API:InCombatLockdown>
- Warcraft Wiki, TOC format: <https://warcraft.wiki.gg/wiki/TOC_format>

World of Warcraft is a trademark of Blizzard Entertainment. AdaptiveUI is a fan-made addon and is not affiliated with
or endorsed by Blizzard.
