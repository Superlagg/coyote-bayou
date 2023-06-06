//defines for loadout categories
//no category defines
#define LOADOUT_CATEGORY_NONE			"ERROR"
#define LOADOUT_SUBCATEGORY_NONE		"Miscellaneous"
#define LOADOUT_SUBCATEGORIES_NONE		list("Miscellaneous")

//the names of the customization tabs
#define SETTINGS_TAB 0
#define GAME_PREFERENCES_TAB 1
#define APPEARANCE_TAB 2
#define ERP_TAB 3
//#define SPEECH_TAB 3
#define LOADOUT_TAB 4
#define CONTENT_PREFERENCES_TAB 5
#define KEYBINDINGS_TAB 6

//the names of the erp tabs - can be 0, 1, or "has_cock" thru "has_womb"
#define ERP_TAB_HOME 0
#define ERP_TAB_REARRANGE 1

//backpack
#define LOADOUT_CATEGORY_BACKPACK 				"In backpack"
#define LOADOUT_SUBCATEGORY_BACKPACK_GENERAL 	"General" //basically anything that there's not enough of to have its own subcategory
//#define LOADOUT_SUBCATEGORY_BACKPACK_TOYS 		"Toys"
#define LOADOUT_SUBCATEGORY_BACKPACK_BACKPACKS 	"Backpacks"
#define LOADOUT_SUBCATEGORY_BACKPACK_RATIONS 	"Snacks"
//#define LOADOUT_SUBCATEGORY_BACKPACK_VAULTGUNS	"Vault Guns"

//neck
#define LOADOUT_CATEGORY_NECK "Neck"
#define LOADOUT_SUBCATEGORY_NECK_GENERAL 	"General"
//#define LOADOUT_SUBCATEGORY_NECK_TIE 		"Ties"
#define LOADOUT_SUBCATEGORY_NECK_SCARVES 	"Scarves"

//mask
#define LOADOUT_CATEGORY_MASK "Mask"
#define LOADOUT_SUBCATEGORY_MASK_GENERAL 		"General"
#define LOADOUT_SUBCATEGORY_MASK_BANDANA 		"Bandanas"
//#define LOADOUT_SUBCATEGORY_MASK_MISCELLANEOUS  "Miscellaneous"

//hands
#define LOADOUT_CATEGORY_HANDS 				"Hands"

//uniform
#define LOADOUT_CATEGORY_UNIFORM 			"Uniform" //there's so many types of uniform it's best to have lots of categories
#define LOADOUT_SUBCATEGORY_UNIFORM_GENERAL "General"
#define LOADOUT_SUBCATEGORY_UNIFORM_TRADITIONAL  	"Traditional"
#define LOADOUT_SUBCATEGORY_UNIFORM_SUITS	"Suits"
#define LOADOUT_SUBCATEGORY_UNIFORM_SKIRTS	"Skirts"
#define LOADOUT_SUBCATEGORY_UNIFORM_DRESSES	"Dresses"
#define LOADOUT_SUBCATEGORY_UNIFORM_SWEATERS	"Sweaters"
#define LOADOUT_SUBCATEGORY_UNIFORM_PANTS	"Pants"
#define LOADOUT_SUBCATEGORY_UNIFORM_RAIDER	"Raider"
#define LOADOUT_SUBCATEGORY_UNIFORM_WASTELAND "Wasteland"
#define LOADOUT_SUBCATEGORY_UNIFORM_UNIFORMS "Uniforms"
#define LOADOUT_SUBCATEGORY_UNIFORM_JUMPSUITS "Jumpsuits"
#define LOADOUT_SUBCATEGORY_UNIFORM_ESCORT "Escort"
#define LOADOUT_SUBCATEGORY_UNIFORM_TRIBAL "Tribal"

//suit
#define LOADOUT_CATEGORY_SUIT 				"Suit"
#define LOADOUT_SUBCATEGORY_SUIT_GENERAL 	"General"
#define LOADOUT_SUBCATEGORY_SUIT_ARMOR 		"Armor"
#define LOADOUT_SUBCATEGORY_SUIT_JACKETS	"Jackets"
//#define LOADOUT_SUBCATEGORY_SUIT_FACTIONS		"Factions"

//Belt
#define LOADOUT_CATEGORY_BELT 				"Belt"

//head
#define LOADOUT_CATEGORY_HEAD 				"Head"
#define LOADOUT_SUBCATEGORY_HEAD_GENERAL 	"General"
#define LOADOUT_SUBCATEGORY_HEAD_COWBOY			"Cowboy hats"
#define LOADOUT_SUBCATEGORY_HEAD_HELMETS 		"Helmets"

//shoes
#define LOADOUT_CATEGORY_SHOES 		"Shoes"
#define LOADOUT_SUBCATEGORY_SHOES_GENERAL 	"General"
#define LOADOUT_SUBCATEGORY_SHOES_BOOTS 	"Boots"
//#define LOADOUT_SUBCATEGORY_SHOES_FACTIONS 		"Factions"

//gloves
#define LOADOUT_CATEGORY_GLOVES		"Gloves"

//glasses
#define LOADOUT_CATEGORY_GLASSES	"Glasses"

//donator items
#define LOADOUT_CATEGORY_DONATOR	"Special"

//how many prosthetics can we have
#define MAXIMUM_LOADOUT_PROSTHETICS	4

//what limbs can be amputated or be prosthetic
#define LOADOUT_ALLOWED_LIMB_TARGETS	list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)

//options for modifiying limbs
#define LOADOUT_LIMB_NORMAL			"Normal"
#define LOADOUT_LIMB_PROSTHETIC		"Prosthetic"
#define LOADOUT_LIMB_AMPUTATED		"Amputated"

#define LOADOUT_LIMBS		 		list(LOADOUT_LIMB_NORMAL,LOADOUT_LIMB_PROSTHETIC,LOADOUT_LIMB_AMPUTATED) //you can amputate your legs/arms though

//loadout saving/loading specific defines
#define MAXIMUM_LOADOUT_SAVES 30	//Remember to increase this if more slots are added
#define LOADOUT_ITEM "loadout_item"
#define LOADOUT_COLOR "loadout_color"
#define LOADOUT_CUSTOM_NAME "loadout_custom_name"
#define LOADOUT_CUSTOM_DESCRIPTION "loadout_custom_description"

//loadout item flags
#define LOADOUT_CAN_NAME (1<<0) //renaming items
#define LOADOUT_CAN_DESCRIPTION (1<<1) //adding a custom description to items

//quirks
#define QUIRK_POSITIVE	"Positive"
#define QUIRK_NEGATIVE	"Negative"
#define QUIRK_NEUTRAL	"Neutral"

/////////////////////////////////////////////////////////////////
///////////////////////////////hi~///////////////////////////////
/////////////////////////////////////////////////////////////////
/// yeah i know its for a different loadout system, eat me
#define LOADOUT_FLAG_WASTER (1<<0)
#define LOADOUT_FLAG_LAWMAN (1<<1)
#define LOADOUT_FLAG_PREMIUM (1<<2)
#define LOADOUT_FLAG_TRIBAL (1<<3)
#define LOADOUT_FLAG_PREACHER (1<<4)
#define LOADOUT_FLAG_TOOL_WASTER (1<<5)

/// Loadout Coins
#define LOADOUT_COIN_PREMIUM "Exquisite"
#define LOADOUT_COIN_LAWMAN "Lawman"
#define LOADOUT_COIN_STANDARD "Standard" // Any non-specialized loadout
#define LOADOUT_COIN_WASTER "Waster"
#define LOADOUT_COIN_TRIBAL "Tribal"
#define LOADOUT_COIN_PREACHER "Preacher"
#define LOADOUT_COIN_SECONDARY "Secondary" // Any non-specialized sidearm thing (knives, pans, etc)
#define LOADOUT_COIN_TOOL "Tool"

/// Loadout price lists
/// These are the coins that are accepted for each loadout
#define LOADOUT_PRICE_PREMIUM list(LOADOUT_COIN_PREMIUM)
#define LOADOUT_PRICE_LAWMAN list(LOADOUT_COIN_LAWMAN)
#define LOADOUT_PRICE_TRIBAL list(LOADOUT_COIN_TRIBAL)
#define LOADOUT_PRICE_PREACHER list(LOADOUT_COIN_PREACHER)
#define LOADOUT_PRICE_STANDARD list(\
	LOADOUT_COIN_STANDARD,\
	LOADOUT_COIN_PREACHER,\
	LOADOUT_COIN_TRIBAL,\
	LOADOUT_COIN_LAWMAN,\
	LOADOUT_COIN_PREMIUM)
#define LOADOUT_PRICE_SECONDARY list(\
	LOADOUT_COIN_SECONDARY,\
	LAODOUT_COIN_PRIMARY,\
	LOADOUT_COIN_PREACHER,\
	LOADOUT_COIN_TRIBAL,\
	LOADOUT_COIN_LAWMAN,\
	LOADOUT_COIN_PREMIUM)

#define LOADOUT_KIT_KEY "kit_key"
#define LOADOUT_KIT_NAME "kit_name"
#define LOADOUT_KIT_PRICE "kit_price"
#define LOADOUT_KIT_CONTENTS "kit_contents"

#define LOADOUT_COIN_KEY "coin_key"
#define LOADOUT_COIN_NAME "coin_name"
#define LOADOUT_COIN_TOOLTIP "coin_tooltip"
#define LOADOUT_COIN_AWESOME_ICON "coin_awesome_icon"
#define LOADOUT_COIN_COLOR "coin_color"
#define LOADOUT_COIN_SUBSTITUTE_COINS "coin_substitute_coins"

#define LOADOUT_BITFIELD "loadout_bitfield"
#define LOADOUT_CLASS "loadout_class"
#define LOADOUT_PATH "loadout_path"

#define LOADOUT_CAT_PREMIUM "Fancy Weapons"
#define LOADOUT_CAT_LAWMAN "Law Weapons"
#define LOADOUT_CAT_MELEE_ONE "One Handed Melee"
#define LOADOUT_CAT_MELEE_TWO "Two Handed Melee"
#define LOADOUT_CAT_PISTOL "Pistols"
#define LOADOUT_CAT_REVOLVER "Revolvers"
#define LOADOUT_CAT_LONGGUN "Long Guns"
#define LOADOUT_CAT_HOBO "Improvised Guns"
#define LOADOUT_CAT_MUSKET "Blackpowder Guns"
#define LOADOUT_CAT_MISC "Misc Things"
#define LOADOUT_CAT_BOW "Bows"
#define LOADOUT_CAT_NULLROD "Spiritual Device"
#define LOADOUT_CAT_SHIELD "Shields"
#define LOADOUT_CAT_ENERGY "Energy Weapons"
#define LOADOUT_CAT_WORKER "Worker Tools"
#define LOADOUT_CAT_ADVENTURE "Adventure Tools"
#define LOADOUT_CAT_MEDICAL "Medical Tools"
#define LOADOUT_CAT_SINISTER "Sinister Tools"
#define LOADOUT_CAT_OTHER "Other Things"

#define LOADOUT_ROOT_ENTRIES list(LOADOUT_CAT_MELEE_ONE, LOADOUT_CAT_MELEE_TWO, LOADOUT_CAT_PISTOL, LOADOUT_CAT_REVOLVER, LOADOUT_CAT_LONGGUN, LOADOUT_CAT_HOBO, LOADOUT_CAT_MISC, LOADOUT_CAT_BOW, LOADOUT_CAT_ENERGY, LOADOUT_CAT_NULLROD, LOADOUT_CAT_SHIELD, LOADOUT_FLAG_TOOL_WASTER, LOADOUT_CAT_MUSKET)
#define LOADOUT_ALL_ENTRIES list(LOADOUT_CAT_PREMIUM, LOADOUT_CAT_LAWMAN, LOADOUT_CAT_MELEE_ONE, LOADOUT_CAT_MELEE_TWO, LOADOUT_CAT_PISTOL, LOADOUT_CAT_REVOLVER, LOADOUT_CAT_LONGGUN, LOADOUT_CAT_HOBO, LOADOUT_CAT_MISC, LOADOUT_CAT_BOW, LOADOUT_CAT_ENERGY, LOADOUT_CAT_NULLROD, LOADOUT_CAT_SHIELD, LOADOUT_CAT_WORKER, LOADOUT_CAT_ADVENTURE, LOADOUT_CAT_MEDICAL, LOADOUT_CAT_SINISTER, LOADOUT_CAT_OTHER, LOADOUT_CAT_MUSKET)



