#===============================================================================
#  Main battle animation processing
#===============================================================================
def pbBattleAnimation(bgm = nil, battletype = 0, foe = nil)
  # gets trainer ID
  trainerid = (foe && foe[0].is_a?(Trainer) ? foe[0].trainer_type : nil) rescue nil
  # sets up starting variables
  handled = false
  playingBGS = nil
  playingBGM = nil
  # memorizes currently playing BGM and BGS
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  # stops currently playing ME
  pbMEFade(0.25)
  pbWait(8)
  pbMEStop
  # checks if battle BGM is registered for species or trainer
  mapBGM = EliteBattle.get_map_data(:BGM)
  bgm = mapBGM if !mapBGM.nil?
  pkmnBGM = EliteBattle.next_bgm?(EliteBattle.get(:wildSpecies), EliteBattle.get(:wildForm), 0, :Species)
  bgm = pkmnBGM if !pkmnBGM.nil? && !trainerid
  trBGM = trainerid ? EliteBattle.next_bgm?(trainerid, foe[0].name, foe[0].partyID, :Trainer) : nil
  bgm = trBGM if !trBGM.nil?
  # plays battle BGM
  if bgm
    pbBGMPlay(bgm)
  else
    pbBGMPlay(pbGetWildBattleBGM(0))
  end
  # initialize viewport
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  # flashes viewport to gray a few times.
  viewport.color = Color.white
  2.times do
    viewport.color.alpha = 0
    for i in 0...16.delta_add
      viewport.color.alpha += (32 * (i < 8.delta_add ? 1 : -1)).delta_sub(false)
      pbWait(1)
    end
  end
  viewport.color.alpha = 0
  # checks if the Sun & Moon styled VS sequence is to be played
  EliteBattle.sun_moon_transition?(trainerid, false, (foe[0].name rescue 0), (foe[0].partyID rescue 0)) if trainerid && foe && foe.length < 2
  EliteBattle.sun_moon_transition?(EliteBattle.get(:wildSpecies), true, EliteBattle.get(:wildForm)) if !trainerid
  $timenow = Time.now
  # plays custom transition if applicable
  handled = EliteBattle.play_next_transition(viewport, trainerid)
  # plays basic trainer intro animation
  if !handled && trainerid
    handled = EliteBattle_BasicTrainerAnimations.new(viewport, battletype, foe)
  end
  if !handled
    handled = EliteBattle_BasicWildAnimations.new(viewport)
  end
  # battle processing
  yield if block_given?
  # resumes memorized BGM and BGS
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  # resets cache variables
  $PokemonGlobal.nextBattleBGM       = nil
  $PokemonGlobal.nextBattleME        = nil
  $PokemonGlobal.nextBattleCaptureME = nil
  $PokemonGlobal.nextBattleBack      = nil
  $PokemonEncounters.reset_step_count
  # fades in viewport
  viewport.color = Color.new(0, 0, 0)
  for j in 0...16
    viewport.color.alpha -= 32.delta_sub(false)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.color.alpha = 0
  viewport.dispose
  $game_temp.in_battle = false
end
