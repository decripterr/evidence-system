local QBCore = exports['qb-core']:GetCoreObject()

local function isAuthorized(src)
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return false end

    -- Job check
    for _, job in pairs(Config.AllowedJobs) do
        if player.PlayerData.job.name == job then
            return true
        end
    end

    -- Optional identifier check
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        for _, allowed in pairs(Config.AllowedIdentifiers or {}) do
            if id == allowed then
                return true
            end
        end
    end

    return false
end

-- Open stash request
RegisterNetEvent("evidence:requestOpen", function(caseID)
    local src = source
    if not isAuthorized(src) then
        print("Unauthorized stash access attempt by ID: " .. src)
        return
    end

    local stashId = "evidence_" .. caseID
    TriggerClientEvent("evidence:openStash", src, stashId)
end)

-- Add item to stash
RegisterNetEvent("evidence:addEvidence", function(caseID, item, amount)
    local src = source
    if not isAuthorized(src) then
        print("Unauthorized evidence add attempt by ID: " .. src)
        return
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local itemData = Player.Functions.GetItemByName(item)
    if itemData and itemData.amount >= amount then
        Player.Functions.RemoveItem(item, amount)

        -- Open the stash UI
        local stashId = "evidence_" .. caseID
        TriggerClientEvent("evidence:openStash", src, stashId)

        -- Optional confirmation message
        TriggerClientEvent("chat:addMessage", src, {
            args = { "[Evidence]", "Removed " .. amount .. "x " .. item .. " and opened Case ID: " .. caseID }
        })
    else
        TriggerClientEvent("chat:addMessage", src, {
            args = { "[Evidence]", "You don't have enough of that item!" }
        })
    end
end)
