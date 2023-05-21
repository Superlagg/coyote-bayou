/// Master merp prefs
/datum/prefcheck/merp_prefs
	index = PB_MERP_MASTER
/datum/prefcheck/merp_prefs/allowed(datum/preferences/consumer)
	return consumer.merp_master_toggle // kinda vital here

/// Merp moans
/datum/prefcheck/merp_prefs/moan_sounds
	index = PB_MERP_MOAN_SOUNDS
/datum/prefcheck/merp_prefs/moan_sounds/allowed(datum/preferences/consumer)
	return consumer.merp_moan_sounds

/// Merp emotes
/datum/prefcheck/merp_prefs/emotes
	index = PB_MERP_EMOTES
/datum/prefcheck/merp_prefs/emotes/allowed(datum/preferences/consumer)
	return consumer.merp_emotes

/// Merp emotes
/datum/prefcheck/merp_prefs/plaps
	index = PB_MERP_PLAP
/datum/prefcheck/merp_prefs/plaps/allowed(datum/preferences/consumer)
	return consumer.merp_plaps

