local assets =
{
}

local prefabs = 
{
}

local function AddMember(inst, member)
	--print("doydoy herd AddMember", inst, member)
	
end

local function OnEmpty(inst)
	--print("doydoy herd OnEmpty")
	inst:Remove()
end

local function OnFull(inst)
	--print("doydoy herd OnFull")
end
   
local function fn(Sim)
	--print("doydoy herd fn")
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	

	inst:AddTag("herd")
	
	-- inst:AddComponent("herd")
	-- inst.components.herd:SetMemberTag("doydoy")
	-- inst.components.herd:SetMaxSize(TUNING.DOYDOY_HERD_SIZE)
	-- inst.components.herd:SetGatherRange(TUNING.DOYDOY_HERD_GATHER_RANGE)
	-- inst.components.herd:SetUpdateRange(20)
	-- inst.components.herd:SetOnEmptyFn(OnEmpty)
	-- inst.components.herd:SetOnFullFn(OnFull)
	-- inst.components.herd:SetAddMemberFn(AddMember)
		
	-- looking for the babyspawner? it's the global doydoyspawner component.
	
	return inst
end

return Prefab( "forest/animals/doydoyherd", fn, assets, prefabs) 
