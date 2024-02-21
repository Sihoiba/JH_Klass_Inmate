nova.require "data/lua/gfx/common"
nova.require "data/lua/jh/gfx/entities/human"
nova.require "data/lua/jh/gfx/entities/security"

register_gfx_blueprint "player_inmate_head_part"
{
    skeleton = "data/model/player_male_mesh.nmd",
    {
        tag = "head",
        render = {
            mesh     = "data/model/player_male_mesh.nmd:player_head_01",
            material = "data/texture/player/male/body_01/A/player_head_01",
        },
    },
    {
        tag = "head",
        attach = "RigHead",
        render = {
            mesh = "data/model/security_mesh.nmd:security_hair_01",
            material = "data/texture/security/A/security_hair_A",
        },
    },
}

register_gfx_blueprint "player_inmate"
{
    blueprint = "player",
    slot_base = {
        { target    = "armor", blueprint = "armor_shirt_01_A_part", },
        { target    = "head",  blueprint = "player_marine_head_part", },
    },
    {
        tag = "head",
        render = {
            mesh     = "data/model/player_male_mesh.nmd:player_head_01",
            material = "data/texture/player/male/body_01/A/player_head_01",
        },
    },
    {
        render = {
            mesh = "data/model/player_male_mesh.nmd:shoes_01",
            material = "data/texture/player/male/shoes_01/A/shoes_01_A",
        },
    },
    {
        tag    = "armor",
        render = {
            mesh = "data/model/player_male_mesh.nmd:player_trousers_01",
            material = "data/texture/player/male/trousers_01/B/trousers_01_B",
        },
    },
    {
        tag = "head",
        attach = "RigHead",
        render = {
            mesh = "data/model/security_mesh.nmd:security_hair_01",
            material = "data/texture/security/A/security_hair_A",
        },
    },
    {
        tag    = "armor",
        render = {
            mesh     = "data/model/player_male_mesh.nmd:player_body",
            material = "data/texture/security/suicider/security_suicider_body_01_A",
        },
    },
}

register_gfx_blueprint "exo_kaxe_inmate"
{
    uisprite = {
        icon = "data/texture/ui/icons/ui_weapon_axe_medium",
        color = vec4( 0.6, 0.0, 0.6, 1.0 ),
    },
    weapon_fx = {
        advance   = 0.5,
    },
    equip = {
        animation  = "to_machete",
        target     = "RigRHandWeaponMount",
        alt_target = "RigLHandWeaponMount",
    },
    vision = {
        pure_floor = true,
    },
    scene = {},
    {
        render = {
            mesh     = "data/model/axe_medium.nmd:axe_medium_01",
            material = "data/texture/weapons/melee/axe_medium_01/A/axe_medium_01",
        },
    },
}

register_gfx_blueprint "exo_armor_inmate"
{
    blueprint = "exo_armor_blue_base",
}

register_gfx_blueprint "exo_helmet_inmate"
{
    blueprint = "exo_helmet_battle",
}

register_gfx_blueprint "exalted_tracker"
{
    equip = {},
    scene = {},
    uisprite = {
        icon       = "data/texture/ui/icons/ui_telegraph_01",
        animation  = "PULSE",
        propagate  = true,
        color      = vec4( 1.5, 0.75, 2.25, 1.0 ),
        visibility = "OOV_ONLY",
    },
}

register_gfx_blueprint "adv_crowbar"
{
    blueprint = "crowbar",
    uisprite = {
        icon = "data/texture/ui/icons/ui_weapon_crowbar",
        color = vec4( 0.0, 1.0, 1.0, 1.0 ),
    },
}

register_gfx_blueprint "adv_axe"
{
    blueprint = "axe",
    uisprite = {
        icon = "data/texture/ui/icons/ui_weapon_axe_medium",
        color = vec4( 0.0, 1.0, 1.0, 1.0 ),
    },
}

register_gfx_blueprint "adv_axe_large"
{
    blueprint = "axe_large",
    uisprite = {
        icon = "data/texture/ui/icons/ui_weapon_axe_large",
        color = vec4( 0.0, 1.0, 1.0, 1.0 ),
    },
}