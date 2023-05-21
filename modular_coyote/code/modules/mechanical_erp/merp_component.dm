
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
	var/plapped_history_length = 10
	/// Actions performed to us
	/// Format: list(datum/plap_record, datum/plap_record, datum/plap_record)
	var/list/plapped_history = list()
	/// My arousal!
	var/arousal = 0 // jk, its erp
	/// My arousal limit!
	var/arousal_limit = MERP_MAX_AROUSAL
	/// How much arousal we gain per second, on default speed
	var/arousal_gain_per_tick
	/// How much arousal we lose per second, on default speed
	var/arousal_loss_per_tick
	/// our arousal datums
	var/list/arousal_datums = list()
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
	RegisterSignal(parent, list(COMSIG_MERP_GIVE_HAND_BIT), .proc/give_merp_item)
	RegisterSignal(parent, list(COMSIG_MERP_DO_PLAP), .proc/plap)
	RegisterSignal(parent, list(COMSIG_MERP_GET_PLAPPED), .proc/get_plapped)
	START_PROCESSING(SSmerp, src)
	setup_merp()

/datum/component/merp/proc/setup_merp()
	MERP_MASTER
	if(!load_prefs(master))
		to_chat(master,span_phobia("ERROR: You seem to have saved MERP prefs, but they couldn't be loaded."))
	calculate_arousal_formula()
	populate_arousal_datums()

/datum/component/merp/proc/calculate_arousal_formula()
	MERP_MASTER
	var/time_per_tick = SSmerp.wait
	arousal_gain_per_tick = (MERP_MAX_AROUSAL / MERP_TIME_TO_CUM_BASE) * time_per_tick * MERP_AROUSAL_GAIN_FACTOR
	arousal_loss_per_tick = (MERP_MAX_AROUSAL / MERP_TIME_TO_CUM_BASE) * time_per_tick * MERP_AROUSAL_GAIN_FACTOR

/datum/component/merp/proc/populate_arousal_datums()
	MERP_MASTER
	for(var/aro in MERP_AROUSAL_BREAKPOINTS)
		var/datum/merp_arousal/arouse = new(text2num(aro))
		arousal_datums[aro] = new()

/// SEE [modular_coyote\code\modules\mechanical_erp\merp_preferences.dm] for save/load code

/datum/component/merp/process()
	merp_loop()

/datum/component/merp/proc/merp_loop()
	if(!merp_mode)
		reset_merp()
		return
	MERP_MASTER
	if(autoplapper_active)
		autoplap()
	handle_arousal()

/datum/component/merp/proc/autoplap()
	for(var/datum/merp_autoplap/plapper in autoplappers)
		plapper.autoplap() // plap plap plap

/// Automatic arousal handling
/datum/component/merp/proc/handle_auto_arousal()
	MERP_MASTER
	if(paused)
		return
	if(last_plap_still_fresh())
		adjust_arousal(arousal_gain_per_tick)
	else
		adjust_arousal(-arousal_loss_per_tick)
	if(arousal >= MERP_AROUSAL_NEAR_CLIMAX)
		ready_to_climax()
	var/datum/merp_arousal/arouse = get_arousal_datum()
	
/datum/component/proc/get_arousal_datum()
	MERP_MASTER
	var/datum/merp_arousal/arouse = LAZYACCESS(arousal_datums, "[MERP_AROUSAL_MIN]")
	for(var/aro in arousal_datums)
		var/aro_num = text2num(aro)
		if(arousal >= aro_num)
			arouse = arousal_datums[aro]
		else
			break
	return arouse

/datum/component/merp/proc/give_merp_item(datum/source, merpi_key)
	if(!merpi_key)
		return
	MERP_MASTER
	if(master.get_active_held_item() && master.get_inactive_held_item())
		to_chat(master, span_alert("Your hands are full!"))
		return
	var/obj/item/merpi_bit/bit = new(master)
	if(!master.put_in_hands(bit, TRUE))
		to_chat(master, span_alert("You couldn't get it in your hand!"))
		return
	if(!merpify(bit, merpi_key))
		to_chat(master, span_phobia("Merpification failed! Call a coder!"))
		stack_trace("Merpification failed! [master] tried to merpify [bit] with key [merpi_key].")
		qdel(bit)
		return
	to_chat(master, span_love("You ready your [bit]!"))

/datum/component/merp/proc/merpify(obj/item/merpi_bit/bit, merpi_key)
	MERP_MASTER
	if(!isliving(master))
		message_admins(span_phobia("MERP ERROR: [master] is not living! Key is [merpi_key]! PANIC!"))
		CRASH("MERP ERROR: [master] is not living! Key is [merpi_key]! PANIC!")
		return
	if(!SSmerp.merpify_item(bit, master, merpi_key))
		CRASH("MERP ERROR: [master] tried to merpify [bit] with key [merpi_key], but it failed!")
	return TRUE

/* 
 * Makes the owner plap the target with the given intent.
 * * datum/source - The source of the plap. Just a formality of signals, not actually relied on.
 * * mob/living/plapper - The mob doing the plapping.
 * * mob/living/plapped - The mob being plapped.
 * * obj/item/merpi_bit/plapped_part - The part of the plapped that is being plapped.
 * * plapper_key - The key of the plapper.
 * * intent - The intent of the plap.
 * * wielded - Whether or not the plapper is wielding the plapped part.
 * * quality - The quality of the plap.
 * * ci - The CI of the plap.
 */
/datum/component/merp/proc/plap(datum/source, mob/living/plappee, user_bit_key, target_bit_key, intent, wielded, quality = MERP_QUALITY_NORMAL, ci)
	SIGNAL_HANDLER
	MERP_MASTER
	if(!isliving(plappee) || !user_bit_key || !target_bit_key)
		return
	if(isnull(intent))
		intent = master.a_intent
	if(isnull(wielded))
		var/obj/item/bit = master.get_active_held_item()
		if(!bit)
			wielded = FALSE // fuck it whatever
		else
			wielded = bit.wielded
	var/merp_message = SSmerp.get_plap_line(master, plappee, user_bit_key, target_bit_key, intent, wielded, quality, ci)
	if(!merp_message)
		return
	master.visible_message(merp_message, pref_check = PB_MERP_PLAP)
	var/base_arousal = SEND_SIGNAL(plappee, COMSIG_MERP_GET_PLAPPED, master, user_bit_key, target_bit_key, intent, wielded, quality, ci)
	return TRUE

/datum/component/merp/proc/get_plapped(datum/source, mob/living/plapper, user_bit_key, target_bit_key, intent, wielded, quality = MERP_QUALITY_NORMAL, ci)
	SIGNAL_HANDLER
	MERP_MASTER
	if(!isliving(plapper) || !user_bit_key || !target_bit_key)
		return
	if(isnull(intent))
		intent = plapper.a_intent
	if(isnull(wielded))
		var/obj/item/bit = plapper.get_active_held_item()
		if(!bit)
			wielded = FALSE // fuck it whatever
		else
			wielded = bit.wielded
	var/base_arousal 




/datum/merp_autoplap
	var/coolname = "plap"
	var/datum/weakref/owner
	var/datum/weakref/target
	var/key
	var/intent
	var/wielded
	var/delay
	COOLDOWN_DECLARE(plap_cooldown)

/datum/merp_autoplap/New(mob/owner, mob/target, key, intent, wielded, delay)
	src.owner = WEAKREF(owner)
	src.target = WEAKREF(target)
	src.key = key
	src.intent = intent
	src.wielded = wielded
	src.delay = delay

/datum/merp_autoplap/proc/can_plap()
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	var/mob/my_target = RESOLVEWEAKREF(target)
	if(!my_owner || !my_target)
		return FALSE
	return COOLDOWN_FINISHED(src, plap_cooldown)

/datum/merp_autoplap/proc/autoplap()
	if(!can_plap())
		return
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	var/mob/my_target = RESOLVEWEAKREF(target)
	if(!my_owner || !my_target)
		return MERP_AP_DELETEME
	SEND_SIGNAL(my_owner, COMSIG_MERP_DO_PLAP, my_target, key, intent, wielded, MERP_QUALITY_REPEAT, FALSE)
	COOLDOWN_START(src, plap_cooldown, delay)


/// A record of a plap someone made to its owner.
/datum/merp_plap_record
	var/datum/weakref/owner
	var/datum/weakref/plapper
	var/plap_name
	var/key
	var/intent
	var/last_plap = 0

/datum/merp_plap_record/New(mob/living/meatwall)
	if(!isliving(meatwall))
		qdel(src)
		return
	owner = WEAKREF(meatwall)

/datum/merp_plap_record/proc/record_plap(mob/living/plapper, key, plap_name, intent)
	if(!plapper || !key || !intent)
		return
	if(!plap_name)
		var/list/merpscript = strings(MERP_PATH(key), null, TRUE)
		plap_name = LAZYACCESS(merpscript, MERPI_NAME)
		if(!plap_name)
			message_admins(span_phobia("MERP ERROR: No MERP cool name found for [plapper]'s merp_key '[key]' when they plapped! PANIC!"))
			return
	src.plapper = WEAKREF(plapper)
	src.plap_name = plap_name
	src.key = key
	src.intent = intent
	src.last_plap = world.time
	return TRUE

/datum/merp_plap_record/proc/plap_still_fresh()
	if(!plapper)
		return FALSE
	if(last_plap + PLAP_FRESH_TIME > world.time)
		return TRUE
	return FALSE

/datum/merp_arousal
	var/datum/weakref/owner
	var/list/emote_list
	var/emote_cooldown
	COOLDOWN_DECLARE(emote_cd)
	var/list/moan_list
	var/moan_cooldown
	COOLDOWN_DECLARE(moan_cd)

/datum/merp_arousal/New(
	mob/owner,
	list/emote_list = list(),
	emote_cooldown,
	list/moan_list = list(),
	moan_cooldown)
	src.owner = WEAKREF(owner)
	src.emote_list = emote_list
	src.emote_cooldown = emote_cooldown

/datum/merp_arousal/proc/can_emote()
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	if(!my_owner)
		return FALSE
	return COOLDOWN_FINISHED(src, emote_cd)

/datum/merp_arousal/proc/do_emote()
	if(!can_emote())
		return
	COOLDOWN_START(src, emote_cd, emote_cooldown)
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	if(!my_owner)
		return
	var/emote = pick(emote_list)
	if(!emote)
		return
	my_owner.emote(emote)
	return TRUE

/datum/merp_arousal/proc/can_moan()
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	if(!my_owner)
		return FALSE
	return COOLDOWN_FINISHED(src, moan_cd)

/datum/merp_arousal/proc/do_moan()
	if(!can_moan())
		return
	COOLDOWN_START(src, moan_cd, moan_cooldown)
	var/mob/my_owner = RESOLVEWEAKREF(owner)
	if(!my_owner)
		return
	var/moan = pick(moan_list)
	if(!moan)
		return
	playsound(my_owner, moan, 40, TRUE, soundpref_index = PB_MERP_MOAN_SOUNDS)
	return TRUE


