# SharedMedia_UnstableExternals

Text-to-speech callouts for external defensive cooldowns — the spells another
player casts on *you*. Registers ten sounds with LibSharedMedia-3.0 so they show
up in any addon's sound dropdown.

Pair it with something that plays a sound on aura gain (NorthernSkyRaidTools'
Aura Sounds, for example) and you hear which external you were just given
without having to look.

## Requirements

None. LibSharedMedia-3.0 is bundled, so it works whether or not you run the
standalone SharedMedia addon. If something else already loaded LSM -- NSRT,
ElvUI, WeakAuras -- LibStub keeps whichever copy came first and the bundled one
stands down.

## Install

In WowUp, *Get Addons* → *Install from URL*, and paste:

```
https://github.com/UnstableGuild/SharedMedia_UnstableExternals
```

WowUp tracks GitHub releases, so it will offer updates from then on.

**Then tick it in the in-game AddOns list, on every character.** A newly
installed addon folder does not come up enabled, and this is the single most
likely reason it appears not to work — the sounds are simply never registered.

## Sounds

All ten register as `Ext: <ability>`. The prefix keeps them together in
dropdowns that are otherwise alphabetical soup.

| Sound | Ability | Spell ID |
| --- | --- | --- |
| Ext: Blessing of Protection | Blessing of Protection | 1022, 1309794 |
| Ext: Blessing of Sacrifice | Blessing of Sacrifice | 6940 |
| Ext: Blessing of Spellwarding | Blessing of Spellwarding | 204018 |
| Ext: Guardian Spirit | Guardian Spirit | 47788 |
| Ext: Ironbark | Ironbark | 102342 |
| Ext: Life Cocoon | Life Cocoon | 116849 |
| Ext: Pain Suppression | Pain Suppression | 33206 |
| Ext: Roar of Sacrifice | Roar of Sacrifice | 53480 |
| Ext: Sacrifice of the Just | Sacrifice of the Just | 387804 |
| Ext: Time Dilation | Time Dilation | 357170 |

The registered **name** is what other addons save, so it is a stable
identifier. Renaming one silently breaks every saved reference to it.

## If you get no sound

Failure is silent by design: a consumer looks the sound up by name, an
unregistered name returns nil, and nothing plays. So "no sound" on its own does
not tell you where the break is. Check registration first:

```
/dump LibStub("LibSharedMedia-3.0"):Fetch("sound", "Ext: Ironbark")
```

A file path means it is registered, and the problem is downstream in whatever
was supposed to play it. `nil` means this addon is not enabled, or the name is
misspelled.

## Audio

Windows SAPI (`System.Speech.Synthesis`), voice Microsoft Zira Desktop, rate 1,
spoken as the full ability name. Ogg Vorbis, mono, 44.1 kHz, quality 4 —
roughly 9-14 KB and 1.4-2.1 seconds each, levelled so they carry over raid
noise and all sit at the same peak.

To regenerate at a different voice or speed, synthesize to WAV and convert:

```
ffmpeg -y -i in.wav -ac 1 -ar 44100 \
  -af "speechnorm=e=6:r=0.0005:l=1,alimiter=limit=0.85:level=disabled" \
  -c:a libvorbis -q:a 4 "out.ogg"
```

`PROMPT.md` carries the full build spec and rationale.
