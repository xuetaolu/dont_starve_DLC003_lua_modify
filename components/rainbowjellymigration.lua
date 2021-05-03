-- manages the migration event of the rainbowjellyfish


RainbowJellyfishMigrationManager = Class(function(self, inst)
    self.inst = inst
    -- number of jellyfish to be placed for effect during the migration
    self.isMigrationActive = false
    self.inst:ListenForEvent( "daycomplete", function(inst, data) self:OnDayComplete() end )
end)

function RainbowJellyfishMigrationManager:IsMigrationActive()
    -- if this becomes functional, then no need to save/load
    return self.isMigrationActive
end

function RainbowJellyfishMigrationManager:OnDayComplete()
    -- migration happens during a new moon, but during the very first one..
    local clock = GetClock()

    if clock:GetNumCycles() > 3 and clock:GetMoonPhase() == "new" then
        self:StartMigration()
    else
        self:EndMigration()
    end
end

function RainbowJellyfishMigrationManager:OnSave()
    return { isMigrationActive = self.isMigrationActive }
end

function RainbowJellyfishMigrationManager:OnLoad(data)
    self.isMigrationActive = data.isMigrationActive or self.isMigrationActive
end


local function setupHomeAndMigrationDestination(jelly, migrationPos, teleport)
    -- make sure they remember their actual home
    local home = jelly.components.knownlocations:GetLocation("home")
    if home == nil then
        -- find out why it didnt know its home yet..
        jelly.components.knownlocations:RememberLocation("home", Vector3(jelly.Transform:GetWorldPosition()))
    end

    local offset = FindWaterOffset(migrationPos, math.random() * 2 * PI, math.random(2,25), 4)

    -- tell them about their new destination
    local jellyHome = Vector3(migrationPos.x + offset.x, migrationPos.y + offset.y, migrationPos.z + offset.z)
    jelly.components.knownlocations:RememberLocation("migration", jellyHome)

    if teleport then
        jelly.Transform:SetPosition(jellyHome.x, jellyHome.y, jellyHome.z)
    end
end

function RainbowJellyfishMigrationManager:StartMigration()
    if self.isMigrationActive == true then
        return
    end

    local theVolcano = TheSim:FindFirstEntityWithTag("theVolcano")

    if theVolcano then
        print("starting rainbow jellyfish migration..")
        self.isMigrationActive = true
        local volcanoPos = Vector3(theVolcano.Transform:GetWorldPosition())

        -- migration home is towards the center of the map
        local dir = Vector3(0,0,0) - volcanoPos;
        dir:Normalize()
        local migrationHomePos = volcanoPos + (dir * 30.0);
        local jellies = TheSim:FindEntities(migrationHomePos.x, migrationHomePos.y, migrationHomePos.z, 9999, {"rainbowjellyfish"})

        local numJelliesToRelocate = math.floor(#jellies * 1.0)
        local numJelliesAtVolcano = math.floor(numJelliesToRelocate * 0.1)

        print("Migrating " .. tostring(numJelliesToRelocate) .. " rainbowjellyfish")


        local streetDestination = volcanoPos + (dir * 30.0)
        local mainAngle = -math.atan2(dir.z, dir.x)
        local streetAngles = { mainAngle - PI * 0.25, mainAngle, mainAngle + PI * 0.25 }

        local numJelliesPerStreet = math.floor((numJelliesToRelocate - numJelliesAtVolcano) / #streetAngles)

        -- setup crowd at volcano
        -- recalc at volcano so all jellies are used
        numJelliesAtVolcano = numJelliesToRelocate - (numJelliesPerStreet * #streetAngles)
        for i=1, numJelliesAtVolcano, 1 do
            setupHomeAndMigrationDestination(jellies[i], migrationHomePos, true)
        end


        -- setup the streets
        local i = numJelliesAtVolcano + 1

        for s=1, #streetAngles, 1 do
            local p = streetDestination
            local angle = streetAngles[s]

            for j=1, numJelliesPerStreet, 1 do   
                setupHomeAndMigrationDestination(jellies[i], migrationHomePos, false)

                -- hop through the water in increments to build a path towards the middle
                local angleVariation = math.random(-1, 1) * PI * 0.25
                local offset = FindWaterOffset(p, angle + angleVariation, 7 + (j * 0.2), 4)
                if offset == nil then
                    print("Unable to build full jelly fish straight.. aborting")
                    break
                end

                -- place a jellyfish
                local jellyPos = p + offset
                jellies[i].Transform:SetPosition(jellyPos.x, jellyPos.y, jellyPos.z)

                -- continue on straight
                p = p + offset

                i = i + 1
            end

        end
    else
        print("THERE IS NO VOLCANO. IGNORE THE MIGRATION")
    end

end

function RainbowJellyfishMigrationManager:EndMigration()

    if self.isMigrationActive == false then
        return
    end

    print("ending rainbow jellyfish migration..")
    self.isMigrationActive = false

    -- this part isn't needed, just let the jellies go back to their homes normally. 
    --[[
    local theVolcano = TheSim:FindFirstEntityWithTag("theVolcano")
    local volcanoPos = Vector3(theVolcano.Transform:GetWorldPosition())

    -- return all jellyfish to their spawn location
    local jellies = TheSim:FindEntities(volcanoPos.x, volcanoPos.y, volcanoPos.z, 9999, {"rainbowjellyfish"})
    local numJellyfish = #jellies

    for i=1, numJellyfish, 1 do
        local home = jellies[i].components.knownlocations:GetLocation("home")
        if home then
    		jellies[i].Transform:SetPosition(home.x, home.y, home.z)
    	else
    		print("!!ERROR: Could Not Find Jellyfish Home")
    	end
    end
    ]]
end

return RainbowJellyfishMigrationManager
