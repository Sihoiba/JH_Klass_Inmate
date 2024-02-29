register_blueprint "ktrait_skilled_inmate"
{
    blueprint = "trait",
    text = {
        name   = "Skilled",
        desc   = "PASSIVE SKILL - improve your class traits",
        full   = "You were locked up for a reason. Each level of this skill improves your berserk active skill.\n\n{!LEVEL 1} - bigger melee damage bonus, better resistances, faster move speed\n{!LEVEL 2} - double Beserk duration, dodge bonus while berserk\n{!LEVEL 3} - even more melee damage, damage resistance and dodge",
        abbr   = "Skl",
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                local attr  = entity.attributes
                attr.skilled_bonus = ( attr.skilled_bonus or 0 ) + 1
            end
        ]=],
    },
}

register_blueprint "ktrait_brute"
{
    blueprint = "trait",
    text = {
        name = "Brute",
        desc = "Increases armour and splash damage resistance",
        full = "You're the guy everyone avoided in the yard. You'll shrug off hits that would stagger others.\n\n{!LEVEL 1} - {!2} points of armour versus all damage\n{!LEVEL 2} - {!3} points of armour, {!-25%} splash damage \n{!LEVEL 3} - {!4} points of armour, {!-50%} splash damage",
        abbr = "Bru",
    },
    armor = {},
    attributes = {
        armor = 2,
        splash_mod = 1.0,
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                local brute = entity:child( "ktrait_brute" )
                if brute then
                    local attr = brute.attributes
                    attr.armor = attr.armor + 1
                    if attr.armor == 3 then
                        attr.splash_mod = 0.75
                    elseif attr.armor == 4 then
                        attr.pain_effect = 0.5
                    end
                else
                    entity:attach( "ktrait_brute" )
                end
            end
        ]=],
    },
}

register_blueprint "ktrait_mule"
{
    blueprint = "trait",
    text = {
        name   = "Mule",
        desc   = "Gain extra inventory slots, locate exits and lootboxes",
        full   = "You are the go to guy to move contraband around Callisto!\n\n{!LEVEL 1} - {!+1} inventory slot, reveal elevators\n{!LEVEL 2} - {!+3} inventory slots\n{!LEVEL 3} - {!+5} inventory slots, reveal lootboxes",
        abbr   = "Mul",
    },
    attributes = {
        level   = 1,
    },
    callbacks = {
        on_activate = [=[
            function( self, entity )
                local attr    = entity.attributes
                local mule = ( attr.mule_level or 0 ) + 1
                attr.mule_level = mule
                if mule == 1 then
                    attr.inv_capacity = attr.inv_capacity + 1
                    for c in world:get_level():coords( { "elevator", "portal", "floor_exit", "elevator_branch", "elevator_special" } ) do
                        world:get_level():set_explored( c, true )
                    end
                elseif mule == 2 then
                    attr.inv_capacity = attr.inv_capacity + 2
                elseif mule == 3 then
                    attr.inv_capacity = attr.inv_capacity + 2
                    leveltk.reveal_lootboxes( world:get_level() )
                end
                entity:attach( "ktrait_mule" )
            end
        ]=],
        on_enter_level = [=[
            function ( self, entity, reenter )
                if reenter then return end
                local level = world:get_level()
                local mule = entity:attribute( "mule_level" ) or 0

                if mule > 0 then
                    for c in level:coords( { "elevator", "portal", "floor_exit", "elevator_branch", "elevator_special" } ) do
                        level:set_explored( c, true )
                    end
                end

                if mule == 3 then
                    leveltk.reveal_lootboxes( world:get_level() )
                end
            end
        ]=],
    },
}

register_blueprint "ktrait_smuggler"
{
    blueprint = "trait",
    text = {
        name   = "Smuggler",
        desc   = "Find ammo in destructable environment objects",
        full   = "You know where the black market stashes items! Break boxes, plants, and chairs to find ammo for the current held weapon, or a random carried weapon if current weapon is melee.\n\n{!LEVEL 1} - small amount of ammo in every object for current weapon, except 40mm grenades and rockets\n{!LEVEL 2} - medium amount of ammo, 40mm grenades can be found \n{!LEVEL 3} - large amount of ammo, rockets can be found",
        abbr   = "Sm",
    },
    attributes = {
        level   = 1,
    },
    callbacks = {
        on_activate = [=[
            function( self, entity )
                gtk.upgrade_trait( entity, "ktrait_smuggler" )
            end
        ]=],
        on_kill = [[
            function ( self, entity, target, weapon, gibbed, coord )
                local level = world:get_level()
                local tlevel = self.attributes.level or 0
                local wep = entity:get_weapon()
                if target and wep and wep.weapon and not (target.data and target.data.ai) and not target.hazard and (target.text and target.text.name ~= "door")  then

                    local ammos  =
                    {
                        [world:hash("ammo_9mm")]     = { id = "ammo_9mm", },
                        [world:hash("ammo_shells")]  = { id = "ammo_shells",},
                        [world:hash("ammo_762")]     = { id = "ammo_762", },
                        [world:hash("ammo_44")]      = { id = "ammo_44", },
                        [world:hash("ammo_40")]      = { id = "ammo_40", },
                        [world:hash("ammo_cells")]   = { id = "ammo_cells", },
                        [world:hash("ammo_rockets")] = { id = "ammo_rockets", },
                    }

                    local grenades = "ammo_40"
                    local rockets = "ammo_rockets"

                    local ammo = nil
                    if wep.weapon.type ~= world:hash("melee") and wep.clip and wep.clip.ammo then
                        ammo = ammos[wep.clip.ammo]
                    elseif wep.weapon.type == world:hash("melee") then
                        local slots         = { "1", "2", "3" }
                        local weapons = {}
                        for _,slot_id in ipairs( slots ) do
                            local slot     = entity:get_slot( slot_id )
                            if slot and slot.weapon and slot.weapon.type ~= world:hash("melee") then
                                table.insert(weapons, slot)
                            end
                        end
                        if next(weapons) then
                            local w = table.remove( weapons, math.random( #weapons ) )
                            nova.log("weapon name "..tostring(w.text.name))
                            if w and w.clip and w.clip.ammo then
                                ammo = ammos[w.clip.ammo]
                            end
                        end
                    end

                    if tlevel == 1 and ammo and ammo.id ~= grenades and ammo.id ~= rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 1 + math.random(2)
                        level:drop_entity( e, coord )
                    elseif tlevel == 2 and ammo and ammo.id == grenades then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 1 + math.random(2)
                        level:drop_entity( e, coord )
                    elseif tlevel == 2 and ammo and ammo.id ~= grenades and ammo.id ~= rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 5 + math.random(5)
                        level:drop_entity( e, coord )
                    elseif tlevel == 3 and ammo and ammo.id == grenades then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 3 + math.random(3)
                        level:drop_entity( e, coord )
                    elseif tlevel == 3 and ammo and ammo.id == rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 1 + math.random(2)
                        level:drop_entity( e, coord )
                    elseif tlevel == 3 and ammo and ammo.id ~= grenades and ammo.id ~= rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 10 + math.random(10)
                        level:drop_entity( e, coord )
                    end
                end
            end
        ]],
    },
}

register_blueprint "ktrait_desperado"
{
    blueprint = "trait",
    text = {
        name = "Desperado",
        desc = "Damage bonus based on weapon shot cost versus clip size. No affect on melee.",
        full = "You have a history of gun crimes and desperate shoot outs. Guns gain flat bonus damage depending on how many shots in the clip, the fewer the better.\n\n{!LEVEL 1} - {!+25%} times shot cost/clip\n{!LEVEL 2} - {!+50%} times shot cost/clip\n{!LEVEL 3} - {!+75%} times shot cost/clip",
        abbr = "Des",
    },
    attributes = {
        level   = 1,
        damage_mult = 1.0,
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                gtk.upgrade_trait( entity, "ktrait_desperado" )
            end
        ]=],
        on_aim = [=[
            function ( self, entity, target, weapon )
                local tlevel = self.attributes.level or 0
                local bonus = 0.25

                if tlevel == 2 then
                    bonus = 0.5
                elseif tlevel == 3 then
                    bonus = 0.75
                end

                if target and weapon and weapon.attributes and weapon.weapon and weapon.weapon.type ~= world:hash("melee") and ( not weapon.stack ) then
                    local shots = weapon.attributes["shots"] or 0
                    for c in weapon:children() do
                        if c.attributes and c.attributes.shots then
                            shots = shots + c.attributes.shots
                        end
                    end
                    local clip_size = weapon.attributes.clip_size or shots
                    local gg = entity:child("ktrait_master_ghost_gun")
                    if gg then
                        local e_shots = gg.attributes.shots or 0
                        shots = shots + e_shots
                    end
                    local shot_cost = weapon.weapon.shot_cost or 1
                    local cost_per_shot = shot_cost * shots
                    local shot_clip_percent = cost_per_shot / clip_size
                    local damage_bonus = 1 + (shot_clip_percent * bonus)

                    self.attributes.damage_mult = damage_bonus
                else
                    self.attributes.damage_mult = 1.0
                end
            end
        ]=],
    },
}

register_blueprint "ktrait_gambler"
{
    blueprint = "trait",
    text = {
        name = "Gambler",
        desc = "Chance to refund charges when using a terminal; excluding extract multitools.",
        full = "You cannot resist a game of chance, hacking them into things when they don't otherwise exist.\n\n{!LEVEL 1} - {!+40%} chance to refund the cost when using a station\n{!LEVEL 2} - {!+10%} chance the station will drop a multitool when using it, and reveal terminals\n{!LEVEL 3} - {!+80%} chance to refund the cost when using a station.",
        abbr = "Gmb",
    },
    attributes = {
        level   = 1,
    },
    data = {
        stations_and_terminals = {},
        multitool_count = 0,
    },
    callbacks = {
        on_activate = [[
            function(self, entity)
                local tlevel = gtk.upgrade_trait( entity, "ktrait_gambler" )
                if tlevel == 2 then
                    leveltk.reveal_terminals_and_stations( world:get_level() )
                end
            end
        ]],
        on_enter_level = [[
            function ( self, entity, reenter )
                if reenter then return end
                self.data.stations_and_terminals = {}
                for e in world:get_level():entities() do
                    if e.attributes and e.attributes.charges then
                        self.data.stations_and_terminals[e] = e.attributes.charges
                    end
                end
                local tlevel = self.attributes.level
                if tlevel > 1 then
                    leveltk.reveal_terminals_and_stations( world:get_level() )
                end
            end
        ]],
        on_pre_command = [[
            function ( self, entity, command, weapon )
                self.data.multitool_count = world:has_item( entity, "kit_multitool" )
                return 0
            end
        ]],
        on_post_command = [[
            function ( self, entity, command, weapon, time )
                if next(self.data.stations_and_terminals) == nil then
                    nova.log("No stations or ammo terminals")
                    return 0
                end

                local tlevel = self.attributes.level or 0

                for e in world:get_level():entities() do
                    for k, v in pairs(self.data.stations_and_terminals) do
                        if k == e then
                            if v > e.attributes.charges then
                                if self.data.multitool_count < world:has_item( entity, "kit_multitool" ) then
                                    self.data.multitool_count = world:has_item( entity, "kit_multitool" )
                                else
                                    local lucky = math.random(5)
                                    local good_luck = 2
                                    if tlevel == 3 then
                                        good_luck = 4
                                    end

                                    if lucky > good_luck then
                                        self.data.stations_and_terminals[e] = e.attributes.charges
                                    elseif lucky <= good_luck then
                                        world:play_sound( "vending_hit_reward", e )
                                        e.attributes.charges = v
                                        uitk.station_activate( entity, e, true )
                                    end

                                    if tlevel > 1 then
                                        local mtlucky = math.random(10)
                                        if mtlucky == 10 then
                                            world:play_sound( "vending_hit_reward", e )
                                            entity:pickup( "kit_multitool", true )
                                            uitk.station_activate( entity, e, true )
                                        end
                                    end
                                end
                            elseif v < e.attributes.charges then
                                self.data.stations_and_terminals[e] = e.attributes.charges
                            end
                        end
                    end
                end
            end
        ]],
     },
}

function run_cutter_ui( self, user, level, return_entity )
    local list = {}

    local max_len = 1
    if level >= 1 and world:has_item( user, "medkit_small" ) > 0 then
        max_len = math.max( max_len, string.len( "Make combat pack" ) )
        table.insert( list, {
            name = "Make combat pack",
            target = self,
            parameter = world:create_entity("combatpack_small"),
            confirm = true,
       })
    end
    if level >= 2 and world:has_item( user, "medkit_small" ) > 0  then
        max_len = math.max( max_len, string.len( "Make stimpack" ) )
        table.insert( list, {
            name = "Make stimpack",
            target = self,
            parameter = world:create_entity("stimpack_small"),
            confirm = true,
       })
    end
    if level == 3 and world:has_item( user, "medkit_large" ) > 0  then
        max_len = math.max( max_len, string.len( "Breakdown large medkit" ) )
        table.insert( list, {
            name = "Breakdown large medkit",
            target = self,
            parameter = world:create_entity("medkit_small"),
            confirm = true,
       })
    end

    table.insert( list, {
        name = ui:text("ui.lua.common.cancel"),
        target = self,
        cancel = true,
    })
    list.title = "Convert medkits"
    list.size  = coord( math.max( 30, max_len + 6 ), 0 )
    list.confirm = "Are you sure you want to convert a medkit?"
    ui:terminal( user, nil, list )
end

register_blueprint "kskill_cutter"
{
    blueprint = "trait",
    text = {
        name  = "Cut Medkits",
        desc  = "ACTIVE SKILL - convert medkits into other item",
        abbr  = "Cut skill",
    },
    callbacks = {
        on_use = [=[
            function( self, entity )
                if entity == world:get_player() then
                    nova.log("Run UI")
                    run_cutter_ui( self, entity, self.attributes.level, entity )
                    return -1
                else
                    return -1
                end
            end
        ]=],
        on_activate = [=[
            function ( self, who, level, param )
                nova.log("on activate")
                if param then
                    nova.log("param"..tostring(param.text.name))
                    if param.text.name == "combat pack" and world:has_item( who, "medkit_small" ) > 0 then
                        world:remove_items( who, "medkit_small", 1 )
                        who:pickup( "combatpack_small", true )
                    elseif param.text.name == "stimpack" and world:has_item( who, "medkit_small" ) > 0  then
                        world:remove_items( who, "medkit_small", 1 )
                        who:pickup( "stimpack_small", true )
                    elseif param.text.name == "small medkit" and world:has_item( who, "medkit_large" ) > 0  then
                        world:remove_items( who, "medkit_large", 1 )
                        who:pickup( "medkit_small", true )
                        who:pickup( "medkit_small", true )
                        who:pickup( "medkit_small", true )
                    end
                end
            end
        ]=],
        is_usable = [=[
            function ( self, user )
                local tlevel = self.attributes.level or 0
                if tlevel >= 1 and world:has_item( user, "medkit_small" ) > 0 then
                    return 1
                elseif tlevel == 3 and world:has_item( user, "medkit_large" ) > 0 then
                    return 1
                end
                return 0
            end
        ]=],
    },
    data = {
        is_free_use = true,
    },
    attributes = {
        level = 1,
    },
    skill = {
        cooldown = 0,
    }
}

register_blueprint "ktrait_cutter"
{
    blueprint = "trait",
    text = {
        name  = "Cutter",
        desc  = "You can convert medkits into better drugs",
        full  = "You know how to convert standard civilian medkits into something much more potent\n\n{!LEVEL 1} - convert small medkits into combat packs\n{!LEVEL 2} - convert small medkits into stimpacks\n{!LEVEL 3} - convert large medkits into three small medkits",
        abbr  = "Cut",
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                gtk.upgrade_trait( entity, "ktrait_cutter" )
                gtk.upgrade_trait( entity, "kskill_cutter" )
            end
        ]=],
    },
    attributes = {
        level = 1,
    },
}

register_blueprint "ktrait_first_rule"
{
    blueprint = "trait",
    text = {
        name   = "First Rule",
        desc   = "Highlight most dangerous enemies on the minimap",
        full   = "First rule as an inmate, find the biggest guy in prison and make him your bitch.\n\n{!LEVEL 1} - the three toughest enemies will be visible on the mini map\n{!LEVEL 2} - exalted enemies are visible on the mini map and highlighted out of view in a different colour\n{!LEVEL 3} - always know where {!all} enemies are",
        abbr   = "FRu",
    },
    attributes = {
        level        = 1,
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local tlevel = gtk.upgrade_trait( entity, "ktrait_first_rule" )

                local level = world:get_level()
                if tlevel == 3 then
                    leveltk.reveal_enemies( world:get_level() )
                elseif tlevel >= 1 then
                    local toughest = {}
                    local toughest3 = {}
                    local track_count = 0
                    for e in level:enemies() do
                        local xp = e.attributes.experience_value or 0
                        local danger = e.attributes.health + xp
                        if tlevel == 2 and e.text and not string.find(e.text.name, "exalted") then
                            table.insert(toughest, {entity = e, danger = danger})
                            track_count = track_count + 1
                        elseif tlevel == 1 then
                            table.insert(toughest, {entity = e, danger = danger})
                            track_count = track_count + 1
                        end
                    end

                    table.sort( toughest, function ( a, b ) return a.danger > b.danger end )

                    for i = 1,3 do
                        if toughest[i] then
                            toughest3[toughest[i].entity] = toughest[i].danger
                        end
                    end

                    for e in level:enemies() do
                        if toughest3[e] then
                            e:equip("tracker")
                            e.minimap.always = true
                        end
                    end
                end
                if tlevel >= 2 then
                    for e in level:enemies() do
                        if e.text and string.find(e.text.name, "exalted") then
                            local tracker = e:child("tracker")
                            if tracker then
                                world:mark_destroy( tracker )
                            end
                            local etracker = e:equip("exalted_tracker")
                            e.minimap.color = etracker.minimap.color
                            e.minimap.always = true
                        end
                    end
                    world:flush_destroy()
                end
            end
        ]=],
        on_enter_level = [=[
            function ( self, entity, reenter )
                if reenter then return end
                local level = world:get_level()
                if self.attributes.level == 3 then
                    leveltk.reveal_enemies( world:get_level() )
                elseif self.attributes.level >= 1 then
                    local toughest = {}
                    local toughest3 = {}
                    local track_count = 0
                    for e in level:enemies() do
                        local xp = e.attributes.experience_value or 0
                        local danger = e.attributes.health + xp
                        if self.attributes.level == 2 and e.text and not string.find(e.text.name, "exalted") then
                            table.insert(toughest, {entity = e, danger = danger})
                            track_count = track_count + 1
                        elseif self.attributes.level == 1 then
                            table.insert(toughest, {entity = e, danger = danger})
                            track_count = track_count + 1
                        end
                    end

                    table.sort( toughest, function ( a, b ) return a.danger > b.danger end )

                    for i = 1,3 do
                        if toughest[i] then
                            toughest3[toughest[i].entity] = toughest[i].danger
                        end
                    end

                    for e in level:enemies() do
                        if toughest3[e] then
                            e:equip("tracker")
                            e.minimap.always = true
                        end
                    end
                end
                if self.attributes.level >= 2 then
                    for e in level:enemies() do
                        if e.text and string.find(e.text.name, "exalted") then
                            local tracker = e:child("tracker")
                            if tracker then
                                world:mark_destroy( tracker )
                            end
                            local etracker = e:equip("exalted_tracker")
                            e.minimap.color = etracker.minimap.color
                            e.minimap.always = true
                        end
                    end
                    world:flush_destroy()
                end
            end
        ]=],
    },
}

register_blueprint "kskill_burglar_open_close"
{
    blueprint = "trait",
    text = {
        name  = "Open doors",
        name2 = "Open/close doors",
        name3 = "Open/close/unlock doors",
        desc  = "ACTIVE SKILL - open near by doors",
        abbr  = "Open doors",
    },
    callbacks = {
        on_use = [=[
            function ( self, entity, level, target )
                local level = world:get_level()
                local tlevel = self.attributes.level
                local return_val = 0
                for e in level:entities() do
                    if e.text and e.text.name == "door" then
                        local coord = world:get_position(e)
                        local distance = level:distance(entity, e)
                        local visible = level:is_visible(coord)
                        local closed = e.flags.data[ EF_NOMOVE ]
                        local broken = e.flags.data[ EF_KILLED ]
                        local locked = ecs:child( e, "door_locked" ) or ecs:child( e, "door2_locked_l" ) or ecs:child( e, "door2_locked_r" ) or ecs:child( e, "door_red_locked" )

                        if tlevel == 1 and distance < 3 and visible and closed and not broken and not locked then
                            e.flags.data = { EF_ACTION },
                            world:play_sound( "door_open", e )
                            world:set_state( e, "open" )
                            return_val = 1
                        elseif tlevel > 1 and visible and closed and not broken and not locked then
                            e.flags.data = { EF_ACTION },
                            world:play_sound( "door_open", e )
                            world:set_state( e, "open" )
                            return_val = 1
                        elseif tlevel > 1 and visible and not closed and not broken and level:can_close( e ) then
                            e.flags.data = { EF_NOSIGHT, EF_NOMOVE, EF_NOFLY, EF_NOSHOOT, EF_BUMPACTION, EF_ACTION }
                            world:play_sound( "door_close", e )
                            world:set_state( e, "closed" )
                            return_val = 1
                        end
                        if tlevel == 3 and visible and not broken and ecs:child( e, "door_locked" ) then
                            e.flags.data = { EF_ACTION },
                            level:change_state( e, {
                                door_locked    = "door_unlocked",
                            })
                            world:play_sound( "door_open", e )
                            world:set_state( e, "open" )
                            return_val = 1
                        end
                    end
                    if tlevel == 3 then
                        local elevators = { elevator_01 = true, elevator_01_off = true, elevator_01_branch = true, elevator_01_special = true, elevator_01_mini = true }
                        for e in level:entities() do
                            local coord = world:get_position(e)
                            local visible = level:is_visible(coord)
                            if visible and elevators[ world:get_id(e) ] then
                                local locked = e:child( "elevator_inactive" ) or e:child( "elevator_locked" ) or e:child("elevator_secure")
                                if locked then
                                    world:set_state( e, "open" )
                                    world:play_sound( "door_open_03", e )
                                    world:mark_destroy( locked )
                                    world:flush_destroy()
                                    return_val = 1
                                end
                            end
                        end
                    end
                end
                if return_val == 0 then
                    if tlevel == 1 then
                        ui:set_hint( "No doors can be interacted with or the doors are too far away", 50, 1 )
                    else
                        ui:set_hint( "No doors can be interacted with", 50, 1 )
                    end
                end
                return return_val
            end
        ]=]
    },
    data = {
        is_free_use = true,
    },
    attributes = {
        level = 1,
    },
    skill = {
        cooldown = 1000,
        cost     = 0,
    },
}

register_blueprint "ktrait_burglar"
{
    blueprint = "trait",
    text = {
        name   = "Burgler",
        desc   = "ACTIVE SKILL - open doors from a distance",
        full   = "There's no where you can't break into given enough time!\n\n{!LEVEL 1} - Open all doors within 2 distance\n{!LEVEL 2} - open or close all doors in sight\n{!LEVEL 3} - open red key card locked doors and elevators, open locked mini level elevators in sight",
        abbr   = "Bur",
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                gtk.upgrade_trait( entity, "ktrait_burglar" )
                local tlevel, burg = gtk.upgrade_trait( entity, "kskill_burglar_open_close" )
                if tlevel == 2 then
                    burg.text.name = burg.text.name2
                    burg.text.abbr = burg.text.name2
                elseif tlevel == 3 then
                    burg.text.name = burg.text.name3
                    burg.text.abbr = burg.text.name3
                end
            end
        ]=]
    },
    attributes = {
        level = 1,
    }
}

register_blueprint "ktrait_sucker_punch"
{
    blueprint = "trait",
    text = {
        name   = "Sucker punch",
        desc   = "They never see the first blow coming",
        full   = "The trick to winning a fight is to land the first blow before the other guy even knows a fight has started! With this trait when you wield non bladed melee weapons you hit faster. To ensure you have the right weapons, lootboxes with bladed weapons will include a non bladed one.\n\n{!LEVEL 1} - {!90%} attack time with non bladed melee weapons\n{!LEVEL 2} - {!80%} attack time with non bladed melee weapons, melee weapon lootboxes also contain Axes\n{!LEVEL 3} - {!60%} attack time with non bladed melee weapons, melee weapon lootboxes contain large axes",
        abbr   = "SPu",
    },
    attributes = {
        level = 1,
        melee_speed = 1.11,
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                local tlevel, t = gtk.upgrade_trait( entity, "ktrait_sucker_punch" )
                local attr = t.attributes
                if tlevel == 2 then
                    attr.melee_speed = 1.25
                elseif tlevel == 3 then
                    attr.melee_speed = 1.67
                end
            end
        ]=],
        on_post_command = [=[
            function ( self, actor, cmt, tgt, time )
                if time <= 0 then return end
                if cmt == COMMAND_USE then
                    local weapon = actor:get_weapon()
                    if weapon and weapon.weapon and weapon.weapon.type == world:hash("melee")
                    and not gtk.is_blade( weapon ) then
                        self.attributes.speed = self.attributes.melee_speed
                    end
                else
                    self.attributes.speed = 1.0
                end
            end
        ]=],
        on_lootbox_open = [=[
            function(self, who, what)
                local tlevel  = self.attributes.level
                local melee_box = false
                local melee_adv = false
                local melee_adv_prefix = ""
                for c in ecs:children( what ) do
                        if c.weapon and c.weapon.type == world:hash("melee") then
                        melee_box = true
                        if c.data and not melee_adv then
                            melee_adv = c.data.adv
                            melee_adv_prefix = c.text.prefix
                        end
                    end
                end
                nova.log(melee_adv_prefix)
                local tier = 0
                if melee_adv_prefix == "AV1" then
                    tier = 1
                elseif melee_adv_prefix == "AV2" then
                    tier = 2
                elseif melee_adv_prefix == "AV3" then
                    tier = 3
                end
                if tlevel == 2 and melee_box then
                    if melee_adv then
                        what:attach("adv_axe", nil, tier)
                    else
                        what:attach("axe")
                    end
                elseif tlevel == 3 and melee_box then
                    if melee_adv then
                        what:attach("adv_axe_large", nil, tier)
                    else
                        what:attach("axe_large")
                    end
                end
            end
        ]=],
    },
}

dealer = {
    data = {
        buffs = {},
    }
}

function dealer.record_buff( entity )
    if entity and entity.text then
        if entity.text.name == "Stimmed" or entity.text.name == "Juiced" or entity.text.name == "Enviro" then
            table.insert(dealer.data.buffs, entity)
        end
    end
end

register_blueprint "ktrait_dealer"
{
    blueprint = "trait",
    text = {
        name = "Dealer",
        desc = "Increases duration of postive buffs from items.",
        full = "When your fellow prisoners want better drugs, you are the person they turn to. When you use items that grant buffs like stim packs the duraction is increased\n\n{!LEVEL 1} - Positive buff duration increased by {!50%} \n{!LEVEL 2} - increase is now {!100%} \n{!LEVEL 3} - increase is now {!200%}s",
        abbr = "Del",
    },
    attributes = {
        level   = 1,
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local tlevel = gtk.upgrade_trait( entity, "ktrait_dealer" )
                if tlevel == 1 then
                    world.register_on_entity( dealer.record_buff )
                end
            end
        ]=],
        on_post_command = [=[
            function ( self, actor, cmt, tgt, time )
                if world:get_player() ~= actor then
                    return 0
                end
                local increase = {1.5, 2.0, 3.0}
                for k,e in pairs(dealer.data.buffs) do
                    if e.lifetime then
                        e.lifetime.time_left = e.lifetime.time_left * increase[self.attributes.level]
                    end

                    table.remove(dealer.data.buffs, k)
                end
                return 0
            end
        ]=],
    },
}

register_blueprint "ktrait_hitman"
{
    blueprint = "trait",
    text = {
        name   = "Hitman",
        desc   = "Improved accuracy and safe explosive usage",
        full   = "When it came time for someone to have an accident they came to you; you then threw that someone down the elevator shaft. Each level of this trait improves your ability to fight at close range.\n\n{!LEVEL 1} - {!-3} minimum distance\n{!LEVEL 2} - grenade launchers, rocket launchers and grenades are safe at close distance\n{!LEVEL 3} - enemy cover is only {!20%} effective",
        abbr   = "Hit",
    },
    attributes = {
        level   = 1,
        min_distance = 0,
        cover_mult   = 1.0,
        player_splash_mod = 1.0
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                local hit, t = gtk.upgrade_trait( entity, "ktrait_hitman" )
                local attr  = t.attributes
                if hit == 1 then
                    attr.min_distance = -3
                else
                    attr.cover_mult   = 0.2
                end
            end
        ]=],
        on_aim = [=[
            function ( self, entity, target, weapon )
                if self.attributes.level < 2 then return end
                local weapon = entity:get_weapon()
                if weapon and weapon.weapon and weapon.attributes and weapon.attributes.explosion then
                    weapon.attributes.splash_mod = 0.0
                end
            end
        ]=],
        on_pre_command = [=[
            function ( self, entity, command, weapon )
                if command == COMMAND_USE then
                    if weapon and weapon.weapon and weapon.weapon.group == world:hash("grenades") then
                        self.attributes.player_splash_mod = entity.attributes.splash_mod
                        entity.attributes.splash_mod = 0.0
                    end
                end
                return 0
            end
        ]=],
        on_post_command = [=[
            function ( self, actor, cmt, tgt, time )
                if command == COMMAND_USE then
                    actor.attributes.splash_mod = self.attributes.player_splash_mod
                end
            end
        ]=],
    },
}

register_blueprint "ktrait_kneecap"
{
    blueprint = "trait",
    text = {
        name   = "Kneecap",
        desc   = "PISTOL/SMG/SEMI/AUTO SKILL - weaken biological enemies on hit",
        full   = "You know where to shoot someone to give them a bad day!\n\n{!LEVEL 1} - enemies shot are slowed\n{!LEVEL 2} - enemies shot have reduced accuracy\n{!LEVEL 3} - enemies shot do reduced damage\n",
        abbr   = "Kne",
    },
    attributes = {
        level = 1,
    },
    callbacks = {
        on_activate = [=[
            function(self, entity)
                local tlevel = gtk.upgrade_trait( entity, "ktrait_kneecap" )
                local index = 0
                repeat
                    local w   = world:get_weapon( entity, index, true )
                    if not w then break end
                    local wd = w.weapon
                    if wd then
                        if gtk.is_weapon_group( w, { "pistols", "smgs", "semi", "auto" } ) then
                            if tlevel >= 1 and not w:child("perk_wb_kneecap") then
                                generator.add_perk( w, "perk_wb_kneecap" )
                            end
                            if tlevel >= 2 and not w:child("perk_we_panic") then
                                generator.add_perk( w, "perk_we_panic" )
                            end
                            if tlevel == 3 and not w:child("perk_we_stun")  then
                                generator.add_perk( w, "perk_we_stun" )
                            end
                        end
                    end
                    index = index + 1
                until false
            end
        ]=],
        on_pickup = [=[
            function ( self, user, w )
                if w and w.weapon and ( not w.stack ) then
                    local tlevel = self.attributes.level
                    local wd     = w.weapon
                    if wd then
                        if gtk.is_weapon_group( w, { "pistols", "smgs", "semi", "auto" } ) then
                            if tlevel >= 1 and not w:child("perk_wb_kneecap") then
                                generator.add_perk( w, "perk_wb_kneecap" )
                            end
                            if tlevel >= 2 and not w:child("perk_we_panic") then
                                generator.add_perk( w, "perk_we_panic" )
                            end
                            if tlevel == 3 and not w:child("perk_we_stun")  then
                                generator.add_perk( w, "perk_we_stun" )
                            end
                        end
                    end
                end
            end
        ]=],
    },
}