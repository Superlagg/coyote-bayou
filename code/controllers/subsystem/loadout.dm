SUBSYSTEM_DEF(loadouts)
	name = "Loadout"
	init_order = INIT_ORDER_LOADOUTS
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_INIT
	/// The list of all loadout categories.
	/// format = list("category" = /datum/kit_category)
	var/list/loadout_categories = list()
	/// The list of all loadouts.
	/// format = list("name" = /datum/loadout)
	var/list/loadouts = list()
	/// List of all loadout beacon lists
	/// format = list("/obj/item/kit_spawner/coolkit" = fuckhuge_list)
	var/list/loadout_beacon_lists = list()
	/// List of data relating to loadout coins
	/// format = list("coinname" = /datum/loadout_coin)
	var/list/loadout_coins = list()
	
/datum/controller/subsystem/loadouts/Initialize(timeofday)
	build_loadouts()
	. = ..()
	var/num_loadouts = LAZYLEN(loadouts)
	var/num_cats = LAZYLEN(loadout_categories)
	to_chat(world, span_boldannounce("Init'd [num_loadouts] loadouts across [num_cats] categories!"))

/datum/controller/subsystem/loadouts/proc/build_loadouts()
	for(var/some_box in subtypesof(/datum/loadout_kit))
		var/datum/loadout_kit/loadybox = new some_box()
		loadouts[loadybox.key] = loadybox
		categorize_kit(loadybox)

/datum/controller/subsystem/loadouts/proc/categorize_kit(datum/loadout_kit/loadybox)
	var/load_cat = loadybox.kit_category
	var/datum/kit_category/cat = loadout_categories[load_cat]
	if(!cat)
		cat = new /datum/kit_category(load_cat)
	cat.add_loadout(loadybox)

/datum/controller/subsystem/loadouts/proc/get_loadout_datum(loadout_key)
	if(!loadout_key)
		return
	return LAZYACCESS(loadouts, loadout_key)

/// Returns a list that loadout kits can reference to display what they have
/// format = list("category" = list("loadoutkey" = list(LOADOUT_KIT_KEY = "loadoutkey", LOADOUT_KIT_PRICE = list(coins), LOADOUT_KIT_CONTENTS = list("itemname", "itemname", ...))))
/datum/controller/subsystem/loadouts/proc/get_formatted_loadout_list(obj/item/kit_spawner/mykit)
	if(!istype(mykit))
		return
	if(LAZYACCESS(loadout_beacon_lists, "[mykit.type]"))
		return LAZYACCESS(loadout_beacon_lists, "[mykit.type]")
	var/list/list_out = list()
	for(var/boxkey in loadouts)
		var/datum/loadout_kit/loadybox = get_loadout_datum(boxkey)
		if(!loadybox)
			continue
		if(!CHECK_BITFIELD(mykit.allowed_flags, loadybox.flags))
			continue
		if(!LAZYACCESS(list_out, loadybox.kit_category))
			list_out[loadybox.kit_category] = list()
		var/list/loady_entry = list()
		loady_entry[LOADOUT_KIT_KEY] = loadybox.key
		loady_entry[LOADOUT_KIT_PRICE] = loadybox.accepted_coins
		loady_entry[LOADOUT_KIT_CONTENTS] = loadybox.box_contents
		list_out[loadybox.kit_category][loadybox.key] = loady_entry
	loadout_beacon_lists["[mykit.type]"] = list_out
	return list_out

/// Spawns the actual items from a loadout
/datum/controller/subsystem/loadouts/proc/spawn_item(kit_key, atom/spawner)
	if(!istype(spawner))
		return
	var/datum/loadout_kit/loadybox = get_loadout_datum(kit_key)
	if(!loadybox)
		return
	if(!ispath(loadybox.spawn_thing))
		CRASH("Loadout kit [loadybox.key] has invalid spawn path [loadybox.spawn_thing]! cmon man")
	var/turf/puthere = get_turf(spawner)
	if(!puthere)
		return
	var/obj/item/thing = new loadybox.spawn_thing(puthere)
	var/mob/living/wanter = locate(/mob/living) in puthere
	if(wanter)
		wanter.put_in_hands(thing)
	return TRUE

/datum/controller/subsystem/loadouts/proc/get_price(key)
	var/datum/loadout_kit/loadybox = get_loadout_datum(key)
	if(loadybox)
		return loadybox.accepted_coins
	return list()

/datum/controller/subsystem/loadouts/proc/get_coin_data(coin_key)
	var/datum/loadout_coin/coin = loadout_coins[coin_key]
	if(!coin)
		return
	var/list/coin_data = list()
	coin_data[LOADOUT_COIN_KEY] = coin.key
	coin_data[LOADOUT_COIN_NAME] = coin.name
	coin_data[LOADOUT_COIN_TOOLTIP] = coin.tooltip
	coin_data[LOADOUT_COIN_AWESOME_ICON] = coin.awesome_icon
	coin_data[LOADOUT_COIN_COLOR] = coin.color
	coin_data[LOADOUT_COIN_SUBSTITUTE_COINS] = coin.substitute_coins
	return coin_data

/datum/loadout_coin
	var/key
	var/name
	var/tooltip
	var/awesome_icon
	var/color
	/// Most coins can be spent on more than just the loadout they're for
	/// This is a list of coin keys that will accept this coin as payment
	/// Like, you can spend a standard coin on a secondary loadout, or a premium coin on a standard loadout
	/// But you can't spend a standard coin on a premium loadout, or a secondary coin on a standard loadout
	var/list/substitute_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_SECONDARY)

/datum/loadout_coin/New()
	substitute_coins |= key

/datum/loadout_coin/exquisite
	key = LOADOUT_COIN_PREMIUM
	name = "Exquisite Coin"
	tooltip = "A fancy coin that can be used to purchase exquisite loadouts. \n\n\
		Can also be used to purchase a Standard or Secondary loadout."
	awesome_icon = "fa-solid fa-gem"
	color = "#ff00ff"

/datum/loadout_coin/lawman
	key = LOADOUT_COIN_LAWMAN
	name = "Lawman Coin"
	tooltip = "A coin that can be used to purchase Lawman loadouts. \n\n\
		Can also be used to purchase a Standard or Secondary loadout."
	awesome_icon = "fa-solid fa-scale-balanced"
	color = "#0000ff"

/datum/loadout_coin/tribal
	key = LOADOUT_COIN_TRIBAL
	name = "Tribal Coin"
	tooltip = "A coin that can be used to purchase Tribal loadouts. \n\n\
		Can also be used to purchase a Standard or Secondary loadout."
	awesome_icon = "fa-solid fa-feather"
	color = "#ff0000"

/datum/loadout_coin/preacher
	key = LOADOUT_COIN_PREACHER
	name = "Preacher Coin"
	tooltip = "A coin that can be used to purchase Preacher loadouts."
	awesome_icon = "fa-solid fa-whale"
	color = "#ffffff"
	substitute_coins = list() // Preacher coins can only be spent on Preacher loadouts

/datum/loadout_coin/waster
	key = LOADOUT_COIN_WASTER
	name = "Waster Coin"
	tooltip = "A coin that can be used to purchase Waster loadouts. \n\n\
		Can also be used to purchase a Standard or Secondary loadout."
	awesome_icon = "fa-solid fa-skull"
	color = "#00ff1a"

/datum/loadout_coin/standard
	key = LOADOUT_COIN_STANDARD
	name = "Standard Coin"
	tooltip = "A coin that can be used to purchase Standard loadouts. \n\n\
		Can also be used to purchase a Secondary loadout."
	awesome_icon = "fa-solid fa-coins"
	color = "#ffff00"

/datum/loadout_coin/secondary
	key = LOADOUT_COIN_SECONDARY
	name = "Secondary Coin"
	tooltip = "A coin that can be used to purchase Secondary loadouts."
	awesome_icon = "fa-solid fa-coin"
	color = "#ff8000"
	substitute_coins = list() // Secondary coins can only be spent on Secondary loadouts

/datum/loadout_coin/tool
	key = LOADOUT_COIN_TOOL
	name = "Tool Coin"
	tooltip = "A coin that can be used to purchase Tool loadouts."
	awesome_icon = "fa-solid fa-hammer"
	color = "#00ffff"
	substitute_coins = list() // Tool coins can only be spent on Tool loadouts

/datum/kit_category
	/// The name of the category.
	var/key
	/// list of all loadouts in this category
	/// format = list("loadoutkey", "loadoutkey", ...)" 
	var/list/my_loadouts

/datum/kit_category/New(key)
	src.key = key
	SSloadouts.loadout_categories[key] = src

/datum/kit_category/proc/add_loadout(datum/loadout_kit/loadybox)
	if(!istype(loadybox))
		return
	my_loadouts |= loadybox.key
	return TRUE

