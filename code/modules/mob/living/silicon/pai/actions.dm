/datum/action/pai
	button_icon = 'icons/screen/actions/pai.dmi'
	var/update_on_grant = FALSE

/// Toggle unfolding/collapsing chassis
/datum/action/pai/toggle_fold
	name = "Unfold Chassis"
	desc = "Unfold Chassis"
	button_icon_state = "pai_open"
	update_on_grant = TRUE

/datum/action/pai/toggle_fold/update_button()
	var/mob/living/silicon/pai/user = owner
	if(!istype(user))
		return

	if(user.loc == user.shell)
		name = "Unfold Chassis"
		desc = "Unfold Chassis"
		button_icon = initial(button_icon)
		button_icon_state = initial(button_icon_state)
	else
		name = "Collapse Chassis"
		desc = "Collapse Chassis"
		button_icon = user.icon
		button_icon_state = user.chassis

	..()

/datum/action/pai/toggle_fold/on_trigger(mob/living/silicon/pai/user)
	if(user.loc == user.shell)
		user.open_up_safe()
	else
		user.close_up_safe()

	update_button()

/// Change chassis
/datum/action/pai/change_chassis
	name = "Change Chassis"
	desc = "Select a different chassis"
	button_icon_state = "pai_chassis_change"

/datum/action/pai/change_chassis/on_trigger(mob/living/silicon/pai/user)
	user.update_chassis()

/// Revert to card
/// This only shows if your shell is not currently the card, otherwise this action is hidden
/datum/action/pai/revert_to_card
	name = "Revert To Card"
	desc = "Revert your shell back to card-form"
	button_icon_state = "pai_shell_revert"

/datum/action/pai/revert_to_card/on_trigger(mob/living/silicon/pai/user)
	user.revert_to_card()

/// Clothing Transform
/datum/action/pai/clothing_transform
	name = "Clothing Transform"
	desc = "Change shell to clothing form"
	button_icon_state = "pai_clothing"

/datum/action/pai/clothing_transform/on_trigger(mob/living/silicon/pai/user)
	user.change_to_clothing()

/// Hologram Display (show scanned object from card form)
/// This only shows if you are in card form, otherwise this action is hidden
/datum/action/pai/hologram_display
	name = "Hologram Display"
	desc = "Display a scanned object as a hologram"
	button_icon_state = "pai_hologram_display"

/datum/action/pai/hologram_display/on_trigger(mob/living/silicon/pai/user)
	user.card_hologram_display()