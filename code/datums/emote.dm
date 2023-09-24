/datum/emote
	var/list/keys /// What calls the emote, any item in the list is accepted
	var/message /// What shows wen the emote is successfully ran
	var/mobility_required /// Mobility flags required to use this emote
	var/emote_type = EMOTE_VISIBLE
	var/biology_required /// What biology is required to use the emote, defaults to null which means any mob type can use the emote
