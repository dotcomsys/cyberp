CybeRp = CybeRp or {}
CybeRp.Crafting = CybeRp.Crafting or {}

local Crafting = CybeRp.Crafting
local Recipes = {
    cyberdeck_mk2 = {
        inputs = { cyberdeck = 1, data_fragments = 5 },
        outputs = { cyberdeck = 1 },
        cost = 200,
    },
}

local function hasInputs(ply, inputs)
    for id, amt in pairs(inputs or {}) do
        if not CybeRp.Inventory.Has(ply, id, amt) then
            return false
        end
    end
    return true
end

function Crafting.CanCraft(ply, recipeId)
    local r = Recipes[recipeId]
    if not r then return false, "no recipe" end
    if not hasInputs(ply, r.inputs) then return false, "missing inputs" end
    if r.cost and ply:GetCredits() < r.cost then return false, "no credits" end
    return true
end

function Crafting.Craft(ply, recipeId)
    local ok, err = Crafting.CanCraft(ply, recipeId)
    if not ok then return false, err end
    local r = Recipes[recipeId]

    for id, amt in pairs(r.inputs or {}) do
        CybeRp.Inventory.Remove(ply, id, amt)
    end
    if r.cost then
        ply:AddCredits(-r.cost)
    end
    for id, amt in pairs(r.outputs or {}) do
        CybeRp.Inventory.Add(ply, id, amt)
    end
    CybeRp.Player.MarkDirty(ply, "credits")
    CybeRp.Inventory.Sync(ply)
    hook.Run("CybeRp_CraftedItem", ply, recipeId)
    return true
end


