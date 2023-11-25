//Stores several modifiers in a way that isn't cleared by changing species

/datum/physiology
	var/brute_mod                  = 1   	// % of brute damage taken from all sources
	var/list/brute_modifiers       = list()   	// % of brute damage taken from all sources
	var/burn_mod                   = 1    	// % of burn damage taken from all sources
	var/list/burn_modifiers        = list()    	// % of burn damage taken from all sources
	var/tox_mod                    = 1     	// % of toxin damage taken from all sources
	var/list/tox_modifiers         = list()     	// % of toxin damage taken from all sources
	var/oxy_mod                    = 1     	// % of oxygen damage taken from all sources
	var/list/oxy_modifiers         = list()     	// % of oxygen damage taken from all sources
	var/clone_mod                  = 1   	// % of clone damage taken from all sources
	var/list/clone_modifiers       = list()   	// % of clone damage taken from all sources
	var/stamina_mod                = 1 	// % of stamina damage taken from all sources
	var/list/stamina_modifiers     = list() 	// % of stamina damage taken from all sources
	var/brain_mod                  = 1   	// % of brain damage taken from all sources
	var/list/brain_modifiers       = list()   	// % of brain damage taken from all sources

	var/pressure_mod               = 1	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/list/pressure_modifiers    = list()	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/heat_mod                   = 1    	// % of burn damage taken from heat (stacks with burn_mod)
	var/list/heat_modifiers        = list()    	// % of burn damage taken from heat (stacks with burn_mod)
	var/cold_mod                   = 1    	// % of burn damage taken from cold (stacks with burn_mod)
	var/list/cold_modifiers        = list()    	// % of burn damage taken from cold (stacks with burn_mod)

	var/damage_resistance          = 0 // %damage reduction from all sources
	var/list/damage_resistanceifiers = list() // %damage reduction from all sources

	var/siemens_coeff             = 1 	// resistance to shocks
	var/list/siemens_coeffifiers  = list() 	// resistance to shocks

	var/stun_mod                  = 1      	// % stun modifier
	var/list/stun_modifiers       = list()      	// % stun modifier
	var/bleed_mod                 = 1     	// % bleeding modifier
	var/list/bleed_modifiers      = list()     	// % bleeding modifier
	var/datum/armor/armor 	// internal armor datum

	var/hunger_mod                = 1		//% of hunger rate taken per tick.
	var/list/hunger_modifiers     = list()		//% of hunger rate taken per tick.

	var/do_after_speed            = 1 //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.
	var/list/do_after_speedifiers = list() //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.

	/// footstep type override for both shoeless and not footstep sounds.
	var/footstep_type

/datum/physiology/New()
	armor = new

/datum/physiology/Destroy(force, ...)
	QDEL_LIST_ASSOC_VALUE(brute_modifiers  )
	QDEL_LIST_ASSOC_VALUE(burn_modifiers   )
	QDEL_LIST_ASSOC_VALUE(tox_modifiers    )
	QDEL_LIST_ASSOC_VALUE(oxy_modifiers    )
	QDEL_LIST_ASSOC_VALUE(clone_modifiers  )
	QDEL_LIST_ASSOC_VALUE(stamina_modifiers)
	QDEL_LIST_ASSOC_VALUE(brain_modifiers  )
	. = ..()

/datum/physiology/proc/add_brute_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_BRUTE, mult, add, key     )

/datum/physiology/proc/add_burn_modifier(mult, add, key   )
	return add_modifier(PHYSMOD_BURN, mult, add, key      )

/datum/physiology/proc/add_tox_modifier(mult, add, key    )
	return add_modifier(PHYSMOD_TOX, mult, add, key       )

/datum/physiology/proc/add_oxy_modifier(mult, add, key    )
	return add_modifier(PHYSMOD_OXY, mult, add, key       )

/datum/physiology/proc/add_clone_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_CLONE, mult, add, key     )

/datum/physiology/proc/add_stamina_modifier(mult, add, key)
	return add_modifier(PHYSMOD_STAMINA, mult, add, key   )

/datum/physiology/proc/add_brain_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_BRAIN, mult, add, key     )

/datum/physiology/proc/add_pressure_modifier(mult, add, key)
	return add_modifier(PHYSMOD_PRESSURE, mult, add, key   )

/datum/physiology/proc/add_heat_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_HEAT, mult, add, key     )

/datum/physiology/proc/add_cold_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_COLD, mult, add, key     )

/datum/physiology/proc/add_damage_resistanceifier(mult, add, key)
	return add_modifier(PHYSMOD_DAMAGE_RESISTANCE, mult, add, key)

/datum/physiology/proc/add_siemens_coeffifier(mult, add, key)
	return add_modifier(PHYSMOD_SIEMENS_COEFF, mult, add, key)

/datum/physiology/proc/add_stun_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_STUN, mult, add, key     )

/datum/physiology/proc/add_bleed_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_BLEED, mult, add, key     )

/datum/physiology/proc/add_hunger_modifier(mult, add, key  )
	return add_modifier(PHYSMOD_HUNGER, mult, add, key     )

/datum/physiology/proc/add_do_after_speedifier(mult, add, key)
	return add_modifier(PHYSMOD_DO_AFTER_SPEED, mult, add, key)

/datum/physiology/proc/remove_brute_modifier(key  )
	return remove_modifier(PHYSMOD_BRUTE, key     )

/datum/physiology/proc/remove_burn_modifier(key   )
	return remove_modifier(PHYSMOD_BURN, key      )

/datum/physiology/proc/remove_tox_modifier(key    )
	return remove_modifier(PHYSMOD_TOX, key       )

/datum/physiology/proc/remove_oxy_modifier(key    )
	return remove_modifier(PHYSMOD_OXY, key       )

/datum/physiology/proc/remove_clone_modifier(key  )
	return remove_modifier(PHYSMOD_CLONE, key     )

/datum/physiology/proc/remove_stamina_modifier(key)
	return remove_modifier(PHYSMOD_STAMINA, key   )

/datum/physiology/proc/remove_brain_modifier(key  )
	return remove_modifier(PHYSMOD_BRAIN, key     )

/datum

/datum/physiology/proc/add_modifier(kind, mult, add, key)
	// Adds a modifier to the list of modifiers
	// kind is the type of damage to modify
	// mult is the multiplier to apply to the damage
	// add is the amount to add to the damage
	// key is the identifier for the modifier, used to remove it later
	var/list/modifiers
	switch(kind)
		if(PHYSMOD_BRUTE)
			modifiers = brute_modifiers
		if(PHYSMOD_BURN)
			modifiers = burn_modifiers
		if(PHYSMOD_TOX)
			modifiers = tox_modifiers
		if(PHYSMOD_OXY)
			modifiers = oxy_modifiers
		if(PHYSMOD_CLONE)
			modifiers = clone_modifiers
		if(PHYSMOD_STAMINA)
			modifiers = stamina_modifiers
		if(PHYSMOD_BRAIN)
			modifiers = brain_modifiers
		if(PHYSMOD_PRESSURE)
			modifiers = pressure_modifiers
		if(PHYSMOD_HEAT)
			modifiers = heat_modifiers
		if(PHYSMOD_COLD)
			modifiers = cold_modifiers
		if(PHYSMOD_DAMAGE_RESISTANCE)
			modifiers = damage_resistanceifiers
		if(PHYSMOD_SIEMENS_COEFF)
			modifiers = siemens_coeffifiers
		if(PHYSMOD_STUN)
			modifiers = stun_modifiers
		if(PHYSMOD_BLEED)
			modifiers = bleed_modifiers
		if(PHYSMOD_HUNGER)
			modifiers = hunger_modifiers
		if(PHYSMOD_DO_AFTER_SPEED)
			modifiers = do_after_speedifiers
		else
			return FALSE
	if(istype(LAZYACCESS(modifiers, key), /datum/physiology_modifier))
		var/datum/physiology_modifier/mod = LAZYACCESS(modifiers, key)
		mod.mult_mod = mult
		mod.add_mod = add
		update_modifiers()
		return mod
	var/datum/physiology_modifier/mod = new /datum/physiology_modifier(parent, key, mult, add)
	modifiers[key] = mod
	update_modifiers()
	return mod
	
/datum/physiology/proc/remove_modifier(kind, key)
	// Removes a modifier from the list of modifiers
	// kind is the type of damage to modify
	// key is the identifier for the modifier, used to remove it later
	var/list/modifiers
	switch(kind)
		if(PHYSMOD_BRUTE)
			modifiers = brute_modifiers
		if(PHYSMOD_BURN)
			modifiers = burn_modifiers
		if(PHYSMOD_TOX)
			modifiers = tox_modifiers
		if(PHYSMOD_OXY)
			modifiers = oxy_modifiers
		if(PHYSMOD_CLONE)
			modifiers = clone_modifiers
		if(PHYSMOD_STAMINA)
			modifiers = stamina_modifiers
		if(PHYSMOD_BRAIN)
			modifiers = brain_modifiers
		if(PHYSMOD_PRESSURE)
			modifiers = pressure_modifiers
		if(PHYSMOD_HEAT)
			modifiers = heat_modifiers
		if(PHYSMOD_COLD)
			modifiers = cold_modifiers
		if(PHYSMOD_DAMAGE_RESISTANCE)
			modifiers = damage_resistanceifiers
		if(PHYSMOD_SIEMENS_COEFF)
			modifiers = siemens_coeffifiers
		if(PHYSMOD_STUN)
			modifiers = stun_modifiers
		if(PHYSMOD_BLEED)
			modifiers = bleed_modifiers
		if(PHYSMOD_HUNGER)
			modifiers = hunger_modifiers
		if(PHYSMOD_DO_AFTER_SPEED)
			modifiers = do_after_speedifiers
		else
			return FALSE
	if(istype(LAZYACCESS(modifiers, key), /datum/physiology_modifier))
		var/datum/physiology_modifier/mod = LAZYACCESS(modifiers, key)
		qdel(mod)
		modifiers -= key
		update_modifiers()
		return TRUE
	return FALSE

/datum/physiology/proc/update_modifiers()
	for(var/varkind in PHYSMOD_ALL_OF_EM)
		var/list/allmod = PHYSMOD_ALL_OF_EM
		var/list/destination = vars[varkind]
		var/list/modifiers = vars[allmod[varkind]]
		if(!islist(modifiers))
			stack_trace("Hey, PHYSIOLIGY vars need to match what they are in the defines! (varkind: " + varkind + ")")
			continue
		var/mult = 1
		var/add = 0
		for(var/datum/physiology_modifier/mod in modifiers)
			mult *= mod.mult_mod
			add += mod.add_mod
		destination = mult
		destination += add

/datum/physiology_modifier
	/// The identifier for this modifier. This is used to remove it later!
	var/key
	var/datum/physiology/parent
	var/mult_mod = 1
	var/add_mod = 0

/datum/physiology_modifier/New(datum/physiology/P, newkey, newmult, newadd)
	. = ..()
	key = newkey
	parent = P
	mult_mod = newmult
	add_mod = newadd

/datum/physiology_modifier/Destroy(force, ...)
	parent = null
	. = ..()

