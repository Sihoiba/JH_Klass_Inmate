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

register_blueprint "perk_ta_capacitor"
{
    blueprint = "perk",
    lists = {
        group    = "perk_ca",
        keywords = { "armor", },
    },
    text = {
        name = "Capacitor matrix",
        desc = "receiving damage recharges class skill (up to 100%)",
    },
    attributes = {
        level = 2,
    },
    callbacks = {
        on_receive_damage = [[
            function ( self, entity, source, weapon, amount )
                nova.log("on_recieve_damage")
                if not entity then return end
                if not entity.data or not entity.data.is_player then return end
                if amount < 5 then return end
                nova.log("on_recieve_damage past guard")
                local restore = math.floor( amount * 0.2 )
                local klass = gtk.get_klass_id( entity )
                local resource

                if klass == "marine" then
                    nova.log("is marine")
                    resource = entity:child( "resource_fury" )
                elseif klass == "scout" then
                    resource = entity:child( "resource_energy" )
                elseif klass == "tech" then
                    resource = entity:child( "resource_power" )
                else
                    local klass_hash = entity.progression.klass
                    nova.log(klass_hash)
                    local klass_id   = world:resolve_hash( klass_hash )
                    nova.log(klass_id)
                    local k = blueprints[ klass_id ]
                    if not k or not k.klass or not k.klass.res then
                        return
                    end
                    resource = entity:child( k.klass.res )
                end

                if not resource then
                    return
                end

                local rattr = resource.attributes
                if rattr.value < rattr.max then
                    nova.log("restoring")
                    rattr.value = math.min( rattr.value + restore, rattr.max )
                end
            end
        ]],
    }
}