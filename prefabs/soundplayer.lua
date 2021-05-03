


local function soundcompletecheck(inst)
    if not inst.SoundEmitter:PlayingSound("mysound") then 
        inst:Remove()
    end 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst:AddTag("FX")
    inst.persists = false
    local theta = math.random(0, 2*PI)
    local radius = 10

    inst.PlaySound = function(position, sound)
        inst.Transform:SetPosition(position.x,position.y,position.z)
        inst.SoundEmitter:PlaySound(sound, "mysound")
        inst:DoPeriodicTask(1, soundcompletecheck)
    end 

    inst:AddTag("FX")  
    return inst
end

return Prefab( "common/fx/soundplayer", fn) 

