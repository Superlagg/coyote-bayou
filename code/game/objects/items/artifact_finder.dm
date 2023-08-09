#define ARFI_SEARCH_COMMON (1 << 0)
#define ARFI_SEARCH_UNCOMMON (1 << 1)
#define ARFI_SEARCH_RARE (1 << 2)
#define ARFI_SEARCH_ALL (ARFI_SEARCH_COMMON | ARFI_SEARCH_UNCOMMON | ARFI_SEARCH_RARE)

#define ARFI_ACC_LOW 1
#define ARFI_ACC_LOW_ROUNDTO 50
#define ARFI_ACC_LOW_SCANTIME (1 SECONDS)
#define ARFI_ACC_LOW_UPGRADE_TIME (5 MINUTES)
#define ARFI_ACC_MEDIUM 2
#define ARFI_ACC_MEDIUM_ROUNDTO 10
#define ARFI_ACC_MEDIUM_SCANTIME (10 SECONDS)
#define ARFI_ACC_MEDIUM_UPGRADE_TIME (10 MINUTES)
#define ARFI_ACC_HIGH 3
#define ARFI_ACC_HIGH_ROUNDTO 1
#define ARFI_ACC_HIGH_SCANTIME (30 SECONDS)
#define ARFI_ACC_LVL1_TIME_DIVISOR 1
#define ARFI_ACC_LVL2_TIME_DIVISOR 2
#define ARFI_ACC_LVL3_TIME_DIVISOR 5

#define ARFI_SCAN_IDLE "scan_not_started"
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

/obj/item/artifact_finder/ui_data(mob/user)
	var/list/data = list()
	data["memory_data"] = list()
	for(var/datum/artifact_tracker_data/ATD in memory)
		data["memory_data"][ATD.art_tag] = ATD.get_ui_data()
	data["current"] = current_artifact // is an art_tag
	data["stats"] = list()
	data["stats"]["scan_time"] = scan_time
	data["stats"]["level"] = lvl
	data["stats"]["max_memory"] = max_memory
	data["stats"]["can_common"] = CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_COMMON)
	data["stats"]["can_uncommon"] = CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_UNCOMMON)
	data["stats"]["can_rare"] = CHECK_BITFIELD(unlocked_rarities, ARFI_SEARCH_RARE)
	data["stats"]["scan_common"] = CHECK_BITFIELD(scan_for, ARFI_SEARCH_COMMON)
	data["stats"]["scan_uncommon"] = CHECK_BITFIELD(scan_for, ARFI_SEARCH_UNCOMMON)
	data["stats"]["scan_rare"] = CHECK_BITFIELD(scan_for, ARFI_SEARCH_RARE)
	data["stats"]["paper_left"] = LAZYLEN(papers)
	data["stats"]["paper_max"] = max_papers
	return data
	
/obj/item/artifact_finder/ui_act(action, params)
	. = ..()
	switch(action)
		if("remove_entry")
			remove_entry(params["entry"])
		if("update_entry")
			update_entry(params["entry"])
		if("enhance")
			enhance(params["entry"])
			



/obj/item/artifact_finder/proc/login_to_artifact_tracker(mob/living/user, username)
	if(!user)
		return
	var/artkey = SSartifacts.tracker_login(user)
	if(!artkey)
		return
	

///////////////////////////////////////////////
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
	var/z_disp
	var/rarity
	var/magnitude // pop pop
	var/last_updated
	var/score = 0
	var/discoverer_ckey
	var/discoverer_name
	var/is_missing = FALSE
	var/scanning_until = 0
	var/current_accuracy
	var/scanning_accuracy

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
			z_disp = z_coord
		if(ARFI_ACC_MED)
			x_roundup = CEILING(x_coord, ARFI_ACC_MED_ROUNDTO)
			x_rounddown = FLOOR(x_coord, ARFI_ACC_MED_ROUNDTO)
			y_roundup = CEILING(y_coord, ARFI_ACC_MED_ROUNDTO)
			y_rounddown = FLOOR(y_coord, ARFI_ACC_MED_ROUNDTO)
			z_disp = CEILING(z_coord, ARFI_ACC_MED_ROUNDTO)
		if(ARFI_ACC_HIGH)
			x_roundup = CEILING(x_coord, ARFI_ACC_HIGH_ROUNDTO)
			x_rounddown = FLOOR(x_coord, ARFI_ACC_HIGH_ROUNDTO)
			y_roundup = CEILING(y_coord, ARFI_ACC_HIGH_ROUNDTO)
			y_rounddown = FLOOR(y_coord, ARFI_ACC_HIGH_ROUNDTO)
			z_disp = CEILING(z_coord, ARFI_ACC_HIGH_ROUNDTO)

/datum/artifact_tracker_data/proc/discover(mob/living/discoverer)
	if(!istype(discoverer) || !discoverer.client)
		return
	var/d_ckey = discoverer.ckey
	var/d_name = discoverer.name
	if(d_ckey == discoverer_ckey || d_name == discoverer_name)
		return
	discoverer_ckey = d_ckey
	discoverer_name = d_name
	SSartifacts.discover_artifact(art_tag, art_name, discoverer)

/datum/artifact_tracker_data/proc/start_scan(accuracy)
	if(scanning_until > world.time)
		return
	if(accuracy <= current_accuracy)
		switch(current_accuracy)
			if(ARFI_ACC_LOW)
				scanning_until = (world.time + ARFI_RESCAN_TIME_LOW)
			if(ARFI_ACC_MED)
				scanning_until = (world.time + ARFI_RESCAN_TIME_MED)
			if(ARFI_ACC_HIGH)
				scanning_until = (world.time + ARFI_RESCAN_TIME_HIGH)
		scanning_accuracy = current_accuracy
		return scanning_until
	switch(accuracy)
		if(ARFI_ACC_LOW)
			scanning_until = (world.time + ARFI_SCAN_TIME_LOW)
		if(ARFI_ACC_MED)
			scanning_until = (world.time + ARFI_SCAN_TIME_MED)
		if(ARFI_ACC_HIGH)
			scanning_until = (world.time + ARFI_SCAN_TIME_HIGH)
	scanning_accuracy = accuracy
	return scanning_until

/datum/artifact_tracker_data/proc/stop_scan()
	scanning_until = 0

/datum/artifact_tracker_data/proc/check_scan()
	if(scanning_until == 0)
		return ARFI_SCAN_IDLE
	if(scanning_until > world.time)
		return ARFI_SCAN_RUNNING
	update()
	return ARFI_SCAN_IDLE

/datum/artifact_tracker_data/proc/scan_timeleft()
	if(scanning_until == 0 || scanning_until < world.time)
		scanning_until = 0
		return 0
	return (scanning_until - world.time)

/datum/artifact_tracker_data/proc/get_ui_data()
	var/list/data = list()
	data["art_tag"] = art_tag
	data["art_name"] = art_name
	data["x_coord"] = x_coord
	data["y_coord"] = y_coord
	data["z_coord"] = z_coord
	data["x_roundup"] = x_roundup
	data["x_rounddown"] = x_rounddown
	data["y_roundup"] = y_roundup
	data["y_rounddown"] = y_rounddown
	data["z_disp"] = z_disp
	data["rarity"] = rarity
	data["magnitude"] = magnitude
	data["last_updated"] = last_updated
	data["score"] = score
	data["discoverer_ckey"] = discoverer_ckey
	data["discoverer_name"] = discoverer_name
	data["scan"] = list()
	var/scanstate = check_scan()
	if(scanstate == ARFI_SCAN_IDLE)
		data["scan"]["state"] = "Idle"
		data["scan"]["timeleft"] = "N/A"
		data["scan"]["acc"] = "N/A"
		data["scan"]["acc_name"] = "N/A"
		data["scan"]["acc_roundto"] = "N/A"
		data["scan"]["acc_rescan"] = "N/A"
		if(current_accuracy >= ARFI_ACC_LOW)
			data["scan"]["acc_roundto"] = "+-[ARFI_ACC_LOW_ROUNDTO]"
			data["scan"]["acc_rescan"] = TRUE
			data["scan"]["acc_lo_scan_time"] = 
	else if(scanstate == ARFI_SCAN_RUNNING)
		data["scan"]["state"] = "Scanning"
		data["scan"]["timeleft"] = DisplayTimeText(scan_timeleft(), show_zeroes = TRUE, abbreviated = TRUE, fixed_digits = TRUE)
		var/accname = "FUZZY"
		switch(scanning_accuracy)
			if(ARFI_ACC_LOW)
				accname = "LOW"
			if(ARFI_ACC_MED)
				accname = "MED"
			if(ARFI_ACC_HIGH)
				accname = "HIGH"
		data["scan"]["acc"] = accname
		data["scan"]["acc_rescan"] = current_accuracy == scanning_accuracy
	return data













/obj/effect/temp_visual/detector_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "freon"
	appearance_flags = 0 //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35









