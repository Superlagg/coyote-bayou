/datum/reagent/consumable/nuka_cola
	name = "Cosmic Cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	taste_description = "the future"
	glass_icon_state = "nukacolaglass"
	glass_name = "Cosmic Cola"
	glass_desc = "Don't cry, Don't raise your eye, It's only nuclear wasteland."
	overdose_threshold = 100
	ghoulfriendly = TRUE

/datum/reagent/consumable/nuka_cola/on_mob_life(mob/living/carbon/M)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(HAS_TRAIT(M, TRAIT_NUKA_LOVER))
		M.adjustBruteLoss(-0.05)
		M.adjustFireLoss(-0.05)
	..()

/datum/reagent/consumable/nuka_cola/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("Too much Nuka-Cola! This cannot be good for you!"))
	M.AdjustSleeping(600, FALSE)
	. = 1

/datum/reagent/consumable/sunset
	name = "Sunset Sarsaparilla"
	description = "Build Mass With Sass!"
	color = "#994C00" // rgb: 153, 76, 0
	taste_description = "root beer, vanilla and caramel"
	glass_icon_state = "sunsetglass"
	glass_name = "glass of Sunset Sarsaparilla"
	glass_desc = "Beverage of the West Coast."
	ghoulfriendly = TRUE

/datum/reagent/consumable/sunset/on_mob_life(mob/living/carbon/M)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/vim
	name = "Vim"
	description = "You've Got Vim!"
	color = "#946B4A"
	taste_description = "off-brand Cosmic-cola"
	glass_icon_state = "vimglass"
	glass_name = "glass of Vim"
	glass_desc = "Unrelated to Cosmic-Cola, Vim trademark Circa 2077."
	ghoulfriendly = TRUE

/datum/reagent/consumable/vim/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-0.5, 0)
	M.adjustOxyLoss(0.5, 0)
	M.drowsyness = max(0,M.drowsyness-3)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder?.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = TRUE

/datum/reagent/consumable/vimquartz
	name = "Vim Quartz"
	description = "You've Got Vim! Quartz edition, worse than the Imitation."
	color = "#946B4A"
	taste_description = "off-brand Cosmic-cola but fucking worse"
	glass_icon_state = "vimquartzglass"
	glass_name = "Vim Quartz"
	glass_desc = "You've Got Vim! Quartz edition, worse than the Imitation."

/datum/reagent/consumable/vimquartz/on_mob_life(mob/living/carbon/M)
	M.vomit(10)
	M.adjustToxLoss(-1, 0)
	M.adjustOxyLoss(2, 0)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder?.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = TRUE

/datum/reagent/consumable/vimrefresh
	name = "Vim Refresh"
	description = "You've Got Vim Refresh! Ooooh!"
	color = "#BFAC9C"
	taste_description = "off-brand Cosmic-cola and refreshment"
	glass_icon_state = "grasshopper"
	glass_name = "Vim Refresh"
	glass_desc = "You've Got Vim Refresh! Ooooh!"

/datum/reagent/consumable/vimrefresh/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustToxLoss(-0.1, 0)
	M.adjustOxyLoss(1, 0)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder?.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = TRUE

/datum/reagent/consumable/vimice
	name = "Vim Ice"
	description = "You've Got Vim! Cold as the East."
	color = "#DFECED"
	taste_description = "cold off-brand Cosmic-cola"
	glass_icon_state = "vimiceglass"
	glass_name = "Iced Vim"
	glass_desc = "You've Got Vim! Cold as the East."

/datum/reagent/consumable/vimice/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, T0C)
	M.adjustFireLoss(-0.2*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1, 0)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	//310.15 is the normal bodytemp.
	..()
	. = TRUE

//nuka bases

/datum/reagent/consumable/nukacherry
	name = "Cosmic Cherry"
	description = "Cosmic-Cola with a Cherry Aftertaste."
	color = "#9C1512"
	taste_description = "fizzy cherry soda"
	glass_icon_state = "nukacherryglass"
	glass_name = "Cosmic Cherry"
	glass_desc = "Cosmic-Cola with a Cherry Aftertaste."

/datum/reagent/consumable/nukacherry/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukagrape
	name = "Cosmic Grape"
	description = "Cosmic-Cola with a Grape Aftertaste."
	color = "#643B65"
	taste_description = "fizzy grape soda"
	glass_icon_state = "nukagrapeglass"
	glass_name = "Cosmic Grape"
	glass_desc = "Cosmic-Cola with a Grape Aftertaste."

/datum/reagent/consumable/nukagrape/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(-0.1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukaorange
	name = "Cosmic Orange"
	description = "Cosmic-Cola with a Orange Aftertaste."
	color = "#FF7F00"
	taste_description = "fizzy orange soda"
	glass_icon_state = "nukaorangeglass"
	glass_name = "Cosmic Orange"
	glass_desc = "Cosmic-Cola with a Orange Aftertaste."

/datum/reagent/consumable/nukaorange/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-0.1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukaquartz
	name = "Cosmic Quartz"
	description = "An abomination of Americas favourite soda."
	color = "#FFFFFF"
	taste_description = "clear"
	glass_icon_state = "nukaquartzglass"
	glass_name = "Cosmic Quartz"
	glass_desc = "An abomination of Americas favourite soda."

/datum/reagent/consumable/nukaquartz/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukaice
	name = "Iced Cosmic"
	description = "Cosmic. Stay frosty."
	color = "#646A7B"
	taste_description = "cold Nuka-Cola"
	glass_icon_state = "nukaiceglass"
	glass_name = "Iced Cosmic"
	glass_desc = "Cosmic. Stay frosty."

/datum/reagent/consumable/nukaice/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT, T0C) //310.15 is the normal bodytemp.
	M.drowsyness = 0
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(HAS_TRAIT(M, TRAIT_NUKA_LOVER))
		M.adjustBruteLoss(-0.075)
		M.adjustFireLoss(-0.075)
	..()
	. = TRUE

/datum/reagent/consumable/nukaice/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("Too much Nuka-Cola! This cannot be good for you!"))
	M.AdjustSleeping(600, FALSE)
	. = 1

/datum/reagent/consumable/nukawild
	name = "Cosmic Wild"
	description = "A totally original concept of Cosmic-Cola!"
	color = "#734517"
	taste_description = "Nuka and root-beer"
	glass_icon_state = "nukawildglass"
	glass_name = "Cosmic Wild"
	glass_desc = "A totally original concept of Cosmic-Cola!"

/datum/reagent/consumable/nukawild/on_mob_life(mob/living/carbon/M)
	M.AdjustStun(-2, 0)
	M.AdjustKnockdown(-2, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukaray
	name = "Cosmic Ray"
	description = "A Cosmic mixture of both Cosmic victory and orange."
	color = "#FFFF00"
	taste_description = "Cosmic orange with a kick"
	glass_icon_state = "nukarayglass"
	glass_name = "Cosmic Ray"
	glass_desc = "A Cosmic mixture of both Cosmic victory and orange."

/datum/reagent/consumable/nukaray/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukarush
	name = "Cosmic Rush"
	description = "A Cosmic mixture of both Cosmic victory and wild."
	color = "#FFFF00"
	taste_description = "Cosmic wild with a kick"
	glass_icon_state = "nukarushglass"
	glass_name = "Cosmic Rush"
	glass_desc = "A Cosmic mixture of both Cosmic victory and wild."

/datum/reagent/consumable/nukarush/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-1.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(-1.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBruteLoss(-1.5*REAGENTS_EFFECT_MULTIPLIER)
	M.drowsyness = 0
	M.AdjustSleeping(-60, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

//nuka mixes

/datum/reagent/consumable/nukanew
	name = "New-Cosmic Cola"
	description = "The tastiest Hybridisation of Cosmic-Colas."
	color = "#75E11D"
	taste_description = "impossibly tasty Cosmic"
	glass_icon_state = "nukanewglass"
	glass_name = "New-Cosmic Cola"
	glass_desc = "The tastiest Hybridisation of Cosmic-Colas."

/datum/reagent/consumable/nukanew/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.AdjustStun(-3, 0)
	M.AdjustKnockdown(-3, 0)
	M.AdjustUnconscious(-3, 0)
	M.drowsyness = 0
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukaberry
	name = "Cosmic Berry"
	description = "Cosmic-Cola with a Berry Aftertaste."
	color = "#753453"
	taste_description = "berry Cosmic-Cola"
	glass_icon_state = "nukaberryglass"
	glass_name = "Cosmic Berry"
	glass_desc = "Cosmic-Cola with a Berry Aftertaste."

/datum/reagent/consumable/nukacooler
	name = "Cosmic Cooler"
	description = "Insanely cold Cosmic-Cola, Freezing the air that surrounds it."
	color = "#B2B2B2"
	taste_description = "insanely cold Cosmic-Cola"
	glass_icon_state = "nukacoolerglass"
	glass_name = "Cosmic Cooler"
	glass_desc = "Insanely cold Cosmic-Cola, Freezing the air that surrounds it."

/datum/reagent/consumable/nukacooler/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(-60 * TEMPERATURE_DAMAGE_COEFFICIENT, T0C) //310.15 is the normal bodytemp.
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/nukafree
	name = "Diet Cosmic"
	description = "Cosmic-Cola with no added sugars!"
	color = "#663300"
	taste_description = "watered down Cosmic"
	glass_icon_state = "nukafreeglass"
	glass_name = "Diet Cosmic"
	glass_desc = "Cosmic-Cola with no added sugars!"

/datum/reagent/consumable/nukafree/on_mob_life(mob/living/carbon/M)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(0.1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.nutrition = max(M.nutrition - 3, 0)
	M.overeatduration = 0
	M.drowsyness = 0
	..()
	. = TRUE

/datum/reagent/consumable/nukafrutti
	name = "Cosmic Frutti"
	description = "The frutiest of Cosmics."
	color = "#FF9ABF"
	taste_description = "fruity Cosmic"
	glass_icon_state = "nukafruttiglass"
	glass_name = "Cosmic Frutti"
	glass_desc = "The frutiest of Cosmic."

/datum/reagent/consumable/nukafrutti/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	..()
	. = TRUE

//shake shack royal rumble

/datum/reagent/consumable/nukafloat
	name = "Cosmic Float"
	description = "A delicious blend of ice-cream and classic Nuka-Cosmic!"
	color = "#11111E"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	taste_description = "creamy Cosmic"
	glass_icon_state = "nukafloatglass"
	glass_name = "Nuka Cosmic"
	glass_desc = "A delicious blend of ice-cream and classic Cosmic-Cola!"

/datum/reagent/consumable/sunsetfloat
	name = "Sunset Float"
	description = "A delicious blend of ice-cream and classic Sunset Sass!"
	color = "#734517"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	taste_description = "creamy root beer"
	glass_icon_state = "sunsetfloatglass"
	glass_name = "Sunset Float"
	glass_desc = "A delicious blend of ice-cream and classic Sunset Sass!"

/datum/reagent/consumable/bawlsshake
	name = "Bawls Shake"
	description = "A blended shake consumed by those on high energy blitz-lifestyles."
	color = "#0070E1"
	nutriment_factor = 10
	taste_description = "creamy sugar"
	glass_icon_state = "bawlsshakeglass"
	glass_name = "Bawls Shake"
	glass_desc = "A blended shake consumed by those on high energy blitz-lifestyles."

/datum/reagent/consumable/jakeshake
	name = "Jake Shake"
	description = "Jakes patented shake of Jake."
	color = "#7ABB5F"
	nutriment_factor = 10
	taste_description = "creamy patented juice"
	glass_icon_state = "jakeshakeglass"
	glass_name = "Jake Shake"
	glass_desc ="Jakes patented shake of Jake."

/datum/reagent/consumable/jakeshake/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/sweetwaterfloat
	name = "Sweetwater Float"
	description = "The sweetest water."
	color = "#FAFAF8"
	nutriment_factor = 10
	taste_description = "the sweetest water"
	glass_icon_state = "sweetwaterfloatglass"
	glass_name = "Sweetwater Float"
	glass_desc = "The sweetest water."

/datum/reagent/consumable/sweetwaterfloat/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-0.2*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/sunsetter
	name = "Sunsetter"
	description = "For when the days dawn, lest brings a brighter tommorrow."
	color = "#B06A24"
	nutriment_factor = 10
	taste_description = "days gone by"
	glass_icon_state = "sunsetterglass"
	glass_name = "Sunsetter"
	glass_desc = "For when the days dawn, lest brings a brighter tommorrow."

/datum/reagent/consumable/sunsetter/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/yuccashake
	name = "Yucca Shake"
	description = "A blended shake consisting of yucca and creamy goodness."
	color = "#FFD24A"
	nutriment_factor = 10
	taste_description = "bannanas and cream"
	glass_icon_state = "yuccashakeglass"
	glass_name = "Yucca Shake"
	glass_desc = "A blended shake consisting of yucca and creamy goodness."

/datum/reagent/consumable/yuccashake/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, 0)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()
	. = TRUE

/datum/reagent/consumable/bawls
	name = "Balls Guarana"
	description = "For that Guarana Bounce!"
	color = "#494A82"
	taste_description = "insanely sweet coffee"
	glass_icon_state = "bawlsglass"
	glass_name = "glass of Balls Guarana"
	glass_desc = "Beverage of the Balls Guarana Company."

/datum/reagent/consumable/bawls/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.AdjustSleeping(-40, FALSE)
	//310.15 is the normal bodytemp.
	M.adjust_bodytemperature(25 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	if(holder?.has_reagent(/datum/reagent/consumable/frostoil))
		holder.remove_reagent(/datum/reagent/consumable/frostoil, 5)
	..()
	. = 1

/datum/reagent/consumable/big_red
	name = "Atomic Red"
	description = "Nothing Bigger or Redder than Big Red!" // NOTICES BIG RED ROCKET KNOT OWO X3 ~MURR~ HE HE HE
	color = "#ff0000"
	taste_description = "bubblegum with a creamy aftertaste"
	glass_icon_state = "bigred"
	glass_name = "bottle of Atomic Red"
	glass_desc = "A bottle of an old southern classic soda, still mixed to this day. A creamy blend of bubblegum-esque orange-lemon, topped off with vanilla for a uniquely pleasant flavor. A favorite of otterlike folk."

/datum/reagent/consumable/big_red/on_mob_life(mob/living/carbon/M)
	M.drowsyness = 0
	M.AdjustSleeping(-40, FALSE)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	if(HAS_TRAIT(M, TRAIT_NUKA_LOVER))
		M.adjustBruteLoss(-0.05)
		M.adjustFireLoss(-0.05)
	..()
	. = 1
