-- scripts/config.lua
-- Gestione impostazioni, persistenza dati e integrazione con Mod Config Menu

local Config = {}
local json = require("json")

Config.Data = {
    showStartupMessage = true,
    debugMode = false,
    adjacentTreasure = true,        -- Treasure room sempre adiacente allo spawn al 1° piano
    minItemQuality = 3,             -- Qualità minima per la prima Treasure Room (3 = Tier 3 e 4)
    qualityFilterAllFloors = false, -- true = applica il filtro su tutti i piani, false = solo 1° piano
}

local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

Config.Default = deepCopy(Config.Data)

function Config.Init(mod)
    Config.Mod = mod

    -- Caricamento dati salvati
    if mod:HasData() then
        local rawData = mod:LoadData()
        local success, decoded = pcall(json.decode, rawData)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                if Config.Data[k] ~= nil then
                    Config.Data[k] = v
                end
            end
            Isaac.DebugString("[Sauro's Tools] Impostazioni caricate con successo.")
        else
            Isaac.DebugString("[Sauro's Tools] Errore decodifica salvataggio, ripristino default.")
        end
    end

    Config.SetupModConfigMenu()
end

function Config.Save()
    if Config.Mod then
        local encoded = json.encode(Config.Data)
        Config.Mod:SaveData(encoded)
        Isaac.DebugString("[Sauro's Tools] Impostazioni salvate.")
    end
end

function Config.SetupModConfigMenu()
    if not ModConfigMenu then return end

    local category = "Sauro's Tools"

    -- Reset per caricamenti sicuri con luamod
    pcall(function()
        ModConfigMenu.RemoveCategory(category)
    end)

    -- === SCHEDA: Treasure QoL ===
    ModConfigMenu.AddTitle(category, "Treasure QoL", "Sauro's Tools - Treasure Room QoL")
    ModConfigMenu.AddSpace(category, "Treasure QoL")

    -- Opzione 1: Stanza del tesoro adiacente
    ModConfigMenu.AddSetting(category, "Treasure QoL", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return Config.Data.adjacentTreasure
        end,
        Display = function()
            return "Adjacent Treasure (Floor 1): " .. (Config.Data.adjacentTreasure and "ON" or "OFF")
        end,
        OnChange = function(val)
            Config.Data.adjacentTreasure = val
            Config.Save()
        end,
        Info = {
            "Garantisce che la Treasure Room sia sempre adiacente allo spawn al 1 piano.",
            "Evita di dover camminare per trovare la prima stanza del tesoro."
        }
    })

    -- Opzione 2: Qualità minima oggetto
    ModConfigMenu.AddSetting(category, "Treasure QoL", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return Config.Data.minItemQuality
        end,
        Minimum = 0,
        Maximum = 4,
        ModifyBy = 1,
        Display = function()
            local q = Config.Data.minItemQuality
            if q == 0 then
                return "Min Item Quality: OFF (Vanilla)"
            elseif q == 4 then
                return "Min Item Quality: Rank 4 Only"
            else
                return "Min Item Quality: Rank " .. tostring(q) .. "+ (Tier " .. tostring(q) .. "-4)"
            end
        end,
        OnChange = function(val)
            Config.Data.minItemQuality = val
            Config.Save()
        end,
        Info = {
            "Rerolla l'oggetto se la sua qualita e inferiore al rank selezionato.",
            "Default: Rank 3+ (include solo oggetti di qualita 3 e 4).",
            "Imposta su 0 per disattivare."
        }
    })

    -- Opzione 3: Portata del filtro di qualità
    ModConfigMenu.AddSetting(category, "Treasure QoL", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return Config.Data.qualityFilterAllFloors
        end,
        Display = function()
            return "Quality Scope: " .. (Config.Data.qualityFilterAllFloors and "All Floors" or "Floor 1 Only")
        end,
        OnChange = function(val)
            Config.Data.qualityFilterAllFloors = val
            Config.Save()
        end,
        Info = {
            "Floor 1 Only: applica il filtro di qualita solo alla Treasure Room iniziale.",
            "All Floors: applica il filtro a tutte le Treasure Room della run."
        }
    })

    -- === SCHEDA: General ===
    ModConfigMenu.AddTitle(category, "General", "Sauro's Tools - Impostazioni Generali")
    ModConfigMenu.AddSpace(category, "General")

    -- Opzione: Messaggio all'avvio
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return Config.Data.showStartupMessage
        end,
        Display = function()
            return "Startup Message: " .. (Config.Data.showStartupMessage and "ON" or "OFF")
        end,
        OnChange = function(val)
            Config.Data.showStartupMessage = val
            Config.Save()
        end,
        Info = {"Mostra un messaggio nella console all'inizio di ogni run"}
    })

    -- Opzione: Debug Mode
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return Config.Data.debugMode
        end,
        Display = function()
            return "Debug Mode: " .. (Config.Data.debugMode and "ON" or "OFF")
        end,
        OnChange = function(val)
            Config.Data.debugMode = val
            Config.Save()
        end,
        Info = {"Abilita log dettagliati nella console di Isaac per il reroll e reseed"}
    })
end

return Config
