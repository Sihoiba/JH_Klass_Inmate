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
    data = {
        cache_missing = 0,
        special_reward = false,
    },
    attributes = {
        level = 0,
    },
    callbacks = {
        on_die = [=[
            function ( self )
                world:mark_destroy( self )
                world:flush_destroy()
            end
        ]=],
        on_receive_damage = [=[
            function ( self, entity, source, weapon, amount )
                if not self then return end
                -- fix for multihit weapons
                if amount and entity.attributes and entity.health and entity.attributes.health ~= entity.health.current + amount then
                    return
                end

                local level = world:get_level()
                local coord = world:get_position(entity)
                local tlevel = self.attributes.level or 0
                local slots = { "1", "2", "3" }
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

                for _,slot_id in ipairs( slots ) do
                    local slot = world:get_player():get_slot( slot_id )
                    if slot and slot.weapon and slot.weapon.type ~= world:hash("melee") and slot.clip and slot.clip.ammo and slot.clip.ammo ~= 0 and ammos[slot.clip.ammo] then
                        local e = world:create_entity( ammos[slot.clip.ammo].id )
                        level:drop_entity( e, coord )
                        if tlevel == 3 and self.data.cache_missing > 0 then
                            local missing = self.data.cache_missing
                            while missing > 0 do
                                missing = missing - 1
                                local e = world:create_entity( ammos[slot.clip.ammo].id )
                                level:drop_entity( e, coord )
                            end
                        end
                    end
                end

                if tlevel == 3 and self.data.special_reward then
                    local id
                    if math.random(2) == 2 then
                        id = core.lists.item.special.weapon:roll( level.level_info.ilevel, world.data.level[ world.data.current ] )
                    else
                        id = core.lists.item.special.armor:roll( level.level_info.ilevel, world.data.level[ world.data.current ] )
                    end
                    local e = world:create_entity( id )
                    level:drop_entity( e, coord )
                end

                world:mark_destroy( self )
            end
        ]=],
    },
}