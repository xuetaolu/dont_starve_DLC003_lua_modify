local assets =
{
	Asset("ANIM", "anim/gravestones.zip"),
}

local prefabs = 
{
}

local function onfinishcallback(inst, worker)

    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")
    inst.components.hole.canbury = true

	if worker then
		if worker.components.sanity then
			worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
		end		
		if worker.components.inventory then
			
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/loot_reveal")

            if inst.buriedinventory ~= nil then
                for k,v in pairs(inst.buriedinventory) do
                    local pref = SpawnPrefab(v.prefab)
                    local x, y, z = inst.Transform:GetWorldPosition()
                    pref.Transform:SetPosition(x, 0, z)
					-- need to set the position before this or it may think it's on water
                    pref:SetPersistData(v.data, {})
                
                    local angle = math.random()*2*PI
                    local speed = 2
                    speed = speed * math.random()
                    pref.Physics:SetVel(speed*math.cos(angle), GetRandomWithVariance(16, 4), speed*math.sin(angle))

                end
                inst.buriedinventory = nil
            end
		end
	end	
end

local function ResetGrave(inst)
	inst.AnimState:PlayAnimation("gravedirt")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.hole.canbury = false
    inst.dug = false
    inst.components.workable:SetOnFinishCallback(onfinishcallback) 
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    anim:SetBank("gravestone")
    anim:SetBuild("gravestones")
    anim:PlayAnimation("gravedirt")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if not inst.components.workable then        	
            return "DUG"
        end
    end
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst:AddComponent("lootdropper")
        
    inst.components.workable:SetOnFinishCallback(onfinishcallback)    

    inst:AddComponent("hole")  
    inst.ResetGrave = ResetGrave

    inst.buriedinventory = {}

    inst.OnSave = function(inst, data)
        if not inst.components.workable then
            data.dug = true
        end
    end        
    
    inst.OnLoad = function(inst, data)
        if data and data.dug or not inst.components.workable then
            inst:RemoveComponent("workable")
            inst.AnimState:PlayAnimation("dug")
            inst.components.hole.canbury = true
        end
    end

    inst.OnSave = function (inst, data)
        data.buriedinventory = inst.buriedinventory
    end

    return inst
end

return Prefab( "common/objects/inventorymound", fn, assets, prefabs ) 
