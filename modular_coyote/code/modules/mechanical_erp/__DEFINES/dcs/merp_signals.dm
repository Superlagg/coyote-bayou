/// MERP SIGNALS ///

/// When a MERPI bit is used on another MERPI bit ///
#define COMSIG_MERP_USE_MERPI_BIT "merp_use_merpi_bit" // (datum/source, obj/item/merpi_bit/used, obj/item/target)
#define COMSIG_MERP_GIVE_HAND_BIT "merp_give_bit" // (datum/source, mob/living/give_to, "merpi_key")
/* 
 * When a MERPI bit is used on another MERPI bit
 * Assumes whoever caught the signal is doing the plap to the target
 * @param datum/source - The object that is using the bit, unused
 * @param mob/living/plappee - The mob being plapped
 * @param user_bit_key - The key of the bit doing the plapping
 * @param target_bit_key - The key of the bit getting plapped
 * @param intent - The intent of the plap
 * @param wielded - Whether the plapping bit is wielded or not
 * @param quality - The quality of the plap - MERP_QUALITY_NORMAL by default
 * @param ci - If the plapping bit is used with CI on
 */
#define COMSIG_MERP_DO_PLAP "merp_plap" // (datum/source, mob/living/plappee, user_bit_key, target_bit_key, intent, wielded, quality = MERP_QUALITY_NORMAL, ci)

/* 
 * When someone gets plapped by a MERPI bit
 * Assumes whoever caught the signal is being plapped by the plapper
 * @param datum/source - The object that is using the bit, unused
 * @param mob/living/plapper - The mob doing the plapping
 * @param user_bit_key - The key of the bit doing the plapping
 * @param target_bit_key - The key of the bit getting plapped
 * @param intent - The intent of the plap
 * @param wielded - Whether the plapping bit is wielded or not
 * @param quality - The quality of the plap - MERP_QUALITY_NORMAL by default
 * @param ci - If the plapping bit is used with CI on
 */
#define COMSIG_MERP_GET_PLAPPED "merp_get_plapped" // (datum/source, mob/living/plapper, user_bit_key, target_bit_key, intent, wielded, quality = MERP_QUALITY_NORMAL, ci)

/* 
 * When a combo is determined to be old or irrelevant or something
 * @param datum/source - The object that is using the bit, unused
 * @param datum/merp_combo/combo - The combo that is being killed
 */
#define COMSIG_MERP_KILL_COMBO "merp_kill_combo" // (datum/source, datum/merp_combo/combo)

/* 
 * When a plap is determined to be old or irrelevant or something
 * @param datum/source - The object that is using the bit, unused
 * @param datum/merp_plap_record/plap - The plap that is being killed
 */
#define COMSIG_MERP_PLAP_EXPIRED "merp_plap_expired" // (datum/source, datum/merp_plap_record/plap)

/* 
 * Another magic signal list nabbinator
 * @param datum/source - The object that is using the bit, unused
 * @param list/combos - The list that will be reference-returned with all the currentmost combos
 */
#define COMSIG_MERP_GET_OTHER_COMBOS "merp_get_other_combos" // (datum/source, list/combos)
