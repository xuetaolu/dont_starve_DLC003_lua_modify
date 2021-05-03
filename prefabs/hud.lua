local assets =
{
	 --In-game only
    Asset("ATLAS", "images/hud.xml"),
    Asset("IMAGE", "images/hud.tex"),

    Asset("ATLAS", "images/fx2.xml"),
    Asset("IMAGE", "images/fx2.tex"),    

    Asset("ATLAS", "images/fx3.xml"),
    Asset("IMAGE", "images/fx3.tex"), 

    Asset("ATLAS", "images/fx4.xml"),
    Asset("IMAGE", "images/fx4.tex"), 
    
    Asset("ATLAS", "images/fx5.xml"),
    Asset("IMAGE", "images/fx5.tex"), 

    Asset("ATLAS", "images/fx6.xml"),
    Asset("IMAGE", "images/fx6.tex"),     

    Asset("ATLAS", "images/fx.xml"),
    Asset("IMAGE", "images/fx.tex"),

    --Asset("ANIM", "anim/fog_over.zip"),
    
    Asset("ANIM", "anim/clock_transitions.zip"),
    Asset("ANIM", "anim/moon_phases_clock.zip"),
    Asset("ANIM", "anim/moon_aporkalypse_phases.zip"),
    Asset("ANIM", "anim/moon_phases.zip"),

    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ANIM", "anim/ui_thatchpack_1x4.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("ANIM", "anim/ui_bundle_2x2.zip"),
    Asset("ANIM", "anim/ui_piggyback_2x6.zip"),
    Asset("ANIM", "anim/ui_krampusbag_2x8.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"), 
    Asset("ANIM", "anim/ui_krampusbag_2x5.zip"),

    Asset("ANIM", "anim/health.zip"),
    Asset("ANIM", "anim/sanity.zip"),
    Asset("ANIM", "anim/sanity_arrow.zip"),
    Asset("ANIM", "anim/poison_meter_overlay.zip"),
    Asset("ANIM", "anim/effigy_topper.zip"),
    Asset("ANIM", "anim/hunger.zip"),
    Asset("ANIM", "anim/beaver_meter.zip"),
    Asset("ANIM", "anim/hunger_health_pulse.zip"),
    Asset("ANIM", "anim/spoiled_meter.zip"),
    Asset("ANIM", "anim/trawlnet_meter.zip"),
    Asset("ANIM", "anim/obsidian_tool_meter.zip"),

    Asset("ANIM", "anim/saving.zip"),
    Asset("ANIM", "anim/vig.zip"),
    Asset("ANIM", "anim/fire_over.zip"),
    Asset("ANIM", "anim/clouds_ol.zip"),   
    
    Asset("ANIM", "anim/leaves_canopy.zip"),
    Asset("ANIM", "anim/leaves_canopy2.zip"),    

    Asset("ANIM", "anim/progressbar.zip"),   
    Asset("ANIM", "anim/wind_fx.zip"),
    
    --Asset("ATLAS", "images/hud_shipwrecked.xml"),
    --Asset("IMAGE", "images/hud_shipwrecked.tex"),
    
    Asset("ATLAS", "images/hud_porkland.xml"),
    Asset("IMAGE", "images/hud_porkland.tex"),

    Asset("ATLAS", "images/inventoryimages.xml"),
    Asset("IMAGE", "images/inventoryimages.tex"),    
    Asset("ATLAS", "images/inventoryimages_2.xml"),
    Asset("IMAGE", "images/inventoryimages_2.tex"),    
    
    Asset("ANIM", "anim/wet_meter_player.zip"), 
    Asset("ANIM", "anim/wet_meter_drop.zip"),
    Asset("ANIM", "anim/wet_meter.zip"),
    Asset("ANIM", "anim/boat_health.zip"),

    Asset("ANIM", "anim/livingartifact_meter.zip"),
}


local prefabs = {
	"minimap",
    "gridplacer",

}

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn(Sim)
    return CreateEntity()
end

return Prefab( "UI/interface/hud", fn, assets, prefabs, true )
