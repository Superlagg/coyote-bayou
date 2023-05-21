/// Some would consider making a subsystem for arousal to be a waste of whatever adding on another subsystem would be a waste of
/// But mama always said, "If you're gonna make horny bullshit for a space station 13 game, put it in a subsystem."
/// time to make her proud

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
	var/list/merp_dictionary = list()

/datum/controller/subsystem/processing/merp/Initialize(start_timeofday)
	var/kinks = build_merp_dictionary()
	if(kinks)
		message_admins("MERP dictionary populated with [kinks] entries!")
	return ..()

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
			message_admins("Invalid MERP script ([merp]) found in [MERP_MASTER_DIRECTORY]. Should probably be removed.")
			continue
		var/datum/merp_script/ms = new()
		if(!ms.merpify(merp_script, merp_key))
			message_admins("Merpify failed for ([merp]).")
			continue
		merp_dictionary[merp_key] = ms
		.++

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
		CRASH("Invalid MERP script ([user_bit_key]) used to plap. Uh oh!")
	var/datum/merp_script/target_script = get_merp_script(target_bit_key)
	if(!istype(target_script))
		CRASH("Invalid MERP script ([target_bit_key]) used to plap. Uh oh!")
	if(ci)
		return user_script.get_ci_line(plapper, plappee, target_script, quality)
	return ms.get_usage_text(plapper, plappee, target_script, intent, wielded, quality)

/// Time to store a fuckhuge list into a fuck lesshuge datum
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


