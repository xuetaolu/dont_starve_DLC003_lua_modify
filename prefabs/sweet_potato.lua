local assets=
{
	Asset("ANIM", "anim/sweet_potato.zip"),
    --Asset("ANIM", "anim/sweetpotatoe.zip"),
}

local prefabs=
{
	"sweet_potato",
}

local function onpickedfn(inst)
	inst:Remove()
end


local function fn(Sim)
    --Carrot you eat is defined in veggies.lua
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
   
    inst.AnimState:SetBank("sweet_potato")
    inst.AnimState:SetBuild("sweet_potato")
    inst.AnimState:PlayAnimation("planted")
    inst.AnimState:SetRayTestOnBB(true);
    

    inst:AddComponent("inspectable")
    
    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("sweet_potato", 10)
	inst.components.pickable.onpickedfn = onpickedfn
    
    inst.components.pickable.quickpick = true

    
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
	
    return inst
end

return Prefab( "common/inventory/sweet_potato_planted", fn, assets) 
