nova.require "libraries/bresenham"

-- BERSERKER

register_blueprint "ktrait_master_berserker"
{
    blueprint = "trait",
    text = {
        name   = "BERSERK",
        desc   = "MASTER TRAIT - you enter berserk on damage and on gibbing with melee weapons.",
        full   = "You're a barely controlled ball of rage, and will go berserk on the slightest provocation.\n\n{!LEVEL 1} - If not Berserk, become berserk if you lose {!10%} of your health in a single hit or {!25%} chance to go berserk on gibbing with a melee kill\n{!LEVEL 2} - Taking damage or gibbing will now add to Berserk time if already berserk\n{!LEVEL 3} - {!33%} chance to go or extend Berserk on a melee gib.\n\nYou can pick only one MASTER trait per character.",
        abbr   = "MBK",
        abbr   = "MBK",

        berserk_proc = "WHO'S A MAN AND A HALF? YOUR A MAN AND A HALF!",
        berserk_extend = "DYNAMITE!"
    },
    attributes = {
        level = 1,
        gib_berserk_chance  = 4,
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                local tlevel, t = gtk.upgrade_master( entity, "ktrait_master_berserker" )
                local tattr = t.attributes
                if tlevel == 3 then
                    tattr.gib_berserk_chance = 3
                end
            end
        ]=],
        on_receive_damage = [=[
            function ( self, entity, source, weapon, amount )
                if not entity then return end
                local tlevel = self.attributes.level
                local max_health = entity.attributes.health
                local ten_percent_max = math.floor( max_health / 10 )
                local is_berserk = entity:child("buff_inmate_berserk_skill_1") or entity:child("buff_inmate_berserk_skill_2") or entity:child("buff_inmate_berserk_skill_3")

                if amount >= ten_percent_max then
                    if (tlevel == 1 and not is_berserk) or tlevel > 1 then
                        if not is_berserk then
                            ui:set_hint( "{R"..self.text.berserk_proc.."}", 2001, 0 )
                        else
                            ui:set_hint( "{R"..self.text.berserk_extend.."}", 2001, 0 )
                        end
                        world:lua_callback( entity, "on_trigger_berserk" )
                    end
                end
            end
        ]=],
        on_kill = [=[
            function ( self, entity, target, weapon, gibbed )
                local tlevel = self.attributes.level
                local gib_berserk = math.random(self.attributes.gib_berserk_chance)
                local is_berserk = entity:child("buff_inmate_berserk_skill_1") or entity:child("buff_inmate_berserk_skill_2") or entity:child("buff_inmate_berserk_skill_3")

                if target.data and target.data.ai and gibbed and gib_berserk == 1 and weapon and weapon.weapon and weapon.weapon.type == world:hash("melee") then
                    if (tlevel == 1 and not is_berserk) or tlevel > 1 then
                        if not is_berserk then
                            ui:set_hint( "{R"..self.text.berserk_proc.."}", 2001, 0 )
                        else
                            ui:set_hint( "{R"..self.text.berserk_extend.."}", 2001, 0 )
                        end
                        world:lua_callback( entity, "on_trigger_berserk" )
                    end
                end
            end
        ]=],
    },
}

-- CHEMIST

function corrode_along_line(self, level, source, end_point, tlevel)
    local start_point = source:get_position()
    local points, _ = line(start_point.x, start_point.y, end_point.x, end_point.y, function (x,y)
        return true
    end)
    local corrode_point = source:get_position()
    for _, v in ipairs(points) do
        if not (v.x == start_point.x and v.y == start_point.y) then
            corrode_point.x = v.x
            corrode_point.y = v.y
            for e in level:entities( corrode_point ) do
                if e.data and e.data.ai then
                    if tlevel == 3 then
                        world:add_buff( e, "buff_corroded", 1000 )
                    end
                    local pool = level:get_entity(corrode_point, "acid_pool" )
                    if not pool then
                        pool = level:place_entity( "acid_pool", corrode_point )
                    end
                end
            end
        end
    end
end

register_blueprint "buff_corroded"
{
    flags = { EF_NOPICKUP },
    text = {
        name    = "Corroded",
        desc    = "{!-100%} acid resistance",
    },
    callbacks = {
        on_die = [[
            function ( self )
                world:mark_destroy( self )
            end
        ]],
    },
    attributes = {
        resist = {
            acid = -100,
        },
    },
    ui_buff = {
       color     = YELLOW,
    },
}

register_blueprint "kperk_chemist"
{
    flags = { EF_NOPICKUP },
    callbacks = {
        on_apply_damage = [=[
            function ( self, source, who )
                if who and who.data and who.data.ai then
                    local clevel = world:get_player():child("ktrait_master_chemist").attributes.level
                    if clevel == 3 and not who:child("buff_corroded") then
                        world:add_buff( who, "buff_corroded", 1000 )
                    end
                end
            end
        ]=],
        on_area_damage = [=[
            function ( self, weapon, level, c, damage, distance, center, source, is_repeat )
                if not is_repeat then
                    local clevel = world:get_player():child("ktrait_master_chemist").attributes.level
                    if weapon and weapon.ui_target and weapon.ui_target.type == world:hash("beam") then
                        corrode_along_line(self, level, source, c, clevel)
                    else
                        for e in level:entities( c ) do
                            if e.data and e.data.ai then
                                if clevel == 3 and not e:child("buff_corroded") then
                                    world:add_buff( e, "buff_corroded", 1000 )
                                end
                            end
                        end
                    end
                end

                if distance < 7 and not world:get_level():get_cell_flags( c )[ EF_NOMOVE ] then
                    nova.log("adding acid pool")
                    if distance < 1 then distance = 1 end
                    local pool = level:get_entity(c, "acid_pool" )
                    if not pool then
                        pool = level:place_entity( "acid_pool", c )
                    end
                    pool.attributes.acid_amount = 10
                    pool.lifetime.time_left = math.max( pool.lifetime.time_left, 400 + math.random(100) )
                end
            end
        ]=],
    },
}

register_blueprint "ktrait_master_chemist"
{
    blueprint = "trait",
    text = {
        name   = "CHEMIST",
        desc   = "MASTER TRAIT - acid resist, and acid spreading on AoE.",
        full   = "You have set up so many make shift drug labs that you know your acids and bases! You are acid immune, moreover any wielded weapon you use (especially area of effect weapons) spread acid!\n\n{!LEVEL 1} - {!immunity} to acid status effect, {!10 Acid} pool created on hit\n{!LEVEL 2} - double armor damage, grenades leave acid in their AoE\n{!LEVEL 3} - hit enemies gain -100% acid resistance\n\nYou can pick only one MASTER trait per character.",
        abbr   = "MCH",
    },
    attributes = {
        level    = 1,
        armor_damage = 1.0,
        resist = {
            acid = 100,
        },
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local tlevel, t = gtk.upgrade_master( entity, "ktrait_master_chemist" )
                t.attributes.chemist_level = tlevel
                if tlevel == 2 then
                    nova.log("Setting armor damage to 2.0")
                    t.attributes.armor_damage = 2.0
                end
                if tlevel >= 1 then
                    local index = 0
                    repeat
                        local w = world:get_weapon( entity, index, true )
                        if not w then break end
                        local fp = w:child("kperk_chemist")
                        if not fp then
                            w:attach("kperk_chemist")
                        end
                        index = index + 1
                    until false
                end
            end
        ]=],
        on_pickup = [=[
            function ( self, user, w )
                local tlevel = self.attributes.level
                if w and w.weapon then
                    if ( tlevel == 1 and not w.stack ) or tlevel > 1 then
                        local fp = w:child("kperk_chemist")
                        if not fp then
                            w:attach("kperk_chemist")
                        end
                    end
                end
            end
        ]=],
        on_pre_command = [=[
            function ( self, entity, command, weapon )
                if command == COMMAND_USE then
                    local tlevel = self.attributes.level
                    if weapon and weapon.weapon and weapon.weapon.group == world:hash("grenades") and tlevel >= 2 then
                        local fp = weapon:child("kperk_chemist")
                        if not fp then
                            weapon:attach("kperk_chemist")
                        end
                    end
                end
                return 0
            end
        ]=],
    },
}

-- GBH

register_blueprint "ktrait_master_gbh"
{
    blueprint = "trait",
    text = {
        name   = "GBH",
        desc   = "MASTER TRAIT - bleed immunity and afflict bleed on attacks.",
        full   = "Grevious bodily harm, it's what you are bloody good at!\n\n{!LEVEL 1} - {!immunity} to bleed status effect, inflict bleed on hit\n{!LEVEL 2} - bleed effects are {!50%} stronger\n{!LEVEL 3} - bleed effects are {!100%} stronger.\n\nYou can pick only one MASTER trait per character.",
        abbr   = "MGB",
    },
    attributes = {
        level    = 1,
        resist = {
            bleed = 100,
        },
        affinity = {
            bleed = 0,
        },
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local tlevel, t = gtk.upgrade_master( entity, "ktrait_master_gbh" )
                if tlevel == 2 then
                    t.attributes["bleed.affinity"] = 50
                elseif tlevel == 3 then
                    t.attributes["bleed.affinity"] = 100
                end
            end
        ]=],
        on_apply_damage = [=[
            function ( self, source, who )
                if who and who.data and who.data.can_bleed then
                    local slevel = core.get_status_value( 4, "bleed", source )
                    core.apply_damage_status( who, "bleed", "bleed", slevel, source )
                end
            end
        ]=],
    },
}

-- GHOST GUN

register_blueprint "buff_ghost_gun"
{
    flags = { EF_NOPICKUP },
    text = {
        name    = "GHOST GUN",
        desc    = "fire all bullets from your pistol/SMGs",
    },
    ui_buff = {
       color     = LIGHTBLUE,
    },
    attributes = {
        level = 1,
        shots = 0
    },
    callbacks = {
        on_pre_command = [=[
            function ( self, entity, command, weapon )
                if command == COMMAND_USE then
                    if weapon and weapon.weapon and weapon.weapon.group == world:hash("grenades") then
                        self.attributes.shots = 0
                    end
                end
                return 0
            end
        ]=],
        on_post_command = [=[
            function ( self, actor, cmt, tgt, time )
                if time <= 0 then return end
                self.attributes.shots = 0
            end
        ]=],
        on_aim = [=[
            function ( self, entity, target, weapon )
                if target and weapon and gtk.is_weapon_group( weapon, {"pistols", "smgs"} ) and weapon.weapon and weapon.attributes and weapon.attributes.shots then
                    local shots = weapon.attributes.shots
                    for c in weapon:children() do
                        if c.attributes and c.attributes.shots then
                            shots = shots + c.attributes.shots
                        end
                    end
                    if weapon:child( "perk_wu_void" ) then
                        shots = shots * (self.attributes.level + 1)
                    end

                    local clip_size = weapon.attributes.clip_size or shots
                    for c in weapon:children() do
                        if c.attributes and c.attributes.clip_size then
                            clip_size = clip_size + c.attributes.clip_size
                        end
                    end
                    local shot_cost = weapon.weapon.shot_cost or 1
                    if shot_cost == 1 then
                        self.attributes.shots = clip_size - shots
                    else
                        self.attributes.shots = math.floor(clip_size/shot_cost) - shots
                    end
                end
            end
        ]=],
        on_rearm = [=[
            function( self, entity, weapon )
                if not gtk.is_weapon_group( weapon, {"pistols","smgs"} ) then
                    world:mark_destroy( self )
                    world:flush_destroy()
                end
            end
        ]=],
        on_detach = [=[
            function( self, parent )
                local sgg = parent:child("kskill_ghost_gun_toggle")
                if sgg then
                    sgg.data.active = false
                    sgg.text.name = sgg.text.on
                end
            end
        ]=]
    }
}

register_blueprint "kskill_ghost_gun_toggle"
{
    flags = { EF_NOPICKUP },
    text = {
        name = "Ghost Gun On",
        on   = "Ghost Gun On",
        off  = "Ghost Gun Off",
    },
    data = {
        is_free_use = true,
        active = false
    },
    skill = {
        cooldown = 0,
    },
    callbacks = {
        on_use = [=[
            function ( self, entity, level )
                 if self.data and self.data.active then
                    self.data.active = false
                    local gg = entity:child( "buff_ghost_gun" )
                    world:mark_destroy( gg )
                    world:flush_destroy()
                    self.text.name = self.text.on
                else
                    self.data.active = true
                    local buff = world:add_buff( entity, "buff_ghost_gun" )

                    local attr = buff.attributes
                    attr.level = level

                    self.text.name = self.text.off
                end
                return 1
            end
        ]=],
        is_usable = [=[
            function ( self, user )
                if gtk.is_weapon_group( user:get_weapon(), {"pistols", "smgs"} ) then
                    return 1
                end
                return 0
            end
        ]=],
    }
}

register_blueprint "ktrait_master_ghost_gun"
{
    blueprint = "trait",
    text = {
        name   = "GHOST GUN",
        desc   = "MASTER TRAIT - PISTOL/SMG ONLY - ACTIVE SKILL Toggle On/Off - empty full clip when firing",
        full   = "You've got a record for using illegal modified firearms. Activate skill to empty your entire clip when you fire a pistol or SMG.\n\n{!LEVEL 1} - While the skill is active fire all your bullets.\n{!LEVEL 2} - Automatically reload pistol/SMGs when empty at {!halved} ammo consumption.\n{!LEVEL 3} reload ammo consumption is {!20%} for pistol/SMGs.\n\nYou can pick only one MASTER trait per character.",
        abbr   = "MGG",
    },
    attributes = {
        level    = 1,
        reload_mod = {
            pistols = 1.0,
            smgs = 1.0,
        },
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local lvl, gg = gtk.upgrade_master( entity, "ktrait_master_ghost_gun" )
                if lvl == 1 then
                    entity:attach( "kskill_ghost_gun_toggle" )
                elseif lvl == 2 then
                    gg.attributes["pistols.reload_mod"] = 0.50
                    gg.attributes["smgs.reload_mod"]    = 0.50
                elseif lvl == 3 then
                    gg.attributes["pistols.reload_mod"] = 0.20
                    gg.attributes["smgs.reload_mod"]    = 0.20
                end
            end
        ]=],
        on_post_command = [=[
            function ( self, actor, cmt, tgt, time )
                if time <= 0 then return end
                local tlevel = self.attributes.level
                if tlevel > 1 and cmt == COMMAND_USE then
                    local weapon = actor:get_weapon()
                    if weapon and gtk.is_weapon_group( weapon, {"pistols", "smgs"} ) then
                        local wd = weapon.weapon
                        if not wd then return 0 end
                        local cd = weapon.clip
                        local clipsize = weapon.attributes.clip_size or 0
                        for c in weapon:children() do
                            if c.attributes and c.attributes.clip_size then
                                clipsize = clipsize + c.attributes.clip_size
                            end
                        end
                        if cd and cd.count == 0 then
                            local reload_attempts = 0
                            while cd.count < clipsize and reload_attempts < 10 do
                                world:get_level():reload( actor, weapon, true )
                                reload_attempts = reload_attempts + 1
                            end
                        end
                    end
                end
            end
        ]=],
    },
}

-- FRAUDSTER

register_blueprint "decoy_light" {
    flags = { EF_NOPICKUP },
    callbacks = {
        on_die = [[
            function ( self )
                world:mark_destroy( self )
            end
        ]],
    }
}

register_blueprint "decoy_self_destruct_slash"
{
    attributes = {
        damage    = 20,
        explosion = 2,
        gib_factor= 2,
    },
    weapon = {
        group = "env",
        damage_type = "slash",
        natural = true,
        fire_sound = "explosion",
    },
    noise = {
        use = 15,
    },
}

register_blueprint "decoy_self_destruct_emp"
{
    attributes = {
        damage     = 20,
        explosion  = 3,
        gib_factor = 0,
        slevel     = { emp = 5, },
    },
    weapon = {
        group = "env",
        damage_type = "emp",
        natural = true,
    },
    callbacks = {
        on_create = [=[
            function( self )
                self:attach( "apply_emp" )
            end
        ]=],
    },
}

register_blueprint "decoy" {
    flags = { EF_NOMOVE, EF_NOFLY, EF_TARGETABLE, EF_ALIVE, EF_IFF, EF_NOCORPSE },
    lists = {
        group = "being",
    },
    text = {
        name = "decoy",
    },
    ascii     = {
        glyph     = "d",
        color     = BLUE,
    },
    health    = {},
    data = {
        level = 1,
        ai = {
            aware = false,
            group = "player",
            state = "idle",
        },
    },
    target = {},
    attributes = {
        health = 25,
    },
    callbacks = {
        on_pre_command = [[
            function ( self, actor, cmt )
                if cmt == COMMAND_WAIT then return 0 end
                world:command( COMMAND_WAIT, actor )
                return -1
            end
        ]],
        on_die = [=[
            function( self, killer, current, weapon )
                world:get_level().level_info.enemies = world:get_level().level_info.enemies + 1
                if self.data.level == 3 then
                    local w_slash = world:create_entity( "decoy_self_destruct_slash" )
                    local w_emp = world:create_entity( "decoy_self_destruct_emp" )
                    world:attach( self, w_slash )
                    world:attach( self, w_emp )
                    world:get_level():fire( self, world:get_position( self ), w_slash, 200 )
                    world:get_level():fire( self, world:get_position( self ), w_emp, 200 )
                end
            end
        ]=],
        on_timer = [=[
            function ( self, first )
                if first then return 1 end
                if not self then return 0 end
                local level = world:get_level()
                for e in level:entities() do
                    if level:can_see_entity(self, e, 8) and e.target and e.target.entity == world:get_player() then
                        e.target.entity = self
                    end
                end
            end
        ]=],
    }
}

register_blueprint "kskill_fraudster_create_decoy"
{
    flags = { EF_NOPICKUP },
    text = {
        name   = "Create decoy",
    },
    data = {
        is_free_use = true
    },
    skill = {
        cooldown = 2000,
    },
    ui_target = {
        type = "mortar",
        opt_distance = 6,
        max_distance = 6,
        range = 0,
    },
    callbacks = {
        on_use = [=[
            function ( self, entity, level )
                local fraudster = entity:child("ktrait_master_fraudster")
                local tlevel = fraudster.attributes.level
                local tcoord = ui:get_target()
                if world:get_level():is_visible(tcoord) then
                    local enemy_count = world:get_level().level_info.enemies * 1
                    local summon = level:add_entity( "decoy", tcoord )
                    summon:equip( "decoy_light" )
                    local friendly = world:create_entity( "friendly" )
                    world:raw_equip( summon, friendly )
                    if tlevel > 1 then
                        summon.attributes.health = 50
                        summon.health.current = 50
                    end
                    summon.data.level = tlevel
                    world:remove_from_max_kills( summon )
                    world:get_level().level_info.enemies = enemy_count
                    return 1
                else
                    world:play_voice( "vo_refuse" )
                    return 0
                end
            end
        ]=],
    }
}

register_blueprint "ktrait_master_fraudster"
{
    blueprint = "trait",
    text = {
        name   = "FRAUDSTER",
        desc   = "MASTER TRAIT - ACTIVE SKILL - create a decoy that attracts enemy fire",
        full   = "You were jailed for fraud; with a few modifications to your comms chip you were able to defraud the system into thinking you were somewhere else giving you all the freedom of Callisto.\n\n{!LEVEL 1} - cooldown {!20}, decoy health {!25}.\n{!LEVEL 2} - cooldown {!10}, decoy health {!50}.\n{!LEVEL 3} cooldown {!5}, decoy explodes on death.\n\nYou can pick only one MASTER trait per character.",
        abbr   = "MFr",
    },
    attributes = {
        level    = 1,
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local lvl, v = gtk.upgrade_master( entity, "ktrait_master_fraudster" )
                if lvl == 1 then
                    entity:attach( "kskill_fraudster_create_decoy" )
                end
                if lvl == 2 then
                    local cd = entity:child( "kskill_fraudster_create_decoy" )
                    cd.skill.cooldown = 1000
                elseif lvl == 3 then
                    local cd = entity:child( "kskill_fraudster_create_decoy" )
                    cd.skill.cooldown = 500
                end
            end
        ]=],
    },
}