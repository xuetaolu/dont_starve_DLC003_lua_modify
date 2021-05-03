require("stategraphs/commonstates")

local events = {}

local actionhandlers =
{
    ActionHandler(ACTIONS.CREATURE_THROW, "attack")
}

local states =
{   
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
    },

    State{ 
        name = "attack",
        tags = {"attack", "canrotate"},
        timeline =
        {
            TimeEvent(22*FRAMES, function(inst) 
                inst:PerformBufferedAction()
                --inst.components.finiteuses:Use(1)
                local x, y, z = inst.Transform:GetWorldPosition()
                y = y + 1
                
                local owner = inst.components.inventoryitem.owner

                if owner and owner.components.drivable and owner.components.drivable.driver then 
                    owner = owner.components.drivable.driver
                end

                local smoke =  SpawnPrefab("collapse_small")

                if owner then 
                    smoke.Transform:SetPosition(owner.AnimState:GetSymbolPosition("swap_sail", 0, 0, 0))
                else 
                    smoke.Transform:SetPosition(x, y, z)
                end 
                
                inst.sg:GoToState("idle")
            end),
        },
    },   
}

return StateGraph("boatcannon", states, events, "idle", actionhandlers)