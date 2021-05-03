local assets =
{
	Asset("ANIM", "anim/plant_normal.zip"),

	-- products for buildswap
    Asset("ANIM", "anim/durian.zip"),
    Asset("ANIM", "anim/eggplant.zip"),
    Asset("ANIM", "anim/dragonfruit.zip"),
    Asset("ANIM", "anim/pomegranate.zip"),
    Asset("ANIM", "anim/corn.zip"),
    Asset("ANIM", "anim/pumpkin.zip"),
    Asset("ANIM", "anim/carrot.zip"),
	Asset("ANIM", "anim/sweet_potato.zip"),
}

require "prefabs/veggies"
   
local prefabs = {}

for k,v in pairs(VEGGIES) do
    table.insert(prefabs, k)
end

local function onmatured(inst, grower)
	inst.SoundEmitter:PlaySound("dontstarve/common/farm_harvestable")
	if inst:HasTag("hydrofarm") and grower ~= nil then
		grower.AnimState:OverrideSymbol("swap_grown", inst.components.crop.product_prefab,inst.components.crop.product_prefab.."01")
	else
		inst.AnimState:OverrideSymbol("swap_grown", inst.components.crop.product_prefab,inst.components.crop.product_prefab.."01")
	end
end

local function onburnt(inst)
    local temp = SpawnPrefab(inst.components.crop.product_prefab)
    local product = nil
    if temp.components.cookable and temp.components.cookable.product and inst.components.crop.matured then
        product = SpawnPrefab(temp.components.cookable.product)
    else
        product = SpawnPrefab("seeds_cooked")
    end
    temp:Remove()

    if inst.components.stackable and product.components.stackle then
        product.components.stackable.stacksize = inst.components.stackable.stacksize
    end

    if inst.components.crop and inst.components.crop.grower and inst.components.crop.grower.components.grower then
        inst.components.crop.grower.components.grower:RemoveCrop(inst)
    end

    product.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end
    
local function OnLoadPostPass(inst)
    if inst.components.crop and not inst.components.crop.grower then
        inst.components.crop:Resume()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    
    anim:SetBank("plant_normal")
    anim:SetBuild("plant_normal")
    anim:PlayAnimation("grow")
    
    inst:AddComponent("crop")
    inst.components.crop:SetOnMatureFn(onmatured)
    inst.makewitherabletask = inst:DoTaskInTime(TUNING.WITHER_BUFFER_TIME, function(inst) inst.components.crop:MakeWitherable() end)
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst.components.crop:IsReadyForHarvest() then
            return "READY"
        elseif inst.components.crop:IsWithered() then
            return "WITHERED"
        else
            return "GROWING"
        end
    end

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:MakeDragonflyBait(1)
    
    anim:SetFinalOffset(-1)
    
    inst.OnLoadPostPass = OnLoadPostPass    

    inst:DoTaskInTime(0,function() 
        if inst.components.crop and not inst.components.crop.product_prefab then
            if inst.components.crop.task then
                inst.components.crop.task:Cancel()
                inst.components.crop.task = nil
            end
            inst.components.crop:StartGrowing("carrot", TUNING.SEEDS_GROW_TIME, inst,1)
        end
    end)    

    return inst
end

return Prefab( "common/objects/plant_normal", fn, assets, prefabs) 
