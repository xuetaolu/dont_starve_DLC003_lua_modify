local assets=
{
	Asset("ANIM", "anim/antler.zip"),
    Asset("ANIM", "anim/swap_antler.zip"),    
}

local function onfinished(inst)
    inst:Remove()    
end

local function OnPlayed(inst, musician)
	if not TheCamera.interior then
	    if GetWorld().components.rocmanager then
    	    GetWorld().components.rocmanager:Spawn()
	    end
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst:AddTag("horn")
    
    inst.AnimState:SetBank("antler")
    inst.AnimState:SetBuild("antler")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = 0
    inst.components.instrument.onplayed = OnPlayed
    inst.components.instrument.sound_noloop = "dontstarve_DLC003/common/crafted/roc_flute"
    
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BIRDWHISLE_USES)
    inst.components.finiteuses:SetUses(TUNING.BIRDWHISLE_USES)
    inst.components.finiteuses:SetOnFinished( onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("inventoryitem")

    inst.hornbuild = "swap_antler"
    inst.hornsymbol = "swap_antler"    

    return inst
end

return Prefab( "common/inventory/antler", fn, assets) 
