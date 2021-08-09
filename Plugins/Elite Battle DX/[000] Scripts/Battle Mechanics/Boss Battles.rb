#===============================================================================
#  Extra additions for generating battlers as well as initializing boss battles
#===============================================================================
module EliteBattle
  #-----------------------------------------------------------------------------
  # generates Pokemon based on hashtable
  #-----------------------------------------------------------------------------
  def self.generateWild(data)
    species = randomizeSpecies(data.get_key(:species), !$nonStaticEncounter)
    level = data.get_key(:level)
    basestats = data.has_key?(:basestats) ? data.get_key(:basestats) : nil
    boss = data.has_key?(:bossboost) ? data.get_key(:bossboost) : false
    # raises error if critical data is not present
    EliteBattle.log.error("No species defined for Pokemon!") if !species
    EliteBattle.log.error("No level defined for Pokemon!") if !level
    # converts species to proper numeric value
    EliteBattle.log.error("Invalid species constant!") if species.nil?
    species = randomizeSpecies(species, true)
    # generates Pokemon for battle
    genwildpoke = pbGenerateWildPokemon(species, level)
    # applies modifiers to generated Pokemon
    genwildpoke.shiny = true if data.get_key(:shiny) || data.get_key(:superShiny)
    genwildpoke.forceSuper = true if data.get_key(:superShiny)
    genwildpoke.ev = data.get_key(:ev) if data.has_key?(:ev) && data[:ev].is_a?(Array)
    genwildpoke.iv = data.get_key(:iv) if data.has_key?(:iv) && data[:iv].is_a?(Array)
    genwildpoke.ability = data.get_key(:ability) if data.has_key?(:ability)
    genwildpoke.calc_stats(basestats, boss)
    genwildpoke.gender = data.get_key(:gender) if data.has_key?(:gender)
    genwildpoke.nature = data.get_key(:nature) if data.has_key?(:nature)
    genwildpoke.givePokerus if data.try_key?(:pokerus)
    genwildpoke.item = data.get_key(:item) if data.has_key?(:item)
    genwildpoke.forced_form = data.get_key(:form) if data.has_key?(:form)
    genwildpoke.reset_moves
    # adds moves
    if data.has_key?(:moves) && data[:moves].is_a?(Array)
      genwildpoke.moves.clear
      for move in data.get_key(:moves)
        genwildpoke.learn_move(move)
      end
    end
    # adds ribbons
    if data.has_key?(:ribbons) && data[:ribbons].is_a?(Array)
      for ribbon in data.get_key(:ribbons)
        genwildpoke.giveRibbon(ribbon)
      end
    end
    return genwildpoke
  end
  #-----------------------------------------------------------------------------
  # customizable wild battles
  #-----------------------------------------------------------------------------
  def self.wildBattle(data, partysize = 1, canEscape = true, canLose = false, playersize = 1)
    # set initial variables
    outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
    outcomeVar = data[:variable] if data.is_a?(Hash) && data.has_key?(:variable)
    canLose    = $PokemonTemp.battleRules["canLose"] || canLose
    # generate wild battler
    genwildpoke = data.is_a?(Pokemon) ? data : self.generateWild(data)
    handled = [nil]
    # wild battle override
    Events.onWildBattleOverride.trigger(genwildpoke, genwildpoke.species, genwildpoke.level, handled)
    return handled[0] if handled[0] != nil
    # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
    if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
      pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemonCount>0
      pbSet(outcomeVar, 1)   # Treat it as a win
      $PokemonTemp.clearBattleRules
      $PokemonGlobal.nextBattleBGM       = nil
      $PokemonGlobal.nextBattleME        = nil
      $PokemonGlobal.nextBattleCaptureME = nil
      $PokemonGlobal.nextBattleBack      = nil
      return true   # Treat it as a win
    end
    # Record information about party Pokémon to be used at the end of battle (e.g.
    # comparing levels for an evolution check)
    Events.onStartBattle.trigger(nil)
    # Generate wild Pokémon based on the species and level
    foeParty = [genwildpoke]
    # Calculate who the trainers and their party are
    playerTrainers    = [$Trainer]
    playerParty       = $Trainer.party
    playerPartyStarts = [0]
    room_for_partner = (foeParty.length > 1)
    if !room_for_partner && $PokemonTemp.battleRules["size"] && !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
      room_for_partner = true
    end
    if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
      ally = NPCTrainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
      ally.id    = $PokemonGlobal.partner[2]
      ally.party = $PokemonGlobal.partner[3]
      playerTrainers.push(ally)
      playerParty = []
      $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
      playerPartyStarts.push(playerParty.length)
      ally.party.each { |pkmn| playerParty.push(pkmn) }
      setBattleRule("double") if !$PokemonTemp.battleRules["size"]
    end
    # caches species number
    EliteBattle.set(:wildSpecies, genwildpoke.species)
    # caches species level
    EliteBattle.set(:wildLevel, genwildpoke.level)
    # caches species form
    EliteBattle.set(:wildForm, genwildpoke.form)
    # set boss parameter to true
    EliteBattle.set(:setBoss, true) if data.is_a?(Hash) && data[:setBoss]
    # try to load the next battle speech
    speech = EliteBattle.get_data(genwildpoke.species, :Species, :BATTLESCRIPT, (genwildpoke.form rescue 0))
    EliteBattle.set(:nextBattleScript, (speech.is_a?(Hash) ? speech : speech.to_sym)) if !speech.nil?
    # set battle rules
    if $PokemonTemp.battleRules
      setBattleRule(sprintf("%dv%d", partysize, playersize)) if !$PokemonTemp.battleRules["size"]
      setBattleRule(canLose ? "canLose" : "cannotLose") if !$PokemonTemp.battleRules.has_key?("canLose", "cannotLose")
      setBattleRule(canEscape ? "canRun" : "cannotRun") if !$PokemonTemp.battleRules.has_key?("canRun", "cannotRun")
    end
    # Create the battle scene (the visual side of it)
    scene = pbNewBattleScene
    # Create the battle class (the mechanics side of it)
    battle = PokeBattle_Battle.new(scene, playerParty, foeParty, playerTrainers, nil)
    battle.party1starts = playerPartyStarts
    # Set various other properties in the battle class
    pbPrepareBattle(battle)
    $PokemonTemp.clearBattleRules
    # Perform the battle itself
    decision = 0
    pbBattleAnimation(pbGetWildBattleBGM(foeParty), (foeParty.length == 1) ? 0 : 2, foeParty) {
      pbSceneStandby {
        decision = battle.pbStartBattle
      }
      pbAfterBattle(decision, canLose)
    }
    Input.update
    pbSet(outcomeVar, decision)
    # Used by the Poké Radar to update/break the chain
    Events.onWildBattleEnd.trigger(nil, genwildpoke.species, genwildpoke.level, decision)
    # return full decision outcome
    return (decision != 2 && decision != 5)
  end
  #-----------------------------------------------------------------------------
  # 2v1 boss battle
  #-----------------------------------------------------------------------------
  def self.bossBattle(species, level, partysize = 2, cancatch = false, options = {})
    data = {
      :species => randomizeSpecies(species, true),
      :level => level,
      :iv => {:HP => 31, :ATTACK => 31, :DEFENSE => 31, :SPECIAL_ATTACK => 31, :SPECIAL_DEFENSE => 31, :SPEED => 31},
      :bossboost => {:HP => 1.75, :ATTACK => 1.25, :DEFENSE => 1.25, :SPECIAL_ATTACK => 1.25, :SPECIAL_DEFENSE => 1.25, :SPEED => 1.25},
      :setBoss => true
    }
    # adds additional option data
    for key in options.keys
      data[key] = options[key].clone
    end
    # prevent catching
    self.set(:nextBattleData, { :CATCH_RATE => -1 }) if !cancatch
    # sets next UI
    d = EliteBattle.get_data(:BOSSDATABOX, :Metrics, :METRICS)
    EliteBattle.set(:nextUI, d ? d : {
      :ENEMYDATABOX => {
        :BITMAP => "dataBoxBoss",
        :CONTAINER => "containersBoss"
      }
    })
    # safety parameter
    partysize = 3 if partysize > 3; partysize = 1 if partysize < 1
    # run battle
    return self.wildBattle(data, partysize, false, false)
  end
  #-----------------------------------------------------------------------------
end
