local assets =
{
	Asset("ANIM", "anim/lighter.zip"),
	Asset("ANIM", "anim/swap_lighter.zip"),
	--Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{
	"lighterfire",
}    

local function onequip(inst, owner, force)
    if not owner.sg:HasStateTag("rowing") or force then 
        --owner.components.combat.damage = TUNING.PICK_DAMAGE 
        inst.components.burnable:Ignite()
        owner.AnimState:OverrideSymbol("swap_object", "swap_lighter", "swap_lighter")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
        
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lighter_LP", "torch")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lighter_on")
        inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )

        inst.fire = SpawnPrefab( "lighterfire" )
		inst.fire:AddTag("INTERIOR_LIMBO_IMMUNE")	-- TODO: Fix follower handling in interiorspawner

        --inst.fire.Transform:SetScale(.125,.125,.125)
        local follower = inst.fire.entity:AddFollower()
        follower:FollowSymbol( owner.GUID, "swap_object", 35, -35, 1 )
    end
end

local function onunequip(inst,owner) 
    if inst.fire then 
	   inst.fire:Remove()
       inst.fire = nil
   end 
    
    inst.components.burnable:Extinguish()
    owner.components.combat.damage = owner.components.combat.defaultdamage 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    inst.SoundEmitter:KillSound("torch")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/lighter_off")        
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("lighter")
    anim:SetBuild("lighter")
    anim:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddTag("irreplaceable")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "lighter.png" )

    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.LIGHTER_DAMAGE)
    inst.components.weapon:SetAttackCallback(
        function(inst, attacker, target)
            if target.components.burnable then
                if math.random() < TUNING.LIGHTER_ATTACK_IGNITE_PERCENT*target.components.burnable.flammability then
                    target.components.burnable:Ignite()
                end
            end
        end
    )
    
    inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("willow")

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
    inst:ListenForEvent( "startrowing", function(inst,data) 
        --print("start rowing!!")
        onunequip(inst, data.owner)
        end, inst)  

    inst:ListenForEvent( "stoprowing", function(inst, data) 
        --print("stop rowing!!")
        onequip(inst, data.owner)
        end, inst)    
    -----------------------------------
    inst:DoTaskInTime(0, function() if not GetPlayer() or GetPlayer().prefab ~= "willow" then inst:Remove() end end)
    return inst
end

return Prefab( "common/lighter", fn, assets, prefabs) 
