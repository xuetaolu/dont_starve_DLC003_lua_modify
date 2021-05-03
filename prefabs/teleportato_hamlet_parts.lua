local function makeassetlist()
    return {
		Asset("ANIM", "anim/teleportato_hamlet_parts.zip"),
		Asset("ANIM", "anim/teleportato_parts_build.zip"),
		Asset("ANIM", "anim/teleportato_adventure_parts_build.zip"),
    }
end

local function makefn(name, frame)
    local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()

		MakeInventoryPhysics(inst)
		
		anim:SetBank("parts")
		
		anim:PlayAnimation(frame, false)
		MakeInventoryFloatable(inst, frame.."_water", frame)
		
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
	        anim:SetBuild("teleportato_adventure_parts_build")
	        inst.components.inventoryitem:ChangeImageName(name.."_adv")
	    else
	        anim:SetBuild("teleportato_hamlet_parts")
	    end
	    
		inst:AddComponent("tradable")
        
		inst:AddTag("irreplaceable")
		inst:AddTag("teleportato_part")

       	return inst
	end
    return fn
end

local function TeleportatoPart(name, frame)
    return Prefab( "common/inventory/" .. name, makefn(name, frame), makeassetlist())
end

return TeleportatoPart( "teleportato_hamlet_ring", "ring"),
		TeleportatoPart( "teleportato_hamlet_box", "lever"),
		TeleportatoPart( "teleportato_hamlet_crank", "support"), 
		TeleportatoPart( "teleportato_hamlet_potato", "potato") 
