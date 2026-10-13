-- scripts/commands.lua
-- Gestore dei comandi per la Debug Console di Isaac (tasto ~)

local Commands = {}

local function printHelp()
    print("=== Sauro's Tools - Comandi Console ===")
    print("  st help       - Mostra questo elenco di comandi")
    print("  st info       - Mostra versione e stato della mod")
    print("  st heal       - Ripristina la salute al massimo")
    print("  st charge     - Ricarica l'oggetto attivo corrente")
    print("  st clear      - Elimina tutti i nemici nella stanza attuale")
    print("  st coins [n]  - Aggiunge monete (default: 10)")
    print("  st bombs [n]  - Aggiunge bombe (default: 5)")
    print("  st keys [n]   - Aggiunge chiavi (default: 5)")
    print("=======================================")
end

function Commands.Init(mod)
    Commands.Mod = mod

    mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, args)
        cmd = string.lower(cmd)
        if cmd ~= "st" and cmd ~= "sauro" then
            return
        end

        local tokens = {}
        for token in string.gmatch(args or "", "%S+") do
            table.insert(tokens, string.lower(token))
        end

        local subCmd = tokens[1] or "help"
        local game = Game()
        local player = Isaac.GetPlayer(0)

        if subCmd == "help" then
            printHelp()

        elseif subCmd == "info" then
            print("Sauro's Tools v" .. tostring(mod.Version) .. " - Ready!")

        elseif subCmd == "heal" then
            if player then
                player:AddHearts(player:GetMaxHearts() * 2)
                print("[Sauro's Tools] Salute ripristinata!")
            end

        elseif subCmd == "charge" then
            if player then
                player:FullCharge(ActiveSlot.SLOT_PRIMARY)
                print("[Sauro's Tools] Oggetto attivo ricaricato!")
            end

        elseif subCmd == "clear" then
            local room = game:GetRoom()
            local enemies = Isaac.FindInRadius(room:GetCenterPos(), 2000, EntityPartition.ENEMY)
            local count = 0
            for _, ent in ipairs(enemies) do
                if ent:IsVulnerableEnemy() and not ent:IsBoss() then
                    ent:Kill()
                    count = count + 1
                end
            end
            print(string.format("[Sauro's Tools] %d nemici eliminati.", count))

        elseif subCmd == "coins" then
            local amount = tonumber(tokens[2]) or 10
            if player then
                player:AddCoins(amount)
                print(string.format("[Sauro's Tools] Aggiunte %d monete.", amount))
            end

        elseif subCmd == "bombs" then
            local amount = tonumber(tokens[2]) or 5
            if player then
                player:AddBombs(amount)
                print(string.format("[Sauro's Tools] Aggiunte %d bombe.", amount))
            end

        elseif subCmd == "keys" then
            local amount = tonumber(tokens[2]) or 5
            if player then
                player:AddKeys(amount)
                print(string.format("[Sauro's Tools] Aggiunte %d chiavi.", amount))
            end

        else
            print(string.format("[Sauro's Tools] Comando sconosciuto: '%s'. Usa 'st help'.", subCmd))
        end
    end)
end

return Commands
