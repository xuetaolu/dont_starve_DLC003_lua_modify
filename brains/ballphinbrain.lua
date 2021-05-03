require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"


local STOP_RUN_DIST = 12
local SEE_PLAYER_DIST = 7

local AVOID_PLAYER_DIST = 5
local AVOID_PLAYER_STOP = 8

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local SEE_BAIT_DIST = 20
local MAX_IDLE_WANDER_DIST = TUNING.SOLOFISH_WANDER_DIST

local WANDER_DIST_DAY = 8
local WANDER_DIST_NIGHT = 4

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local START_FOLLOW_DIST = 13

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 8
local TARGET_FOLLOW_DIST = 2

local SEE_FOOD_DIST = 10
local SEE_CORAL_DIST = 15
local KEEP_MINING_DIST = 10

local BallphinBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
	self.afraid = false
end)


function BallphinBrain:OnInitializationComplete()
	  self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
 end

local wandertimes =
{
	minwalktime = 2,
	randwalktime =  2,
	minwaittime = 0.1,
	randwaittime = 0.1,
}

local function EatFoodAction(inst)
	local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
	local target = FindEntity(inst, SEE_BAIT_DIST, function(item) return inst.components.eater:CanEat(item) and item.components.bait and not item:HasTag("planted") and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end, nil, notags)
	if target then
		local act = BufferedAction(inst, target, ACTIONS.EAT)
		act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
		return act
	end
end


local function GetWanderDistFn(inst)
    if GetClock() and not GetClock():IsDay() then
        return WANDER_DIST_NIGHT
    else
        return WANDER_DIST_DAY
    end
end

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("character", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") and target:GetIsOnWater(target:GetPosition():Get()) then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget") and target:GetIsOnWater(target:GetPosition():Get())
end

local function GetFollowTargetFn(inst)
    local target = GetClosestInstWithTag("character", inst, START_FOLLOW_DIST)
    if target and not target:HasTag("notarget") and target:GetIsOnWater(target:GetPosition():Get()) then
        return target
    end
end

local function HasValidHome(inst)
    return inst.components.homeseeker and
       inst.components.homeseeker.home and
       inst.components.homeseeker.home:IsValid()
end

local function GoHomeAction(inst)
    if not inst.components.follower.leader and
        HasValidHome(inst) and
        not inst.components.combat.target then
            return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function GetTraderFn(inst)
    return FindEntity(inst, TRADE_DIST, function(target) return inst.components.trader:IsTryingToTradeWithMe(target) end, {"player"})
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local function GetNoLeaderHomePos(inst)
    if GetLeader(inst) then
        return nil
    end
    return GetHomePos(inst)
end

local function FindFoodAction(inst)
    local target = nil

	if inst.sg:HasStateTag("busy") then
		return
	end

    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end

    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    local noveggie = time_since_eat and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD*4

    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then

        target = FindEntity(inst, SEE_FOOD_DIST, function(item)
				if item:GetTimeAlive() < 8 then return false end
				if item.prefab == "mandrake" then return false end
				if noveggie and item.components.edible and item.components.edible.foodtype ~= "MEAT" then
					return false
				end
				if not item:IsOnValidGround() then
					return false
				end

				return inst.components.eater:CanEat(item)
			end)

    end

    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item)
                if not item.components.shelf then return false end
                if not item.components.shelf.itemonshelf or not item.components.shelf.cantakeitem then return false end
                if noveggie and item.components.shelf.itemonshelf.components.edible and item.components.shelf.itemonshelf.components.edible.foodtype ~= "MEAT" then

                    return false
                end
                if not item:IsOnValidGround() then
                    return false
                end

                return inst.components.eater:CanEat(item.components.shelf.itemonshelf)
            end)
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end

end

local function KeepMiningAction(inst)
    local keep_mine = inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_MINING_DIST*KEEP_MINING_DIST
    local target = FindEntity(inst, SEE_CORAL_DIST/3, function(item)
        return item.prefab == "coralreef" and item.components.workable and item.components.workable.action == ACTIONS.MINE 
    end)    

    return (keep_mine or target ~= nil)
end

local function StartMiningCondition(inst)
    local start_mine = inst.components.follower.leader and inst.components.follower.leader.sg and 
            (inst.components.follower.leader.sg:HasStateTag("mining") or inst.components.follower.leader.sg:HasStateTag("premine"))
    
    return start_mine
end


local function FindCoralToMineAction(inst)
    local target = FindEntity(inst, SEE_CORAL_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.MINE end)
    if target then
        return BufferedAction(inst, target, ACTIONS.MINE)
    end
end

function BallphinBrain:OnStart()

	local afraid = WhileNode( function() return self.afraid end, "IsAfraid",
        PriorityNode{
            ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_FIND_LIGHT,
                FindLight(self.inst)),
            ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_PANIC,
                Panic(self.inst)),
        },1)

     local clock = GetClock()
     local day = WhileNode( function() return clock and clock:IsDay() end, "IsDay",
                PriorityNode{
                    IfNode(function() return StartMiningCondition(self.inst) end, "mine", 
                        WhileNode(function() return KeepMiningAction(self.inst) end, "keep mining",
                            LoopNode{ 
                                ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_HELP_MINE_CORAL,
                                DoAction(self.inst, FindCoralToMineAction ))}
                                )
                           )
                },1)          
     
	 local night = WhileNode( function() return clock and not clock:IsDay() end, "IsNight",
        PriorityNode{
            ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_HOME,
                DoAction(self.inst, GoHomeAction, "go home", true )),
        },1)

	local root = PriorityNode(
	{
        WhileNode(function() return not self.inst.entity:IsVisible() end, "Hiding", StandStill(self.inst)),
        WhileNode(function() return not self.inst:HasTag("ballphinfriend") end, "Not a ballphinfriend", ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
		WhileNode(function() return self.inst:HasTag("ballphinfriend") end, "a ballphinfriend", ChaseAndAttack(self.inst, 100)),
        ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_FIND_MEAT, DoAction(self.inst, FindFoodAction )),
		afraid,
		night,
        ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_FOLLOWWILSON, Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
		Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, 30, 20),
        day,
        Follow(self.inst, function() return GetFollowTargetFn(self.inst) end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
		Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, GetWanderDistFn)
	}, .25)
	self.bt = BT(self.inst, root)
end

return BallphinBrain
