local assets=
{
	Asset("ANIM", "anim/porkalypse_clock_01.zip"),
	Asset("ANIM", "anim/porkalypse_clock_02.zip"),
	Asset("ANIM", "anim/porkalypse_clock_03.zip"),
	Asset("ANIM", "anim/porkalypse_clock_marker.zip"),
	Asset("ANIM", "anim/porkalypse_totem.zip"),

	Asset("ANIM", "anim/pressure_plate.zip"),
	Asset("ANIM", "anim/pressure_plate_backwards_build.zip"),
	Asset("ANIM", "anim/pressure_plate_forwards_build.zip"),

	Asset("MINIMAP_IMAGE", "porkalypse_clock"), 
}

local clock_prefabs = 
{
	"aporkalypse_clock1",
	"aporkalypse_clock2",
	"aporkalypse_clock3",
}

local plate_prefabs = 
{
	["aporkalypse_rewind_plate"] = {x = 6, z = 6},
	["aporkalypse_fastforward_plate"] = {x = 6, z = -6},
}

local function set_rotation( inst, angle )
	inst.Transform:SetRotation(angle + 90)
end

local function common_clock_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )

	inst:AddTag("OnFloor")

	return inst
end

local function make_clock_fn(bank, build, sort_order, mult, speed)
	local function fn()
		local inst = common_clock_fn()

		inst.AnimState:SetSortOrder( 3 )
		inst.AnimState:SetFinalOffset( sort_order )
	    inst.AnimState:SetBank(bank)
	    inst.AnimState:SetBuild(build)
	    inst.AnimState:PlayAnimation("off_idle")
	    
	    inst:AddComponent("inspectable")
	    inst.components.inspectable.nameoverride = "aporkalypse_clock"
	    inst.name = STRINGS.NAMES.APORKALYPSE_CLOCK

	    return inst
	end
	
	return fn
end

local function FixAngle( target_angle)
    while target_angle > 360 do
        target_angle = target_angle % 360
    end

    while target_angle < 0 do
        target_angle = target_angle + 360
    end
    
    return target_angle
end

local function SpawnChildren(inst)
	-- if the clock is in limbo, so should its parts
	local inLimbo = inst:HasTag("INTERIOR_LIMBO")

	local marker = inst:SpawnChild("aporkalypse_marker")
	marker.Transform:SetRotation(90)
	if inLimbo then
		marker:AddTag("INTERIOR_LIMBO")
	end


	for i,v in ipairs(clock_prefabs) do
		local clock = inst:SpawnChild(v)
		if inLimbo then
			clock:AddTag("INTERIOR_LIMBO")
		end
		clock.OnRemoveEntity = function(self)
			print("A clock was removed!")
			for i,v in ipairs(inst.clocks) do
				if v == self then
					print("removing it from our clocks!")
					table.remove(inst.clocks,i)
					return
				end
			end
		end
		table.insert(inst.clocks, clock)
		clock.Transform:SetRotation(90)
	end

	for k,v in pairs(plate_prefabs) do
		local plate = inst:SpawnChild(k)
		
		plate.Transform:SetPosition(v.x,0,v.z)
		if inLimbo then
			plate:AddTag("INTERIOR_LIMBO")
		end

		plate.aporkalypse_clock = inst
		table.insert(inst.plates, plate)
	end
end

local function CleanupAllOrphans(inst)
	local names = {}
	names["aporkalypse_marker"] = true
	for i,v in ipairs(clock_prefabs) do
		names[v] = true
	end
	for k,v in pairs(plate_prefabs) do
		names[k] = true
	end
	local toRemove = {}
	for i,v in pairs(Ents) do
		local prefab = v.prefab
		if names[prefab] then
			table.insert(toRemove,v)
		end
	end
	local interiorSpawner = GetInteriorSpawner()
	for i,v in pairs(toRemove) do
		v:Remove()
	end
end

local function ReturnToInteriorScene(inst)
	for i,v in pairs(inst.children) do
		i:RemoveTag("INTERIOR_LIMBO")
	end
end
								
local function RemoveFromInteriorScene(inst)
	-- put all my children in interior limbo
	for i,v in pairs(inst.children) do
		i:AddTag("INTERIOR_LIMBO")
	end
end

local function make_master_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()        
    minimap:SetIcon("porkalypse_clock.png")

	local anim = inst.entity:AddAnimState()

	anim:SetBank("totem")
	anim:SetBuild("porkalypse_totem")
	anim:PlayAnimation("idle_loop", true)

	inst.plates = {}
	inst.clocks = {}
	
	local function playclockanimation(anim)
		for i,v in ipairs(inst.clocks) do
	   		v.AnimState:PlayAnimation(anim .. "_shake", false)
	   		v.AnimState:PushAnimation(anim .. "_idle")
	   	end
	end

	inst:DoTaskInTime(0, function()
		CleanupAllOrphans(inst)
		SpawnChildren(inst)

		local aporkalypse = GetAporkalypse()
		if aporkalypse and aporkalypse:IsActive() then
		   	inst.AnimState:PlayAnimation("idle_on")
			playclockanimation("on")
		end

	end)

	-- total rotations for each disc in a full aporkalypse cycle
	inst.rotation_speeds = { 1, 60, 2 }

	inst.StartRewind = function()
		if inst.rewind then
			return
		end

		inst.SoundEmitter:KillSound("base_sound")
		if inst.rewind_mult < 0 then
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/base_backwards_LP", "rewind_sound")
		else
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/base_fast_LP", "rewind_sound")
		end

		inst.rewind = true
	end

	inst.StopRewind = function ( )
		if not inst.rewind then
			return
		end
		inst.SoundEmitter:KillSound("rewind_sound")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/base_LP", "base_sound")

		inst.rewind = false
	end

	inst:DoTaskInTime(0.02, function() 
		inst:ListenForEvent( "clocktick", function(world, data)
			local total_time = GetClock():GetTotalTime()
			local aporkalypse = GetAporkalypse()

			local time_left_till_aporkalypse = aporkalypse and math.max(aporkalypse:GetBeginDate() - GetClock():GetTotalTime(), 0) or 0
			--print("time_left:",time_left_till_aporkalypse	)

			if inst.rewind then

				if aporkalypse then
					if aporkalypse:IsActive() then
						aporkalypse:EndAporkalypse()
					end
					time_left_till_aporkalypse = aporkalypse and math.max(aporkalypse:GetBeginDate() - GetClock():GetTotalTime(), 0) or 0
					-- I'd like to use dt but update for season-switch can mess with it bigtime
					local dt = math.clamp(data.dt, 0, 2 * TheSim:GetTickTime())
					time_left_till_aporkalypse = time_left_till_aporkalypse - inst.rewind_mult * dt * 250
					aporkalypse:ScheduleAporkalypse(GetClock():GetTotalTime() + time_left_till_aporkalypse)
				end

			end

			for i,v in ipairs(inst.clocks) do
				local angle = time_left_till_aporkalypse / (60 * TUNING.TOTAL_DAY_TIME) * 360 * inst.rotation_speeds[i]
				set_rotation(v, angle)
			end

		end, GetWorld())
	end)

	inst:ListenForEvent("beginaporkalypse", function()
		playclockanimation("on")
		
		inst.SoundEmitter:KillSound("totem_sound")
		inst.SoundEmitter:KillSound("base_sound")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/stone_door/close")
		TheCamera:Shake("FULL", 0.7, 0.02, .5, 40)

		inst.AnimState:PushAnimation("idle_pst", false)
	   	inst.AnimState:PushAnimation("idle_on")
	end, GetWorld())

	inst:ListenForEvent("endaporkalypse", function ()
		playclockanimation("off")

		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/totem_LP", "totem_sound")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/base_LP", "base_sound")

		inst.AnimState:PushAnimation("idle_pre", false)
	   	inst.AnimState:PushAnimation("idle_loop")
	end, GetWorld())

    inst.returntointeriorscene = ReturnToInteriorScene
    inst.removefrominteriorscene = RemoveFromInteriorScene

    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/totem_LP", "totem_sound")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/aporkalypse_clock/base_LP", "base_sound")

	return inst
end


local function on_pressure_plate_near(inst)
    if not inst:HasTag("INTERIOR_LIMBO") and not inst.down then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/pressure_plate/hit")
        inst.AnimState:PlayAnimation("popdown")
        inst.AnimState:PushAnimation("down_idle")
        inst.down = true
        inst.trigger(inst)
    end
end

local function on_pressure_plate_far(inst)
    if not inst:HasTag("INTERIOR_LIMBO") and inst.down then
        inst.AnimState:PlayAnimation("popup")
        inst.AnimState:PushAnimation("up_idle")
        inst.down = nil
        inst.untrigger(inst)
    end
end

local function make_common_plate()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    anim:SetBank("pressure_plate")
    anim:SetBuild("pressure_plate")
    anim:PlayAnimation("up_idle")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("structure")
    
    inst.weights = 0

    inst:AddTag("weighdownable")

-------------------------------------------------------------------------------
    inst:AddComponent("creatureprox")
    inst.components.creatureprox:SetOnPlayerNear(on_pressure_plate_near)
    inst.components.creatureprox:SetOnPlayerFar(on_pressure_plate_far)

    inst.components.creatureprox:SetTestfn(function(testing) return not testing:HasTag("flying") end)
    
    inst.components.creatureprox:SetDist(0.8, 0.9)
    inst.components.creatureprox.inventorytrigger = true

-------------------------------------------------------------------------------

    return inst
end


local function make_rewind_plate()
	local inst = make_common_plate()
	inst.AnimState:SetBuild("pressure_plate_forwards_build")

	inst.trigger = function() 
		if inst.aporkalypse_clock then
			inst.aporkalypse_clock.rewind_mult = -1
			inst.aporkalypse_clock:StartRewind()
		end

		local pt = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
        for i, ent in ipairs(ents) do
            if ent:HasTag("lockable_door") then
                ent:PushEvent("close")
            end
        end
	end
	inst.untrigger = function() 
		if inst.aporkalypse_clock then
			inst.aporkalypse_clock:StopRewind()
		end

		local pt = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
        for i, ent in ipairs(ents) do
            if ent:HasTag("lockable_door") then
                ent:PushEvent("open")
            end
        end
	end

	return inst
end

local function make_fastforward_plate()
	local inst = make_common_plate()
	inst.AnimState:SetBuild("pressure_plate_backwards_build")

	inst.trigger = function() 
		if inst.aporkalypse_clock then
			inst.aporkalypse_clock.rewind_mult = 1
			inst.aporkalypse_clock:StartRewind()
		end

		local pt = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
        for i, ent in ipairs(ents) do
            if ent:HasTag("lockable_door") then
                ent:PushEvent("close")
            end
        end
	end

	inst.untrigger = function() 
		if inst.aporkalypse_clock then
			inst.aporkalypse_clock:StopRewind()
		end

		local pt = Vector3(inst.Transform:GetWorldPosition())
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
        for i, ent in ipairs(ents) do
            if ent:HasTag("lockable_door") then
                ent:PushEvent("open")
            end
        end
	end

	return inst
end

local function make_marker()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBuild("porkalypse_clock_marker")
	anim:SetBank("clock_marker")
	anim:PlayAnimation("idle")

	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(0)
	return inst
end

local function MakeClock(clock_num, mult, speed)
	local name = "aporkalypse_clock" .. clock_num
	local bank = "clock_0".. clock_num
	local build = "porkalypse_clock_0" .. clock_num
	local sort_order = clock_num

	return Prefab( "common/objects/" .. name, make_clock_fn( bank, build, sort_order, mult, speed), assets)
end

return MakeClock( 1, 1, 1),
	   MakeClock( 2, -1, 3),
	   MakeClock( 3, 1, 0.5),
	   Prefab( "common/objects/aporkalypse_rewind_plate", make_rewind_plate, assets),
	   Prefab( "common/objects/aporkalypse_fastforward_plate", make_fastforward_plate, assets),
	   Prefab( "common/objects/aporkalypse_clock", make_master_fn, assets),
	   Prefab( "common/objects/aporkalypse_marker", make_marker, assets)