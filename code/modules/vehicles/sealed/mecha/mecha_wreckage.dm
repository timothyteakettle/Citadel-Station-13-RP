///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/effect/decal/mecha_wreckage
	name = "Exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable."
	icon = 'icons/mecha/mecha.dmi'
	density = 1
	anchored = 0
	opacity = 0
	var/list/welder_salvage = list(/obj/item/stack/material/plasteel,/obj/item/stack/material/steel,/obj/item/stack/rods)
	var/list/wirecutters_salvage = list(/obj/item/stack/cable_coil)
	var/list/crowbar_salvage
	var/salvage_num = 5

/obj/effect/decal/mecha_wreckage/New()
	..()
	crowbar_salvage = new
	return

/obj/effect/decal/mecha_wreckage/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weldingtool))
		var/obj/item/weldingtool/WT = W
		if(salvage_num <= 0)
			to_chat(user, "You don't see anything that can be cut with [W].")
			return
		if (!!length(welder_salvage) && WT.remove_fuel(0,user))
			var/type = prob(70)?pick(welder_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src]", "You cut [N] from [src]", "You hear a sound of welder nearby")
				if(istype(N, /obj/item/vehicle_part))
					welder_salvage -= type
				salvage_num--
			else
				to_chat(user, "You failed to salvage anything valuable from [src].")
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
	if(W.is_wirecutter())
		if(salvage_num <= 0)
			to_chat(user, "You don't see anything that can be cut with [W].")
			return
		else if(!!length(wirecutters_salvage))
			var/type = prob(70)?pick(wirecutters_salvage):null
			if(type)
				var/N = new type(get_turf(user))
				user.visible_message("[user] cuts [N] from [src].", "You cut [N] from [src].")
				salvage_num--
			else
				to_chat(user, "You failed to salvage anything valuable from [src].")
	if(W.is_crowbar())
		if(!!length(crowbar_salvage))
			var/obj/S = pick(crowbar_salvage)
			if(S)
				S.loc = get_turf(user)
				crowbar_salvage -= S
				user.visible_message("[user] pries [S] from [src].", "You pry [S] from [src].")
			return
		else
			to_chat(user, "You don't see anything that can be pried with [W].")
	else
		..()
	return


/obj/effect/decal/mecha_wreckage/gygax
	name = "Gygax wreckage"
	icon_state = "gygax-broken"

/obj/effect/decal/mecha_wreckage/gygax/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/gygax_torso,
		/obj/item/vehicle_part/gygax_head,
		/obj/item/vehicle_part/gygax_left_arm,
		/obj/item/vehicle_part/gygax_right_arm,
		/obj/item/vehicle_part/gygax_left_leg,
		/obj/item/vehicle_part/gygax_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/gygax/dark
	name = "Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/effect/decal/mecha_wreckage/gygax/adv
	name = "Gygax wreckage"
	icon_state = "gygax_adv-broken"

/obj/effect/decal/mecha_wreckage/gygax/dark_adv
	name = "Advanced Dark Gygax wreckage"
	icon_state = "darkgygax_adv-broken"

/obj/effect/decal/mecha_wreckage/gygax/medgax
	name = "Medgax wreckage"
	icon_state = "medgax-broken"

/obj/effect/decal/mecha_wreckage/gygax/serenity
	name = "Serenity wreckage"
	icon_state = "medgax-broken"

/obj/effect/decal/mecha_wreckage/marauder
	name = "Marauder wreckage"
	icon_state = "marauder-broken"

/obj/effect/decal/mecha_wreckage/mauler
	name = "Mauler Wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/effect/decal/mecha_wreckage/seraph
	name = "Seraph wreckage"
	icon_state = "seraph-broken"

/obj/effect/decal/mecha_wreckage/ripley
	name = "Ripley wreckage"
	icon_state = "ripley-broken"

/obj/effect/decal/mecha_wreckage/ripley/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/ripley_torso,
		/obj/item/vehicle_part/ripley_left_arm,
		/obj/item/vehicle_part/ripley_right_arm,
		/obj/item/vehicle_part/ripley_left_leg,
		/obj/item/vehicle_part/ripley_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/ripley/firefighter
	name = "Firefighter wreckage"
	icon_state = "firefighter-broken"

/obj/effect/decal/mecha_wreckage/ripley/firefighter/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/ripley_torso,
		/obj/item/vehicle_part/ripley_left_arm,
		/obj/item/vehicle_part/ripley_right_arm,
		/obj/item/vehicle_part/ripley_left_leg,
		/obj/item/vehicle_part/ripley_right_leg,
		/obj/item/clothing/suit/fire,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/ripley/geiger
	name = "Lightweight APLU wreckage"
	icon_state = "ripley-broken-old"

/obj/effect/decal/mecha_wreckage/ripley/geiger/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/geiger_torso,
		/obj/item/vehicle_part/ripley_left_arm,
		/obj/item/vehicle_part/ripley_right_arm,
		/obj/item/vehicle_part/ripley_left_leg,
		/obj/item/vehicle_part/ripley_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return


/obj/effect/decal/mecha_wreckage/ripley/deathripley
	name = "Death-Ripley wreckage"
	icon_state = "deathripley-broken"

/obj/effect/decal/mecha_wreckage/durand
	name = "Durand wreckage"
	icon_state = "durand-broken"

/obj/effect/decal/mecha_wreckage/durand/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/durand_torso,
		/obj/item/vehicle_part/durand_head,
		/obj/item/vehicle_part/durand_left_arm,
		/obj/item/vehicle_part/durand_right_arm,
		/obj/item/vehicle_part/durand_left_leg,
		/obj/item/vehicle_part/durand_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/phazon
	name = "Phazon wreckage"
	icon_state = "phazon-broken"


/obj/effect/decal/mecha_wreckage/odysseus
	name = "Odysseus wreckage"
	icon_state = "odysseus-broken"

/obj/effect/decal/mecha_wreckage/odysseus/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/odysseus_torso,
		/obj/item/vehicle_part/odysseus_head,
		/obj/item/vehicle_part/odysseus_left_arm,
		/obj/item/vehicle_part/odysseus_right_arm,
		/obj/item/vehicle_part/odysseus_left_leg,
		/obj/item/vehicle_part/odysseus_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/odysseus/murdysseus
	icon_state = "murdysseus-broken"

/obj/effect/decal/mecha_wreckage/hoverpod
	name = "Hover pod wreckage"
	icon_state = "engineering_pod-broken"

/obj/effect/decal/mecha_wreckage/janus
	name = "Janus wreckage"
	icon_state = "janus-broken"
	description_info = "Due to the incredibly intricate design of this exosuit, it is impossible to salvage components from it."

/obj/effect/decal/mecha_wreckage/shuttlecraft
	name = "Shuttlecraft wreckage"
	desc = "Remains of some unfortunate shuttlecraft. Completely unrepairable."
	icon = 'icons/mecha/mecha64x64.dmi'
	icon_state = "shuttle_standard-broken"
	bound_width = 64
	bound_height = 64

// Honker
/obj/effect/decal/mecha_wreckage/honker
	name = "H.O.N.K. wreckage"
	icon_state = "honker-broken"

/obj/effect/decal/mecha_wreckage/honker/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/honker_torso,
		/obj/item/vehicle_part/honker_head,
		/obj/item/vehicle_part/honker_left_arm,
		/obj/item/vehicle_part/honker_right_arm,
		/obj/item/vehicle_part/honker_left_leg,
		/obj/item/vehicle_part/honker_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/honker/cluwne
	name = "C.L.W.U.N.E. wreckage"
	icon = 'icons/mecha/mecha_vr.dmi'
	icon_state = "cluwne-broken"

// Reticent
/obj/effect/decal/mecha_wreckage/reticent
	name = "Reticent wreckage"
	icon_state = "reticent-broken"

/obj/effect/decal/mecha_wreckage/reticent/New()
	..()
	var/list/parts = list(
		/obj/item/vehicle_part/reticent_torso,
		/obj/item/vehicle_part/reticent_head,
		/obj/item/vehicle_part/reticent_left_arm,
		/obj/item/vehicle_part/reticent_right_arm,
		/obj/item/vehicle_part/reticent_left_leg,
		/obj/item/vehicle_part/reticent_right_leg,
	)
	for(var/i=0;i<2;i++)
		if(!!length(parts) && prob(40))
			var/part = pick(parts)
			welder_salvage += part
			parts -= part
	return

/obj/effect/decal/mecha_wreckage/reticent/reticence
	name = "Reticence wreckage"
	icon_state = "reticence-broken"
