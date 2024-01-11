/obj/item/organ/headpat_receptor
	name = "Huza-Guboi neuro-cluster"
	desc = "A specialized neural pathway dedicated to, of all things, processing stimuli from having their head pat. Common throughout dogfolk, thought to be an adaptation to the fact that they are very good dogs."
	icon_state = "liver"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_HEADPAT_RECEPTOR
	color = "#FF00FF" // pank as hell

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	high_threshold_passed = span_warning("Your happy place(s) numben!")
	high_threshold_cleared = span_notice("Feeling returns to your happy place(s).")
	now_fixed = span_notice("The numbness in your happy place(s) dulls a bit.")

	/// do we like lots of pats from one person, or lots of pats from many people?
	var/patlover_kind = HEADPAT_MONOGAMOUS
	var/list/patters = list()

	var/short_

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)

/obj/item/organ/headpat_receptor/on_life()
	. = ..()
	if(!. || !owner)//can't process reagents with a failing liver (but its a sodie organ)
		return

/obj/item/organ/headpat_receptor/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!. || QDELETED(owner))
		return

/obj/item/organ/headpat_receptor/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_HEADPAT, .proc/head_was_pat)

/obj/item/organ/headpat_receptor/Remove(special = FALSE)
	UnregisterSignal(owner, COMSIG_MOB_HEADPAT)
	return ..()
