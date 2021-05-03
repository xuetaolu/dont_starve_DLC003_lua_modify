local res = require("scenarios/x_chestbutton")()

res.openfn = function( inst, data ) 
    local player = GetPlayer()
    if player then
        player.components.talker:Say( 'hello' )
    end
end

return res
