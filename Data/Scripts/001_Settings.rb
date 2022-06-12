#==============================================================================#
#                              Pokémon Essentials                              #
#                                 Version 19.1                                 #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#

module Settings
  # The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
  GAME_VERSION = '5.2.0'

  # The generation that the battle system follows. Used throughout the battle
  # scripts, and also by some other settings which are used in and out of battle
  # (you can of course change those settings to suit your game).
  # Note that this isn't perfect. Essentials doesn't accurately replicate every
  # single generation's mechanics. It's considered to be good enough. Only
  # generations 5 and later are reasonably supported.
  MECHANICS_GENERATION = 8

  #=============================================================================

  # The default screen width (at a scale of 1.0).
  SCREEN_WIDTH  = 512
  # The default screen height (at a scale of 1.0).
  SCREEN_HEIGHT = 384
  # The default screen scale factor. Possible values are 0.5, 1.0, 1.5 and 2.0.
  SCREEN_SCALE  = 1.0

  #=============================================================================

  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL            = 100
  # The level of newly hatched Pokémon.
  EGG_LEVEL                = 1
  # The odds of a newly generated Pokémon being shiny (out of 65536).
  SHINY_POKEMON_CHANCE     = (MECHANICS_GENERATION >= 6) ? 16 : 8
  # The odds of a newly generated Pokémon being a Brilliant Pokemon (out of 65536).
  # Set this to 0 to disable Brilliant Pokemon.
  BRILLIANT_POKEMON_CHANCE = 64
  # Whether square shininess is enabled (uses a different shiny animation with
  # square sparkles).
  SQUARE_SHINY             = (MECHANICS_GENERATION >= 8)
  # The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
  POKERUS_CHANCE           = 3
  # Whether a bred baby Pokémon can inherit any TM/HM moves from its father. It
  # can never inherit TM/HM moves from its mother.
  BREEDING_CAN_INHERIT_MACHINE_MOVES         = (MECHANICS_GENERATION <= 5)
  # Whether a bred baby Pokémon can inherit egg moves from its mother. It can
  # always inherit egg moves from its father.
  BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER = (MECHANICS_GENERATION >= 6)

  #=============================================================================

  # The amount of money the player starts the game with.
  INITIAL_MONEY        = 10000
  # The maximum amount of money the player can have.
  MAX_MONEY            = 999_999
  # The maximum number of Game Corner coins the player can have.
  MAX_COINS            = 99_999
  # The maximum number of Battle Points the player can have.
  MAX_BATTLE_POINTS    = 9_999
  # The maximum amount of soot the player can have.
  MAX_SOOT             = 9_999
  # The maximum length, in characters, that the player's name can be.
  MAX_PLAYER_NAME_SIZE = 10
  # The maximum number of Pokémon that can be in the party.
  MAX_PARTY_SIZE       = 6

  #=============================================================================

  # A set of arrays each containing a trainer type followed by a Global Variable
  # number. If the variable isn't set to 0, then all trainers with the
  # associated trainer type will be named as whatever is in that variable.
  RIVAL_NAMES = [
  ]

  #=============================================================================

  # Whether outdoor maps should be shaded according to the time of day.
  TIME_SHADING = true

  #=============================================================================

  # Whether poisoned Pokémon will lose HP while walking around in the field.
  POISON_IN_FIELD       = (MECHANICS_GENERATION <= 4)
  # Whether poisoned Pokémon will faint while walking around in the field
  # (true), or survive the poisoning with 1 HP (false).
  POISON_FAINT_IN_FIELD = (MECHANICS_GENERATION <= 3)
  # Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
  # mechanics (false).
  NEW_BERRY_PLANTS      = (MECHANICS_GENERATION >= 4)
  # Whether fishing automatically hooks the Pokémon (true), or whether there is
  # a reaction test first (false).
  FISHING_AUTO_HOOK     = false
  # The ID of the common event that runs when the player starts fishing (runs
  # instead of showing the casting animation).
  FISHING_BEGIN_COMMON_EVENT = -1
  # The ID of the common event that runs when the player stops fishing (runs
  # instead of showing the reeling in animation).
  FISHING_END_COMMON_EVENT   = -1

  #=============================================================================

  # The number of steps allowed before a Safari Zone game is over (0=infinite).
  SAFARI_STEPS     = 600
  # The number of seconds a Bug Catching Contest lasts for (0=infinite).
  BUG_CONTEST_TIME = 20 * 60   # 20 minutes

  #=============================================================================

  # Pairs of map IDs, where the location signpost isn't shown when moving from
  # one of the maps in a pair to the other (and vice versa). Useful for single
  # long routes/towns that are spread over multiple maps.
  #   e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
  # Moving between two maps that have the exact same name won't show the
  # location signpost anyway, so you don't need to list those maps here.
  NO_SIGNPOSTS = []

  #=============================================================================

  # Whether you need at least a certain number of badges to use some hidden
  # moves in the field (true), or whether you need one specific badge to use
  # them (false). The amounts/specific badges are defined below.
  FIELD_MOVES_COUNT_BADGES = false
  # Depending on FIELD_MOVES_COUNT_BADGES, either the number of badges required
  # to use each hidden move in the field, or the specific badge number required
  # to use each move. Remember that badge 0 is the first badge, badge 1 is the
  # second badge, etc.
  #   e.g. To require the second badge, put false and 1.
  #        To require at least 2 badges, put true and 2.
  BADGE_FOR_CUT       = 7
  BADGE_FOR_FLASH     = 7
  BADGE_FOR_ROCKSMASH = 7
  BADGE_FOR_SURF      = 7
  BADGE_FOR_FLY       = 7
  BADGE_FOR_STRENGTH  = 7
  BADGE_FOR_DIVE      = 7
  BADGE_FOR_WATERFALL = 7

  #=============================================================================

  # If a move taught by a TM/HM/TR replaces another move, this setting is
  # whether the machine's move retains the replaced move's PP (true), or whether
  # the machine's move has full PP (false).
  TAUGHT_MACHINES_KEEP_OLD_PP          = (MECHANICS_GENERATION == 5)
  # If a move is taught to a Pokemon using a TR and the Pokemon forgets that
  # move, it can relearn that move at a move tutor.
  RELEARNABLE_TR_MOVES                 = (MECHANICS_GENERATION >= 8)
  # Whether the Black/White Flutes will raise/lower the levels of wild Pokémon
  # respectively (true), or will lower/raise the wild encounter rate
  # respectively (false).
  FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS  = (MECHANICS_GENERATION >= 6)
  # Whether Repel uses the level of the first Pokémon in the party regardless of
  # its HP (true), or it uses the level of the first unfainted Pokémon (false).
  REPEL_COUNTS_FAINTED_POKEMON         = (MECHANICS_GENERATION >= 6)
  # Whether Rage Candy Bar acts as a Full Heal (true) or a Potion (false).
  RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS = (MECHANICS_GENERATION >= 7)
  # Whether Rare Candy can be used on a Pokémon that is already at its maximum
  # level if it is able to evolve by level-up (if so, triggers that evolution).
  RARE_CANDY_USABLE_AT_MAX_LEVEL       = (MECHANICS_GENERATION >= 8)
  # Whether various HP-healing items heal the amounts they do in Gen 7+ (true)
  # or in earlier Generations (false).
  # Examples:
  #  * Fresh Water heals 50 HP in Gen 5 and 30 HP in Gen 7
  #  * Lemonade heals 80 HP in Gen 5 and 70 HP in Gen 7
  #  * Hyper Potion and Energy Root heal 200 HP in Gen 5 and 120 HP in Gen 7
  #  * Super Potion and Energy Powder heal 50 HP in Gen 5 and 60 HP in Gen 7
  REBALANCED_HEALING_ITEM_AMOUNTS      = (MECHANICS_GENERATION >= 7)
  # Whether vitamins can add EVs no matter how many that stat already has in it
  # (true), or whether they can't make that stat's EVs greater than 100 (false).
  NO_VITAMIN_EV_CAP                    = (MECHANICS_GENERATION < 8)
  # Whether you get 1 Premier Ball for every 10 of any kind of Poké Ball bought
  # at once (true), or 1 Premier Ball for buying 10+ Poké Balls (false).
  MORE_BONUS_PREMIER_BALLS              = (MECHANICS_GENERATION >= 8)
  # Whether Pokemon evolve when their happiness value goes above the
  # threshold of 160 (true) or 220 (false)
  LOWER_HAPPINESS_EVOLUTION_CAP        = (MECHANICS_GENERATION >= 8)

  #=============================================================================

  # The name of the person who created the Pokémon storage system.
  def self.storage_creator_name
    return _INTL("Amanita")
  end
  # The number of boxes in Pokémon storage.
  NUM_STORAGE_BOXES   = 30
  # Whether putting a Pokémon into Pokémon storage will heal it. IF false, they
  # are healed by the Recover All: Entire Party event command (at Poké Centers).
  HEAL_STORED_POKEMON = (MECHANICS_GENERATION < 8)

  #=============================================================================

  # The names of each pocket of the Bag. Ignore the first entry ("").
  def self.bag_pocket_names
    return ["",
      _INTL("Items"),
      _INTL("Medicine"),
      _INTL("Poké Balls"),
      _INTL("TMs & HMs"),
      _INTL("Berries"),
      _INTL("Mail"),
      _INTL("Battle Items"),
      _INTL("Key Items")
    ]
  end
  # The maximum number of slots per pocket (-1 means infinite number). Ignore
  # the first number (0).
  BAG_MAX_POCKET_SIZE  = [0, -1, -1, -1, -1, -1, -1, -1, -1]
  # The maximum number of items each slot in the Bag can hold.
  BAG_MAX_PER_SLOT     = 999
  # Whether each pocket in turn auto-sorts itself by item ID number. Ignore the
  # first entry (the 0).
  BAG_POCKET_AUTO_SORT = [0, true, true, true, true, true, true, true, true]

  #=============================================================================

  # Whether the Pokédex list shown is the one for the player's current region
  # (true), or whether a menu pops up for the player to manually choose which
  # Dex list to view if more than one is available (false).
  USE_CURRENT_REGION_DEX = false
  # The names of the Pokédex lists, in the order they are defined in the PBS
  # file "regionaldexes.txt". The last name is for the National Dex and is added
  # onto the end of this array (remember that you don't need to use it). This
  # array's order is also the order of $Trainer.pokedex.unlocked_dexes, which
  # records which Dexes have been unlocked (the first is unlocked by default).
  # If an entry is just a name, then the region map shown in the Area page while
  # viewing that Dex list will be the region map of the region the player is
  # currently in. The National Dex entry should always behave like this.
  # If an entry is of the form [name, number], then the number is a region
  # number. That region's map will appear in the Area page while viewing that
  # Dex list, no matter which region the player is currently in.
  def self.pokedex_names
    return [
      [_INTL("South Unova"), 0],
	    [_INTL("???"), 1],
	    [_INTL("Ultra Space"), 2],
      _INTL("National Pokédex")
    ]
  end
  # Whether all forms of a given species will be immediately available to view
  # in the Pokédex so long as that species has been seen at all (true), or
  # whether each form needs to be seen specifically before that form appears in
  # the Pokédex (false).
  DEX_SHOWS_ALL_FORMS = false
  # Whether the Pokedex shows the Footprints of a Pokemon in the first page of
  # the dex entry (true) or whether it shows the Icon Sprite of the Pokemon
  # there (false).
  DEX_SHOWS_FOOTPRINTS = false
  # An array of numbers, where each number is that of a Dex list (in the same
  # order as above, except the National Dex is -1). All Dex lists included here
  # will begin their numbering at 0 rather than 1 (e.g. Victini in Unova's Dex).
  DEXES_WITH_OFFSETS  = []
  # Whether the amount of Pokemon of a particular species caught or defeated in
  # battle by the player boosts shiny odds.
  NUMBER_BATTLED_BOOSTS_SHINY_ODDS  = true

  #=============================================================================

  # A set of arrays, each containing details of a graphic to be shown on the
  # region map if appropriate. The values for each array are as follows:
  #   * Region number.
  #   * Game Switch; the graphic is shown if this is ON (non-wall maps only).
  #   * X coordinate of the graphic on the map, in squares.
  #   * Y coordinate of the graphic on the map, in squares.
  #   * Name of the graphic, found in the Graphics/Pictures folder.
  #   * The graphic will always (true) or never (false) be shown on a wall map.
  REGION_MAP_EXTRAS = [
  ]

  #=============================================================================

  # A list of maps used by roaming Pokémon. Each map has an array of other maps
  # it can lead to.
  ROAMING_AREAS = {
  }
  # A set of arrays, each containing the details of a roaming Pokémon. The
  # information within each array is as follows:
  #   * Species.
  #   * Level.
  #   * Game Switch; the Pokémon roams while this is ON.
  #   * Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
  #     4=surfing/fishing). See the bottom of PField_RoamingPokemon for lists.
  #   * Name of BGM to play for that encounter (optional).
  #   * Roaming areas specifically for this Pokémon (optional).
  ROAMING_SPECIES = [
  ]

  #=============================================================================

  # A set of arrays, each containing the details of a wild encounter that can
  # only occur via using the Poké Radar. The information within each array is as
  # follows:
  #   * Map ID on which this encounter can occur.
  #   * Probability that this encounter will occur (as a percentage).
  #   * Species.
  #   * Minimum possible level.
  #   * Maximum possible level (optional).
  POKE_RADAR_ENCOUNTERS = [
  ]

  #=============================================================================

  # The Game Switch that is set to ON when the player blacks out.
  STARTING_OVER_SWITCH      = 1
  # The Game Switch that is set to ON when the player has seen Pokérus in the
  # Poké Center (and doesn't need to be told about it again).
  SEEN_POKERUS_SWITCH       = 2
  # The Game Switch which, while ON, makes all wild Pokémon created be shiny.
  SHINY_WILD_POKEMON_SWITCH = 31
  # The Game Switch which, while ON, makes all Pokémon created considered to be
  # met via a fateful encounter.
  FATEFUL_ENCOUNTER_SWITCH  = 32
  # The Game Switch which, while ON, blocks access to the Pokemon Box Link
  # Storage functionality. Set this to -1 to always have Pokemon Box Link access.
  POKEMON_BOX_LINK_SWITCH   = -1
  # The Game Switch which, while ON, makes all wild Pokémon created be Brilliant.
  BRILLIANT_POKEMON_SWITCH  = -1

  #=============================================================================

  # ID of the animation played when the player steps on grass (grass rustling).
  GRASS_ANIMATION_ID           = 1
  # ID of the animation played when the player lands on the ground after hopping
  # over a ledge (shows a dust impact).
  DUST_ANIMATION_ID            = 2
  # ID of the animation played when a trainer notices the player (an exclamation
  # bubble).
  EXCLAMATION_ANIMATION_ID     = 3
  # ID of the animation played when a patch of grass rustles due to using the
  # Poké Radar.
  RUSTLE_NORMAL_ANIMATION_ID   = 1
  # ID of the animation played when a patch of grass rustles vigorously due to
  # using the Poké Radar. (Rarer species)
  RUSTLE_VIGOROUS_ANIMATION_ID = 5
  # ID of the animation played when a patch of grass rustles and shines due to
  # using the Poké Radar. (Shiny encounter)
  RUSTLE_SHINY_ANIMATION_ID    = 6
  # ID of the animation played when a berry tree grows a stage while the player
  # is on the map (for new plant growth mechanics only).
  PLANT_SPARKLE_ANIMATION_ID   = 7

  #=============================================================================

  # The scale to zoom the front sprite of a Pokemon. (1 for no scaling)
  FRONT_BATTLER_SPRITE_SCALE    = 2
  # The scale to zoom the back sprite of a Pokemon. (1 for no scaling)
  BACK_BATTLER_SPRITE_SCALE     = 3

  #=============================================================================

  # An array of available languages in the game, and their corresponding message
  # file in the Data folder. Edit only if you have 2 or more languages to choose
  # from.
  LANGUAGES = [
    # ["Português", "portuguese.dat"],
    # ["English", "english.dat"]
  ]

  #=============================================================================

  # Available speech frames. These are graphic files in "Graphics/Windowskins/".
  SPEECH_WINDOWSKINS = [
    "speech hgss 1",
    "speech hgss 2",
    "speech hgss 3",
    "speech hgss 4",
    "speech hgss 5",
    "speech hgss 6",
    "speech hgss 7",
    "speech hgss 8",
    "speech hgss 9",
    "speech hgss 10",
    "speech hgss 11",
    "speech hgss 12",
    "speech hgss 13",
    "speech hgss 14",
    "speech hgss 15",
    "speech hgss 16",
    "speech hgss 17",
    "speech hgss 18",
    "speech hgss 19",
    "speech hgss 20",
    "speech pl 18"
  ]

  # Available menu frames. These are graphic files in "Graphics/Windowskins/".
  MENU_WINDOWSKINS = [
    "choice 1",
    "choice 2",
    "choice 3",
    "choice 4",
    "choice 5",
    "choice 6",
    "choice 7",
    "choice 8",
    "choice 9",
    "choice 10",
    "choice 11",
    "choice 12",
    "choice 13",
    "choice 14",
    "choice 15",
    "choice 16",
    "choice 17",
    "choice 18",
    "choice 19",
    "choice 20",
    "choice 21",
    "choice 22",
    "choice 23",
    "choice 24",
    "choice 25",
    "choice 26",
    "choice 27",
    "choice 28"
  ]
end

# DO NOT EDIT THESE!
module Essentials
  VERSION = "19.1"
  ERROR_TEXT = ""
end
