#define MERP_QUALITY_NORMAL "merp_quality_normal"
#define MERP_QUALITY_REPEAT "merp_quality_repeat"
#define MERP_QUALITY_FLOWERY "merp_quality_flowery"

#define is_merp_quality(A) (A in list(MERP_QUALITY_NORMAL, MERP_QUALITY_REPEAT, MERP_QUALITY_FLOWERY))

/// All jsons with the right format in this directory will be pulled for merping. All of them.
/// Adding new forms of merping is as simple as adding a new json file.
/// You're welcome, Fenny.
#define MERP_MASTER_DIRECTORY "modular_coyote/code/modules/mechanical_erp/merp_strings/"
#define MERP_SAVE_DIRECTORY "modular_coyote/code/modules/mechanical_erp/merp_saves/"
#define MERP_SAVEFILE_NAME "merp_save.json"

#define MERP_PATH(key) "[MERP_MASTER_DIRECTORY][key].json"

/// MERP prefkeys
#define PB_MERP_MASTER "merp_pref_master"
#define PB_MERP_MOAN_SOUNDS "merp_moan_sounds"
#define PB_MERP_EMOTES "merp_emotes"
#define PB_MERP_PLAP "merp_plap"

#define MERP_MAX_AROUSAL 900
#define MERP_AROUSAL_MIN 0
#define MERP_AROUSAL_LOW MERP_MAX_AROUSAL * 0.25
#define MERP_AROUSAL_MED MERP_MAX_AROUSAL * 0.5
#define MERP_AROUSAL_HIGH MERP_MAX_AROUSAL * 0.75
#define MERP_AROUSAL_NEAR_CLIMAX MERP_MAX_AROUSAL * 0.95
#define MERP_AROUSAL_BREAKPOINTS list("[MERP_AROUSAL_LOW]", "[MERP_AROUSAL_MED]", "[MERP_AROUSAL_HIGH]", "[MERP_AROUSAL_NEAR_CLIMAX]")

#define MERP_AROUSAL_PER_PLAP_BASE 1 // base per plap
#define MERP_AROUSAL_COMBO_MULT 2 // arousal multiplier per combo
#define MERP_MIN_PLAPS_FOR_COMBO 3 // minimum number of plaps for a combo
#define MERP_COMBO_SOFT_CAP 10 // soft cap for combo multiplier. It can go higher, for master MERPers, but it'll grant less and less arousal per combo
#define MERP_PLAP_HISTORY_LENGTH 100 // number of plaps to check for combos -- lol this is probably too high

#define MERP_COMBO_FINISHER_DIFFERENT_KEYS 1 // How much a different key is worth in a combo
#define MERP_COMBO_FINISHER_DIFFERENT_INTENTS 0.5 // How much a different intent is worth in a combo
#define MERP_COMBO_FINISHER_DIFFERENT_QUALITIES 0.5 // How much a different quality is worth in a combo

#define MERP_COMBO_MANUAL_BONUS 1 // Combo was finished by a manual plap

#define MERP_SCORE_COMBO "combo"
#define MERP_SCORE_EXTRA "extra"

#define MERP_AP_DELETEME "DELETEME"

#define MERP_PLAP_FRESH_TIME 30 SECONDS
#define MERP_PLAP_COMBO_TIME 30 SECONDS

#define MERP_TIME_TO_CUM_BASE 5 MINUTES

#define MERP_AROUSAL_GAIN_FACTOR 1
#define MERP_AROUSAL_LOSS_FACTOR 1


/* 
that combo was
1	Lame...
5	Cheesy
10	Not bad but not great either
15	Getting somewhere!
20	Nice, :) Good job
25	Cheflike
30	Brutal!
35	Evil
40	Unclean
45	Disturbing
50	Twisted
55	Psychotic
60	Ill-willed
65	Crushing
70	Funny!
75	Unfunny
 */
