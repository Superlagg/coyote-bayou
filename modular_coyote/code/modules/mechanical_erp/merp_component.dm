/* 
 * MERP COMPONENT FOR MOBS
 * Allows someone to participate in mechanical roleplay!
 */

// Oh yeah, with this, after this, master will be a var that is the parent
#define MERP_MASTER var/mob/living/master = parent
/// FLOORRRR MASTERRRRRR yeah nobody's gonna get that but me

/datum/component/merp
	/// We merpin?
	var/merp_mode = FALSE
	/// People whitelisted to merp with us any time~
	var/list/merp_whitelist = list()
	/// Our box of MERPI bits
	var/obj/item/storage/merpsack/merp_bits = list()
	/// Actions we've taken
	var/list/merp_actions = list()
	/// Actions done to us
	var/list/merp_actions_done = list()
	/// My arousal!
	var/arousal = 0
	/// My arousal limit!
	var/arousal_limit = 1000
	/// Emote to do when arousal is above 5%
	var/list/arousal_emote_low = list("merp" = 1) // merp
	/// Emote to do when arousal is above 35%
	var/list/arousal_emote_med = list("merp" = 1) // merp
	/// Emote to do when arousal is above 65%
	var/list/arousal_emote_high = list("merp" = 1) // merp
	/// Emote to do when arousal is at limit and about to climax
	var/list/arousal_emote_max = list("merp" = 1) // merp
	/// Emote to do when climaxing
	var/list/arousal_emote_climax = list("merp" = 1) // merp



/datum/component/merp/Initialize()
	if(!SSmerp.should_merp(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_MOB_CLIENT_LOGIN), .proc/setup_merp)
	START_PROCESSING(SSmerp, src)

/datum/component/merp/proc/setup_merp(force)
	MERP_MASTER
	setup_verbs()
	if(!load_prefs())
		to_chat(master,span_phobia("ERROR: You seem to have saved vore prefs, but they couldn't be loaded."))
	if(LAZYLEN(vore_organs))
		vore_selected = vore_organs[1]

/datum/component/merp/proc/load_prefs()


