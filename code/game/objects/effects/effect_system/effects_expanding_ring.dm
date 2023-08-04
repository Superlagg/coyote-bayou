/////////////////////////////////////////////
//// cool angled line 
/////////////////////////////////////////////

/// Generates a scaled line starting at a turf and extending for a fixed length in a given angle
/datum/effect_fancy/expanding_ring
	index = EFFECT_RING_EFFECT
	var/obj/effect/temp_visual/ringholder/myline = /obj/effect/temp_visual/ringholder

/// Generates a scaled line starting at a turf and extending for a fixed length in a given angle
/datum/effect_fancy/expanding_ring/do_effect(turf/start, size, duration)
	if(!isturf(start) || !size || !time)
		return
	var/obj/effect/temp_visual/ringholder/the_ring = new myring(get_turf(start), time)
	var/matrix/t_end = matrix()
	M = M.Scale(size, size)
	animate(the_ring, transform = t_end, time = duration, alpha = 0)

/obj/effect/temp_visual/ringholder
	icon = 'icons/effects/effects.dmi'
	icon_state = "medi_holo_no_anim" // I love that anima
	duration = 0.3 SECONDS

/obj/effect/temp_visual/ringholder/Initialize(mapload, time_override)
	if(!isnull(time_override))
		duration = time_override
	. = ..()
	
