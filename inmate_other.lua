nova.require "data/lua/core/common"

register_blueprint "exalted_tracker"
{
    flags = { EF_NOPICKUP, },
    minimap = {
        color    = tcolor( LIGHTMAGENTA, 255, 128, 255 ),
        priority = 110,
    },
    callbacks = {
        on_die = [=[
            function ( self )
                world:mark_destroy( self )
            end
        ]=],
    },
}

register_blueprint "smuggler_cache"
{
    flags = { EF_NOPICKUP },
    text = {
        name  = "Smuggler cache",
    },
    ui_buff = {
        color     = WHITE,
    },
    attributes = {
        level = 0
    },
    callbacks = {
        on_die = [=[
            function ( self )
                world:mark_destroy( self )
            end
        ]=],
        on_receive_damage = [=[
            function ( self, entity, source, weapon, amount )
                if not self then return end
                nova.log("recieved damage")
                local level = world:get_level()
                local tlevel = self.attributes.level or 0
                local wep = world:get_player():get_weapon()
                local coord = world:get_position(entity)
                if wep and wep.weapon then
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
                            local slot     = source:get_slot( slot_id )
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
                world:mark_destroy( self )
            end
        ]=],
    },
}