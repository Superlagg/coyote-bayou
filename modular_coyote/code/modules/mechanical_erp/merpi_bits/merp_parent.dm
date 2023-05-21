/// Hi mom, I'm a cervix! (I'm a cervix!) ///
/// the actual held item that players hold in their hands
/obj/item/merpi_bit
	name = "M-ERP-I apparatus"
	desc = "Mechanical Erotic RolePlay Interface apparatus. It's a bit."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bhole3"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	max_reach = 7 // yo my dick is looooooong
	/// The following are keys to the merpi_bit's dictionary. (get it? dictionary?)
	var/merp_key = "merp_breasts"
	var/datum/weakref/owner

/obj/item/merpi_bit/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_STORAGE_REMOVE, TRAIT_GENERIC) // its okay, it'll be forced into the owner's inventory


/obj/item/merpi_bit/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(user, COMSIG_MERP_USE_MERPI_BIT, W, src)) // Use that, on me
		return
	. = ..()

/// the button that sits in the merpi boxes and gives its corresponding merpi_bit when clicked by the owner
/// Also is treated as a merpi_bit itself when another merpi_bit is used on it
/obj/item/merpi_bit/button
	name = "M-ERP-I button"
	desc = "Mechanical Erotic RolePlay Interface button. It's a button."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bhole3"

/obj/item/merpi_bit/button/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_STORAGE_REMOVE, TRAIT_GENERIC)

/obj/item/merpi_bit/button/attack_hand(mob/user, act_intent, attackchain_flags)
	. = ..()
	var/mob/living/my_owner = owner?.resolve()
	if(!my_owner)
		return
	if(my_owner != user)
		return // we'll handle poking parts with your hand later
	SEND_SIGNAL(user, COMSIG_MERP_GIVE_HAND_BIT, user, merp_key)








