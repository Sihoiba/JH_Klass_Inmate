register_sound "vo_no_rage"
{
    group = "voice",
    tags  = {"silly"},
    sub   = "Can't.",
    "data/sound/vo/cooldown/cooldown_short_03.wav",
    "data/sound/vo/cooldown/cooldown_short_04.wav",
}

register_sound "vo_no_rage_high"
{
    group = "voice",
    sub   = "Yeah, right.",
    tags  = {"silly"},
    "data/sound/vo/unusable/unusable_01.wav",
    "data/sound/vo/unusable/unusable_02.wav",
}

register_sound "vo_no_rage_serious"
{
    group = "voice",
    sub   = "I can't do that.",
    tags  = { "serious", },
    "data/sound/vo/cooldown/cooldown_serious_01.wav",
    "data/sound/vo/cooldown/cooldown_serious_02.wav",
    "data/sound/vo/cooldown/cooldown_serious_03.wav",
}

register_styler "voice_inmate"
{
	vo_no_rage = { "vo_no_rage", "vo_no_rage_serious", },
	repeat_vo_no_rage = { "vo_no_rage_high", "vo_no_rage_serious", },
}