require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandattack"
require "behaviours/leash"

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 7
local MAX_FOLLOW_DIST = 10

local MIN_FRIEND_FOLLOW_DIST = 0
local TARGET_FRIEND_FOLLOW_DIST = 5
local MAX_FRIEND_FOLLOW_DIST = 10

local RUN_AWAY_DIST = 7
local STOP_RUN_AWAY_DIST = 15

local SEE_FOOD_DIST = 10

local MAX_WANDER_DIST = 20

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local TIME_BETWEEN_EATING = 30

local LEASH_RETURN_DIST = 15
local LEASH_MAX_DIST = 20

local PrimeapeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--No longer used, the checks now use the function below (IsPlayerFriendOfMe)
local function IsPlayerFriendOfPrimeapes(inst)
   return GetPlayer().components.leader:CountFollowers("primeape") > 0 or GetPlayer():HasTag("monkey")
end

local function FriendsWithPlayer(inst)
    return inst.components.follower.leader == GetPlayer()
end

local function IsPlayerFriendOfMe(inst)
   return FriendsWithPlayer(inst) or GetPlayer():HasTag("monkey")
end

local function HasMonkeyBait(inst)
    local ball = inst.components.inventory:FindItem(function(item) return item:HasTag("monkeybait") end)
    if ball then
        -- print("I have the ball!")
        return true
    end
end

local function ShouldRunFn(inst, hunter)
    if inst.components.combat.target then
        return hunter == GetPlayer()
    end
end

local function GetPoop(inst)
    local target = nil

    if inst.sg:HasStateTag("busy") then
        return
    end
    target = FindEntity(inst, SEE_FOOD_DIST, function(item)    
    
    if item.prefab ~= "poop" then
        return false
    end
    if not item.components.inventoryitem or (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) then 
        return false
    end
    if not item:IsOnValidGround() then
        return false
    end
    if distsq(inst.components.combat.target:GetPosition(), item:GetPosition()) < RUN_AWAY_DIST * RUN_AWAY_DIST then
        return false
    end
    
    return true
    
    end)

    if target then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
    end

end

local ValidFoodsToPick = 
{
    "berries",
    "cave_banana",
    "carrot",
    "sweet_potato",
    "red_cap",
    "blue_cap",
    "green_cap", 
}

local function ItemIsInList(item, list)
    for _, v in ipairs(list) do
        if v == item then
            return true
        end
    end
end

local function CanPickup(item)
     local ret = item:IsValid() and
        item.components.inventoryitem and 
        not item.components.inventoryitem:IsHeld() and
        item.components.inventoryitem.canbepickedup and
        not item.components.inventoryitem.owner and

        not item.components.container and
        not item.components.inventory and
        not item:HasTag("irreplaceable") and
        not item:HasTag("nosteal") and
        not item:HasTag("trap")

        and item:IsOnValidGround()

    return ret
end


local function EatFoodAction(inst)

    if inst.sg:HasStateTag("busy") then
        return
    end

    local player = GetPlayer()

    --Get the stuff around you and store it in ents
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST*2, nil, {"aquatic", "falling", "FX", "NOCLICK", "DECOR", "INLIMBO"})

    for _, item in ipairs(ents) do
        
        local owner = item.components.inventoryitem and item.components.inventoryitem.owner
        if not owner and item:HasTag("monkeybait") and item:IsOnValidGround() then
            -- print('monkey eat ball', item:HasTag('falling'), item:HasTag('aquatic'))
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end


    if (inst.components.eater:TimeSinceLastEating() and inst.components.eater:TimeSinceLastEating() < TIME_BETWEEN_EATING) or
        (inst.components.inventory and inst.components.inventory:IsFull()) then

        return
    end

    if math.random() < 0.75 then
        return
    end

    -- eat from own bag
    if inst.components.inventory and inst.components.eater then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then 
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

    --If you're not wearing a hat, look for a hat to wear!
    for _, item in ipairs(ents) do
        if item.components.equippable and 
        item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
        (inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)) and
        CanPickup(item) then
            -- print("pickup 1", item.prefab)
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end

    --Look for food on the ground, pick it up
    for _, item in ipairs(ents) do
        if item:GetTimeAlive() > 8 and inst.components.eater:CanEat(item) and CanPickup(item) then
            -- print("pickup 2", item.prefab)
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end

    --Look for harvestable items, pick them.
    for _, item in ipairs(ents) do
        if item.components.pickable and item.components.pickable.caninteractwith and item.components.pickable:CanBePicked()
        and (ItemIsInList(item.components.pickable.product, ValidFoodsToPick) or item.prefab == "worm") then
            return BufferedAction(inst, item, ACTIONS.PICK)
        end
    end

    --Look for crops items, harvest them.
    for _, item in ipairs(ents) do
        if item.components.crop and item.components.crop:IsReadyForHarvest() then
            return BufferedAction(inst, item, ACTIONS.HARVEST)
        end
    end

    if not inst.curious or inst.components.combat.target then
        return
    end

    if IsPlayerFriendOfMe(inst) then
        -- we are friends with the player, don't annoy him
        return
    end

    ---At the very end, look for a random item to pick up and do that.
    for _, item in ipairs(ents) do
        if CanPickup(item) then
            
            inst.curious = false
            inst:DoTaskInTime(10, function() inst.curious = true end)
            -- print("pickup 3", item.prefab)
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end
end




local function AnnoyPlayer(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local player = GetPlayer() -- You will only ever harass the player.
    if IsPlayerFriendOfMe(inst) then
        -- we are friends with the player, don't annoy him
        return
    end

    local p_pt = player:GetPosition()
    local m_pt = inst:GetPosition()
    local ents = TheSim:FindEntities(m_pt.x, m_pt.y, m_pt.z, 30, nil, {"aquatic", "falling", "FX", "NOCLICK", "DECOR", "INLIMBO", "irreplaceable", "nosteal", "trap"})

    --Can we hassle the player by taking items from stuff he has killed or worked?
    for _, item in pairs(ents) do
        if CanPickup(item) and item:GetTimeAlive() < 5 then
            -- print("pickup 4", item.prefab)
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end

    --Can we hassle our player by taking the items he wants?
    local ba = player:GetBufferedAction()
    if ba and ba.action.id == "PICKUP" then
        --The player wants to pick something up. Am I closer than the player?
        local tar = ba.target

        local t_pt = tar:GetPosition()

        if CanPickup(tar) and distsq(p_pt, t_pt) > distsq(m_pt, t_pt) then
            --I'm closer to the item than the player! Lets go get it!
            -- print("pickup 5", item.prefab)
            return BufferedAction(inst, tar, ACTIONS.PICKUP)
        end
    end
end

local function GetFaceTargetFn(inst)
    return inst.components.combat.target
end

local function KeepFaceTargetFn(inst, target)
    return target == inst.components.combat.target
end

local function HarassPlayer(inst)

    if IsPlayerFriendOfMe(inst) then
        -- we are friends with the player, don't annoy him
        return
    end

    local player = GetPlayer() -- You will only ever harass the player.
    return inst.harassplayer and not (player and player.components.driver and player.components.driver:GetIsDriving())
end

local function GoHome(inst)
    if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function AssistPlayer(inst)
    --Do some sort of cooldown on this action. 30-60 seconds?
    if inst.CanThrowItems then
        --If I have stuff in my inventory, throw it towards the player.
        if inst.components.inventory then
            local throwable = inst.components.inventory:FindItem(function(item) return not inst.components.eater:CanEat(item) and not item.components.fertilizer end)
            if throwable then
                --Add throwable component, remove when it is picked up again.
                if not throwable.components.throwable then
                    throwable:AddComponent("throwable")
                    throwable.throwable_onputininventory = function()
                        throwable:RemoveComponent("throwable")
                        throwable:RemoveEventCallback("onputininventory", throwable.throwable_onputininventory)
                        throwable.throwable_onputininventory = nil
                    end
                    throwable:ListenForEvent("onputininventory", throwable.throwable_onputininventory)
                end

                return BufferedAction(inst, GetPlayer(), ACTIONS.THROW, throwable)
            end
        end
        
        --If there is anything nearby (but still farish from the player) that I can pick, pick it.
        local pt = inst:GetPosition()
        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST*2, nil, {"aquatic", "falling", "FX", "NOCLICK", "DECOR", "INLIMBO"})

        --Look for harvestable items, pick them.
        for _, item in pairs(ents) do
            if item.components.pickable and item.components.pickable.caninteractwith and item.components.pickable:CanBePicked() and not item:GetIsOnWater() then
                inst.components.timer:StartTimer("CanThrow", TUNING.PRIMEAPE_THROW_COOLDOWN)
                inst.CanThrowItems = false
                return BufferedAction(inst, item, ACTIONS.PICK)
            end
        end

        --Look for crops items, harvest them.
        for _, item in pairs(ents) do
            if item.components.crop and item.components.crop:IsReadyForHarvest() and not item:GetIsOnWater() then
                inst.components.timer:StartTimer("CanThrow", TUNING.PRIMEAPE_THROW_COOLDOWN)
                inst.CanThrowItems = false
                return BufferedAction(inst, item, ACTIONS.HARVEST)
            end
        end
    end
end

local function GetRidOfTheBall(inst)
    local ball = inst.components.inventory:FindItem(function(item) return item:HasTag("monkeybait") end)
    local action

    if math.random() < TUNING.MONKEYBALL_PASS_TO_PLAYER_CHANCE then
        action = BufferedAction(inst, GetPlayer(), ACTIONS.THROW, ball)
    else
        local pos = inst:GetPosition()
        local offset, _, _ = FindWalkableOffset(inst:GetPosition(), math.random()*2*PI, math.random()*5 + 5, 8, true, false) -- try to avoid walls

        if offset then
            action = BufferedAction(inst, nil, ACTIONS.THROW, ball, pos + offset)
        else
            action = BufferedAction(inst, GetPlayer(), ACTIONS.THROW, ball)
        end
        -- doer, target, action, invobject, pos, recipe, distance, rotation
    end
    
    return action
end

local function HomeOffset(inst)
    local home = inst.components.homeseeker and inst.components.homeseeker.home

    if home then
        local rad = home.Physics:GetRadius() + inst.Physics:GetRadius() + 0.2
        local vec = (inst:GetPosition() - home:GetPosition()):Normalize()
        local offset = Vector3(vec.x * rad, 0, vec.z * rad)

        return home:GetPosition() + offset
    else
        return inst:GetPosition()
    end
end

function PrimeapeBrain:OnStart()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        --Primeapes go home when quakes start.
        EventNode(self.inst, "gohome", 
            DoAction(self.inst, GoHome)),

        SequenceNode{
            ConditionNode(function() return HasMonkeyBait(self.inst) end, "HasBall"),
            ParallelNodeAny {
                WaitNode(4+math.random()*2),
                Panic(self.inst),
            },
            DoAction(self.inst, GetRidOfTheBall),
        },
        
        Follow(self.inst, function() return FindEntity(self.inst, 20, HasMonkeyBait, {"primeape"}) end, 1, 1.5, 2),


        --In combat (with the player)... Should only ever use poop throwing.
        RunAway(self.inst, "character", RUN_AWAY_DIST, STOP_RUN_AWAY_DIST, function(hunter) return ShouldRunFn(self.inst, hunter) end),
        
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() and self.inst.HasAmmo(self.inst) end, "Attack Player", 
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
        --Pick up poop to throw
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() and not self.inst.HasAmmo(self.inst) end, "Pick Up Poop", 
            DoAction(self.inst, GetPoop)),
        --Eat/ pick/ harvest foods.
        WhileNode(function() return (self.inst.components.combat.target == GetPlayer() or self.inst.components.combat.target == nil) end, "Should Eat",
            DoAction(self.inst, EatFoodAction)),
        --Priority must be lower than poop pick up or it will never happen.
        WhileNode(function() return self.inst.components.combat.target == GetPlayer() and not self.inst.HasAmmo(self.inst) end, "Leash to Player",
        PriorityNode{
            Leash(self.inst, function() if self.inst.components.combat.target then return self.inst.components.combat.target:GetPosition() end end, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
        }),


        --In combat with everything else
        WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat.target ~= GetPlayer() end, "Attack NPC", --For everything else
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),

        
        --Following
        WhileNode(function() return HarassPlayer(self.inst) end, "Annoy Player", 
            DoAction(self.inst, AnnoyPlayer)),
        Follow(self.inst, function() return HarassPlayer(self.inst) and GetPlayer() end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        --Prime apes like the player.        
        WhileNode(function() return IsPlayerFriendOfMe(self.inst) end, "Assist Player", 
            DoAction(self.inst, AssistPlayer)),

        -- Following as a friend
        Follow(self.inst, function() return FriendsWithPlayer(self.inst) and GetPlayer() end, MIN_FRIEND_FOLLOW_DIST, TARGET_FRIEND_FOLLOW_DIST, MAX_FRIEND_FOLLOW_DIST),

		-- occasionally just go home
		WhileNode(function() return not self.inst.components.timer:TimerExists("go_home_delay") end, "Occasionally go home",
            DoAction(self.inst, GoHome)),

        --Doing nothing
        WhileNode(function() return HarassPlayer(self.inst)  end, "Wander Around Player", 
            Wander(self.inst, function() if HarassPlayer(self.inst)  then return GetPlayer():GetPosition() end end, MAX_FOLLOW_DIST)),
        WhileNode(function() return not HarassPlayer(self.inst) and not self.inst.components.combat.target end,
        "Wander Around Home", Wander(self.inst, function() return HomeOffset(self.inst) end, MAX_WANDER_DIST))
    }, .25)
    self.bt = BT(self.inst, root)
end

return PrimeapeBrain
