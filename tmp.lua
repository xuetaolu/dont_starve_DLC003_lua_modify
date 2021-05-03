__xue__.CAN_CANCEL_ATTACK = not __xue__.CAN_CANCEL_ATTACK


-- local saved = {}

-- saved.prefab   = 'treasurechest'
-- saved.scenario = 'x_kill'
-- saved.x, saved.y, saved.z = TheInput:GetWorldPosition():Get()

-- local inst = SpawnSaveRecord( saved, {} )
-- inst.kill_range = 64
-- inst:AddTag('debug')
-- inst.components.scenariorunner:Run()

-- saved.scenario = 'x_say_1'
-- saved.x        = saved.x + 2
-- inst = SpawnSaveRecord( saved, {} )
-- inst.components.scenariorunner:Run()

ACTIONS.TERRAFORM.fn = function(act)
    if act.invobject and act.invobject.components.terraformer then
        local tile = GetWorld().Map:GetTileAtPoint(act.pos.x, act.pos.y, act.pos.z)

        if tile == GROUND.GASJUNGLE then
            act.invobject.components.finiteuses:SetUses(0)
            GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_TOOLCORRODED"))
            return true
        elseif tile == GROUND.DEEPRAINFOREST then
            GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_TURFTOOHARD"))
            return true
        else
            return act.invobject.components.terraformer:Terraform(act.pos)
        end
    end
end

local function fn()

ACTIONS.TERRAFORM.fn = function(act)
    if act.invobject and act.invobject.components.terraformer then
        local tile = GetWorld().Map:GetTileAtPoint(act.pos.x, act.pos.y, act.pos.z)
        return act.invobject.components.terraformer:Terraform(act.pos)
    end
end

end


function x_wa()
    GetDebugEntity().components.terraformer:Terraform(TheInput:GetWorldPosition())
end
