nova.require "data/lua/core/common"

register_blueprint "exalted_tracker"
{
    flags = { EF_NOPICKUP, },
    minimap = {
        color    = tcolor( LIGHTMAGENTA, 255, 128, 255 ),
        priority = 110,
    },
    callbacks = {
        on_die = [[
            function ( self )
                world:mark_destroy( self )
            end
        ]],
    },
}