# Build prompt: SharedMedia_Externals

The original build spec, kept for the audio provenance and the spell IDs. The
addon was built from it and then diverged in four places -- the shipped files
are the source of truth, not this document:

| This spec says | Shipped | Why |
| --- | --- | --- |
| `SharedMedia_Externals` | `SharedMedia_UnstableExternals` | Guild naming; the folder name is baked into the media path, so it had to change before anyone installed it |
| `## Dependencies: SharedMedia` | LibSharedMedia-3.0 embedded | The consumers embed LSM rather than installing the standalone SharedMedia addon -- NorthernSkyRaidTools included -- so a hard dependency blocked loading for the intended audience |
| `## Version: 1.0` | `@project-version@` | Substituted from the git tag by the BigWigs packager |
| `## Interface: 120007, 120100` | `120100` | Single live build, kept current by the weekly toc-interface workflow |

Unchanged and deliberate: the `Ext:` prefix on registered names, the `[[...]]`
path literal, and the loud `LibStub()` call.

---

## What to build

A World of Warcraft **retail** addon named `SharedMedia_Externals` that does one
thing: register eight `.ogg` files with LibSharedMedia-3.0 so any addon's sound
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
    sound/                         <- already here, do not touch
        Blessing of Protection.ogg
        Blessing of Sacrifice.ogg
        Blessing of Spellwarding.ogg
        Guardian Spirit.ogg
        Ironbark.ogg
        Life Cocoon.ogg
        Pain Suppression.ogg
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

Eight abilities, nine IDs — Blessing of Protection has two.

Roar of Sacrifice (53480) and Echoing Protection (387804) were dropped in 2.0.0:
neither lands on a tank in practice, and 387804 had been mislabelled here as
"Sacrifice of the Just", a name that matches no spell.

| Ability | Spell ID |
| --- | --- |
| Blessing of Protection | 1022, 1309794 |
| Blessing of Sacrifice | 6940 |
| Blessing of Spellwarding | 204018 |
| Guardian Spirit | 47788 |
| Ironbark | 102342 |
| Life Cocoon | 116849 |
| Pain Suppression | 33206 |
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

Levelled after synthesis: SAPI output sits around -22 dB mean, which is quiet
against raid noise. `speechnorm` lifts it about 5 dB and `alimiter` holds the
ceiling, landing every file within 0.2 dB of the same peak instead of the 1.6 dB
spread they had raw.

To regenerate at a different voice or speed, synthesize to WAV and convert:

```
ffmpeg -y -i in.wav -ac 1 -ar 44100 \
  -af "speechnorm=e=6:r=0.0005:l=1,alimiter=limit=0.85:level=disabled" \
  -c:a libvorbis -q:a 4 "out.ogg"
```

`libvorbis` is required -- ffmpeg's built-in `vorbis` encoder is experimental and
audibly worse. Homebrew's ffmpeg on this machine ships without libvorbis, so the
levelling pass ran in an Alpine container (`apk add ffmpeg`).
