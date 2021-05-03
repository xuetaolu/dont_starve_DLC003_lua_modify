require("constants")


local assets =
{
	--Asset( "IMAGE", texture ),
	--Asset( "SHADER", shader ),
}

local prefabs =
{
	"mosquito",
	"frog"
}

local function OnWaterLevelChanged(inst, waterlevel, waterlevelprev)
	--print(waterlevel .. ", ".. waterlevelprev)
	if waterlevel > 1 then
		inst.FloodingEntity:SetRadius(2 * waterlevel)
		GetWorld().components.flooding:BroadcastFloodChange()
	end
end

local function OnWaterLevelZero(inst)
	--print("Flood dried up!")
	--inst.FloodingEntity:SetRadius(0)
	inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddFloodingEntity()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pond_cave.png" )

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst:AddComponent("floodlistener")
	inst.components.floodlistener.waterlevelchangefn = OnWaterLevelChanged
	inst.components.floodlistener.waterlevelzerofn = OnWaterLevelZero

	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "mosquito"
	inst.components.childspawner:SetRareChild("frog", 0.25)
	inst.components.childspawner:SetRegenPeriod(4 * TUNING.SEG_TIME)
	inst.components.childspawner:SetSpawnPeriod(1 * TUNING.SEG_TIME)
	inst.components.childspawner:SetMaxChildren(math.random(4, 8))
	inst.components.childspawner:StartSpawning()
	inst.components.childspawner:StartRegen()

	inst.FloodingEntity:SetRadius(2)

	inst.OnSave = function(inst, data)
	end

	inst.OnLoad = function(inst, data)
	end

    return inst
end

return Prefab( "shipwrecked/objects/floodsource", fn, assets, prefabs )
