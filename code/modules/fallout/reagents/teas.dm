//fallout teas

// Discount fernet
/datum/reagent/consumable/tea/agavetea
	name = "Agave Tea"
	description = "A soothing herbal rememedy steeped from the Agave Plant. Soothes the stomach after a hearty meal."
	color = "#FFFF91"
	nutriment_factor = 0
	taste_description = "bitterness"
	glass_icon_state = "tea"
	glass_name = "Agave Tea"
	glass_desc = "A soothing herbal rememedy steeped from the Agave Plant. Soothes the stomach after a hearty meal."

/datum/reagent/consumable/tea/agavetea/on_mob_life(mob/living/carbon/M)
	if(M.nutrition >= NUTRITION_LEVEL_HUNGRY)
		M.nutrition -= rand(1,3)
		M.overeatduration = 0
	M.drowsyness = max(0 , M.drowsyness + 1) // post-eat itis
	M.dizziness = max(0 , M.dizziness-2)
	M.jitteriness = max(0 , M.jitteriness-3)
	M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = TRUE

// Discount broc juice
/datum/reagent/consumable/tea/broctea
	name = "Broc Tea"
	description = "A soothing herbal rememedy steeped from the Broc Flower. Settles an upset stomach, and provides a mild bruise healing effect."
	color = "#FF6347"
	nutriment_factor = 0
	taste_description = "bitterness"
	glass_icon_state = "tea"
	glass_name = "Broc Tea"
	glass_desc = "A soothing herbal rememedy steeped from the Broc Flower. Settles an upset stomach, and provides a mild bruise healing effect."

/datum/reagent/consumable/tea/broctea/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.25*REAGENTS_EFFECT_MULTIPLIER, 0)
	if(M.nutrition >= NUTRITION_LEVEL_HUNGRY)
		M.nutrition -= rand(1,3)
		M.overeatduration = 0
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness+1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = TRUE

// Discount jet
/datum/reagent/consumable/tea/coyotetea
	name = "Coyote Tea"
	description = "A smokey herbal rememedy steeped from coyote tobacco stems. Natural caffeines keep the drinker alert and awake while numbing the senses."
	color = "#008000"
	nutriment_factor = 0
	taste_description = "smoke"
	glass_icon_state = "coyotetea"
	glass_name = "Coyote Tea"
	glass_desc = "A smokey herbal rememedy steeped from coyote tobacco stems. Natural caffeines keep the drinker alert and awake while numbing the senses."

/datum/reagent/consumable/tea/coyotetea/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		var/smoke_message = pick(
			"You feel awake.", 
			"You feel wired.",
			"You feel alert.",
			"You feel rugged.")
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	M.AdjustStun(-5, 0)
	M.AdjustKnockdown(-5, 0)
	M.AdjustUnconscious(-40, 0)
	M.adjustStaminaLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.dizziness = max(0,M.dizziness+1)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness+3)
	M.AdjustSleeping(-20, FALSE)
	M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = TRUE

// Discount calomel
/datum/reagent/consumable/tea/feratea
	name = "Barrel Tea"
	description = "A sour and dry 'rememedy' steeped from barrel cactus fruit. Filters the user's blood through natural radioactive activated carbon."
	color = "#FF6347"
	nutriment_factor = 0
	taste_description = "bitterness"
	glass_icon_state = "tea"
	glass_name = "Barrel Tea"
	glass_desc = "A sour and dry 'rememedy' steeped from barrel cactus fruit. Filters the user's blood through natural radioactive activated carbon. Mildly toxic, but can purge other deadlier toxins."

/datum/reagent/consumable/tea/feratea/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.type,1)
	if(M.health > 20)
		M.adjustToxLoss(0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
		. = TRUE
	M.radiation += 0.1
	M.dizziness = max(0,M.dizziness+1)
	M.drowsyness = max(0,M.drowsyness+1)
	M.jitteriness = max(0,M.jitteriness+3)
	M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()
	. = TRUE

// Just yummy tea
/datum/reagent/consumable/tea/pricklytea
	name = "Prickly Tea"
	description = "A sweet and fruity rememedy steeped from prickly pear fruit. Nutritious and delicious."
	color = "#FF6347"
	nutriment_factor = 2
	taste_description = "sweetness"
	glass_icon_state = "cafe_latte"
	glass_name = "Prickly Tea"
	glass_desc = "A sweet and fruity rememedy steeped from prickly pear fruit. Nutritious and delicious."

/datum/reagent/consumable/tea/pricklytea/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(0,M.jitteriness-3)
	if(prob(50))
		M.adjustBruteLoss(-0.25*REAGENTS_EFFECT_MULTIPLIER, 0)
	else
		M.adjustFireLoss(-0.25*REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = TRUE

// Discount xander juice
/datum/reagent/consumable/tea/xandertea
	name = "Xander Tea"
	description = "A engaging herbal rememedy steeped from blitzed Xander root. Hydrates burns and helps liver function."
	color = "#FF6347"
	nutriment_factor = 0
	taste_description = "earthy"
	glass_icon_state = "coffee"
	glass_name = "Xander Tea"
	glass_desc = "A engaging herbal rememedy steeped from blitzed Xander root. Detoxifies and replenishes the bodies blood supply."

/datum/reagent/consumable/tea/xandertea/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -1)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.adjustFireLoss(-0.25, 0)
	M.adjustToxLoss(-0.25, 0)
	..()
	. = TRUE
