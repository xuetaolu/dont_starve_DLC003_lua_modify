local ChestButton=function( ... )
    local public, private = {}, {}, {}
    local self   = public

    self.openfn=function( inst, data )
        local player = GetPlayer()
        if player then
            player.components.talker:Say( inst.prefab )
        end
    end

    self.OnCreate=function( inst, scenariorunner )
        
    end

    self.OnLoad=function( inst, scenariorunner )
        inst.scene_triggerfn = function( inst, data )  
            if self.openfn then
                self.openfn( inst, data )
            end
        end
        inst:ListenForEvent("onopen", inst.scene_triggerfn)
    end

    self.OnDestroy=function(inst)
        if inst.scene_triggerfn then
            inst:RemoveEventCallback("onopen", inst.scene_triggerfn)
            inst.scene_triggerfn = nil
        end
    end

    private.Init = function()
    end
    private.Init( ... )
    return self
end

return ChestButton
