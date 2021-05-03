

local XP_PER_DAY = 20

local XP_levels = 
{   
    XP_PER_DAY*8, 
    XP_PER_DAY*16,
    XP_PER_DAY*32,  
    XP_PER_DAY*48,
    XP_PER_DAY*64,
    XP_PER_DAY*80,
    -- XP_PER_DAY*96,
    -- XP_PER_DAY*112,
}



--Wes & Maxwell unlocked through other means.
local Level_rewards = {'willow', 'wolfgang', 'wendy', 'wx78', 'wickerbottom', 'woodie'} 

local function CheckDLC()
    local start_num = #Level_rewards

    if IsDLCInstalled(REIGN_OF_GIANTS) then
        if not table.contains(Level_rewards, 'wathgrithr') then
            table.insert(Level_rewards, 'wathgrithr')
        end
    end

    if IsDLCInstalled(CAPY_DLC) then
        if not table.contains(Level_rewards, 'walani') then
            table.insert(Level_rewards, 'walani')
        end

        if not table.contains(Level_rewards, 'warly') then
            table.insert(Level_rewards, 'warly')
        end

        --Wilbur and Woodlegs unlocked through other means.
    end

    if IsDLCInstalled(PORKLAND_DLC) then
        if not table.contains(Level_rewards, 'wheeler') then
            table.insert(Level_rewards, 'wheeler')
        end
        
        --Wilba unlocked through other means.
    end

    local end_num = #Level_rewards
    local addtl = end_num - start_num

    for i = 1, addtl do
        table.insert(XP_levels, XP_levels[#XP_levels] + XP_PER_DAY * 16)
    end
end


local function GetLevelForXP(xp)
    local last = 0
    for k,v in ipairs(XP_levels) do
        if xp < v then
            local percent = ((xp - last) / (v - last))
            return k-1, percent
        end
        last = v
    end
    --at cap!
    return #XP_levels, 0
end

    
return 
{
	GetXPCap = function()
		CheckDLC()
        return XP_levels[#XP_levels]
	end,
	
    GetRewardsForTotalXP = function(xp)
        CheckDLC()
        local Level_cap = #XP_levels
        local level = math.min(GetLevelForXP(xp), Level_cap)
        local rewards = {}
    
        -- print("__________ LEVEL REWARDS __________")

        -- print(GetLevelForXP(xp))
        -- print(Level_cap)

        -- dumptable(Level_rewards)

        if level > 0 then
            for k = 1, math.min(level, #Level_rewards) do
                table.insert(rewards, Level_rewards[k])
            end
        end
        return rewards
    end,
    
    GetRewardForLevel = function(level)
        CheckDLC()
        level = level + 1
        if level > 0 and level <= #Level_rewards then
            return Level_rewards[level]
        end
    end,
    
    GetXPForDays = function(days)
		CheckDLC()
        return XP_PER_DAY*days
    end,

    GetXPForLevel = function(level)
        CheckDLC()
        if level == 0 then
            return 0, XP_levels[1]
        end
        if level <= #XP_levels then
            return XP_levels[level], level + 1 <= #XP_levels and (XP_levels[level + 1] - XP_levels[level]) or 0
        end
        
    end,

    GetLevelForXP = function (xp)
        CheckDLC()
        return GetLevelForXP(xp)
    end, 

    IsCappedXP = function(xp)
        CheckDLC()
        return xp >= XP_levels[#XP_levels]
    end
}
