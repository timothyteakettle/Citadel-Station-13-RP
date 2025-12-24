/proc/_admin_edit_bind_variable(type, variable_name, variable_datatype, category)
	if(isnull(GLOB.admin_edit_directory[type]))
		var/datum/admin_edit_type/binded_type = new()
		binded_type.admin_edit_type = type
		binded_type.admin_edit_variables = list()

	var/datum/admin_edit_variable/binded_variable = new()
	binded_variable.variable_name = variable_name
	binded_variable.variable_datatype = variable_datatype
	binded_variable.category = category

	GLOB.admin_edit_directory[type].admin_edit_variables[variable_name] = binded_variable

/proc/get_admin_edit_type(atom/A)
	for(var/type in GLOB.admin_edit_directory)
		if(istype(A, type))
			return GLOB.admin_edit_directory[type]
	return null
