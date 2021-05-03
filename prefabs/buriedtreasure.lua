-- This seems to still work without this line, the needed functions are probably already in the global space.
require("map/treasurehunt")

local assets =
{
	Asset("ANIM", "anim/x_marks_spot.zip"),
}

local prefabs =
{
	"messagebottle",
	"collapse_small",
}

local function linkBottles(inst, count)
	print(string.format("Place %d bottles\n", count))
	for i = 1, count, 1 do
		local bottle = SpawnPrefab("messagebottle")
		bottle.treasure = inst
		bottle.PlaceBottle(bottle)
	end
end

local function linkTreasure(inst)
	local x, y, z = inst.Transform:GetLocalPosition()
	--find a treasure to link to this treasure, don't link twice
	local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"}, {"linkingtreasure"})
	if treasures and #treasures > 0 then
		local t = treasures[math.random(1, #treasures)]
		if t then
			print("Linking treasures")
			t.treasurenext = inst
			inst.treasureprev = t
			t:AddTag("linkingtreasure")
			inst:AddTag("linktreasure")
		end
	end
end

local function onfinishcallback(inst, worker)

    inst.MiniMapEntity:SetEnabled(false)
    inst:RemoveComponent("workable")
    inst.components.hole.canbury = true

	if worker then
		if inst.treasurenext and inst.treasurenext ~= nil then
			--How much longer?
			if inst.treasureprev and inst.treasureprev ~= nil and inst.treasureprev.treasureprev and inst.treasureprev.treasureprev ~= nil then
				worker.components.talker:Say(GetString(worker.prefab, "ANNOUNCE_MORETREASURE"))
			end
		end

		-- figure out which side to drop the loot
		local pt = Vector3(inst.Transform:GetWorldPosition())
		local hispos = Vector3(worker.Transform:GetWorldPosition())

		local he_right = ((hispos - pt):Dot(TheCamera:GetRightVec()) > 0)
		
		if he_right then
			inst.components.lootdropper:DropLoot(pt - (TheCamera:GetRightVec()*(math.random()+1)))
			inst.components.lootdropper:DropLoot(pt - (TheCamera:GetRightVec()*(math.random()+1)))
		else
			inst.components.lootdropper:DropLoot(pt + (TheCamera:GetRightVec()*(math.random()+1)))
			inst.components.lootdropper:DropLoot(pt + (TheCamera:GetRightVec()*(math.random()+1)))
		end
		
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/loot_reveal")
		SpawnTreasureChest(inst.loot, inst.components.lootdropper, Point(inst.Transform:GetWorldPosition()), inst.treasurenext)

		inst:Remove()
	end	
end

local function onsave(inst, data)
    if not inst.components.workable then
        data.dug = true
    end

	if inst.treasureprev and inst.treasureprev ~= nil then
		data.treasureprev = inst.treasureprev.GUID
	end
	if inst.treasurenext and inst.treasurenext ~= nil then
		data.treasurenext = inst.treasurenext.GUID
	end
	if inst.loot then
		data.loot = inst.loot
	end
	if inst.revealed then
		data.revealed = inst.revealed
	end
end

local function onload(inst, data)

    if data and data.dug or not inst.components.workable then
        inst:RemoveComponent("workable")
        inst.components.hole.canbury = true
        inst:RemoveTag("NOCLICK")
    end

    if data and data.loot and data.loot ~= nil then
    	inst.loot = data.loot
    end

    if data and data.revealed and data.revealed == true then
    	print("Reveal treasure")
    	inst:Reveal(inst)
    end
end

local function loadpostpass(inst, ents, data)

	if data then
		if data.loot and data.loot ~= nil then
			if type(data.loot) == "table" then
				inst.loot = data.loot[math.random(1, #data.loot)]
			else
				inst.loot = data.loot
			end
		end
		if data.treasureprev and data.treasureprev ~= nil then
			local ent = ents[data.treasureprev]
			if ent then
				inst.treasureprev = ent.entity
				inst:AddTag("linktreasure")
			end
		end
		if data.treasurenext and data.treasurenext ~= nil then
			local ent = ents[data.treasurenext]
			if ent then
				inst.treasurenext = ent.entity
				inst:AddTag("linkingtreasure")
			end
		end
		if data.bottles then
			linkBottles(inst, data.bottles)
		end
		if data.name then
			inst.debugname = data.name
		end
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()

	inst.entity:AddSoundEmitter()

	inst:AddTag("buriedtreasure")
	inst:AddTag("NOCLICK")
	inst.entity:Hide()

	minimap:SetIcon( "xspot.png" )
	minimap:SetEnabled(false)

    anim:SetBank("x_marks_spot")
    anim:SetBuild("x_marks_spot")
    anim:PlayAnimation("anim")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if not inst.components.workable then
            return "DUG"
        end
    end
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"boneshard"})
        
    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst:AddComponent("hole")

    inst.loot = ""
    inst.revealed = false

    inst.Reveal = function(inst)
    	print("Treasure revealed")
    	inst.revealed = true
    	inst.entity:Show()
    	inst.MiniMapEntity:SetEnabled(true)
    	inst:RemoveTag("NOCLICK")
	end

	inst.RevealFog = function(inst)
		print("Tresure fog revealed")
    	local x, y, z = inst.Transform:GetLocalPosition()
    	local minimap = GetWorld().minimap.MiniMap
    	local map = GetWorld().Map
        local cx, cy, cz = map:GetTileCenterPoint(x, 0, z)
        minimap:ShowArea(cx, cy, cz, 30)
        map:VisitTile(map:GetTileCoordsAtPoint(cx, cy, cz))
	end

	inst.IsRevealed = function(inst)
		return inst.revealed
	end

	inst.FocusMinimap = function(inst, bottle)
    	local px, py, pz = GetPlayer().Transform:GetWorldPosition()
    	local x, y, z = inst.Transform:GetLocalPosition()
    	local minimap = GetWorld().minimap.MiniMap
		print("Find treasure on minimap (" .. x .. ", "  .. z .. ")")
    	GetPlayer().HUD.controls:ToggleMap()
    	minimap:Focus(x - px, z - pz, -minimap:GetZoom()) --Zoom in all the way		
	end

	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnLoadPostPass = loadpostpass

	if math.random() < 0.2 then
		--linkTreasure(inst)
	end

	if not inst.treasurenext or inst.treasurenext == nil then
		--Spawn linked message bottles
		--linkBottles(inst, math.random(1, 3))
	end

	inst.SetRandomTreasure = function(inst)
		inst:Reveal()

		local treasures = GetTreasureLootDefinitionTable()
		local treasure = GetRandomKey(treasures)
		inst.loot = treasure
	end

    return inst
end

return Prefab( "shipwrecked/objects/buriedtreasure", fn, assets, prefabs )
