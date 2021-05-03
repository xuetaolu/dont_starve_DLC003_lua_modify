local assets =
{
	Asset("SOUNDPACKAGE", "sound/dontstarve_DLC002.fev"),
	Asset("SOUNDPACKAGE", "sound/dontstarve_DLC001.fev"),
}


local function fn(Sim)
    return nil
end

return Prefab( "common/DLC0002", fn, assets ) 
