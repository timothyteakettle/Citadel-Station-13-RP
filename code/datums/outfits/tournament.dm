/datum/outfit/tournament_gear
	abstract_type = /datum/outfit/tournament_gear

	head = /obj/item/clothing/head/helmet/thunderdome
	suit = /obj/item/clothing/suit/armor/vest
	l_hand = /obj/item/material/knife
	r_hand = /obj/item/gun/projectile/energy/nt_pulse/rifle
	r_pocket = /obj/item/grenade/simple/smoke
	shoes = /obj/item/clothing/shoes/black

/datum/outfit/tournament_gear/red
	name = "Tournament - Red"
	uniform = /obj/item/clothing/under/color/red

/datum/outfit/tournament_gear/green
	name = "Tournament gear - Green"
	uniform = /obj/item/clothing/under/color/green

/datum/outfit/tournament_gear/gangster
	name = "Tournament gear - Gangster"
	head = /obj/item/clothing/head/det
	uniform = /obj/item/clothing/under/det
	suit_store = /obj/item/clothing/suit/storage/det_trench
	glasses = /obj/item/clothing/glasses/thermal/plain/monocle
	r_hand = /obj/item/gun/projectile/ballistic/revolver
	l_pocket = /obj/item/ammo_magazine/a357/speedloader

/datum/outfit/tournament_gear/chef
	name = "Tournament gear - Chef"
	head = /obj/item/clothing/head/chefhat
	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	r_hand = /obj/item/material/kitchen/rollingpin
	l_pocket = /obj/item/material/knife/tacknife
	r_pocket = /obj/item/material/knife/tacknife

/datum/outfit/tournament_gear/janitor
	name = "Tournament gear - Janitor"
	uniform = /obj/item/clothing/under/rank/janitor
	back = /obj/item/storage/backpack
	r_hand = /obj/item/mop
	l_hand = /obj/item/reagent_containers/glass/bucket
	l_pocket = /obj/item/grenade/simple/chemical/premade/cleaner
	r_pocket = /obj/item/grenade/simple/chemical/premade/cleaner
	backpack_contents = list(/obj/item/stack/tile/floor = 6)

/datum/outfit/tournament_gear/janitor/post_equip(var/mob/living/carbon/human/H)
	var/obj/item/reagent_containers/glass/bucket/bucket = locate(/obj/item/reagent_containers/glass/bucket) in H
	if(bucket)
		bucket.reagents.add_reagent(/datum/reagent/water, 70)
