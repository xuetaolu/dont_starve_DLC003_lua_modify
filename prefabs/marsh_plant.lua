local assets =
{
	Asset("ANIM", "anim/marsh_plant.zip"),
    Asset("ANIM", "anim/marsh_plant_tropical.zip"),
    Asset("ANIM", "anim/pond_plant_cave.zip")
}

local tidalassets =
{
    Asset("ANIM", "anim/tidal_plant.zip"),
    Asset("ANIM", "anim/marsh_plant_tropical.zip"),
}

local function fn(bank, build)
    local func = function()
    	local inst = CreateEntity()
    	local trans = inst.entity:AddTransform()
    	local anim = inst.entity:AddAnimState()

        MakeMediumBurnable(inst)
        MakeSmallPropagator(inst)

        anim:SetBank(bank)
        anim:SetBuild(build)
        
        anim:PlayAnimation("idle")
        
        inst:AddComponent("inspectable")
        return inst
    end
    return func
end

return Prefab( "marsh/objects/marsh_plant", fn("marsh_plant", "marsh_plant"), assets),
Prefab("cave/objects/pond_algae", fn("pond_rock", "pond_plant_cave"), assets),
Prefab("shipwrecked/objects/tidal_plant", fn("tidal_plant", "tidal_plant"), tidalassets),
Prefab("shipwrecked/objects/marsh_plant_tropical", fn("marsh_plant_tropical", "marsh_plant_tropical"), tidalassets)