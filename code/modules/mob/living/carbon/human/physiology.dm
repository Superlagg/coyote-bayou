//Stores several modifiers in a way that isn't cleared by changing species

/datum/physiology
	var/list/modifiers             = list()   	// % of brute damage taken from all sources
	var/brute_mod                  = 1   	// % of brute damage taken from all sources
	var/burn_mod                   = 1    	// % of burn damage taken from all sources
	var/tox_mod                    = 1     	// % of toxin damage taken from all sources
	var/oxy_mod                    = 1     	// % of oxygen damage taken from all sources
	var/clone_mod                  = 1   	// % of clone damage taken from all sources
	var/stamina_mod                = 1 	// % of stamina damage taken from all sources
	var/brain_mod                  = 1   	// % of brain damage taken from all sources
	var/pressure_mod               = 1	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/heat_mod                   = 1    	// % of burn damage taken from heat (stacks with burn_mod)
	var/cold_mod                   = 1    	// % of burn damage taken from cold (stacks with burn_mod)
	var/damage_resistance          = 0 // %damage reduction from all sources
	var/siemens_coeff             = 1 	// resistance to shocks
	var/stun_mod                  = 1      	// % stun modifier
	var/bleed_mod                 = 1     	// % bleeding modifier
	var/hunger_mod                = 1		//% of hunger rate taken per tick.
	var/do_after_speed            = 1 //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.
	var/datum/armor/armor 	// internal armor datum

	/// footstep type override for both shoeless and not footstep sounds.
	var/footstep_type

/datum/physiology/New()
	armor = new

/datum/physiology/Destroy(force, ...)
	QDEL_LIST_ASSOC_VALUE(brute_modifiers  )

	. = ..()

//////////////////////////////////

/datum/physiology/proc/add_modifier(kind, mult, add, key)
	if(!key)
		key = "[kind]-generic"
	// Adds a modifier to the list of modifiers
	// kind is the type of damage to modify
	// mult is the multiplier to apply to the damage
	// add is the amount to add to the damage
	// key is the identifier for the modifier, used to remove it later
	if(istype(LAZYACCESS(modifiers, key), /datum/physiology_modifier))
		var/datum/physiology_modifier/mod = LAZYACCESS(modifiers, key)
		mod.mult_mod = mult
		mod.add_mod = add
	else
		var/datum/physiology_modifier/mod = new /datum/physiology_modifier(parent, kind, key, mult, add)
		modifiers[key] = mod
	update_modifiers()
	return mod
	
/datum/physiology/proc/remove_modifier(key)
	if(!istype(LAZYACCESS(modifiers, key), /datum/physiology_modifier))
		return FALSE
	var/datum/physiology_modifier/mod = LAZYACCESS(modifiers, key)
	qdel(mod)
	modifiers -= key
	update_modifiers()
	return TRUE

/datum/physiology/proc/update_modifiers()
	reset_values()
	for(var/thingkey in modifiers)
		var/datum/physiology_modifier/mod = LAZYACCESS(modifiers, thingkey)
		if(!mod)
			continue
		switch(mod.kind)
			if(PHYSMOD_BRUTE)
				brute_mod                 = mod.crunch_number(brute_mod)
			if(PHYSMOD_BURN)
				burn_mod                  = mod.crunch_number(burn_mod)
			if(PHYSMOD_TOX)
				tox_mod                   = mod.crunch_number(tox_mod)
			if(PHYSMOD_OXY)
				oxy_mod                   = mod.crunch_number(oxy_mod)
			if(PHYSMOD_CLONE)
				clone_mod                 = mod.crunch_number(clone_mod)
			if(PHYSMOD_STAMINA)
				stamina_mod               = mod.crunch_number(stamina_mod)
			if(PHYSMOD_BRAIN)
				brain_mod                 = mod.crunch_number(brain_mod)
			if(PHYSMOD_PRESSURE)
				pressure_mod              = mod.crunch_number(pressure_mod)
			if(PHYSMOD_HEAT)
				heat_mod                  = mod.crunch_number(heat_mod)
			if(PHYSMOD_COLD)
				cold_mod                  = mod.crunch_number(cold_mod)
			if(PHYSMOD_DAMAGE_RESISTANCE)
				damage_resistance         = mod.crunch_number(damage_resistance)
			if(PHYSMOD_SIEMENS_COEFF)
				siemens_coeff             = mod.crunch_number(siemens_coeff)
			if(PHYSMOD_STUN)
				stun_mod                  = mod.crunch_number(stun_mod)
			if(PHYSMOD_BLEED)
				bleed_mod                 = mod.crunch_number(bleed_mod)
			if(PHYSMOD_HUNGER)
				hunger_mod                = mod.crunch_number(hunger_mod)
			if(PHYSMOD_DO_AFTER_SPEED)
				do_after_speed            = mod.crunch_number(do_after_speed)

/datum/physiology/proc/reset_values()
	brute_mod         =initial(brute_mod)
	burn_mod          =initial(burn_mod)
	tox_mod           =initial(tox_mod)
	oxy_mod           =initial(oxy_mod)
	clone_mod         =initial(clone_mod)
	stamina_mod       =initial(stamina_mod)
	brain_mod         =initial(brain_mod)
	pressure_mod      =initial(pressure_mod)
	heat_mod          =initial(heat_mod)
	cold_mod          =initial(cold_mod)
	damage_resistance =initial(damage_resistance)
	siemens_coeff     =initial(siemens_coeff)
	stun_mod          =initial(stun_mod)
	bleed_mod         =initial(bleed_mod)
	hunger_mod        =initial(hunger_mod)
	do_after_speed    =initial(do_after_speed)

/datum/physiology_modifier
	/// The identifier for this modifier. This is used to remove it later!
	var/key
	var/datum/weakref/parent
	var/mult_mod = 1
	var/add_mod = 0
	var/kind

/datum/physiology_modifier/New(datum/physiology/P, kind, newkey, newmult, newadd)
	. = ..()
	key = newkey
	parent = WEAKREF(P)
	mult_mod = newmult
	add_mod = newadd
	src.kind = kind

/datum/physiology_modifier/Destroy(force, ...)
	parent = null
	. = ..()

/datum/physiology_modifier/proc/crunch_number(num)
	return (num * mult_mod) + add_mod

