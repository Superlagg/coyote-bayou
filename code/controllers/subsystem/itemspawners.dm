SUBSYSTEM_DEF(itemspawners)
	name = "Item Spawners"
	wait = 1 HOURS

/datum/controller/subsystem/itemspawners/fire(resumed = 0)
	log_game("Item Spawners Subsystem Firing")
	message_admins("Item Spawners Subsystem Firing.")

//	cleanup_trash()
	restock_trash_piles()

/obj/item
	var/from_trash = FALSE

/datum/controller/subsystem/itemspawners/proc/restock_trash_piles()
	for(var/datum/weakref/TS in GLOB.trash_piles)
		var/obj/item/storage/trash_stack/tresh = TS?.resolve()
		if(!tresh)
			GLOB.trash_piles -= TS
			continue
		tresh.cleanup()

//Called when a human swaps hands to a hand which is holding this item
/obj/item/proc/swapped_to(mob/user)
	add_hud_actions(user)

//Called when a human swaps hands away from a hand which is holding this item
/obj/item/proc/swapped_from(mob/user)
	remove_hud_actions(user)
