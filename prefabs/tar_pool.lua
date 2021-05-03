local assets=
{
	Asset("ANIM", "anim/tar_pit.zip"),
    Asset("MINIMAP_IMAGE", "tar_pit"),
}

local prefabs=
{
	"tar",
}


local function onsave(inst, data)
    if inst.components.inspectable and inst.components.inspectable.inspectdisabled then
        data.inspectdisabled = true
    end    
end

local function onload(inst, data)
    if data and data.inspectdisabled then
        if inst.components.inspectable then
            inst.components.inspectable.inspectdisabled = data.inspectdisabled
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
    local minimap = inst.entity:AddMiniMapEntity()
    local sound = inst.entity:AddSoundEmitter()
    minimap:SetIcon("tar_pit.png")
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst:AddTag("aquatic")
    inst:AddTag("tar source")
    inst.AnimState:SetBank("tar_pit")
    inst.AnimState:SetBuild("tar_pit")
    inst.AnimState:PlayAnimation("idle", true)
    --inst.AnimState:SetRayTestOnBB(true)

    -- This looping sound seems to show up at 0,0,0.. so waiting a frame to start it when the tarpool will be in the world at it's location.
    inst:DoTaskInTime(0, function() inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/tar_LP","burble") end)

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    inst:AddComponent("inspectable")
    
	--MakeSmallBurnable(inst)
    --MakeSmallPropagator(inst)
 
    inst.OnSave = onsave 
    inst.OnLoad = onload

    return inst
end

return Prefab( "shipwrecked/tar_pool", fn, assets) 
