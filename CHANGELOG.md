# Changelog

## 2.0.0
- Removed `Ext: Roar of Sacrifice` and `Ext: Sacrifice of the Just`. Neither lands on a tank in practice, and the second was mislabelled: spell 387804 is Echoing Protection, so that callout spoke a name belonging to no spell
- **Breaking.** If you had either selected in NSRT or anywhere else, that reference now resolves to nothing and fails silently. Clear it and pick a replacement, or nothing plays

## 1.0.2
- Levelled all ten callouts. They were about 5 dB quieter than they should be against raid noise, and their peaks varied by 1.6 dB; they now sit within 0.2 dB of each other

## 1.0.1
- Documentation brought in line with what actually shipped: the rename, the embedded library, and the version and interface handling

## 1.0.0
- Ten TTS callouts for external defensive cooldowns, registered with LibSharedMedia-3.0 as `Ext: <ability>`
