module Settings
  # Whether a move's physical/special category depends on the move itself as in
  # newer Gens (true), or on its type as in older Gens (false).
  MOVE_CATEGORY_PER_MOVE                      = (MECHANICS_GENERATION >= 4)
  # Whether turn order is recalculated after a Pokémon Mega Evolves.
  RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION = (MECHANICS_GENERATION >= 7)
  # Whether turn order is recalculated after a Pokémon's Speed stat changes.
  RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES  = (MECHANICS_GENERATION >= 8)
  # Whether critical hits do 1.5x damage and have 4 stages (true), or they do 2x
  # damage and have 5 stages as in Gen 5 (false). Also determines whether
  # critical hit rate can be copied by Transform/Psych Up.
  NEW_CRITICAL_HIT_RATE_MECHANICS             = (MECHANICS_GENERATION >= 6)
  # Whether several effects apply relating to a Pokémon's type:
  #   * Electric-type immunity to paralysis
  #   * Ghost-type immunity to being trapped
  #   * Grass-type immunity to powder moves and Effect Spore
  #   * Poison-type Pokémon can't miss when using Toxic
  #   * Dark-type Pokemon immunity to Prankster moves
  MORE_TYPE_EFFECTS                           = (MECHANICS_GENERATION >= 6)
  # Whether weather caused by an ability lasts 5 rounds (true) or forever (false).
  FIXED_DURATION_WEATHER_FROM_ABILITY         = (MECHANICS_GENERATION >= 6)
  # Whether the fog weather behave like its Gen 8 counterpart (true)
  # or Gen 4 counterpart (false)
  SWSH_FOG_IN_BATTLES                         = (MECHANICS_GENERATION >= 8)
  # Whether any Pokémon (originally owned by the player or foreign) can disobey
  # the player's commands if the Pokémon is too high a level compared to the
  # number of Gym Badges the player has.
  ANY_HIGH_LEVEL_POKEMON_CAN_DISOBEY          = false
  # Whether foreign Pokémon can disobey the player's commands if the Pokémon is
  # too high a level compared to the number of Gym Badges the player has.
  FOREIGN_HIGH_LEVEL_POKEMON_CAN_DISOBEY      = false

  #=============================================================================

  # Whether Pokémon with high affection will gain more Exp from battles, have a
  # chance of avoiding/curing negative effects by themselves, resisting
  # fainting, etc.
  # (Only works when used with bo4p5687's Pokemon Amie script for v19)
  AFFECTION_EFFECTS        = (MECHANICS_GENERATION >= 6)

  #=============================================================================

  # Whether X items (X Attack, etc.) raise their stat by 2 stages (true) or 1
  # (false).
  X_STAT_ITEMS_RAISE_BY_TWO_STAGES = (MECHANICS_GENERATION >= 7)
  # Whether some Poké Balls have catch rate multipliers from Gen 7 (true) or
  # from earlier generations (false).
  NEW_POKE_BALL_CATCH_RATES        = (MECHANICS_GENERATION >= 7)
  # Whether Soul Dew powers up Psychic and Dragon-type moves by 20% (true) or
  # raises the holder's Special Attack and Special Defense by 50% (false).
  SOUL_DEW_POWERS_UP_TYPES         = (MECHANICS_GENERATION >= 7)
  # Whether a Pokémon holding a Power item gains 8 (true) or 4 (false) EVs in
  # the relevant stat.
  MORE_EVS_FROM_POWER_ITEMS        = (MECHANICS_GENERATION >= 7)
  # Whether the damage boost from the Terrains is 1.5x (false) like in Gen 6
  # and 7, or 1.3x (true) like in Gen 8.
  NERFED_TERRAIN_DAMAGE            = (MECHANICS_GENERATION >= 8)

  #=============================================================================

  # The minimum number of badges required to boost each stat of a player's
  # Pokémon by 1.1x, in battle only.
  NUM_BADGES_BOOST_ATTACK  = (MECHANICS_GENERATION >= 4) ? 999 : 1
  NUM_BADGES_BOOST_DEFENSE = (MECHANICS_GENERATION >= 4) ? 999 : 5
  NUM_BADGES_BOOST_SPATK   = (MECHANICS_GENERATION >= 4) ? 999 : 7
  NUM_BADGES_BOOST_SPDEF   = (MECHANICS_GENERATION >= 4) ? 999 : 7
  NUM_BADGES_BOOST_SPEED   = (MECHANICS_GENERATION >= 4) ? 999 : 3

  #=============================================================================

  # An array of items which act as Mega Rings for the player (NPCs don't need a
  # Mega Ring item, just a Mega Stone held by their Pokémon).
  MEGA_RINGS        = [:MEGARING, :MEGABRACELET, :MEGACUFF, :MEGACHARM]
  # The Game Switch which, while ON, prevents all Pokémon in battle from Mega
  # Evolving even if they otherwise could.
  NO_MEGA_EVOLUTION = 34

  #=============================================================================

  # Whether the Exp gained from beating a Pokémon should be scaled depending on
  # the gainer's level.
  SCALED_EXP_FORMULA        = (MECHANICS_GENERATION == 5 || MECHANICS_GENERATION >= 7)
  # Whether the Exp gained from beating a Pokémon should be divided equally
  # between each participant (true), or whether each participant should gain
  # that much Exp (false). This also applies to Exp gained via the Exp Share
  # (held item version) being distributed to all Exp Share holders.
  SPLIT_EXP_BETWEEN_GAINERS = (MECHANICS_GENERATION <= 5)
  # Whether the critical capture mechanic applies. Note that its calculation is
  # based on a total of 600+ species (i.e. that many species need to be caught
  # to provide the greatest critical capture chance of 2.5x), and there may be
  # fewer species in your game.
  ENABLE_CRITICAL_CAPTURES  = (MECHANICS_GENERATION >= 5)
  # Whether Pokémon gain Exp for capturing a Pokémon.
  GAIN_EXP_FOR_CAPTURE      = (MECHANICS_GENERATION >= 6)
  # The Game Switch which, whie ON, prevents the player from losing money if
  # they lose a battle (they can still gain money from trainers for winning).
  NO_MONEY_LOSS             = 33
  # Whether party Pokémon check whether they can evolve after all battles
  # regardless of the outcome (true), or only after battles the player won (false).
  CHECK_EVOLUTION_AFTER_ALL_BATTLES   = (MECHANICS_GENERATION >= 6)
  # Whether fainted Pokémon can try to evolve after a battle.
  CHECK_EVOLUTION_FOR_FAINTED_POKEMON = true
end
