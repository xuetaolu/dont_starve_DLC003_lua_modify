require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/icemachine.zip"),
}

local prefabs =
{
	"coffeebeans_cooked",
	"collapse_small",
}


local function fn(Sim)

	local inst = CreateEntity()

    inst:AddTag("structure")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	local spawncoffee

	local function onhammered(inst, worker)
		inst.components.lootdropper:DropLoot()
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
		
		inst:Remove()
	end

	local function onhit(inst, worker)
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle", true)
		inst:RemoveEventCallback("animover", spawncoffee)
	end
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "icemachine.png" )
	
	inst.AnimState:SetBank("icemachine")
	inst.AnimState:SetBuild("icemachine")
	inst.AnimState:PlayAnimation("idle", true)
	
	MakeObstaclePhysics(inst, .4)    
	

	inst:AddComponent("lootdropper")

	inst:AddComponent("fueled")
	local fueled = inst.components.fueled

	local fueltask
	local fueltaskfn

	spawncoffee = function ()
		-- spawn
		inst.components.lootdropper:SpawnLootPrefab("coffee")
		inst:RemoveEventCallback("animover", spawncoffee)

		if fueled:IsEmpty() then
			inst.AnimState:PlayAnimation("idle")
		else
			inst.AnimState:PlayAnimation("proximity_loop", true)
		end
	end
	
	fueltaskfn = function()
		inst.AnimState:PlayAnimation("use")
		inst:ListenForEvent("animover", spawncoffee)
	end

	fueled.maxfuel = TUNING.CAMPFIRE_FUEL_MAX
	fueled.accepting = true
	fueled:SetSections(4)

	fueled.ontakefuelfn = function()
		print(fueled:GetDebugString())
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
		fueled:StartConsuming()
	end
	
	fueled:SetUpdateFn( function()
		-- TODO: summer season rate adjustment?
		fueled.rate = 1
	end )
	
	fueled:SetSectionCallback(
		function(section)
			if section == 0 then
				inst.AnimState:PlayAnimation("idle", true)
				if fueltask then
					fueltask:Cancel()
					fueltask = nil
				end
			else
				inst.AnimState:PlayAnimation("proximity_loop", true) 
				fueled.rate = 1
				if fueltask == nil then
					fueltask = inst:DoPeriodicTask(TUNING.ICEMAKER_SPAWN_TIME, fueltaskfn)
				end
			end
		end)
		
	fueled:InitializeFuelLevel(0)
	fueled:StartConsuming()
	
	-----------------------------
	
	-- this doesn't work...
	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = function(inst)
		local sec = fueled:GetCurrentSection()
		if sec == 0 then 
			return "OUT"
		elseif sec <= 4 then
			local t= {"EMBERS","LOW","NORMAL","HIGH"} 
			return t[sec]
		end
	end
	

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	return inst
end

return Prefab( "common/objects/coffeebot", fn, assets, prefabs),
		MakePlacer( "common/coffeebot_placer", "icemachine", "icemachine", "idle" ) 
