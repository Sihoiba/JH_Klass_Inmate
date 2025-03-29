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
        desc = "Increases berserk duration by 10 turns",
    },
    attributes = {
        berserk_duration_bonus = 1000,
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

register_blueprint "buff_kneecapped"
{
    flags = { EF_NOPICKUP },
    text = {
        name  = "Kneecapped",
        desc  = "reduces enemy move speed by 25%",
    },
    ui_buff = {
        color     = LIGHTRED,
    },
    attributes = {
        move_time   = 1.5,
    },
}

register_blueprint "perk_wb_kneecap"
{
    flags = { EF_NOPICKUP },
    callbacks = {
        on_damage = [=[
            function ( unused, weapon, who, amount, source )
                if who and who.data and ( not who.data.is_mechanical ) and who.data.can_bleed then
                    world:add_buff( who, "buff_kneecapped", 150, true )
                end
            end
        ]=],
    },
}

register_blueprint "buff_panicked"
{
    flags = { EF_NOPICKUP },
    text = {
        name  = "Panicked",
        desc  = "reduces enemy accuracy by 25%",
    },
    ui_buff = {
        color     = LIGHTRED,
    },
    attributes = {
        accuracy = -25,
    },
}

register_blueprint "perk_we_panic"
{
    flags = { EF_NOPICKUP },
    callbacks = {
        on_damage = [=[
            function ( unused, weapon, who, amount, source )
                if who and who.data and ( not who.data.is_mechanical ) and who.data.can_bleed then
                    world:add_buff( who, "buff_panicked", 150, true )
                end
            end
        ]=],
    },
}

register_blueprint "buff_stunned"
{
    flags = { EF_NOPICKUP },
    text = {
        name  = "Stunned",
        desc  = "damage dealt by this entity is reduced by 25%",
    },
    ui_buff = {
        color     = LIGHTRED,
    },
    attributes = {
        damage_mult = 0.75,
    },
}

register_blueprint "perk_we_stun"
{
    flags = { EF_NOPICKUP },
    callbacks = {
        on_damage = [=[
            function ( unused, weapon, who, amount, source )
                if who and who.data and ( not who.data.is_mechanical ) and who.data.can_bleed then
                    world:add_buff( who, "buff_stunned", 150, true )
                end
            end
        ]=],
    },
}