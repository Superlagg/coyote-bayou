#define MERP_AROUSAL_LOW 0.05
#define MERP_AROUSAL_MED 0.35
#define MERP_AROUSAL_HIGH 0.65
#define MERP_AROUSAL_MAX 0.95
#define MERP_AROUSAL_CLIMAX 1.0

/* 
 * MERP COMPONENT FOR MOBS
 * Allows someone to participate in mechanical roleplay!
 */

// Oh yeah, with this, after this, master will be a var that is the parent
#define MERP_MASTER var/mob/living/master = parent
/// FLOORRRR MASTERRRRRR yeah nobody's gonna get that but me

/datum/component/merp // MEchanical RolePlay
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
	var/arousal = 0 // jk, its erp
	/// My arousal limit!
	var/arousal_limit = 900
	/// Emote to do when arousal is above 5%
	var/list/arousal_emote_low = list("merp" = 1) // merp
	/// Delay between autoemotes
	var/arousal_emote_low_delay = 2 SECONDS
	/// cooldown
	COOLDOWN_DECLARE(autoemote_cooldown_low)
	/// Emote to do when arousal is above 35%
	var/list/arousal_emote_med = list("merp" = 1) // merp
	/// Delay between autoemotes
	var/arousal_emote_med_delay = 2 SECONDS
	/// Emote to do when arousal is above 65%
	var/list/arousal_emote_high = list("merp" = 1) // merp
	/// Delay between autoemotes
	var/arousal_emote_high_delay = 2 SECONDS
	/// Emote to do when arousal is at limit and about to climax
	var/list/arousal_emote_max = list("merp" = 1) // merp
	/// Delay between autoemotes
	var/arousal_emote_max_delay = 2 SECONDS
	/// Emote to do when climaxing
	var/list/arousal_emote_climax = list("merp" = 1) // merp
	/// Autoemote cooldown
	/// Autoplapper vars!
	/// Are we autoplapping?
	var/autoplapper_active = FALSE
	/// Our autoplappers!
	var/list/autoplappers = list()
	/// Are we paused?
	var/paused = FALSE



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

/datum/component/merp/process()
	merp_loop()

/datum/component/merp/proc/merp_loop()
	if(!merp_mode)
		reset_merp()
		return
	MERP_MASTER
	if(auto_plapper_active)
		autoplap()
	handle_arousal()

/datum/component/merp/proc/autoplap()
	for(var/datum/autoplap/plap in autoplapper_merpi_bits)
		plap.plap() // plap plap plap

/// Automatic arousal handling
/datum/component/merp/proc/handle_arousal()
	MERP_MASTER
	if(paused)
		return
	var/arousal_percent = arousal/arousal_limit
	switch(arousal_percent)
		if(-INFINITY to MERP_AROUSAL_LOW)
			do_arousal_emote(arousal_emote_low)
		if(MERP_AROUSAL_LOW to MERP_AROUSAL_MED)
			do_arousal_emote(arousal_emote_med)
		if(MERP_AROUSAL_MED to MERP_AROUSAL_HIGH)
			do_arousal_emote(arousal_emote_high)
		if(MERP_AROUSAL_HIGH to MERP_AROUSAL_MAX)
			do_arousal_emote(arousal_emote_max)
		
/datum/component/merp/proc/do_arousal_emote(list/emote_list)
	MERP_MASTER
	if(!emote_list)
		return
	if(!COOLDOWN_FINISHED(src, autoemote_cooldown))
		return
	var/emote = emote_list[random(1, emote_list.len)]
	if(emote)
		to_chat(master, emote)
	COOLDOWN_SET(src, autoemote_cooldown, arousal_emote_low_delay)

/datum/autoplap
	var/coolname = "plap"
	var/datum/weakref/owner
	var/datum/weakref/target
	var/key
	var/intent
	var/delay
	COOLDOWN_DECLARE(plap_cooldown)

/datum/autoplap/New(mob/owner, mob/target, key, intent, delay)
	src.owner = WEAKREF(owner)
	src.target = WEAKREF(target)
	src.key = key
	src.intent = intent
	src.delay = delay

/datum/autoplap/proc/can_plap()
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	var/mob/my_target = RESOLVEWEAKREF(target)
	if(!my_owner || !my_target)
		return FALSE
	return COOLDOWN_FINISHED(src, plap_cooldown)

/datum/autoplap/proc/plap()
	if(!can_plap())
		return
	COOLDOWN_START(src, plap_cooldown, delay)
	owner.plap(target, key, intent)





