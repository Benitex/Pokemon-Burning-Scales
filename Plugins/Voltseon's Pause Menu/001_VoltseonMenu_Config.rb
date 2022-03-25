#-------------------------------------------------------------------------------
# Voltseon's Pause Menu
# Pause with style 😎
#-------------------------------------------------------------------------------
#
# Original Script by Yankas
# Updated compatablilty by Cony
# Edited and modified by Voltseon, Golisopod User and ENLS
#
# Made for people who dont want
# to have ugly pause menus
# so here's a really cool one!
# Version: 1.7
#
#
#-------------------------------------------------------------------------------
# Menu Options
#-------------------------------------------------------------------------------
# Main file path for the menu
MENU_FILE_PATH = "Graphics/Pictures/Voltseon's Pause Menu/"

# An array of aLL the Menu Entry Classes from 005_VoltseonMenu_Entries that
# need to be loaded
MENU_ENTRIES = [
  "MenuEntryPokemon", "MenuEntryPokedex", "MenuEntryBag", "MenuEntryTrainer", 
  "MenuEntryEncounterList", "MenuEntryQuests", "MenuEntryMap", "MenuEntryPokegear",
  "MenuEntryExitBugContest","MenuEntryExitSafari", "MenuEntrySave", "MenuEntryDebug", 
  "MenuEntryOptions", "MenuEntryQuit"
]

# An array of aLL the Menu Component Classes from 004_VoltseonMenu_Components
# that need to be loaded
MENU_COMPONENTS = [
  "SafariHud", "BugContestHud", "PokemonPartyHud", "DateAndTimeHud", "NewQuestHud"
]

# The default theme for the menu screen
DEFAULT_MENU_THEME = 1

# Change Theme in the Options Menu
CHANGE_THEME_IN_OPTIONS = true

#-------------------------------------------------------------------------------
# Look and Feel
#-------------------------------------------------------------------------------
# Background options
BACKGROUND_TINT = Color.new(-30,-30,-30,130) # Tone (Red, Green, Blue, Grey) applied to the background/map.

SHOW_MENU_NAMES = true # Whether or not the Menu option Names show on screen (true = show names)

# Icon options
ACTIVE_SCALE = 1.5

MENU_TEXTCOLOR = [
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248)
          ]
MENU_TEXTOUTLINE = [
            Color.new(64,64,64),
            Color.new(64,64,64),
            Color.new(68,96,0),
            Color.new(66,18,0),
            Color.new(0,82,107),
            Color.new(126,98,11),
            Color.new(38,22,91),
            Color.new(12,37,24),
            Color.new(0,58,76)
          ]
LOCATION_TEXTCOLOR = [
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248),
            Color.new(248,248,248)
          ]
LOCATION_TEXTOUTLINE = [
            Color.new(64,64,64),
            Color.new(64,64,64),
            Color.new(68,96,0),
            Color.new(66,18,0),
            Color.new(0,82,107),
            Color.new(137,0,100),
            Color.new(38,22,91),
            Color.new(12,37,24),
            Color.new(0,58,76)
          ]

# Sound Options
MENU_OPEN_SOUND   = "GUI menu open"
MENU_CLOSE_SOUND  = "GUI menu close"
MENU_CURSOR_SOUND = "GUI sel cursor"
