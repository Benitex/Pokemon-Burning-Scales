#===============================================================================
#  New animated and modular Title Screen for Pokemon Essentials
#    by Luka S.J.
#
#  ONLY FOR Essentials v19.x
# ----------------
#  Configuration constants for the script. All the various constants have been
#  commented to label what each of them does. Please make sure to read what
#  they do, and how to use them. Most of this script is just green text.
#
#  A lot of time and effort went into making this an extensive and comprehensive
#  resource. So please be kind enough to give credit when using it.
#
#  Please consult the official documentation page to learn how to set up
#  your animated title screens: https://luka-sj.com/res/modts/docs
#===============================================================================
module ModularTitle
  # Configuration constant used to style the Title Screen
  # Add multiple modifiers to add visual effects to the Title Screen
  # Non additive modifiers do not stack i.e. you can only use one of each type
  MODIFIERS = [
  #-------------------------------------------------------------------------------
  #                                  PRESETS
  #-------------------------------------------------------------------------------
    # Electric Nightmare
    #"background1", "logo:bounce", "effect9", "logo:shine", "intro:4"

    # Trainer Adventure
    #"background6", "misc1", "overlay5", "effect8", "logo:glow", "bgm:title_hgss", "intro:2"

    # Enter the Ultra Wormhole
    #"background2", "effect1", "effect5", "overlay:static003", "logo:glow", "intro:7"

    # Ugly Rainbow
    #"background5", "logo:sparkle", "overlay:static004", "effect1", "intro:5"

    # Ocean Breeze
    #"background11", "intro:1", "logoY:172", "logo:sparkle", "logo:shine", "overlay:blue_z25", "misc5:blastoise_x294_y118", "effect5_y106", "effect4_y106", "bgm:title_frlg"

    # Evolution
    #"background8", "effect7_y272", "effect6_y272", "effect4_y272", "effect5_y272", "logoY:172", "misc4_y312", "overlay5", "bgm:title_rse", "intro:3"

    # Burning Red (gen 1)
    #"background:frlg", "intro:1", "effect10_y308", "overlay:frlg", "logoX:204", "logoY:164", "logo:sparkle", "misc5:charizard_x284_y142", "bgm:title_frlg"

    # Heart of Gold (gen 2)
    #"background:dawn", "intro:2", "logoY:172", "logo:glow", "misc2", "effect11_x368_y112", "effect6_x368_y112", "effect4_x368_y112", "overlay3", "bgm:title_hgss"

    # Sapphire Abyss (gen 3)
    #"background:rse", "intro:3", "misc3_x260_y236", "overlay4", "logoY:172", "logo:sparkle", "logo:shine", "effect3_y236", "bgm:title_rse"

    # Platinum Shade (gen 4)
    #"background10", "intro:4", "overlay7", "bgm:title_dppt", "logoY:172"

    # Dark Display (gen 5)
    #"background:bw", "overlay2", "logoY:172", "logo:shine", "misc4_s2_x284_y339", "effect6_y312", "bgm:title_bw"

    # Forest Sky (gen 6)
    #"background4", "intro:6", "effect4", "effect5", "effect7", "overlay:static002", "bgm:title_xy"

    # Cosmic Vibes (gen 7)
    #"background3", "intro:7", "effect5", "effect6", "overlay6", "logo:shine", "bgm:title_sm"
  #-------------------------------------------------------------------------------
  #                  V V     add your modifiers in here     V V
  #-------------------------------------------------------------------------------
  "background2", "effect1", "effect5", "overlay:static003", "logo:glow", "intro:7"

  ] # end of config constant
  #-------------------------------------------------------------------------------
  # Other config
  #-------------------------------------------------------------------------------
  # Config used for determining the cry of species to play, along with displaying
  # a certain Pokemon sprite if applicable. Leave it as nil in order not to play
  # a species cry, otherwise set as a symbolic value
  SPECIES = :VOLCARONA
  # Applies a form to Pokemon species
  SPECIES_FORM = 0
  # Applies female form
  SPECIES_FEMALE = false
  # Applies shiny variant
  SPECIES_SHINY = false
  # Applies backsprite
  SPECIES_BACK = false

  # Config to reposition the "Press Enter" text across the screen
  # keep values at nil to keep at default position
  # format is [x,y]
  START_POS = [nil, nil]

  # set to true to show Title Screen even when running the game in Debug mode
  SHOW_IN_DEBUG = false

end
