local res = require("scenarios/x_chestbutton")()

res.openfn = function( inst, data ) 
    local x,y,z = inst.Transform:GetWorldPosition()
    local range = inst.kill_range or 10
    for k,v in pairs( TheSim:FindEntities( x,y,z, range) ) do
        if (not v:HasTag('debug')) and not (v.components.inventoryitem and v.components.inventoryitem:GetContainer()) then
            if v ~= GetPlayer() then
                if v.components.health then
                    v.components.health:Kill()
                elseif v.Remove then
                    v:Remove()
                end
                if v:HasTag('wall') then v:Remove() return end
            end
        end
    end
end

return res
