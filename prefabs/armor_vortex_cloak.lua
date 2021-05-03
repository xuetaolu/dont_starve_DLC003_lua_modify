local assets=
{
	Asset("ANIM", "anim/armor_vortex_cloak.zip"),
    Asset("ANIM", "anim/cloak_fx.zip"),
    Asset("MINIMAP_IMAGE", "armor_vortex_cloak"),
}

local function setsoundparam(inst)
    local param = Remap(inst.components.armor.condition, 0, inst.components.armor.maxcondition,0, 1 ) 
    print(param)
    inst.SoundEmitter:SetParameter( "vortex", "intensity", param )
end

local function spawnwisp(owner)
    local wisp = SpawnPrefab("armorvortexcloak_fx")
    local x,y,z = owner.Transform:GetWorldPosition()
    wisp.Transform:SetPosition(x+math.random()*0.25 -0.25/2,y,z+math.random()*0.25 -0.25/2)    
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_vortex_cloak", "swap_body")
    owner.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/vortex_armour/equip_off")
    local function OnBlocked()
        if inst.components.armor.condition and inst.components.armor.condition > 0 then
            owner:AddChild(SpawnPrefab("vortex_cloak_fx"))                    
        end        
        setsoundparam(inst)
    end
    inst.OnBlocked = OnBlocked

  --  inst:ListenForEvent("blocked", inst.OnBlocked, owner) -- function(inst,data) OnBlocked(owner,inst) end
  --  inst:ListenForEvent("attacked", inst.OnBlocked, owner)      -- function(inst,data) OnBlocked(owner,inst) end
    inst:ListenForEvent("armorhit", inst.OnBlocked)

    owner:AddTag("not_hit_stunned")
    owner.components.inventory:SetOverflow(inst)
    inst.components.container:Open(owner)    
    inst.wisptask = inst:DoPeriodicTask(0.1,function() spawnwisp(owner) end)  

    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/vortex_armour/LP","vortex") 
    setsoundparam(inst)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/vortex_armour/equip_on")
 --   inst:RemoveEventCallback("blocked", inst.OnBlocked, owner)
 --   inst:RemoveEventCallback("attacked", inst.OnBlocked, owner)    
    inst:RemoveEventCallback("armorhit", inst.OnBlocked)
    owner:RemoveTag("not_hit_stunned")
    owner.components.inventory:SetOverflow(nil)
    inst.components.container:Close(owner)    
    if inst.wisptask then
        inst.wisptask:Cancel()
        inst.wisptask= nil
    end

    inst.SoundEmitter:KillSound("vortex")
end

local slotpos = {}

for y = 0, 3 do
    table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
    table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
end

local function nofuel(inst)

end

local function ontakefuel(inst)
    if inst.components.armor.condition and inst.components.armor.condition < 0 then
        inst.components.armor:SetCondition(0)
    end
    inst.components.armor:SetCondition( math.min( inst.components.armor.condition + (inst.components.armor.maxcondition/20), inst.components.armor.maxcondition) )
    GetPlayer().components.sanity:DoDelta(-TUNING.SANITY_TINY)
    GetPlayer().SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/vortex_armour/add_fuel")  
end

local function fn()
	local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")    

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "armor_vortex_cloak.png" )

    inst:AddTag("vortex_cloak")
    
    inst.AnimState:SetBank("armor_vortex_cloak")
    inst.AnimState:SetBuild("armor_vortex_cloak")
    inst.AnimState:PlayAnimation("anim")
        
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")    
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.foleysound = "dontstarve_DLC003/common/crafted/vortex_armour/foley"
	--inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/marblearmour"

    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_backpack_2x4"
    inst.components.container.widgetanimbuild = "ui_backpack_2x4"
    inst.components.container.widgetpos = Vector3(-5,-70,0)
    inst.components.container.side_widget = true
    inst.components.container.type = "pack"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "NIGHTMARE"
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)

    inst.components.fueled.ontakefuelfn = ontakefuel
    inst.components.fueled.accepting = true

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORVORTEX, TUNING.ARMORVORTEX_ABSORPTION)
    inst.components.armor.dontremove = true
    inst.components.armor:SetImmuneTags({"shadow"})
    inst.components.armor.bonussanitydamage = 0.3
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable.dapperness = TUNING.CRAZINESS_MED
    
    return inst
end

local function fxfn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("cloakfx")
    inst.AnimState:SetBuild("cloak_fx")
    inst.AnimState:PlayAnimation("idle",true)    

    inst:AddTag("fx")

    for i=1,14 do
        inst.AnimState:Hide("fx"..i)
    end
    inst.AnimState:Show("fx"..math.random(1,14))

    inst:ListenForEvent("animover", function() inst:Remove() end) 

    return inst
end

return Prefab( "common/inventory/armorvortexcloak", fn, assets),
        Prefab( "common/inventory/armorvortexcloak_fx", fxfn, assets) 
