local Fertalizable = Class(function(self, inst)
    self.inst = inst
end)

function Fertalizable:CollectSceneActions(doer, actions)
    if self.inst:HasTag("healonfertalize") then
        table.insert(actions, ACTIONS.FERTILIZE)
    end
end

return Fertalizable