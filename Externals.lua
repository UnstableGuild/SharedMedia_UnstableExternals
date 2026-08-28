-- SharedMedia_Externals
-- Registers nine TTS callouts of external cooldowns with LibSharedMedia-3.0,
-- so any addon's sound dropdown can use them. Pair with something that plays a
-- sound on aura gain (NorthernSkyRaidTools' Aura Sounds) to hear which external
-- you were just given without looking.
--
-- "External" here means cast on you by someone else, not defensive: Power
-- Infusion is a throughput buff and belongs for the same reason the rest do.
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
    ["Ext: Power Infusion"]           = "Power Infusion.ogg",
    ["Ext: Time Dilation"]            = "Time Dilation.ogg",
}

for name, file in pairs(sounds) do
    LSM:Register("sound", name, PATH .. file)
end

-- Deadly Boss Mods ships sound clips it never registers with LibSharedMedia, so
-- nothing can select them. Point at the file where it already sits rather than
-- copying it: this repo is public, and the audio is DBM's, not ours.
--
-- Guarded on the addon existing so the dropdown never offers an entry that
-- resolves to a missing file -- an unresolvable sound plays nothing and says
-- nothing, which is the hardest kind of break to trace.
if C_AddOns and C_AddOns.DoesAddOnExist and C_AddOns.DoesAddOnExist("DBM-Core") then
    LSM:Register("sound", "DBM: Don't Die",
        [[Interface\AddOns\DBM-Core\sounds\SoundClips\dontdie.ogg]])
end
