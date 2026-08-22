-- SharedMedia_Externals
-- Registers ten TTS callouts of external defensive cooldowns with
-- LibSharedMedia-3.0, so any addon's sound dropdown can use them. Pair with
-- something that plays a sound on aura gain (NorthernSkyRaidTools' Aura
-- Sounds) to hear which external you were just given without looking.
--
-- LibStub is fetched loudly on purpose. Everything downstream of a missing
-- registration fails silently -- a consumer looking the name up gets nil and
-- plays nothing -- so an error here is the only chance of being told why.

local LSM = LibStub("LibSharedMedia-3.0")

local PATH = [[Interface\AddOns\SharedMedia_UnstableExternals\sound\]]

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
