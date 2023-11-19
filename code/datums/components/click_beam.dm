/* 
 * Its a component that intercepts your clicks and makes a beam to that location
 * 
 * */
/datum/component/click_beam
	var/datum/point/vector/punch_laser
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/click_beam/Initialize(rads_per_second, list/ref_n_type)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED), .proc/update_clickhack)
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED), .proc/update_clickhack)




