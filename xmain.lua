global( '_xmain' ) _xmain = _xmain or {} G = _xmain

if not G.binddodge then
    G.binddodge = true
    TheInput:AddKeyUpHandler(KEY_Z, function()
        local inst = GetPlayer()
        if (GetTime() - inst.last_dodge_time > TUNING.WHEELER_DODGE_COOLDOWN) and 
                    not inst.components.driver:GetIsDriving() and not inst.components.rider:IsRiding() then
        inst.components.locomotor:GoToPoint( 
            TheInput:GetWorldPosition(), 
            BufferedAction(GetPlayer(), nil, ACTIONS.DODGE, nil, TheInput:GetWorldPosition() ), 
            true )
        end
    end )
end

function xsave()
    SaveGameIndex:SaveCurrent()
end

c_enablecheats()