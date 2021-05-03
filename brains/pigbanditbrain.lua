require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_FOOD_DIST = 10
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8
local SEE_STOLEN_ITEM_DIST = 10
local MAX_WANDER_DIST = 20



local function FindRandomOffscreenPoint(inst)
    local OFFSET = 70
    --local x,y,z = inst.Transform:GetWorldPosition()

    local pt = Vector3(inst.Transform:GetWorldPosition() )
    
    local theta = math.random() * 2 * PI
    local radius = OFFSET

    local offset = FindWalkableOffset(pt, theta, radius, 12, true) --12

    if offset then
        local newpt = pt + offset
        local ground = GetWorld()
        local tile = GROUND.GRASS
        if ground and ground.Map then
            tile = inst:GetCurrentTileType(newpt:Get())

            local onWater = ground.Map:IsWater(tile)
            if not onWater then 
                return newpt
            end 
        end        
    end
    print("FAILED!!!!!!")
    return nil
end


local function GoHomeAction(inst)
    local position = FindRandomOffscreenPoint(inst)

    if not inst.components.homeseeker:HasHome() then
        inst.components.homeseeker:SetHome(SpawnPrefab("pigbanditexit"))
    end

    if position then        
        inst.components.homeseeker.home.Transform:SetPosition(position.x, position.y, position.z)
    --if inst.components.homeseeker and inst.components.homeseeker:HasHome() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    --end
    end
end

local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST,
        function(item)
            return inst.components.eater:CanEat(item) and
            item.components.bait and
            not item:HasTag("planted") and
            not (item.components.inventoryitem and
                item.components.inventoryitem:IsHeld())
        end)

    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end

local function OincNearby(inst)
    return FindEntity(inst, SEE_STOLEN_ITEM_DIST,
            function(item)
                local x,y,z = item.Transform:GetWorldPosition()
                local isValidPosition = x and y and z
                local isValidPickupItem =
                    isValidPosition and
                    item.components.inventoryitem and
                    not item.components.inventoryitem:IsHeld() and
                    item.components.inventoryitem.canbepickedup and
                    item:IsOnValidGround() and
                    not item:HasTag("trap") and
                    item.components.currency -- bandits only steal money
                return isValidPickupItem
            end)
end

local function PickupAction(inst)
    local target = OincNearby(inst)

    if target then
        return BufferedAction(inst, target, ACTIONS.PICKUP)
    end
end

local PigBanditBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetPlayerPos(inst)
    return Vector3(GetPlayer().Transform:GetWorldPosition())
end

function PigBanditBrain:OnStart()
    local clock = GetClock()

    local root = 
        PriorityNode(
        {
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
				ChattyNode(self.inst, STRINGS.PIG_TALK_PANICFIRE, Panic(self.inst))),
            WhileNode(function() return ( self.inst.attacked or (self.inst.components.inventory:NumItems() > 1 and not OincNearby(self.inst))) and not self.inst.sg:HasStateTag("busy") end, "run off with prize",
                DoAction(self.inst, GoHomeAction, "disappear", true)),
            DoAction(self.inst, PickupAction, "searching for prize", true),
            ChattyNode(self.inst, STRINGS.BANDIT_TALK_FIGHT,
                WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                    ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST))),
            RunAway(self.inst, function(guy) return guy:HasTag("pig") and guy.components.combat and guy.components.combat.target == self.inst end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
            Wander(self.inst, GetPlayerPos, MAX_WANDER_DIST)
        }, .5)

    self.bt = BT(self.inst, root)
end

return PigBanditBrain
