/// Some would consider making a subsystem for arousal to be a waste of whatever adding on another subsystem would be a waste of
/// But mama always said, "If you're gonna make horny bullshit for a space station 13 game, put it in a subsystem."
/// time to make her proud. All aboard the SS MERP!

//
// MERP subsystem - Processes arousal and related things, stores a list of all merp scripts
//
PROCESSING_SUBSYSTEM_DEF(merp)
	name = "MERP"
	priority = FIRE_PRIORITY_MERP
	wait = 0.2 SECONDS // FAST PROCESSING~!
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME
	/// the master list of all merp scripts
	/// cus strings() just wasnt hardcore enough
	var/list/merp_dictionary = list() // heh dictionary
	/// the master list of all merp folders
	/// This constitutes the entire MERP tree, despite being flat as a board
	var/list/merp_folders = list()

/datum/controller/subsystem/processing/merp/Initialize(start_timeofday)
	initialize_fatmerp()
	. = ..()
	send_merp_status_report() // tell everyone how much MERP is in store for them

/datum/controller/subsystem/processing/merp/send_merp_status_report()
	if(!LAZYLEN(merp_dictionary))
		return
	var/folders
	var/total_entries
	var/total_scripts
	if(LAZYLEN(merp_dictionary))
		to_chat(world, span_boldannounce("MERP is in full force!"))


/// The giant hellproc to construct a giant helllist out of bits and boobs
/// Takes in all the loaded MERPI datums and cycles through them to build a tree of what bits go in what folder
/// End result will be a tree of lists
/// We can't assume anything is anywhere for any reason or whatever, so we're making this list, and checking it (at least) twice
/datum/controller/subsystem/processing/merp/proc/initialize_fatmerp()
	sort_files_and_subfolders_in_folders(sort_unsortable_merpies_into_unsorted_folder(poplate_folders_with_files_and_subfolders(extract_folders_from_merp_dictionary(build_merp_dictionary())))) // hi

/datum/controller/subsystem/processing/merp/proc/build_merp_dictionary()
	/// Yes, we are using flist to search for all our furry kinks. lets fucking go.
	var/list/all_merp_files = flist(MERP_MASTER_DIRECTORY)
	if(LAZYLEN(merp_dictionary))
		QDEL_LIST_ASSOC(merp_dictionary)
	for(var/merp in all_merp_files)
		var/list/split_merp = splittext(merp, ".")
		if(LAZYLEN(split_merp) != 2)
			continue
		if(split_merp[2] != "json")
			continue
		var/merp_key = split_merp[1]
		var/list/merp_script = safe_json_decode("[MERP_PATH(merp_key)]")
		if(!LAZYLEN(LAZYACCESS(merp_script, "merpi_intent_help")))
			stack_trace("Invalid MERP script ([merp]) found in [MERP_MASTER_DIRECTORY]. Should probably be removed.")
			continue
		var/datum/merp_script/ms = new()
		if(!ms.merpify(merp_script, merp_key))
			stack_trace("Merpify failed for ([merp]).")
			continue
		merp_dictionary[merp_key] = ms
	return merp_dictionary

/datum/controller/subsystem/processing/merp/proc/extract_folders_from_merp_dictionary() // these dont need to be stacked, I'm just compensating for something
	if(!LAZYLEN(merp_dictionary))
		CRASH("No MERP scripts loaded!") // and thus the house of procs came crashing down into a pile of runtimes
	if(LAZYLEN(merp_folders))
		QDEL_LIST_ASSOC(merp_folders)
	merp_folders = list()
	for(var/merp_key in merp_dictionary)
		var/datum/merp_script/ms = get_merp_script(merp_key)
		if(!ms.is_container)
			continue
		var/folder_name = ms.parent_merpi
		if(LAZYACCESS(merp_folders, ms.index))
			stack_trace("MERP folder [folder_name] already exists! This is a problem! How did this happen?")
			continue
		var/datum/merp_folder/folder = new(merp_key, ms.parent_merpi)
		merp_folders[merp_key] = folder
	return merp_folders /// At this point, merp_folders should look like: list("Folder1" = /datum/merp_folder/folder1, "Folder2" = /datum/merp_folder/folder2, etc)

/// This is the second step. We're going to take our flat pile of folders and put all the scripts and folders into them
/datum/controller/subsystem/processing/merp/proc/poplate_folders_with_files_and_subfolders()
	if(!LAZYLEN(merp_folders))
		CRASH("No MERP folders given! We need at least one!") // oof, still got a ways to go
	if(!LAZYLEN(merp_dictionary))
		CRASH("No MERP scripts loaded!") // and thus the house of procs came crashing down into a pile of runtimes
	var/list/unsorted_merpies = list()
	for(var/merp_key in merp_dictionary)
		unsorted_merpies += merp_key
	for(var/folder_key in merp_folders)
		var/datum/merp_folder/folder = get_merp_folder(folder_key)
		if(!folder)
			stack_trace("MERP folder [folder_key] does not exist! This is a problem! How did this happen?")
			continue
		var/list/used_files = list()
		used_files =| folder.populate_my_files()
		used_files =| folder.populate_my_folders() // sure I could do it all in one proc, but I'm not going to
		unsorted_merpies -= used_files
	/// All merp files have been sorted! Except for the ones that werent, those go in the special folder
	return unsorted_merpies

/datum/controller/subsystem/processing/merp/proc/sort_unsortable_merpies(list/unsorted_merpies)
	if(!LAZYLEN(unsorted_merpies))
		return // we're done here, all merp files have been sorted
	var/datum/merp_folder/folder = new(FATMERP_UNSORTED, null)
	merp_folders[FATMERP_UNSORTED] = folder
	folder.populate_my_files(unsorted_merpies) // they dont get subfolders cus they're unsorted
	return all_folders /// all_folders shouldnt have changed, but the contents of its contents are now populated

/// Now we just sort all the files so they're all good and neat
/datum/controller/subsystem/processing/merp/proc/sort_files_and_subfolders_in_folders()
	if(!LAZYLEN(merp_folders))
		CRASH("No filled MERP folders to sort!") // man there's a lot of stairs, huh
	for(var/folder_key in merp_folders)
		var/datum/merp_folder/folder = get_merp_folder(folder_key)
		folder.sort_everything()
	return merp_folders /// merp_folders should now be sorted
	/// Aaaaand, that should be it! We're done! We've got a nice neat pile of folders and files and everything is sorted and ready to go!

/// Digs through a given folder and assembles an actual physical box of unmentionables (merp scripts)
/datum/controller/subsystem/processing/merp/proc/show_merp_inventory(mob/living/looker, mob/living/owner, merp_folder_index)
	if(!istype(looker) || !istype(owner))
		CRASH("Invalid merper or owner given to show_merp_inventory()!")
	var/datum/merp_folder/mf = get_merp_folder(merp_folder_index)
	if(!mf)
		CRASH("Invalid merp_folder given to show_merp_inventory()!")
	//first, make the merp box
	// Actually, first check if its in their prefs to want this thing
	if(!CHECK_PREFS(looker, "[MERP_BIT_PREFERENCE]-[merp_folder_index]"))
		to_chat(looker, span_alert("You have disabled this MERP folder!"))
		return // they dont want this thing, so dont give it to them
	var/obj/item/storage/backpack/merp_box = build_merp_box(owner, mf) // its a backpack, get it?
	if(!merp_box)
		CRASH("Failed to build merp box! This is a problem! How did this happen?")
	//now, fill it with merp scripts
	// First, the back button
	add_back_button(owner, mf, merp_box)
	// Now, the scripts
	add_merpi_buttons(owner, mf, merp_box)
	/// now, show the box to the looker
	SEND_SIGNAL(merp_box, COMSIG_TRY_STORAGE_SHOW, looker, TRUE) // FORCE see it

/datum/controller/subsystem/processing/merp/proc/add_merpi_buttons(mob/living/looker, mob/living/owner, datum/merp_folder/MF, obj/item/storage/backpack/merp_box)
	if(!istype(owner) || !istype(MF) || !istype(merp_box))
		CRASH("Invalid owner or merp_folder given to add_merpi_buttons()!")
	var/list/merpis_to_add = MF.subfolders + MF.merpis
	var/looker_is_owner = (looker == owner)
	for(var/merpi_key in merpis_to_add)
		if(!CHECK_PREFS(looker, MERP_PREFCHECK_BIT(looker, merpi_key)))
			continue
		var/datum/merp_script/MS = get_merp_script(merpi_key)
		if(MS.is_private && !looker_is_owner)
			continue
		var/obj/item/merpi_bit/button/merpi_button = new(merp_box)
		merpify_item(merpi_button, owner, merpi_key)

/datum/controller/subsystem/processing/merp/proc/add_back_button(mob/living/looker, mob/living/owner, datum/merp_folder/MF, obj/item/storage/backpack/merp_box)
	if(!istype(owner) || !istype(MF))
		CRASH("Invalid owner or merp_folder given to add_back_button()!")
	var/obj/item/merpi_bit/button/back_button = new(merp_box)
	merpify_item(back_button, owner, MF.parent_folder)
	back_button.name = "Return to [name]"
	back_button.desc = "Go back to the previous folder."

/datum/controller/subsystem/processing/merp/proc/build_merp_box(mob/living/owner, datum/merp_folder/MF)
	if(!istype(owner) || !istype(MF))
		CRASH("Invalid owner or merp_folder given to build_merp_box()!")
	var/obj/item/storage/backpack/merp_box = build_merp_box(owner, MF) // its a backpack, get it?
	merp_box.name = "[owner]'s [MF.name]"
	merp_box.desc = MF.desc
	var/datum/component/storage/concrete/STR = GetComponent(/datum/component/storage/concrete)
	if(!STR)
		CRASH("Storage component not found! This is a problem! How did this happen?")
	var/num_slots = LAZYLEN(MF.merpis) + LAZYLEN(MF.folders) + 1 // +1 for the back button
	STR.max_volume = num_slots // *u
	if(num_slots > 8) // just in case someone decides to just make a folder with 1000 scripts in it
		STR.number_of_rows = round(num_slots / 8) // know what, if you *do* make a folder with a thousand scripts in it, you deserve to have the UI zoom off into infinity
	STR.max_items = num_slots
	STR.max_combined_w_class = num_slots * WEIGHT_CLASS_TINY // no way my dick is HUGE
	STR.quota = list(/obj/item/mannequin = 1) // basically block anything from going in that we didnt insert ourself. If someone manages to fit a mannequin in it, please @superlagg for a prize
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC // for my dick
	STR.max_reach = 7
	return merp_box // subscribe to merp box for monthly grab bags and goodies

/datum/controller/subsystem/processing/merp/proc/should_merp(mob/living/living_pred)
	if(!isliving(living_pred))
		return FALSE // no ghostmerp (yet)
	if(issimpleanimalmob(living_pred))
		var/mob/living/simple_animal/critter = living_pred
		if(!critter.dextrous) // you really need both hands for this
			return FALSE
	return TRUE

/datum/controller/subsystem/processing/merp/proc/get_merp_script(merp_key)
	if(!(merp_key in merp_dictionary))
		CRASH("Invalid MERP script ([merp_key]). Key wasnt in the fucking list. Uh oh!")
	var/datum/merp_script/ms = LAZYACCESS(merp_dictionary, merp_key)
	if(!istype(ms))
		CRASH("Invalid MERP script ([merp_key]). Returned a fucking null script. Uh oh!")
	return ms

/datum/controller/subsystem/processing/merp/proc/get_merp_folder(merp_key)
	if(!(merp_key in merp_dictionary))
		CRASH("Invalid MERP folder ([merp_key]). Returned a fucking null folder. Uh oh!")
	var/datum/merp_folder/mf = LAZYACCESS(merp_dictionary, merp_key)
	if(!istype(mf))
		CRASH("Invalid MERP folder ([merp_key]). Returned a fucking null folder. Uh oh!")
	return mf

/datum/controller/subsystem/processing/merp/proc/merpify_item(obj/item/merpi_bit/plapper_bit, mob/living/plapper, plapper_bit_key)
	if(!istype(plapper_bit) || !isliving(plapper))
		CRASH("Invalid arguments passed to [name] merpify_item()! [plapper_bit], [plapper], [plapper_bit_key].")
	var/datum/merp_script/ms = get_merp_script(plapper_bit_key)
	return ms.merpify_item(plapper_bit, plapper)

/datum/controller/subsystem/processing/merp/proc/get_plap_line(mob/living/plapper, mob/living/plappee, user_bit_key, target_bit_key, intent = INTENT_HELP, wielded = FALSE, quality = MERP_QUALITY_NORMAL, ci)
	if(!isliving(plapper) || !isliving(plappee) || !user_bit_key || !target_bit_key)
		CRASH("Invalid arguments passed to plap()! [plapper], [plappee], [user_bit_key], [target_bit_key], [intent], [wielded], [quality].")
	var/datum/merp_script/user_script = get_merp_script(user_bit_key)
	if(!istype(user_script))
		CRASH("Invalid MERP user script ([user_bit_key]) used to plap. Uh oh!")
	var/datum/merp_script/target_script = get_merp_script(target_bit_key)
	if(!istype(target_script))
		CRASH("Invalid MERP target script ([target_bit_key]) used to plap. Uh oh!")
	if(ci)
		return user_script.get_ci_line(plapper, plappee, target_script, quality)
	return user_script.get_usage_text(plapper, plappee, target_script, intent, wielded, quality)

/// fuckhuge lists suffer
/// These serve as simple datum management for organizing merp scripts
/// They know what folder holds them, and what folders it contains, along with its contained scripts
/datum/merp_folder
	var/index
	/// The folder index we're in. Or the root. Could be the root. could be many parents, we support extended families
	var/parent_folder
	var/list/subfolders = list()
	var/list/merpis = list() // simplex

/datum/merp_folder/New(index, my_parent)
	src.index = index
	if(!my_parent)
		my_parent = FATMERP_ROOT
	parent_folder = my_parent

/datum/merp_folder/proc/add_merpi(script_key)
	if(!istext(script_key))
		CRASH("add_merpi needs a string. given: [script_key].")
	merpi.Insert(1, script_key)

/datum/merp_folder/proc/add_subfolder(folder_key)
	if(!istext(folder_key))
		CRASH("add_script needs a string. given: [folder_key].")
	subfolders.Insert(1, folder_key)

/datum/merp_folder/proc/get_parent_folder()
	var/datum/merp_folder/parnt = SSmerp.get_merp_folder(parent_folder)
	return parnt

/datum/merp_folder/proc/populate_my_files(list/merpi_list)
	if(!LAZYLEN(SSmerp.merp_dictionary))
		CRASH("SSmerp.merp_dictionary is empty. Uh oh!")
	var/list/list_to_use = merpi_list || SSmerp.merp_dictionary
	for(var/merp_key in list_to_use)
		var/datum/merp_script/ms = LAZYACCESS(SSmerp.merp_dictionary, merp_key)
		if(!istype(ms))
			continue
		if(ms.is_container)
			continue // we dont want to add containers to the list just yet
		if(ms.parent_merpi == index)
			add_merpi(merp_key)

/datum/merp_folder/proc/populate_my_folders()
	if(!LAZYLEN(SSmerp.merp_dictionary))
		CRASH("SSmerp.merp_dictionary is empty. Uh oh!")
	for(var/merp_key in SSmerp.merp_dictionary)
		var/datum/merp_script/ms = LAZYACCESS(SSmerp.merp_dictionary, merp_key)
		if(!istype(ms))
			continue
		if(!ms.is_container)
			continue // we dont want to add non-containers to the list just yet
		if(ms.parent_merpi == index)
			add_subfolder(merp_key)

/datum/merp_folder/proc/sort_everything()
	merpis = sort_list(merpis, /proc/cmp_merp_names_asc)
	subfolders = sort_list(subfolders, /proc/cmp_merp_names_asc)

/proc/cmp_merp_names_asc(A, B)
	var/datum/merp_script/MS_A = SSmerp.get_merp_script(A)
	var/datum/merp_script/MS_B = SSmerp.get_merp_script(B)
	if(!istype(MS_A) || !istype(MS_B))
		return 0
	return sorttext("[MS_A.name]","[MS_B.name]")

/// Time to store a fuckhuge list into a fuck lesshuge datum
/// Stores all the relevant lines and such for a merpi bit
/datum/merp_script
	var/index

	var/name
	var/desc
	var/icon
	var/icon_state

	var/is_private
	var/smell
	var/taste
	var/sound

	/// Finds the MERPI bit with this key and flags it to be put into that thing
	var/parent_merpi
	/// Is a holder of MERPI bits, like Arm or Upper Body
	var/is_container
	/// If set, clicking this thing will bring up some settings
	var/option_key

	var/list/on_ci
	var/list/on_ci_flowery

	var/list/help_held_normal
	var/list/help_held_repeat
	var/list/help_held_flowery

	var/list/help_wield_normal
	var/list/help_wield_repeat
	var/list/help_wield_flowery

	var/list/disarm_held_normal
	var/list/disarm_held_repeat
	var/list/disarm_held_flowery

	var/list/disarm_wield_normal
	var/list/disarm_wield_repeat
	var/list/disarm_wield_flowery

	var/list/grab_held_normal
	var/list/grab_held_repeat
	var/list/grab_held_flowery

	var/list/grab_wield_normal
	var/list/grab_wield_repeat
	var/list/grab_wield_flowery

	var/list/harm_held_normal
	var/list/harm_held_repeat
	var/list/harm_held_flowery

	var/list/harm_wield_normal
	var/list/harm_wield_repeat
	var/list/harm_wield_flowery

	var/list/bit_used_male
	var/list/bit_used_female
	var/list/bit_used_nonbinary

	var/list/bit_climax_male
	var/list/bit_climax_female
	var/list/bit_climax_nonbinary
	/// jk its fuckhuge af

/datum/merp_script/proc/merpify_item(obj/item/merpi_bit/plapper_bit, mob/living/plapper)
	if(!istype(plapper_bit) || !istype(plapper))
		CRASH("Invalid arguments passed to [name] merpify_item()! [plapper_bit], [plapper].")
	plapper_bit.name = "[parse_merp(name, plapper)]"
	plapper_bit.desc = "[parse_merp(desc, plapper)]"
	plapper_bit.icon = icon
	plapper_bit.icon_state = icon_state
	plapper_bit.is_private = is_private
	plapper_bit.is_container = is_container
	plapper_bit.tastes = list("[parse_merp(taste, plapper)]" = 1)
	plapper_bit.merp_key = index
	plapper_bit.plapper = WEAKREF(plapper)
	return TRUE

/datum/merp_script/proc/get_ci_text(mob/living/plapper, mob/living/plappee, datum/merp_script/target_bit_datum, quality = MERP_QUALITY_NORMAL)
	if(!istype(plapper) || !istype(plappee) || !istype(target_thing))
		CRASH("Invalid arguments passed to [name] get_ci_text()! [plapper], [plappee], [target_thing].")
	var/list/lines
	switch(quality)
		if(MERP_QUALITY_NORMAL, MERP_QUALITY_REPEAT)
			lines = on_ci
		if(MERP_FLOWERY)
			lines = on_ci_flowery
	if(!lines)
		return "AAAAAAAAAAAAA"
	var/line = pick(lines)
	if(!line)
		return "RAAAAGE"
	var/parsed_line = parse_merp(line, plapper, plappee, target_thing)
	return parsed_line

/datum/merp_script/proc/get_usage_text(mob/living/plapper, mob/living/plappee, datum/merp_script/target_bit_datum, intent, wielded, quality)
	if(!istype(plapper) || !istype(plappee) || !istype(target_bit_datum))
		CRASH("Invalid arguments passed to [name] get_usage_text()! [plapper], [plappee], [target_bit_datum], [intent], [wielded], [quality].")
	var/list/lines
	switch(intent)
		if(INTENT_HELP)
			if(wielded)
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = help_wield_normal
					if(MERP_QUALITY_REPEAT)
						lines = help_wield_repeat
					if(MERP_FLOWERY)
						lines = help_wield_flowery
			else
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = help_held_normal
					if(MERP_QUALITY_REPEAT)
						lines = help_held_repeat
					if(MERP_FLOWERY)
						lines = help_held_flowery
		if(INTENT_DISARM)
			if(wielded)
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = disarm_wield_normal
					if(MERP_QUALITY_REPEAT)
						lines = disarm_wield_repeat
					if(MERP_FLOWERY)
						lines = disarm_wield_flowery
			else
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = disarm_held_normal
					if(MERP_QUALITY_REPEAT)
						lines = disarm_held_repeat
					if(MERP_FLOWERY)
						lines = disarm_held_flowery
		if(INTENT_GRAB)
			if(wielded)
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = grab_wield_normal
					if(MERP_QUALITY_REPEAT)
						lines = grab_wield_repeat
					if(MERP_FLOWERY)
						lines = grab_wield_flowery
			else
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = grab_held_normal
					if(MERP_QUALITY_REPEAT)
						lines = grab_held_repeat
					if(MERP_FLOWERY)
						lines = grab_held_flowery
		if(INTENT_HARM)
			if(wielded)
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = harm_wield_normal
					if(MERP_QUALITY_REPEAT)
						lines = harm_wield_repeat
					if(MERP_FLOWERY)
						lines = harm_wield_flowery
			else
				switch(quality)
					if(MERP_QUALITY_NORMAL)
						lines = harm_held_normal
					if(MERP_QUALITY_REPEAT)
						lines = harm_held_repeat
					if(MERP_FLOWERY)
						lines = harm_held_flowery
	var/line = pick(lines)
	var/parsed_line = parse_merp(line, plapper, plappee, target_bit_datum)
	return parsed_line

/datum/merp_script/proc/parse_merp(line, mob/living/plapper, mob/living/plappee, datum/merp_script/target_bit_datum)
	if(!line)
		return "Bingus"
	if(isliving(plapper))
		line = replacetext(line, "%USER", plapper.name)
		line = replacetext(line, "%USER_THEY", plapper.p_they())
		line = replacetext(line, "%USER_THEM", plapper.p_them())
		line = replacetext(line, "%USER_THEIR", plapper.p_their())
	if(isliving(plappee))
		line = replacetext(line, "%TARGET", plappee.name)
		line = replacetext(line, "%TARGET_THEY", plappee.p_they())
		line = replacetext(line, "%TARGET_THEM", plappee.p_them())
		line = replacetext(line, "%TARGET_THEIR", plappee.p_their())
	if(istype(target_thing))
		line = replacetext(line, "%T_PART", target_thing.name)
	line = replacetext(line, "%SRC", name)
	return line

/datum/merp_script/proc/merpify(list/my_merp, my_key)
	if(!islist(my_merp))
		message_admins("MERP ERROR: merpify() called with a non-list - [my_merp]")
		CRASH("MERP ERROR: merpify() called with a non-list - [my_merp]")
	if(!my_key)
		message_admins("MERP ERROR: merpify() called with a bad key - [my_key]")
		CRASH("MERP ERROR: merpify() called with a bad key - [my_key]")
	index = my_key
	var/list/script = my_merp
	name = LAZYACCESS(script, "merpi_name")
	desc = LAZYACCESS(script, "merpi_desc")
	icon = LAZYACCESS(script, "merpi_icon")
	icon_state = LAZYACCESS(script, "merpi_icon_state")
	is_private = LAZYACCESS(script, "merpi_is_private")
	taste = LAZYACCESS(script, "taste")
	sound = LAZYACCESS(script, "merpi_sound")

	var/list/ci_script = LAZYACCESS(script, "merpi_ci")
	on_ci = LAZYACCESS(ci_script, "merpi_normal")
	on_ci_flowery = LAZYACCESS(ci_script, "merpi_flowery")

	var/list/help_script = LAZYACCESS(script, "merpi_intent_help")
	var/list/held_stuff = LAZYACCESS(help_script, "merpi_held")
	help_held_normal = LAZYACCESS(held_stuff, "merpi_normal")
	help_held_repeat = LAZYACCESS(held_stuff, "merpi_repeat")
	help_held_flowery = LAZYACCESS(held_stuff, "merpi_flowery")
	var/list/wield_stuff = LAZYACCESS(help_script, "merpi_wielded")
	help_wield_normal = LAZYACCESS(wield_stuff, "merpi_normal")
	help_wield_repeat = LAZYACCESS(wield_stuff, "merpi_repeat")
	help_wield_flowery = LAZYACCESS(wield_stuff, "merpi_flowery")

	var/list/disarm_script = LAZYACCESS(script, "merpi_intent_disarm")
	var/list/disarm_held_stuff = LAZYACCESS(disarm_script, "merpi_held")
	disarm_held_normal = LAZYACCESS(disarm_held_stuff, "merpi_normal")
	disarm_held_repeat = LAZYACCESS(disarm_held_stuff, "merpi_repeat")
	disarm_held_flowery = LAZYACCESS(disarm_held_stuff, "merpi_flowery")
	var/list/disarm_wield_stuff = LAZYACCESS(disarm_script, "merpi_wielded")
	disarm_wield_normal = LAZYACCESS(disarm_wield_stuff, "merpi_normal")
	disarm_wield_repeat = LAZYACCESS(disarm_wield_stuff, "merpi_repeat")
	disarm_wield_flowery = LAZYACCESS(disarm_wield_stuff, "merpi_flowery")

	var/list/grab_script = LAZYACCESS(script, "merpi_intent_grab")
	var/list/grab_held_stuff = LAZYACCESS(grab_script, "merpi_held")
	grab_held_normal = LAZYACCESS(grab_held_stuff, "merpi_normal")
	grab_held_repeat = LAZYACCESS(grab_held_stuff, "merpi_repeat")
	grab_held_flowery = LAZYACCESS(grab_held_stuff, "merpi_flowery")
	var/list/grab_wield_stuff = LAZYACCESS(grab_script, "merpi_wielded")
	grab_wield_normal = LAZYACCESS(grab_wield_stuff, "merpi_normal")
	grab_wield_repeat = LAZYACCESS(grab_wield_stuff, "merpi_repeat")
	grab_wield_flowery = LAZYACCESS(grab_wield_stuff, "merpi_flowery")

	var/list/harm_script = LAZYACCESS(script, "merpi_intent_harm")
	var/list/harm_held_stuff = LAZYACCESS(harm_script, "merpi_held")
	harm_held_normal = LAZYACCESS(harm_held_stuff, "merpi_normal")
	harm_held_repeat = LAZYACCESS(harm_held_stuff, "merpi_repeat")
	harm_held_flowery = LAZYACCESS(harm_held_stuff, "merpi_flowery")
	var/list/harm_wield_stuff = LAZYACCESS(harm_script, "merpi_wielded")
	harm_wield_normal = LAZYACCESS(harm_wield_stuff, "merpi_normal")
	harm_wield_repeat = LAZYACCESS(harm_wield_stuff, "merpi_repeat")
	harm_wield_flowery = LAZYACCESS(harm_wield_stuff, "merpi_flowery")
	//cool
	return TRUE


