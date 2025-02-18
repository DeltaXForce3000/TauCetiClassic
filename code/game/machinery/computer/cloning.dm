/obj/machinery/computer/cloning
	name = "Cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	state_broken_preset = "crewb"
	state_nopower_preset = "crew0"
	light_color = "#315ab4"
	circuit = /obj/item/weapon/circuitboard/cloning
	req_access = list(access_heads) //Only used for record deletion right now.
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/temp = ""
	var/scantemp = "Scanner unoccupied"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/autoprocess = 0

/obj/machinery/computer/cloning/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/cloning/atom_init_late()
	updatemodules()

/obj/machinery/computer/cloning/process()
	if(!(scanner && pod1 && autoprocess))
		return

	if(scanner.occupant && (scanner.scan_level > 2))
		scan_mob(scanner.occupant)

	if(!(pod1.occupant || pod1.mess) && (pod1.efficiency > 5))
		for(var/datum/data/record/R in records)
			if(!(pod1.occupant || pod1.mess))
				if(pod1.growclone(R.fields["ckey"], R.fields["name"], R.fields["UI"], R.fields["SE"], R.fields["mind"], R.fields["mrace"]))
					records -= R

/obj/machinery/computer/cloning/proc/updatemodules()
	src.scanner = findscanner()
	src.pod1 = findcloner()

	if (!isnull(src.pod1))
		src.pod1.connected = src // Some variable the pod needs

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null
	// Loop through every direction
	for(var/nextdir in cardinal)

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, nextdir))

		// If found, then we break, and return the scanner
		if(!isnull(scannerf))
			break
	// If no scanner was found, it will return null
	return scannerf

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = null
	for(var/newdir in cardinal)

		podf = locate(/obj/machinery/clonepod, get_step(src, newdir))

		if(!isnull(podf))
			break
	return podf

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_from_inventory(W, src)
			src.diskette = W
			to_chat(user, "You insert [W].")
			updateUsrDialog()
			return
	else
		..()
	return

/obj/machinery/computer/cloning/ui_interact(mob/user)
	updatemodules()

	var/dat = ""
	dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font><br>"
	if(scanner && pod1 && ((scanner.scan_level > 2) || (pod1.efficiency > 5)))
		if(!autoprocess)
			dat += "<a href='byond://?src=\ref[src];task=autoprocess'>Autoprocess</a>"
		else
			dat += "<a href='byond://?src=\ref[src];task=stopautoprocess'>Stop autoprocess</a>"
	else
		dat += "<span class='disabled'>Autoprocess</span>"
	dat += "<br><tt>[temp]</tt><br>"

	switch(src.menu)
		if(1)
			// Modules
			dat += "<h4>Modules</h4>"
			//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
			if (isnull(src.scanner))
				dat += " <span class='red'>Scanner-ERROR</span><br>"
			else
				dat += " <span class='green'>Scanner-Found!</span><br>"
			if (isnull(src.pod1))
				dat += " <span class='red'>Pod-ERROR</span><br>"
			else
				dat += " <span class='green'>Pod-Found!</span><br>"

			// Scanner
			dat += "<h4>Scanner Functions</h4>"

			if(loading)
				dat += "<b>Scanning...</b><br>"
			else
				dat += "<b>[scantemp]</b><br>"

			if (isnull(src.scanner))
				dat += "No scanner connected!<br>"
			else
				if (src.scanner.occupant)
					if(scantemp == "Scanner unoccupied") scantemp = "" // Stupid check to remove the text

					dat += "<a href='byond://?src=\ref[src];scan=1'>Scan - [src.scanner.occupant]</a><br>"
				else
					scantemp = "Scanner unoccupied"

				dat += "Lock status: <a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Locked" : "Unlocked"]</a><br>"

			if (!isnull(src.pod1))
				dat += "Biomass: <i>[src.pod1.biomass]</i><br>"

			// Database
			dat += "<h4>Database Functions</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>View Records</a><br>"
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a>"


		if(2)
			dat += "<h4>Current records</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=1'>Back</a><br><br>"
			for(var/datum/dna2/record/R in src.records)
				dat += "<li><a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.dna.real_name]</a><li>"

		if(3)
			dat += "<h4>Selected Record</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>Back</a><br>"

			if (!src.active_record)
				dat += "<span class='red'>ERROR: Record not found.</span>"
			else
				dat += {"<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Delete Record</a></font><br>
					<b>Name:</b> [src.active_record.dna.real_name]<br>"}
				var/obj/item/weapon/implant/health/H = null
				if(src.active_record.implant)
					H=locate(src.active_record.implant)

				if ((H) && (istype(H)))
					dat += "<b>Health:</b> [H.sensehealth()] | OXY-BURN-TOX-BRUTE<br>"
				else
					dat += "<span class='red'>Unable to locate implant.</span><br>"

				if (!isnull(src.diskette))
					dat += "<a href='byond://?src=\ref[src];disk=load'>Load from disk.</a>"

					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ue'>UI + UE</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ui'>UI</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=se'>SE</a>"
					dat += "<br>"
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				dat += {"<b>UI:</b> [src.active_record.dna.uni_identity]<br>
				<b>SE:</b> [src.active_record.dna.struc_enzymes]<br><br>"}

				if(pod1 && pod1.biomass >= CLONE_BIOMASS)
					dat += {"<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Clone</a><br>"}
				else
					dat += {"<b>Insufficient biomass</b><br>"}

		if(4)
			if (!src.active_record)
				src.menu = 2
			dat = "[src.temp]<br>"
			dat += "<h4>Confirm Record Deletion</h4>"

			dat += "<b><a href='byond://?src=\ref[src];del_rec=1'>Scan card to confirm.</a></b><br>"
			dat += "<b><a href='byond://?src=\ref[src];menu=3'>No</a></b>"

	var/datum/browser/popup = new(user, "cloning", "Cloning System Control")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(loading)
		return

	if(href_list["task"])
		switch(href_list["task"])
			if("autoprocess")
				autoprocess = 1
			if("stopautoprocess")
				autoprocess = 0

	else if ((href_list["scan"]) && (!isnull(src.scanner)))
		scantemp = ""

		loading = 1
		updateUsrDialog()

		spawn(20)
			scan_mob(src.scanner.occupant)

			loading = 0
			updateUsrDialog()


		//No locking an open scanner.
	else if ((href_list["lock"]) && (!isnull(src.scanner)))
		if ((!src.scanner.locked) && (src.scanner.occupant))
			src.scanner.locked = 1
		else
			src.scanner.locked = 0

	else if (href_list["view_rec"])
		src.active_record = locate(href_list["view_rec"])
		if(istype(src.active_record,/datum/dna2/record))
			if ((isnull(src.active_record.ckey)))
				qdel(src.active_record)
				src.temp = "ERROR: Record Corrupt"
			else
				src.menu = 3
		else
			src.active_record = null
			src.temp = "Record missing."

	else if (href_list["del_rec"])
		if ((!src.active_record) || (src.menu < 3))
			return
		if (src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Delete record?"
			src.menu = 4

		else if (src.menu == 4)
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(check_access(C))
					records.Remove(src.active_record)
					qdel(src.active_record)
					src.temp = "Record deleted."
					src.menu = 2
				else
					src.temp = "Access Denied."

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(src.diskette)) || isnull(src.diskette.buf))
					src.temp = "Load error."
					updateUsrDialog()
					return
				if (isnull(src.active_record))
					src.temp = "Record error."
					src.menu = 1
					updateUsrDialog()
					return

				src.active_record = src.diskette.buf

				src.temp = "Load successful."
			if("eject")
				if (!isnull(src.diskette))
					src.diskette.loc = src.loc
					src.diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(src.active_record)))
			src.temp = "Save error."
			updateUsrDialog()
			return

		// DNA2 makes things a little simpler.
		src.diskette.buf=src.active_record
		src.diskette.buf.types=0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				src.diskette.buf.types=DNA2_BUF_UI
			if("ue")
				src.diskette.buf.types=DNA2_BUF_UI|DNA2_BUF_UE
			if("se")
				src.diskette.buf.types=DNA2_BUF_SE
		src.diskette.name = "data disk - '[src.active_record.dna.real_name]'"
		src.temp = "Save \[[href_list["save_disk"]]\] successful."

	else if (href_list["refresh"])
		updateUsrDialog()

	else if (href_list["clone"])
		var/datum/dna2/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!pod1)
				temp = "Error: No Clonepod detected."
			else if(pod1.occupant)
				temp = "Error: Clonepod is currently occupied."
			else if(pod1.biomass < CLONE_BIOMASS)
				temp = "Error: Not enough biomass."
			else if(pod1.mess)
				temp = "Error: Clonepod malfunction."
			else if(!config.revival_cloning)
				temp = "Error: Unable to initiate cloning cycle."

			else if(pod1.growclone(C))
				temp = "<span class='good'>Cloning cycle in progress...</span>"
				records.Remove(C)
				qdel(C)
				menu = 1
			else
				var/mob/selected = find_dead_player("[C.ckey]")
				if(selected)
					selected.playsound_local(null, 'sound/machines/chime.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)	//probably not the best sound but I think it's reasonable
					var/answer = tgui_alert(selected,"Do you want to return to life?","Cloning", list("Yes","No"))
					if(answer != "No" && pod1.growclone(C))
						temp = "Initiating cloning cycle..."
						records.Remove(C)
						qdel(C)
						menu = 1
					else
						temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."
				else
					temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."

		else
			temp = "Error: Data corruption."

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])

	updateUsrDialog()

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject)
	if ((isnull(subject)) || (!(ishuman(subject))) || subject.species.flags[NO_SCAN] || (!subject.dna))
		scantemp = "Error: Unable to locate valid genetic data."
		return
	if (!subject.has_brain())
		scantemp = "Error: No signs of intelligence detected."
		return
	if (subject.suiciding == 1)
		scantemp = "Error: Subject's brain is not responding to scanning stimuli."
		return
	if ((!subject.ckey) || (!subject.client))
		scantemp = "Error: Mental interface failure."
		return
	if ((NOCLONE in subject.mutations && src.scanner.scan_level < 4) || HAS_TRAIT(subject, TRAIT_NO_CLONE))
		scantemp = "<span class='bad'>Subject no longer contains the fundamental materials required to create a living clone.</span>"
		return
	if (!isnull(find_record(subject.ckey)))
		scantemp = "Subject already in database."
		return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.dna=subject.dna
	R.ckey = subject.ckey
	R.id= copytext(md5(subject.real_name), 2, 6)
	R.name=R.dna.real_name
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages=subject.languages

	R.quirks = list()
	for(var/V in subject.roundstart_quirks)
		var/datum/quirk/T = V
		R.quirks += T.type
	R.quirks += /datum/quirk/genetic_degradation // clones cannot be cloned

	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implanted = subject
		subject.sec_hud_set_implants()
		R.implant = "\ref[imp]"
	//Update it if needed
	else
		R.implant = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	src.records += R
	scantemp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in src.records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "crew0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
