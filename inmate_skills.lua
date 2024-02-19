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
        desc = "Increases armour and splash damaage resistnace",
        full = "You're the guy everyone avoided in the yard. You'll shrug off hits that would stagger others.\n\n{!LEVEL 1} - {!2} points of armour versus all damage\n{!LEVEL 2} - {!3} points of armour, {!%-25} splash damage \n{!LEVEL 3} - {!4} points of armour, {!%-50} splash damage",
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
        full   = "You are the go to guy to move contraband around callisto!\n\n{!LEVEL 1} - {!+1} inventory slot, reveal elevators\n{!LEVEL 2} - {!+3} inventory slots\n{!LEVEL 3} - {!+5} inventory slots, reveal lost boxes",
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
                elseif mule == 2 then
                    attr.inv_capacity = attr.inv_capacity + 2
                elseif mule == 3 then
                    attr.inv_capacity = attr.inv_capacity + 2
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
        desc   = "Find ammo in descructable environment objects",
        full   = "You know where the black market stashes items!\n\n{!LEVEL 1} - small amount of ammo in every object for current weapon, except grenades and rockets\n{!LEVEL 2} - medium amount of ammo, grenades can be found \n{!LEVEL 3} - large amount of ammo, rockets can be found",
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
                if target and wep and wep.weapon and not (target.data and target.data.ai) and not target.hazard and (target.text and target.text.name ~= "door") and wep.weapon.type ~= world:hash("melee") and wep.clip and wep.clip.ammo then

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

                    local ammo = ammos[wep.clip.ammo]
                    local grenades = "ammo_40"
                    local rockets = "ammo_rockets"

                    if tlevel == 1 and ammo.id ~= grenades and ammo.id ~= rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 1 + math.random(2)
                        level:drop_entity( e, coord )
                    elseif tlevel == 2 and ammo.id == grenades then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 1 + math.random(2)
                        level:drop_entity( e, coord )
                    elseif tlevel == 2 and ammo.id ~= grenades and ammo.id ~= rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 5 + math.random(5)
                        level:drop_entity( e, coord )
                    elseif tlevel == 3 and ammo.id == grenades then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 3 + math.random(3)
                        level:drop_entity( e, coord )
                    elseif tlevel == 3 and ammo.id == rockets then
                        local e = world:create_entity( ammo.id )
                        e.stack.amount = 1 + math.random(2)
                        level:drop_entity( e, coord )
                    elseif tlevel == 3 and ammo.id ~= grenades and ammo.id ~= rockets then
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
        full = "You have a history of gun crimes and desperate shoot outs. Guns gain flat bonus damage depending on how many shots in the clip, the fewer the better.\n\n{!LEVEL 1} - {!+25%} times shot cost/clip\n{!LEVEL 2} - {!+50%} times shot cost/clip\n{!LEVEL 3} - {!+100%} times shot cost/clip",
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
                    bonus = 1.0
                end

                if target and weapon and weapon.attributes and weapon.attributes.clip_size then
                    local shot_cost = weapon.weapon.shot_cost or 1
                    local cost_per_shot = shot_cost * weapon.attributes.shots
                    local shot_clip_percent = cost_per_shot /  weapon.attributes.clip_size
                    local damage_bonus = 1 + (shot_clip_percent * bonus)

                    self.attributes.damage_mult = damage_bonus
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
        full = "You cannot resist a game of chance, hacking them into things when they don't otherwise exist.\n\n{!LEVEL 1} - {!+50%} chance to refund the cost when using a station\n{!LEVEL 2} - {!+10%} chance the station will drop a multitool when using it, and reveal terminals\n{!LEVEL 3} - {!+75%} chance to refund the cost when using a station.",
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
                gtk.upgrade_trait( entity, "ktrait_gambler" )
            end
        ]],
        on_enter_level = [[
            function ( self, entity, reenter )
                if reenter then return end
                self.data.stations_and_terminals = {}
                for e in world:get_level():entities() do
                    if e.attributes and e.attributes.charges then
                        self.data.stations_and_terminals[world:get_id(e)] = e.attributes.charges
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
                        if k == world:get_id(e) then
                            if v > e.attributes.charges then
                                if self.data.multitool_count < world:has_item( entity, "kit_multitool" ) then
                                    self.data.multitool_count = world:has_item( entity, "kit_multitool" )
                                else
                                    local lucky = math.random(2)

                                    if tlevel == 3 then
                                        lucky = math.random(4)
                                    end

                                    if lucky == 1 then
                                        self.data.stations_and_terminals[world:get_id(e)] = e.attributes.charges
                                    elseif lucky > 1 then
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
                                self.data.stations_and_terminals[world:get_id(e)] = e.attributes.charges
                            end
                        end
                    end
                end
            end
        ]],
     },
}