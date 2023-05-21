/datum/preferences
	/// Prefbreak stuff
	var/merp_master_toggle = TRUE
	var/merp_moan_sounds = TRUE
	var/merp_emotes = TRUE
	var/merp_plaps = TRUE
	var/merp_arousal_level_min = MERP_AROUSAL_MIN
	var/merp_arousal_level_low = MERP_AROUSAL_LOW
	var/merp_arousal_level_med = MERP_AROUSAL_MED
	var/merp_arousal_level_high = MERP_AROUSAL_HIGH
	var/merp_arousal_level_climax = MERP_AROUSAL_NEAR_CLIMAX

/datum/component/merp/proc/get_save_path(mob/living/user)
	var/client/theirclient = user?.client
	if(!theirclient)
		return FALSE
	var/ckey = theirclient.ckey
	return = "[MERP_SAVE_DIRECTORY][ckey[1]]/[ckey]/[MERP_SAVEFILE_NAME]"

/datum/component/merp/proc/save_prefs(mob/living/user)
	var/datum/preferences/pref = user?.client?.prefs
	if(!pref)
		return FALSE
	var/path = get_save_path(user)
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	WRITE_FILE(S["merp_master_toggle"], pref.merp_master_toggle)
	WRITE_FILE(S["merp_moan_sounds"], pref.merp_moan_sounds)
	WRITE_FILE(S["merp_emotes"], pref.merp_emotes)
	WRITE_FILE(S["merp_plaps"], pref.merp_plaps)
	return TRUE

/datum/component/merp/proc/load_prefs(mob/living/user)
	var/datum/preferences/pref = user?.client?.prefs
	if(!pref)
		return FALSE
	var/path = get_save_path(user)
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"
	S["merp_master_toggle"] >> pref.merp_master_toggle
	S["merp_moan_sounds"] >> pref.merp_moan_sounds
	S["merp_emotes"] >> pref.merp_emotes
	S["merp_plaps"] >> pref.merp_plaps
	return TRUE
