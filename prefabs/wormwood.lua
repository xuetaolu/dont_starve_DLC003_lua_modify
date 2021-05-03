
local MakePlayerCharacter = require "prefabs/player_common"

local assets = 
{
    Asset("ANIM", "anim/wormwood.zip"),
    Asset("ANIM", "anim/wormwood_stage_2.zip"),
    Asset("ANIM", "anim/wormwood_stage_3.zip"),
    Asset("ANIM", "anim/wormwood_stage_4.zip"),
    Asset("ANIM", "anim/player_wormwood.zip"),
    Asset("ANIM", "anim/player_wormwood_fertilizer.zip"),    
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {
	"wormwood_plant_fx",
	"wormwood_pollen_fx",
}

local function checkeartforbloom(inst)

	if not inst:HasTag("ironlord") then

		if inst.bloomstage == 0 then
			inst.AnimState:SetBuild("wormwood")
		elseif inst.bloomstage == 1 then
			inst.AnimState:SetBuild("wormwood_stage_2")
		elseif inst.bloomstage == 2 then
			inst.AnimState:SetBuild("wormwood_stage_3")
		elseif inst.bloomstage == 3 then
			inst.AnimState:SetBuild("wormwood_stage_4")
		end

		local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		if hat and hat.opentop then
			hat = nil		
		end
		if inst.components.bloomable.blooming and not hat then 		
			inst.AnimState:Show("BEARD")
		else
			inst.AnimState:Hide("BEARD")
		end

	end
end

local function killedplantfn(inst, penalty)
	if penalty then 
		inst.components.sanity:DoDelta(penalty)
	else
		inst.components.sanity:DoDelta(-TUNING.SANITY_TINY)
	end
	GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_KILLEDPLANT"))            
end

local function growplantfn(inst, bonus)
	if bonus then 
		inst.components.sanity:DoDelta(bonus)
	else
		inst.components.sanity:DoDelta(TUNING.SANITY_TINY)
	end	
	inst.components.sanity:DoDelta(TUNING.SANITY_TINY)
	GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_GROWPLANT"))            
end

local function canbloom(inst)
	 return true	 
end

local function spawnpollen(inst)
	inst:DoTaskInTime(math.random()*0.6, function()
		local pollen = SpawnPrefab("wormwood_pollen_fx")
		local x,y,z = inst.Transform:GetWorldPosition()
		pollen.Transform:SetPosition(x,y,z)
		pollen.AnimState:SetFinalOffset(2)
	end)

end

local function setbloomstage(inst, stage)
	inst.bloomstage = stage

	local MAX_BLOOM_PEED_MULT = 1.2

	local speed = Remap(stage, 0, 3, 1, MAX_BLOOM_PEED_MULT)

	inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED  *speed
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED *speed

    local hunger = Remap(stage, 0, 3, TUNING.WILSON_HUNGER_RATE, TUNING.WILSON_HUNGER_RATE*2)

    inst.components.hunger.hungerrate = hunger

    if stage == 3 then
		inst.components.groundpainter:Enable(true)		
		inst.components.groundpainter:SetMax(stage *6)

		if not inst.pollentask then
			inst.pollentask = inst:DoPeriodicTask(0.7,function(inst) spawnpollen(inst) end)
		end
    else
    	if inst.pollentask then
    		inst.pollentask:Cancel()
    		inst.pollentask = nil
    	end
    	inst.components.groundpainter:Enable(false)
    end
end

local function checkbloomstage(inst)
	if inst.components.bloomable.blooming then
		local sm = GetSeasonManager()
		local percent = sm:GetPercentSeason()
		if percent < 1/6 then
			setbloomstage(inst, 1)
		elseif percent < 2/6 then
			setbloomstage(inst, 2)
		elseif percent < 4/6 then
			setbloomstage(inst, 3)
		elseif percent < 5/6 then
			setbloomstage(inst, 2)
		else
			setbloomstage(inst, 1)
		end
	else
		setbloomstage(inst, 0)
	end
	checkeartforbloom(inst)
end

local function startbloom(inst, instant)
	checkbloomstage(inst)	
    if not instant then
    	GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_BLOOMING"))
    end
end

local function stopbloom(inst)
	setbloomstage(inst, 0)
	checkeartforbloom(inst)

end

local fn = function(inst)


	--inst.components.health.fire_damage_scale = 1

	inst.soundsname = "wormwood"
	inst.talker_path_override = "dontstarve_DLC003/characters/"

	inst:AddTag("donthealfromfood")
	inst:AddTag("healonfertilize")	

	inst:AddTag("plantkin")
	inst:AddTag("beebeacon")
	
	--inst:AddTag("bramble_resistant")  -- TIE THIS INTO THE BRAMBLE ARMOR

	inst.AnimState:Hide("BEARD")
	inst.AnimState:AddOverrideBuild("player_wormwood_fertilizer")

	inst:AddComponent("bloomable")
	inst.components.bloomable:SetCanBloom(canbloom)
	inst.components.bloomable:SetStartBloomFn(startbloom)
	inst.components.bloomable:SetStopBloomFn(stopbloom)
	inst.components.bloomable.season = {SEASONS.LUSH,SEASONS.GREEN,SEASONS.SPRING}
	inst.components.bloomable.timevarriance = TUNING.TOTAL_DAY_TIME/16
	inst.components.bloomable.attractbees = true

    inst.components.talker.fontsize = 36
    inst.components.talker.font = TALKINGFONT_WORMWOOD
    inst.components.talker.colour = Vector3(0.50, 0.90, .4, 1)

    inst.components.hayfever.hayfeverimune = true    

	inst:AddComponent("groundpainter")
	inst.components.groundpainter:SetPrefab("wormwood_plant_fx")
	inst.components.groundpainter:SetRange(1)
	inst.components.groundpainter:SetMax(15)
	inst.components.groundpainter:SetRate(0.25)
	inst.components.groundpainter.tags = {"wormwood_plant_fx"}	
	inst.components.groundpainter:SetNotTiles({GROUND.INVALID,GROUND.IMPASSABLE,GROUND.ROAD,GROUND.ROCKY,GROUND.WOODFLOOR,GROUND.CARPET,GROUND.BRICK,GROUND.FOUNDATION,GROUND.COBBLEROAD,GROUND.INTERIOR,GROUND.VOLCANO_ROCK,GROUND.VOLCANO,GROUND.VOLCANO_LAVA,GROUND.ASH})

	inst.bloomstage = 0

	inst.killedplantfn = killedplantfn
	inst.growplantfn = growplantfn

	local naturetab = {str = "NATURE", sort=999, icon = "tab_herbology.tex"}
	inst.components.builder:AddRecipeTab(naturetab)
	
	Recipe("livinglog", {Ingredient(CHARACTER_INGREDIENT.HEALTH, 20)}, naturetab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
	Recipe("poisonbalm", {Ingredient("livinglog", 1), Ingredient("venomgland", 1)}, naturetab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
	Recipe("armor_bramble", {Ingredient("livinglog", 2), Ingredient("boneshard", 4)}, naturetab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
	Recipe("trap_bramble", {Ingredient("livinglog", 1), Ingredient("stinger", 1)}, naturetab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
	Recipe("compostwrap", {Ingredient("poop", 5), Ingredient("spoiled_food", 2), Ingredient("nitre", 1)}, naturetab, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})

	inst:ListenForEvent("equip", function()   checkeartforbloom(inst) end )
	inst:ListenForEvent("unequip", function() checkeartforbloom(inst) end)

	inst:ListenForEvent("daytime", function() print("NEW DAY") checkbloomstage(inst) end, GetWorld())

    MakeMediumBurnableCharacter(inst, "body")
    inst.components.burnable:SetBurnTime(4)
    inst.components.burnable.flammability = 0.5

    inst.components.talker.endspeechsound = "dontstarve_DLC003/characters/wormwood/end"

    MakeSmallPropagator(inst)
end

if Profile then
	Profile:UnlockCharacter("wormwood")
end

return MakePlayerCharacter("wormwood", prefabs, assets, fn) 
