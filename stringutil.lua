local function getcharacterstring(tab, item, modifier)
    if modifier then
        if type(modifier) == "table" then
            for i,v in ipairs(modifier) do
                v = string.upper(v)
            end
        else
		  modifier = string.upper(modifier)
        end
	end


    if tab then
        local topic_tab = tab[item]
        if topic_tab then
            if type(topic_tab) == "string" then
		        return topic_tab
            elseif type(topic_tab) == "table" then
                if modifier then
                    if type(modifier) == "table" and #modifier > 1 then
                        local curr = topic_tab[modifier[1]]
                        if curr then
                            for i,v in ipairs(modifier) do
                                if i > 1 then
                                    curr = curr[v]
                                end
                            end
                        end
                        return curr
                    elseif topic_tab[modifier] then
                        return topic_tab[modifier]
                    end
                end

                if topic_tab['GENERIC'] then
                    return topic_tab['GENERIC']
                end

				if #topic_tab > 0 then
					return topic_tab[math.random(#topic_tab)]
				end
            end
        end
    end
end

function GetGenderStrings(charactername)
    if table.contains(CHARACTER_GENDERS.MALE, charactername) then
        return "MALE"
    elseif table.contains(CHARACTER_GENDERS.FEMALE, charactername) then
        return "FEMALE"
    elseif table.contains(CHARACTER_GENDERS.ROBOT, charactername) then
        return "ROBOT"
    else
        return "MALE"
    end
end

function CraftMonkeyString()
    local function NumInRange(num, min, max)
        return (num <= max) and (num > min)
    end

    local STRING_STATE = "START"

    local string_start = function()
        local str = "O"
        if STRING_STATE == "START" then
            str = string.upper(str)
        end
        local l = math.random(2, 4)
        for i = 2, l do
            local nextletter = (math.random() > 0.3 and "o") or "a"
            str = str..nextletter
        end
        return str
    end

    local endings =
    {
        "",
        "e",
        "h",
    }

    local string_end = function()
        return endings[math.random(#endings)]
    end

    local string_space = function()
        local c = math.random()
        local str =
        (NumInRange(c, 0.4, 1) and " ") or
        (NumInRange(c, 0.3, 0.4) and ", ") or
        (NumInRange(c, 0.2, 0.3) and "? ") or
        (NumInRange(c, 0.1, 0.2) and ". ") or
        (NumInRange(c, 0, 0.1) and "! ") or
        "! "
        if c <= 0.3 then
            STRING_STATE = "START"
        else
            STRING_STATE = "MID"
        end
        return str
    end

    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str..string_start()..string_end()
        if i ~= length then
            str = str..string_space()
        end
    end

    local punc = {".", "?", "!"}

    str = str..punc[math.random(#punc)]

    return str
end

function GetSpecialCharacterString(character, stringtype, modifier)
    character = string.lower(character)
    if character == "wilton" then

		local sayings =
		{
			"Ehhhhhhhhhhhhhh.",
			"Eeeeeeeeeeeer.",
			"Rattle.",
			"click click click click",
			"Hissss!",
			"Aaaaaaaaa.",
			"mooooooooooooaaaaan.",
			"...",
		}

		return sayings[math.random(#sayings)]
    elseif character == "wes" then
		return ""
    elseif character == "wilbur" then
        return getcharacterstring(STRINGS.CHARACTERS.WILBUR.DESCRIBE, stringtype, modifier) or CraftMonkeyString()
    elseif character == "wilba" and GetPlayer().were then
        local growl_count = math.random(1, 4)
        local growl_str = ""

        for i=1,growl_count do
            growl_str = growl_str .. " " .. STRINGS.WEREWILBA_SPEECH[math.random(1, #STRINGS.WEREWILBA_SPEECH)]
        end

        return growl_str
    end
end

function GetString(character, stringtype, modifier)
    character = character and string.upper(character)
    stringtype = stringtype and string.upper(stringtype)

    if type(stringtype) == "table" then
        stringtype = stringtype[math.random(#stringtype)]
    end
    
    if type(modifier) == "table" then
        for i,v in ipairs(modifier) do
            v = v and string.upper(v)
        end
    else
        modifier = modifier and string.upper(modifier)
    end
    
    local ret = GetSpecialCharacterString(character, stringtype, modifier) or
			    getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier) or
                getcharacterstring(STRINGS.CHARACTERS["GENERIC"], stringtype, modifier)
    if ret then
        return ret
    end

    return "UNKNOWN STRING: "..( character or "") .." ".. (stringtype or "") .." ".. (modifier or "")

end

function GetActionString(action, modifier)
    return getcharacterstring(STRINGS.ACTIONS, action, modifier) or "ACTION"
end

function GetDescription(character, item, modifier)
    character = character and string.upper(character)

    local itemname = item.nameoverride or item.components.inspectable.nameoverride or item.prefab or nil

    itemname = itemname and string.upper(itemname)
    if type(modifier) == "table" then
        for i,v in ipairs(modifier) do
            v = v and string.upper(v)
        end
    else
        modifier = modifier and string.upper(modifier)
    end

    local ret = GetSpecialCharacterString(character, itemname, modifier)

    if not ret then
        if STRINGS.CHARACTERS[character] then
            ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, itemname, modifier)
        end

        if not ret and STRINGS.CHARACTERS.GENERIC then
            ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, itemname, modifier)
        end

        if not ret then
            ret = STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
        end
    end

    if ret and item and item.components.repairable and item.components.repairable:NeedsRepairs() and item.components.repairable.announcecanfix and 
        character ~= "WILBUR" and character ~= "WES" then

        local repair = nil
        if STRINGS.CHARACTERS[character] and STRINGS.CHARACTERS[character].DESCRIBE then
            repair = getcharacterstring(STRINGS.CHARACTERS[character], "ANNOUNCE_CANFIX", modifier)
        end
    
        if not repair and STRINGS.CHARACTERS.GENERIC then
            repair = getcharacterstring(STRINGS.CHARACTERS.GENERIC, "ANNOUNCE_CANFIX", modifier)
        end

        if repair then 
            ret = ret..repair
        end
    end  

    return ret 
end

function GetActionFailString(inst, action, reason)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    character = character and string.upper(character)
    local ret = nil

	local ret = GetSpecialCharacterString(character)
	if ret then
		return ret
	end

    if STRINGS.CHARACTERS[character] then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason)
    end

    if not ret then
        ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason)
    end

    if ret then
       return ret
    end
    return STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end


function FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

function TrimString( s )
   return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
end

-- usage:
-- subfmt("this is my {adjective} string, read it {number} times!", {adjective="cool", number="five"})
-- => "this is my cool string, read it five times"
function subfmt(s, tab)
    return (s:gsub('(%b{})', function(w) return tab[w:sub(2, -2)] or w end))
end

function printf(...)
	print(string.format(...))
end
function string:endsWith(ends)
	local tail = self:sub(-#ends)
	return tail == ends
end

-- return the leftmost x characters of a string
-- if x is negative it returns string minus x rightmost characters
function string:left(len)
	if len >= 0 then
		return self:sub(1,len)
	else
		local len = #self + len
		if len < 0 then 
			len = 0
		end
		return self:sub(1,len)
	end
end

