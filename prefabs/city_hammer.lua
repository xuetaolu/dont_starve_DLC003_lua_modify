local assets=
{
	Asset("ANIM", "anim/city_hammer.zip"),
	Asset("ANIM", "anim/swap_city_hammer.zip"),
}

local prefabs =
{
	"collapse_small",
	"collapse_big",
}

local function onfinished(inst)
    inst:Remove()
end
    

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_city_hammer", "swap_city_hammer")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    anim:SetBank("city_hammer")
    anim:SetBuild("city_hammer")
    anim:PlayAnimation("idle")
    
    inst:AddTag("irreplaceable")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.HAMMER_DAMAGE)
    inst:AddTag("hammer")
    inst:AddTag("fixable_crusher")
    inst:AddTag("irreplaceable")
    

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)
    inst.components.tool.tagrequirements = {"fixable"}
    -------

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end


return Prefab( "common/inventory/city_hammer", fn, assets, prefabs) 
