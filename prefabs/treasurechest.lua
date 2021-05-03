require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/treasure_chest.zip"),
	Asset("ANIM", "anim/ui_chest_3x2.zip"),
	Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),

	Asset("ANIM", "anim/pandoras_chest.zip"),
	Asset("ANIM", "anim/skull_chest.zip"),
	Asset("ANIM", "anim/pandoras_chest_large.zip"),
	Asset("ANIM", "anim/luggage.zip"),
	Asset("ANIM", "anim/octopus_chest.zip"),
	Asset("ANIM", "anim/kraken_chest.zip"),
	Asset("ANIM", "anim/water_chest.zip"),
	Asset("ANIM", "anim/ant_chest.zip"),
	Asset("ANIM", "anim/ant_chest_honey_build.zip"),
	Asset("ANIM", "anim/ant_chest_nectar_build.zip"),
	Asset("ANIM", "anim/treasure_chest_cork.zip"),	

	Asset("ANIM", "anim/treasure_chest_roottrunk.zip"),	
	
	Asset("MINIMAP_IMAGE", "treasure_chest"),
	Asset("MINIMAP_IMAGE", "minotaur_chest"),
	Asset("MINIMAP_IMAGE", "pandoras_chest"),
	Asset("MINIMAP_IMAGE", "luggage_chest"),
	Asset("MINIMAP_IMAGE", "kraken_chest"),
	Asset("MINIMAP_IMAGE", "water_chest"),
	Asset("MINIMAP_IMAGE", "ant_chest"),
	Asset("MINIMAP_IMAGE", "ant_chest_honey"),
	Asset("MINIMAP_IMAGE", "ant_chest_nectar"),
	Asset("MINIMAP_IMAGE", "cork_chest"),	
	Asset("MINIMAP_IMAGE", "root_chest_child"),	
}

local prefabs =
{
	"collapse_small",
}

local chests =
{
	treasure_chest =
	{
		bank  = "chest",
		build = "treasure_chest",
	},
	skull_chest =
	{
		bank  = "skull_chest",
		build = "skull_chest",
	},
	pandoras_chest =
	{
		bank  = "pandoras_chest",
		build = "pandoras_chest",
	},
	minotaur_chest =
	{
		bank  = "pandoras_chest_large",
		build = "pandoras_chest_large",
	},
	luggage_chest =
	{
		bank  = "luggage",
		build = "luggage",
	},
	octopus_chest =
	{
		bank  = "octopus_chest",
		build = "octopus_chest",
	},
	kraken_chest =
	{
		bank  = "kraken_chest",
		build = "kraken_chest",
	},
	water_chest =
	{
		bank  = "water_chest",
		build = "water_chest",
	},
	ant_chest =
	{
		bank  = "ant_chest",
		build = "ant_chest",
	},
	cork_chest =
	{
		bank  = "treasure_chest_cork",
		build = "treasure_chest_cork",
	},
	root_chest =
	{
		bank  = "roottrunk",
		build = "treasure_chest_roottrunk",
	},	
	root_chest_child =
	{
		bank  = "roottrunk",
		build = "treasure_chest_roottrunk",
	},			
}

local function testitem_honeychest(inst, item, slot)
	return item.prefab == "honey" or item.prefab == "nectar_pod"
end

local function onopen(inst) 
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")

		if inst:HasTag("aquatic") then
			inst.AnimState:PushAnimation("opened", true)
		end

		if inst.prefab == "luggagechest" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/steamer_trunk/steamer_trunk_open")
		elseif inst.prefab == "corkchest" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/cork_chest/open")
		elseif inst.prefab == "antchest" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/honey_chest/open")
		elseif inst.prefab == "roottrunk_child" then
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/root_trunk/open")
		else
			inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
		end
	end
end

local function onclose(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")

		if inst:HasTag("aquatic") then
			inst.AnimState:PushAnimation("closed", true)
		end
		
		if inst.prefab == "luggagechest" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/steamer_trunk/steamer_trunk_close")
		elseif inst.prefab == "corkchest" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/cork_chest/close")
		elseif inst.prefab == "antchest" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/honey_chest/open")			
		elseif inst.prefab == "roottrunk_child" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/root_trunk/open")
		else		
			inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		end
	end
end



local function oncloseocto(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")

		if not inst.components.container:IsEmpty() then
			inst.AnimState:PushAnimation("closed", true)
			return
		else
		
			inst.AnimState:PushAnimation("sink", false)
			
			inst:DoTaskInTime(96*FRAMES, function (inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_small")
			end)

			inst:ListenForEvent("animqueueover", function (inst)
				inst:Remove()
			end)
		end
	end
end 

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", true)
		if inst.components.container then 
			inst.components.container:DropEverything() 
			inst.components.container:Close()
		end
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", true)
	if inst.prefab == "corkchest" then
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/cork_chest/place")
	elseif inst.prefab == "roottrunk_child" then
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/root_trunk/place")
	else
		inst.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
	end	
	
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
		data.burnt = true
	end

	if inst.honeyWasLoaded then
		data.honeyWasLoaded = inst.honeyWasLoaded
	end
end

local joecounter = 1
local function onload(inst, data)
	if data and data.burnt then
		inst.components.burnable.onburnt(inst)
	end

	if (inst.prefab == "antchest") and data and data.honeyWasLoaded then
		inst.honeyWasLoaded = data.honeyWasLoaded
	end

	-- from the worldgen data
	if data and data.joeluggage then
		joecounter = joecounter%4
		inst:AddComponent("scenariorunner")
		inst.components.scenariorunner:SetScript("chest_luggage"..tostring(joecounter + 1))
		inst.components.scenariorunner:Run()
		joecounter = joecounter + 1
	end
end

local slotpos = {}

for y = 2, 0, -1 do
	for x = 0, 2 do
		table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80, 0))
	end
end

local octo_slotpos = {}
						
for y = 0, 3 do
	table.insert(octo_slotpos, Vector3(-162 +(75/2), -y*75 + 114, 0))
end

local root_slotpos = {}

for y = 2.5, -0.5, -1 do
	for x = 0, 2 do
		table.insert(root_slotpos, Vector3(75*x-75*2+75, 75*y-75*2+75,0))
	end
end

local function LoadHoneyFirstTime(inst)
	if not inst.honeyWasLoaded then
		inst.honeyWasLoaded = true

		for index = 1, #slotpos, 1 do
			inst.components.container:GiveItem(SpawnPrefab("honey"), index, Vector3(inst.Transform:GetWorldPosition()))
		end
	end
end

local function RefreshAntChestBuild(inst, minimap)
	local containsHoney  = false
	local containsNectar = false

	for index = 1, #slotpos, 1 do
		local item = inst.components.container:GetItemInSlot(index)

		if item then
			if item.prefab == "honey" then
				containsHoney = true
			end

			if item.prefab == "nectar_pod" then
				containsNectar = true
			end
		end
	end

	if containsHoney then
		inst.AnimState:SetBuild("ant_chest_honey_build")
		minimap:SetIcon("ant_chest_honey.png")
	elseif containsNectar then
		inst.AnimState:SetBuild("ant_chest_nectar_build")
		minimap:SetIcon("ant_chest_nectar.png")
	else
		inst.AnimState:SetBuild("ant_chest")
		minimap:SetIcon("ant_chest.png")
	end
end

local function chest(style, aquatic)
	local fn = function(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon(style..".png")

		inst:AddTag("structure")
		inst:AddTag("chest")
		inst.AnimState:SetBank(chests[style].bank)
		inst.AnimState:SetBuild(chests[style].build)
		inst.AnimState:PlayAnimation("closed", true)

		inst:AddComponent("floatable")

		inst:AddComponent("inspectable")
		inst:AddComponent("container")
		inst.components.container:SetNumSlots(#slotpos)

		inst.components.container.onopenfn = onopen
		inst.components.container.onclosefn = onclose

		inst.components.container.widgetslotpos = slotpos
		inst.components.container.widgetanimbank = "ui_chest_3x3"
		inst.components.container.widgetanimbuild = "ui_chest_3x3"
		inst.components.container.widgetpos = Vector3(0, 200, 0)
		inst.components.container.side_align_tip = 160

		if style == "ant_chest" then
			inst.components.container.itemtestfn = testitem_honeychest
    		inst:ListenForEvent("itemget", function() RefreshAntChestBuild(inst, minimap) end)
    		inst:ListenForEvent("itemlose", function() RefreshAntChestBuild(inst, minimap) end)
			inst:DoTaskInTime(0.01, function() LoadHoneyFirstTime(inst) end)
		end
		if style == "root_chest" then
			inst:ListenForEvent("onremove", function() assert(false,"MAIN ROOT CHEST WAS REMOVED SOMEHOW") end)
		end
		if style == "root_chest" or style == "root_chest_child" then
			inst.components.container:SetNumSlots(#root_slotpos, true)
			inst.components.container.widgetslotpos = root_slotpos
			inst.components.container.widgetpos = Vector3(75, 200, 0)
		    inst.components.container.widgetanimbank = "ui_chester_shadow_3x4"
		    inst.components.container.widgetanimbuild = "ui_chester_shadow_3x4"			
		end

		if style == "root_chest_child" then
			inst:ListenForEvent("onopen", function() if GetWorld().components.roottrunkinventory then GetWorld().components.roottrunkinventory:empty(inst) end end)
			inst:ListenForEvent("onclose", function() if GetWorld().components.roottrunkinventory then GetWorld().components.roottrunkinventory:fill(inst) end end)
		end

		if style == "cork_chest" then
			inst.components.container:SetNumSlots(#octo_slotpos, true)
			inst.components.container.widgetslotpos = octo_slotpos
			inst.components.container.widgetpos = Vector3(75, 200, 0)
		    inst.components.container.widgetanimbank = "ui_thatchpack_1x4"
		    inst.components.container.widgetanimbuild = "ui_thatchpack_1x4"
			
			inst:AddTag("pogproof")
		end

		if style ~= "octopus_chest" then
			inst:AddComponent("lootdropper")
			inst:AddComponent("workable")
			inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
			inst.components.workable:SetWorkLeft(2)
			inst.components.workable:SetOnFinishCallback(onhammered)
			inst.components.workable:SetOnWorkCallback(onhit)
		else
			MakeInventoryPhysics(inst)
			inst:AddComponent("inventoryitem")
			inst.components.inventoryitem.canbepickedup = false
			inst.components.inventoryitem.cangoincontainer = false
			inst.components.inventoryitem.nobounce = true
			inst.components.container.onclosefn = oncloseocto
			inst.components.container:SetNumSlots(#octo_slotpos, true)

			inst.components.container.widgetslotpos = octo_slotpos
			inst.components.container.widgetpos = Vector3(75, 200, 0)
		    inst.components.container.widgetanimbank = "ui_thatchpack_1x4"
		    inst.components.container.widgetanimbuild = "ui_thatchpack_1x4"
		end

		inst:ListenForEvent( "onbuilt", onbuilt)
		MakeSnowCovered(inst, 0.01)	

		if style ~= "water_chest" then
			MakeSmallBurnable(inst, nil, nil, true)
			MakeSmallPropagator(inst)
		end

		inst.OnSave = onsave 
		inst.OnLoad = onload

		if aquatic then
			inst:AddTag("aquatic")
			inst:AddComponent("waterproofer")
    		inst.components.waterproofer.effectiveness = 0
		end

		return inst
	end

	return fn
end



return Prefab("common/treasurechest", chest("treasure_chest"), assets, prefabs),
		MakePlacer("common/treasurechest_placer", "chest", "treasure_chest", "closed"),
		Prefab("common/pandoraschest", chest("pandoras_chest"), assets, prefabs),
		Prefab("common/skullchest", chest("skull_chest"), assets, prefabs),
		Prefab("common/minotaurchest", chest("minotaur_chest"), assets, prefabs),
		Prefab("common/luggagechest", chest("luggage_chest", true), assets, prefabs),
		Prefab("common/octopuschest", chest("octopus_chest", true), assets, prefabs),
		Prefab("common/krakenchest", chest("kraken_chest", true), assets, prefabs),
		Prefab("common/waterchest", chest("water_chest", true), assets, prefabs),
		Prefab("common/antchest", chest("ant_chest"), assets, prefabs),
		Prefab("common/corkchest", chest("cork_chest"), assets, prefabs),		
		MakePlacer("common/corkchest_placer", "chest", "treasure_chest_cork", "closed"),
		MakePlacer("common/waterchest_placer", "water_chest", "water_chest", "closed"),
		Prefab("common/roottrunk", chest("root_chest"), assets, prefabs),
		Prefab("common/roottrunk_child", chest("root_chest_child"), assets, prefabs),
		MakePlacer("common/roottrunk_child_placer", "roottrunk", "treasure_chest_roottrunk", "closed")