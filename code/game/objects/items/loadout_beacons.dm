/* LIST STRUCTURELOADOUT_ROOT
 * list encodes "tag" = list(LOADOUT_BITFIELD = a bitfield, LOADOUT_CLASS = melee, LOADOUT_PATH = the path)
 */

GLOBAL_LIST_EMPTY(loadout_datums)
GLOBAL_LIST_EMPTY(loadout_boxes)

/obj/item/kit_spawner
	name = "kit spawner!"
	desc = "Some kind of kit spawner!"
	icon = 'icons/obj/crates.dmi' //old weapon crate uses this. good enough for a gun case
	icon_state = "weaponcrate"
	item_state = "syringe_kit" //old weapon crate used this. I'm not familiar enough to know if there's something better
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi' //taken from briefcase code, should look okay for an inhand
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	/// these flags define what show up in the kit spawner menu thing
	var/allowed_flags = NONE
	/// What loadout coins we have left to spend
	/// format: list("coin_name", ...)
	var/list/loadout_coins = list(LOADOUT_COIN_STANDARD)
	/// Currently chosen category
	var/current_category
	/// Currently chosen loadout
	var/current_loadout_key
	/// Our contents have been spent, time to return to our home planet
	var/my_home_planet_needs_me

/obj/item/kit_spawner/Initialize()
	. = ..()
	/// We'll access this later
	SSloadouts.get_formatted_loadout_list(src)

/obj/item/kit_spawner/proc/get_user()
	var/mob/living/user = recursive_loc_search(src, /mob/living, 5, TRUE)
	return user

/obj/item/kit_spawner/proc/purchase_kit(kit_key, coin)
	var/mob/living/user = get_user()
	if(my_home_planet_needs_me)
		return FALSE
	if(!loadout_is_accessible(kit_key))
		if(user)
			to_chat(user, span_alert("That loadout is not available!"))
		return
	if(!spend_coin(user, coin, kit_key))
		return
	var/turf/spawn_here = get_turf(src)
	var/obj/item/cool_thing = SSloadouts.spawn_item(kit_key, spawn_here)
	if(!cool_thing)
		give_coin(coin) // cool refund
		return FALSE
	give_receipt(user, cool_thing, coin)
	current_loadout_key = null
	INVOKE_ASYNC(src, .proc/return_to_home_planet)
	return TRUE

/// I have to go now, my planet needs me
/obj/item/kit_spawner/proc/return_to_home_planet()
	if(!my_home_planet_needs_me)
		return
	/// Make it travel up and away
	disappear_up_and_away(delete_on_end = TRUE)
	/// my stupid kit spawner died on its way back to its home planet

/obj/item/kit_spawner/proc/spend_coin(mob/living/user, coin, kit_key)
	if(!(coin in loadout_coins))
		if(user)
			to_chat(user, span_alert("You don't have that coin!"))
		return FALSE
	if(!can_afford(kit_key, coin))
		if(user)
			to_chat(user, span_alert("You can't afford that loadout!"))
		return FALSE
	loadout_coins -= coin
	if(!loadout_coins)
		my_home_planet_needs_me = TRUE

/obj/item/kit_spawner/proc/give_coin(coin)
	loadout_coins += coin
	if(LAZYLEN(loadout_coins))
		my_home_planet_needs_me = FALSE

/obj/item/kit_spawner/proc/give_receipt(turf/right_here, obj/item/bought, coin_spent = "broke-ass penny")
	if(!bought)
		return
	var/list/my_coin = SSloadouts.get_coin_data(coin_spent)
	var/coiname = LAZYACCESS(my_coin, LOADOUT_COIN_NAME)
	if(!right_here)
		right_here = get_turf(src)
	if(!coiname)
		coiname = span_phobia("2521 Double-Nullref Imcoder Quarter")
	var/mob/living/buyer = get_user()
	if(buyer)
		to_chat(buyer, span_green("You bought \a [bought] with \a [coiname]!"))

/obj/item/kit_spawner/proc/can_afford(kitkey, coin)
	if(!kitkey || !coin || !(coin in loadout_coins))
		return FALSE
	var/list/coin_data = SSloadouts.get_coin_data(coin)
	if(!LAZYLEN(coin_data))
		return FALSE
	var/list/suitable_subs = LAZYACCESS(coin_data, LOADOUT_COIN_SUBSTITUTE_COINS)
	if(!LAZYLEN(suitable_subs))
		return FALSE
	return (coin in suitable_subs)

/obj/item/kit_spawner/proc/get_cats(list/mybiglist)
	if(LAZYLEN(mybiglist))
		return list()
	var/list/cats = list()
	for(var/loadya in mybiglist)
		cats += loadya
	return cats

/obj/item/kit_spawner/proc/loadout_is_accessible(loadout_key)
	if(!current_category)
		return FALSE
	var/list/loadout_table = SSloadouts.get_formatted_loadout_list(src)
	if(LAZYACCESSASSOC(loadout_table, current_category, loadout_key))
		return TRUE
	return FALSE

/obj/item/kit_spawner/proc/get_loadout_coins()
	var/list/shiny_coins = list()
	for(var/coin in loadout_coins)
		shiny_coins += SSloadouts.get_coin_data(coin)
	return shiny_coins

/obj/item/kit_spawner/ui_status(mob/user, datum/ui_state/state)
	//bye!
	if(my_home_planet_needs_me)
		return UI_CLOSE
	if(loc != user)
		return UI_CLOSE
	return ..()

/obj/item/kit_spawner/can_interact(mob/user)
	if(loc != user)
		return FALSE
	return ..()

/obj/item/kit_spawner/ui_interact(mob/user, datum/tgui/ui)
	// Update the UI
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutKitMain", name)
		ui.open()

/obj/item/kit_spawner/ui_data()
	if(my_home_planet_needs_me)
		return
	var/list/data = list()
	data["KitName"] = name
	var/list/my_table = SSloadouts.get_formatted_loadout_list(src)
	var/list/categories = get_cats(my_table)
	data["AllCategories"] = categories
	data["CurrentCategory"] = current_category // if null, it'll show the list of categories
	data["CurrentLoadout"] = current_loadout_key
	data["LoadoutTable"] = my_table
	data["Coins"] = get_loadout_coins()
	return data

/obj/item/kit_spawner/ui_act(action, params)
	if(..())
		return
	if(my_home_planet_needs_me)
		return
	var/mob/living/user = usr
	if(!Adjacent(user))
		return
	var/list/my_table = SSloadouts.get_formatted_loadout_list(src)
	switch(action)
		if("SetCategory")
			if(params["KitCategory"] in get_cats(my_table))
				current_category = params["KitCategory"]
			else
				current_category = null
			. = TRUE
		if("ClearCategory")
			current_category = null
			. = TRUE
		if("SetLoadout")
			var/my_loadout = params["KitKey"]
			if(loadout_is_accessible(my_loadout))
				current_loadout_key = params["KitKey"]
			. = TRUE
		if("ClearLoadout")
			current_loadout_key = null
			. = TRUE
		if("BuyLoadout")
			var/my_loadout = params["BuyKey"]
			var/pay_with = params["CoinToSpend"]
			if(!purchase_kit(my_loadout, pay_with))
				to_chat(user, span_alert("Something went wrong!"))
			current_loadout_key = null


// /obj/item/kit_spawner/proc/build_loadout_list()
// 	if(LAZYLEN(GLOB.loadout_datums))
// 		return
// 	for(var/some_box in subtypesof(/datum/loadout_kit))
// 		var/datum/loadout_kit/loadybox = some_box
// 		GLOB.loadout_datums[initial(loadybox.key)] = list(LOADOUT_BITFIELD = initial(loadybox.flags), LOADOUT_CLASS = initial(loadybox.kit_category), LOADOUT_PATH = initial(loadybox.spawn_thing))

// /obj/item/kit_spawner/proc/build_output_list()
// 	if(!LAZYLEN(GLOB.loadout_datums))
// 		build_loadout_list()
// 		return
// 	if(LAZYLEN(GLOB.loadout_boxes[type])) // already init'd!
// 		return
// 	var/list/list_of_stuff = list()
// 	for(var/loadya in LOADOUT_ALL_ENTRIES)
// 		var/list/list2add = list()
// 		for(var/loadies in GLOB.loadout_datums)
// 			if(GLOB.loadout_datums[loadies][LOADOUT_CLASS] == loadya && CHECK_BITFIELD(GLOB.loadout_datums[loadies][LOADOUT_BITFIELD], allowed_flags))
// 				list2add[loadies] = GLOB.loadout_datums[loadies][LOADOUT_PATH]
// 		if(LAZYLEN(list2add))
// 			if(!islist(list_of_stuff[loadya]))
// 				list_of_stuff[loadya] = list()
// 			list2add = sort_list(list2add)
// 			list_of_stuff[loadya] |= list2add
// 	if(LAZYLEN(list_of_stuff))
// 		GLOB.loadout_boxes[type] = list_of_stuff
// 		log_admin("[src] initialized successfully!")
// 	else
// 		message_admins(span_phobia("Hey Lagg, [src] didnt initialize right. The list is empty! point and laugh"))

// /obj/item/kit_spawner/attack_self(mob/user)
// 	if(can_use_kit(user))
// 		use_the_kit(user)

// /obj/item/kit_spawner/proc/can_use_kit(mob/living/user)
// 	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
// 		return TRUE
// 	playsound(src, 'sound/machines/synth_no.ogg', 40, 1)
// 	return FALSE

// /obj/item/kit_spawner/proc/use_the_kit(mob/living/user)
// 	if(!LAZYLEN(GLOB.loadout_boxes[type]))
// 		build_output_list()
// 		if(!LAZYLEN(GLOB.loadout_boxes[type]))
// 			message_admins(span_phobia("Hey Lagg, [src] didnt set up its lists, like, at all. And cant!. The list is empty! point and laugh"))
// 	var/first_key
// 	var/list/first_list
// 	if(LAZYLEN(loadout_coins))
// 		first_key = input(user, "Pick a category!", "Pick a category!") as null|anything in loadout_coins
// 		if(!first_key)
// 			user.show_message(span_alert("Invalid selection!"))
// 			return
// 		if(!LAZYLEN(loadout_coins[first_key]))
// 			user.show_message(span_phobia("Whoever set up [src] didn't set up the multiple choice list right! there should be a list here, and there isnt one! this is a bug~"))
// 			return
// 		first_list = loadout_coins[first_key]
// 		// Filter out anything from the first list that isnt in the second list. & might work, were I cleverer
// 		for(var/in_it in first_list)
// 			if(!(in_it in GLOB.loadout_boxes[type]))
// 				first_list -= in_it
// 	else
// 		first_list = GLOB.loadout_boxes[type]
// 	var/one_only
// 	//first, show the player the root menu! ROOT is just a list of strings
// 	var/second_key
// 	if(LAZYLEN(first_list) > 1)
// 		second_key = input(user, "Pick a category!", "Pick a category!") as null|anything in first_list
// 	else
// 		for(var/choosething in first_list)
// 			if(choosething)
// 				second_key = choosething
// 		one_only = TRUE
// 	if(!second_key)
// 		user.show_message(span_alert("Invalid selection!"))
// 		return
// 	user.show_message("[second_key] selected!")
// 	/// now the actual gunweapon! entries are formatted as "thingname" = path
// 	var/final_key
// 	if(LAZYLEN(GLOB.loadout_boxes[type][second_key]) == 1 && one_only)
// 		for(var/choosethinge in GLOB.loadout_boxes[type][second_key])
// 			if(choosethinge)
// 				final_key = choosethinge
// 	else
// 		final_key = input(user, "Pick a weapon!", "Pick a weapon!") as null|anything in GLOB.loadout_boxes[type][second_key]
// 	if(!check_choice(GLOB.loadout_boxes[type][second_key][final_key]))
// 		user.show_message(span_alert("Invalid selection!"))
// 		return
// 	//user.show_message("[final_key] selected!")
// 	if(!spawn_the_thing(user, GLOB.loadout_boxes[type][second_key][final_key]))
// 		user.show_message(span_alert("Couldn't get the thing out of the case. Try again?"))
// 		return
// 	if(first_key && (first_key in loadout_coins))
// 		loadout_coins[first_key] = null
// 		loadout_coins -= first_key
// 	if(LAZYLEN(loadout_coins) < 1)
// 		qdel(src)


// /obj/item/kit_spawner/proc/check_choice(choice_to_check)
// 	if(!choice_to_check)
// 		return FALSE
// 	if(!ispath(choice_to_check))
// 		return FALSE
// 	return TRUE

// /obj/item/kit_spawner/proc/hax_check()
// 	if(max_items <= 0)
// 		qdel(src)
// 		return FALSE

// /obj/item/kit_spawner/proc/spawn_the_thing(mob/user, atom/the_thing)
// 	hax_check()
// 	max_items--
// 	var/turf/spawn_here
// 	spawn_here = user ? get_turf(user) : get_turf(src)
// 	var/obj/item/new_thing = new the_thing(spawn_here)
// 	if(istype(new_thing))
// 		user.show_message(span_green("You pull \a [new_thing.name] out of [src]."))
// 		return TRUE

/obj/item/kit_spawner/waster
	name = "Wasteland survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/raider
	name = "Rugged survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/raider/doctor
	name = "Rugged survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/raider/civvy
	name = "Rugged survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/raider/boss
	name = "Ruggedest survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM | LOADOUT_FLAG_TRIBAL
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/townie
	name = "Civilian survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/townie/doctor
	name = "Medical survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/townie/barkeep
	name = "Barkeep survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL

/obj/item/kit_spawner/townie/banker
	name = "Banker survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/townie/trader
	name = "Trader survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/townie/mayor
	name = "Mayoral survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/follower
	name = "Volunteer survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER

/obj/item/kit_spawner/follower/guard
	name = "Guard survival kit"
	desc = "Packed with the essentials: Some kind of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_SECONDARY)

/obj/item/kit_spawner/follower/doctor
	name = "Doctor survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER

/obj/item/kit_spawner/follower/scientist
	name = "Science survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER

/obj/item/kit_spawner/follower/admin
	name = "Science survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/bos
	name = "Techy survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/bos/boss
	name = "Techy survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/bos/combat
	name = "Techy survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_LAWMAN | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_LAWMAN)

/obj/item/kit_spawner/bos/scientist
	name = "Techy survival kit"
	desc = "Packed with the essentials: Some kind of cool weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/preacher
	name = "Spiritual survival kit"
	desc = "Packed with the essentials: Some kind of weapon, and a cool holy stick."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL | LOADOUT_FLAG_PREACHER
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREACHER)

/obj/item/kit_spawner/lawman
	name = "Lawman equipment kit"
	desc = "Loaded with two sets of weapon."
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_LAWMAN
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_LAWMAN)

/obj/item/kit_spawner/lawman/sheriff
	name = "Sheriff equipment kit"
	desc = "Now with access to better things!"
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_LAWMAN
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_LAWMAN)

/obj/item/kit_spawner/premium
	name = "Premium equipment kit"
	desc = "Some of the fanciest guns known to the wastes!"
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_PREMIUM
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_PREMIUM)

/obj/item/kit_spawner/tribal
	name = "Tribal equipment kit"
	desc = "Primitive equipment for a primitive person!"
	allowed_flags = LOADOUT_FLAG_TRIBAL
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_TRIBAL)

/obj/item/kit_spawner/tribal/farlands
	name = "Farlands tribal equipment kit"
	desc = "Primitive equipment for a primitive person!"
	allowed_flags = LOADOUT_FLAG_TRIBAL | LOADOUT_FLAG_WASTER
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_TRIBAL)

/obj/item/kit_spawner/debug_waster
	name = "waster kit spawner!"
	desc = "Some kind of kit spawner!"
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_LAWMAN | LOADOUT_FLAG_TRIBAL | LOADOUT_FLAG_PREACHER
	loadout_coins = list(LOADOUT_COIN_STANDARD, LOADOUT_COIN_TRIBAL, LOADOUT_COIN_LAWMAN, LOADOUT_COIN_PREMIUM, LOADOUT_COIN_PREACHER, LOADOUT_COIN_SECONDARY)

/obj/item/kit_spawner/debug_waster_lawman
	name = "waster kit spawner!"
	desc = "Some kind of kit spawner!"
	/// these flags plus whatever's picked in the root menu = what we're allowed to spawn, easy peasy
	allowed_flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_LAWMAN

/obj/item/kit_spawner/debug_tribal
	name = "waster kit spawner!"
	desc = "Some kind of kit spawner!"
	/// these flags plus whatever's picked in the root menu = what we're allowed to spawn, easy peasy
	allowed_flags = LOADOUT_FLAG_TRIBAL


/obj/item/storage/box/gun
	name = "weapon case"
	desc = "a sturdy case keeping your weapon of choice safe until you pop it open."
	icon = 'icons/obj/crates.dmi' //old weapon crate uses this. good enough for a gun case
	icon_state = "weaponcrate"
	item_state = "syringe_kit" //old weapon crate used this. I'm not familiar enough to know if there's something better
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi' //taken from briefcase code, should look okay for an inhand
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	component_type = /datum/component/storage/concrete/box

/obj/item/storage/box/gun/update_icon_state()
	if(contents.len == 0)
		qdel(src)



/// Guns for the LAWman
/obj/item/storage/box/gun/law
	name = "American 180 case" //it was meant to be a police rifle anyways~
	w_class = WEIGHT_CLASS_BULKY //most will be rifles

/obj/item/storage/box/gun/law/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/american180(src)
	new /obj/item/ammo_box/magazine/m22smg/empty(src) //you get a ton of ammo already
	new /obj/item/ammo_box/m22(src) //but just in case you get unlucky...

/obj/item/storage/box/gun/law/smg10mm
	name = "10mm smg case"

/obj/item/storage/box/gun/law/smg10mm/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/smg10mm(src)
	new /obj/item/ammo_box/magazine/m10mm/adv/ext(src)
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/law/commando
	name = "commando carbine case"

/obj/item/storage/box/gun/law/commando/PopulateContents()
	new /obj/item/gun/ballistic/automatic/delisle/commando(src)
	new /obj/item/ammo_box/magazine/m45/socom(src)
	new /obj/item/ammo_box/c45(src)

/obj/item/storage/box/gun/law/combat //luv u scryden
	name = "combat carbine case"

/obj/item/storage/box/gun/law/combat/PopulateContents()
	new /obj/item/gun/ballistic/automatic/combat(src)
	new /obj/item/ammo_box/magazine/tommygunm45/stick(src)
	new /obj/item/ammo_box/c45(src)

/obj/item/storage/box/gun/law/service
	name = "service rifle case"

/obj/item/storage/box/gun/law/service/PopulateContents()
	new /obj/item/gun/ballistic/automatic/service(src)
	new /obj/item/ammo_box/magazine/m556/rifle(src)
	new /obj/item/ammo_box/a556(src)

/obj/item/storage/box/gun/law/policerifle
	name = "police rifle case"

/obj/item/storage/box/gun/law/policerifle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/marksman/policerifle(src)
	new /obj/item/ammo_box/magazine/m556/rifle(src)
	new /obj/item/ammo_box/a556(src)

/obj/item/storage/box/gun/law/assault_carbine
	name = "assault carbine case" //police assault rifle is stronger, not sure which they should have

/obj/item/storage/box/gun/law/assault_carbine/PopulateContents()
	new /obj/item/gun/ballistic/automatic/assault_carbine(src)
	new /obj/item/ammo_box/magazine/m5mm(src)
	new /obj/item/ammo_box/m5mmbox(src)

/obj/item/storage/box/gun/law/mk23 //not a whole rifle, but a really good pistol if you track down your own rifle
	name = "Tactical MK-23 case"
	w_class = WEIGHT_CLASS_NORMAL //only normal sized law gun

/obj/item/storage/box/gun/law/mk23/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/mk23(src)
	new /obj/item/ammo_box/magazine/m45/socom(src)
	new /obj/item/ammo_box/c45(src)

/obj/item/storage/box/gun/law/trail
	name = "trail carbine case"

/obj/item/storage/box/gun/law/trail/PopulateContents()
	new /obj/item/gun/ballistic/rifle/repeater/trail(src)
	new /obj/item/ammo_box/tube/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/law/police
	name = "police shotgun case"

/obj/item/storage/box/gun/law/police/PopulateContents()
	new /obj/item/gun/ballistic/shotgun/police(src)
	new /obj/item/ammo_box/shotgun/buck(src) //eeeevery flavor
	new /obj/item/ammo_box/shotgun/bean(src)
	new /obj/item/ammo_box/shotgun/rubber(src) //make sure these are okay

/obj/item/storage/box/gun/rifle/brushgun
	name = "brush gun case"

/obj/item/storage/box/gun/rifle/brushgun/PopulateContents()
	new /obj/item/gun/ballistic/rifle/repeater/brush(src)
	new /obj/item/ammo_box/c4570box(src)

/obj/item/storage/box/gun/rifle/junglecarbine
	name = "jungle carbine case"

/obj/item/storage/box/gun/rifle/junglecarbine/PopulateContents()
	new /obj/item/gun/ballistic/rifle/enfield/jungle(src)
	new /obj/item/ammo_box/a308(src)
	new /obj/item/ammo_box/a308box(src)

/obj/item/storage/box/gun/rifle/smle
	name = "lee-enfield case"

/obj/item/storage/box/gun/rifle/smle/PopulateContents()
	new /obj/item/gun/ballistic/rifle/enfield(src)
	new /obj/item/ammo_box/a308(src)
	new /obj/item/ammo_box/a308box(src)

/obj/item/storage/box/gun/aer9
	name = "laser rifle case"

/obj/item/storage/box/gun/aer9/PopulateContents()
	new /obj/item/gun/energy/laser/aer9(src)
	new /obj/item/stock_parts/cell/ammo/mfc(src)
	new /obj/item/stock_parts/cell/ammo/mfc(src)

/// Premium guns!

/obj/item/storage/box/gun/premium/maria //fancier guns, for high rank roles
	name = "Maria case" //maria might not should be allowed, cause meant to be unique, but will see
	w_class = WEIGHT_CLASS_NORMAL //all neat and tidy pistols

/obj/item/storage/box/gun/premium/maria/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/ninemil/maria(src)
	new /obj/item/ammo_box/magazine/m9mm/doublestack(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/premium/automatic //beretta m93r, but keeping the naming scheme I got
	name = "Beretta M93R case" //might be stronk, might need to not take greasegun mags, will see

/obj/item/storage/box/gun/premium/automatic/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/beretta/automatic(src)
	new /obj/item/ammo_box/magazine/m9mm/doublestack(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/premium/executive //good to be here till we get the vault back
	name = "the Executive case"

/obj/item/storage/box/gun/premium/executive/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/n99/executive(src)
	new /obj/item/ammo_box/magazine/m10mm/adv/simple(src)
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/premium/crusader
	name = "Crusader pistol case"

/obj/item/storage/box/gun/premium/crusader/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/n99/crusader(src)
	new /obj/item/ammo_box/magazine/m10mm/adv/simple(src)
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/premium/sig //can downgrade to whatever the trusty sig p220 is for. it has slightly lower fire rate
	name = "Sig P220 case"

/obj/item/storage/box/gun/premium/sig/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/sig(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/c45(src)

/obj/item/storage/box/gun/premium/custom
	name = "M1911 Custom case"

/obj/item/storage/box/gun/premium/custom/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911/custom(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/c45(src)

//mk23 and magnum semi-autos are just a liiiiittle too chonky for this list

/obj/item/storage/box/gun/premium/mateba //ugh, fiiiiiiiine you can have your dumb coolness revolver, if you're the right rank~
	name = "Unica 6 case"

/obj/item/storage/box/gun/premium/mateba/PopulateContents()
	new /obj/item/gun/ballistic/revolver/colt357/mateba(src)
	new /obj/item/ammo_box/a357(src)
	new /obj/item/ammo_box/a357box(src)
	new /obj/item/ammo_box/a357/ratshot(src)

/obj/item/storage/box/gun/premium/lucky //not sure if this should be allowed, or if is supposed to be unique
	name = ".357 magnum revolver case"

/obj/item/storage/box/gun/premium/lucky/PopulateContents()
	new /obj/item/gun/ballistic/revolver/colt357/lucky(src)
	new /obj/item/ammo_box/a357(src)
	new /obj/item/ammo_box/a357box(src)
	new /obj/item/ammo_box/a357/ratshot(src)

/obj/item/storage/box/gun/premium/alt //pearly .44 mag
	name = "pearl .44 magnum case"

/obj/item/storage/box/gun/premium/alt/PopulateContents()
	new /obj/item/gun/ballistic/revolver/m29/alt(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/premium/peacekeeper
	name = "Peacekeeper case"

/obj/item/storage/box/gun/premium/peacekeeper/PopulateContents()
	new /obj/item/gun/ballistic/revolver/m29/peacekeeper(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/premium/desert_ranger
	name = "ranger revolver case"

/obj/item/storage/box/gun/premium/desert_ranger/PopulateContents()
	new /obj/item/gun/ballistic/revolver/revolver44/desert_ranger(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/// Long guns

/obj/item/storage/box/gun/rifle
	name = "cowboy repeater case"
	w_class = WEIGHT_CLASS_BULKY //rifles beeg, no fit in backpack for later

/obj/item/storage/box/gun/rifle/PopulateContents()
	new /obj/item/gun/ballistic/rifle/repeater/cowboy(src)
	new /obj/item/ammo_box/tube/a357(src) //high capacity, only get one
	new /obj/item/ammo_box/a357box(src)
	new /obj/item/ammo_box/a357/ratshot(src)

/obj/item/storage/box/gun/rifle/hunting
	name = "hunting rifle case"

/obj/item/storage/box/gun/rifle/hunting/PopulateContents()
	new /obj/item/gun/ballistic/rifle/hunting(src)
	new /obj/item/ammo_box/a3006(src)
	new /obj/item/ammo_box/a3006box(src)

/obj/item/storage/box/gun/rifle/caravan_shotgun
	name = "caravan rifle case"

/obj/item/storage/box/gun/rifle/caravan_shotgun/PopulateContents()
	new /obj/item/gun/ballistic/revolver/caravan_shotgun(src)
	//new /obj/item/ammo_box/shotgun/buck(src) //lots of shotshells, just one box
	new /obj/item/ammo_box/c4570box(src)
	new /obj/item/ammo_box/c4570/ratshot(src)

/obj/item/storage/box/gun/rifle/widowmaker
	name = "Winchester Widowmaker case"

/obj/item/storage/box/gun/rifle/widowmaker/PopulateContents()
	new /obj/item/gun/ballistic/revolver/widowmaker(src)
	new /obj/item/ammo_box/shotgun/buck(src)

/obj/item/storage/box/gun/rifle/gras
	name = "Gras Rifle"

/obj/item/storage/box/gun/rifle/gras/PopulateContents()
	new /obj/item/gun/ballistic/rifle/antique/gras (src)
	new /obj/item/ammo_box/a3006box(src)

/obj/item/storage/box/gun/rifle/smg22
	name = ".22 Uzi case"

/obj/item/storage/box/gun/rifle/smg22/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/mini_uzi/smg22(src)
	new /obj/item/ammo_box/magazine/m22/extended(src)
	new /obj/item/ammo_box/m22(src)

/obj/item/storage/box/gun/rifle/rockwell
	name = "9mm Rockwell SMG case"

/obj/item/storage/box/gun/rifle/rockwell/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/mini_uzi/rockwell(src)
	new /obj/item/ammo_box/magazine/uzim9mm/rockwell(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/rifle/sidewinder //should this be allowed? not field tested personally
	name = "multi-caliber carbine case"

/obj/item/storage/box/gun/rifle/sidewinder/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/sidewinder/worn(src)
	new /obj/item/ammo_box/magazine/m22(src) //you asked for multicaliber, you get multiple calibers
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/m22(src)

/obj/item/storage/box/gun/rifle/sidewinder_magnum //should this be allowed? not field tested personally
	name = "multi-caliber magnum case"

/obj/item/storage/box/gun/rifle/sidewinder_magnum/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/sidewinder/magnum(src)
	new /obj/item/ammo_box/magazine/m45(src) //you asked for multicaliber, you get multiple calibers
	new /obj/item/ammo_box/magazine/m44(src)
	new /obj/item/ammo_box/magazine/m14mm(src)

/obj/item/storage/box/gun/rifle/m1carbine
	name = "M1 carbine case"

/obj/item/storage/box/gun/rifle/m1carbine/PopulateContents()
	new /obj/item/gun/ballistic/automatic/m1carbine(src)
	new /obj/item/ammo_box/magazine/m10mm/adv(src) //why can't 10mm magazines be normal? make sure these aren't extended or broken
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/rifle/delisle
	name = "De Lisle carbine case"

/obj/item/storage/box/gun/rifle/delisle/PopulateContents()
	new /obj/item/gun/ballistic/automatic/delisle(src)
	new /obj/item/ammo_box/magazine/m9mm/doublestack(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/rifle/carbine9mm
	name = "9mm carbine case"

/obj/item/storage/box/gun/rifle/carbine9mm/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/beretta/carbine(src)
	new /obj/item/ammo_box/magazine/m9mm/doublestack(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/rifle/sportcarbine
	name = "sport carbine case"

/obj/item/storage/box/gun/rifle/sportcarbine/PopulateContents()
	new /obj/item/gun/ballistic/automatic/sportcarbine(src)
	new /obj/item/ammo_box/magazine/m22/extended(src) //high cap, just one
	new /obj/item/ammo_box/m22(src)

/obj/item/storage/box/gun/rifle/varmint
	name = "varmint rifle case"

/obj/item/storage/box/gun/rifle/varmint/PopulateContents()
	new /obj/item/gun/ballistic/automatic/varmint(src)
	new /obj/item/ammo_box/magazine/m556/rifle/small(src) //no extendeds for you till you find em
	new /obj/item/ammo_box/a556(src)

/// MELEE
//gunmelee
/obj/item/storage/box/gun/melee //hopefully a decent variety. someone with more expertise expand on this. maybe split between one and two handed
	name = "scrap sabre case" //stronk, but currently a roundstart. we shall see
	w_class = WEIGHT_CLASS_NORMAL //some are bulky

/obj/item/storage/box/gun/melee/PopulateContents()
	new /obj/item/melee/onehanded/machete/scrapsabre(src)

/obj/item/storage/box/gun/melee/celestia
	name = "Plasma Cutter Celestia"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/melee/celestia/PopulateContents()
	new /obj/item/melee/transforming/plasmacutter/regular/celestia(src)

/obj/item/storage/box/gun/melee/eve
	name = "Plasma Cutter Eve"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/melee/eve/PopulateContents()
	new /obj/item/melee/transforming/plasmacutter/regular/eve(src)

/obj/item/storage/box/gun/melee/plasma
	name = "Plasma Cutter"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/melee/PopulateContents()
	new /obj/item/melee/transforming/plasmacutter/regular(src)

/obj/item/storage/box/gun/melee/bowie //that's not a knife, this is a knife.
	name = "bowie knife case" //not as strong as a scrap sabre, but a good weapon to slip in boot

/obj/item/storage/box/gun/melee/bowie/PopulateContents()
	new /obj/item/melee/onehanded/knife/bowie(src)

/obj/item/storage/box/gun/melee/switchblade
	name = "switchblade case"

/obj/item/storage/box/gun/melee/switchblade/PopulateContents()
	new /obj/item/melee/onehanded/knife/switchblade(src)

/obj/item/storage/box/gun/melee/throwing
	name = "throwing knife case"

/obj/item/storage/box/gun/melee/throwing/PopulateContents()
	new /obj/item/melee/onehanded/knife/throwing(src)
	new /obj/item/melee/onehanded/knife/throwing(src)
	new /obj/item/melee/onehanded/knife/throwing(src)
	new /obj/item/melee/onehanded/knife/throwing(src)
	new /obj/item/melee/onehanded/knife/throwing(src)
	new /obj/item/melee/onehanded/knife/throwing(src)
	new /obj/item/melee/onehanded/knife/throwing(src) //go have fun~

/obj/item/storage/box/gun/melee/brass //roundstart unarmed bb
	name = "brass knuckles case" //what? you don't keep your brass knuckles ina gun case?

/obj/item/storage/box/gun/melee/brass/PopulateContents()
	new /obj/item/melee/unarmed/brass(src)

/obj/item/storage/box/gun/melee/fryingpan //because YES
	name = "frying pan case" //a deadly weapon, keep it in its case

/obj/item/storage/box/gun/melee/fryingpan/PopulateContents()
	new /obj/item/melee/onehanded/club/fryingpan(src)

/obj/item/storage/box/gun/melee/scrapspear //pretty scrappy
	name = "scrap spear case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/scrapspear/PopulateContents()
	new /obj/item/twohanded/spear/scrapspear(src)

/obj/item/storage/box/gun/melee/baseball
	name = "baseball bat case"

/obj/item/storage/box/gun/melee/baseball/PopulateContents()
	new /obj/item/twohanded/baseball(src)

/obj/item/storage/box/gun/melee/sledgehammer
	name = "sledgehammer case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/sledgehammer/PopulateContents()
	new /obj/item/twohanded/sledgehammer/simple(src)

/obj/item/storage/box/gun/melee/fireaxe
	name = "fire axe case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/fireaxe/PopulateContents()
	new /obj/item/twohanded/fireaxe(src)

/obj/item/storage/box/gun/melee/pitchfork
	name = "pitchfork case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/pitchfork/PopulateContents()
	new /obj/item/pitchfork(src)

/obj/item/storage/box/gun/melee/chainsaw
	name = "chainsaw case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/chainsaw/PopulateContents()
	new /obj/item/twohanded/chainsaw(src)

/obj/item/storage/box/gun/melee/fist_of_the_swampstar
	name = "bands of the swampstar case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/fist_of_the_swampstar/PopulateContents()
	new /obj/item/clothing/gloves/fingerless/pugilist/rapid(src)

/obj/item/storage/box/gun/melee/militarypolice
	name = "baton case"

/obj/item/storage/box/gun/melee/militarypolice/PopulateContents()
	new /obj/item/melee/classic_baton/militarypolice(src)

/obj/item/storage/box/gun/melee/raging_boar
	name = "raging boar case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/raging_boar/PopulateContents()
	new /obj/item/book/granter/martial/raging_boar(src)

/obj/item/storage/box/gun/melee/sleeping_carp
	name = "sleeping carp case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/melee/sleeping_carp/PopulateContents()
	new /obj/item/book/granter/martial/carp(src)

/obj/item/storage/box/gun/melee/oldclaymore/PopulateContents()
	new /obj/item/melee/coyote/oldclaymore(src)

/obj/item/storage/box/gun/melee/harpoon/PopulateContents()
	new /obj/item/melee/coyote/harpoon(src)

/obj/item/storage/box/gun/melee/katanaold/PopulateContents()
	new /obj/item/melee/coyote/katanaold(src)

/obj/item/storage/box/gun/melee/wakazashiold/PopulateContents()
	new /obj/item/melee/coyote/wakazashiold(src)

/obj/item/storage/box/gun/melee/tantoold/PopulateContents()
	new /obj/item/melee/coyote/tantoold(src)

/obj/item/storage/box/gun/melee/combataxe/PopulateContents()
	new /obj/item/melee/coyote/combataxe(src)

/obj/item/storage/box/gun/melee/smallsword/PopulateContents()
	new /obj/item/melee/coyote/smallsword(src)

/obj/item/storage/box/gun/melee/oldcutlass/PopulateContents()
	new /obj/item/melee/coyote/oldcutlass(src)

/obj/item/storage/box/gun/melee/crudeblade/PopulateContents()
	new /obj/item/melee/coyote/crudeblade(src)

/obj/item/storage/box/gun/melee/oldkanobo/PopulateContents()
	new /obj/item/melee/coyote/oldkanobo(src)

/obj/item/storage/box/gun/melee/mauler/PopulateContents()
	new /obj/item/melee/coyote/mauler(src)

/obj/item/storage/box/gun/melee/club/PopulateContents()
	new /obj/item/melee/coyote/club(src)

/obj/item/storage/box/gun/melee/bigclub/PopulateContents()
	new /obj/item/melee/coyote/bigclub(src)

/obj/item/storage/box/gun/melee/oldlongsword/PopulateContents()
	new /obj/item/melee/coyote/oldlongsword(src)

/obj/item/storage/box/gun/melee/oldhalberd/PopulateContents()
	new /obj/item/melee/coyote/oldhalberd(src)

/obj/item/storage/box/gun/melee/oldquarterstaff/PopulateContents()
	new /obj/item/melee/classic_baton/coyote/oldquarterstaff(src)

/obj/item/storage/box/gun/melee/olddervish/PopulateContents()
	new /obj/item/melee/coyote/olddervish(src)

/obj/item/storage/box/gun/melee/oldpike/sarissa/PopulateContents()
	new /obj/item/melee/coyote/oldpike/sarissa(src)

/obj/item/storage/box/gun/melee/oldlongsword/spadroon/PopulateContents()
	new /obj/item/melee/coyote/oldlongsword/spadroon(src)


/obj/item/storage/box/gun/melee/oldlongsword/broadsword/PopulateContents()
	new /obj/item/melee/coyote/oldlongsword/broadsword(src)

/obj/item/storage/box/gun/melee/oldlongsword/armingsword/PopulateContents()
	new /obj/item/melee/coyote/oldlongsword/armingsword(src)

/obj/item/storage/box/gun/melee/oldlongsword/longquan/PopulateContents()
	new /obj/item/melee/coyote/oldlongsword/longquan(src)

/obj/item/storage/box/gun/melee/oldlongsword/xiphos/PopulateContents()
	new /obj/item/melee/coyote/oldlongsword/xiphos(src)

/obj/item/storage/box/gun/melee/oldpike/PopulateContents()
	new /obj/item/melee/coyote/oldpike(src)

/obj/item/storage/box/gun/melee/oldnaginata/PopulateContents()
	new /obj/item/melee/coyote/oldnaginata(src)

/obj/item/storage/box/gun/melee/oldashandarei/PopulateContents()
	new /obj/item/melee/coyote/oldashandarei(src)

/obj/item/storage/box/gun/melee/macuahuitl/PopulateContents()
	new /obj/item/melee/coyote/macuahuitl(src)

/obj/item/storage/box/gun/melee/oldkhopesh/PopulateContents()
	new /obj/item/melee/coyote/oldkhopesh(src)

/// HOBO GUNS

/obj/item/storage/box/gun/hobo
	name = "hand shotgun case"
	w_class = WEIGHT_CLASS_NORMAL //will designate for each box since pipe guns vary in size

/obj/item/storage/box/gun/hobo/PopulateContents()
	new /obj/item/gun/ballistic/revolver/shotpistol(src)
	new /obj/item/ammo_box/shotgun/buck(src)

/obj/item/storage/box/gun/hobo/zipgun
	name = "Zip gun case"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/hobo/zipgun/PopulateContents()
	new /obj/item/gun/ballistic/automatic/hobo/zipgun(src)
	new /obj/item/ammo_box/magazine/zipgun(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/hobo/piperifle
	name = "pipe rifle case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/hobo/piperifle/PopulateContents()
	new /obj/item/gun/ballistic/revolver/hobo/piperifle(src)
	new /obj/item/ammo_box/a556/improvised(src) //it's like a box but smaller

/obj/item/storage/box/gun/hobo/brick
	name = "brick launcher case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/hobo/brick/PopulateContents()
	new /obj/item/gun/ballistic/revolver/brick(src)

/obj/item/storage/box/gun/hobo/pepperbox
	name = "pepperbox gun case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/hobo/pepperbox/PopulateContents()
	new /obj/item/gun/ballistic/revolver/hobo/pepperbox(src)
	new /obj/item/ammo_box/l10mm(src) //no idea wtf this is for originally but it'll do
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/hobo/single_shotgun
	name = "shotgun bat case"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/hobo/single_shotgun/PopulateContents()
	new /obj/item/gun/ballistic/revolver/hobo/single_shotgun(src)
	new /obj/item/ammo_box/shotgun/buck(src)

/obj/item/storage/box/gun/hobo/knifegun
	name = "knife gun case"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/hobo/knifegun/PopulateContents()
	new /obj/item/gun/ballistic/revolver/hobo/knifegun(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/hobo/knucklegun
	name = "knucklegun case"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/hobo/knucklegun/PopulateContents()
	new /obj/item/gun/ballistic/revolver/hobo/knucklegun(src)
	new /obj/item/ammo_box/c45rev(src)
	new /obj/item/ammo_box/c45(src)

/obj/item/storage/box/gun/hobo/winchesterrebored
	name = "rebored Winchester case"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/gun/hobo/winchesterrebored/PopulateContents()
	new /obj/item/gun/ballistic/revolver/winchesterrebored(src)
	new /obj/item/ammo_box/a308box(src) //it's like a box but smaller

/// revolvers!

/obj/item/storage/box/gun/revolver
	name = ".22LR Revolver case"
	w_class = WEIGHT_CLASS_NORMAL //revolvers aren't bulky

/obj/item/storage/box/gun/revolver/PopulateContents()
	new /obj/item/gun/ballistic/revolver/detective(src)
	new /obj/item/ammo_box/m22(src)
	new /obj/item/ammo_box/c22(src)

/obj/item/storage/box/gun/revolver/revolver45
	name = ".45 ACP revolver case"

/obj/item/storage/box/gun/revolver/revolver45/PopulateContents()
	new /obj/item/gun/ballistic/revolver/revolver45(src)
	new /obj/item/ammo_box/c45rev(src)
	new /obj/item/ammo_box/c45(src)

/obj/item/storage/box/gun/revolver/colt357
	name = ".357 magnum revolver case" //what does \improper mean, is needed here?

/obj/item/storage/box/gun/revolver/colt357/PopulateContents()
	new /obj/item/gun/ballistic/revolver/colt357(src)
	new /obj/item/ammo_box/a357(src)
	new /obj/item/ammo_box/a357box(src)
	new /obj/item/ammo_box/a357/ratshot(src)

/obj/item/storage/box/gun/revolver/police
	name = "police revolver case"

/obj/item/storage/box/gun/revolver/police/PopulateContents()
	new /obj/item/gun/ballistic/revolver/police(src)
	new /obj/item/ammo_box/a357(src)
	new /obj/item/ammo_box/a357box(src)
	new /obj/item/ammo_box/a357/ratshot(src)

/obj/item/storage/box/gun/revolver/m29
	name = ".44 magnum revolver case"

/obj/item/storage/box/gun/revolver/m29/PopulateContents()
	new /obj/item/gun/ballistic/revolver/m29(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/revolver/m29snub
	name = "snubnose .44 magnum case"

/obj/item/storage/box/gun/revolver/m29snub/PopulateContents()
	new /obj/item/gun/ballistic/revolver/m29/snub(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/revolver/revolver44
	name = ".44 magnum single-action case"

/obj/item/storage/box/gun/revolver/revolver44/PopulateContents()
	new /obj/item/gun/ballistic/revolver/revolver44(src)
	new /obj/item/ammo_box/m44(src)
	new /obj/item/ammo_box/m44box(src)

/obj/item/storage/box/gun/revolver/thatgun
	name = ".308 pistol case"

/obj/item/storage/box/gun/revolver/thatgun/PopulateContents()
	new /obj/item/gun/ballistic/revolver/thatgun(src)
	new /obj/item/ammo_box/a308(src)
	new /obj/item/ammo_box/a308box(src)

/// Semiauto pistols!

/obj/item/storage/box/gun/pistol
	name = ".22 pistol case"
	w_class = WEIGHT_CLASS_NORMAL //pistols aren't bulky

/obj/item/storage/box/gun/pistol/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/pistol22(src)
	new /obj/item/ammo_box/magazine/m22(src)
	new /obj/item/ammo_box/m22(src)

/obj/item/storage/box/gun/pistol/tec22
	name = ".22 machine pistol case"

/obj/item/storage/box/gun/pistol/tec22/PopulateContents()
	new /obj/item/gun/ballistic/automatic/smg/mini_uzi/smg22/tec22(src)
	new /obj/item/ammo_box/magazine/m22(src)
	new /obj/item/ammo_box/m22(src)

/obj/item/storage/box/gun/pistol/ninemil
	name = "Browning Hi-power case"

/obj/item/storage/box/gun/pistol/ninemil/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/ninemil(src)
	new /obj/item/ammo_box/magazine/m9mm/doublestack(src)
	new /obj/item/ammo_box/c9mm(src)



/obj/item/storage/box/gun/pistol/auto9mm
	name = "9mm Autopistol case"

/obj/item/storage/box/gun/pistol/auto9mm/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/ninemil/auto(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/pistol/borchardt
	name = "9mm Borchardt case"

/obj/item/storage/box/gun/pistol/borchardt/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/ninemil/c93(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/pistol/luger
	name = "9mm Luger case"

/obj/item/storage/box/gun/pistol/luger/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/ninemil/c93/luger(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/pistol/ruby/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/ninemil/ruby(src)
	new /obj/item/ammo_box/magazine/m9mm(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/pistol/beretta
	name = "Beretta M9FS case"

/obj/item/storage/box/gun/pistol/beretta/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/beretta(src)
	new /obj/item/ammo_box/magazine/m9mm/doublestack(src)
	new /obj/item/ammo_box/c9mm(src)

/obj/item/storage/box/gun/pistol/n99
	name = "10mm pistol case"

/obj/item/storage/box/gun/pistol/n99/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/n99(src)
	new /obj/item/ammo_box/magazine/m10mm/adv/simple(src)
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/pistol/flintlock
	name = "flintlock pistol case"

/obj/item/storage/box/gun/pistol/flintlock/PopulateContents()
	new /obj/item/gun/flintlock(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/rifle/musket
	name = "flintlock musket case"

/obj/item/storage/box/gun/rifle/musket/PopulateContents()
	new /obj/item/gun/flintlock/musket(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/rifle/musketoon
	name = "flintlock musketoon case"

/obj/item/storage/box/gun/rifle/musketoon/PopulateContents()
	new /obj/item/gun/flintlock/musketoon(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/pistol/musketoon/spingarda
	name = "flintlock Spingarda case"

/obj/item/storage/box/gun/rifle/musketoon/spingarda/PopulateContents()
	new /obj/item/gun/flintlock/musketoon/spingarda(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/rifle/musketoon/mosquete
	name = "flintlock Mosquete case"

/obj/item/storage/box/gun/rifle/musketoon/mosquete/PopulateContents()
	new /obj/item/gun/flintlock/musketoon/mosquete(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/rifle/musket/tanegashima
	name = "tanegashima case"

/obj/item/storage/box/gun/rifle/musket/tanegashima/PopulateContents()
	new /obj/item/gun/flintlock/musket/tanegashima(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/rifle/jezail
	name = "jezail case"

/obj/item/storage/box/gun/rifle/jezail/PopulateContents()
	new /obj/item/gun/flintlock/musket/jezail(src)
	new /obj/item/ammo_box/flintlock(src)

/obj/item/storage/box/gun/rifle/jezail/culverin
	name = "culverin case"

/obj/item/storage/box/gun/rifle/jezail/culverin/PopulateContents()
	new /obj/item/gun/flintlock/musket/jezail/culverin(src)
	new /obj/item/ammo_box/flintlock(src)


/obj/item/storage/box/gun/pistol/type17
	name = "Type 17 case"

/obj/item/storage/box/gun/pistol/type17/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/type17(src)
	new /obj/item/ammo_box/magazine/m10mm/adv/simple(src)
	new /obj/item/ammo_box/c10mm(src)

/obj/item/storage/box/gun/pistol/m1911 //muh three worldly whores
	name = "M1911 case"

/obj/item/storage/box/gun/pistol/m1911/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/c45(src)

/// Tribal!

/obj/item/storage/box/gun/tribal //not terribly versed in tribal stuff. someone can give this a bit more love than I
	name = "bone spear case"
	w_class = WEIGHT_CLASS_BULKY //a few are small

/obj/item/storage/box/gun/tribal/PopulateContents()
	new /obj/item/twohanded/spear/bonespear(src)

/obj/item/storage/box/gun/tribal/forgedmachete
	name = "machete case"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/tribal/forgedmachete/PopulateContents()
	new /obj/item/melee/onehanded/machete/forgedmachete(src)

/obj/item/storage/box/gun/tribal/bmprsword
	name = "bumpersword case"

/obj/item/storage/box/gun/tribal/bmprsword/PopulateContents()
	new /obj/item/twohanded/fireaxe/bmprsword(src)

/obj/item/storage/box/gun/tribal/warmace
	name = "warmace case"

/obj/item/storage/box/gun/tribal/warmace/PopulateContents()
	new /obj/item/twohanded/sledgehammer/warmace(src)

/obj/item/storage/box/gun/tribal/spearquiver
	name = "spear quiver case"

/obj/item/storage/box/gun/tribal/spearquiver/PopulateContents()
	new /obj/item/storage/backpack/spearquiver(src)

/obj/item/storage/box/gun/bow/shortbow
	name = "shortbow case"

/obj/item/storage/box/gun/bow/shortbow/PopulateContents()
	new /obj/item/gun/ballistic/bow/shortbow(src)
	new /obj/item/storage/bag/tribe_quiver/light/full(src)

/*dunno if we should have roundstart crossbow simply cause we want a lil more progression
/obj/item/storage/box/gun/bow/crossbow
	name = "crossbow case"

/obj/item/storage/box/gun/bow/crossbow/PopulateContents()
	new /obj/item/gun/ballistic/bow/crossbow(src)
	new /obj/item/storage/bag/tribe_quiver/light(src)
*/

/obj/item/storage/box/gun/tribal/warclub
	name = "war club case"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/gun/tribal/warclub/PopulateContents()
	new /obj/item/melee/onehanded/club/warclub(src)



/obj/item/storage/box/gun/tribal/boneaxe
	name = "bone axe case"

/obj/item/storage/box/gun/tribal/boneaxe/PopulateContents()
	new /obj/item/twohanded/fireaxe/boneaxe(src)

/// Preacher Stuff

/obj/item/storage/box/gun/preacher/nullrod
	name = "spriritual device case"

/obj/item/storage/box/gun/preacher/nullrod/PopulateContents()
	new /obj/item/nullrod(src)

/// ENERGY!

/obj/item/storage/box/gun/energy
	name = "compact rcw case"
	w_class = WEIGHT_CLASS_NORMAL //no roundstart laser rifles rn

/obj/item/storage/box/gun/energy/PopulateContents()
	new /obj/item/gun/energy/laser/auto/worn(src)
	new /obj/item/stock_parts/cell/ammo/ecp(src)

/obj/item/storage/box/gun/energy/plasma
	name = "plasma pistol case"

/obj/item/storage/box/gun/energy/plasma/PopulateContents()
	new /obj/item/gun/energy/laser/plasma/pistol/worn(src)
	new /obj/item/stock_parts/cell/ammo/ec(src)

/obj/item/storage/box/gun/energy/stun
	name = "compliance regulator case"

/obj/item/storage/box/gun/energy/stun/PopulateContents()
	new /obj/item/gun/energy/laser/complianceregulator(src)
	new /obj/item/stock_parts/cell/ammo/ec(src)

/obj/item/storage/box/gun/energy/compact_rcw
	name = "compact RCW case"

/obj/item/storage/box/gun/energy/compact_rcw/PopulateContents()
	new /obj/item/gun/energy/laser/auto(src)
	new /obj/item/stock_parts/cell/ammo/ecp(src)

/obj/item/storage/box/gun/energy/wattz1000
	name = "wattz 1000 case"

/obj/item/storage/box/gun/energy/wattz1000/PopulateContents()
	new /obj/item/gun/energy/laser/wattz(src)
	new /obj/item/stock_parts/cell/ammo/ec(src)

/obj/item/storage/box/gun/energy/wornaep7
	name = "worn AEP-7 case"

/obj/item/storage/box/gun/energy/wornaep7/PopulateContents()
	new /obj/item/gun/energy/laser/pistol/worn(src)
	new /obj/item/stock_parts/cell/ammo/ec(src)

/obj/item/choice_beacon/box/gun //template for sprites
	name = "weapon case"
	desc = "a sturdy case keeping your weapon of choice safe until you pop it open."
	icon = 'icons/obj/crates.dmi' //old weapon crate uses this. good enough for a gun case
	icon_state = "weaponcrate"
	item_state = "syringe_kit" //old weapon crate used this. I'm not familiar enough to know if there's something better
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi' //taken from briefcase code, should look okay for an inhand
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'

//could use a click sound when opened instead of a tear?

/datum/loadout_kit
	var/key
	var/flags
	var/desc = "A kit full of stuff."
	var/kit_category
	var/obj/item/spawn_thing
	/// Cache of what's in the booooox, so we can access it wuickly later
	var/list/box_contents
	/// The cost of this kit, in tokens
	/// OKAY SO loadout kits have a cost associated with them, right? They cost one token of their 'tier' to buy.
	/// There are: Premium, Standard, and Secondary tokens
	/// Also tool tokens, but we dont talk about those
	var/list/accepted_coins = LOADOUT_PRICE_STANDARD

/datum/loadout_kit/New()
	if(!spawn_thing)
		return
	build_contents()

/datum/loadout_kit/proc/build_contents()
	/// now to get the contents of my box. or just the thing if it's not a box
	/// Since storages re built *after* they are spawned, you know what that means?
	/// We get to play the ~Instantiation-Destruction~ game!
	/// Player 1 to the stage, please!
	var/obj/item/thingy = new spawn_thing()
	var/list/stuff_in_thingy = list()
	stuff_in_thingy += list(thingy.name, thingy.desc)
	for(var/obj/item/item in thingy.contents)
		stuff_in_thingy += list(thingy.name, thingy.desc)
	qdel(thingy)
	/// Good game, everyone loses
	box_contents = stuff_in_thingy

/// Energy Guns

/datum/loadout_kit/energy
	key = "Compact RCW"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_ENERGY
	spawn_thing = /obj/item/storage/box/gun/energy

/datum/loadout_kit/plasma
	key = "Plasma Pistol"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/energy/plasma

/datum/loadout_kit/aer9
	key = "AER-9"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/aer9

/datum/loadout_kit/aer92
	key = "AER-9"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/aer9

/datum/loadout_kit/stun
	key = "Compliance Regulator"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_ENERGY
	spawn_thing = /obj/item/storage/box/gun/energy/stun

/datum/loadout_kit/compact_rcw
	key = "Compact RCW"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_ENERGY
	spawn_thing = /obj/item/storage/box/gun/energy/compact_rcw

/datum/loadout_kit/wattz1000
	key = "Wattz 1000"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_ENERGY
	spawn_thing = /obj/item/storage/box/gun/energy/wattz1000

/datum/loadout_kit/wornaep7
	key = "Worn AEP-7"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_ENERGY
	spawn_thing = /obj/item/storage/box/gun/energy/wornaep7

/// Fancyguns

/datum/loadout_kit/maria
	key = "Maria"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/maria

/datum/loadout_kit/beretta_auto
	key = "Beretta M93R Burstfire"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/automatic

/datum/loadout_kit/executive_10mm
	key = "The Executive 10mm pistol"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/executive

/datum/loadout_kit/crusader
	key = "Crusader 10mm pistol"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/crusader

/datum/loadout_kit/sig
	key = "Sig P220"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/sig

/datum/loadout_kit/m1911_custom
	key = "M1911 Custom"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/custom

/datum/loadout_kit/mateba
	key = "Unica 6"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/mateba

/datum/loadout_kit/lucky
	key = "Lucky Revolver"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/lucky

/datum/loadout_kit/alt
	key = "Pearl .44 Magnum"
	flags = LOADOUT_FLAG_PREMIUM
	kit_category = LOADOUT_CAT_PREMIUM
	spawn_thing = /obj/item/storage/box/gun/premium/alt

/datum/loadout_kit/alt2
	key = "Pearl .44 Magnum"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/premium/alt

/datum/loadout_kit/peacekeeper
	key = "Peacekeeper Magnum"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/premium/peacekeeper

/datum/loadout_kit/desert_ranger
	key = "Desert Ranger Magnum"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/premium/desert_ranger

/// Lawman guns

/datum/loadout_kit/american_180
	key = "American 180"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law

/datum/loadout_kit/smg10mm
	key = "10mm SMG"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/smg10mm

/datum/loadout_kit/commando
	key = "Commando Carbine"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/commando

/datum/loadout_kit/combat
	key = "Combat Carbine"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/combat

/datum/loadout_kit/service
	key = "Service Rifle"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/service

/datum/loadout_kit/policerifle
	key = "Police Rifle"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/policerifle

/datum/loadout_kit/assault_carbine
	key = "Assault Carbine"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/assault_carbine

/datum/loadout_kit/mk23
	key = "Tactical MK-23"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/mk23

/// Long guns, mostly wasters

/datum/loadout_kit/rifle
	key = "Cowboy Repeater"
	flags = LOADOUT_FLAG_WASTER // frontier something something
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle

/datum/loadout_kit/hunting
	key = "Hunting Rifle"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/hunting

/datum/loadout_kit/caravan_shotgun
	key = "Caravan Rifle"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/caravan_shotgun

/datum/loadout_kit/widowmaker
	key = "Widowmaker Shotgun"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/widowmaker

/datum/loadout_kit/smg22
	key = ".22 Uzi"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/smg22

/datum/loadout_kit/rockwell
	key = "9mm Rockwell SMG"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/rockwell

/datum/loadout_kit/gras
	key = "Gras Rifle"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/gras

/datum/loadout_kit/sidewinder
	key = "Multicaliber Carbine"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/sidewinder

/* /datum/loadout_kit/sidewinder_magnum
	key = "Multicaliber Magnum"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/sidewinder_magnum */

/datum/loadout_kit/m1carbine
	key = "M1 Carbine"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/m1carbine

/datum/loadout_kit/delisle
	key = "Delisle Carbine"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/delisle

/datum/loadout_kit/carbine9mm
	key = "9mm Carbine"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/carbine9mm

/datum/loadout_kit/sportcarbine
	key = "Sport Carbine"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/sportcarbine

/datum/loadout_kit/varmint
	key = "Varmint Rifle"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/varmint

/datum/loadout_kit/trail
	key = "Trail Carbine"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/law/trail

/datum/loadout_kit/flintlockmusket
	key = "Flintlock Musket"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/musket

/datum/loadout_kit/tanegashima
	key = "Tanegashima Musket"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/musket/tanegashima

/datum/loadout_kit/flintlockmusketoon
	key = "Flintlock Musketoon"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/musketoon

/datum/loadout_kit/flintlockspingarda
	key = "Flintlock Spingarda"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/musketoon/spingarda

/datum/loadout_kit/flintlockmosquete
	key = "Flintlock Mosquete"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/musketoon/mosquete

/datum/loadout_kit/flintlockjezail
	key = "Jezail Long Rifle"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/jezail


/datum/loadout_kit/flintlockculverin
	key = "Culverin"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/rifle/jezail/culverin


/datum/loadout_kit/junglecarbine
	key = "Jungle Carbine"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/junglecarbine

/datum/loadout_kit/smle
	key = "Lee-Enfield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_LONGGUN
	spawn_thing = /obj/item/storage/box/gun/rifle/smle

/// Hobo Guns

/datum/loadout_kit/hand_shotgun
	key = "Hand Shotgun"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo

/datum/loadout_kit/zipgun
	key = "Zipgun"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/zipgun

/datum/loadout_kit/piperifle
	key = "Pipe Rifle"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/piperifle

/datum/loadout_kit/brick
	key = "Brick Launcher"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/brick

/datum/loadout_kit/pepperbox
	key = "Pepperbox"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/pepperbox

/datum/loadout_kit/single_shotgun
	key = "Shotgun Bat"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/single_shotgun

/datum/loadout_kit/knifegun
	key = "Knife Gun"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/knifegun

/datum/loadout_kit/knucklegun
	key = "Knuckle Gun"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/knucklegun

/datum/loadout_kit/winchesterrebored
	key = "Rebored Winchester"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/storage/box/gun/hobo/winchesterrebored

/// Revolvers!

/datum/loadout_kit/detective
	key = ".22LR Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver

/datum/loadout_kit/revolver45
	key = ".45ACP Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/revolver45

/datum/loadout_kit/colt357
	key = ".357 Magnum Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/colt357

/datum/loadout_kit/police
	key = ".357 Snubnose Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/police

/datum/loadout_kit/m29
	key = ".44 Magnum Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/m29

/datum/loadout_kit/m29snub
	key = ".44 Snubnose Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/m29snub

/datum/loadout_kit/revolver44
	key = ".44 Single-Action Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/revolver44

/datum/loadout_kit/thatgun //thotgun
	key = ".308 Revolver"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_REVOLVER
	spawn_thing = /obj/item/storage/box/gun/revolver/thatgun

/// Semi-auto pistols!

/datum/loadout_kit/pistol
	key = ".22 Pistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol

/datum/loadout_kit/tec22
	key = ".22 Machine Pistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/tec22

/datum/loadout_kit/ninemil
	key = "Hi-Power Pistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/ninemil

/datum/loadout_kit/auto9mm
	key = "9mm Autopistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/auto9mm

/datum/loadout_kit/borchardt
	key = "9mm Borchardt"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/borchardt

/datum/loadout_kit/luger
	key = "9mm Luger"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/luger

/datum/loadout_kit/ruby
	key = "9mm Bootgun"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/ruby

/datum/loadout_kit/beretta
	key = "Beretta M9FS"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/beretta

/datum/loadout_kit/n99
	key = "10mm Pistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/n99

/datum/loadout_kit/flintlock
	key = "Flintlock Pistol"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MUSKET
	spawn_thing = /obj/item/storage/box/gun/pistol/flintlock

/datum/loadout_kit/type17
	key = "10mm Type17 Pistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/type17

/datum/loadout_kit/m1911
	key = ".45ACP Pistol"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_PISTOL
	spawn_thing = /obj/item/storage/box/gun/pistol/m1911

/// Melee!

/datum/loadout_kit/melee
	key = "Scrap Sabre"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee

/datum/loadout_kit/melee/celestia
	key = "Plasma Cutter Celestia"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee/celestia

/datum/loadout_kit/melee/eve
	key = "Plasma Cutter Eve"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee/eve

/datum/loadout_kit/melee/plasma
	key = "Plasma Cutter"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee/plasma

/datum/loadout_kit/bowie
	key = "Bowie Knife"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee/bowie

/datum/loadout_kit/switchblade
	key = "Switchblade"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee/switchblade

/datum/loadout_kit/throwing
	key = "Throwing Knives"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_BOW
	spawn_thing = /obj/item/storage/box/gun/melee/throwing

/datum/loadout_kit/brass
	key = "Brass Knuckles"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL | LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/storage/box/gun/melee/brass

/datum/loadout_kit/fryingpan
	key = "Frying Pan"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/melee/fryingpan

/datum/loadout_kit/scrapspear
	key = "Scrap Spear"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/melee/scrapspear

/datum/loadout_kit/baseball
	key = "Baseball Bat"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_LAWMAN | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/melee/baseball

/datum/loadout_kit/sledgehammer
	key = "Sledgehammer"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/melee/sledgehammer

/datum/loadout_kit/fireaxe
	key = "fire axe"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/melee/fireaxe

/datum/loadout_kit/pitchfork
	key = "pitchfork"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/melee/pitchfork

/datum/loadout_kit/chainsaw
	key = "Chainsaw"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/melee/chainsaw

/datum/loadout_kit/fist_of_the_swampstar // pornstar
	key = "Bands of the Swamp Star gloves"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/storage/box/gun/melee/fist_of_the_swampstar

/datum/loadout_kit/raging_boar // YEET
	key = "Raging Boar Scroll"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/storage/box/gun/melee/raging_boar

/datum/loadout_kit/sleeping_carp // Snippity Snap
	key = "Sleeping Carp Scroll"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/storage/box/gun/melee/sleeping_carp

/datum/loadout_kit/oldclaymore //FOR SCOTLAND
	key = "Old Claymore"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldclaymore

/datum/loadout_kit/harpoon //https://youtu.be/-UhrVpRCOYM ~TK
	key = "Harpoon"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/harpoon

/datum/loadout_kit/katanaold
	key = "Old Katana"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/katanaold

/datum/loadout_kit/wakazashiold
	key = "Old Wakazashi"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/wakazashiold

/datum/loadout_kit/tantoold
	key = "Old Tanto"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/tantoold

/datum/loadout_kit/combataxe
	key = "Combat Axe"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/combataxe

/datum/loadout_kit/smallsword
	key = "Small Sword"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/smallsword

/datum/loadout_kit/oldcutlass
	key = "Old Cutlass"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldcutlass

/datum/loadout_kit/crudeblade
	key = "Crude Blade"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/crudeblade

/datum/loadout_kit/mauler
	key = "Mauler"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/mauler

/datum/loadout_kit/club
	key = "Club"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/club

/datum/loadout_kit/club/mace
	key = "Mace"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/club/mace


/datum/loadout_kit/bigclub
	key = "Big Club"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/bigclub

/datum/loadout_kit/oldlongsword
	key = "Old Longsword"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldlongsword

/datum/loadout_kit/oldhalberd
	key = "Old Halberd"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldhalberd

/datum/loadout_kit/oldpike
	key = "Old Pike"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldpike

/datum/loadout_kit/oldnaginata
	key = "Old Naginata"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldnaginata

/datum/loadout_kit/oldashandarei
	key = "Old Ashandarei"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldashandarei

/datum/loadout_kit/oldkhopesh
	key = "Old Khopesh"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldkhopesh

/datum/loadout_kit/oldkanobo
	key = "Old Kanobo"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldkanobo

/datum/loadout_kit/macuahuitl
	key = "Macuahuitl"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/macuahuitl

/datum/loadout_kit/militarypolice
	key = "Police Baton"
	flags = LOADOUT_FLAG_LAWMAN
	kit_category = LOADOUT_CAT_LAWMAN
	spawn_thing = /obj/item/storage/box/gun/melee/militarypolice

/// Tribal

/datum/loadout_kit/tribal
	key = "Bone Spear"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/tribal

/datum/loadout_kit/forgedmachete
	key = "Machete"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/tribal/forgedmachete

/datum/loadout_kit/bmprsword
	key = "Bumper Sword"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/tribal/bmprsword

/datum/loadout_kit/warmace
	key = "Warmace"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/tribal/warmace

/datum/loadout_kit/spear_quiver
	key = "Spear Quiver"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_BOW
	spawn_thing = /obj/item/storage/box/gun/tribal/spearquiver

/datum/loadout_kit/warclub
	key = "War Club"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/storage/box/gun/tribal/warclub

/datum/loadout_kit/boneaxe
	key = "Bone Axe"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/storage/box/gun/tribal/boneaxe

/// BOWS

/datum/loadout_kit/shortbow
	key = "Shortbow"
	flags = LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_BOW
	spawn_thing = /obj/item/storage/box/gun/bow/shortbow

/*
/datum/loadout_kit/crossbow
	key = "Crossbow"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_BOW
	spawn_thing = /obj/item/storage/box/gun/bow/crossbow
*/

/// Preacher Stuff

/datum/loadout_kit/nullrod
	key = "Spiritual Device"
	flags = LOADOUT_FLAG_PREACHER
	kit_category = LOADOUT_CAT_NULLROD
	spawn_thing = /obj/item/storage/box/gun/preacher/nullrod

/// misc Stuff

/datum/loadout_kit/dynamite
	key = "Box of Dynamite"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/storage/box/dynamite_box

/datum/loadout_kit/caps
	key = "25 Coins"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/stack/f13Cash/caps/twofive

/datum/loadout_kit/woodenbuckler
	key = "Wooden Buckler"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_MISC
	spawn_thing = /obj/item/shield/riot/buckler

/datum/loadout_kit/stopsign
	key = "Stop Sign Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/riot/buckler/stop


/datum/loadout_kit/kiteshield
	key = "Kite Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/kiteshield


/datum/loadout_kit/bucklertwo
	key = "Oak Buckler"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/bucklertwo

/datum/loadout_kit/egyptianshield
	key = "Dusty Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/egyptianshield

/datum/loadout_kit/semioval
	key = "Semioval Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/semioval

/datum/loadout_kit/romanbuckler
	key = "Skirmisher's Buckler"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/romanbuckler

/datum/loadout_kit/ironshieldfour
	key = "Checkered Red Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/ironshieldfour

/datum/loadout_kit/ironshieldthree
	key = "Red Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/ironshieldthree

/datum/loadout_kit/ironshieldtwo
	key = "Oval Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/ironshieldtwo

/datum/loadout_kit/bronzeshield
	key = "Bronze Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/bronzeshield

/datum/loadout_kit/ironshield
	key = "Iron Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/ironshield

/datum/loadout_kit/steelshield
	key = "Steel Shield"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/steelshield

/datum/loadout_kit/bluebuckler
	key = "Blue Buckler"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/bluebuckler

/datum/loadout_kit/redbuckler
	key = "Red Buckler"
	flags = LOADOUT_FLAG_WASTER
	kit_category = LOADOUT_CAT_SHIELD
	spawn_thing = /obj/item/shield/coyote/redbuckler

/datum/loadout_kit/oldquarterstaff
	key = "Old Quarterstaff"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/classic_baton/coyote/oldquarterstaff

/datum/loadout_kit/oldquarterstaff/bokken
	key = "Old Bokken"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/classic_baton/coyote/oldquarterstaff/oldbokken

/datum/loadout_kit/olddervish
	key = "Old Dervish Blade"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/olddervish

/datum/loadout_kit/oldpike/sarissa
	key = "Old Sarissa"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_TWO
	spawn_thing = /obj/item/melee/coyote/oldpike/sarissa

/datum/loadout_kit/oldlongsword/spadroon
	key = "Old Spadroon"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldlongsword/spadroon

/datum/loadout_kit/oldlongsword/broadsword
	key = "Old Broadsword"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldlongsword/broadsword

/datum/loadout_kit/oldlongsword/armingsword
	key = "Old Arming Sword"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldlongsword/armingsword

/datum/loadout_kit/oldlongsword/longquan
	key = "Old Chinese Sword"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldlongsword/longquan

/datum/loadout_kit/oldlongsword/xiphos
	key = "Old Xiphos"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/melee/coyote/oldlongsword/xiphos

/datum/loadout_kit/gar/
	key = "Black Gar Glasses"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/clothing/glasses/sunglasses/garb


/datum/loadout_kit/blackgiggagar/
	key = "Black Gigga Gar Glasses"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/clothing/glasses/sunglasses/garb/supergarb

/datum/loadout_kit/orangegar/
	key = "Orange Gar Glasses"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/clothing/glasses/sunglasses/gar

/datum/loadout_kit/giggagar/
	key = "Gigga Gar Glasses"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_MELEE_ONE
	spawn_thing = /obj/item/clothing/glasses/sunglasses/gar/supergar

/datum/loadout_kit/sling
	key = "Sling"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/gun/ballistic/revolver/sling

/datum/loadout_kit/slingstaff
	key = "Slingstaff"
	flags = LOADOUT_FLAG_WASTER | LOADOUT_FLAG_TRIBAL
	kit_category = LOADOUT_CAT_HOBO
	spawn_thing = /obj/item/gun/ballistic/revolver/sling/staff




