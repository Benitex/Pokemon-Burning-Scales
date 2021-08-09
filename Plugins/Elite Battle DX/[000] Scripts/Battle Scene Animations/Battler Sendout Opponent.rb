#===============================================================================
#  Scene override for new animations when opponent sends out their battler(s)
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  function to trigger the sendout animation
  #-----------------------------------------------------------------------------
  def trainerBattlerSendOut(sendOuts, startBattle = false) # Opponent sending out Pokemon
    @opponentLineUp.toggle = false
    @smTrainerSequence.sendout if @smTrainerSequence
    # initial configuration of used variables
    ballframe = 0
    dig = []; alt = []; curve = []; orgcord = []; burst = {}; dust = {}
    # prepare graphical assets
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      pkmn = @battle.battlers[b[0]].effects[PBEffects::Illusion] || b[1]
      # render databox
      @sprites["dataBox_#{i}"].render
      # draw Pokeball sprites
      bstr = "Graphics/EBDX/Pictures/Pokeballs/#{pkmn.poke_ball}"
      ballbmp = pbResolveBitmap(bstr) ? pbBitmap(bstr) : pbBitmap("Graphics/EBDX/Pictures/Pokeballs/POKEBALL")
      @sprites["pokeball#{i}"] = Sprite.new(@viewport)
      @sprites["pokeball#{i}"].bitmap = ballbmp
      @sprites["pokeball#{i}"].src_rect.set(0, ballframe*40, 41, 40)
      @sprites["pokeball#{i}"].ox = 20
      @sprites["pokeball#{i}"].oy = 20
      @sprites["pokeball#{i}"].zoom_x = 0.75
      @sprites["pokeball#{i}"].zoom_y = 0.75
      @sprites["pokeball#{i}"].z = 19
      @sprites["pokeball#{i}"].opacity = 0
      # additional metrics
      dig.push(EliteBattle.get_data(battler.species, :Species, :GROUNDED, (battler.form rescue 0)))
      # set battler bitmap
      @sprites["pokemon_#{i}"].setPokemonBitmap(pkmn, false)
      @sprites["pokemon_#{i}"].showshadow = false
      orgcord.push(@sprites["pokemon_#{i}"].oy)
      @sprites["pokemon_#{i}"].oy = @sprites["pokemon_#{i}"].height/2 if !dig[m]
      @sprites["pokemon_#{i}"].tone = Tone.new(255, 255, 255)
      @sprites["pokemon_#{i}"].opacity = 255
      @sprites["pokemon_#{i}"].visible = false
      curve.push(
        calculateCurve(
            @sprites["pokemon_#{i}"].x, @sprites["battlebg"].battler(i).y-50-(orgcord[m]-@sprites["pokemon_#{i}"].oy),
            @sprites["pokemon_#{i}"].x, @sprites["battlebg"].battler(i).y-100-(orgcord[m]-@sprites["pokemon_#{i}"].oy),
            @sprites["pokemon_#{i}"].x, @sprites["battlebg"].battler(i).y-50-(orgcord[m]-@sprites["pokemon_#{i}"].oy), 30
        )
      )
    end
    # initial trainer fade and Pokeball throwing animation
    pbSEPlay("EBDX/Throw")
    for j in 0...30
      ballframe += 1
      ballframe = 0 if ballframe > 7
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        # animation for fading out the opponent
        if @firstsendout && @sprites["trainer_#{m}"]
          if @minorAnimation && !@smTrainerSequence
            @sprites["trainer_#{m}"].x += 8
          else
            @sprites["trainer_#{m}"].x += 3
            @sprites["trainer_#{m}"].y -= 2
            @sprites["trainer_#{m}"].zoom_x -= 0.02
            @sprites["trainer_#{m}"].zoom_y -= 0.02
          end
          @sprites["trainer_#{m}"].opacity -= 12.8
        end
        @sprites["pokeball#{i}"].src_rect.set(0, ballframe*40, 41, 40)
        @sprites["pokeball#{i}"].x = curve[m][j][0]
        @sprites["pokeball#{i}"].y = curve[m][j][1]
        @sprites["pokeball#{i}"].opacity += 51
      end
      self.wait
    end
    # configuring the Y position of Pokemon sprites
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      pkmn = @battle.battlers[b[0]].effects[PBEffects::Illusion] || b[1]
      @sprites["pokemon_#{i}"].visible = true
      @sprites["pokemon_#{i}"].y -= 50 + (orgcord[m] - @sprites["pokemon_#{i}"].oy) if !dig[m]
      @sprites["pokemon_#{i}"].zoom_x = 0
      @sprites["pokemon_#{i}"].zoom_y = 0
      @sprites["dataBox_#{i}"].appear
      playBattlerCry(battler)
      burst["#{i}"] = EBBallBurst.new(@viewport, @sprites["pokeball#{i}"].x, @sprites["pokeball#{i}"].y, 19, 1, pkmn.poke_ball)
    end
    # starting Pokemon release animation
    pbSEPlay("Battle recall")
    @sendingOut = false
    clearMessageWindow
    zStep = calculateCurve(0, 0, 1, 20, 2, 10, 20)
    for j in 0...20
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        burst["#{i}"].update
        next if j < 4
        @sprites["pokeball#{i}"].opacity -= 51
        @sprites["pokemon_#{i}"].zoom_x = zStep[j][1]*@vector.zoom1*0.1
        @sprites["pokemon_#{i}"].zoom_y = zStep[j][1]*@vector.zoom1*0.1
        @sprites["pokemon_#{i}"].still
        @sprites["dataBox_#{i}"].show
      end
      self.wait
    end
    for j in 0...22
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        burst["#{i}"].update
        burst["#{i}"].dispose if j == 21
        next if j < 8
        @sprites["pokemon_#{i}"].tone.red -= 51 if @sprites["pokemon_#{i}"].tone.red > 0
        @sprites["pokemon_#{i}"].tone.green -= 51 if @sprites["pokemon_#{i}"].tone.green > 0
        @sprites["pokemon_#{i}"].tone.blue -= 51 if @sprites["pokemon_#{i}"].tone.blue > 0
      end
      self.wait
    end
    burst = nil
    # dropping Pokemon onto the ground
    sendoutDropPkmn(sendOuts, orgcord, dig, 1, 5)
    # handler for screenshake (and weight animation upon entry)
    heavy = sendoutScreenShake(sendOuts, dig, startBattle, alt, dust)
    # dust animation upon entry of heavy pokemon
    sendoutDustAnim(sendOuts, heavy, dust, alt)
    # shiny animation upon entry
    sendoutShinyPkmn(sendOuts)
    # done
    @sendingOut = false
    return true
  end
  #-----------------------------------------------------------------------------
end
