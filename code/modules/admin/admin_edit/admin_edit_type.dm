/datum/admin_edit_type
	var/admin_edit_type
	var/list/datum/admin_edit_variable/admin_edit_variables

/datum/admin_edit_type/proc/tgui_serialize()
	var/list/data = new()
	data["type"] = admin_edit_type
	data["variables"] = list()

	for(var/datum/admin_edit_variable/variable in admin_edit_variables)
		data["variables"][variable.variable_name] = variable.tgui_serialize()

	return data
