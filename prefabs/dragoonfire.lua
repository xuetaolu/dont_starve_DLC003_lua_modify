local assets=
{
	
}

local prefabs=
{
	
}

local function OnLoad(inst, data)
	inst:Remove()
end

local function OnIgnite(inst)
end

local function OnExtinguish(inst)
	inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddLight()

	inst:AddTag("fire")
	inst:AddTag("NOCLICK")

	inst:AddComponent("propagator")

	inst:AddComponent("burnable")
	inst.components.burnable:AddBurnFX("campfirefire", Vector3(0,0,0) )
	inst.components.burnable:MakeNotWildfireStarter()
	inst:ListenForEvent("onextinguish", OnExtinguish)
	inst:ListenForEvent("onignite", OnIgnite)

	inst:AddComponent("fueled")
	inst.components.fueled.maxfuel = TUNING.DRAGOONFIRE_FUEL_MAX
	inst.components.fueled.accepting = false
	
	inst.components.fueled:SetSections(4)
	inst.components.fueled.rate = 1

	inst.components.fueled:SetUpdateFn( function()
		if inst.components.burnable and inst.components.fueled then
			inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
		end
	end)
		
	inst.components.fueled:SetSectionCallback( function(section)
		if section == 0 then
			inst.components.burnable:Extinguish() 
		else
			if not inst.components.burnable:IsBurning() then
				inst.components.burnable:Ignite()
			end
			
			inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
			
		end
	end)
		
	inst.components.fueled:InitializeFuelLevel(TUNING.DRAGOONFIRE_FUEL)
	  
	inst.OnLoad = OnLoad

	return inst
end

return Prefab( "common/shipwrecked/dragoonfire", fn, assets, prefabs)
