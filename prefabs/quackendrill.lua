require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/quacken_drill.zip"),
	Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{

}    


local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype == GROUND.OCEAN_MEDIUM or tiletype == GROUND.OCEAN_DEEP 
    
    local ground = GetWorld()

	if ground_OK then
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		
		return true

	end
	return false	
end

local function spawnoil(inst,pt)	
	local oil = SpawnPrefab("tar_pool") 
	if oil then 
		oil.Transform:SetPosition(pt.x, pt.y, pt.z) 
		oil.AnimState:PlayAnimation("place")
		oil.AnimState:PushAnimation("idle",true)
	end
	inst:Remove()
end

local function nextstage(inst,pt)
	if not inst.drillstage then
		inst.AnimState:PlayAnimation("idle",true)
		inst.drillstage = 1
		inst:DoTaskInTime(2,function(inst) nextstage(inst,pt)  end)

	elseif inst.drillstage == 1 then
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/quacken_drill/drill") 
		inst.AnimState:PlayAnimation("drill")	
		inst:ListenForEvent("animover", function(inst) nextstage(inst,pt)  end)
		inst.drillstage = 2
	else
		local SHAKE_DIST = 40
		local player = GetClosestInstWithTag("player", inst, SHAKE_DIST)			
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/quacken_drill/underwater_hit") 	
		player.components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, 3, SHAKE_DIST)		
		inst:Hide()
		inst:DoTaskInTime(2,function(inst) spawnoil(inst,pt)  end)
	end
end

local function ondeploy(inst, pt)	
	inst.Transform:SetPosition(pt.x, pt.y, pt.z) 
	inst.AnimState:PlayAnimation("place")
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/quacken_drill/ramp") 
	inst:ListenForEvent("animover", nextstage(inst,pt) )	
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("quacken_drill")
	inst.AnimState:SetBuild("quacken_drill")
	inst.AnimState:PlayAnimation("dropped")
	
	inst:AddComponent("inspectable")
	--inst.components.inspectable.nameoverride = data.inspectoverride or "dug_"..data.name
	inst:AddComponent("inventoryitem")
    
	inst:AddTag("fire_proof")

	
    inst:AddComponent("deployable")
    --inst.components.deployable.test = function() return true end
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.test = test_ground
    inst.components.deployable.min_spacing = 2
    
    
	MakeInventoryFloatable(inst, "dropped_water", "dropped")
	inst.useownripples = true
	---------------------  

	return inst      
end

return Prefab( "common/objects/quackendrill", fn, assets,prefabs),
	   MakePlacer( "common/quackendrill_placer", "quacken_drill", "quacken_drill", "placer" )


