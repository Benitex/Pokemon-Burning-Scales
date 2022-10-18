#===============================================================================
# Start a trainer battle
#===============================================================================
def pbSimulatedTrainerBattleCore(players,opponents,fullNames=[false,false])
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player is holding Ctrl in Debug mode
  if ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
    pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.able_pokemon_count>0
    pbSet(outcomeVar,($Trainer.able_pokemon_count==0) ? 0 : 1)   # Treat it as undecided/a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    return ($Trainer.able_pokemon_count==0) ? 0 : 1   # Treat it as undecided/a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate trainers and their parties based on the arguments given
  foeTrainers    = []
  foeItems       = []
  foeEndSpeeches = []
  foeParty       = []
  foePartyStarts = []
  for opponent in opponents 
    if opponent.is_a?(NPCTrainer) || opponent.is_a?(Player)
      foeTrainers.push(opponent)
      foePartyStarts.push(foeParty.length)
      opponent.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(opponent.lose_text) if !opponent.is_a?(Player)
      foeItems.push(opponent.items) if !opponent.is_a?(Player)
    elsif opponent.is_a?(Array)   # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(opponent[0],opponent[1],opponent[2])
      pbMissingTrainer(opponent[0],opponent[1],opponent[2]) if !trainer
      return 0 if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      foeTrainers.push(trainer)
      foePartyStarts.push(foeParty.length)
      trainer.party.each { |pkmn| foeParty.push(pkmn) }
      foeEndSpeeches.push(opponent[3] || trainer.lose_text)
      foeItems.push(trainer.items)
    else
      raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", opponent)
    end
  end
  # Calculate who the player trainer(s) and their party are
  playerTrainers    = []
  playerParty       = []
  playerPartyStarts = []
  playerItems       = []
  playerEndSpeeches = []
  
  for player in players
    if player.is_a?(NPCTrainer) || player.is_a?(Player)
      playerTrainers.push(player)
      playerPartyStarts.push(playerParty.length)
      player.party.each { |pkmn| playerParty.push(pkmn) }
      playerEndSpeeches.push(player.lose_text) if !player.is_a?(Player)
      playerItems.push(player.items) if !player.is_a?(Player)
    elsif player.is_a?(Array)   # [trainer type, trainer name, ID, speech (optional)]
      trainer = pbLoadTrainer(player[0],player[1],player[2])
      pbMissingTrainer(player[0],player[1],player[2]) if !trainer
      return 0 if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      playerTrainers.push(trainer)
      playerPartyStarts.push(playerParty.length)
      trainer.party.each { |pkmn| playerParty.push(pkmn) }
      playerEndSpeeches.push(player[3] || trainer.lose_text)
      playerItems.push(trainer.items)
    else
      raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", player)
    end
  end

  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Simulated_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers,fullNames)
  battle.party1starts = playerPartyStarts
  battle.party2starts = foePartyStarts
  battle.items        = foeItems
  battle.endSpeeches  = foeEndSpeeches
  battle.playerEndspeeches  = playerEndSpeeches
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # End the trainer intro music
  Audio.me_stop
  # Perform the battle itself
  decision = 0
  pbScriptedBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers, playerTrainers) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterSimulatedBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end

#===============================================================================
# Standard methods that start a simulated trainer battle of various sizes
#===============================================================================

def pbSimulatedTrainerBattle(player,opponent,size0=1,size1=1,canLose=true,outcomeVar=1,fullNames=[false,false]) 
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("canLose") if canLose
  setBattleRule(sprintf("%dv%d",size0,size1))
  setBattleRule("setstyle")
  # Perform the battle
  if player.is_a?(Array)
    players = []
    for pl in player
        players.push(pl)
    end
  else
    players = [player]
  end
  
  if opponent.is_a?(Array)
    opponents = []
    for op in opponent
        opponents.push(op)
    end
  else
    opponents = [opponent]
  end
  
  decision = pbSimulatedTrainerBattleCore(players,opponents,fullNames)
  $PokemonTemp.waitingTrainer = nil
  # Return true if the player won the battle, and false if any other result
  return (decision==1)
end


#===============================================================================
# After battles
#===============================================================================
def pbAfterSimulatedBattle(decision,canLose)
  if decision==2 || decision==5   # if loss or draw
    if canLose
      $Trainer.party.each { |pkmn| pkmn.heal }
      (Graphics.frame_rate/4).times { Graphics.update }
    end
  end
  Events.onEndBattle.trigger(nil,decision,canLose)
  $game_player.straighten
end

Events.onEndBattle += proc { |sender,e|
  decision = e[0]
  canLose  = e[1]
  case decision
  when 1, 4   # Win, capture
  when 2, 5   # Lose, draw
    if !canLose
      $game_system.bgm_unpause
      $game_system.bgs_unpause
      pbStartOver
    end
  end
}