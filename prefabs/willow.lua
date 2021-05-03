
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/willow.zip"),
	Asset("SOUND", "sound/willow.fsb"),
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = 
{
    "willowfire",
    "lighter",
}

local start_inv = 
{
	"lighter",
}

local function sanityfn(inst)
	local x,y,z = inst.Transform:GetWorldPosition()	
	local delta = 0
	local max_rad = 10
	local ents = TheSim:FindEntities(x,y,z, max_rad, {"fire"})
    for k,v in pairs(ents) do 
    	if v.components.burnable and v.components.burnable.burning then
    		local sz = TUNING.SANITYAURA_TINY
    		local rad = v.components.burnable:GetLargestLightRadius() or 1
    		sz = sz * ( math.min(max_rad, rad) / max_rad )
			local distsq = inst:GetDistanceSqToInst(v)
			delta = delta + sz/math.max(1, distsq)
    	end
    end

    if GetWorld().IsVolcano() then
    	local map = GetWorld().Map
    	if map and map:IsTileGridValid() then
			local tx, ty = map:GetTileXYAtPoint(x, y, z)
			local dist = map:GetClosestTileDist(tx, ty, GROUND.VOLCANO_LAVA, 4)
			if dist <= 4 then
				delta = math.max(delta, TUNING.SANITYAURA_TINY * (1 - (dist / 4)))
			end
		end
    end
    
    return delta
end


local function boatFireUpdate(inst, dt)
	--print(dt)
	if not inst.components.driver:GetIsDriving() then 
		--put out the fire 
		inst.components.burnable:Extinguish()
	else 
		local boatHurtRate = -10
		local amount = boatHurtRate * dt
		inst.components.driver.vehicle.components.boathealth:DoDelta(amount, "fire")
	end 



end 


local function onIgnite(inst)
	if inst.burnTask then 
		inst.burnTask:Cancel()
	end
	inst.burnTask = inst:DoPeriodicTask(0.5, function() boatFireUpdate(inst, .5) end)
end 

local function onExtinguish(inst)
	if inst.burnTask then 
		inst.burnTask:Cancel()
	end 
end 



local fn = function(inst)
	inst:AddComponent("firebug")
	inst.components.firebug.prefab = "willowfire"
	inst.components.health.fire_damage_scale = 0
	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)

	inst.components.sanity.custom_rate_fn = sanityfn
	inst.components.inventory:GuaranteeItems(start_inv)

	inst:AddTag("flingomatic_freeze_immune")
	inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(5)
    inst.components.burnable:AddBurnFX("character_fire",Vector3(0, 0, 0) )
    inst.components.burnable.canlight = false 
    inst.components.burnable:MakeNotWildfireStarter()
    inst.components.burnable:SetOnIgniteFn(onIgnite)
    inst.components.burnable:SetOnExtinguishFn(onExtinguish)
    inst.components.burnable.lightningimmune = true
end


return MakePlayerCharacter("willow", prefabs, assets, fn, start_inv) 
