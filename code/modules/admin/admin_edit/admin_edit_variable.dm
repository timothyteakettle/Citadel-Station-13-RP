/datum/admin_edit_variable
	var/variable_name
	var/variable_datatype
	var/category

/datum/admin_edit_variable/proc/tgui_serialize()
	var/list/data = new()
	data["variable_name"] = variable_name
	data["variable_datatype"] = variable_datatype
	data["category"] = category
	return data
