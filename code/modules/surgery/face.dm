//Procedures in this file: Facial reconstruction surgery
//////////////////////////////////////////////////////////////////
//						FACE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/face
	priority = 2
	req_open = 0
	can_infect = 0

/datum/surgery_step/face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..()) return FALSE
	if (!hasorgans(target))
		return 0
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if (!affected || (affected.robotic >= ORGAN_ROBOT))
		return 0
	return target_zone == O_MOUTH

///////////////////////////////////////////////////////////////
// Face Opening Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/generic/cut_face
	step_name = "Cut face"

	allowed_tools = list(
	/obj/item/surgical/scalpel = 100,		\
	/obj/item/surgical/scalpel_primitive = 80,	\
	/obj/item/surgical/scalpel_bronze = 90,	\
	/obj/item/material/knife = 75,	\
	/obj/item/material/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/generic/cut_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == O_MOUTH && target.op_stage.face == 0

/datum/surgery_step/generic/cut_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to cut open [target]'s face and neck with \the [tool].", \
	"You start to cut open [target]'s face and neck with \the [tool].")
	..()

/datum/surgery_step/generic/cut_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] has cut open [target]'s face and neck with \the [tool].</font>" , \
	"<font color=#4F49AF> You have cut open[target]'s face and neck with \the [tool].</font>",)
	target.op_stage.face = 1

/datum/surgery_step/generic/cut_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, slicing [target]'s throat wth \the [tool]!</font>" , \
	"<font color='red'>Your hand slips, slicing [target]'s throat wth \the [tool]!</font>" )
	affected.create_wound(WOUND_TYPE_CUT, 60)
	target.AdjustLosebreath(10)

///////////////////////////////////////////////////////////////
// Vocal Cord/Face Repair Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/face/mend_vocal
	step_name = "Fix vocal cords"

	allowed_tools = list(
	/obj/item/surgical/hemostat = 100, 	\
	/obj/item/stack/cable_coil = 75, 	\
	/obj/item/surgical/hemostat_primitive = 50,	\
	/obj/item/assembly/mousetrap = 10	//I don't know. Don't ask me. But I'm leaving it because hilarity.
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/face/mend_vocal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 1

/datum/surgery_step/face/mend_vocal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending [target]'s vocal cords with \the [tool].", \
	"You start mending [target]'s vocal cords with \the [tool].")
	..()

/datum/surgery_step/face/mend_vocal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] mends [target]'s vocal cords with \the [tool].</font>", \
	"<font color=#4F49AF>You mend [target]'s vocal cords with \the [tool].</font>")
	target.op_stage.face = 2

/datum/surgery_step/face/mend_vocal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color='red'>[user]'s hand slips, clamping [target]'s trachea shut for a moment with \the [tool]!</font>", \
	"<font color='red'>Your hand slips, clamping [user]'s trachea shut for a moment with \the [tool]!</font>")
	target.AdjustLosebreath(10)

///////////////////////////////////////////////////////////////
// Face Fixing Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/face/fix_face
	step_name = "Fix face"

	allowed_tools = list(
		/obj/item/surgical/retractor = 100, 	\
		/obj/item/surgical/retractor_primitive = 75,	\
		/obj/item/material/kitchen/utensil/fork = 75
	)

	allowed_procs = list(IS_CROWBAR = 55)

	min_duration = 80
	max_duration = 100

/datum/surgery_step/face/fix_face/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 2

/datum/surgery_step/face/fix_face/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts pulling the skin on [target]'s face back in place with \the [tool].", \
	"You start pulling the skin on [target]'s face back in place with \the [tool].")
	..()

/datum/surgery_step/face/fix_face/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] pulls the skin on [target]'s face back in place with \the [tool].</font>",	\
	"<font color=#4F49AF>You pull the skin on [target]'s face back in place with \the [tool].</font>")
	target.op_stage.face = 3

/datum/surgery_step/face/fix_face/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, tearing skin on [target]'s face with \the [tool]!</font>", \
	"<font color='red'>Your hand slips, tearing skin on [target]'s face with \the [tool]!</font>")
	target.apply_damage(10, DAMAGE_TYPE_BRUTE, affected, sharp=1, sharp=1)

///////////////////////////////////////////////////////////////
// Face Cauterizing Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/face/cauterize
	step_name = "Cauterize"

	allowed_tools = list(
	/obj/item/surgical/cautery = 100,			\
	/obj/item/clothing/mask/smokable/cigarette = 75,	\
	/obj/item/surgical/cautery_primitive = 70,	\
	/obj/item/flame/lighter = 50,			\
	/obj/item/weldingtool = 25
	)

	min_duration = 70
	max_duration = 100

/datum/surgery_step/face/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face > 0

/datum/surgery_step/face/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] is beginning to cauterize the incision on [target]'s face and neck with \the [tool].</font>" , \
	"<font color=#4F49AF>You are beginning to cauterize the incision on [target]'s face and neck with \the [tool].</font>")
	..()

/datum/surgery_step/face/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color=#4F49AF>[user] cauterizes the incision on [target]'s face and neck with \the [tool].</font>", \
	"<font color=#4F49AF>You cauterize the incision on [target]'s face and neck with \the [tool].</font>")
	affected.open = 0
	affected.status &= ~ORGAN_BLEEDING
	if (target.op_stage.face == 3)
		var/obj/item/organ/external/head/h = affected
		h.disfigured = 0
	target.op_stage.face = 0

/datum/surgery_step/face/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<font color='red'>[user]'s hand slips, leaving a small burn on [target]'s face with \the [tool]!</font>", \
	"<font color='red'>Your hand slips, leaving a small burn on [target]'s face with \the [tool]!</font>")
	target.apply_damage(4, DAMAGE_TYPE_BURN, affected)
