require 'util'

-- xkill()
-- xday()
-- xreset()
-- xue()
-- xmaze()
-- xboons()
-- xtraps()
-- xpres()
-- xinterest()
-- xlayouts()
-- Save()
-- Load()

local layout_name = ""

function xclear()
    xkill( 256 )
end

function xkill( range )
    range = range or 10
    local x,y,z = TheInput:GetWorldPosition():Get()
    -- for k,v in pairs( TheSim:FindEntities( x,y,z, range) ) do
    --     if v ~= GetPlayer() then
    --         if v.components.health then
    --             v.components.health:Kill()
    --         elseif v.Remove then
    --             v:Remove()
    --         end
    --         if v:HasTag('wall') then v:Remove() return end
    --     end
    -- end

    -- local x,y,z = inst.Transform:GetWorldPosition()
    -- local range = inst.kill_range or 10
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

function xday()
    GetClock():Reset()
    GetSeasonManager():SetSeason(SEASONS.TEMPERATE)
end

local _g = {}

function xreset()
    _g = {}
end

c_enablecheats()

function Save()
    SaveGameIndex:SaveCurrent()
end

function Load()
    StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
end

function season()
    print( GetSeasonManager():GetDebugString() )
end

GetPlayer().components.talker:Say('pig city')

function x_select()
    SetDebugEntity(TheInput:GetWorldEntityUnderMouse())
end