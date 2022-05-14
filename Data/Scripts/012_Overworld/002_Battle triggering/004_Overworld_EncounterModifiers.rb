################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
  end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate += proc { |_sender, e|
  if $game_switches[100]
    pokemon = e[0]
    new_level = pbBalancedLevel($Trainer.party)
    if $game_variables[100] == 1      # Easy
      new_level += rand(2) - 2
    elsif $game_variables[100] == 2   # Normal
      new_level += rand(4) - 2
    else                              # Hard
      new_level += rand(3) + 1
    end
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pokemon.level = new_level
    pokemon.calc_stats
    pokemon.reset_moves
  end
}

# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
Events.onTrainerPartyLoad += proc { |_sender, trainer|
  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
    if $game_switches[99]
      for pokemon in trainer[0].party
        new_level = pbBalancedLevel($Trainer.party)
        # Difficulty modifiers
        if $game_variables[100] == 1      # Easy
          new_level += rand(2) - 2
        elsif $game_variables[100] == 2   # Normal
          new_level += rand(2)
        else                              # Hard
          new_level += rand(3) + 3
        end
        new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
        pokemon.level = new_level
        pokemon.calc_stats
        pokemon.reset_moves
      end
    end
  end
}
