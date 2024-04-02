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
        { target    = "head",  blueprint = "player_inmate_head_part", },
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
    }
}

register_gfx_blueprint "fx_on_fire_decoy_destruct_slash"
{
    lifetime = {
        duration = 2.0,
    },
    light = {
        color       = vec4(4.0,1.0,1.0,1.0),
        range       = 2.0,
    },
    fade = {
        fade_out = 1.0,
    },
    physics_explosion = {
        radius = 1.0,
    },
    "ps_explosion_focused",
    "ps_explosion_crater",
}

register_gfx_blueprint "decoy_self_destruct_slash"
{
    weapon_fx = {
        on_fire    = "fx_on_fire_decoy_destruct_slash",
    },
}

register_gfx_blueprint "fx_on_fire_decoy_destruct_emp"
{
    blueprint = "ps_explosion_large",
    lifetime = {
        duration = 4.0,
    },
    particle = {
        material       = "data/texture/particles/electric_01/electric_01",
        group_id       = "pgroup_fx",
        tiling         = 8,
    },
    light = {
        color       = vec4(2.0,2.0,4.0,1.0),
        range       = 2.0,
    },
    fade = {
        fade_out = 1.0,
    },
    physics_explosion = {
        radius = 2.0,
    },
}

register_gfx_blueprint "decoy_self_destruct_emp"
{
    weapon_fx = {
        on_fire    = "fx_on_fire_decoy_destruct_emp",
    },
}

register_gfx_blueprint "decoy_light" {
    tag = "glow",
    equip = {},
    light = {
        position    = vec3(0,0.2,0),
        color       = vec4(0.5,0.0,1.0,2),
        range       = 2.0,
    }
}

register_gfx_blueprint "decoy_head_part"
{
    skeleton = "data/model/player_male_mesh.nmd",
    {
        tag = "head",
        scale = {
            scale = 0.8,
        },
        render = {
            mesh     = "data/model/player_male_mesh.nmd:player_head_01",
            material = "data/texture/player/male/body_01/A/player_head_01",
        },
    },
}

register_gfx_blueprint "decoy" {
    blueprint = "player",
    slot_base = {
        { target    = "armor", blueprint = "armor_shirt_01_A_part", },
        { target    = "head",  blueprint = "decoy_head_part", },
    },
    {
        tag = "head",
        scale = {
            scale = 0.8,
        },
        render = {
            mesh     = "data/model/player_male_mesh.nmd:player_head_01",
            material = "data/texture/player/male/body_01/A/player_head_01",
        },
    },
    {
        scale = {
            scale = 0.8,
        },
        render = {
            mesh = "data/model/player_male_mesh.nmd:shoes_01",
            material = "data/texture/player/male/shoes_01/A/shoes_01_A",
        },
    },
    {
        scale = {
            scale = 0.8,
        },
        tag    = "armor",
        render = {
            mesh = "data/model/player_male_mesh.nmd:player_trousers_01",
            material = "data/texture/player/male/trousers_01/B/trousers_01_B",
        },
    },
    {
        scale = {
            scale = 0.8,
        },
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

register_gfx_blueprint "buff_inmate_berserk_base"
{
    equip = {},
    persist = true,
    point_generator = {
        type    = "cylinder",
        extents = vec3(0.2,0.9,0.0),
    },
    particle = {
        material       = "data/texture/particles/shapes_01/blick_01",
        group_id       = "pgroup_fx",
        orientation    = PS_ORIENTED,
        destroy_owner  = true,
    },
    particle_emitter = {
        rate     = 96,
        size     = vec2(0.05,0.1),
        velocity = 0.1,
        lifetime = 0.5,
        color    = vec4(1.0,0.1,0.1,0.5),
    },
    particle_transform = {
        force = vec3(0,3,0),
    },
    particle_fade = {
        fade_out = 0.5,
    },
}

register_gfx_blueprint "buff_inmate_berserk_skill_1"
{
    blueprint = "buff_inmate_berserk_base"
}

register_gfx_blueprint "buff_inmate_berserk_skill_2"
{
    blueprint = "buff_inmate_berserk_base"
}

register_gfx_blueprint "buff_inmate_berserk_skill_3"
{
    blueprint = "buff_inmate_berserk_base"
}

register_gfx_blueprint "fragile_pipe_wrench"
{
    uisprite = {
        icon = "data/texture/ui/icons/ui_weapon_pipe_wrench",
        color = vec4( 1.0, 0.15, 0.0, 1.0 ),
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
            mesh     = "data/model/pipe_wrench.nmd:pipe_wrench_01",
            material = "data/texture/weapons/melee/pipe_wrench_01/A/pipe_wrench_01",
        },
    },
}

register_gfx_blueprint "smuggler_cache"
{
    equip = {},
    persist = true,
    point_generator = {
        type    = "cylinder",
        extents = vec3(0.2,0.9,0.0),
    },
    particle = {
        material      = "data/texture/particles/shapes_01/blick_01",
        group_id      = "pgroup_fx",
        orientation   = PS_ORIENTED,
        destroy_owner = true,
    },
    particle_emitter = {
        rate     = 32,
        size     = vec2(0.07,0.2),
        velocity = 0.1,
        color    = vec4(0.84,0.84,0.84,0.5),
        lifetime = 1.5,
    },
    particle_transform = {
        force = vec3(0,1,0),
    },
    light = {
        position = vec3(0,0.3,0),
        color    = vec4(0.84,0.84,0.84,1),
        range    = 1.5,
        vision   = true,
    },
    particle_fade = {
        fade_out = 0.5,
    },
    uisprite = {
        icon       = "data/texture/ui/icons/ui_telegraph_01",
        animation  = "PULSE",
        propagate  = true,
        color      = vec4( 0.84,0.84,0.84, 1.0 ),
        visibility = "OOV_ONLY",
    },
}