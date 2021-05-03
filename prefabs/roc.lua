
require "stategraphs/SGroc"

local assets=
{
	Asset("ANIM", "anim/roc_shadow.zip"),
}

local prefabs =
{
	"roc_leg",
	"roc_head",
	"roc_tail",
}


local function setstage(inst,stage)
	if stage == 1 then
		inst.Transform:SetScale(0.35,0.35,0.35)
        inst.components.locomotor.runspeed = 5
	elseif stage == 2 then
		inst.Transform:SetScale(0.65,0.65,0.65)
        inst.components.locomotor.runspeed = 7.5
    else
		inst.Transform:SetScale(1,1,1)
        inst.components.locomotor.runspeed = 10
	end
end


local function scalefn(inst,scale)
	inst.components.locomotor.runspeed = TUNING.ROC_SPEED * scale
	inst.components.shadowcaster:setrange(TUNING.ROC_SHADOWRANGE*scale)	
end

local function OnRemoved(inst)     
    GetWorld().components.rocmanager:RemoveRoc(inst)
end



local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
--	local shadow = inst.entity:AddDynamicShadow()
--	shadow:SetSize( 6.5, 6.5 )
	
	--inst.Transform:SetSixFaced()
	MakeNoPhysics(inst, 10, 1.5)
	--MakeGhostPhysics(inst, 10, 1.5)
    --MakeCharacterPhysics(inst, 10, 1.5)
    RemovePhysicsColliders(inst)

    inst.Transform:SetScale(1.5,1.5,1.5)

	inst:AddTag("roc")
	inst:AddTag("roc_body")
	inst:AddTag("canopytracker")
	inst:AddTag("noteleport")
	inst:AddTag("NOCLICK")

	anim:SetBank("roc")
	anim:SetBuild("roc_shadow")
	anim:PlayAnimation("ground_loop")

	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 1 )	

	anim:SetMultColour(1, 1, 1, 0.5)

	inst:AddComponent("colourtweener")
	if not GetClock():IsNight() and not inst:HasTag("under_leaf_canopy") then
		inst.components.colourtweener:StartTween({1,1,1,0.5}, 3)
	else
		inst.components.colourtweener:StartTween({1,1,1,0}, 3)
	end
	inst:ListenForEvent("daytime", function()	 
		if not inst:HasTag("under_leaf_canopy") then  
			inst.components.colourtweener:StartTween({1,1,1,0.5}, 3)		
		end
	end, GetWorld())

	inst:ListenForEvent("nighttime", function() 
			inst.components.colourtweener:StartTween({1,1,1,0}, 3)
	end, GetWorld())

	inst:AddComponent("knownlocations")

	inst:AddComponent("shadowcaster")

	inst:AddComponent("area_aware")

    inst:ListenForEvent("onremove", OnRemoved)

    inst:ListenForEvent( "onchangecanopyzone", function()
    	--[[
	    local ground = GetWorld()
	    local x,y,z = inst.Transform:GetWorldPosition()
	    local tile_type = ground.Map:GetTileAtPoint(x,y,z)
	    if tile_type == GROUND.DEEPRAINFOREST or tile_type == GROUND.GASJUNGLE or tile_type == GROUND.PIGRUINS then 
	        inst:AddTag("under_leaf_canopy")
	    else
	        inst:RemoveTag("under_leaf_canopy")
	    end 
	    ]]

	    if inst:HasTag("under_leaf_canopy") then
	    	inst.components.colourtweener:StartTween({1,1,1,0}, 1)
	    else
	    	if not GetClock():IsNight() then
	    		inst.components.colourtweener:StartTween({1,1,1,0.5}, 1)
	    	end
	    end
    end, GetWorld())

	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor.runspeed = TUNING.ROC_SPEED

	inst:AddComponent("roccontroller")	
	inst.components.roccontroller:Setup(TUNING.ROC_SPEED, 0.35, 3)
	inst.components.roccontroller:Start()
	inst.components.roccontroller.scalefn = scalefn

	inst:SetStateGraph("SGroc")

--	inst:AddComponent("health")
--	inst.components.health:SetMaxHealth(TUNING.SNAKE_HEALTH)
	--inst.components.health.poison_damage_scale = 0 -- immune to poison

	--inst:ListenForEvent("attacked", OnAttacked)
	--inst:ListenForEvent("onattackother", OnAttackOther)
	inst.setstage = setstage

	return inst
end

return Prefab("monsters/roc", fn, assets, prefabs)
