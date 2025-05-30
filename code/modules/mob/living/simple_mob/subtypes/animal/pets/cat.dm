/datum/category_item/catalogue/fauna/cat
	name = "Cat"
	desc = "Felines are a popular domestic animal hailing from Earth. \
	Sharing common ancestry with Earth's 'big cats', the housecats retain \
	much of those primitive instincts. Although generally docile around \
	their owners and larger creatures, cats are frequently employed for pest \
	control on interstellar facilities. They are a popular subject for photography \
	and film on the Exonet."
	value = CATALOGUER_REWARD_TRIVIAL

/mob/living/simple_mob/animal/passive/cat
	name = "cat"
	desc = "A domesticated, feline pet. Has a tendency to adopt crewmembers."
	tt_desc = "E Felis silvestris catus"
	icon_state = "cat2"
	item_state = "cat2"
	catalogue_data = list(/datum/category_item/catalogue/fauna/cat)

	movement_base_speed = 10 / 0.5 SECONDS

	randomized = TRUE

	see_in_dark = 6 // Not sure if this actually works.
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"

	holder_type = /obj/item/holder/cat
	mob_size = MOB_SMALL

	has_langs = list("Cat")

	var/mob/living/friend = null // Our best pal, who we'll follow. Meow.
	var/named = FALSE //have I been named yet?
	var/friend_name = null // Lock befriending to this character

	meat_amount = 2
	bone_amount = 2
	hide_amount = 5
	hide_type = /obj/item/stack/animalhide/cat

/mob/living/simple_mob/animal/passive/cat/Initialize(mapload)
	icon_living = "[initial(icon_state)]"
	icon_dead = "[initial(icon_state)]_dead"
	icon_rest = "[initial(icon_state)]_rest"
	update_icon()
	return ..()

/mob/living/simple_mob/animal/passive/cat/handle_special()
	if(!stat && prob(2)) // spooky
		var/mob/observer/dead/spook = locate() in range(src, 5)
		if(spook)
			var/turf/T = get_turf(spook)
			var/list/visible = list()
			for(var/obj/O in T.contents)
				if(!O.invisibility && O.name)
					visible += O
			if(visible.len)
				var/atom/A = pick(visible)
				visible_emote("suddenly stops and stares at something unseen[istype(A) ? " near [A]":""].")

// Instakills mice.
/mob/living/simple_mob/animal/passive/cat/apply_melee_effects(var/atom/A)
	if(ismouse(A))
		var/mob/living/simple_mob/animal/passive/mouse/mouse = A
		if(mouse.getMaxHealth() < 20) // In case a badmin makes giant mice or something.
			mouse.splat()
			visible_emote(pick("bites \the [mouse]!", "toys with \the [mouse].", "chomps on \the [mouse]!"))
	else
		..()

/mob/living/simple_mob/animal/passive/cat/IIsAlly(mob/living/L)
	if(L == friend) // Always be pals with our special friend.
		return TRUE

	. = ..()

	if(.) // We're pals, but they might be a dirty mouse...
		if(ismouse(L))
			return FALSE // Cats and mice can never get along.

/mob/living/simple_mob/animal/passive/cat/verb/become_friends()
	set name = "Become Friends"
	set category = VERB_CATEGORY_IC
	set src in view(1)

	var/mob/living/L = usr
	if(!istype(L))
		return // Fuck off ghosts.

	if(friend)
		if(friend == usr)
			to_chat(L, SPAN_NOTICE("\The [src] is already your friend! Meow!"))
			return
		else
			to_chat(L, SPAN_WARNING( "\The [src] ignores you."))
			return

	// friend_name var checks
	if(!friend_name || L.real_name == friend_name)
		friend = L
		face_atom(L)
		to_chat(L, SPAN_NOTICE("\The [src] is now your friend! Meow."))
		visible_emote(pick("nuzzles [friend].", "brushes against [friend].", "rubs against [friend].", "purrs."))

		if(has_polaris_AI())
			var/datum/ai_holder/polaris/AI = ai_holder
			AI.set_follow(friend)
	else
		to_chat(L, SPAN_NOTICE("[src] ignores you."))


/mob/living/simple_mob/animal/passive/cat/runtime
	name = "Runtime"
	desc = "Her fur has the look and feel of velvet, and her tail quivers occasionally."
	tt_desc = "E Felis silvestris medicalis" // a hypoallergenic breed produced by NT for... medical purposes? Sure.
	gender = FEMALE
	icon_state = "cat"
	item_state = "cat"
	named = TRUE
	makes_dirt = 0
	randomized = FALSE

/mob/living/simple_mob/animal/passive/cat/kitten
	name = "kitten"
	desc = "D'aaawwww!"
	icon_state = "kitten"
	item_state = "kitten"
	gender = NEUTER
	holder_type = /obj/item/holder/cat/kitten

/mob/living/simple_mob/animal/passive/cat/kitten/Initialize(mapload)
	if(gender == NEUTER)
		gender = pick(MALE, FEMALE)
	return ..()

/mob/living/simple_mob/animal/passive/cat/black
	icon_state = "cat"
	item_state = "cat"

// Leaving this here for now.
/obj/item/holder/cat/fluff/bones
	name = "Bones"
	desc = "It's Bones! Meow."
	gender = MALE
	icon_state = "cat3"

/mob/living/simple_mob/animal/passive/cat/bones
	name = "Bones"
	desc = "That's Bones the cat. He's a laid back, black cat. Meow."
	gender = MALE
	icon_state = "cat3"
	item_state = "cat3"
	named = TRUE
	holder_type = /obj/item/holder/cat/fluff/bones
	randomized = FALSE

/// Tactical kittens!
/obj/item/holder/cat/kitten
	icon_state = "kitten"
	w_class = WEIGHT_CLASS_SMALL

/datum/say_list/cat
	speak = list("Meow!","Esp!","Purr!","HSSSSS")
	emote_hear = list("meows","mews")
	emote_see = list("shakes their head", "shivers")
	say_maybe_target = list("Meow?","Mew?","Mao?")
	say_got_target = list("MEOW!","HSSSS!","REEER!")

/mob/living/simple_mob/animal/passive/cat/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/flashlight/pen))
		if(named)
			to_chat(user, "<span class='notice'>\the [name] already has a name!</span>")
		else
			var/tmp_name = sanitizeSafe(input(user, "Give \the [name] a name", "Name"), MAX_NAME_LEN)
			if(length(tmp_name) > 50)
				to_chat(user, "<span class='notice'>The name can be at most 50 characters long.</span>")
			else
				to_chat(user, "<span class='notice'>You name \the [name]. Meow!</span>")
				name = tmp_name
				named = TRUE
	else
		..()

/obj/item/cat_box
	name = "faintly purring box"
	desc = "This box is purring faintly. You're pretty sure there's a cat inside it."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box"
	var/cattype = /mob/living/simple_mob/animal/passive/cat

/obj/item/cat_box/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	var/turf/catturf = get_turf(src)
	to_chat(user, "<span class='notice'>You peek into \the [name]-- and a cat jumps out!</span>")
	new cattype(catturf)
	new /obj/item/stack/material/cardboard(catturf) //if i fits i sits
	qdel(src)

/obj/item/cat_box/black
	cattype = /mob/living/simple_mob/animal/passive/cat/black
