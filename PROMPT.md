# Build prompt: SharedMedia_Externals

Hand this whole folder to whoever (or whatever) is building the addon. The audio
is already made; only two text files are missing.

---

## What to build

A World of Warcraft **retail** addon named `SharedMedia_Externals` that does one
thing: register ten `.ogg` files with LibSharedMedia-3.0 so any addon's sound
dropdown can use them.

They are text-to-speech callouts of external defensive cooldowns — the spells
another player casts on *you*. Paired with an addon that plays a sound on aura
gain (NorthernSkyRaidTools' Aura Sounds, for example), you hear which external
you just received without looking.

The `sound/` folder in this package is final. Do not re-encode or rename the
files: the filename is what the registered name is derived from, and anything
already pointing at these names breaks if they change.

## Final layout

```
SharedMedia_Externals/
    SharedMedia_Externals.toc      <- create
    Externals.lua                  <- create
    sound/                         <- already here, 10 files, do not touch
        Blessing of Protection.ogg
        Blessing of Sacrifice.ogg
        Blessing of Spellwarding.ogg
        Guardian Spirit.ogg
        Ironbark.ogg
        Life Cocoon.ogg
        Pain Suppression.ogg
        Roar of Sacrifice.ogg
        Sacrifice of the Just.ogg
        Time Dilation.ogg
```

The folder name, the `.toc` filename and the `## Title` must all match, or the
client will not load it.

## SharedMedia_Externals.toc

```
## Interface: 120007, 120100
## Title: SharedMedia_Externals
## Notes: TTS callouts for external defensive cooldowns.
## Author: John
## Version: 1.0
## Dependencies: SharedMedia
Externals.lua
```

`## Interface` must cover the live client build. 120007/120100 are Midnight-era;
check and update. If it is wrong the addon shows as out of date and only loads
with "Load out of date addons" ticked.

`## Dependencies: SharedMedia` guarantees LibSharedMedia-3.0 exists and is
loaded first. Anyone installing this needs the `SharedMedia` addon as well.

## Externals.lua

One `LSM:Register` per file. Registered name is `Ext: <ability>` — the prefix
groups them together in the dropdowns, which are otherwise alphabetical soup.

```lua
local LSM = LibStub("LibSharedMedia-3.0")

local PATH = [[Interface\Addons\SharedMedia_Externals\sound\]]

-- Registered name -> filename. The NAME is what other addons store, so it is a
-- stable identifier: renaming one silently breaks every saved reference to it.
local sounds = {
    ["Ext: Blessing of Protection"]   = "Blessing of Protection.ogg",
    ["Ext: Blessing of Sacrifice"]    = "Blessing of Sacrifice.ogg",
    ["Ext: Blessing of Spellwarding"] = "Blessing of Spellwarding.ogg",
    ["Ext: Guardian Spirit"]          = "Guardian Spirit.ogg",
    ["Ext: Ironbark"]                 = "Ironbark.ogg",
    ["Ext: Life Cocoon"]              = "Life Cocoon.ogg",
    ["Ext: Pain Suppression"]         = "Pain Suppression.ogg",
    ["Ext: Roar of Sacrifice"]        = "Roar of Sacrifice.ogg",
    ["Ext: Sacrifice of the Just"]    = "Sacrifice of the Just.ogg",
    ["Ext: Time Dilation"]            = "Time Dilation.ogg",
}

for name, file in pairs(sounds) do
    LSM:Register("sound", name, PATH .. file)
end
```

Note the path uses **backslashes** and a `[[...]]` literal — WoW asset paths are
Windows-style regardless of platform, and `\s` in a normal quoted string is an
invalid escape.

## Spell IDs, for whatever consumes these

Ten abilities, eleven IDs — Blessing of Protection has two.

| Ability | Spell ID |
| --- | --- |
| Blessing of Protection | 1022, 1309794 |
| Blessing of Sacrifice | 6940 |
| Blessing of Spellwarding | 204018 |
| Guardian Spirit | 47788 |
| Ironbark | 102342 |
| Life Cocoon | 116849 |
| Pain Suppression | 33206 |
| Roar of Sacrifice | 53480 |
| Sacrifice of the Just | 387804 |
| Time Dilation | 357170 |

## Three things that will waste an afternoon

1. **A newly created addon folder does not come up enabled.** After installing,
   tick it in the in-game AddOns list, for every character. This is the single
   most likely reason it "does not work" — the sound is simply never registered.

2. **Failure is silent.** Consumers look the sound up by name; an unregistered
   name returns nil and they play nothing, with no error. So "no sound" tells
   you nothing about *where* the break is. Verify registration first:

   ```
   /dump LibStub("LibSharedMedia-3.0"):Fetch("sound", "Ext: Ironbark")
   ```

   A file path means it is registered. `nil` means the addon is not loaded, the
   name is misspelled, or the file is missing.

3. **Load-on-demand addons register their media late.** If something else on
   the machine registers sounds only when its options window opens, its names
   are absent at login. That is a trap for *other* media, not this addon — this
   one registers at load — but it explains why some sound names come and go.

## Audio provenance

Windows SAPI (`System.Speech.Synthesis`), voice **Microsoft Zira Desktop**,
rate 1, spoken as the full ability name. Encoded with ffmpeg to Ogg Vorbis,
mono, 44.1 kHz, quality 4. Roughly 9-13 KB and 1.4-2.1 seconds each.

To regenerate at a different voice or speed, synthesize to WAV and convert:

```
ffmpeg -y -i in.wav -ac 1 -ar 44100 -c:a libvorbis -q:a 4 "out.ogg"
```
