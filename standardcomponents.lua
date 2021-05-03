function GetWorldCollision()
    local worldCollision = { forest = COLLISION.WORLD_01, shipwrecked = COLLISION.WORLD_01, porkland = COLLISION.WORLD_01, volcanolevel = COLLISION.WORLD_01, cave = COLLISION.WORLD_01 }
    return worldCollision[GetWorld().prefab]
end

function GetWaterCollision()
    local waterCollision = { forest = COLLISION.WORLD_01, shipwrecked = COLLISION.WORLD_01, porkland = COLLISION.WORLD_02, volcanolevel = COLLISION.WORLD_01, cave = COLLISION.WORLD_01 }
    return waterCollision[GetWorld().prefab]
end

function SetAquaticEntityCollision(inst)
    if GetWorld().prefab == "shipwrecked" then
        inst.Physics:CollidesWith(COLLISION.GROUND)
    else
        inst.Physics:CollidesWith(COLLISION.WORLD_01)
    end
end

function DefaultIgniteFn(inst)
	if inst.components.burnable then inst.components.burnable:Ignite() end 
end

function DefaultBurnFn(inst)
    if inst.components.inventoryitem and not inst.components.inventoryitem:IsHeld() then
        inst.inventoryitemdata = 
        {
            ["foleysound"] = inst.components.inventoryitem.foleysound,
            ["onputininventoryfn"] = inst.components.inventoryitem.onputininventoryfn,
            ["cangoincontainer"] = inst.components.inventoryitem.cangoincontainer,
            ["nobounce"] = inst.components.inventoryitem.nobounce,
            ["canbepickedup"] = inst.components.inventoryitem.canbepickedup,
            ["imagename"] = inst.components.inventoryitem.imagename,
            ["atlasname"] = inst.components.inventoryitem.atlasname,
            ["ondropfn"] = inst.components.inventoryitem.ondropfn,
            ["onpickupfn"] = inst.components.inventoryitem.onpickupfn,
            ["trappable"] = inst.components.inventoryitem.trappable,
            ["isnew"] = inst.components.inventoryitem.isnew,
            ["keepondeath"] = inst.components.inventoryitem.keepondeath,
            ["onactiveitemfn"] = inst.components.inventoryitem.onactiveitemfn,
            ["candrop"] = inst.components.inventoryitem.candrop,
        }
        inst:RemoveComponent("inventoryitem")
    end
    if not inst:HasTag("tree") and not inst:HasTag("structure") and not inst.persists == false then
        inst.persists = false
    end

    if inst.components.spawner and inst:HasTag("dumpchildrenonignite") and inst.components.spawner:IsOccupied() then
        inst.components.spawner:ReleaseChild()
    end
end

function DefaultBurntFn(inst)
    if inst.components.growable then
        inst:RemoveComponent("growable")
    end

    if inst.inventoryitemdata then inst.inventoryitemdata = nil end

    if inst.components.workable and inst.components.workable.action ~= ACTIONS.HAMMER then
        inst.components.workable:SetWorkLeft(0)
    end

    if not inst:GetIsOnWater() then
        local ash = SpawnPrefab("ash")
        local x, y, z = inst.Transform:GetWorldPosition()
        ash.Transform:SetPosition(x, y, z)
        
        if inst.components.stackable then
            ash.components.stackable.stacksize = inst.components.stackable.stacksize
        end
    end

    inst:Remove()
end

function DefaultExtinguishFn(inst)
    if not inst:HasTag("tree") and not inst:HasTag("structure") then
        inst.persists = true
    end
end

function DefaultBurntStructureFn(inst)
    inst:AddTag("burnt")
    inst.components.burnable.canlight = false
    if inst.AnimState then
        inst.AnimState:PlayAnimation("burnt", true)
    end
    inst:PushEvent("burntup")
    if inst.SoundEmitter then
        inst.SoundEmitter:KillSound("idlesound")
        inst.SoundEmitter:KillSound("sound")
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:KillSound("snd")
    end
    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetEnabled(false)
    end
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.components.childspawner then
        if inst:GetTimeAlive() > 5 then inst.components.childspawner:ReleaseAllChildren() end
        inst.components.childspawner:StopSpawning()
        inst:RemoveComponent("childspawner")
    end
    if inst.components.container then
        inst.components.container:DropEverything()
        inst.components.container:Close()
        inst:RemoveComponent("container")
    end
    if inst.components.dryer then
        inst.components.dryer:StopDrying("fire")
        inst:RemoveComponent("dryer")
    end
    if inst.components.stewer then
       inst.components.stewer:StopCooking("fire") 
       inst:RemoveComponent("stewer")
    end
    if inst.components.harvestable then
        inst.components.harvestable:StopGrowing()
        inst:RemoveComponent("harvestable")
    end
    if inst.components.sleepingbag then
        inst:RemoveComponent("sleepingbag")
    end
    if inst.components.grower then
        inst.components.grower:Reset("fire")
        inst:RemoveComponent("grower")
    end
    if inst.components.spawner then
        if inst:GetTimeAlive() > 5 then inst.components.spawner:ReleaseChild() end
        inst:RemoveComponent("spawner")
    end
    if inst.components.prototyper then
        inst:RemoveComponent("prototyper")
    end
    if inst.Light then
        inst.Light:Enable(false)
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
    if inst.components.floodable then 
        inst:RemoveComponent("floodable")
    end 
    inst:RemoveTag("dragonflybait_lowprio")
    inst:RemoveTag("dragonflybait_medprio")
    inst:RemoveTag("dragonflybait_highprio")
end

local burnfx = 
{
    character = "character_fire",
    generic = "fire",
}

function MakeSmallBurnable(inst, time, offset, structure)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(time or 5)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    if structure then
        inst.components.burnable:SetOnBurntFn(DefaultBurntStructureFn)
        inst.components.burnable:MakeDragonflyBait(2)
    else
        inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    end
end

function MakeMediumBurnable(inst, time, offset, structure)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(time or 10)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)

    if structure then
        inst.components.burnable:SetOnBurntFn(DefaultBurntStructureFn)
        inst.components.burnable:MakeDragonflyBait(2)
    else
        inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    end
end

function MakeLargeBurnable(inst, time, offset, structure)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(4)
    inst.components.burnable:SetBurnTime(time or 15)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)

    if structure then
        inst.components.burnable:SetOnBurntFn(DefaultBurntStructureFn)
        inst.components.burnable:MakeDragonflyBait(2)
    else
        inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    end
end

function MakeSmallPropagator(inst)
   
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 5 + math.random()*5
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 3
    inst.components.propagator.heatoutput = 8
    
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true
end

function MakeMediumPropagator(inst)
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 10+math.random()*10
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 4
    inst.components.propagator.heatoutput = 8.5--12

    inst.components.propagator.damagerange = 3
    inst.components.propagator.damages = true
end

function MakeLargePropagator(inst)
    
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 15+math.random()*10
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 6
    inst.components.propagator.heatoutput = 12
    
    inst.components.propagator.damagerange = 3
    inst.components.propagator.damages = true
end

function MakeSmallBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(1)
    inst.components.burnable:SetBurnTime(6)
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)
    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeMediumBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable.canlight = false
    inst.components.burnable:SetBurnTime(8)
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)
    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeLargeBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable.canlight = false
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)
    MakeLargePropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeAreaPoisoner(inst, poisonrange)
    inst:AddComponent("areapoisoner")
    inst.components.areapoisoner.poisonrange = poisonrange or 0
end

function MakePoisonableCharacter(inst, sym, offset, damage_penalty, attack_period_penalty, speed_penalty, hunger_burn)
    inst:AddComponent("poisonable")
    inst:AddTag("poisonable")
    inst.components.poisonable:AddPoisonFX("poisonbubble", offset or Vector3(0, 0, 0), sym)
    
    inst.components.poisonable:SetOnPoisonedFn(function()
        if inst.components.combat then
            inst.components.combat:AddDamageModifier("poison", damage_penalty or TUNING.POISON_DAMAGE_MOD)
            inst.components.combat:AddPeriodModifier("poison", attack_period_penalty or TUNING.POISON_ATTACK_PERIOD_MOD)
        end

        if inst.components.locomotor then
            inst.components.locomotor:AddSpeedModifier_Mult("poison", speed_penalty or TUNING.POISON_SPEED_MOD)
        end

        if inst.components.hunger then
            inst.components.hunger:AddBurnRateModifier("poison", hunger_burn or TUNING.POISON_HUNGER_DRAIN_MOD)
        end
    end)
    
    inst.components.poisonable:SetOnCuredFn(function()
        if inst.components.combat then
            inst.components.combat:RemoveDamageModifier("poison")
            inst.components.combat:RemovePeriodModifier("poison")
        end

        if inst.components.locomotor then
            inst.components.locomotor:RemoveSpeedModifier_Mult("poison")
        end

        if inst.components.hunger then
            inst.components.hunger:RemoveBurnRateModifier("poison")
        end
    end)
end

local shatterfx = 
{
    character = "shatter",
}

function MakeTinyFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(1)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeSmallFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(2)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeMediumFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(3)
    inst.components.freezable:SetResistance(2)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeLargeFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(4)
    inst.components.freezable:SetResistance(3)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeHugeFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(5)
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeInventoryPhysics(inst)
    inst.entity:AddPhysics()
    inst.Physics:SetSphere(.5)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(.1)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND) --inst.Physics:CollidesWith(COLLISION.WORLD) [dg] Trying this
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end


function MakeCharacterPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(GetWaterCollision())
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function MakeUnderwaterCharacterPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(GetWaterCollision())    
end

function MakeAmphibiousCharacterPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    SetAquaticEntityCollision(inst)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
    inst:AddTag("amphibious")
end

function MakeAmphibiousGhostPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function MakeGhostPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

-- THIS PHYSICS DEF WILL IGNORE INTERIOR WALLS. FOR SHADOW HANDS
function MakeSpecialGhostPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WAVES)
end


function MakeNoPhysics(inst, mass, rad)
    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
end


function ChangeToGhostPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.WORLD)
    -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function ChangeToCharacterPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(GetWaterCollision())
    -- inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function ChangeToUndergroundCharacterPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function ChangeToObstaclePhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:SetMass(0) 
    -- inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function ChangeToInventoryPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND) --inst.Physics:CollidesWith(COLLISION.WORLD) [dg] Trying this
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function ChangeToUnderwaterCharacterPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(GetWaterCollision())
    -- inst.Physics:CollidesWith(COLLISION.WORLD)
end

function MakeObstaclePhysics(inst, rad, height)
    height = height or 2

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    --this is lame. Bullet wants 0 mass for static objects, 
    -- for for some reason it is slow when we do that
    
    -- Doesnt seem to slow anything down now.
    inst.Physics:SetMass(0) 
    inst.Physics:SetCapsule(rad,height)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end

function MakeWallPhysics(inst, rad, height)
    height = height or 2

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0) 
    inst.Physics:SetRectangle(rad,height)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
end


function MakeInteriorPhysics(inst, rad, height, width)
    height = height or 20

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(0) 
    inst.Physics:SetRectangle(rad,height,width)
    inst.Physics:SetCollisionGroup(COLLISION.INTWALL) -- GetWorldCollision()
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)    
end

function RemovePhysicsColliders(inst)
    inst.Physics:ClearCollisionMask()
    if inst.Physics:GetMass() > 0 then
        inst.Physics:CollidesWith(COLLISION.GROUND)
    end
end


local function OnGrowSeasonChange(inst)
	if not GetSeasonManager() then return end
	
	if inst.components.pickable then
		if GetSeasonManager():IsWinter() then
			inst.components.pickable:Pause()
		elseif not inst.components.pickable.dontunpauseafterwinter then     
			inst.components.pickable:Resume()
		end
	end
end

function MakeNoGrowInWinter(inst)
	if not GetSeasonManager() then return end
	
	inst:ListenForEvent("seasonChange", function() OnGrowSeasonChange(inst) end, GetWorld())
	if GetSeasonManager():IsWinter() then
		OnGrowSeasonChange(inst)
	end
end


function MakeSnowCovered(inst)
	-- need to defer this, our position is most likely not set yet
	inst:DoTaskInTime(0,function(inst)
		if not GetSeasonManager() then return end
		if inst:GetIsInInterior() then return end

		inst.AnimState:OverrideSymbol("snow", "snow", "snow")
		inst:AddTag("SnowCovered")

		if GetSeasonManager().ground_snow_level < SNOW_THRESH then
			inst.AnimState:Hide("snow")
		else
			inst.AnimState:Show("snow")
		end
	end)
end

function MakeFeedablePet(inst, starvetime, oninventory, ondropped)
    if not inst.components.eater then
        inst:AddComponent("eater")
    end

    inst.components.eater:SetOnEatFn(
        function(inst, food)   
            if inst.components.perishable then
                inst.components.perishable:SetPercent(1)
            end 
        end)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(starvetime)
    inst.components.perishable:StopPerishing()
    inst.components.perishable:SetOnPerishFn(
        function(inst)
            local owner = inst.components.inventoryitem.owner

            inst.components.inventoryitem:RemoveFromOwner(true)

            local stacksize = 1
            if inst.components.stackable then
                stacksize = inst.components.stackable.stacksize
            end
            if owner then
                if inst.components.lootdropper then
                    for i = 1, stacksize do
                        local loots = inst.components.lootdropper:GenerateLoot()
                        for k, v in pairs(loots) do
                            local loot = SpawnPrefab(v)
                            if owner.components.inventory then
                                owner.components.inventory:GiveItem(loot)
                            elseif owner.components.container then
                                owner.components.container:GiveItem(loot)
                            else
                                loot:Remove()
                            end
                        end      
                    end
                end
            end
            inst:Remove()
        end)

    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst)
        inst.components.perishable:StartPerishing()
        if oninventory then
            oninventory(inst)
        end
    end)

    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        inst.components.perishable:StopPerishing()
        if ondropped then
            ondropped(inst)
        end
    end) 

    inst:AddTag("show_spoilage")
    inst:AddTag("pet")
end

local function MakeBlowInHurricane_OnCollision(inst, other)
    if inst and inst.Physics ~= nil then
        local x, y, z = inst.Physics:GetVelocity()
        print(string.format("%s collision\n(%4.2f, %4.2f, %4.2f)\n", tostring(inst.prefab), x, y, z))
    end
end

function MakeBlowInHurricane(inst, minscale, maxscale)

    if not SaveGameIndex:IsModeShipwrecked() and not SaveGameIndex:IsModePorkland() then
        return
    end

    local minsc = minscale or 0.1
    local maxsc = maxscale or 1.0

    --if inst.Physics ~= nil then
        --inst.Physics:SetCollisionCallback(MakeBlowInHurricane_OnCollision)
    --end

    if inst.components.blowinwind == nil then
        inst:AddComponent("blowinwind")
    end
    
    inst.components.blowinwind:SetAverageSpeed(TUNING.WILSON_WALK_SPEED / 4)
    inst.components.blowinwind:SetMaxSpeedMult(minsc)
    inst.components.blowinwind:SetMinSpeedMult(maxsc)
    inst.components.blowinwind:Start()
end

function RemoveBlowInHurricane(inst)
    --inst:RemoveComponent("locomotor")
    inst:RemoveComponent("blowinwind")
end

function MakeRipples(inst)
    -- used if something has the ripple effects but it's an inventory item
    inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
    inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")
end

function MakeInventoryFloatableWaterproof(inst, water_anim, land_anim)
    local water = water_anim or "idle_water"
    local land = land_anim or "idle"

    if inst.components.floatable == nil then
        inst:AddComponent("floatable")
    end
    inst.components.floatable.landanim = land 
    inst.components.floatable.wateranim = water
end 

function MakeInventoryFloatable(inst, water_anim, land_anim)
    MakeRipples(inst)
    MakeInventoryFloatableWaterproof(inst, water_anim, land_anim)
end

function MakePickableBlowInWindGust(inst, wind_speed, destroy_chance)
    inst.onblownpstdone = function(inst)
        if inst.components.pickable and inst.components.pickable:CanBePicked() and inst.AnimState:IsCurrentAnimation("blown_pst") then
            inst.AnimState:PlayAnimation("idle", true)
        end
        inst:RemoveEventCallback("animover", inst.onblownpstdone)
    end

    inst.ongustanimdone = function(inst)
        if inst.components.pickable and inst.components.pickable:CanBePicked() then
            if inst.components.blowinwindgust:IsGusting() then
                local anim = math.random(1,2)
                inst.AnimState:PlayAnimation("blown_loop"..anim, false)
            else
                inst:DoTaskInTime(math.random()/2, function(inst)
                    inst:RemoveEventCallback("animover", inst.ongustanimdone)
                    inst.AnimState:PlayAnimation("blown_pst", false)
                    -- changed this from a push animation to an animover listen event so that it can be interrupted if necessary, and that a check can be made at the end to know if it should go to idle at that time.
                    --inst.AnimState:PushAnimation("idle", true)
                    inst:ListenForEvent("animover", inst.onblownpstdone)
                end)
            end
        else
            inst:RemoveEventCallback("animover", inst.ongustanimdone)
        end
    end

    inst.onguststart = function(inst, windspeed)
        if inst.components.pickable and inst.components.pickable:CanBePicked() then
            inst:DoTaskInTime(math.random()/2, function(inst)
                inst.AnimState:PlayAnimation("blown_pre", false)
                inst:ListenForEvent("animover", inst.ongustanimdone)
            end)
        end
    end

    inst.ongustpick = function(inst)
        if inst.components.pickable and inst.components.pickable:CanBePicked() then
            inst.components.pickable:MakeEmpty()
            inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
        end
    end

    inst:AddComponent("blowinwindgust")
    inst.components.blowinwindgust:SetWindSpeedThreshold(wind_speed)
    inst.components.blowinwindgust:SetDestroyChance(destroy_chance)
    inst.components.blowinwindgust:SetGustStartFn(inst.onguststart)
    inst.components.blowinwindgust:SetDestroyFn(inst.ongustpick)
    inst.components.blowinwindgust:Start()
end

function MakeHackableBlowInWindGust(inst, wind_speed, destroy_chance)
    inst.ongustanimdone = function(inst)
        if inst.components.hackable and inst.components.hackable:CanBeHacked() then
            if inst.components.blowinwindgust:IsGusting() then
                local anim = math.random(1,2)
                inst.AnimState:PlayAnimation("blown_loop"..anim, false)
            else
                inst:DoTaskInTime(math.random()/2, function(inst)
                    inst:RemoveEventCallback("animover", inst.ongustanimdone)
                    inst.AnimState:PlayAnimation("blown_pst", false)
                    inst.AnimState:PushAnimation("idle", true)
                end)
            end
        else
            inst:RemoveEventCallback("animover", inst.ongustanimdone)
        end
    end

    inst.onguststart = function(inst, windspeed)
        if inst.components.hackable and inst.components.hackable:CanBeHacked() then
            inst:DoTaskInTime(math.random()/2, function(inst)
                inst.AnimState:PlayAnimation("blown_pre", false)
                inst:ListenForEvent("animover", inst.ongustanimdone)
            end)
        end
    end

    inst.ongusthack = function(inst)
        if inst.components.hackable and inst.components.hackable:CanBeHacked() then
            inst.components.hackable:MakeEmpty()
            inst.components.lootdropper:SpawnLootPrefab(inst.components.hackable.product)
        end
    end

    inst:AddComponent("blowinwindgust")
    inst.components.blowinwindgust:SetWindSpeedThreshold(wind_speed)
    inst.components.blowinwindgust:SetDestroyChance(destroy_chance)
    inst.components.blowinwindgust:SetGustStartFn(inst.onguststart)
    inst.components.blowinwindgust:SetDestroyFn(inst.ongusthack)
    inst.components.blowinwindgust:Start()
end

local function GetObsidianHeat(inst, observer)
    local charge, maxcharge = inst.components.obsidiantool:GetCharge()
    local heat = Lerp(0, TUNING.OBSIDIAN_TOOL_MAXHEAT, charge/maxcharge)
    return heat
end

local function GetObsidianEquippedHeat(inst, observer)
    local heat = GetObsidianHeat(inst, observer)
    heat = math.clamp(heat, 0, TUNING.OBSIDIAN_TOOL_MAXHEAT)
    --awkward/hacky but safer
    if observer.components.temperature then
        local current = observer.components.temperature:GetCurrent()
        if heat > current then
            heat = heat + current
        elseif heat < current then
            heat = current --cancel out heat so tools don't cool you down
        end
    end
    return heat
end

local function ChangeObsidianLight(inst, old, new)
    local percentage = new/inst.components.obsidiantool.maxcharge
    local rad = Lerp(1, 2.5, percentage)

    if percentage >= inst.components.obsidiantool.red_threshold then
        inst.Light:Enable(true)
        inst.Light:SetColour(254/255,98/255,75/255)
        inst.Light:SetRadius(rad)
    elseif percentage >= inst.components.obsidiantool.orange_threshold then
        inst.Light:Enable(true)
        inst.Light:SetColour(255/255,159/255,102/255)
        inst.Light:SetRadius(rad)
    elseif percentage >= inst.components.obsidiantool.yellow_threshold then
        inst.Light:Enable(true)
        inst.Light:SetColour(255/255,223/255,125/255)
        inst.Light:SetRadius(rad)
    else
        inst.Light:Enable(false)
    end
end

local function ManageObsidianLight(inst)
    local cur, max = inst.components.obsidiantool:GetCharge() 
    if cur/max >= inst.components.obsidiantool.yellow_threshold then
        inst.Light:Enable(true)
    else
        inst.Light:Enable(false)
    end
end

local function ObsidianToolAttack(inst, attacker, target, projectile)
    --deal bonus damage to the target based on the original damage of the spear.
    local base_damage = inst.components.weapon.damage
    local charge, maxcharge = inst.components.obsidiantool:GetCharge()
    local damage_mod = Lerp(0, 1, charge/maxcharge) --Deal up to double damage based on charge.

    local remove = false
    if projectile and not inst:HasTag("projectile") then
        inst:AddTag("projectile")
        remove = true
    end
    
    target.components.combat:GetAttacked(attacker, base_damage * damage_mod, inst, "FIRE")

    if remove then
        inst:RemoveTag("projectile")
    end

    --light target on fire if at maximum heat.
    if charge == maxcharge then
        if target.components.burnable then
            target.components.burnable:Ignite()
        end
    end
end

function MakeObsidianTool(inst, tooltype)
    inst:AddTag("obsidian")
    inst:AddTag("notslippery")
    inst.no_wet_prefix = true

    if inst.components.floatable then
        inst.components.floatable:SetOnHitWaterFn(function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/obsidian_wetsizzles")
            inst.components.obsidiantool:SetCharge(0)
        end)
    end

    inst:AddComponent("obsidiantool")
    inst.components.obsidiantool.tool_type = tooltype

    if not inst.components.heater then
        --only hook up heater to obsidiantool if the heater isn't already on.
        inst:AddComponent("heater")
        inst.components.heater.show_heat = true

        inst.components.heater.heatfn = GetObsidianHeat
        inst.components.heater.minheat = 0
        inst.components.heater.maxheat = TUNING.OBSIDIAN_TOOL_MAXHEAT

        inst.components.heater.equippedheatfn = GetObsidianEquippedHeat
        --inst.components.heater.minequippedheat = 0
        --inst.components.heater.maxequippedheat = TUNING.OBSIDIAN_TOOL_MAXHEAT

        inst.components.heater.carriedheatfn = GetObsidianHeat
        inst.components.heater.mincarriedheat = 0
        inst.components.heater.maxcarriedheat = TUNING.OBSIDIAN_TOOL_MAXHEAT
    end

    if not inst.Light then
        --only add a light if there is no light already
        inst.entity:AddLight()
        inst.Light:SetFalloff(0.5)
        inst.Light:SetIntensity(0.75)
        inst.components.obsidiantool.onchargedelta = ChangeObsidianLight
        inst:ListenForEvent("equipped", ManageObsidianLight)
        inst:ListenForEvent("onputininventory", ManageObsidianLight)
        inst:ListenForEvent("ondropped", ManageObsidianLight)
    end

    if inst.components.weapon then
        if inst.components.weapon.onattack then
            print("Obsidian Weapon", inst, "already has an onattack!")
        else
            inst.components.weapon:SetOnAttack(ObsidianToolAttack)
        end
    end
end
