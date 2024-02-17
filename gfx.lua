nova.require "data/lua/gfx/common"
nova.require "data/lua/jh/gfx/entities/human"
nova.require "data/lua/jh/gfx/entities/security"

register_gfx_blueprint "player_inmate_head_part"
{
	skeleton = "data/model/player_male_mesh.nmd",
	{
		tag = "head",
		render = {
			mesh     = "data/model/player_male_mesh.nmd:player_head_01",
			material = "data/texture/player/male/body_01/A/player_head_01",
		},
	},
	{
		tag = "head",
		attach = "RigHead",
		render = {
			mesh = "data/model/security_mesh.nmd:security_hair_01",
			material = "data/texture/security/A/security_hair_A",
		},
	},
}

register_gfx_blueprint "player_inmate"
{
	blueprint = "player",
	slot_base = {
		{ target    = "armor", blueprint = "armor_shirt_01_A_part", },
		{ target    = "head",  blueprint = "player_marine_head_part", },
	},
	{
		tag = "head",
		render = {
			mesh     = "data/model/player_male_mesh.nmd:player_head_01",
			material = "data/texture/player/male/body_01/A/player_head_01",
		},
	},
	{
		render = {
			mesh = "data/model/player_male_mesh.nmd:shoes_01",
			material = "data/texture/player/male/shoes_01/A/shoes_01_A",
		},
	},
	{
		tag    = "armor",
		render = {
			mesh = "data/model/player_male_mesh.nmd:player_trousers_01",
			material = "data/texture/player/male/trousers_01/B/trousers_01_B",
		},
	},
	{
		tag = "head",
		attach = "RigHead",
		render = {
			mesh = "data/model/security_mesh.nmd:security_hair_01",
			material = "data/texture/security/A/security_hair_A",
		},
	},
	{
		tag    = "armor",
		render = {
			mesh     = "data/model/player_male_mesh.nmd:player_body",
			material = "data/texture/security/suicider/security_suicider_body_01_A",
		},
	},

}