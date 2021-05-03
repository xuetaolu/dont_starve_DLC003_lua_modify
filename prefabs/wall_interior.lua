local assets=
{
	Asset("ANIM", "anim/interior_wall_noseam.zip"),
}

local prefabs =
{

}    

local function onsave(inst, data)
    if inst.rotation then
        data.rotation = inst.rotation 
    end
end

local function onload(inst, data)
    if data then
        if data.rotation then
            inst.Transform:SetRotation(data.rotation)
            inst.rotation = data.rotation
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("interior_wall")
    inst.AnimState:SetBuild("interior_wall_noseam")
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.RotatingBillboard)

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )      
    inst.AnimState:SetScale(4,4,4 )      
    --inst.AnimState:SetRayTestOnBB(true);

    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 

    return inst
end

return Prefab( "interior/objects/wall_interior", fn, assets, prefabs)
