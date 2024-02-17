nova.require "data/lua/core/common"

register_blueprint "exo_axe"
{
    blueprint = "base_melee",
    text = {
        name = "axe",
        desc = "Pretty sure it's not used to chop down trees.",
    },
    lists = {
        group    = "item",
        keywords = { "general", "melee", "special", "exotic" },
        weight   = 10,
        dmin     = 12,
        dmed     = 19,
    },
    ascii     = {
        glyph     = "/",
        color     = MAGENTA,
    },
    attributes = {
        damage = 70,
        swap_time    = 0.5,
        crit_damage  = 50,
        mod_capacity = 1,
        gib_factor   = 2,
    },
    ui_target = {
        type = "melee",
    },
    weapon = {
        group = "melee",
        type  = "melee",
        damage_type = "slash",
        fire_sound = "axe_swing",
        hit_sound  = "blunt",
    },
}

register_blueprint "perk_we_axe_inmate"
{
    flags = { EF_NOPICKUP },
    text = {
        name = "Vicious Swing",
        desc = "+10% attack speed when under the effect of Berserk",
    },
    attributes = {
        level    = 3,
        speed = 1.0,
    },
    callbacks = {
        on_aim = [=[
            function ( self, entity, target, weapon )
                local speed = 1.0
                local berserk = entity:child("buff_inmate_berserk_base") or
                entity:child("buff_inmate_berserk_skill_1") or
                entity:child("buff_inmate_berserk_skill_2") or
                entity:child("buff_inmate_berserk_skill_3")
                if berserk then
                    speed = 1.1
                end
                entity.attributes.speed = speed
            end
        ]=],
    },
}

register_blueprint "exo_kaxe_inmate"
{
    blueprint = "exo_axe",
    text = {
        name = "prison axe",
        desc = "An axe made by an enterprising inmate from a bed post and a lunch tray, surprisingly light and vicious.",
    },
    lists = {
        group    = "item",
        keywords = { "inmate", "weapon", "special", "melee", "exotic", },
        weight   = 10,
        dmin     = 8,
        dmed     = 15,
        dmax     = 18,
    },
    data = {
        perk = {
            type          = "perk_w",
            subtype       = "melee",
            damage_low    = 10,
            damage_high   = 20,
            damage_status = 10,
            exotic        = "perk_we_axe_inmate",
        },
    },
    callbacks = {
        on_create = [=[
        function(self,_,tier)
            generator.roll_perks( self, tier )
        end
        ]=],
    },
}

register_blueprint "perk_he_berserk_boost"
{
    blueprint = "perk",
    text = {
        name = "Berserk Boost",
        desc = "using Booost clears all negative effects",
    },
    attributes = {
        level = 3,
    },
    callbacks = {
        on_inmate_berserk = [[
            function ( self, entity )
                world:destroy( entity:child("bleed") )
                world:destroy( entity:child("poisoned") )
                world:destroy( entity:child("acided") )
                world:destroy( entity:child("burning") )
                world:destroy( entity:child("freeze") )
            end
        ]],
    },
}

register_blueprint "exo_helmet_inmate"
{
    lists = {
        group    = "item",
        keywords = { "inmate", "exotic", "head", "special", },
        weight   = 3,
        dmin     = 5,
        dmed     = 10,
    },
    flags = { EF_ITEM },
    slot = "head",
    text = {
        name = "improvised helmet",
        desc = "An inmate managed to build a helmet out of medical terminal spares.",
    },
    ascii     = {
        glyph     = "[",
        color     = MAGENTA,
    },
    attributes = {
        mod_capacity = 1,
        armor = {
            3,
        },
        crit_defence = 100,
        health = 1000,
    },
    armor = {
        permanent = true,
    },
    health = {},
    data = {
        perk = {
            type     = "perk_c",
            subtype  = "helmet",
            exotic   = "perk_he_berserk_boost",
        },
    },
    callbacks = {
        on_create = [=[
            function(self,_,tier)
                generator.roll_perks( self, tier )
            end
        ]=],
    },
}

register_blueprint "perk_ae_grace_period"
{
    blueprint = "perk",
    text = {
        name = "Grace Period",
        desc = "After Berserk ends gain a short lived damage resistance",
    },
    attributes = {
        level = 3,
    },
    callbacks = {
        on_inmate_berserk = [[
            function ( self, entity )
                entity.attributes.grace_period = true
            end
        ]],
    },
}

register_blueprint "exo_armor_inmate"
{
    blueprint = "exo_armor_klass_base",
    lists = {
        group    = "item",
        keywords = { "inmate", "armor", "special", "exotic" },
        weight   = 7,
        dmin     = 7,
        dmed     = 14,
    },
    text = {
        name = "inmate armor",
        desc = "An inmate has wedged armour plates into a prison jumpsuit; surprisingly effective.",
    },
    attributes = {
        dodge_max   = -20,
        dodge_value = -20,
        armor = {
            4,
            slash  = 6,
            pierce = -2,
            plasma = -2,
        },
    },
    data = {
        perk = {
            type    = "perk_c",
            subtype = "armor",
            exotic  = "perk_ae_grace_period"
        },
    },
    callbacks = {
        on_create = [=[
            function(self,_,tier)
                generator.roll_perks( self, tier )
            end
        ]=],
    },
}