
local Weapon = Class(function(self, inst)
    self.inst = inst
    self.damage = 10
    self.attackrange = nil
    self.hitrange = nil
    self.onattack = nil
    self.onprojectilelaunch = nil
    self.canattack = nil
    self.projectile = nil
    self.stimuli = nil
    self.projectilelaunchsymbol = nil 
    self.heightoffset = nil
    self.getdamagefn = nil 
    --Monkey uses these
    self.modes = 
    {
        MODE1 = {damage = 0, ranged = false, attackrange = 0, hitrange = 0},
        --etc.
    }
    self.variedmodefn = nil
end)

function Weapon:SetDamage(dmg)
    self.damage = dmg
end

function Weapon:GetDamage()
    if self.getdamagefn then 
        return self.getdamagefn(self.inst)
    end 

    return self.damage
end 

function Weapon:SetRange(attack, hit)
    self.attackrange = attack
    self.hitrange = hit or self.attackrange
end

function Weapon:SetOnAttack(fn)
    self.onattack = fn
end

function Weapon:SetOnProjectileLaunch(fn)
    self.onprojectilelaunch = fn
end

function Weapon:SetCanAttack(fn)
    self.canattack = fn
end

function Weapon:SetProjectile(projectile)
    self.projectile = projectile
end

function Weapon:SetElectric()
    self.stimuli = "electric"
end

function Weapon:SetPoisonous()
    self.stimuli = "poisonous"
end

function Weapon:CanRangedAttack()
    if self.variedmodefn then
        local mode = self.variedmodefn(self.inst)
        if not mode.ranged then
            --determined to use melee mode, return false.
            return false
        end
    end

    return self.projectile ~= nil
end

-- This does exactly the same thing as the SetOnAttack up there...
function Weapon:SetAttackCallback(fn)
    self.onattack = fn
end

function Weapon:OnAttack(attacker, target, projectile)
    if self.onattack then
        self.onattack(self.inst, attacker, target, projectile)
    end
    
    if self.inst.components.finiteuses and not target:HasTag("no_durability_loss_on_hit") then
        self.inst.components.finiteuses:Use(self.attackwear or 1)
    end

    if self.inst.components.obsidiantool then
        self.inst.components.obsidiantool:Use(attacker, target)
    end
end

function Weapon:LaunchProjectile(attacker, target)
    if self.projectile then
        local proj = SpawnPrefab(self.projectile)

        if proj then
            if self.onprojectilelaunch then
                self.onprojectilelaunch(self.inst, attacker, target, proj)
            end

            if proj.components.projectile then
                local owner = nil 
                if self.inst.components.inventoryitem then 
                    owner = self.inst.components.inventoryitem.owner --Could be the player or a weapon that is equipped by another weapon (i.e. boat cannon)
                    if owner and owner.components.inventoryitem and owner.components.inventoryitem.owner then 
                            owner = owner.components.inventoryitem.owner
                    end  
                    if owner and owner.components.drivable and owner.components.drivable.driver then 
                            owner = owner.components.drivable.driver
                    end 
                end

                if self.projectilelaunchsymbol and owner and owner.AnimState then 
                    proj.Transform:SetPosition(owner.AnimState:GetSymbolPosition(self.projectilelaunchsymbol, 0, 0, 0))
                else
                    local x, y, z = attacker.Transform:GetWorldPosition()
                    proj.Transform:SetPosition(x, y+(self.heightoffset or 0), z)
                end 
                proj.components.projectile:Throw(self.inst, target, attacker)
            end
            if proj.components.complexprojectile then 
                proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
                proj.components.complexprojectile:Launch(target:GetPosition(), attacker, self.inst)                
            end
        end
    end
end

function Weapon:CollectUseActions(doer, target, actions)
    if self.inst.components.inventoryitem and target.components.container and target.components.container.canbeopened then
        -- put weapons into chester, don't attack him unless forcing attack with key press
		table.insert(actions, target:HasTag("bundle") and ACTIONS.BUNDLESTORE or ACTIONS.STORE)
    else
        if doer.components.combat and doer.components.combat:CanTarget(target) 
            and target.components.combat:CanBeAttacked(doer)
            and (not self.canattack or self.canattack(self.inst, target) ) then
             
            local should_light = target.components.burnable and self.inst.components.lighter 
            if not should_light then
                table.insert(actions, ACTIONS.ATTACK)
            end
        end
    end
end


function Weapon:CollectEquippedActions(doer, target, actions, right)
    
    -- This is here to prevent players from accidentally attacking pigs
    if right and not target:HasTag("civilized") then
        return
    elseif not right and target:HasTag("civilized") then
        return
    end

    if doer.components.combat 
        and not target:HasTag("wall")
        and doer.components.combat:CanTarget(target)
        and target.components.combat:CanBeAttacked(doer)
        and not doer.components.combat:IsAlly(target)
        and (not self.canattack or self.canattack(self.inst, target) ) 
        and target:HasTag("mole")
        and self.inst:HasTag("hammer") then
            table.insert(actions, ACTIONS.WHACK)
    
    elseif doer.components.combat
        and self.inst:HasTag("extinguisher")
        and target.components.burnable
        and (target.components.burnable:IsSmoldering() or target.components.burnable:IsBurning()) then
            table.insert(actions, ACTIONS.RANGEDSMOTHER)
    
    elseif doer.components.combat
        and self.inst:HasTag("rangedlighter")
        and target.components.burnable
        and target.components.burnable.canlight
        and not target.components.burnable:IsBurning() 
        and not target:HasTag("burnt") then
            table.insert(actions, ACTIONS.RANGEDLIGHT)
    
    elseif doer.components.combat 
        and not target:HasTag("wall")
        and doer.components.combat:CanTarget(target)
        and target.components.combat:CanBeAttacked(doer)
        and not doer.components.combat:IsAlly(target)
        and (not self.canattack or self.canattack(self.inst, target) ) then
            table.insert(actions, ACTIONS.ATTACK)
    end
end

return Weapon