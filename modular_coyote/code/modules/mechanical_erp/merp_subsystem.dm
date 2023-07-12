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
	if(!LAZYLEN(merp_dictionary))
		return // no MERP for you
	var/list/output_list = sort_unsortables(dump_unsortables(structure_flat_folders_into_tree(sort_flat_folder_contents(populate_flat_folder_list(folderize_merp_dictionary(build_merp_dictionary())))))) // hi

/datum/controller/subsystem/processing/merp/proc/build_merp_dictionary()
	/// Yes, we are using flist to search for all our furry kinks. lets fucking go.
	var/list/all_merp_files = flist(MERP_MASTER_DIRECTORY)
	for(var/merp in all_merp_files)
		var/list/split_merp = splittext(merp, ".")
		if(LAZYLEN(split_merp) != 2)
			continue
		if(split_merp[2] != "json")
			continue
		var/merp_key = split_merp[1]
		var/list/merp_script = strings("[MERP_PATH(merp_key)]", null, TRUE)
		if(!LAZYLEN(LAZYACCESS(merp_script, "merpi_intent_help")))
			stack_trace("Invalid MERP script ([merp]) found in [MERP_MASTER_DIRECTORY]. Should probably be removed.")
			continue
		var/datum/merp_script/ms = new()
		if(!ms.merpify(merp_script, merp_key))
			stack_trace("Merpify failed for ([merp]).")
			continue
		merp_dictionary[merp_key] = ms
	return merp_dictionary

/datum/controller/subsystem/processing/merp/proc/folderize_merp_dictionary(list/merptionary)
	if(!LAZYLEN(merptionary))
		CRASH("No MERP scripts loaded!") // and thus the house of procs came crashing down into a pile of runtimes
	var/list/all_folders = list()
	for(var/merp_key in merptionary)
		var/datum/merp_script/script = get_merp_script(merp_key)
		if(!script.is_container)
			continue
		var/folder_name = script.parent_merpi
		if(LAZYACCESS(all_folders, script.index))
			stack_trace("MERP folder [folder_name] already exists! This is a problem! How did this happen?")
			continue
		var/datum/merp_folder/folder = new(merp_key, merp_key, script.parent_merpi)
		all_folders += folder
	return all_folders /// At this point, all_folders should look like: list(/datum/merp_folder/folder1, /datum/merp_folder/folder2, /datum/merp_folder/folder3, etc...)

/// This is the second step. We're going to take our flat pile of folders and put all the scripts and folders into them
/datum/controller/subsystem/processing/merp/proc/populate_flat_folder_list(list/all_folders)
	if(!LAZYLEN(all_folders))
		CRASH("No MERP folders given! We need at least one!") // oof, still got a ways to go
	var/list/allmerpi = merp_dictionary.Copy()
	for(var/datum/merp_folder/folder in all_folders)
		for(var/merp_key in allmerpi)
			var/datum/merp_script/ms = get_merp_script(merp_key)
			if(ms.parent_merpi != folder.index)
				continue
			if(ms.is_container)
				folder.add_subfolder(merp_key)
			else
				folder.add_merpi(merp_key)
			allmerpi -= merp_key
	/// Allmerpi now contains everything that couldnt be sorted into a folder
	for(var/merp_key in allmerpi)
		var/datum/merp_script/ms = get_merp_script(merp_key)
		if(ms.parent_merpi)
			continue
		var/datum/merp_folder/folder = new(merp_key, merp_key, null)
		folder.add_merpi(merp_key)
		all_folders += folder
		allmerpi -= merp_key
	return all_folders /// all_folders shouldnt have changed, but the contents of its contents are now populated

/// This is the third step. We're going to sort the contents of each folder. Easy peasy
/datum/controller/subsystem/processing/merp/proc/sort_flat_folder_contents(list/filled_folders)
	if(!LAZYLEN(filled_folders))
		CRASH("No filled MERP folders to sort!") // man there's a lot of stairs, huh
	var/list/sorted_folders = list()
	for(var/folderkey in filled_folders)
		var/list/templist = LAZYACCESS(filled_folders, folderkey)
		if(!LAZYLEN(templist))
			continue
		templist = sort_list(templist)
		sorted_folders[folderkey] = templist
	return sorted_folders /// At this point, sorted_folders should look like: list("folder1" = list("merp1", "merp2", "merp3"), "folder2" = list("merp4", "merp5", "merp6"), "folder3" = list("merp7", "merp8", "merp9"), etc...

/// This is the fourth step. We're going to take our structured folders and turn them into a tree
/// it'll be done through multiple passes. First we take one folder and treat that as our root
/// Then we search through all the folders for any that have that folder as their parent
/// Then set that folder-in-a-folder aside and repeat the process with the next folder
/// Once we've gone through all the folders, then we go through our list of folders-in-folders and repeat the process
/// We keep doing this until we have one fuckhuge tree, and no more folders or folder-in-folder-in-folders
/datum/controller/subsystem/processing/merp/proc/structure_flat_folders_into_tree(list/sorted_folders)
	if(!LAZYLEN(sorted_folders))
		CRASH("No sorted MERP folders to structure!") // Oof ouch, warned ya bro
	var/list/structured_folders = list()
	var/list/semi_structured_folders = list()
	var/list/unstrucutred_folders = sorted_folders.Copy()
	var/iterations_left = 1000 /// holy fuck dont let it get this high
	mainloop:
		while(iterations_left--)
			var/list/my_folder
			var/my_key
			var/list/mixlist
			for(var/fdd in unstrucutred_folders)
				my_folder = list(fdd = LAZYACCESS(unstrucutred_folders, fdd))
				my_key = fdd
				unstrucutred_folders -= fdd
			if(!my_folder) // huh
				continue
			for(var/maybebaby in unstrucutred_folders)
				var/datum/merp_script/ms = LAZYACCESS(merp_dictionary, maybebaby)
				if(ms.parent != my_key)
					continue
				var/list/that_folder = LAZYACCESS(unstrucutred_folders, maybebaby)
				my_folder += that_folder
				semi_structured_folders += my_folder
				continue mainloop // running theme is every time I try to make a nested loop, I figure out a better way. Here's hoping!
			












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
	var/associated_script_key
	/// The folder index we're in. Or the root. Could be the root
	var/parent_folder
	var/list/subfolders = list()
	var/list/merpis = list()

/datum/merp_folder/New(index, my_script_key, my_parent)
	src.index = index
	associated_script_key = my_script_key
	if(!my_parent)
		my_parent = FATMERP_ROOT
	parent_folder = my_parent

/datum/merp_folder/proc/add_merpi(script_key)
	if(!istext(script_key))
		CRASH("add_merpi needs a string. given: [script_key].")
	merpis[script_key] = script_key

/datum/merp_folder/proc/add_subfolder(folder_key)
	if(!istext(folder_key))
		CRASH("add_script needs a string. given: [folder_key].")
	subfolders[folder_key] = folder_key

/datum/merp_folder/proc/get_parent_folder()
	/datum/merp_folder/parnt = SSmerp.get_folder(parent_folder) // can be null, null means root
	return parnt


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
	plapper_bit.taste = list("[parse_merp(taste, plapper)]" = 1)
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


