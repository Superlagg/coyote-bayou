/// The MERP sack, designed to hold a fuckload of MERP

/obj/item/storage/merpsack
	name = "MERP Inventory"
	desc = "Inside is the secret to a good relationship: Lots of mechanical roleplay aids. Totally not just a backpack jammed in your chest. Nope."
	icon = 'icons/effects/effects.dmi'
	icon_state = "heart"
	w_class = WEIGHT_CLASS_GIGANTIC // Lotta room for a lotta love
	interaction_flags_item = INTERACT_ITEM_ATTACK_HAND_IS_ALT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 30000
	component_type = /datum/component/storage/concrete/backpack/merp

/// MERP bag
/datum/component/storage/concrete/backpack/merp
	storage_flags = STORAGE_FLAGS_VOLUME_DEFAULT // only really here to prevent graphical dorkery
	max_items = 300
	max_w_class = 300
	max_combined_w_class = 300
	max_volume = 300
	rustle_sound = FALSE
	number_of_rows = STORAGE_ROWS_BACKPACK


