register_blueprint "resource_rage"
{
    flags = { EF_NOPICKUP },
    text = {
        name   = "Rage",
        desc   = "PASSIVE SKILL - Inmate resource",
        full   = "INTERNAL!",
        abbr   = "Rage",
    },
    attributes = {
        value  = 40,
        max    = 40,
        amount = 1
    },
    resource = {
        color = LIGHTRED,
        block_size = 5,
    },
    callbacks = {
        on_receive_damage = [[
            function ( self, entity, source, weapon, amount )

                if not entity then return end
                if not entity.data or not entity.data.is_player then return end
                if amount < 5 then return end

                local restore_bonus = entity:attribute( "rage_bonus") or 0
                local restore = math.floor( amount * 0.2 ) + restore_bonus
                local resource = entity:child( "resource_rage" )

                local rattr = resource.attributes
                if rattr.value < rattr.max then
                    rattr.value = math.min( rattr.value + restore, rattr.max )
                end
            end
        ]],
    },
}

register_blueprint "ktrait_always_angry"
{
    blueprint = "trait",
    text = {
        name   = "Always Angry",
        desc   = "PASSIVE SKILL - restore 50% rage every time you enter a level",
        full   = "INTERNAL!",
        abbr   = "AAn",
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                entity:attach( "ktrait_always_angry" )
            end
        ]=],
        on_enter_level = [=[
            function ( self, entity, reenter )
                if reenter then return end
                local resource = entity:child( "resource_rage" )

                local rattr = resource.attributes
                if rattr.value < rattr.max then
                    rattr.value = rattr.value + (rattr.max * 0.5)
                    if rattr.value > rattr.max then
                        rattr.value = rattr.max
                    end
                end
            end
        ]=],
    },
}

register_blueprint "buff_inmate_berserk_base"
{
    flags = { EF_NOPICKUP },
    text = {
        name = "Berserk!",
        desc = "Big damage resistance, faster movement, increased melee damage, but melee only white it lasts.",
        weapon_fail = "GUNS ARE FOR WUSSES! RIP AND TEAR!",
        kill_text = "RIP AND TEAR! RIP AND TEAR!",
        door_kill_text = "KNOCK, KNOCK. WHO'S THERE? ME!",
        environmental_object_kill_text = "CHOO CHOO CHA'BOOGIE!",
    },
    data = {
        resource_before = 0
    },
    ui_buff = {
        color     = RED,
        priority  = 200,
        style     = 3,
    },
    attributes = {
        damage_mult = 5.0,
        accuracy    = 10,
        pain_max    = -75,
        dodge_value = 0,
        dodge_max   = 0,
        move_time   = 0.9,
        splash_mod  = 0.5,
        resist = {
            slash = 50,
            impact = 50,
            pierce = 50,
            plasma = 50,
            fire = 25,
            cold = 25,
            acid = 25,
            toxin = 25,
        },
    },
    callbacks = {
        on_pre_command = [[
            function ( self, entity, command, w, coord )
                self.attributes.initialized = 1
                if command == COMMAND_USE then
                    if w then
                        if ( w.weapon and w.weapon.type ~= world:hash("melee") ) or ( w.skill and ( w.skill.weapon and ( not w.skill.melee ) ) ) then
                            ui:set_hint( "{R"..self.text.weapon_fail.."}", 2001, 0 )
                            return -1
                        end
                    end
                end
                return 0
            end
        ]],
        on_aim = [[
            function ( self, entity, target, weapon )
                if target and weapon then
                    if ( weapon.weapon and weapon.weapon.group == world:hash("env") ) then
                        return 0
                    end
                    if ( weapon.weapon and weapon.weapon.type ~= world:hash("melee") ) or ( weapon.skill and weapon.skill.weapon and not weapon.skill.melee ) then
                        return -1
                    end
                end
            end
        ]],
        on_kill = [[
            function ( self, entity, target, weapon )
                local is_door = false
                local level = world:get_level()
                local c = world:get_position(target)
                local d = level:get_entity(c, "door") or level:get_entity(c, "pdoor") or level:get_entity(c, "door2") or level:get_entity(c, "door2_l") or level:get_entity(c, "door2_r")
                if d and d == target then
                    is_door = true
                end
                if is_door then
                    ui:set_hint( "{R"..self.text.door_kill_text.."}", 2001, 0 )
                elseif not (target.data and target.data.ai) then
                    ui:set_hint( "{R"..self.text.environmental_object_kill_text.."}", 2001, 0 )
                else
                    ui:set_hint( "{R"..self.text.kill_text.."}", 2001, 0 )
                end
            end
        ]],
        on_detach = [[
            function( self, parent )
                if parent and parent.attributes and parent.attributes.grace_period then
                    parent.attributes.grace_period = false
                    buff = world:add_buff( parent, "buff_inmate_berserk_grace_period", 300 )
                end
            end
        ]]
    },
}

register_blueprint "buff_inmate_berserk_skill_1"
{
    blueprint = "buff_inmate_berserk_base",
    attributes = {
        damage_mult = 10.0,
        accuracy    = 10,
        pain_max    = -75,
        dodge_value = 0,
        dodge_max   = 0,
        move_time   = 0.75,
        splash_mod  = 0.5,
        resist = {
            slash = 75,
            impact = 75,
            pierce = 75,
            plasma = 75,
            fire = 50,
            cold = 50,
            acid = 50,
            toxin = 50,
        },
    }
}

register_blueprint "buff_inmate_berserk_skill_2"
{
    blueprint = "buff_inmate_berserk_base",
    attributes = {
        damage_mult = 10.0,
        accuracy    = 10,
        pain_max    = -75,
        dodge_value = 10,
        dodge_max   = 10,
        move_time   = 0.75,
        splash_mod  = 0.5,
        resist = {
            slash = 75,
            impact = 75,
            pierce = 75,
            plasma = 75,
            fire = 50,
            cold = 50,
            acid = 50,
            toxin = 50,
        },
    }
}

register_blueprint "buff_inmate_berserk_skill_3"
{
    blueprint = "buff_inmate_berserk_base",
    attributes = {
        damage_mult = 12.0,
        accuracy    = 15,
        pain_max    = -75,
        dodge_value = 20,
        dodge_max   = 20,
        move_time   = 0.75,
        splash_mod  = 0.1,
        resist = {
            slash = 90,
            impact = 90,
            pierce = 90,
            plasma = 90,
            fire = 75,
            cold = 75,
            acid = 75,
            toxin = 75,
        },
    }
}

register_blueprint "buff_inmate_berserk_grace_period"
{
    flags = { EF_NOPICKUP },
    text = {
        name = "Grace!",
        desc = "Short lived damage resistance to get to safety.",
    },
    ui_buff = {
        color     = BLUE,
        priority  = 200,
        style     = 3,
    },
    attributes = {
        dodge_value = 30,
        dodge_max   = 30,
        resist = {
            slash = 80,
            impact = 80,
            pierce = 80,
            plasma = 80,
        },
    }
}

register_blueprint "buff_inmate_berserk_speed_boost"
{
    flags = { EF_NOPICKUP },
    attributes = {
        speed = 1.1
    }
}

register_blueprint "ktrait_berserk"
{
    blueprint = "trait",
    text = {
        name   = "Berserk",
        desc   = "ACTIVE SKILL - spend your rage to go Berserk!",
        full   = "You're a barely controlled simmering ball of anger. It doesn't take much to send you into a berserker rage that earned you a reputation as someone not to mess with. When berserk you do increased melee damage, have damage and status resistance, but your too mad to waste time using gun when you could hurt people with your hands. Activating berserk will automatically swap to the first carried melee weapon if present",
        abbr   = "Ber",
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                entity:attach( "ktrait_berserk" )
            end
        ]=],
        on_use = [=[
            function ( self, entity, level, target )
                local buff
                local duration_bonus = (entity:attribute( "berserk_duration_bonus") or 0) + 1
                local duration = 1000 * duration_bonus
                if entity.attributes and entity.attributes.skilled_bonus and entity.attributes.skilled_bonus == 1 then
                    buff = world:add_buff( entity, "buff_inmate_berserk_skill_1", duration )
                elseif entity.attributes and entity.attributes.skilled_bonus and entity.attributes.skilled_bonus == 2 then
                    duration = duration * 2
                    buff = world:add_buff( entity, "buff_inmate_berserk_skill_2", duration )
                elseif entity.attributes and entity.attributes.skilled_bonus and entity.attributes.skilled_bonus == 3 then
                    duration = duration * 2
                    buff = world:add_buff( entity, "buff_inmate_berserk_skill_3", duration )
                else
                    buff = world:add_buff( entity, "buff_inmate_berserk_base", duration )
                end
                if entity:attribute( "berserk_action_bonus" ) then
                    world:add_buff( entity, "buff_inmate_berserk_speed_boost", duration )
                end
                world:lua_callback( entity, "on_inmate_berserk" )

                local index = 0
                local melee = nil
                repeat
                    melee = world:get_weapon( entity, index, true )
                    if not melee then break end
                    if melee.weapon and melee.weapon.type == world:hash("melee") then
                        break
                    end
                    index = index + 1
                until false
                if melee then
                    local bgg = entity:child("buff_ghost_gun")
                    if bgg then
                        nova.log("GHOST GUN disabled")
                        world:mark_destroy( bgg )
                        world:flush_destroy()
                    end
                    level:swap_weapon( entity, index )
                end

                world:lua_callback( entity, "on_berserk" )

                return 1
            end
        ]=],
        on_trigger_berserk = [=[
            function ( self, entity )
                local buff
                local duration_bonus = (entity:attribute( "berserk_duration_bonus") or 0) + 1
                local duration = 1000 * duration_bonus
                if entity.attributes and entity.attributes.skilled_bonus and entity.attributes.skilled_bonus == 1 then
                    buff = world:add_buff( entity, "buff_inmate_berserk_skill_1", duration )
                elseif entity.attributes and entity.attributes.skilled_bonus and entity.attributes.skilled_bonus == 2 then
                    duration = duration * 2
                    buff = world:add_buff( entity, "buff_inmate_berserk_skill_2", duration )
                elseif entity.attributes and entity.attributes.skilled_bonus and entity.attributes.skilled_bonus == 3 then
                    duration = duration * 2
                    buff = world:add_buff( entity, "buff_inmate_berserk_skill_3", duration )
                else
                    buff = world:add_buff( entity, "buff_inmate_berserk_base", duration )
                end
                if entity:attribute( "berserk_action_bonus" ) then
                    world:add_buff( entity, "buff_inmate_berserk_speed_boost", duration )
                end
                world:lua_callback( entity, "on_inmate_berserk" )
            end
        ]=],
    },
    data = {
        is_free_use = true,
    },
    skill = {
        resource = "resource_rage",
        fail_vo  = "vo_no_rage",
        cooldown = 500,
        cost     = 25,
    },
}

register_blueprint "runtime_add_xp"
{
    flags = { EF_NOPICKUP },
    callbacks = {
        on_enter_level = [[
            function ( self, player, reenter )
                world:add_experience( player, 4000 )
            end
        ]],
    },
}

register_blueprint "klass_inmate"
{
    text = {
        name  = "Inmate",
        short = "Inmate",
        desc = "Inmates are mean and tough enough to need to be imprisoned all the way out here.\n\n{!RESOURCE} - {!Rage} is the Inmate's class resource, it regenerates as the inmate takes damage.\n\n{!PASSIVE} - each time you enter a new level you restore 50% {!Rage}.\n\n{!ACTIVE} - for {!30} points of Rage you go Berserk gaining movement speed, damage resistance and a massive melee damage boost.\n\n{!GEAR} - Inmates start with a pipe wrench but no guns.",
        abbr = "M",
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                entity:attach( "resource_rage" )
                entity:attach( "ktrait_always_angry" )
                local adr = entity:attach( "ktrait_berserk" )
                adr.skill.cost = 30
                entity:attach( "pipe_wrench" )
            end
        ]=],
    },
    klass = {
        id     = "inmate",
        entity = "player_inmate",
        traits = {
            { "ktrait_skilled_inmate", max = 3, },
            { "ktrait_dash", max = 3, },
            { "ktrait_grenadier", max = 3, },
            { "trait_juggler", max = 3, },
            { "ktrait_brute", max = 3, },
            { "ktrait_mule", max = 3, },
            { "ktrait_smuggler", max = 3, },
            { "ktrait_desperado", max = 3, },
            { "ktrait_gambler", max = 3, },
            { "ktrait_cutter", max = 3, },

            { "ktrait_sucker_punch", max = 3, require = { ktrait_skilled_inmate = 1, } },
            { "ktrait_first_rule", max = 3, require = { ktrait_brute = 1, } },
            { "ktrait_burglar", max = 3, require = { ktrait_smuggler = 1, } },
            { "ktrait_dealer", max = 3, require = { ktrait_cutter = 1, } },
            { "ktrait_kneecap", max = 3, require = { ktrait_dash = 1, } },
            { "ktrait_hitman", max = 3, require = { ktrait_desperado = 1, } },
            { "trait_whizkid", max = 3, require = { ktrait_gambler = 1, } },

            { "ktrait_master_berserker", max = 3, master = true, require = { ktrait_skilled_inmate = 2, level = 6, level_inc = 4, } },
            { "ktrait_master_chemist", max = 3, master = true, require = { ktrait_cutter = 1, ktrait_grenadier = 1, level = 6, level_inc = 4, } },
            { "ktrait_master_gbh", max = 3, master = true, require = { ktrait_kneecap = 1, level = 6, level_inc = 4, } },
            { "ktrait_master_fraudster", max = 3, master = true, require = {  ktrait_burglar = 1, level = 6, level_inc = 4, } },
            { "ktrait_master_ghost_gun", max = 3, master = true, require = { ktrait_desperado = 1, ktrait_smuggler = 1, level = 6, level_inc = 4, } },
        },
    },
}

register_blueprint "player_inmate"
{
    blueprint = "player",
    text = {
        name = "you",
        namep = "you",
        killed_by = "suicide",
    },
}