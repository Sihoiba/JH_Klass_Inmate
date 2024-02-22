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
                    if weapon and weapon.weapon and weapon.weapon.group == world:hash("grenades") and tlevel >= 1 then
                        local fp = weapon:child("kperk_chemist")
                        if not fp then
                            weapon:attach("kperk_chemist")
                        end
                    end
                end
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
}

register_blueprint "ktrait_master_ghost_gun"
{
    blueprint = "trait",
    text = {
        name   = "GHOST GUN",
        desc   = "MASTER TRAIT - PISTOL/SMG ONLY - ACTIVE SKILL - empty full clip when firing",
        full   = "You've got a record for using illegal modified firearms. Activate skill to empty your entire clip when you fire a pistol or SMG.\n\n{!LEVEL 1} - While the skill is active fire all your bullets.\n{!LEVEL 2} - Automatically reload pistol/SMGs when empty at {!halved} ammo consumption.\n{!LEVEL 3} reload ammo consumption is {!20%} for pistol/SMGs.\n\nYou can pick only one MASTER trait per character.",
        abbr   = "MGG",
    },
    attributes = {
        level    = 1,
        reload_mod = {
            pistols = 1.0,
            smgs = 1.0,
        },
        shots = 0
    },
    data = {
        is_free_use = true,
        active = false
    },
    skill = {
        cooldown = 0,
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                local lvl, v = gtk.upgrade_master( entity, "ktrait_master_ghost_gun" )
                local attr = v.attributes
                if lvl == 2 then
                    attr["pistols.reload_mod"] = 0.50
                    attr["smgs.reload_mod"]    = 0.50
                elseif lvl == 3 then
                    attr["pistols.reload_mod"] = 0.20
                    attr["smgs.reload_mod"]    = 0.20
                end
            end
        ]=],
        on_post_command = [=[
            function ( self, actor, cmt, tgt, time )
                if time <= 0 then return end
                local tlevel = self.attributes.level
                if tlevel > 1 and cmt == COMMAND_USE then
                    local weapon = actor:get_weapon()
                    if weapon and gtk.is_weapon_group( weapon, {"pistols","smgs"} ) then
                        local wd = weapon.weapon
                        if not wd then return 0 end
                        local cd = weapon.clip
                        if cd and cd.count == 0 then
                            world:get_level():reload( actor, weapon, true )
                        end
                    end
                end
                self.attributes.shots = 0
            end
        ]=],
        on_aim = [=[
            function ( self, entity, target, weapon )
                if self.data and self.data.active and target and weapon and gtk.is_weapon_group( weapon, {"pistols", "smgs"} ) and weapon.weapon and weapon.attributes and weapon.attributes.clip_size and weapon.attributes.shots then
                    local shots = weapon.attributes.shots
                    local clipsize = weapon.attributes.clip_size
                    local shot_cost = weapon.weapon.shot_cost or 1
                    if shot_cost == 1 then
                        self.attributes.shots = weapon.attributes.clip_size - weapon.attributes.shots
                    else
                        self.attributes.shots = math.floor(weapon.attributes.clip_size/shot_cost) - weapon.attributes.shots
                    end
                end
            end
        ]=],
        on_use = [=[
            function ( self, entity )
                if self.data and self.data.active then
                    self.data.active = false
                    local gg = entity:child("buff_ghost_gun")
                    world:mark_destroy( gg )
                    world:flush_destroy()
                else
                    self.data.active = true
                    world:add_buff( entity, "buff_ghost_gun" )
                end
                return 1
            end
        ]=],
        is_usable = [=[
            function ( self, user )
                if gtk.is_weapon_group( user:get_weapon(), {"pistols","smgs"} ) then
                    return 1
                end
                return 0
            end
        ]=],
        on_rearm = [=[
            function( self, entity, weapon )
                if not gtk.is_weapon_group( weapon, {"pistols","smgs"} ) then
                    local gg = entity:child("buff_ghost_gun")
                    world:mark_destroy( gg )
                    world:flush_destroy()
                end
            end
        ]=],
    },
}