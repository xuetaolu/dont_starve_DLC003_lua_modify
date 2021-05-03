local assets=
{
	--Asset("ANIM", "anim/umbrella.zip"),
	--Asset("ANIM", "anim/swap_umbrella.zip"),
   -- Asset("ANIM", "anim/swap_parasol.zip"),
    --Asset("ANIM", "anim/parasol.zip"),
}
  

local function onfinished(inst)
    inst:Remove()
end
  
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    inst:AddTag("aquatic")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst:AddComponent("inspectable") --Work around for script error until we replace this with a widget 

    return inst
end


return Prefab( "common/inventory/boat_indicator", fn, assets)
