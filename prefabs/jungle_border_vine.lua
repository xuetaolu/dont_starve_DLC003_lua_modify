local assets=
{
	Asset("ANIM", "anim/vines_rainforest_border.zip"),    
}


local prefabs =
{
}    

local function onsave(inst, data)
	data.animchoice = inst.animchoice
end

local function onload(inst, data)
    if data and data.animchoice then
        inst.animchoice = data.animchoice
	    inst.AnimState:PlayAnimation("idle_"..inst.animchoice)
	end
end


local function plantfn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("vine_rainforest_border")
    inst:AddTag("NOCLICK")
    inst.AnimState:SetBuild("vines_rainforest_border")

    inst:AddComponent("distancefade")
    inst.components.distancefade:Setup(15,25)

    local color = 0.7 + math.random() * 0.3
    inst.AnimState:SetMultColour(color, color, color, 1)    

    inst.animchoice = math.random(1,6)
    inst.AnimState:PlayAnimation("idle_"..inst.animchoice)

    inst:ListenForEvent( "renderjunglevines", 
          function(it, data) 
				if data.value == true then
					inst:Show()
				else
					inst:Hide()
				end
          end, GetWorld()) 

    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 
    
    return inst
end



return Prefab( "forest/objects/jungle_border_vine", plantfn, assets, prefabs)
