require "brains/gnatbrain"
require "stategraphs/SGgnat"

local assets=
{
	Asset("ANIM", "anim/cropdust_fx.zip"),
}
	
local prefabs =
{

}

local START_RANGE = 2
local END_RANGE = 2.2

local function dogason(inst)
	if inst.OnGasChange then
		inst.OnGasChange(inst,true)
	else
		if inst:HasTag("insect") and inst.components.poisonable then
			inst.components.poisonable:Poison(true, nil, true)
		end
	end
end

local function dogasoff(inst)
	if inst.OnGasChange then
		inst.OnGasChange(inst,false)
	else

	end
end

local function die(inst)

	inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover",function()
			for i,ent in ipairs(inst.gassedents)do

				dogasoff(ent)
			end
		    inst:Remove() 
    	end)
end

local function spawn(inst)
	inst.AnimState:PlayAnimation("appear")
	inst.AnimState:PushAnimation("idle_loop",true)	
end

local function onupdate(inst, dt)
	local x,y,z = inst.Transform:GetWorldPosition()
    local musthave = { "animal","character","monster" }
    local nothave = {"INTERIOR_LIMBO","gas"}
	local ents = TheSim:FindEntities(x,y,z, START_RANGE, nil, nothave,  musthave )

	local oldents = inst.gassedents --deepcopy(inst.gassedents)

	inst.gassedents = ents

	for i,ent in ipairs(inst.gassedents)do
		local oldent = false
		for t, tent in ipairs(oldents)do
						
			if tent == ent then				
				oldent = true

				table.remove(oldents,t)
				break
			end
		end
		if not oldent then

			dogason(ent)
		end		
	end

	for i,ent in ipairs(oldents)do

		dogasoff(ent)
	end

end

local function oncollide(inst, other)
    if other == GetPlayer() then
       other.OnGasChange(other,true)
    end
end


local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.5, 1.5 )

	----------
	
	inst:AddTag("gas")


	--MakeNoPhysics(inst, 1, .25)

	--inst.Physics:SetCollisionCallback(oncollide)

	inst.Transform:SetFourFaced()

	--inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
	--inst.Physics:ClearCollisionMask()
	--inst.Physics:CollidesWith(GetWorldCollision())

	inst.AnimState:SetBuild("cropdust_fx")

	------------

    inst:AddComponent("creatureprox")
   -- inst.components.creatureprox.inproxfn = oncollide
    inst.components.creatureprox.period = 0.01
    inst.components.creatureprox:SetDist(START_RANGE,END_RANGE)	
    inst.components.creatureprox.piggybackfn = onupdate

    ---------------	
	
	inst.AnimState:SetBank("cropdust_fx")
	inst.AnimState:PlayAnimation("idle_loop",true)
	inst.AnimState:SetRayTestOnBB(true); 

	------------------
	
	inst:AddComponent("inspectable")

	inst:DoTaskInTime(20,function() die(inst) end)

	inst.gassedents = {} 

	inst.spawn = spawn

	return inst
end

return Prefab( "forest/common/gascloud", fn, assets, prefabs)
