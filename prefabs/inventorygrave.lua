local assets =
{
	Asset("ANIM", "anim/gravestones.zip"),
	Asset("MINIMAP_IMAGE", "gravestones"),  
}

local prefabs = 
{
	"inventorymound",
}

local function onsave(inst, data)
	
	if inst.mound then
		data.mounddata = inst.mound:GetSaveRecord()
	end
end	

local function onload(inst, data, newents)
	if data then
		if inst.mound and data.mounddata then
	        if newents and data.mounddata.id then
	            newents[data.mounddata.id] = {entity=inst.mound, data=data.mounddata} 
	        end

	        if data.mounddata.data and data.mounddata.data.buriedinventory then
				inst.mound.buriedinventory = data.mounddata.data.buriedinventory
        	elseif data.mounddata.buriedinventory then
				inst.mound.buriedinventory = data.mounddata.buriedinventory
        	end
		end

		if data.setepitaph then	
			--this handles custom epitaphs set in the tile editor
			if GetPlayer().prefab ~= "wilbur" then
	    		inst.components.inspectable:SetDescription("'"..data.setepitaph.."'")
	    	end
	    	inst.setepitaph = data.setepitaph
		end
	end
end	

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()

	minimap:SetIcon( "gravestones.png" )

    MakeObstaclePhysics(inst, .25)
    
    anim:SetBank("gravestone")
    anim:SetBuild("gravestones")
    anim:PlayAnimation("grave" .. tostring( math.random(4)))

    inst:AddComponent("inspectable")

    if GetPlayer().prefab ~= "wilbur" then
    	inst.components.inspectable:SetDescription( STRINGS.EPITAPHS[math.random(#STRINGS.EPITAPHS)] )	    	
    end
    
	inst:AddTag("grave")

    inst.mound = inst:SpawnChild("inventorymound")
    
	inst.OnLoad = onload
	inst.OnSave = onsave
    
    inst.mound.Transform:SetPosition((TheCamera:GetDownVec()*.5):Get())
     
    return inst
end

return Prefab( "common/objects/inventorygrave", fn, assets, prefabs ) 
