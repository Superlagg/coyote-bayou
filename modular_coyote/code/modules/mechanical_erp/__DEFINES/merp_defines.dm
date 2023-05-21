#define MERP_QUALITY_NORMAL
#define MERP_QUALITY_REPEAT
#define MERP_QUALITY_FLOWERY

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

#define MERP_AP_DELETEME "DELETEME"

#define PLAP_FRESH_TIME 30 SECONDS

#define MERP_TIME_TO_CUM_BASE 5 MINUTES

#define MERP_AROUSAL_GAIN_FACTOR 1
#define MERP_AROUSAL_LOSS_FACTOR 1
