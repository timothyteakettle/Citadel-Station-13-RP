/datum/category_item/catalogue/fauna/redpanda
	name = "Red Panda"
	desc = "Red Pandas are sometimes imported to the Frontier from \
	exotic pet brokers in Orion space. Popular among collectors due \
	to their coloration, patterning, and generally adorable appearance, \
	the Red Panda is a popular pet and status symbol rolled into one."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/simple_mob/vore/redpanda
	name = "red panda"
	desc = "It's a wah! Beware of doom pounce!"
	tt_desc = "Ailurus fulgens"
	catalogue_data = list(/datum/category_item/catalogue/fauna/redpanda)

	icon_state = "wah"
	icon_living = "wah"
	icon_dead = "wah_dead"
	icon_rest = "wah_rest"
	icon = 'icons/mob/vore.dmi'

	faction = "redpanda" //stop naming stuff vaguely
	maxHealth = 30
	health = 30
	randomized = TRUE

	response_help = "pats the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"

	harm_intent_damage = 3
	legacy_melee_damage_lower = 3
	legacy_melee_damage_upper = 1
	attacktext = list("bapped")

	say_list_type = /datum/say_list/redpanda
	ai_holder_type = /datum/ai_holder/polaris/simple_mob/passive

// Activate Noms!
/mob/living/simple_mob/vore/redpanda
	vore_active = 1
	vore_bump_chance = 10
	vore_bump_emote	= "playfully lunges at"
	vore_pounce_chance = 40
	vore_default_mode = DM_HOLD // above will only matter if someone toggles it anyway
	vore_icons = SA_ICON_LIVING

/mob/living/simple_mob/vore/redpanda/fae
	name = "dark wah"
	desc = "Ominous, but still cute!"
	tt_desc = "Ailurus brattus"

	icon_state = "wah_fae"
	icon_living = "wah_fae"
	icon_dead = "wah_fae_dead"
	icon_rest = "wah_fae_rest"

	vore_ignores_undigestable = 0	// wah don't care you're edible or not, you still go in
	vore_digest_chance = 0			// instead of digesting if you struggle...
	vore_absorb_chance = 20			// you get to become adorable purple wahpudge.
	vore_bump_chance = 75
	maxHealth = 100
	health = 100
	legacy_melee_damage_lower = 10
	legacy_melee_damage_upper = 20

/datum/say_list/redpanda
	speak = list("Wah!","Wah?","Waaaah.")
	emote_hear = list("wahs!","chitters.")
	emote_see = list("trundles around","rears up onto their hind legs and pounces a bug")
