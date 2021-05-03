local assets =
{
	Asset("ANIM", "anim/torch.zip"),
	Asset("ANIM", "anim/swap_torch.zip"),
	Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{
	"torchfire",
}    

local function onequip(inst, owner, force) 
    --owner.components.combat.damage = TUNING.PICK_DAMAGE 
    if not owner.sg:HasStateTag("rowing") or force then 

        inst.components.burnable:Ignite()
        owner.AnimState:OverrideSymbol("swap_object", "swap_torch", "swap_torch")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
        
        inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
        inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )

        if not inst.fire then
            inst.fire = SpawnPrefab( "torchfire" )
            inst.fire:AddTag("INTERIOR_LIMBO_IMMUNE")	-- TODO: Fix follower handling in interiorspawner

            local follower = inst.fire.entity:AddFollower()
            follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 0 )
            --owner:AddChild(inst.fire)
        end
        
        --take a percent of fuel next frame instead of this one, so we can remove the torch properly if it runs out at that point
    	inst:DoTaskInTime(0, function()
     	    if inst.components.fueled.currentfuel < inst.components.fueled.maxfuel then
    		    inst.components.fueled:DoDelta(-inst.components.fueled.maxfuel*.01)
    	    end
    	end)
    end 
end

local function onunequip(inst,owner) 
	
    if inst.fire then
        owner:RemoveChild(inst.fire)
        inst.fire:Remove()
        inst.fire = nil
    end
    
    inst.components.burnable:Extinguish()
    owner.components.combat.damage = owner.components.combat.defaultdamage 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    inst.SoundEmitter:KillSound("torch")
    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")        
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("torch")
    anim:SetBuild("torch")
    anim:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TORCH_DAMAGE)
    inst.components.weapon:SetAttackCallback(
        function(inst, attacker, target)
            if target.components.burnable then
                if math.random() < TUNING.TORCH_ATTACK_IGNITE_PERCENT*target.components.burnable.flammability then
                    target.components.burnable:Ignite()
                end
            end
        end
    )
    
    -----------------------------------
    inst:AddComponent("lighter")
    -----------------------------------
    
    inst:AddComponent("inventoryitem")
    -----------------------------------
    
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnPocket( function(owner) inst.components.burnable:Extinguish()  end)
    
    inst.components.equippable:SetOnEquip( onequip )
     
    inst.components.equippable:SetOnUnequip( onunequip )
    

    -----------------------------------
    
    inst:AddComponent("inspectable")
 
    -----------------------------------
    
    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil
    --inst.components.burnable:AddFXOffset(Vector3(0,1.5,-.01))
    ----------------------------------------
    
    -----------------------------------
    
    inst:AddComponent("fueled")
    

    inst.components.fueled:SetUpdateFn( function()
        local rate = 1
        if GetSeasonManager():IsRaining() and not 
                (inst.components.inventoryitem and inst.components.inventoryitem.owner and 
                inst.components.inventoryitem.owner.components.moisture and inst.components.inventoryitem.owner.components.moisture.sheltered) then
            rate = rate + TUNING.TORCH_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
        end
         rate = rate + TUNING.TORCH_WIND_RATE * GetSeasonManager():GetHurricaneWindSpeed() 
         inst.components.fueled.rate = rate
    end)


    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then
                --when we burn out
                if inst.components.burnable then 
					inst.components.burnable:Extinguish() 
				end
				
                if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
                    local owner = inst.components.inventoryitem.owner
                    inst:Remove()
                    
                    if owner then
                        owner:PushEvent("torchranout", {torch = inst})
                    end
                end
                
            end
        end)
    inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL)
    inst.components.fueled:SetDepletedFn(function(inst) inst:Remove() end)

    inst:ListenForEvent( "startrowing", function(inst,data) 
        --print("start rowing!!")
        onunequip(inst, data.owner)
        end, inst)  

    inst:ListenForEvent( "stoprowing", function(inst, data) 
        onequip(inst, data.owner, true)
        end, inst)    
    
    return inst   
end   

return Prefab( "common/inventory/torch", fn, assets, prefabs) 