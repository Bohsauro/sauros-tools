-- main.lua
-- Entry point principale per "Sauro's Tools"

local SaurosTools = RegisterMod("Sauro's Tools", 1)

SaurosTools.Name = "Sauro's Tools"
SaurosTools.Version = "1.0.0"
SaurosTools.Author = "Bohsauro"

-- Inizializzazione moduli
local Config = require("scripts.config")
local Commands = require("scripts.commands")
local TreasureQoL = require("scripts.qol.treasure_room")

SaurosTools.Config = Config
SaurosTools.Commands = Commands
SaurosTools.TreasureQoL = TreasureQoL

Config.Init(SaurosTools)
Commands.Init(SaurosTools)
TreasureQoL.Init(SaurosTools)

-- Supporto sicuro se ModConfigMenu viene caricato dopo Sauro's Tools nell'ordine delle mod
local mcmRegistered = (ModConfigMenu ~= nil)
SaurosTools:AddCallback(ModCallbacks.MC_POST_RENDER, function(_)
    if not mcmRegistered and ModConfigMenu then
        mcmRegistered = true
        Config.SetupModConfigMenu()
    end
end)

-- Callback all'avvio della partita / nuova run
SaurosTools:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
    if Config.Data.showStartupMessage then
        local status = isContinued and "Partita ripresa" or "Nuova run iniziata"
        Isaac.DebugString(string.format("[%s v%s] %s. Digita 'st help' in console per i comandi.", SaurosTools.Name, SaurosTools.Version, status))
    end
end)

-- Callback all'uscita dalla partita (salvataggio dati)
SaurosTools:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
    Config.Save()
end)

Isaac.DebugString(string.format("[%s] Mod caricata con successo (v%s)!", SaurosTools.Name, SaurosTools.Version))

return SaurosTools
