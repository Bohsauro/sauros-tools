-- scripts/qol/treasure_room.lua
-- Quality of Life: Treasure Room adiacente al primo piano e filtro qualità minima oggetti

local TreasureQoL = {}

local processedPickups = {}
local game = Game()

-- Verifica se nel piano corrente esiste almeno una Treasure Room
local function hasTreasureRoomInLevel(level)
    local rooms = level:GetRooms()
    for i = 0, rooms.Size - 1 do
        local r = rooms:Get(i)
        if r and r.Data and r.Data.Type == RoomType.ROOM_TREASURE then
            return true
        end
    end
    return false
end

-- Verifica se una stanza adiacente allo spawn è una Treasure Room
local function hasAdjacentTreasureRoom(level)
    local startIdx = level:GetStartingRoomIndex()
    local offsets = { -13, 13, -1, 1 }

    for _, offset in ipairs(offsets) do
        -- Controlla bordi sinistro e destro della griglia 13x13 per evitare wrap-around
        if not (offset == -1 and (startIdx % 13 == 0)) and
           not (offset == 1 and ((startIdx + 1) % 13 == 0)) then
            local neighborIdx = startIdx + offset
            if neighborIdx >= 0 and neighborIdx <= 168 then
                local roomDesc = level:GetRoomByIdx(neighborIdx)
                if roomDesc and roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_TREASURE then
                    return true
                end
            end
        end
    end

    return false
end

-- Rerolla il seed del livello finché non c'è una Treasure Room adiacente
local function ensureAdjacentTreasure(mod)
    if not mod.Config.Data.adjacentTreasure then return end
    if game:IsGreedMode() then return end

    local level = game:GetLevel()
    if level:GetStage() ~= 1 then return end

    -- Se è una sfida che non ha treasure room, non reseeda
    if game.Challenge ~= Challenge.CHALLENGE_NULL and not hasTreasureRoomInLevel(level) then
        return
    end

    local maxReseeds = 250
    local count = 0

    while count < maxReseeds and not hasAdjacentTreasureRoom(level) do
        Isaac.ExecuteCommand("reseed")
        count = count + 1
    end

    if hasAdjacentTreasureRoom(level) then
        local msg = string.format("[Sauro's Tools] Treasure Room adiacente garantita (reseed necessari: %d).", count)
        Isaac.DebugString(msg)
        if mod.Config.Data.debugMode and count > 0 then
            print(msg)
        end
    else
        Isaac.DebugString("[Sauro's Tools] Limite reseed raggiunto per Treasure Room adiacente.")
    end
end

-- Filtra e migliora la qualità dell'oggetto generato nella stanza del tesoro
local function filterItemQuality(mod, pickup)
    local minQuality = mod.Config.Data.minItemQuality
    if not minQuality or minQuality <= 0 then return end

    local level = game:GetLevel()
    local isStage1 = (level:GetStage() == 1)

    -- Di default solo al 1° piano, a meno che l'utente non abbia scelto tutti i piani
    if not isStage1 and not mod.Config.Data.qualityFilterAllFloors then
        return
    end

    local room = game:GetRoom()
    local roomDesc = level:GetCurrentRoomDesc()
    local isTreasureRoom = (room:GetType() == RoomType.ROOM_TREASURE) or 
                           (roomDesc and roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_TREASURE)

    if not isTreasureRoom then return end

    -- Evita doppie elaborazioni sullo stesso pickup
    local ptrHash = GetPtrHash(pickup)
    if processedPickups[ptrHash] then return end
    processedPickups[ptrHash] = true

    local collectibleId = pickup.SubType
    if collectibleId <= 0 then return end

    local itemConfig = Isaac.GetItemConfig()
    local currentItem = itemConfig:GetCollectible(collectibleId)
    if not currentItem then return end

    -- Se l'oggetto ha già una qualità soddisfacente, lascialo invariato
    if currentItem.Quality >= minQuality then
        if mod.Config.Data.debugMode then
            print(string.format("[Sauro's Tools] Oggetto '%s' gia di qualita %d (>= %d). Mantenuto.", currentItem.Name, currentItem.Quality, minQuality))
        end
        return
    end

    -- Altrimenti cerca un oggetto nel pool Treasure con Qualità >= minQuality
    local itemPool = game:GetItemPool()
    local seed = pickup.InitSeed
    if not seed or seed == 0 then
        seed = room:GetAwardSeed()
    end

    local chosenItem = nil
    local bestFound = nil
    local bestQuality = -1
    local maxAttempts = 150

    for i = 1, maxAttempts do
        local candidateId = itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, false, seed + i * 37)
        local candidateDef = itemConfig:GetCollectible(candidateId)
        if candidateDef then
            if candidateDef.Quality >= minQuality then
                chosenItem = candidateId
                break
            elseif candidateDef.Quality > bestQuality then
                bestQuality = candidateDef.Quality
                bestFound = candidateId
            end
        end
    end

    -- Se non trova l'esatta qualità richiesta, usa il migliore trovato tra i candidati
    if not chosenItem and bestFound and bestQuality > currentItem.Quality then
        chosenItem = bestFound
    end

    if chosenItem and chosenItem ~= collectibleId then
        itemPool:RemoveCollectible(chosenItem)
        local newItemDef = itemConfig:GetCollectible(chosenItem)
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, chosenItem, true)

        local logMsg = string.format("[Sauro's Tools] Upgrade Treasure: '%s' (Q%d) -> '%s' (Q%d)",
            currentItem.Name, currentItem.Quality, newItemDef.Name, newItemDef.Quality)
        Isaac.DebugString(logMsg)
        if mod.Config.Data.debugMode then
            print(logMsg)
        end
    end
end

function TreasureQoL.Init(mod)
    TreasureQoL.Mod = mod

    -- Al via di una nuova partita / reset con R
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
        if not isContinued then
            processedPickups = {}
            ensureAdjacentTreasure(mod)
        end
    end)

    -- Ad ogni cambio piano pulisci la cache dei pickup
    mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function(_)
        processedPickups = {}
    end)

    -- Intercetta la generazione di collezionabili (piedistalli)
    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
        filterItemQuality(mod, pickup)
    end, PickupVariant.PICKUP_COLLECTIBLE)
end

return TreasureQoL
