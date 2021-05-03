local Breeder = Class(function(self, inst)
    self.inst = inst
    self.crops = {}
    self.volume = 0
    self.max_volume = 4
    self.seeded = false
    self.harvestable = false
    self.level = 1
    self.croppoints = {}
    self.growrate = 1


    self.inst:AddTag("breeder")
    
end)



function Breeder:IsEmpty()
    return self.volume == 0
end

function Breeder:OnSave()
    local data = {
        harvestable = self.harvestable,
        volume = self.volume,
        seeded = self.seeded,
        product = self.product,
        harvested = self.harvested,
    }

    if self.breedTask then     
        data.breedtasktime = GetTaskRemaining(self.breedTask)     
    end

    if self.luretask then
        data.luretasktime = GetTaskRemaining(self.luretask) 
    end

    return data
end    

function Breeder:OnLoad(data, newents)    
	self.volume = data.volume
    self.seeded = data.seeded
    self.harvestable = data.harvestable
    self.product = data.product   
    self.harvested= data.harvested         
    --self.inst:AddTag("NOCLICK")    

    if data.breedtasktime then        
        self.breedTask = self.inst:DoTaskInTime(data.breedtasktime,function() self:checkVolume() end)
    end

    if data.luretasktime then
        self.lureTask = self.inst:DoTaskInTime(data.luretask,function() self:checkLure() end)
    end

    self.inst:DoTaskInTime(0, function() self.inst:PushEvent("onVisChange", {}) end )
end

function Breeder:checkSeeded()
    if self.volume < 1 and not self.harvestable then        
        self:StopBreeding()
    end 
    self.inst:PushEvent("onVisChange", {})
end

function Breeder:updatevolume(delta)
    self.volume = math.min(math.max(self.volume + delta,0),self.max_volume)
    self:checkSeeded()
end


local function SpawnPredatorPrefab(inst)

    local sm = GetSeasonManager()
    local prefab = "crocodog"

    local world = GetWorld()
    local x, y, z = inst.Transform:GetWorldPosition()
    local tile, tileinfo = inst:GetCurrentTileType(x, y, z)

    if tile == GROUND.OCEAN_DEEP or tile == GROUND.OCEAN_MEDIUM then
        if math.random() < 0.7 then
            prefab = "swordfish"
        end
    end

    local pt = Vector3(inst.Transform:GetWorldPosition())
    local predators = TheSim:FindEntities(pt.x, pt.y, pt.z, 10, {"crocodog","swordfish"}, nil)

    if #predators > 2 then
        return nil
    end
    print("PREDATORS SPAWNING")
    return SpawnPrefab(prefab)
end


function Breeder:summonpredator()
    local spawn_pt = Vector3(self.inst.Transform:GetWorldPosition())


    if spawn_pt then
        local predator = SpawnPredatorPrefab(self.inst)

        if predator then
          --  local ptp = spawn_pt:Get()
            local radius = 30 
            local base = spawn_pt
            local theta = math.random() * 2 * PI
            local offset = Vector3(0,0,0)

            if self.inst:GetDistanceSqToInst(GetPlayer()) < radius * radius then
               offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))            
               base = Vector3(GetPlayer().Transform:GetWorldPosition())
            end

            predator.Physics:Teleport(base.x+ offset.x, base.y+offset.y, base.z+offset.z)
            predator.components.combat:SuggestTarget(GetPlayer())
        end
    end
end

function Breeder:checkLure()
    if self.volume > 0 then
        if math.random()*120/math.pow(self.volume,1.5) <=1 then
            self:summonpredator()
        end
    end
    self.lureTask = self.inst:DoTaskInTime(TUNING.FISH_FARM_LURE_TEST_TIME,function() self:checkLure() end)
end

function Breeder:checkVolume()
    if self.seeded then
     --[[   if self.volume > 0 and not self.harvestable then
            self.harvestable = true    
        else]]
            self:updatevolume(1)            
        --end
        self.inst:PushEvent("onVisChange", {})
        local time = math.random(TUNING.FISH_FARM_CYCLE_TIME_MIN,TUNING.FISH_FARM_CYCLE_TIME_MAX)

        self.breedTask = self.inst:DoTaskInTime(time, function() self:checkVolume() end)
    end
end

function Breeder:Seed(item)

    if not item.components.seedable then
        return false
    end
    
    self:Reset()
    
    local prefab = nil
    if item.components.seedable.product and type(item.components.seedable.product) == "function" then
		prefab = item.components.seedable.product(item)
    else
		prefab = item.components.seedable.product or item.prefab
	end
    self.product = prefab

    self.seeded = true

    local time = math.random(TUNING.FISH_FARM_CYCLE_TIME_MIN,TUNING.FISH_FARM_CYCLE_TIME_MAX)

    self.breedTask = self.inst:DoTaskInTime(time,function() self:checkVolume() end)

    self.lureTask = self.inst:DoTaskInTime(TUNING.FISH_FARM_LURE_TEST_TIME,function() self:checkLure() end)

    if self.onseedfn then
		self.onseedfn(item)
    end
    self.inst:PushEvent("onVisChange", {})
	item:Remove()    
	
    return true
end

function Breeder:CollectSceneActions(doer, actions)
    if self.volume > 0 and doer.components.inventory then
        table.insert(actions, ACTIONS.HARVEST)
    end
end



function Breeder:Harvest(harvester)

    self.inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_small")
    self.inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/fish_farm/harvest")

    self.harvestable = false
    self.harvested = true
    if harvester.components.inventory then
        local product = SpawnPrefab(self.product)
        harvester.components.inventory:GiveItem(product)
    else
        harvester.components.lootdropper:SpawnLootPrefab(self.product)
    end
    self:updatevolume(-1)   

    return true
end

function Breeder:GetDebugString()
    return "seeded: ".. tostring(self.seeded) .." harvestable: ".. tostring(self.harvestable) .." volume: ".. tostring(self.volume)
end

function Breeder:Reset()
    self.harvested = false
    self.seeded = false
    self.harvestable = false
    self.volume = 0   
    self.product = nil 
    self.inst:PushEvent("onVisChange", {})

    if self.lureTask then
        self.lureTask:Cancel()
        self.lureTask = nil
    end
end

function Breeder:StopBreeding()
    self:Reset()
    if self.breedTask then
        self.breedTask:Cancel()
        self.breedTask = nil
    end
end

return Breeder
