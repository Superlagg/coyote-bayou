/// Hi mom, I'm a cervix! (I'm a cervix!) ///
#define MERP_PATH(key) "modular_coyote/code/modules/mechanical_erp/merp_strings/[key].json"

/// the actual held item that players hold in their hands
/obj/item/hand_item/merpi_bit
	name = "M-ERP-I apparatus"
	desc = "Mechanical Erotic RolePlay Interface apparatus. It's a bit."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bhole3"
	/// The following are keys to the merpi_bit's dictionary. (get it? dictionary?)
	var/merp_key = "merp_breasts"
	var/datum/weakref/owner

/obj/item/button/merpi_button
	name = "M-ERP-I button"
	desc = "Mechanical Erotic RolePlay Interface button. It's a button."

/// Dives into the merpi_bit's dictionary and transforms this thing into the thing it should be
/obj/item/hand_item/proc/merpify(m_key, mob/living/owner)
	if(!isliving(owner))
		message_admins(span_phobia("MERP ERROR: [owner] is not living! Key is [m_key]! PANIC!"))
		return
	owner = WEAKREF(owner)
	merp_key = m_key
	var/list/my_merpi = strings(MERP_PATH(merp_key), null, TRUE)
	if(!LAZYLEN(my_merpi))
		message_admins(span_phobia("MERP ERROR: No MERP found for [src]'s [merp_key]! PANIC!"))
		return
	name = my_merpi[MERPI_NAME]
	desc = my_merpi[MERPI_DESC]
	tastes = list(my_merpi[MERPI_TASTE], 1)
	RegisterSignal(src, COMSIG_MERP_USE_MERPI_BIT, .proc/perform_merp_action)
	return TRUE
	
/obj/item/hand_item/attackby(obj/item/W, mob/user, params)
	if(!W)
		return
	/// Basically reflects back the merpi bit's use to the thing that initiated the thing
	/// THis is so that we can have the merpi bit *do* an action *on* another bit, instead of it just reacting to the action
	SEND_SIGNAL(W, COMSIG_MERP_USE_MERPI_BIT, src)
	return

/// Performs the action that the merpi bit is supposed to do
/// Takes in a target part, and this does the rest
/obj/item/merpi_bit/proc/perform_merp_action(datum/source, obj/item/target_bit)
	SIGNAL_HANDLER







