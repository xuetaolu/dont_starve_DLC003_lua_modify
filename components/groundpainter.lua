local Groundpainter = Class(function(self, inst)
    self.inst = inst      
    self.water = false   
    self.range = 1 
    self.max = 5
    self.enabled = false
    self.rate = 1
    self.tags = {}
    self.notags = {}
end)


local function IsWaterTileType(ground)
    return (ground == GROUND.OCEAN_MEDIUM or ground == GROUND.OCEAN_DEEP)
end

function Groundpainter:SetPrefab(prefab)
    self.prefab = prefab
end

function Groundpainter:SetRange(range)
    self.range = range
end

function Groundpainter:SetMax(max)
    self.max = max
end

function Groundpainter:SetRate(rate)
    self.rate = rate
end

function Groundpainter:SetNotTiles(notiles)
    self.notiles = notiles
end

function Groundpainter:Process()
    local x,y,z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, self.range, self.tags,self.notags)

    if #ents < self.max then
        local dist = math.random() * self.range
        local angle = math.random() * 2 * PI

        local offset = Vector3(dist * math.cos( angle ), 0, -dist * math.sin( angle ))

        local newpt = Vector3(x+offset.x,y+offset.y,z+offset.z)

        if self.notiles then
            local ground = GetWorld()
            local tile = ground.Map:GetTileAtPoint(newpt.x, newpt.y, newpt.z)
            if not self.water and ground.Map:IsWater(tile) then
                return
            end
            for i,testtile in ipairs(self.notiles) do
                if tile == testtile then
                    print("ABORT")
                    return
                end
            end
        end

        local paint = SpawnPrefab(self.prefab)
        paint.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
    end
end

function Groundpainter:Enable(val)
    if self.enabled ~= val then
        self.enabled = val
        if self.enabled then        
            self.task = self.inst:DoPeriodicTask(self.rate, function() self:Process() end)
        else
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
        end
    end
end

--[[
function Groundpainter:OnSave()
    local data = {}

    return data
end   


function Groundpainter:OnLoad(data, newents)

end




function Grower:Groundpainter()
	return "Cycles left" .. tostring(self.cycles_left) .. " / " .. tostring(self.max_cycles_left)
end
]]

return Groundpainter
