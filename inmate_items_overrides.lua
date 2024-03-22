register_blueprint "stimpack_small"
{
    flags = { EF_ITEM, EF_CONSUMABLE },
    lists = {
        group    = "item",
        keywords = { "medical", },
        weight   = 400,
        dmin     = 4,
        dmed     = 7,
    },
    text = {
        name = "stimpack",
        desc = "Standard civilian stimpack. Not the heavy {?curse|shit|stuff} the military uses, but at least you won't get addicted. Protects from pain and negative status effects for a bit, increases your reflexes, and heals like a small medkit. It also resets all your short skill cooldowns and regenerates a part of your class resource.",
    },
    ascii     = {
        glyph     = "+",
        color     = LIGHTGREEN,
    },
    stack = {
        max    = 3,
        amount = 1,
    },
    callbacks = {
        on_use = [=[
            function(self,entity)
                local hc      = entity.health
                local max     = entity.attributes.health
                local mod     = world:get_attribute_mul( entity, "medkit_mod" ) or 1.0
                local current = hc.current

                world:play_sound( "medkit_small", entity )
                if hc.current < max then
                    hc.current = current + math.floor( 40 * mod )
                    if hc.current > max then
                        hc.current = max
                    end
                end

                local epain = entity:child("pain")
                if epain then
                    epain.attributes.accuracy = 0
                    epain.attributes.value    = 0
                end

                for c in ecs:children( entity ) do
                    if c.resource then
                        local attr   = c.attributes
                        local value  = attr.value
                        local max    = attr.max
                        if value < max then
                            local amount = math.floor( max / 4 )
                            attr.value = math.min( value + amount, max )
                        end
                    end
                    if c.skill then
                        if c.skill.time_left > 0 then
                            c.skill.time_left = 0
                        end
                    end
                end

                -- Inmate mod difference here --
                local inmate_dealer = entity:child("ktrait_dealer")
                if inmate_dealer then
                    local increase = {1.5, 2.0, 3.0}
                    world:add_buff( entity, "buff_stimpack", 500 * increase[inmate_dealer.attributes.level])
                else
                    world:add_buff( entity, "buff_stimpack", 500 )
                end
                -- Inmate mod difference ends --

                ui:spawn_fx( entity, "fx_heal", entity )
                if current <= 30 then
                    world:play_voice("vo_imedkit")
                else
                    world:play_voice("vo_medkit")
                end
                world:destroy( entity:child("bleed") )
                world:destroy( entity:child("poisoned") )
                world:destroy( entity:child("acided") )
                world:destroy( entity:child("burning") )
                world:destroy( entity:child("freeze") )
                gtk.remove_fire( entity:get_position() )
                world:get_player().statistics.data.medkit:inc()
                return 100
            end
        ]=],
    },
}

register_blueprint "stimpack_large"
{
    flags = { EF_ITEM, EF_CONSUMABLE },
    lists = {
        group    = "item",
        keywords = { "medical", },
        weight   = 100,
        dmin     = 7,
        dmed     = 14,
    },
    text = {
        name = "military stimpack",
        desc = "Standard military stimpack. Fully heals you, resets all skill cooldowns, regenerates class resource, and removes pain and grants resistances for a longer time. We'd suggest you not overuse it, but we know you better. You monster.",
    },
    ascii     = {
        glyph     = "+",
        color     = GREEN,
    },
    callbacks = {
        on_use = [=[
            function(self,entity)
                local hd      = entity.health
                local attr    = entity.attributes
                local mod     = world:get_attribute_mul( entity, "medkit_mod" ) or 1.0
                local current = hd.current

                world:play_sound( "medkit_large", entity )
                if attr.health > 60 then
                    attr.health = math.max( attr.health - 5, 60 )
                end
                if hd.current < attr.health then
                    hd.current = math.min( current + math.ceil( attr.health * mod ), attr.health )
                end
                local epain = entity:child("pain")
                if epain then
                    epain.attributes.accuracy = 0
                    epain.attributes.value    = 0
                end
                for c in ecs:children( entity ) do
                    if c.resource then
                        local attr   = c.attributes
                        attr.value   = math.max( attr.value, attr.max )
                    end
                    if c.skill then
                        if c.attributes then
                            c.attributes.skill_reset = 1
                        end
                        if c.skill.time_left ~= 0 then
                            c.skill.time_left = 0
                        end
                    end
                end

                -- Inmate mod difference here --
                local inmate_dealer = entity:child("ktrait_dealer")
                if inmate_dealer then
                    local increase = {1.5, 2.0, 3.0}
                    world:add_buff( entity, "buff_stimpack", 3000 * increase[inmate_dealer.attributes.level])
                else
                    world:add_buff( entity, "buff_stimpack", 3000 )
                end
                -- Inmate mod difference ends --

                ui:spawn_fx( entity, "fx_heal", entity )
                if current <= 30 then
                    world:play_voice("vo_imedkit")
                else
                    world:play_voice("vo_medkit")
                end
                world:destroy( entity:child("bleed") )
                world:destroy( entity:child("poisoned") )
                world:destroy( entity:child("acided") )
                world:destroy( entity:child("burning") )
                world:destroy( entity:child("freeze") )
                gtk.remove_fire( entity:get_position() )
                world:get_player().statistics.data.medkit:inc()
                return 100
            end
            ]=],
    },
}

register_blueprint "combatpack_small"
{
    flags = { EF_ITEM, EF_CONSUMABLE },
    lists = {
        group    = "item",
        keywords = { "medical", },
        weight   = 400,
        dmin     = 7,
        dmed     = 14,
    },
    text = {
        name = "combat pack",
        desc = "Military combat drug pack. Prep for a harder engagement. For {!5} turns provides health regeneration ({!10%} per turn), bleed and pain immunity.",
    },
    ascii     = {
        glyph     = "+",
        color     = LIGHTBLUE,
    },
    stack = {
        max    = 3,
        amount = 1,
    },
    callbacks = {
        on_use = [=[
            function(self, entity)

                -- Inmate mod difference here --
                local inmate_dealer = entity:child("ktrait_dealer")
                if inmate_dealer then
                    local increase = {1.5, 2.0, 3.0}
                    world:add_buff( entity, "buff_combatpack", 500 * increase[inmate_dealer.attributes.level])
                else
                    world:add_buff( entity, "buff_combatpack", 500 )
                end
                -- Inmate mod difference ends --

                world:play_sound( "medkit_small", entity )
                world:play_voice("vo_medkit")
                world:destroy( entity:child("bleed") )
                world:get_player().statistics.data.medkit:inc()
                return 100
            end
        ]=],
    },
}

register_blueprint "combatpack_large"
{
    flags = { EF_ITEM, EF_CONSUMABLE },
    lists = {
        group    = "item",
        keywords = { "medical", },
        weight   = 100,
        dmin     = 10,
        dmed     = 17,
    },
    text = {
        name = "large combat pack",
        desc = "Large military combat drug pack. Great when expecting a prolonged firefight. For {!15} turns provides health regeneration ({!10%} per turn), bleed and pain immunity.",
    },
    ascii     = {
        glyph     = "+",
        color     = BLUE,
    },
    callbacks = {
        on_use = [=[
            function(self,entity)
                -- Inmate mod difference here --
                local inmate_dealer = entity:child("ktrait_dealer")
                if inmate_dealer then
                    local increase = {1.5, 2.0, 3.0}
                    world:add_buff( entity, "buff_combatpack", 1500 * increase[inmate_dealer.attributes.level])
                else
                    world:add_buff( entity, "buff_combatpack", 1500 )
                end
                -- Inmate mod difference ends --

                world:play_sound( "medkit_large", entity )
                world:play_voice("vo_medkit")
                world:destroy( entity:child("bleed") )
                world:get_player().statistics.data.medkit:inc()
                return 100
            end
        ]=],
    },
}

register_blueprint "enviropack"
{
    flags = { EF_ITEM, EF_CONSUMABLE },
    lists = {
        group    = "item",
        keywords = { "general", },
        weight   = 400,
        dmin     = 6,
        dmed     = 12,
    },
    text = {
        name = "enviro pack",
        desc = "Military survival pack. For {!50} turns provides full immunity to burning, cold, acid and poisoned statuses.",
    },
    ascii     = {
        glyph     = "+",
        color     = YELLOW,
    },
    stack = {
        max    = 3,
        amount = 1,
    },
    callbacks = {
        on_use = [=[
            function(self,entity)

                -- Inmate mod difference here --
                local inmate_dealer = entity:child("ktrait_dealer")
                if inmate_dealer then
                    local increase = {1.5, 2.0, 3.0}
                    world:add_buff( entity, "buff_enviro", 5000 * increase[inmate_dealer.attributes.level])
                else
                    world:add_buff( entity, "buff_enviro", 5000 )
                end
                -- Inmate mod difference ends --

                world:play_sound( "medkit_small", entity )
                world:destroy( self:child("poisoned") )
                world:destroy( self:child("acided") )
                world:destroy( self:child("burning") )
                world:destroy( self:child("freeze") )
                gtk.remove_fire( entity:get_position() )
                return 100
            end
        ]=],
    },
}