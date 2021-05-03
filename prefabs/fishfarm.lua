require "prefabutil"
require "tuning"

local assets =
{
	Asset("ANIM", "anim/fish_farm.zip"),
	Asset("MINIMAP_IMAGE", "fish_farm"),
}

local prefabs = 
{
    "fish_farm_sign"
}

local usedFishStates = {}
local unusedFishStates={1,2,3,4,5,6,7,8}

local function onRemove(inst)
    if inst.sign_prefab then
        inst.sign_prefab:Remove()
    end
end

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	if inst.components.breeder then inst.components.breeder:Reset() end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
end

local function onhit(inst, worker)
	--inst.AnimState:PlayAnimation("hit")
	--inst.AnimState:PushAnimation("idle")
end

local rates = 
{
	TUNING.FARM1_GROW_BONUS,
	TUNING.FARM2_GROW_BONUS,
	TUNING.FARM3_GROW_BONUS,
}

local croppoints = {
	{ Vector3(0,0,0) },
	{ Vector3(0,0,0) },
	{ Vector3(0,0,0) },
}

local function resetArt(inst)    
    inst.AnimState:Hide("sign")
    inst.AnimState:Hide("fish_1")    
    inst.AnimState:Hide("fish_2")
    inst.AnimState:Hide("fish_3")
    inst.AnimState:Hide("fish_4")
    inst.AnimState:Hide("fish_5")
    inst.AnimState:Hide("fish_6")
    inst.AnimState:Hide("fish_7")
    inst.AnimState:Hide("fish_8")    
    inst.AnimState:Hide("fish_9")    
end

local function switchTables(fromTable,toTable)
        
    local randNum = math.random(#fromTable)
    local fishLayer = fromTable[randNum]
    table.remove(fromTable,randNum)
    table.insert(toTable,fishLayer)    

    return fishLayer
end

local function refreshArt(inst)
    if inst.sign_prefab then
        inst.sign_prefab.resetArt(inst.sign_prefab)
    end
    --[[
    if inst.components.breeder.seeded then        
    --    inst.AnimState:Show("sign")
    else
        inst.AnimState:Hide("sign")
    end
    ]]

    if inst.volume ~= inst.components.breeder.volume then
        local fishLayer = 0
       
        for i=1,math.abs(inst.volume - inst.components.breeder.volume) do
            if inst.volume < inst.components.breeder.volume then
                if inst.volume == inst.components.breeder.max_volume -1 then
                    table.insert(inst.usedFishStates,9)                    
                    inst.AnimState:Show("fish_9")
                else
                    local loop = 1
                    if #inst.usedFishStates > 0 then                    
                        loop = 2
                    end
                    for i=1,loop do
                        inst.AnimState:Show("fish_"..switchTables(inst.unusedFishStates,inst.usedFishStates)) 
                    end
                end
                inst.volume = inst.volume + 1
            else
                if inst.volume == inst.components.breeder.max_volume then
                    table.remove(inst.usedFishStates,#inst.usedFishStates)
                    inst.AnimState:Hide("fish_9")
                else
                    local loop = 1
                    if #inst.usedFishStates > 1 then                    
                        loop = 2
                    end
                    for i=1,loop do
                        inst.AnimState:Hide("fish_"..switchTables(inst.usedFishStates,inst.unusedFishStates))
                    end
                end
                inst.volume = inst.volume -1
            end
        end
    end
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data then
		if data.burnt then
        	inst.components.burnable.onburnt(inst)
       	end
    end
    resetArt(inst)
    refreshArt(inst)
end

local function spawnSign(inst)
    local pt =   Vector3(inst.Transform:GetWorldPosition())
    --pt.x = pt.x+1
    inst.sign_prefab = SpawnPrefab("fish_farm_sign")
    inst.sign_prefab.Transform:SetPosition(pt.x,0,pt.z)
    inst.sign_prefab.parent = inst
    inst.sign_prefab.resetArt(inst.sign_prefab)
end

local function onbuilt(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_submerge_med")
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_medium")
	refreshArt(inst)
end

local function placeTestFn(inst, pt)

    if not inst.arthidden then

        inst.AnimState:Hide("mouseover")
        inst.AnimState:Hide("sign")
        inst.AnimState:Hide("fish_1")    
        inst.AnimState:Hide("fish_2")
        inst.AnimState:Hide("fish_3")
        inst.AnimState:Hide("fish_4")
        inst.AnimState:Hide("fish_5")
        inst.AnimState:Hide("fish_6")
        inst.AnimState:Hide("fish_7")
        inst.AnimState:Hide("fish_8")    
        inst.AnimState:Hide("fish_9") 

        inst.arthidden = true
    end

    local range = 5
    local canbuild = false
    
    local blocks = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"structure"}, nil)

    if #blocks < 1 then
        canbuild = true      
    end
    return canbuild
end

local function fn(Sim)
	

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    
    inst:AddTag("structure")
    inst:AddTag("fishfarm")
    
    anim:SetBank("fish_farm")
    anim:SetBuild("fish_farm")
    anim:PlayAnimation( "idle",true)
	--anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "fish_farm.png" )

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "FISH_FARM"
    inst.components.inspectable.getstatus = function(inst)
        if inst.components.breeder.volume > 0 then
            if inst.components.breeder.volume == 1 then
                return "ONEFISH"
            elseif inst.components.breeder.volume == 2 then
                return "TWOFISH"
            elseif inst.components.breeder.volume == 3 then
                return "REDFISH"
            elseif inst.components.breeder.volume == 4 then
                return "BLUEFISH"
            end
        else
            if inst.components.breeder.seeded then
                return "STOCKED"
            else
                return "EMPTY"
            end
        end
    end

    inst.OnSave = onsave 
    inst.OnLoad = onload        
        
    inst:AddComponent("breeder")    
    inst.components.breeder.onseedfn = function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_small")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/pickobject_water")
    end  
   -- inst.components.breeder.updateFn = updateFn
	
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

    inst.volume = 0
    inst.usedFishStates = {}
    inst.unusedFishStates={1,2,3,4,5,6,7,8}

    inst.OnRemoveEntity = onRemove

	inst:ListenForEvent("onbuilt", function () onbuilt(inst) end)
    
	inst:ListenForEvent("onVisChange", function () refreshArt(inst) end)

    inst.AnimState:Hide("mouseover")

    inst:DoTaskInTime(0,function()  spawnSign(inst) end)
   
    
    resetArt(inst)
	refreshArt(inst)
    
    return inst

end    

return Prefab( "common/objects/fish_farm", fn, assets, prefabs ),	   
	   MakePlacer( "common/fish_farm_placer", "fish_farm", "fish_farm", "idle", nil, nil, nil, nil, nil, nil, 90, nil, nil, placeTestFn) 


