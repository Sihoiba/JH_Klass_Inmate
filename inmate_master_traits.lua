register_blueprint "ktrait_master_berserker"
{
    blueprint = "trait",
    text = {
        name   = "BERSERK",
        desc   = "MASTER TRAIT - you enter berserk on damage and on gibbing with melee weapons.",
        full   = "You're a barely controlled ball of rage, and will go berserk on the slightest provocation.\n\n{!LEVEL 1} - If not Berserk, become berserk if you lose {!10%} of your health in a single hit or {!25%} chance to go berserk on gibbing with a melee kill\n{!LEVEL 2} - Taking damage or gibbing will now add to Berserk time if already berserk\n{!LEVEL 3} - {!33%} chance to go or extend Berserk on a melee gib.\n\nYou can pick only one MASTER trait per character.",
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
                local tattr     = t.attributes
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