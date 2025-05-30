/obj/structure/trash_pile
	name = "trash pile"
	desc = "A heap of garbage, but maybe there's something interesting inside?"
	icon = 'icons/obj/trash_piles.dmi'
	icon_state = "randompile"
	density = 1
	anchored = 1.0

	var/list/searchedby	= list()// Characters that have searched this trashpile, with values of searched time.
	var/mob/living/hider		// A simple animal that might be hiding in the pile

	var/obj/structure/mob_spawner/pest_nest/pest_nest = null

	var/chance_alpha	= 79	// Alpha list is junk items and normal random stuff.
	var/chance_beta		= 20	// Beta list is actually maybe some useful illegal items. If it's not alpha or gamma, it's beta.
	var/chance_gamma	= 1		// Gamma list is unique items only, and will only spawn one of each. This is a sub-chance of beta chance.

	//These are types that can only spawn once, and then will be removed from this list.
	//Alpha and beta lists are in their respective procs.
	var/global/list/unique_gamma = list(
		/obj/item/perfect_tele,
		/obj/item/bluespace_harpoon,
		/obj/item/clothing/glasses/thermal/syndi,
		/obj/item/gun/projectile/energy/netgun,
		/obj/item/gun/projectile/ballistic/pirate,
		/obj/item/clothing/accessory/permit/gun,
		/obj/item/gun/projectile/ballistic/dartgun
		)

	var/global/list/allocated_gamma = list()

/obj/structure/trash_pile/Initialize(mapload)
	. = ..()
	icon_state = pick(
		"pile1",
		"pile2",
		"pilechair",
		"piletable",
		"pilevending",
		"brtrashpile",
		"microwavepile",
		"rackpile",
		"boxfort",
		"trashbag",
		"brokecomp")
	if(prob(50))
		pest_nest = new(src)


/obj/structure/trash_pile/attackby(obj/item/W as obj, mob/user as mob)
	var/w_type = W.type
	if(w_type in allocated_gamma)
		if(!user.attempt_insert_item_for_installation(W, src))
			return
		to_chat(user,"<span class='notice'>You feel \the [W] slip from your hand, and disappear into the trash pile.</span>")
		allocated_gamma -= w_type
		unique_gamma += w_type
		qdel(W)

	else
		return ..()

/obj/structure/trash_pile/attack_generic(mob/user)
	//Simple Animal
	if(isanimal(user))
		var/mob/living/L = user
		//They're in it, and want to get out.
		if(L.loc == src)
			var/choice = alert("Do you want to exit \the [src]?","Un-Hide?","Exit","Stay")
			if(choice == "Exit")
				if(L == hider)
					hider = null
				L.forceMove(get_turf(src))
		else if(!hider)
			var/choice = alert("Do you want to hide in \the [src]?","Un-Hide?","Hide","Stay")
			if(choice == "Hide" && !hider) //Check again because PROMPT
				L.forceMove(src)
				hider = L
	else
		return ..()

/obj/structure/trash_pile/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	//Human mob
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.visible_message("[user] searches through \the [src].","<span class='notice'>You search through \the [src].</span>")
		if(hider)
			to_chat(hider,"<span class='warning'>[user] is searching the trash pile you're in!</span>")

		//Do the searching
		if(do_after(user,rand(4 SECONDS,6 SECONDS),src))

			//If there was a hider, chance to reveal them
			if(hider && prob(50))
				to_chat(hider,"<span class='danger'>You've been discovered!</span>")
				hider.forceMove(get_turf(src))
				hider = null
				to_chat(user,"<span class='danger'>Some sort of creature leaps out of \the [src]!</span>")

			//You already searched this one bruh
			else if(user.ckey in searchedby)
				to_chat(H,"<span class='warning'>There's nothing else for you in \the [src]!</span>")

			//You found an item!
			else
				var/luck = rand(1,100)
				var/obj/item/I
				if(luck <= chance_alpha)
					I = produce_alpha_item()
				else if(luck <= chance_alpha+chance_beta)
					I = produce_beta_item()
				else if(luck <= chance_alpha+chance_beta+chance_gamma)
					I = produce_gamma_item()

				//We either have an item to hand over or we don't, at this point!
				if(I)
					searchedby += user.ckey
					I.forceMove(get_turf(src))
					to_chat(H,"<span class='notice'>You found \a [I]!</span>")

	else
		return ..()

/obj/structure/trash_pile/proc/create_mob_spawner()
	if(!pest_nest)
		pest_nest = new(src)
	else
		debug_admins("[src] tried to create pest_nest when pest_nest already existsed([pest_nest])")

//Random lists
/obj/structure/trash_pile/proc/produce_alpha_item()
	var/path = pick(prob(5);/obj/item/clothing/gloves/rainbow,
					prob(5);/obj/item/clothing/gloves/white,
					prob(5);/obj/item/storage/backpack,
					prob(5);/obj/item/storage/backpack/satchel/norm,
					prob(5);/obj/item/storage/box,
				//	prob(5);/obj/random/cigarettes,
					prob(4);/obj/item/broken_device/random,
					prob(4);/obj/item/clothing/head/hardhat,
					prob(4);/obj/item/clothing/mask/breath,
					prob(4);/obj/item/clothing/shoes/black,
					prob(4);/obj/item/clothing/shoes/black,
					prob(4);/obj/item/clothing/shoes/laceup,
					prob(4);/obj/item/clothing/shoes/laceup/brown,
					prob(4);/obj/item/clothing/suit/storage/hazardvest,
					prob(4);/obj/item/clothing/under/color/grey,
					prob(4);/obj/item/caution,
					prob(4);/obj/item/cell,
					prob(4);/obj/item/cell/device,
					prob(4);/obj/item/reagent_containers/food/snacks/liquid,
					prob(4);/obj/item/spacecash/c1,
					prob(4);/obj/item/storage/backpack/satchel,
					prob(4);/obj/item/storage/briefcase,
					prob(3);/obj/item/clothing/accessory/storage/webbing,
					prob(3);/obj/item/clothing/glasses/meson,
					prob(3);/obj/item/clothing/gloves/botanic_leather,
					prob(3);/obj/item/clothing/head/hardhat/red,
					prob(3);/obj/item/clothing/mask/gas,
					prob(3);/obj/item/clothing/suit/storage/apron,
					prob(3);/obj/item/clothing/suit/storage/toggle/bomber,
					prob(3);/obj/item/clothing/suit/storage/toggle/brown_jacket,
					prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/black,
					prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/blue,
					prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/red,
					prob(3);/obj/item/clothing/suit/storage/toggle/hoodie/yellow,
					prob(3);/obj/item/clothing/suit/storage/toggle/leather_jacket,
					prob(3);/obj/item/pda,
					prob(3);/obj/item/radio/headset,
					prob(3);/obj/item/camera_assembly,
					prob(3);/obj/item/clothing/head/cone,
					prob(3);/obj/item/cell/high,
					prob(3);/obj/item/spacecash/c10,
					prob(3);/obj/item/spacecash/c20,
					prob(3);/obj/item/storage/backpack/dufflebag,
					prob(3);/obj/item/storage/box/donkpockets,
					prob(3);/obj/item/storage/box/mousetraps,
					prob(3);/obj/item/storage/wallet,
					prob(2);/obj/item/clothing/glasses/meson/prescription,
					prob(2);/obj/item/clothing/gloves/fyellow,
					prob(2);/obj/item/clothing/gloves/sterile/latex,
					prob(2);/obj/item/clothing/head/welding,
					prob(2);/obj/item/clothing/mask/gas/half,
					prob(2);/obj/item/clothing/shoes/galoshes,
					prob(2);/obj/item/clothing/under/pants/camo,
					prob(2);/obj/item/clothing/under/syndicate/tacticool,
					prob(2);/obj/item/camera,
					prob(2);/obj/item/flashlight/flare,
					prob(2);/obj/item/flashlight/glowstick,
					prob(2);/obj/item/flashlight/glowstick/blue,
					prob(2);/obj/item/card/emag_broken,
					prob(2);/obj/item/cell/super,
					prob(2);/obj/item/poster,
					prob(2);/obj/item/reagent_containers/glass/rag,
					prob(2);/obj/item/storage/box/sinpockets,
					prob(2);/obj/item/storage/secure/briefcase,
					prob(2);/obj/item/clothing/under/fluff/latexmaid,
					prob(1);/obj/item/clothing/glasses/sunglasses,
					prob(1);/obj/item/clothing/glasses/welding,
					prob(1);/obj/item/clothing/gloves/yellow,
					prob(1);/obj/item/clothing/head/bio_hood/general,
					prob(1);/obj/item/clothing/head/ushanka,
					prob(1);/obj/item/clothing/shoes/syndigaloshes,
					prob(1);/obj/item/clothing/suit/bio_suit/general,
					prob(1);/obj/item/clothing/suit/space/emergency,
					prob(1);/obj/item/clothing/under/gear_harness,
					prob(1);/obj/item/clothing/under/tactical,
					prob(1);/obj/item/clothing/suit/armor/material/makeshift,
					prob(1);/obj/item/flashlight/glowstick/orange,
					prob(1);/obj/item/flashlight/glowstick/red,
					prob(1);/obj/item/flashlight/glowstick/yellow,
					prob(1);/obj/item/flashlight/pen,
					prob(1);/obj/item/paicard,
					prob(1);/obj/item/card/emag,
					prob(1);/obj/item/clothing/mask/gas/voice,
					prob(1);/obj/item/spacecash/c100,
					prob(1);/obj/item/spacecash/c50,
					prob(1);/obj/item/storage/backpack/dufflebag/syndie,
					prob(1);/obj/item/storage/box/cups,
					prob(1);/obj/item/gun/projectile/energy/stripper,
					prob(1);/obj/item/pizzavoucher)

	var/obj/item/I = new path()
	return I

/obj/structure/trash_pile/proc/produce_beta_item()
	var/path = pick(prob(6);/obj/item/storage/pill_bottle/tramadol,
					prob(4);/obj/item/storage/pill_bottle/happy,
					prob(4);/obj/item/storage/pill_bottle/zoom,
					prob(4);/obj/item/gun/projectile/energy/sizegun,
					prob(4);/obj/item/gun/projectile/energy/stripper,
					prob(3);/obj/item/material/butterfly,
					prob(3);/obj/item/material/butterfly/switchblade,
					prob(3);/obj/item/clothing/gloves/knuckledusters,
					prob(3);/obj/item/reagent_containers/syringe/drugs,
					prob(2);/obj/item/storage/pill_bottle/citalopram, //happer pills
					prob(2);/obj/item/storage/pill_bottle/iron,
					prob(2);/obj/item/storage/pill_bottle/bicaridine,
					prob(2);/obj/item/storage/pill_bottle/antitox,
					prob(2);/obj/item/storage/pill_bottle/kelotane,
					prob(2);/obj/item/handcuffs/fuzzy,
					prob(2);/obj/item/storage/box/syndie_kit/spy,
					prob(2);/obj/item/grenade/simple/antiphoton,
					prob(1);/obj/item/nif/bad,
					prob(1);/obj/item/clothing/suit/storage/vest/heavy/merc,
					prob(1);/obj/item/clothing/head/helmet/medieval/crusader,
					prob(1);/obj/item/clothing/suit/armor/medieval/crusader/dark,
					prob(1);/obj/item/radio_jammer,
					// prob(1);/obj/item/sleevemate,
					// prob(1);/obj/item/bodysnatcher,
					prob(1);/obj/item/beartrap,
					prob(1);/obj/item/cell/hyper/empty,
					prob(1);/obj/item/disk/nifsoft/compliance,
					prob(1);/obj/item/material/knife/tacknife,
					prob(1);/obj/item/clothing/accessory/storage/brown_vest,
					prob(1);/obj/item/clothing/accessory/storage/black_vest,
					prob(1);/obj/item/clothing/accessory/storage/white_vest,
					prob(1);/obj/item/reagent_containers/syringe/steroid)

	var/obj/item/I = new path()
	return I

/obj/structure/trash_pile/proc/produce_gamma_item()
	var/path = pick_n_take(unique_gamma)
	if(!path) //Tapped out, reallocate?
		for(var/P in allocated_gamma)
			var/obj/item/I = allocated_gamma[P]
			if(QDELETED(I) || istype(I.loc,/obj/machinery/computer/cryopod))
				allocated_gamma -= P
				path = P
				break

	if(path)
		var/obj/item/I = new path()
		allocated_gamma[path] = I
		return I
	else
		return produce_beta_item()

/obj/structure/mob_spawner/pest_nest
	name = "trash"
	desc = "A small heap of trash, perfect for vermin to nest in."
	icon = 'icons/obj/trash_piles.dmi'
	icon_state = "randompile"
	spawn_types = list(/mob/living/simple_mob/animal/passive/mouse)
	simultaneous_spawns = 1
	spawn_delay = 1 HOUR

/obj/structure/mob_spawner/pest_nest/Initialize(mapload)
	. = ..()
	last_spawn = rand(world.time - spawn_delay, world.time)
	icon_state = pick(
		"pile1",
		"pile2",
		"pilechair",
		"piletable",
		"pilevending",
		"brtrashpile",
		"microwavepile",
		"rackpile",
		"boxfort",
		"trashbag",
		"brokecomp")

/obj/structure/mob_spawner/pest_nest/do_spawn(var/mob_path)
	. = ..()
	var/atom/A = get_holder_at_turf_level(src)
	A.visible_message("[.] crawls out of \the [src].")

/obj/structure/mob_spawner/pest_nest/get_death_report(var/mob/living/L)
	..()
	last_spawn = rand(world.time - spawn_delay, world.time)
