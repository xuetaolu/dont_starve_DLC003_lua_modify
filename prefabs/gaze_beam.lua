
local assets=
{
	Asset("ANIM", "anim/gaze_beam.zip"),
}

local prefabs =
{
	
}

local function onupdate(inst, dt)
	if dt then
		inst.timeremaining = inst.timeremaining - dt
		local dist = Remap(inst.timeremaining, inst.timeremainingMax, 0, 2, 6)
		inst.components.creatureprox:SetDist(dist,dist+1)
	end
end

local function oncollide(inst, other)
    if other.components.freezable and not other.components.freezable:IsFrozen( ) and other ~= inst.host then
    	if inst.host and other.components.combat then
    		other:PushEvent("attacked", {attacker = inst.host, damage = 0, weapon = inst})
    	end
        other.components.freezable:AddColdness(5)
        other.components.freezable:SpawnShatterFX()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
    MakeGhostPhysics(inst, 0, 0)
    RemovePhysicsColliders(inst)


	anim:SetBank("gaze_beam")
	anim:SetBuild("gaze_beam")
	anim:PlayAnimation("loop")

	inst:AddTag("projectile")

	inst.timeremainingMax = 2
	inst.timeremaining = inst.timeremainingMax
                       
    inst:AddComponent("genericonupdate")
    inst.components.genericonupdate:Setup(onupdate)

    inst:AddComponent("creatureprox")
    inst.components.creatureprox.inproxfn = oncollide
    inst.components.creatureprox.period = 0.001
    inst.components.creatureprox:SetDist(3,4)	
    inst.components.creatureprox.piggybackfn = onupdate

	inst.Physics:SetMotorVelOverride(10,0,0)
	
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/gaze_LP","gaze")

	inst:ListenForEvent("animover", function(inst, data)
						if inst.components.creatureprox.enabled then
							 inst.components.creatureprox.enabled = false
							 inst.AnimState:PlayAnimation("loop_pst")
							 inst.SoundEmitter:KillSound("gaze")
						else
							inst:Remove()
						end
                    end)    
                    

	return inst
end

return Prefab( "gaze_beam", fn, assets, prefabs) 
