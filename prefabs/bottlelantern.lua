local assets=
{
	Asset("ANIM", "anim/lantern_bottle.zip"),
	Asset("ANIM", "anim/swap_bottlle_lantern.zip"),
    Asset("INV_IMAGE", "bottlelantern_off"),
}


local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()        
        end
        inst.Light:Enable(true)
        --inst.components.floatable:SetOnHitWaterFn(onhitwater_on)
        inst.components.floatable:UpdateAnimations("idle_on_water", "idle_on")

        if inst.components.equippable:IsEquipped() then
            inst.components.inventoryitem.owner.AnimState:OverrideSymbol("swap_object", "swap_bottlle_lantern", "swap_lantern_on")
            inst.components.inventoryitem.owner.AnimState:Show("LANTERN_OVERLAY") 
            
        end
        --inst.components.machine.ison = true

        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bottlelantern_turnon")

        if not  inst.SoundEmitter:PlayingSound("loop") then 
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bottlelantern_lp", "loop")
        end 

        inst.components.inventoryitem:ChangeImageName("bottlelantern")
    end
end

local function turnoff(inst)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()        
    end

    inst.Light:Enable(false)
  
    inst.components.floatable:UpdateAnimations("idle_water", "idle_off")
    if inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:OverrideSymbol("swap_object", "swap_bottlle_lantern", "swap_lantern_off")
        inst.components.inventoryitem.owner.AnimState:Hide("LANTERN_OVERLAY") 
    end

   -- inst.components.machine.ison = false

    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bottlelantern_turnoff")

    inst.components.inventoryitem:ChangeImageName("bottlelantern_off")
end

local function ondropped(inst)
    --turnoff(inst) --Why turn off here? 
    if not inst.components.fueled:IsEmpty() then
        inst.components.machine:TurnOn()
    else
        inst.components.machine:TurnOff()
    end 
end

local function onpickup(inst)
	inst.components.machine:TurnOn()
end

local function onputininventory(inst)
    inst.components.machine:TurnOff()
end
--
local function onequip(inst, owner) 
    if not owner.sg:HasStateTag("rowing") then
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal")
        owner.AnimState:OverrideSymbol("lantern_overlay", "swap_bottlle_lantern", "lantern_overlay")
    	
        if inst.components.fueled:IsEmpty() then
            owner.AnimState:OverrideSymbol("swap_object", "swap_bottlle_lantern", "swap_lantern_off")
    		owner.AnimState:Hide("LANTERN_OVERLAY") 
        else
            owner.AnimState:OverrideSymbol("swap_object", "swap_bottlle_lantern", "swap_lantern_on")
    		owner.AnimState:Show("LANTERN_OVERLAY") 
        end
        inst.components.machine:TurnOn()
    end 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
	owner.AnimState:Hide("LANTERN_OVERLAY") 	
end

local function nofuel(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        owner:PushEvent("torchranout", {torch = inst})
    end

    turnoff(inst)
end

local function takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        turnon(inst)
    end
end

local function fuelupdate(inst)
    local fuelpercent = inst.components.fueled:GetPercent()
    inst.Light:SetIntensity(Lerp(0.4, 0.65, fuelpercent))
    inst.Light:SetRadius(Lerp(3, 5, fuelpercent))
    inst.Light:SetFalloff(.9)
end

local function returntointeriorscene(inst)
	if inst.components.fueled:IsEmpty() then
		nofuel(inst)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()        
    MakeInventoryPhysics(inst)
    --MakeInventoryFloatable(inst, "idle_water_empty", "idle_empty")
    
    inst.AnimState:SetBank("lantern_bottle")
    inst.AnimState:SetBuild("lantern_bottle")
    inst.AnimState:PlayAnimation("idle_off")

    MakeInventoryFloatable(inst, "idle_water", "idle_off")

    inst:AddTag("light")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)    

    inst:AddComponent("equippable")

    inst:AddComponent("fueled")

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0
    inst.components.machine.caninteractfn = function() return not inst.components.fueled:IsEmpty() and (inst.components.inventoryitem.owner == nil or inst.components.equippable.isequipped) end


    inst.components.fueled.fueltype = "CAVE"
    inst.components.fueled:InitializeFuelLevel(TUNING.BOTTLE_LANTERN_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled.ontakefuelfn = takefuel
    inst.components.fueled.accepting = true

    inst.entity:AddLight()
    inst.Light:SetColour(0/255, 180/255, 255/255)

    fuelupdate(inst)

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip ) 

    inst:ListenForEvent( "startrowing", function(inst,data) 
        --print("start rowing!!")
        turnoff(inst)
        end, inst)  

    inst:ListenForEvent( "stoprowing", function(inst, data) 
        --print("stop rowing!!")
        turnon(inst)
        end, inst)

	inst.returntointeriorscene = returntointeriorscene

    return inst
end


return Prefab( "common/inventory/bottlelantern", fn, assets) 
