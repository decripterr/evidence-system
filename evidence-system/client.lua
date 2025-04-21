local QBCore = exports['qb-core']:GetCoreObject()

-- STEP 1: Create qb-target zones for stash locations
Citizen.CreateThread(function()
    for _, coords in pairs(Config.StashLocations) do
        exports['qb-target']:AddBoxZone("evidence_stash_" .. coords.label, vector3(coords.x, coords.y, coords.z), 1.5, 1.5, {
            name = "evidence_stash_" .. coords.label,
            heading = coords.heading or 0,
            debugPoly = false,
            minZ = coords.z - 1.0,
            maxZ = coords.z + 1.0,
        }, {
            options = {
                {
                    icon = "fas fa-box",
                    label = "Add to Evidence Stash",
                    action = function()
                        openEvidenceInput()
                    end,
                },
                {
                    icon = "fas fa-archive",
                    label = "Open Evidence Stash",
                    action = function()
                        openStashInput()
                    end,
                },
            },
            distance = 2.0
        })
    end
end)

-- STEP 2: Input UI to ADD item to evidence stash
function openEvidenceInput()
    local dialog = exports['qb-input']:ShowInput({
        header = "Add Evidence",
        submitText = "Submit",
        inputs = {
            { type = 'text', isRequired = true, name = 'caseid', text = 'Enter Case ID' },
            { type = 'text', isRequired = true, name = 'item', text = 'Item Name (e.g. pistol_ammo)' },
            { type = 'number', isRequired = true, name = 'amount', text = 'Amount' }
        }
    })

    if dialog then
        local caseID = dialog.caseid
        local item = dialog.item
        local amount = tonumber(dialog.amount)
        if caseID and item and amount then
            TriggerServerEvent("evidence:addEvidence", caseID, item, amount)
        end
    end
end

-- STEP 3: Input UI to OPEN stash
function openStashInput()
    local dialog = exports['qb-input']:ShowInput({
        header = "Open Evidence Stash",
        submitText = "Open",
        inputs = {
            { type = 'text', isRequired = true, name = 'caseid', text = 'Enter Case ID' }
        }
    })

    if dialog and dialog.caseid then
        TriggerServerEvent("evidence:requestOpen", dialog.caseid)
    end
end

-- STEP 4: Handle opening stash on client
RegisterNetEvent("evidence:openStash", function(stashId)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", stashId, {
        maxweight = 2000000, -- or adjust for your inventory system
        slots = 60           -- increase if you're getting "not enough across slots"
    })
    TriggerEvent("inventory:client:SetCurrentStash", stashId)
end)
