/obj/item/syringe_cartridge
	name = "syringe gun cartridge"
	desc = "An impact-triggered compressed gas cartridge that can be fitted to a syringe for rapid injection."
	icon = 'icons/modules/projectiles/casings/syringe.dmi'
	icon_state = "syringe-cartridge"
	var/icon_flight = "syringe-cartridge-flight" //so it doesn't look so weird when shot
	materials_base = list(MAT_STEEL = 125, MAT_GLASS = 375)
	slot_flags = SLOT_BELT | SLOT_EARS
	throw_force = 3
	damage_force = 3
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/reagent_containers/syringe/syringe

/obj/item/syringe_cartridge/update_icon()
	underlays.Cut()
	if(syringe)
		underlays += image(syringe.icon, src, syringe.icon_state)
		underlays += syringe.filling

/obj/item/syringe_cartridge/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/syringe))
		if(!user.attempt_insert_item_for_installation(I, src))
			return
		syringe = I
		to_chat(user, "<span class='notice'>You carefully insert [syringe] into [src].</span>")
		damage_mode |= DAMAGE_MODE_SHARP
		name = "syringe dart"
		update_icon()

/obj/item/syringe_cartridge/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(syringe)
		to_chat(user, "<span class='notice'>You remove [syringe] from [src].</span>")
		playsound(src, 'sound/weapons/empty.ogg', 50, 1)
		user.grab_item_from_interacted_with(syringe, src)
		syringe = null
		damage_mode &= ~DAMAGE_MODE_SHARP
		name = initial(name)
		update_icon()

/obj/item/syringe_cartridge/proc/prime()
	//the icon state will revert back when update_icon() is called from throw_impact()
	icon_state = icon_flight
	underlays.Cut()

/obj/item/syringe_cartridge/throw_impact(atom/A, datum/thrownthing/TT)
	. = ..()
	if(syringe)
		//check speed to see if we hit hard enough to trigger the rapid injection
		//incidentally, this means syringe_cartridges can be used with the pneumatic launcher
		if(TT.speed >= 10 && isliving(A))
			var/mob/living/L = A
			//unfortuately we don't know where the dart will actually hit, since that's done by the parent.
			if(L.can_inject() && syringe.reagents)
				var/contained = syringe.reagents.get_reagents()
				var/trans = syringe.reagents.trans_to_mob(L, 15, CHEM_INJECT)
				add_attack_logs(TT.thrower,L,"Shot with [src.name] containing [contained], trasferred [trans] units")

		syringe.break_syringe(iscarbon(A)? A : null)
		syringe.update_icon()

	icon_state = initial(icon_state) //reset icon state
	update_icon()

/obj/item/gun/launcher/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, designed to incapacitate unruly patients from a distance."
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	materials_base = list(MAT_STEEL = 2000)
	damage_force = 7
	slot_flags = SLOT_BELT

	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"
	recoil = 0
	release_force = 10
	throw_distance = 10

	var/list/darts = list()
	var/max_darts = 1
	var/obj/item/syringe_cartridge/next

/obj/item/gun/launcher/syringe/consume_next_throwable(datum/gun_firing_cycle/cycle)
	if(next)
		next.prime()
		. = next
		darts -= next
		next = null
	else
		return GUN_FIRED_FAIL_EMPTY

/obj/item/gun/launcher/syringe/attack_self(mob/user, datum/event_args/actor/actor)
	. = ..()
	if(.)
		return
	if(next)
		user.visible_message("[user] unlatches and carefully relaxes the bolt on [src].", "<span class='warning'>You unlatch and carefully relax the bolt on [src], unloading the spring.</span>")
		next = null
	else if(darts.len)
		playsound(src.loc, 'sound/weapons/flipblade.ogg', 50, 1)
		user.visible_message("[user] draws back the bolt on [src], clicking it into place.", "<span class='warning'>You draw back the bolt on the [src], loading the spring!</span>")
		next = darts[1]
	add_fingerprint(user)

/obj/item/gun/launcher/syringe/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(user.get_inactive_held_item() == src)
		if(!darts.len)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return
		if(next)
			to_chat(user, "<span class='warning'>[src]'s cover is locked shut.</span>")
			return
		var/obj/item/syringe_cartridge/C = darts[1]
		darts -= C
		user.put_in_hands(C)
		user.visible_message("[user] removes \a [C] from [src].", "<span class='notice'>You remove \a [C] from [src].</span>")
		playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	else
		..()

/obj/item/gun/launcher/syringe/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/syringe_cartridge))
		var/obj/item/syringe_cartridge/C = A
		if(darts.len >= max_darts)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return
		if(!user.attempt_insert_item_for_installation(C, src))
			return
		darts += C //add to the end
		user.visible_message("[user] inserts \a [C] into [src].", "<span class='notice'>You insert \a [C] into [src].</span>")
	else
		..()

/obj/item/gun/launcher/syringe/rapid
	name = "syringe gun revolver"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to five syringes. The spring still needs to be drawn between shots."
	icon_state = "rapidsyringegun"
	item_state = "rapidsyringegun"
	max_darts = 5
