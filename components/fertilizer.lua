local Fertilizer = Class(function(self, inst)
    self.inst = inst
    self.fertilizervalue = 1
    self.soil_cycles = 1
    self.withered_cycles = 1
    self.volcanic = nil
end)

function Fertilizer:CollectUseActions(doer, target, actions)
    --print("doer",doer.prefab)
    --print("target",target.prefab)
    if not self.volcanic and not self.oceanic then
        if target.components.crop and not target.components.crop:IsReadyForHarvest() then
            table.insert(actions, ACTIONS.FERTILIZE)
        elseif target.components.grower and target.components.grower:IsEmpty() and not target.components.grower:IsFullFertile() then
            table.insert(actions, ACTIONS.FERTILIZE)
        elseif target.components.pickable and not target.components.pickable.reverseseasons and target.components.pickable:CanBeFertilized() then
            table.insert(actions, ACTIONS.FERTILIZE)
        elseif target.components.hackable and target.components.hackable:CanBeFertilized() then
            table.insert(actions, ACTIONS.FERTILIZE)
        end
    elseif self.volcanic then
        if target.components.pickable and target.components.pickable.reverseseasons and target.components.pickable:CanBeFertilized() then
            table.insert(actions, ACTIONS.FERTILIZE)
        end
    elseif self.oceanic then
        if target.components.pickable and target.components.pickable.oceanic and target.components.pickable:CanBeFertilized() then
            table.insert(actions, ACTIONS.FERTILIZE)
        end
    end
end

function Fertilizer:CollectInventoryActions(doer, actions)
    --print("TESTING")
    if doer:HasTag("healonfertilize") and self.planthealing then
        table.insert(actions, ACTIONS.FERTILIZE)
    end
end

return Fertilizer
