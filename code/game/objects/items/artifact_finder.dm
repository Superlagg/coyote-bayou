#define ARFI_SEARCH_COMMON (1 << 0)
#define ARFI_SEARCH_UNCOMMON (1 << 1)
#define ARFI_SEARCH_RARE (1 << 2)
#define ARFI_SEARCH_ALL (ARFI_SEARCH_COMMON | ARFI_SEARCH_UNCOMMON | ARFI_SEARCH_RARE)

#define ARFI_ACC_LOW 1
#define ARFI_ACC_LOW_ROUNDTO 75
#define ARFI_RESCAN_TIME_LOW (1 SECONDS)
#define ARFI_ACC_LOW_UPGRADE_TIME (10 MINUTES)

#define ARFI_ACC_MEDIUM 2
#define ARFI_ACC_MEDIUM_ROUNDTO 15
#define ARFI_RESCAN_TIME_MED (10 SECONDS)
#define ARFI_ACC_MEDIUM_UPGRADE_TIME (10 MINUTES)

#define ARFI_ACC_HIGH 3
#define ARFI_ACC_HIGH_ROUNDTO 1
#define ARFI_RESCAN_TIME_HIGH (30 SECONDS)

#define ARFI_LVL1_TIME_DIVISOR 1
#define ARFI_LVL2_TIME_DIVISOR 2
#define ARFI_LVL3_TIME_DIVISOR 5

#define ARFI_SCAN_IDLE "scan_not_started"
#define ARFI_SCAN_ENHANCING "scan_enhancing"
#define ARFI_SCAN_UPDATING "scan_updating"
#define ARFI_SCAN_IN_PROGRESS "scan_in_progress"
#define ARFI_SCAN_COMPLETE "scan_complete"
#define ARFI_SCAN_FINALIZED "scan_finalized"

/// Click it to send a ping to its chosen artifact, or just some random one I guess
/// Altclick it to bring up a TGUI window to select an artifact to ping
/// Can hold up to 10 artifacts in memory at once
/obj/item/artifact_finder
	name = "\improperGekkertech Artifinder"
	desc = "A device that can be used to find artifacts."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer"
	w_class = WEIGHT_CLASS_SMALL
	var/username
	/// format: list("artifact_tag", "artifact_tag", ...)
	var/list/catalogued = list()
	/// format: list("artifact_tag" = /datum/artifact_tracker_data, ...)
	var/list/memory = list()
	var/lvl = 1
	var/unlocked_rarities = ARFI_SEARCH_COMMON
	var/scan_for = ARFI_SEARCH_COMMON
	var/current_artifact = null
	var/max_memory = 3
	var/currently_scanning = FALSE
	var/scan_time = 3 SECONDS
	var/scan_started_time = 0
	var/scan_cooldown_time = 10 SECONDS
	var/datum/weakref/scan_turf
	var/list/papers = list()
	var/max_paper = 5
	var/start_paper = 5
	var/ui_top_panel = FALSE
	COOLDOWN_DECLARE(scan_cooldown)

/obj/item/artifact_finder/Initialize(mapload)
	. = ..()
	for(var/i in 1 to start_paper)
		papers += new /obj/item/paper(src)

/obj/item/artifact_finder/proc/ping(mob/user)
	if(!user)
		return
	if(!COOLDOWN_FINISHED(src, scan_cooldown))
		return
	if(currently_scanning)
		return
	area_scan(user)
	// if(!current_artifact)
	// 	return
	// var/datum/weakref/thingy = LAZYACCESS(memory, current_artifact)
	// var/obj/item/arti = GET_WEAKREF(thingy)
	// if(!arti)
	// 	return
	// var/turf/here = get_turf(src)
	// var/turf/there = get_turf(arti)
	// var/angle = Get_Angle(here, there)
	// angle += rand(-5, 5)

/obj/item/artifact_finer/AltClick(mob/user)
	. = ..()
	ping(user)

/obj/item/artifact_finder/proc/area_scan(mob/user)
	if(!user)
		return
	SSeffects.expanding_ring(get_turf(src), 4, 0.5 SECONDS)
	var/list/arts = list()
	for(var/obj/item/I in range(5, get_turf(src)))
		if(SEND_SIGNAL(I, COMSIG_ITEM_ARTIFACT_EXISTS))
			arts += I
	if(LAZYLEN(arts))
		for(var/obj/item/arty in arts)
			var/obj/effect/temp_visual/detector_overlay/oldC = locate(/obj/effect/temp_visual/detector_overlay) in M
			if(oldC)
				qdel(oldC)
			new /obj/effect/temp_visual/detector_overlay(M)

/obj/item/artifact_finder/proc/start_scan()
	if(!COOLDOWN_FINISHED(src, scan_cooldown))
		return
	if(currently_scanning)
		return
	currently_scanning = TRUE
	addtimer(CALLBACK(src, .proc/gather_artifacts), scan_time)

/obj/item/artifact_finder/proc/gather_artifacts()
	if(LAZYLEN(memory) >= max_memory)
		return
	var/wantnum = max_memory - LAZYLEN(memory)
	if(wantnum > max_memory || wantnum <= 0)
		return
	COOLDOWN_START(src, scan_cooldown, scan_cooldown_time)
	var/list/found = list()
	var/list/to_search = list()
	if(CHECK_BITFIELD(scan_for, ARFI_SEARCH_COMMON) && CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_COMMON))
		to_search += SSartifacts.common_artifacts
	if(CHECK_BITFIELD(scan_for, ARFI_SEARCH_UNCOMMON) && CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_UNCOMMON))
		to_search += SSartifacts.uncommon_artifacts
	if(CHECK_BITFIELD(scan_for, ARFI_SEARCH_RARE) && CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_RARE))
		to_search += SSartifacts.rare_artifacts
	var/iter_left = 1000
	while(iter_left-- > 0 && LAZYLEN(found) < wantnum && LAZYLEN(to_search) > 0)
		var/art_tag = pick(to_search)
		if(art_tag in memory)
			to_search -= art_tag
			continue
		var/obj/item/thing = GET_WEAKREF(LAZYACCESS(SSartifacts.all_artifacts, art_tag))
		if(!thing)
			to_search -= art_tag
			continue
		found += arti
		var/datum/artifact_tracker_data/track = new /datum/artifact_tracker_data(arti)
		memory[art_tag] = track
		if(LAZYLEN(found) >= wantnum)
			break
	currently_scanning = FALSE
	return LAZYLEN(found)

/obj/item/artifact_finder/proc/remove_entry(entry)
	if(!entry || current_artifact == entry)
		return
	var/datum/artifact_tracker_data/track = LAZYACCESS(SSartifacts.all_artifacts, entry)
	if(!track)
		return
	track.remove()
	qdel(track)
	memory -= entry

/obj/item/artifact_finder/proc/update_entry(entry)
	if(!entry)
		return
	var/datum/artifact_tracker_data/track = LAZYACCESS(SSartifacts.all_artifacts, entry)
	if(!track)
		return
	track.update()

/obj/item/artifact_finder/proc/enhance(entry)
	if(!entry)
		return
	var/datum/artifact_tracker_data/track = LAZYACCESS(SSartifacts.all_artifacts, entry)
	if(!track)
		return
	return track.enhance()

/obj/item/artifact_finder/proc/get_pos_xy()
	var/turf/here = get_turf(src)
	var/x_high = 0
	var/x_low = 0
	var/y_high = 0
	var/y_low = 0
	var/err
	switch(lvl)
		if(1)
			x_high = CEILING(here.x, ARFI_ACC_LOW_ROUNDTO)
			x_low = FLOOR(here.x, ARFI_ACC_LOW_ROUNDTO)
			y_high = CEILING(here.y, ARFI_ACC_LOW_ROUNDTO)
			y_low = FLOOR(here.y, ARFI_ACC_LOW_ROUNDTO)
			err = ARFI_ACC_LOW_ROUNDTO
		if(2)
			x_high = CEILING(here.x, ARFI_ACC_MED_ROUNDTO)
			x_low = FLOOR(here.x, ARFI_ACC_MED_ROUNDTO)
			y_high = CEILING(here.y, ARFI_ACC_MED_ROUNDTO)
			y_low = FLOOR(here.y, ARFI_ACC_MED_ROUNDTO)
			err = ARFI_ACC_MED_ROUNDTO
		if(3)
			x_high = CEILING(here.x, ARFI_ACC_HIGH_ROUNDTO)
			x_low = FLOOR(here.x, ARFI_ACC_HIGH_ROUNDTO)
			y_high = CEILING(here.y, ARFI_ACC_HIGH_ROUNDTO)
			y_low = FLOOR(here.y, ARFI_ACC_HIGH_ROUNDTO)
			err = ARFI_ACC_HIGH_ROUNDTO
	return "X: [x_low]:[x_high], Y: [y_low]:[y_high] ± [err]m"

/obj/item/artifact_finder/proc/get_z_level()
	return "Region: [z2text(get_turf(src))]"

/obj/item/artifact_finder/proc/get_exp_list()
	var/list/out = list()
	out["exp_total"] = exp_total // the displayed total
	out["exp_total_max"] = exp_total_max // the displayed max
	out["exp_lvl"] = exp_this_level // the value for the bar's position
	out["exp_lvl_max"] = exp_next_level // the value for the bar's max
	return out

/obj/item/artifact_finder/proc/get_scan_data()
	var/list/out = list()
	out["scanning"] = currently_scanning
	out["memory_full"] = LAZYLEN(memory) >= max_memory
	out["time_max"] = scan_time
	out["time_curr"] = ((world.time - scan_started_time) / 10)
	out["can_common"] = CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_COMMON)
	out["can_uncommon"] = CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_UNCOMMON)
	out["can_rare"] = CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_RARE)
	out["scan_common"] = CHECK_BITFIELD(scan_for, ARFI_SEARCH_COMMON)
	out["scan_uncommon"] = CHECK_BITFIELD(scan_for, ARFI_SEARCH_UNCOMMON)
	out["scan_rare"] = CHECK_BITFIELD(scan_for, ARFI_SEARCH_RARE)

/obj/item/artifact_finder/proc/toggle_flag(flag)

/obj/item/artifact_finder/proc/clear_memory()

/obj/item/artifact_finder/proc/eject_a_paper()
	if(!LAZYLEN(papers))
		audible_message("[src] makes a faint whirr.")
		return
	var/obj/item/paper/paper = LAZYACCESS(papers, 1)

/obj/item/artifact_finder/ui_data(mob/user)
	var/list/data = list()
	data["memory_data"] = list()
	for(var/datum/artifact_tracker_data/ATD in memory)
		data["memory_data"][ATD.art_tag] = ATD.get_ui_data()
	data["current"] = current_artifact // is an art_tag
	data["pos_xy"] = get_pos_xy()
	data["pos_error"] = get_pos_error()
	data["region"] = get_z_level()
	data["level"] = lvl
	data["exp"] = get_exp_list()
	data["scan_data"] = get_scan_data()
	data["max_memory"] = max_memory
	data["num_memory"] = LAZYLEN(memory)
	data["paper_left"] = LAZYLEN(papers)
	data["paper_max"] = max_papers
	data["score"] = SSartifacts.get_score(username)
	data["scoretotal"] = SSartifacts.get_score(username, TRUE)
	data["username"] = get_username()
	return data
	
/obj/item/artifact_finder/ui_act(action, params)
	. = ..()
	switch(action)
		if("leaderboard")
			SSartifacts.show_leaderboard(usr)
		if("start_scan")
			start_scan()
		if("toggle_common")
			toggle_flag(ARFI_SEARCH_COMMON)
		if("toggle_uncommon")
			toggle_flag(ARFI_SEARCH_UNCOMMON)
		if("toggle_rare")
			toggle_flag(ARFI_SEARCH_RARE)
		if("clear")
			clear_memory()
		if("eject")
			eject_a_paper()
		if("discard")
			remove_entry(params["discard"])
		if("update_coords")
			update_entry(params["update_coords"])
		if("enhance")
			enhance(params["enhance"])
		if("print")
			print(params["print"])

/obj/item/artifact_finder/proc/login_to_artifact_tracker(mob/living/user, username)
	if(!user)
		return
	var/artkey = SSartifacts.tracker_login(user)
	if(!artkey)
		return
	

///////////////////////////////////////////////////////////atom
//////////////////////////////////////////////////////////atom
/////////////////////////////////////////////////////////atom
////////////////////////////////////////////////////////atom
///////////////////////////////////////////////////////atom
/datum/artifact_tracker_data
	var/art_tag
	var/art_name
	var/x_coord
	var/y_coord
	var/z_coord
	var/x_roundup
	var/x_rounddown
	var/y_roundup
	var/y_rounddown
	var/rarity
	var/magnitude // pop pop
	var/last_updated
	var/score = 0
	var/discoverer_ckey
	var/discoverer_name
	var/is_missing = FALSE
	var/enhancing_until = 0
	var/enhance_duration = 0
	var/updating_until = 0
	var/update_duration = 0
	var/current_accuracy

/datum/artifact_tracker_data/New(obj/item/thing)
	if(!istype(thing))
		CRASH("Artifact tracker data created for non-item [thing]")
	var/datum/component/artifact/art = thing.GetComponent(/datum/component/artifact)
	if(!art)
		CRASH("Artifact tracker data created for non-artifact item [thing]")
	art_tag = art.my_cool_id
	art_name = art.get_name_string()
	rarity = art.rarity
	magnitude = art.get_highest_magnitude()
	score = art.get_score()
	update()
	. = ..()

/datum/artifact_tracker_data/proc/update()
	var/obj/item/thing = SSartifacts.get_artifact(art_tag)
	if(!thing)
		is_missing = TRUE
		return
	. = TRUE
	var/turf/there = get_turf(thing)
	x_coord = there.x
	y_coord = there.y
	z_coord = there.z
	last_updated = world.time
	switch(current_accuracy)
		if(ARFI_ACC_LOW)
			x_roundup = CEILING(x_coord, ARFI_ACC_LOW_ROUNDTO)
			x_rounddown = FLOOR(x_coord, ARFI_ACC_LOW_ROUNDTO)
			y_roundup = CEILING(y_coord, ARFI_ACC_LOW_ROUNDTO)
			y_rounddown = FLOOR(y_coord, ARFI_ACC_LOW_ROUNDTO)
		if(ARFI_ACC_MED)
			x_roundup = CEILING(x_coord, ARFI_ACC_MED_ROUNDTO)
			x_rounddown = FLOOR(x_coord, ARFI_ACC_MED_ROUNDTO)
			y_roundup = CEILING(y_coord, ARFI_ACC_MED_ROUNDTO)
			y_rounddown = FLOOR(y_coord, ARFI_ACC_MED_ROUNDTO)
		if(ARFI_ACC_HIGH)
			x_roundup = CEILING(x_coord, ARFI_ACC_HIGH_ROUNDTO)
			x_rounddown = FLOOR(x_coord, ARFI_ACC_HIGH_ROUNDTO)
			y_roundup = CEILING(y_coord, ARFI_ACC_HIGH_ROUNDTO)
			y_rounddown = FLOOR(y_coord, ARFI_ACC_HIGH_ROUNDTO)

/datum/artifact_tracker_data/proc/discover(mob/living/discoverer)
	if(!istype(discoverer) || !discoverer.client)
		return
	return SSartifacts.discover_artifact(art_tag, art_name, discoverer)

/datum/artifact_tracker_data/proc/is_discovered(art_tag)
	return SSartifacts.is_discovered(art_tag)

/// Updates our data on the artifact, and returns TRUE if we're done
/datum/artifact_tracker_data/proc/start_update(lvl)
	if(update_timeleft())
		return
	var/divizer = 1
	var/timedo
	switch(lvl)
		if(1)
			divizer = ARFI_LVL1_TIME_DIVISOR
		if(2)
			divizer = ARFI_LVL2_TIME_DIVISOR
		if(3)
			divizer = ARFI_LVL3_TIME_DIVISOR
	switch(current_accuracy)
		if(ARFI_ACC_LOW)
			timedo = (ARFI_RESCAN_TIME_LOW / divizer)
		if(ARFI_ACC_MED)
			timedo = (ARFI_RESCAN_TIME_MED / divizer)
		if(ARFI_ACC_HIGH)
			timedo = (ARFI_RESCAN_TIME_HIGH / divizer)
	COOLDOWN_START(src, updating_until, timedo)
	addtimer(CALLBACK(src, .proc/finish_update), timedo)
	update_duration = timedo
	return TRUE

/datum/artifact_tracker_data/proc/update_timeleft()
	if(updating_until == 0 || updating_until < world.time)
		updating_until = 0
		return 0
	return (updating_until - world.time)

/datum/artifact_tracker_data/proc/finish_update()
	updating_until = 0
	update()

/// Starts enhancing the resolution on the scan, and returns the time it'll take to finish
/datum/artifact_tracker_data/proc/start_enhance(lvl)
	if(accuracy >= ARFI_ACC_HIGH)
		return
	if(!enhance_timeleft())
		return
	var/divizer = 1
	var/timedo
	switch(lvl)
		if(1)
			divizer = ARFI_LVL1_TIME_DIVISOR
		if(2)
			divizer = ARFI_LVL2_TIME_DIVISOR
		if(3)
			divizer = ARFI_LVL3_TIME_DIVISOR
	switch(current_accuracy)
		if(ARFI_ACC_LOW)
			timedo = (ARFI_ACC_LOW_UPGRADE_TIME / divizer)
		if(ARFI_ACC_MED)
			timedo = (ARFI_ACC_MEDIUM_UPGRADE_TIME / divizer)
	COOLDOWN_START(src, enhancing_until, timedo)
	addtimer(CALLBACK(src, .proc/finish_enhance), timedo)
	enhance_duration = timedo
	return TRUE

/datum/artifact_tracker_data/proc/check_enhance()
	if(enhancing_until == 0 || enhancing_until < world.time)
		enhancing_until = 0
		return 0
	return (enhancing_until - world.time)

/datum/artifact_tracker_data/proc/finish_enhance()
	enhancing_until = 0
	current_accuracy++
	update() // throw in a free update, for free

/datum/artifact_tracker_data/proc/get_discover_text()
	if(!discoverer_name)
		return "Not Yet Discovered!"
	return "Discovered by: [discoverer_name]"

/datum/artifact_tracker_data/proc/get_ui_data()
	var/list/data = list()
	data["art_name"] = art_name
	data["x_read"] = "X [x_roundup]:[x_rounddown]"
	data["y_read"] = "Y [y_roundup]:[y_rounddown]"
	data["z_disp"] = z2text(z_coord)
	var/rarty = rarity
	switch(accuracy)
		if(ARFI_ACC_LOW)
			if(rarty != ART_RARITY_COMMON)
				rarty = ART_RARITY_COMMON
		if(ARFI_ACC_MED)
			if(rarty == ART_RARITY_RARE)
				rarty = ART_RARITY_UNCOMMON
	data["rarity"] = rarty
	var/update_time = update_timeleft()
	data["is_updating"] = !!update_time
	data["update_timeleft"] = !!update_time ? "Updated [DisplayTimeText(update_time, show_zeroes = TRUE, abbreviated = TRUE, fixed_digits = 2)] ago" | "N/A"
	data["update_progress"] = update_duration ? ((update_duration - update_time) / update_duration) * 100 : 0
	data["time_since_update"] = "Last Update: [DisplayTimeText(world.time - last_updated, show_zeroes = TRUE, abbreviated = TRUE, fixed_digits = 2)]"
	var/enhance_time = enhance_timeleft()
	data["can_enhance"] = (current_accuracy < ARFI_ACC_HIGH)
	data["enhancing"] = !!enhance_time
	data["enhance_timeleft"] = !!enhance_time ? "Enhancing: [DisplayTimeText(enhance_time, show_zeroes = TRUE, abbreviated = TRUE, fixed_digits = 2)]" | "N/A"
	data["enhance_progress"] = enhance_duration ? ((enhance_duration - enhance_time) / enhance_duration) * 100 : 0
	var/acc = "Unknown"
	switch(current_accuracy)
		if(ARFI_ACC_LOW)
			acc = "VAGUE - 75m Accuracy"
		if(ARFI_ACC_MED)
			acc = "FUZZY - 15m Accuracy"
		if(ARFI_ACC_HIGH)
			acc = "PRECISE - 1m Accuracy"
	data["enhance_text"] = "Signal Strength: [acc]"
	data["disco_text"] = get_discover_text()
	return data












/obj/effect/temp_visual/detector_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "freon"
	appearance_flags = 0 //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35









