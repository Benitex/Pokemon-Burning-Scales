class PokeBattle_Simulated_Battle < PokeBattle_Battle
  attr_accessor :endMessage, :playerEndspeeches # used for scripted battles

  #=============================================================================
  # Creating the battle class
  #=============================================================================
  def initialize(scene, p1, p2, player, opponent, fullNames = [false, false])
    super(scene, p1, p2, player, opponent)
    @useFullPlayerNames   = fullNames[0]
    @useFullOpponentNames = fullNames[1]
    @controlPlayer        = true
  end

  def setNameUsage(fullNames)
    @useFullPlayerNames   = fullNames[0]
    @useFullOpponentNames = fullNames[1]
  end

  def pbGetNameOf(trainer, opposing)
    return @useFullOpponentNames ? trainer.fullname : trainer.name if opposing # Opponent

    @useFullPlayerNames ? trainer.fullname : trainer.name
  end

  def pbSetSeen(battler)
    return if !battler || !@internalBattle

    $Trainer.pokedex.register(battler.displaySpecies, battler.displayGender, battler.displayForm)
  end

  def pbRecordAndStoreCaughtPokemon
    nil
  end

  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision == 1 && wildBattle? && @caughtPokemon.length > 0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log('')
      PBDebug.log('***Player won***')
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL('You defeated {1}!', @opponent[0].full_name))
        when 2
          pbDisplayPaused(_INTL('You defeated {1} and {2}!', @opponent[0].full_name,
                                @opponent[1].full_name))
        when 3
          pbDisplayPaused(_INTL('You defeated {1}, {2} and {3}!', @opponent[0].full_name,
                                @opponent[1].full_name, @opponent[2].full_name))
        end
        @opponent.each_with_index do |_t, i|
          @scene.pbShowOpponent(i)
          msg = @endSpeeches[i] && @endSpeeches[i] != '' ? @endSpeeches[i] : '...'
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name))
        end
      end
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length > 0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log('')
      PBDebug.log('***Player lost***') if @decision == 2
      PBDebug.log('***Player drew with opponent***') if @decision == 5
      if @internalBattle
        pbDisplayPaused(_INTL('You have no more Pokémon that can fight!'))
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL('You lost against {1}!', @opponent[0].full_name))
          when 2
            pbDisplayPaused(_INTL('You lost against {1} and {2}!',
                                  @opponent[0].full_name, @opponent[1].full_name))
          when 3
            pbDisplayPaused(_INTL('You lost against {1}, {2} and {3}!',
                                  @opponent[0].full_name, @opponent[1].full_name, @opponent[2].full_name))
          end
        end
        # Lose money from losing a battle

        pbDisplayPaused(_INTL('You blacked out!')) unless @canLose
      elsif @decision == 2
        if @opponent
          @opponent.each_with_index do |_t, i|
            @scene.pbShowOpponent(i)
            msg = @endSpeechesWin[i] && @endSpeechesWin[i] != '' ? @endSpeechesWin[i] : '...'
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/, pbPlayer.name))
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess unless Settings::GAIN_EXP_FOR_CAPTURE
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $Trainer.party.each_with_index do |pkmn, i|
        infected.push(i) if pkmn.pokerusStage == 1
      end
      infected.each do |idxParty|
        strain = $Trainer.party[idxParty].pokerusStrain
        if idxParty > 0 && $Trainer.party[idxParty - 1].pokerusStage == 0 && (rand(3) == 0)
          $Trainer.party[idxParty - 1].givePokerus(strain) # 33%
        end
        if idxParty < $Trainer.party.length - 1 && $Trainer.party[idxParty + 1].pokerusStage == 0 && (rand(3) == 0)
          $Trainer.party[idxParty + 1].givePokerus(strain) # 33%
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next unless b

      pbCancelChoice(b.index) # Restore unused items to Bag
      BattleHandlers.triggerAbilityOnSwitchOut(b.ability, b, true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn, i|
      next unless pkmn

      @peer.pbOnLeavingBattle(self, pkmn, @usedInBattle[0][i], true)   # Reset form
      pkmn.item = @initialItems[0][i]
    end
    @decision
  end
end
