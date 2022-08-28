/// Survival pouch
/obj/item/storage/survivalkit
	name = "pocket pouch"
	desc = "A robust leather pocket pouch for all the essentials for wasteland survival."
	icon_state = "survivalkit"
	component_type = /datum/component/storage/concrete/box/survivalkit
	slot_flags = ITEM_SLOT_POCKET | ITEM_SLOT_BELT

/obj/item/storage/survivalkit/PopulateContents()
	new /obj/item/flashlight(src)
	new /obj/item/flashlight/glowstick(src)
	new /obj/item/melee/onehanded/knife/hunting(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimpak/epipak(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimpak(src)
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/stack/medical/ointment(src)

/// Empty kit!
/obj/item/storage/survivalkit/empty/PopulateContents()
	return

/obj/item/storage/survivalkit/khan
	name = "survival kit"
	desc = "A robust leather pouch containing essentials a Khan might need in the wasteland."
	icon = 'icons/fallout/clothing/khans.dmi'
	icon_state = "survivalkit"

/obj/item/storage/survivalkit/khan/empty/PopulateContents()
	return

/// Tribal pouch!
/obj/item/storage/survivalkit/tribal
	name = "tribal pouch"
	desc = "A robust leather pocket pouch for all the essentials for wasteland tribal survival."
	icon_state = "survivalkit_tribal"

/obj/item/storage/survivalkit/tribal/PopulateContents()
	new /obj/item/flashlight/flare/torch(src)
	new /obj/item/flashlight/flare/torch(src)
	new /obj/item/melee/onehanded/knife/bone(src)
	new /obj/item/reagent_containers/pill/healingpowder(src)
	new /obj/item/reagent_containers/pill/healingpowder(src)
	new /obj/item/stack/medical/gauze/improvised(src)
	new /obj/item/stack/medical/mesh/aloe(src)

/obj/item/storage/survivalkit/tribal/empty/PopulateContents()
	return

/// Chieftaint pouch!
/obj/item/storage/survivalkit/tribal/chief
	name = "chieftain pouch"
	desc = "A robust leather pouch containing the essentials for wasteland survival."
	icon_state = "survivalkit_tribal"

/// Outlaw pouch!
/obj/item/storage/survivalkit/outlaw
	name = "rugged pouch"
	desc = "A robust leather pouch containing the essentials for wasteland survival."
	icon_state = "survivalkit_rugged"

/obj/item/storage/survivalkit/outlaw/PopulateContents()
	new /obj/item/flashlight(src)
	new /obj/item/flashlight/glowstick(src)
	new /obj/item/melee/onehanded/knife/bowie(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimpak/epipak(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimpak(src)
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/stack/medical/ointment(src)
	
/obj/item/storage/survivalkit/outlaw/empty/PopulateContents()
	return

/// Combat Kit!
/obj/item/storage/survivalkit/combat
	name = "combat kit"
	desc = "A robust leather kit for combat equipment."
	icon_state = "survivalkit_bullet"
	//component_type = /datum/component/storage/concrete/box/survivalkit/specialized/combat

/obj/item/storage/survivalkit/combat/empty/PopulateContents()
	return

/// Medical pouch!
/obj/item/storage/survivalkit/medical
	name = "survival medkit"
	desc = "A robust leather medipouch for quick-access medical equipment."
	icon_state = "survivalkit_medical"
	//component_type = /datum/component/storage/concrete/box/survivalkit/specialized/medical

/* /obj/item/storage/survivalkit/medical/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/stimpak/epipak(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimpak(src)
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/stack/medical/ointment(src) */

/obj/item/storage/survivalkit/medical/empty/PopulateContents()
	return

/// Follower pouch!
/obj/item/storage/survivalkit/medical/follower
	name = "pocket first-aid kit"
	desc = "A robust leather pouch containing the essentials for trauma care."
	icon_state = "survivalkit_medical"
	color = "#5dc9ff"
	//component_type = /datum/component/storage/concrete/box/survivalkit/specialized/medical

/obj/item/storage/survivalkit/medical/follower/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/stimpak/epipak(src)
	new /obj/item/stack/medical/gauze/adv(src)
	new /obj/item/stack/medical/suture/medicated(src)
	new /obj/item/stack/medical/mesh/advanced(src)

/// Tribal med pouch!
/obj/item/storage/survivalkit/medical/tribal
	name = "pocket medicine bag"
	desc = "A robust leather pouch containing the essentials for tribal trauma care."
	icon_state = "survivalkit_tribal"
	color = "#d1ffb3"
	//component_type = /datum/component/storage/concrete/box/survivalkit/specialized/medical

/* /obj/item/storage/survivalkit/medical/tribal/PopulateContents()
	new /obj/item/reagent_containers/pill/healingpowder(src)
	new /obj/item/reagent_containers/pill/healingpowder(src)
	new /obj/item/stack/medical/gauze/improvised(src)
	new /obj/item/stack/medical/mesh/aloe(src)
 */
/obj/item/storage/survivalkit/medical/tribal/empty/PopulateContents()
	return

/// Huge pouch!
/obj/item/storage/survivalkit/triple
	name = "large survival kit"
	desc = "A large, robust set of leather pouches tailored to hold lots and lots of tiny things. This one won't fit in your pocket, but it comes with straps that'll attach to most armors. Kinda makes a mess of your stuff though."
	icon_state = "survivalkit_triple"
	component_type = /datum/component/storage/concrete/box/survivalkit/triple
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/survivalkit/triple/PopulateContents()
	return
