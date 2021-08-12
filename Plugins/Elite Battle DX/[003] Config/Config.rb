#===============================================================================
#  Elite Battle: DX
#    by Luka S.J.
# ----------------
#  System Settings
#===============================================================================
module EliteBattle

  # Waiting period (in seconds) before battle "camera" starts moving
  BATTLE_MOTION_TIMER = 90

  # used to scale the trainer bitmaps (front sprites) to 200%
  TRAINER_SPRITE_SCALE = 1

  # used to scale the Pokemon bitmaps (front sprites and UI) to 200%
  FRONT_SPRITE_SCALE = 2

  # used to scale the Pokemon bitmaps (back sprites) to 200%
  BACK_SPRITE_SCALE = 2

  # configures the scale of the room to account for the vector motion
  ROOM_SCALE = 2.25

  # set this to true to use the low HP bgm when player's Pokemon HP reaches 25%
  USE_LOW_HP_BGM = false

  # set this to true if you want to use your own common animations from the editor
  CUSTOM_COMMON_ANIM = false

  # set this to true to use animations from the Animation editor for missing move animations
  CUSTOM_MOVE_ANIM = false

  # disables "camera" zooming and movement throughout the entire scene
  DISABLE_SCENE_MOTION = false

  # Chance (%) (from 0 to 100, allows up to 2 decimal places) that Shiny Pokemon
  # will have a unique hue applied to them, altering their color further
  # this percentage is calculated AFTER the shiny generation chance
  SUPER_SHINY_RATE = 1

  # the minimum amount of (random) IV attributes to be set to 31 for shiny Pokemon
  PERFECT_IV_SHINY = 1

  # the minimum amount of (random) IV attributes to be set to 31 for super shiny Pokemon
  PERFECT_IV_SUPER = 3

  # Show player line up during wild battles
  SHOW_LINEUP_WILD = false

  # Adjust the player sendout animations based on whether or not the
  # Following Pokemon EX system is present
  USE_FOLLOWER_EXCEPTION = true

  # add EBDX debug menu
  SHOW_DEBUG_FEATURES = false

end
#-------------------------------------------------------------------------------
# Adds additional "camera" vectors for when the camera is idling
# vector parameters are: x, y, angle, scale, scene zoom
EliteBattle.add_vector(:CAMERA_MOTION,
  [132, 408, 24, 302, 1],
  [122, 294, 20, 322, 1],
  [238, 304, 26, 322, 1],
  [0, 384, 26, 322, 1],
  [198, 298, 18, 282, 1],
  [196, 306, 26, 242, 0.6],
  [156, 280, 18, 226, 0.6],
  [60, 280, 12, 388, 1],
  [160, 286, 16, 340, 1]
)
#-------------------------------------------------------------------------------
#  additional battle system configuration
#-------------------------------------------------------------------------------
# method of bulk assigning Transitions for Pokemon and Trainers
EliteBattle.assign_transition("rainbowIntro", :ALLOW_ALL)
