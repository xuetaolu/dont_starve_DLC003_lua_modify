local function OnLoad(inst, scenariorunner)
	inst:AddTag("vinehideout")
end

local function OnDestroy(inst)
	inst:RemoveTag("vinehideout")
end

return
{
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}