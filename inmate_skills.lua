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
        full = "You're the guy everyone avoided in the yard. You'll shrug off hits that would stagger others.\n\n{!LEVEL 1} - {!2} points of armour versus all damage\n{!LEVEL 2} - {!3} points of armour, {!%-25} slash damage \n{!LEVEL 3} - {!4} points of armour, {!%-50} slash damage",
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