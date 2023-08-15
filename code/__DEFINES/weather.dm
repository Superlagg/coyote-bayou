/// Z levels that are more or less above ground and can see the sky
/// For telling players about the weather
#define Z_LEVEL_CENTCOM 1
#define Z_LEVEL_DUNGEON 2
#define Z_LEVEL_NASH_UNDERGROUND 3
#define Z_LEVEL_NASH_COMMON 4
#define Z_LEVEL_NASH_LVL2 5
#define Z_LEVEL_NASH_LVL3 6
#define Z_LEVEL_REDWATER 7
#define Z_LEVEL_REDLICK 8
#define Z_LEVEL_GARLAND 9
#define Z_LEVEL_REDLICK_UPPER 10
#define Z_LEVEL_TRANSIT 11
#define Z_LEVEL_VR 12
#define ABOVE_GROUND_Z_LEVELS list(\
	Z_LEVEL_REDLICK_UPPER,\
	Z_LEVEL_NASH_COMMON,\
	Z_LEVEL_NASH_LVL2,\
	Z_LEVEL_NASH_LVL3,\
	Z_LEVEL_REDWATER,\
	Z_LEVEL_REDLICK,\
	Z_LEVEL_GARLAND)
#define COMMON_Z_LEVELS list(\
	Z_LEVEL_REDLICK_UPPER,\
	Z_LEVEL_NASH_UNDERGROUND,\
	Z_LEVEL_NASH_COMMON,\
	Z_LEVEL_NASH_LVL2,\
	Z_LEVEL_NASH_LVL3,\
	Z_LEVEL_REDWATER,\
	Z_LEVEL_REDLICK,\
	Z_LEVEL_GARLAND)
#define CORE_Z_LEVELS list(\
	Z_LEVEL_NASH_UNDERGROUND,\
	Z_LEVEL_NASH_COMMON,\
	Z_LEVEL_NASH_LVL2,\
	Z_LEVEL_NASH_LVL3)
#define VALIDBALL_Z_LEVELS list(\
	Z_LEVEL_CENTCOM,\
	Z_LEVEL_TRANSIT,\
	Z_LEVEL_REDLICK_UPPER,\
	Z_LEVEL_NASH_UNDERGROUND,\
	Z_LEVEL_NASH_COMMON,\
	Z_LEVEL_NASH_LVL2,\
	Z_LEVEL_NASH_LVL3,\
	Z_LEVEL_REDWATER,\
	Z_LEVEL_REDLICK,\
	Z_LEVEL_GARLAND)
#define ARTIFACT_Z_LEVELS list(\
	Z_LEVEL_NASH_UNDERGROUND,\
	Z_LEVEL_NASH_COMMON,\
	Z_LEVEL_NASH_LVL2,\
	Z_LEVEL_NASH_LVL3,\
	Z_LEVEL_REDWATER,\
	Z_LEVEL_REDLICK,\
	Z_LEVEL_GARLAND)

/// so you're probably wondering why all the Z level shit is in the weather defines
/// Who knows! 
/proc/z2text(turf/hereturf)
	if(!hereturf)
		return "!!UNKNOWN!!"
	if(!isturf(hereturf))
		hereturf = get_turf(hereturf)
		if(!isturf(hereturf))
			return "??UNKNOWN??"
	switch(hereturf.z)
		if(Z_LEVEL_GARLAND)
			return "Garland City - Common"
		if(Z_LEVEL_REDLICK_UPPER)
			return "Ashdown - Common"
		if(Z_LEVEL_TRANSIT)
			return "Moving along Rail Route 14-2 Delta"
		if(Z_LEVEL_CENTCOM)
			return "Somewhere far away~"
		if(Z_LEVEL_DUNGEON)
			return "Hostile Region 47-Q"
		if(Z_LEVEL_VR)
			return "C:/AAAACOYOTE/coyote-bayou/maps/mybutt.dmm"
		if(Z_LEVEL_NASH_UNDERGROUND)
			return "Nash Wastes - Underground"
		if(Z_LEVEL_NASH_COMMON)
			return "Nash Wastes - Common"
		if(Z_LEVEL_NASH_LVL2)
			return "Nash Wastes - Second Story"
		if(Z_LEVEL_NASH_LVL3)
			return "Nash Wastes - Third Story"
		if(Z_LEVEL_REDWATER)
			return "Southern Wastes - Common"
		if(Z_LEVEL_REDLICK)
			return "Northern Wastes - Common"
		else
			return "~!UNKNOWN!~"

/* * * * * * * * * * * * *
 * THE Z LEVELS~
 * 3 = NASH UNDERGROUND
 * 4 = NASH CENTRAL
 * 5 = NASH LVL 2
 * 6 = NASH LVL 3
 * 7 = REDWATER
 * 8 = REDLICK
 * * * * * * * * * * * * */

/// Minimum time between weathers
#define WEATHER_WAIT_MIN 30 MINUTES
/// Maximum time between weathers
#define WEATHER_WAIT_MAX 45 MINUTES

/// Weather tags!

#define WEATHER_HEAT "heat_wave"
#define WEATHER_COLD "cold_snap"
#define WEATHER_SNOW "snow_storm"
#define WEATHER_RAIN "normal_ass_rain"
#define WEATHER_ACID "acid_rain"
#define WEATHER_SAND "sand_storm"
#define WEATHER_RADS "RADSTORM"
#define WEATHER_ALL_AREAS "all_of_em"

/// All weather tags
#define WEATHER_ALL WEATHER_HEAT,\
	WEATHER_COLD,\
	WEATHER_SNOW,\
	WEATHER_RAIN,\
	WEATHER_ACID,\
	WEATHER_SAND,\
	WEATHER_RADS

/// All weather tags,
#define WEATHER_ALL_MINUS_HEAT WEATHER_COLD,\
	WEATHER_SNOW,\
	WEATHER_RAIN,\
	WEATHER_ACID,\
	WEATHER_SAND,\
	WEATHER_RADS

