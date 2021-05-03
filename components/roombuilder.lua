local RoomBuilder = Class(function(self, inst)
    self.inst = inst
end)

function RoomBuilder:CollectUseActions(doer, target, actions)
    if target:HasTag("predoor") then
        table.insert(actions, ACTIONS.BUILD_ROOM)
    end
end


return RoomBuilder
