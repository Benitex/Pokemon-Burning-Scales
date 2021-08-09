#===============================================================================
#  Functions used to align the battle scene and update visual contents of
#  the scene (including special S/M and integrated VS sequences)
#===============================================================================
class PokeBattle_Scene
  attr_reader :vector
  #-----------------------------------------------------------------------------
  #  Misc code to automate sprite animation and placement
  #-----------------------------------------------------------------------------
  def animateScene(align = false, smanim = false, &block)
    # special intro animations
    @smTrainerSequence.update if @smTrainerSequence && @smTrainerSequence.started
    @smSpeciesSequence.update if @smSpeciesSequence && @smSpeciesSequence.started
    @integratedVSSequence.update if @integratedVSSequence
    @integratedVSSequence.finish if @introdone && @integratedVSSequence
    @playerLineUp.update if !@playerLineUp.disposed?
    @opponentLineUp.update if !@opponentLineUp.disposed?
    # update block if given
    block.call if block
    @fancyMsg.update if @fancyMsg && !@fancyMsg.disposed?
    # dex data
    @sprites["dexdata"].update if @sprites["dexdata"]
    pbHideAllDataboxes if @sprites["dexdata"]
    # vector update
    @vector.update
    # trick for clearing message windows
    if @inMoveAnim.is_a?(Numeric)
      @inMoveAnim += 1
      if @inMoveAnim > Graphics.frame_rate*0.5
        clearMessageWindow
        @inMoveAnim = false
      end
    end
    # backdrop update
    @sprites["battlebg"].update
    @sprites["trainer_Anim"].update
    @sprites["trainer_Anim"].opacity -= 8 if @introdone && @sprites["trainer_Anim"].opacity > 0
    @idleTimer += 1 if @idleTimer >= 0
    @lastMotion = nil if @idleTimer < 0
    @sprites["player_"].x += (40-@sprites["player_"].x)/4 if @safaribattle && @sprites["player_"] && @playerfix
    # update battler sprites
    @battle.battlers.each_with_index do |b, i|
      if b
        unless EliteBattle.get(:smAnim)
          if @sprites["pokemon_#{i}"].loaded
            status = @battle.battlers[i].status
            case status
            when :SLEEP
              @sprites["pokemon_#{i}"].actualBitmap.setSpeed(3)
            when :PARALYSIS
              @sprites["pokemon_#{i}"].actualBitmap.setSpeed(2)
              @sprites["pokemon_#{i}"].status = 2
            when :FROZEN
              @sprites["pokemon_#{i}"].actualBitmap.setSpeed(0)
              @sprites["pokemon_#{i}"].status = 3
            when :POISON
              @sprites["pokemon_#{i}"].status = 1
            when :BURN
              @sprites["pokemon_#{i}"].status = 4
            else
              @sprites["pokemon_#{i}"].actualBitmap.setSpeed(1)
              @sprites["pokemon_#{i}"].status = 0
            end
          end
          @sprites["pokemon_#{i}"].update(@sprites["battlebg"].scale_y)
          @sprites["pokemon_#{i}"].shadowUpdate
          @sprites["pokemon_#{i}"].chargedUpdate
          @sprites["pokemon_#{i}"].energyUpdate
          @sprites["dataBox_#{i}"].update if @sprites["dataBox_#{i}"] && @sprites["pokemon_#{i}"].loaded
        end
        if !@orgPos.nil? && @idleTimer > (@lastMotion.nil? ? EliteBattle::BATTLE_MOTION_TIMER*Graphics.frame_rate : EliteBattle::BATTLE_MOTION_TIMER*Graphics.frame_rate*0.5) && @vector.finished? && !@safaribattle
          @vector.inc = 0.005*(rand(4)+1)
          a = EliteBattle.random_vector(@battle, @lastMotion)
          @lastMotion = rand(a.length)
          setVector(a[@lastMotion])
        end
      end
      # update trainer sprites
      if @battle.opponent
        for t in 0...@battle.opponent.length
          next if !@sprites["trainer_#{t}"]
          @sprites["trainer_#{t}"].scale_y = @sprites["battlebg"].scale_y
        end
      end
      next if !align
      # align the positions of all sprites in scene
      zoom = (i%2 == 0) ? 2 : 1
      if @sprites["pokemon_#{i}"]
        dmax = (i%2 == 0) ? 4/EliteBattle::BACK_SPRITE_SCALE : 4; zoomer = (@vector.zoom1**0.75) * zoom * (@sprites["pokemon_#{i}"].dynamax ? dmax : 1)
        @sprites["pokemon_#{i}"].x = @sprites["battlebg"].battler(i).x - (i%2 == 0 ? 64 : -32) * (@sprites["pokemon_#{i}"].dynamax ? 1 : 0)
        @sprites["pokemon_#{i}"].y = @sprites["battlebg"].battler(i).y + (@sprites["pokemon_#{i}"].dynamax ? 38 : 0)
        @sprites["pokemon_#{i}"].zoom_x = zoomer
        @sprites["pokemon_#{i}"].zoom_y = zoomer
      end
      if @battle.opponent
        for t in 0...@battle.opponent.length
          next if !@sprites["trainer_#{t}"]
          @sprites["trainer_#{t}"].x = @sprites["battlebg"].trainer(t*2 + 1).x
          @sprites["trainer_#{t}"].y = @sprites["battlebg"].trainer(t*2 + 1).y
          @sprites["trainer_#{t}"].zoom_x = (@vector.zoom1**0.75)
          @sprites["trainer_#{t}"].zoom_y = (@vector.zoom1**0.75)
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  moves all elements inside the scene
  #-----------------------------------------------------------------------------
  def moveEntireScene(x=0, y=0, lock=true, bypass=false, except=nil)
    return if !bypass && EliteBattle::DISABLE_SCENE_MOTION
    for i in 0...4
      next if !i.nil? && i == except
      @sprites["pokemon_#{i}"].x += x if @sprites["pokemon_#{i}"]
      @sprites["pokemon_#{i}"].y += y if @sprites["pokemon_#{i}"]
    end
    @vector.x += x; @vector.y += y
    return if !lock; return if @orgPos.nil?
    @orgPos[0] += x; @orgPos[1] += y
  end
  #-----------------------------------------------------------------------------
  #  scene wait with animation
  #-----------------------------------------------------------------------------
  def wait(frames = 1, align = false, &block)
    frames.times do
      animateScene(align, &block)
      Graphics.update if !EliteBattle.get(:smAnim)
    end
  end
  #-----------------------------------------------------------------------------
  #  sets scene vector
  #-----------------------------------------------------------------------------
  def setVector(*args)
    return if EliteBattle::DISABLE_SCENE_MOTION
    if args[0].is_a?(Array)
      return if args[0].length < 5
      x, y, angle, scale, zoom = args[0]
    else
      return if args.length < 5
      x, y, angle, scale, zoom = args
    end
    vector = EliteBattle.get_vector(:MAIN, @battle)
    x += @orgPos[0] - vector[0]
    y += @orgPos[1] - vector[1]
    angle += @orgPos[2] - vector[2]
    scale += @orgPos[3] - vector[3]
    zoom += @orgPos[4] - vector[4]
    @vector.set(x, y, angle, scale, zoom, 1)
  end
  #-----------------------------------------------------------------------------
  #  resets sprites for move transformations
  #-----------------------------------------------------------------------------
  def revertMoveTransformations(index)
    if @sprites["pokemon_#{index}"] && @sprites["pokemon_#{index}"].hidden
      @sprites["pokemon_#{index}"].hidden = false
      @sprites["pokemon_#{index}"].visible = true
    end
  end
  #-----------------------------------------------------------------------------
end
