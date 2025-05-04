nova.require "data/lua/core/common"

register_blueprint "exo_axe"
{
    blueprint = "base_melee",
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
    },
    callbacks = {
        on_aim = [=[
            function ( self, entity, target, weapon )
                local fire_time = 1.0
                local berserk = entity:child("buff_inmate_berserk_base") or
                entity:child("buff_inmate_berserk_skill_1") or
                entity:child("buff_inmate_berserk_skill_2") or
                entity:child("buff_inmate_berserk_skill_3")
                if berserk then
                    fire_time = 0.9
                end
                self:parent().attributes.fire_time = fire_time
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
        desc = "using Berserk clears all negative effects",
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

register_blueprint "adv_crowbar"
{
    blueprint = "crowbar",
    lists = {
        group    = "item",
        keywords = { "inmate", "weapon", "special", "melee" },
        weight   = 70,
        dmin     = 2,
        dmed     = 5,
        dmax     = 8,
    },
    text = {
        desc = "When scientists decide to make a better crowbar",
    },
    ascii     = {
        glyph     = "/",
        color     = CYAN,
    },
    data = {
        perk = {
            type          = "perk_w",
            subtype       = "melee",
            damage_low    = 10,
            damage_high   = 15,
            damage_status = 5,
        },
    },
    callbacks = {
        on_create = [=[
            function(self,_,tier)
                nova.log("crowbar tier"..tostring(tier))
                generator.roll_perks( self, tier )
                generator.add_perk( self, "perk_wb_zombiebane" )
            end
        ]=]
    },
}

register_blueprint "adv_axe"
{
    blueprint = "axe",
    text = {
        desc = "For when you need to fell something.",
    },
    lists = {
        group    = "item",
        keywords = { "inmate", "weapon", "special", "melee" },
        weight   = 70,
        dmin     = 8,
        dmed     = 15,
        dmax     = 18,
    },
    ascii     = {
        glyph     = "/",
        color     = CYAN,
    },
    data = {
        perk = {
            type          = "perk_w",
            subtype       = "melee",
            damage_low    = 20,
            damage_high   = 25,
            damage_status = 5,
        },
    },
    callbacks = {
        on_create = [=[
            function(self,_,tier)
                nova.log("axe tier"..tostring(tier))
                generator.roll_perks( self, tier )
            end
        ]=],
    },
}

register_blueprint "adv_axe_large"
{
    blueprint = "axe_large",
    text = {
        desc = "Timber!",
    },
    lists = {
        group    = "item",
        keywords = { "inmate", "weapon", "special", "melee" },
        weight   = 70,
        dmin     = 15,
        dmed     = 18,
        dmax     = 25,
    },
    ascii     = {
        glyph     = "/",
        color     = CYAN,
    },
    data = {
        perk = {
            type          = "perk_w",
            subtype       = "melee",
            damage_low    = 20,
            damage_high   = 30,
            damage_status = 10,
        },
    },
    callbacks = {
        on_create = [=[
            function(self,_,tier)
                nova.log("large axe tier"..tostring(tier))
                generator.roll_perks( self, tier )
            end
        ]=],
    },
}

register_blueprint "perk_fragile"
{
    flags      = { EF_NOPICKUP },
    text = {
        name  = "Fragile",
        desc  = "breaks after this many attacks.",
    },
    attributes = {
        level = 1,
        value = 10,
    },
    callbacks = {
        on_post_command = [=[
            function ( self, actor, cmt, weapon, time )
                if self:parent() == weapon then
                    local sattr = self.attributes
                    sattr.value = sattr.value - 1
                    if sattr.value == 0 then
                        world:get_level():drop_item( actor, weapon )
                        world:destroy( weapon )
                    end
                end
                return 0
            end
        ]=],
    }
}

register_blueprint "fragile_pipe_wrench"
{
    blueprint = "base_melee",
    text = {
        name = "shoddy pipe wrench",
        desc = "It's seen a lot of use, and won't take much more.",
    },
    ascii     = {
        glyph     = "/",
        color     = DARKGRAY,
    },
    attributes = {
        damage = 30,
        swap_time    = 0.5,
        crit_damage  = 50,
        mod_capacity = 4,
        gib_factor   = 2,
    },
    ui_target = {
        type = "melee",
    },
    weapon = {
        group = "melee",
        type  = "melee",
        damage_type = "impact",
        fire_sound = "blunt_swing",
        hit_sound  = "blunt",
    },
    callbacks = {
        on_create = [=[
            function(self,_,tier)
                generator.add_perk( self, "perk_wb_mechabane" )
                generator.add_perk( self, "perk_fragile" )
            end
        ]=],
    },
}

register_blueprint "damaged_pistol"
{
	blueprint = "base_pistol",
	lists = {
		group    = "item",
		keywords = { "base_weapon", },
		weight   = 20,
		dmed     = 12,
		dmax     = 18,
	},
	text = {
		name = "damaged 9mm pistol",
		desc = "Standard military sidearm, damaged but in better shape than the {?curse|poor sod|fucker} you stole it and the landing craft from in your escape attempt. The magazine is jammed so it can't be reloaded.",
	},
	ascii     = {
		glyph     = "/",
		color     = DARKGRAY,
	},
	clip = {
		ammo  = "ammo_9mm",
		count = 8,
		reload_sound = "pistol_reload",
		reload_count = -1,
	},
	attributes = {
		swap_time = 0.5,
		damage = 16,
		shots = 1,
		clip_size  = 8,
		crit_damage = 50,
		mod_capacity = 0,
		opt_distance = 3,
		max_distance = 6,
	},
	ui_target = {
		type = "path",
	},
	noise = {
		use = 10,
	},
	weapon = {
		group = "pistols",
		damage_type = "impact",
		fire_sound = "pistol_shot",
		hit_sound  = "bullet",
	},
}