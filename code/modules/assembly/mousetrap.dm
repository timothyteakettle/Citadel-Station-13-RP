/obj/item/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	origin_tech = list(TECH_COMBAT = 1)
	materials_base = list(MAT_STEEL = 100)
	var/armed = 0


/obj/item/assembly/mousetrap/examine(var/mob/user)
	. = ..()
	if(armed)
		. += "It looks like it's armed."

/obj/item/assembly/mousetrap/update_icon()
	if(armed)
		icon_state = "mousetraparmed"
	else
		icon_state = "mousetrap"
	if(holder)
		holder.update_icon()

/obj/item/assembly/mousetrap/proc/triggered(var/mob/target, var/type = "feet")
	if(!armed)
		return
	var/obj/item/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_organ(pick("l_leg", "r_leg"))
					H.afflict_paralyze(20 * 3)
			if("l_hand", "r_hand")
				if(!H.gloves)
					affecting = H.get_organ(type)
					H.afflict_stun(20 * 3)
		affecting?.inflict_bodypart_damage(
			brute = 1,
		)
	else if(ismouse(target))
		var/mob/living/simple_mob/animal/passive/mouse/M = target
		visible_message("<font color='red'><b>SPLAT!</b></font>")
		M.splat()
	playsound(target.loc, 'sound/effects/snap.ogg', 50, 1)
	layer = MOB_LAYER - 0.2
	armed = 0
	update_icon()
	pulse(0)

/obj/item/assembly/mousetrap/attack_self(mob/user, datum/event_args/actor/actor)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		if((MUTATION_CLUMSY in user.mutations) && prob(50))
			var/which_hand = "l_hand"
			var/mob/living/carbon/human/H = ishuman(user)? user : null
			if(!(H?.active_hand % 2))
				which_hand = "r_hand"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return

		to_chat(user, "<span class='notice'>You disarm [src].</span>")
	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)


/obj/item/assembly/mousetrap/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	var/mob/living/L = user
	if(!istype(L))
		return
	if(armed)
		if((MUTATION_CLUMSY in user.mutations) && prob(50))
			var/which_hand = user.active_hand % 2? "l_hand" : "r_hand"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()


/obj/item/assembly/mousetrap/Crossed(var/atom/movable/AM)
	if(AM.is_incorporeal() || AM.is_avoiding_ground())
		return
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == "run")
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
								  "<span class='warning'>You accidentally step on [src]</span>")
		if(ismouse(AM))
			triggered(AM)
	..()

/obj/item/assembly/mousetrap/on_containing_storage_opening(datum/event_args/actor/actor, datum/object_system/storage/storage)
	. = ..()

	var/mob/living/finder = actor.performer
	if(!istype(finder))
		return
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
							   "<span class='warning'>You accidentally trigger [src]!</span>")
		triggered(finder, finder.active_hand % 2? "l_hand" : "r_hand")
		return 1	//end the search!
	return 0

/obj/item/assembly/mousetrap/throw_impacted(atom/movable/AM, datum/thrownthing/TT)
	. = ..()
	if(!armed)
		return
	visible_message("<span class='warning'>[src] is triggered by [AM].</span>")
	triggered(null)

/obj/item/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1

/obj/item/assembly/mousetrap/verb/hide_under()
	set src in oview(1)
	set name = "Hide"
	set category = VERB_CATEGORY_OBJECT

	if(usr.stat)
		return

	layer = HIDING_LAYER
	to_chat(usr, "<span class='notice'>You hide [src].</span>")
