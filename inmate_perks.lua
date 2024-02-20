nova.require "data/lua/core/common"

register_blueprint "perk_ca_runaway_train"
{
    blueprint = "perk",
    lists = {
        group    = "perk_ca",
        keywords = { "inmate", "amp", "armor", },
    },
    text = {
        name = "Runaway Train",
        desc = "increases berserk action speed",
    },
    attributes = {
        level = 2,
        berserk_action_bonus = 1,
    },
}

register_blueprint "perk_cb_tantrum"
{
    blueprint = "perk",
    lists = {
        group    = "perk_cb",
        keywords = { "inmate", "amp", "armor", },
    },
    text = {
        name = "Tantrum",
        desc = "Doubles berserk duration",
    },
    attributes = {
        berserk_duration_bonus = 1,
    },
}

register_blueprint "perk_cb_short_tempered"
{
    blueprint = "perk",
    lists = {
        group    = "perk_cb",
        keywords = { "inmate", "amp", "armor", },
    },
    text = {
        name = "Short Tempered",
        desc = "Increased rage gain on recieving damage",
    },
    attributes = {
        rage_bonus = 5,
    },
}

register_blueprint "perk_cb_healing_rage"
{
    blueprint = "perk",
    lists = {
        group    = "perk_cb",
        keywords = { "inmate", "amp", "armor", },
    },
    text = {
        name = "Healing Rage",
        desc = "Activating Berserk heals by 20%",
    },
    callbacks = {
        on_inmate_berserk = [[
            function ( self, entity )
                local attr  = entity.attributes
                local hp    = entity.health.current
                if hp < attr.health then
                    entity.health.current = hp + (attr.health * 0.2)
                end
            end
        ]],
    },
}