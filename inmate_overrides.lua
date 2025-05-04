register_blueprint "level_callisto_intro"
{
    blueprint   = "level_base",
    text        = {
        name        = "CALLISTO L1",
        on_enter    = "You come back from a routine patrol of the Callisto orbit. Your landing craft gets shot down by the automated defense systems. Something is wrong...",
        on_enter_inmate   = "You planned your escape, jumped the pilot and hijacked the landing craft. Before you left orbit you were shot down by the automated defense systems. You need a new way off this rock...",
    },
    environment = {
        music        = "music_callisto_01",
    },
    attributes = {
        xp_check = 0,
    },
    callbacks = {
        on_create = [[
            function ( self )

                local generate = function( self, params )
                    local tiles  = {
                        callisto_intro.tileset_13x13, callisto_intro.tileset_13x13_2,
                        callisto_intro.tileset_11x13, callisto_intro.tileset_9x7,
                        callisto_intro.tileset_7x11,  callisto_intro.tileset_7x11,
                        callisto_intro.tileset_9x7_2, callisto_intro.tileset_9x7_2,
                    }
                    local set    = tiles[ math.random(#tiles) ]
                    if set.map_size then
                        self:resize( set.map_size )
                    end
                    self:set_styles{ set.base_style or "ts06_F:ext", "ts06_F:hangar", "ts06_F", "ts06_F:pipes", "ts01_A" }

                    local result  = generator.archibald( self, set, set.param_override )
                    local rewards = {
                        { "lootbox_medical", "lootbox_ammo", "lootbox_general" },
                        { "lootbox_medical", "lootbox_ammo", "lootbox_general" },
                        { "lootbox_medical", "lootbox_ammo" },
                        { "lootbox_medical", "lootbox_ammo" },
                        { "lootbox_medical", "lootbox_ammo", "lootbox_armor" },
                    }
                    local list = rewards[ math.min( DIFFICULTY + 1, #rewards )]
                    generator.drop_marker_rewards( self, "mark_special", larea, list )
                    result.no_elevator_check = true
                    for c in self:get_area():edges() do
                        self:set_cell_flag( c, EF_NOSPAWN, true )
                    end
                    return result
                end

                local spawn = function( self )
                    local enemies = {
                        -- EASY:
                        { { "grunt1", "grunt1" }, "grunt1", "sergeant1", "guard1", "drone1" },
                        -- MEDIUM:
                        { { "grunt1", "grunt1" }, { "grunt1", "grunt1" }, "sergeant1", { "drone1", "drone1" }, "guard1", "guard1" },
                        -- HARD:
                        { { "grunt1", "grunt1" }, { "grunt1", "grunt1" }, "fire_fiend", "sergeant1", "sergeant1", { "drone1", "drone1" }, "soldier1", "guard1", "guard1" },
                        -- UV, N!
                        { { "grunt1", "grunt1" }, { "grunt1", "grunt1" }, { "guard1", "guard1", "guard1" }, "fire_fiend", "fiend", "sergeant1", { "drone1", "drone1" }, "soldier1", "soldier1" },        }
                    local list        = enemies[ math.min( DIFFICULTY + 1, #enemies )]
                    local entry_coord = self:find_coord( "floor_entrance" ) or ivec2(1,1)

                    for _,v in ipairs( list ) do
                        local p = generator.random_safe_spawn_coord( self, self:get_area():shrinked(4), entry_coord, 8 )
                        local result = generator.spawn( self, v, p )
                    end
                end

                generator.run( self, nil, generate, spawn )
                self.environment.lut = math.random_pick( luts.standard )
            end
            ]],
        on_enter_level = [[
            function ( self, player, reenter )
                if reenter then return end
                local vo = "vo_callisto"
                if DIFFICULTY > 1 and math.random(10) == 1 then
                    if math.random(10) == 1 then
                        vo = "vo_callisto_rare"
                    else
                        vo = "vo_callisto_cool"
                    end
                end
                if gtk.get_klass_id( player ) == "inmate" then
                    ui:alert {
                        title   = "",
                        teletype = 0,
                        content = self.text.on_enter_inmate,
                        size    = ivec2( 34, 10 ),
                    }
                else
                    ui:alert {
                        title   = "",
                        teletype = 0,
                        content = self.text.on_enter,
                        size    = ivec2( 34, 10 ),
                    }
                end
                world:play_voice( vo )
            end
        ]],
        on_kill = [[
            function ( self, killed, killer, all )
                if self.attributes.xp_check == 1 then
                    local expected = { 200, 220, 300, 400 }
                    local min_xp   = expected[math.min( DIFFICULTY + 1, #expected )]
                    local player   = world:get_player()
                    if player.progression and player.progression.experience < min_xp then
                        local bonus = min_xp - player.progression.experience
                        world:add_experience( player, bonus )
                    end
                    self.attributes.xp_check = 0
                end
            end
        ]],
        on_cleared = [[
            function ( self )
                self.attributes.xp_check = 1
            end
        ]],
    }
}

register_blueprint "challenge_reload_fraudster"
{
    text = {
        name   = "Angel of New York Reload - Inmate Fraudster Fix",
        desc   = "Why waste time reloading if you can pull out another gun? The real trick is to have one always at hand though! You cannot reload at all, and to make sure you cannot cheat, you cannot pickup ammo or melee weapons either! To give you any (miniscule) chance of beating the game you get a six shot Golden Gun. Additionally, all enemies drop some kind of weapon. Good luck, you'll need it! Identical to standard AoNYR but using Fraudster Decoy skill won't crash the game\n\nRating   : {RHARD}",
        rating = "HARD",
        abbr   = "AoNYR",
        letter = "R",
    },
    challenge = {
        type      = "challenge",
        rank      = 6,
        group     = "reload",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                local attr = player.attributes
                player:attach( "runtime_reload" )
                local eammo = player:child("ammo_9mm") or player:child("ammo_44")
                if eammo then world:destroy( eammo ) end
                player:attach( "unich_golden_gun" )
            end
        ]],
        on_create_entity = [[
            function( self, entity, alive )
                if alive then
                    local id = world:get_id( entity )
                    if id == "summoner" or id == "exalted_summoner" then
                        entity.attributes.gate = 666
                    elseif id == "boss_damage_gate" then
                        entity.attributes.gate = 666
                    elseif id == "decoy" then
                        return
                    else
                        local w = entity:get_weapon()
                        if w and w.weapon and w.weapon.natural then
                            if not entity.inventory then
                                ecs:add( entity, "inventory" )
                            end
                            local ilvl = world:get_level().level_info.ilevel
                            local item
                            if math.random(10) == 1 then
                                item = core.lists.item.weapon:roll( ilvl )
                            else
                                item = core.lists.item.base_weapon:roll( ilvl )
                            end

                            if item then
                                entity:stash_item( item )
                            end
                        end
                    end
                end
            end
        ]],
        on_mortem = [[
            function( self, player, win )
                local depth = world.data.level[ world.data.current ].depth
                if depth > 14 then
                    world.award_badge( player, "badge_reload1" )
                end
                if win then
                    world.award_badge( player, "badge_reload2" )
                    if DIFFICULTY > 1 then
                        world.award_badge( player, "badge_reload3" )
                        if DIFFICULTY > 2 then
                            world.award_badge( player, "badge_reload4" )
                            if DIFFICULTY > 3 then
                                world.award_badge( player, "badge_reload5" )
                            end
                        end
                    end
                end
            end
        ]],
    },
}