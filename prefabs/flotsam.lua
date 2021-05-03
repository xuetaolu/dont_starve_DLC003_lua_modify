local assets =
{
	Asset("ANIM", "anim/flotsam_debris_armoured_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_bamboo_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_cargo_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_lograft_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_rowboat_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_surfboard_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_corkboat_build.zip"),
	Asset("ANIM", "anim/flotsam_debris_sw.zip"),
	Asset("ANIM", "anim/flotsam_knightboat_build.zip"),

}

local anim_appends =
{
	"",
	"2",
	"3",
	"4",
	"5",
}

local prefabs = 
{
	"flotsam_basegame",
	"flotsam",
	"flotsam_debris",
}

local function sink(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boat_debris_submerge")
	inst.AnimState:PushAnimation("sink"..inst.anim_append)
	inst:ListenForEvent("animover", inst.Remove)
end

local function fn(build)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boat_debris_breakoff")

	inst.AnimState:SetBank("flotsam_debris_sw")
	inst.AnimState:SetBuild("flotsam_debris_"..build.."_build")
	inst.anim_append = anim_appends[math.random(#anim_appends)]
	inst.AnimState:PlayAnimation("idle"..inst.anim_append, true)

	inst:DoTaskInTime(3 + math.random() * 4, sink)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.persists = false

	return inst
end

return Prefab("flotsam_armoured", function() return fn("armoured") end, assets, prefabs),
Prefab("flotsam_bamboo", function() return fn("bamboo") end, assets, prefabs),
Prefab("flotsam_cargo", function() return fn("cargo") end, assets, prefabs),
Prefab("flotsam_lograft", function() return fn("lograft") end, assets, prefabs),
Prefab("flotsam_rowboat", function() return fn("rowboat") end, assets, prefabs),
Prefab("flotsam_surfboard", function() return fn("surfboard") end, assets, prefabs),
Prefab("flotsam_corkboat", function() return fn("corkboat") end, assets, prefabs)