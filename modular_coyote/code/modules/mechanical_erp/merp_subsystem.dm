/// Some would consider making a subsystem for arousal to be a waste of whatever adding on another subsystem would be a waste of
/// But mama always said, "If you're gonna make horny bullshit for a space station 13 game, put it in a subsystem."
/// time to make her proud

//
// MERP subsystem - Process arousal and related things
//
PROCESSING_SUBSYSTEM_DEF(merp)
	name = "M-ERP"
	priority = FIRE_PRIORITY_MERP
	wait = 1 SECONDS
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	runlevels = RUNLEVEL_GAME|RUNLEVEL_POSTGAME

/datum/controller/subsystem/processing/merp/Initialize(start_timeofday)
	build_list_of_mobtypes_that_should_vore()
	build_list_of_items_that_can_be_vored()
	return ..()

/datum/controller/subsystem/processing/merp/proc/should_merp(mob/living/living_pred)
	if(!isliving(living_pred))
		return FALSE // no ghostvore (yet)
	if(issimpleanimalmob(living_pred))
		var/mob/living/simple_animal/critter = living_pred
		if(!critter.dextrous) // you really need both hands for this
			return FALSE
	return TRUE





