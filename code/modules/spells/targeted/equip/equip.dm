//You can set duration to 0 to have the items last forever

/spell/targeted/equip_item
	name = "equipment spell"

	var/list/equipped_summons = list() //assoc list of text ids and paths to spawn

	var/list/summoned_items = list() //list of items we summoned and will dispose when the spell runs out

	var/delete_old = 1 //if the item previously in the slot is deleted - otherwise, it's dropped

/spell/targeted/equip_item/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/L in targets)
		for(var/slot_id in equipped_summons)
			var/to_create = equipped_summons[slot_id]
			slot_id = text2num(slot_id) //because the index is text, we access this instead
			var/obj/item/new_item = summon_item(to_create)
			var/obj/item/old_item = L.item_by_slot_id(slot_id)
			if(old_item)
				if(delete_old)
					qdel(old_item)
				else
					L.drop_item_to_ground(old_item)
			L.equip_to_slot_or_del(new_item, slot_id)
			if(duration)
				summoned_items += new_item //we store it in a list to remove later

	if(duration)
		spawn(duration)
			for(var/obj/item/to_remove in summoned_items)
				qdel(to_remove)

/spell/targeted/equip_item/proc/summon_item(var/newtype)
	return new newtype
