/*
 * This file contains all of the UI code for the RD console.
 * It's moved off to this file for simplicity and understanding what is UI and what is functionality.
 */

#define ENTRIES_PER_RDPAGE 50

/obj/machinery/computer/rdconsole
	var/locked = FALSE
	var/busy_msg = null

	var/search = ""
	var/design_page = 0
	var/builder_page = 0

/obj/machinery/computer/rdconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ResearchConsole", name)
		ui.open()

/obj/machinery/computer/rdconsole/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(locked && !allowed(user) && !emagged)
		. = min(., UI_UPDATE)

/obj/machinery/computer/rdconsole/ui_static_data(mob/user, datum/tgui/ui)
	var/list/data = ..()

	data["tech"] = tgui_GetResearchLevelsInfo()
	data["designs"] = tgui_GetDesignInfo(design_page)

	data["lathe_designs"] = tgui_GetProtolatheDesigns(linked_lathe, builder_page)
	data["imprinter_designs"] = tgui_GetImprinterDesigns(linked_imprinter, builder_page)

	return data

/obj/machinery/computer/rdconsole/ui_data(mob/user, datum/tgui/ui)
	var/list/data = ..()

	data["locked"] = locked
	data["busy_msg"] = busy_msg
	data["search"] = search

	if(!locked)
		data["info"] = list(
			"sync" = sync,
		)

		data["info"]["linked_destroy"] = list("present" = FALSE)
		if(linked_destroy)
			data["info"]["linked_destroy"] = list(
				"present" = TRUE,
				"loaded_item" = linked_destroy.loaded_item,
				"origin_tech" = tgui_GetOriginTechForItem(linked_destroy.loaded_item),
			)

		data["info"]["linked_lathe"] = list("present" = FALSE)
		if(linked_lathe)
			data["info"]["linked_lathe"] = list(
				"present" = TRUE,
				"total_materials" = linked_lathe.TotalMaterials(),
				"max_materials" = linked_lathe.max_material_storage,
				"total_volume" = linked_lathe.reagents.total_volume,
				"max_volume" = linked_lathe.reagents.maximum_volume,
				"busy" = linked_lathe.busy,
			)

			var/list/materials = list()
			for(var/M in linked_lathe.stored_materials)
				var/amount = linked_lathe.stored_materials[M]
				var/hidden_mat = FALSE
				for(var/HM in linked_lathe.hidden_materials)
					if(M == HM && amount == 0)
						hidden_mat = TRUE
						break
				if(hidden_mat)
					continue
				materials.Add(list(list(
					"name" = M,
					"amount" = amount,
					"sheets" = round(amount / SHEET_MATERIAL_AMOUNT),
					"removable" = amount >= SHEET_MATERIAL_AMOUNT,
				)))
			data["info"]["linked_lathe"]["mats"] = materials

			var/list/reagents = list()
			for(var/datum/reagent/R in linked_lathe.reagents.get_reagent_datums())
				reagents.Add(list(list(
					"name" = R.name,
					"id" = R.id,
					"volume" = linked_lathe.reagents.reagent_volumes[R.id],
				)))
			data["info"]["linked_lathe"]["reagents"] = reagents

			var/list/queue = list()
			var/i = 1
			for(var/datum/prototype/design/D in linked_lathe.queue)
				queue.Add(list(list(
					"name" = D.name,
					"index" = i, // ugghhhh
				)))
				i++
			data["info"]["linked_lathe"]["queue"] = queue

		data["info"]["linked_imprinter"] = list("present" = FALSE)
		if(linked_imprinter)
			data["info"]["linked_imprinter"] = list(
				"present" = TRUE,
				"total_materials" = linked_imprinter.TotalMaterials(),
				"max_materials" = linked_imprinter.max_material_storage,
				"total_volume" = linked_imprinter.reagents.total_volume,
				"max_volume" = linked_imprinter.reagents.maximum_volume,
				"busy" = linked_imprinter.busy,
			)

			var/list/materials = list()
			for(var/M in linked_imprinter.stored_materials)
				var/amount = linked_imprinter.stored_materials[M]
				var/hidden_mat = FALSE
				for(var/HM in linked_imprinter.hidden_materials)
					if(M == HM && amount == 0)
						hidden_mat = TRUE
						break
				if(hidden_mat)
					continue
				materials.Add(list(list(
					"name" = M,
					"amount" = amount,
					"sheets" = round(amount / SHEET_MATERIAL_AMOUNT),
					"removable" = amount >= SHEET_MATERIAL_AMOUNT,
				)))
			data["info"]["linked_imprinter"]["mats"] = materials

			var/list/reagents = list()
			for(var/datum/reagent/R in linked_imprinter.reagents.get_reagent_datums())
				reagents.Add(list(list(
					"name" = R.name,
					"id" = R.id,
					"volume" = linked_imprinter.reagents.reagent_volumes[R.id],
				)))
			data["info"]["linked_imprinter"]["reagents"] = reagents

			var/list/queue = list()
			var/i = 1
			for(var/datum/prototype/design/D in linked_imprinter.queue)
				queue.Add(list(list(
					"name" = D.name,
					"index" = i, // ugghhhh
				)))
				i++
			data["info"]["linked_imprinter"]["queue"] = queue

		data["info"]["t_disk"] = list("present" = FALSE)
		if(t_disk)
			data["info"]["t_disk"] = list(
				"present" = TRUE,
				"stored" = !!t_disk.stored,
			)
			if(t_disk.stored)
				data["info"]["t_disk"]["name"] = t_disk.stored.name
				data["info"]["t_disk"]["level"] = t_disk.stored.level
				data["info"]["t_disk"]["desc"] = t_disk.stored.desc

		data["info"]["d_disk"] = list("present" = FALSE)
		if(d_disk)
			data["info"]["d_disk"] = list(
				"present" = TRUE,
				"stored" = !!d_disk.design_id,
			)
			if(d_disk.design_id)
				var/datum/prototype/design/blueprint = RSdesigns.fetch(d_disk.design_id)
				data["info"]["d_disk"]["name"] = blueprint.name
				data["info"]["d_disk"]["build_type"] = blueprint.lathe_type
				data["info"]["d_disk"]["materials"] = blueprint.materials_base

	return data

/obj/machinery/computer/rdconsole/proc/tgui_GetResearchLevelsInfo()
	var/list/data = list()
	for(var/datum/tech/T in files.known_tech)
		if(T.level < 1)
			continue
		data.Add(list(list(
			"name" = T.name,
			"level" = T.level,
			"desc" = T.desc,
			"id" = T.id,
		)))
	return data

/obj/machinery/computer/rdconsole/proc/tgui_GetOriginTechForItem(obj/item/I)
	if(!istype(I))
		return list()

	var/list/data = list()
	for(var/T in I.origin_tech)
		var/list/subdata = list(
			"name" = CallTechName(T),
			"level" = I.origin_tech[T],
			"current" = null,
		)
		for(var/datum/tech/F in files.known_tech)
			if(F.name == CallTechName(T))
				subdata["current"] = F.level
				break
		data.Add(list(subdata))

	return data

/proc/cmp_designs_rdconsole(list/A, list/B)
	return sorttext(B["name"], A["name"])

/obj/machinery/computer/rdconsole/proc/tgui_GetProtolatheDesigns(obj/machinery/r_n_d/protolathe/P, page)
	if(!istype(P))
		return list()

	var/list/data = list()
	// For some reason, this is faster than direct access.
	var/list/known_designs = files.legacy_all_design_datums()
	for(var/datum/prototype/design/D in known_designs)
		if(!D.build_path || !(D.lathe_type & LATHE_TYPE_PROTOLATHE))
			continue
		if(search && !findtext(D.name, search))
			continue

		var/list/mat_list = list()
		for(var/M in D.materials_base)
			mat_list.Add("[D.materials_base[M] * P.mat_efficiency] [CallMaterialName(M)]")

		var/list/chem_list = list()
		for(var/T in D.reagents)
			chem_list.Add("[D.reagents[T] * P.mat_efficiency] [CallReagentName(T)]")

		data.Add(list(list(
			"name" = D.name,
			"id" = D.id,
			"mat_list" = mat_list,
			"chem_list" = chem_list,
		)))

	data = tim_sort(data, GLOBAL_PROC_REF(cmp_designs_rdconsole), FALSE)
	if(LAZYLEN(data) > ENTRIES_PER_RDPAGE)
		var/first_index = clamp(ENTRIES_PER_RDPAGE * page, 1, LAZYLEN(data))
		var/last_index  = min((ENTRIES_PER_RDPAGE * page) + ENTRIES_PER_RDPAGE, LAZYLEN(data) + 1)

		data = data.Copy(first_index, last_index)

	return data


/obj/machinery/computer/rdconsole/proc/tgui_GetImprinterDesigns(obj/machinery/r_n_d/circuit_imprinter/P, page)
	if(!istype(P))
		return list()

	var/list/data = list()
	// For some reason, this is faster than direct access.
	var/list/known_designs = files.legacy_all_design_datums()
	for(var/datum/prototype/design/D in known_designs)
		if(!D.build_path || !(D.lathe_type & LATHE_TYPE_CIRCUIT))
			continue
		if(search && !findtext(D.name, search))
			continue

		var/list/mat_list = list()
		for(var/M in D.materials_base)
			mat_list.Add("[D.materials_base[M] * P.mat_efficiency] [CallMaterialName(M)]")

		var/list/chem_list = list()
		for(var/T in D.reagents)
			chem_list.Add("[D.reagents[T] * P.mat_efficiency] [CallReagentName(T)]")

		data.Add(list(list(
			"name" = D.name,
			"id" = D.id,
			"mat_list" = mat_list,
			"chem_list" = chem_list,
		)))

	data = tim_sort(data, GLOBAL_PROC_REF(cmp_designs_rdconsole), FALSE)
	if(LAZYLEN(data) > ENTRIES_PER_RDPAGE)
		var/first_index = clamp(ENTRIES_PER_RDPAGE * page, 1, LAZYLEN(data))
		var/last_index  = min((ENTRIES_PER_RDPAGE * page) + ENTRIES_PER_RDPAGE, LAZYLEN(data) + 1)

		data = data.Copy(first_index, last_index)

	return data

/obj/machinery/computer/rdconsole/proc/tgui_GetDesignInfo(page)
	var/list/data = list()
	// For some reason, this is faster than direct access.
	var/list/known_designs = files.legacy_all_design_datums()
	for(var/datum/prototype/design/D in known_designs)
		if(search && !findtext(D.name, search))
			continue
		if(D.build_path)
			data.Add(list(list(
				"name" = D.name,
				"desc" = D.desc,
				"id" = D.id,
			)))

	data = tim_sort(data, GLOBAL_PROC_REF(cmp_designs_rdconsole), FALSE)
	if(LAZYLEN(data) > ENTRIES_PER_RDPAGE)
		var/first_index = clamp(ENTRIES_PER_RDPAGE * page, 1, LAZYLEN(data))
		var/last_index  = clamp((ENTRIES_PER_RDPAGE * page) + ENTRIES_PER_RDPAGE, 1, LAZYLEN(data) + 1)

		data = data.Copy(first_index, last_index)

	return data

/obj/machinery/computer/rdconsole/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE

	add_fingerprint(usr)
	usr.set_machine(src)

	switch(action)
		if("search")
			search = params["search"]
			push_ui_data(data = list(
				"lathe_designs" = tgui_GetProtolatheDesigns(linked_lathe, builder_page),
				"imprinter_designs" = tgui_GetImprinterDesigns(linked_imprinter, builder_page)
			))
			return TRUE
		if("design_page")
			if(params["reset"])
				design_page = 0
			else
				design_page = max(design_page + (1 * params["reverse"]), 0)
			push_ui_data(data = list("designs" = tgui_GetDesignInfo(design_page)))
			return TRUE
		if("builder_page")
			if(params["reset"])
				builder_page = 0
			else
				builder_page = max(builder_page + (1 * params["reverse"]), 0)
			push_ui_data(data = list(
				"lathe_designs" = tgui_GetProtolatheDesigns(linked_lathe, builder_page),
				"imprinter_designs" = tgui_GetImprinterDesigns(linked_imprinter, builder_page)
			))
			return TRUE

		if("updt_tech") //Update the research holder with information from the technology disk.
			busy_msg = "Updating Database..."
			spawn(5 SECONDS)
				busy_msg = null
				files.AddTech2Known(t_disk.stored)
				files.RefreshResearch()
				update_static_data(usr, ui)
			return TRUE

		if("clear_tech") //Erase data on the technology disk.
			t_disk.stored = null
			return TRUE

		if("eject_tech") //Eject the technology disk.
			t_disk.loc = loc
			t_disk = null
			return TRUE

		if("copy_tech") //Copys some technology data from the research holder to the disk.
			for(var/datum/tech/T in files.known_tech)
				if(params["copy_tech_ID"] == T.id)
					t_disk.stored = T
					break
			return TRUE

		if("updt_design") //Updates the research holder with design data from the design disk.
			busy_msg = "Updating Database..."
			spawn(5 SECONDS)
				busy_msg = null
				if(d_disk?.design_id)
					files.AddDesign2Known(RSdesigns.fetch(d_disk.design_id))
				update_static_data(usr, ui)
			return TRUE

		if("clear_design") //Erases data on the design disk.
			d_disk.design_id = null
			return TRUE

		if("eject_design") //Eject the design disk.
			d_disk.loc = loc
			d_disk = null
			return TRUE

		if("copy_design") //Copy design data from the research holder to the design disk.
			var/target_design_id = params["copy_design_ID"]
			if(target_design_id in files.known_design_ids)
				d_disk.design_id = target_design_id
			return TRUE

		if("eject_item") //Eject the item inside the destructive analyzer.
			if(linked_destroy)
				if(linked_destroy.busy)
					to_chat(usr, "<span class='notice'>The destructive analyzer is busy at the moment.</span>")
					return FALSE

				if(linked_destroy.loaded_item)
					linked_destroy.loaded_item.loc = linked_destroy.loc
					linked_destroy.loaded_item = null
					linked_destroy.icon_state = "d_analyzer"
				return TRUE

		if("deconstruct") //Deconstruct the item in the destructive analyzer and update the research holder.
			if(!linked_destroy)
				return FALSE

			if(linked_destroy.busy)
				to_chat(usr, "<span class='notice'>The destructive analyzer is busy at the moment.</span>")
				return

			if(alert("Proceeding will destroy loaded item. Continue?", "Destructive analyzer confirmation", "Yes", "No") == "No" || !linked_destroy)
				return
			linked_destroy.busy = 1
			busy_msg = "Processing and Updating Database..."
			flick("d_analyzer_process", linked_destroy)
			spawn(2.4 SECONDS)
				if(linked_destroy)
					linked_destroy.busy = 0
					busy_msg = null
					if(!linked_destroy.loaded_item)
						to_chat(usr, "<span class='notice'>The destructive analyzer appears to be empty.</span>")
						return

					for(var/T in linked_destroy.loaded_item.origin_tech)
						files.UpdateTech(T, linked_destroy.loaded_item.origin_tech[T])
					if(linked_lathe) // Also sends salvaged materials to a linked protolathe, if any.
						var/list/mats = linked_destroy.loaded_item.get_materials(TRUE)
						for(var/t in mats)
							if(t in linked_lathe.stored_materials)
								linked_lathe.stored_materials[t] += min(linked_lathe.max_material_storage - linked_lathe.TotalMaterials(), mats[t] * linked_destroy.decon_mod)


					linked_destroy.loaded_item = null
					for(var/obj/I in linked_destroy.contents)
						for(var/mob/M in I.contents)
							M.death()
						if(istype(I,/obj/item/stack/material))//Only deconsturcts one sheet at a time instead of the entire stack
							var/obj/item/stack/material/S = I
							if(S.get_amount() > 1)
								S.use(1)
								linked_destroy.loaded_item = S
							else
								qdel(S)
								linked_destroy.icon_state = "d_analyzer"
						else
							if(I != linked_destroy.circuit && !(I in linked_destroy.component_parts))
								qdel(I)
								linked_destroy.icon_state = "d_analyzer"

					use_power(linked_destroy.active_power_usage)
					files.RefreshResearch()
					update_static_data(usr, ui)
			return TRUE

		if("lock") //Lock the console from use by anyone without tox access.
			if(!allowed(usr))
				to_chat(usr, "Unauthorized Access.")
				return
			locked = !locked
			return TRUE

		if("sync") //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
			if(!sync)
				to_chat(usr, "<span class='notice'>You must connect to the network first.</span>")
				return

			busy_msg = "Updating Database..."
			spawn(3 SECONDS)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
						var/server_processed = 0
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/datum/tech/T in files.known_tech)
								S.files.AddTech2Known(T)
							for(var/datum/prototype/design/D in files.legacy_all_design_datums())
								S.files.AddDesign2Known(D)
							S.files.RefreshResearch()
							server_processed = 1
						if((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/datum/tech/T in S.files.known_tech)
								files.AddTech2Known(T)
							for(var/datum/prototype/design/D in S.files.legacy_all_design_datums())
								files.AddDesign2Known(D)
							server_processed = 1
						if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
							S.produce_heat()
					busy_msg = null
					files.RefreshResearch()
					update_static_data(usr, ui)
			return TRUE

		if("togglesync") //Prevents the console from being synced by other consoles. Can still send data.
			sync = !sync
			return TRUE

		if("build") //Causes the Protolathe to build something.
			if(linked_lathe)
				var/datum/prototype/design/being_built = null
				for(var/datum/prototype/design/D in files.legacy_all_design_datums())
					if(D.id == params["build"])
						being_built = D
						break
				if(being_built)
					linked_lathe.addToQueue(being_built)
				return TRUE

		if("buildfive") //Causes the Protolathe to build 5 of something.
			if(linked_lathe)
				var/datum/prototype/design/being_built = null
				for(var/datum/prototype/design/D in files.legacy_all_design_datums())
					if(D.id == params["build"])
						being_built = D
						break
				if(being_built)
					for(var/i = 1 to 5)
						linked_lathe.addToQueue(being_built)
				return TRUE

		if("imprint") //Causes the Circuit Imprinter to build something.
			if(linked_imprinter)
				var/datum/prototype/design/being_built = null
				for(var/datum/prototype/design/D in files.legacy_all_design_datums())
					if(D.id == params["imprint"])
						being_built = D
						break
				if(being_built)
					linked_imprinter.addToQueue(being_built)
				return TRUE

		if("disposeI")  //Causes the circuit imprinter to dispose of a single reagent (all of it)
			if(!linked_imprinter)
				return
			linked_imprinter.reagents.del_reagent(params["dispose"])
			return TRUE

		if("disposeallI") //Causes the circuit imprinter to dispose of all it's reagents.
			if(!linked_imprinter)
				return
			linked_imprinter.reagents.clear_reagents()
			return TRUE

		if("removeI")
			if(!linked_imprinter)
				return
			linked_imprinter.removeFromQueue(text2num(params["removeI"]))
			return TRUE

		if("imprinter_ejectsheet") //Causes the imprinter to eject a sheet of material
			if(!linked_imprinter)
				return
			linked_imprinter.eject(params["imprinter_ejectsheet"], text2num(params["amount"]))
			return TRUE

		if("disposeP")  //Causes the protolathe to dispose of a single reagent (all of it)
			if(!linked_lathe)
				return
			linked_lathe.reagents.del_reagent(params["dispose"])
			return TRUE

		if("disposeallP") //Causes the protolathe to dispose of all it's reagents.
			if(!linked_lathe)
				return
			linked_lathe.reagents.clear_reagents()
			return TRUE

		if("removeP")
			if(!linked_lathe)
				return
			linked_lathe.removeFromQueue(text2num(params["removeP"]))
			return TRUE

		if("lathe_ejectsheet") //Causes the protolathe to eject a sheet of material
			if(!linked_lathe)
				return
			linked_lathe.eject(params["lathe_ejectsheet"], text2num(params["amount"]))
			return TRUE

		if("find_device") //The R&D console looks for devices nearby to link up with.
			busy_msg = "Updating Database..."

			spawn(10)
				busy_msg = null
				SyncRDevices()
				update_static_data(usr, ui)
			return TRUE

		if("disconnect") //The R&D console disconnects with a specific device.
			switch(params["disconnect"])
				if("destroy")
					linked_destroy.linked_console = null
					linked_destroy = null
				if("lathe")
					linked_lathe.linked_console = null
					linked_lathe = null
				if("imprinter")
					linked_imprinter.linked_console = null
					linked_imprinter = null
			update_static_data(usr, ui)

		if("reset") //Reset the R&D console's database.
			var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
			if(choice == "Continue")
				busy_msg = "Updating Database..."
				qdel(files)
				files = new /datum/research(src)
				spawn(20)
					busy_msg = null
					update_static_data(usr, ui)

		if("print") //Print research information
			busy_msg = "Printing Research Information. Please Wait..."
			spawn(20)
				var/obj/item/paper/PR = new/obj/item/paper
				PR.name = "list of researched technologies"
				PR.info = "<center><b>[station_name()] Science Laboratories</b>"
				PR.info += "<h2>[ (text2num(params["print"]) == 2) ? "Detailed" : null] Research Progress Report</h2>"
				PR.info += "<i>report prepared at [stationtime2text()] station time</i></center><br>"
				if(text2num(params["print"]) == 2)
					PR.info += GetResearchListInfo()
				else
					PR.info += GetResearchLevelsInfo()
				PR.info_links = PR.info
				PR.icon_state = "paper_words"
				PR.forceMove(loc)
				busy_msg = null
