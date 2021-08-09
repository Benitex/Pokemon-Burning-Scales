#===============================================================================
#  Scene override for new animations when player sends out their battler(s)
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  function to trigger the sendout animation
  #-----------------------------------------------------------------------------
  def playerBattlerSendOut(sendOuts, startBattle = false) # Player sending out Pokémon
    @playerLineUp.toggle = false
    # skip for followers
    if sendOuts.length < 2 && !EliteBattle.follower(@battle).nil?
      clearMessageWindow(true)
      playBattlerCry(@battlers[EliteBattle.follower(@battle)])
      @firstsendout = false
      return
    end
    # initial configuration of used variables
    ballframe = 0
    dig = []; alt = []; curve = []; orgcord = []; burst = {}; dust = {}
    # try to remove low HP BGM
    setBGMLowHP(false)
    # prepare graphical assets
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      pkmn = @battle.battlers[b[0]].effects[PBEffects::Illusion] || b[1]
      # additional metrics
      dig.push(EliteBattle.get_data(battler.species, :Species, :GROUNDED, (battler.form rescue 0)))
      if i == EliteBattle.follower(@battle)
        orgcord.push(0); next
      end
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
      # set battler bitmap
      @sprites["pokemon_#{i}"].setPokemonBitmap(pkmn, true)
      @sprites["pokemon_#{i}"].showshadow = false
      orgcord.push(@sprites["pokemon_#{i}"].oy)
      @sprites["pokemon_#{i}"].oy = @sprites["pokemon_#{i}"].height/2 if !dig[m]
      @sprites["pokemon_#{i}"].tone = Tone.new(255, 255, 255)
      @sprites["pokemon_#{i}"].opacity = 255
      @sprites["pokemon_#{i}"].visible = false
    end
    # vector alignment
    v = startBattle ? EliteBattle.get_vector(:SENDOUT) : EliteBattle.get_vector(:MAIN, @battle)
    @vector.set(v)
    (startBattle ? 44 : 20).times do
      sendOuts.each_with_index do |b, m|
        next if !startBattle
        next if m < 1 && !EliteBattle.follower(@battle).nil?
        @sprites["player_#{m}"].opacity += 25.5 if @sprites["player_#{m}"]
      end
      self.wait(1, true)
    end
    # player throw animation
    for j in 0...7
      next if !startBattle
      sendOuts.each_with_index do |b, m|
        next if !@sprites["player_#{m}"]
        next if m < 1 && !EliteBattle.follower(@battle).nil?
        @sprites["player_#{m}"].src_rect.x += (@sprites["player_#{m}"].bitmap.width/5) if j == 0
        @sprites["player_#{m}"].x -= 2 if j > 0
      end
      self.wait(1, false)
    end
    self.wait(6, true) if startBattle
    for j in 0...6
      next if !startBattle
      sendOuts.each_with_index do |b, m|
        next if !@sprites["player_#{m}"]
        next if m < 1 && !EliteBattle.follower(@battle).nil?
        @sprites["player_#{m}"].src_rect.x += (@sprites["player_#{m}"].bitmap.width/5) if j%2 == 0
        @sprites["player_#{m}"].x += 3 if j < 4
      end
      self.wait(1, false)
    end
    # throw SE
    pbSEPlay("EBDX/Throw")
    addzoom = (@vector.zoom1**0.75) * 2
    # calculating the curve for the Pokeball trajectory
    posX = (startBattle && !EliteBattle::DISABLE_SCENE_MOTION) ? [80, 30] : [100, 40]
    posY = (startBattle && !EliteBattle::DISABLE_SCENE_MOTION) ? [40, 160, 120] : [70, 170, 120]
    z1 = startBattle ? addzoom : 1
    z2 = startBattle ? addzoom : 2
    z3 = startBattle ? 1 : 2
    # calculate ball curve
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      y3 = 120 + (orgcord[m] - @sprites["pokemon_#{i}"].oy)*z3
      curve.push(
        calculateCurve(
            @sprites["pokemon_#{i}"].x-posX[0], @sprites["battlebg"].battler(i).y-posY[0]*z1-(orgcord[m]-@sprites["pokemon_#{i}"].oy)*z2,
            @sprites["pokemon_#{i}"].x-posX[1], @sprites["battlebg"].battler(i).y-posY[1]*z1-(orgcord[m]-@sprites["pokemon_#{i}"].oy)*z2,
            @sprites["pokemon_#{i}"].x, @sprites["battlebg"].battler(i).y-y3, 28
        )
      )
      next if i == EliteBattle.follower(@battle)
      @sprites["pokeball#{i}"].zoom_x *= addzoom
      @sprites["pokeball#{i}"].zoom_y *= addzoom
    end
    # initial Pokeball throwing animation
    for j in 0...48
      ballframe += 1
      ballframe = 0 if ballframe > 7
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        next if i == EliteBattle.follower(@battle)
        @sprites["pokeball#{i}"].src_rect.set(0, ballframe*40, 41, 40)
        @sprites["pokeball#{i}"].x = curve[m][j][0] if j < 28
        @sprites["pokeball#{i}"].y = curve[m][j][1] if j < 28
        @sprites["pokeball#{i}"].opacity += 42
      end
      self.wait(1, false)
    end
    # configuring the Y position of Pokemon sprites
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      pkmn = @battle.battlers[b[0]].effects[PBEffects::Illusion] || b[1]
      playBattlerCry(battler)
      next if i == EliteBattle.follower(@battle)
      @sprites["pokemon_#{i}"].visible = true
      @sprites["pokemon_#{i}"].y -= 120 + (orgcord[m] - @sprites["pokemon_#{i}"].oy)*z3 if !dig[m]
      @sprites["pokemon_#{i}"].zoom_x = 0
      @sprites["pokemon_#{i}"].zoom_y = 0
      @sprites["dataBox_#{i}"].appear
      burst["#{i}"] = EBBallBurst.new(@viewport, @sprites["pokeball#{i}"].x, @sprites["pokeball#{i}"].y, 29, (startBattle ? 1 : 2), pkmn.poke_ball)
    end
    # starting Pokemon release animation
    pbSEPlay("Battle recall")
    self.clearMessageWindow(true)
    zStep = calculateCurve(0, 0, 1, 20, 2, 10, 20)
    for j in 0...20
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        @sprites["player_#{m}"].opacity -= 25.5 if @sprites["player_#{m}"] && startBattle
        next if i == EliteBattle.follower(@battle)
        burst["#{i}"].update
        next if j < 4
        @sprites["pokeball#{i}"].opacity -= 51
        if startBattle
          @sprites["pokemon_#{i}"].zoom_x = (zStep[j][1]*addzoom*0.1)
          @sprites["pokemon_#{i}"].zoom_y = (zStep[j][1]*addzoom*0.1)
        else
          @sprites["pokemon_#{i}"].zoom_x = (zStep[j][1]*@vector.zoom1*0.2)
          @sprites["pokemon_#{i}"].zoom_y = (zStep[j][1]*@vector.zoom1*0.2)
        end
        @sprites["pokemon_#{i}"].still
        @sprites["dataBox_#{i}"].show
      end
      self.wait(1, false)
    end
    # pokemon burst animation
    for j in 0...22
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        next if i == EliteBattle.follower(@battle)
        burst["#{i}"].update
        burst["#{i}"].dispose if j == 21
        next if j < 8
        @sprites["pokemon_#{i}"].tone.red -= 51 if @sprites["pokemon_#{i}"].tone.red > 0
        @sprites["pokemon_#{i}"].tone.green -= 51 if @sprites["pokemon_#{i}"].tone.green > 0
        @sprites["pokemon_#{i}"].tone.blue -= 51 if @sprites["pokemon_#{i}"].tone.blue > 0
      end
      self.wait(1, false)
    end
    burst = nil
    # dropping Pokemon onto the ground
    if startBattle
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        next if i == EliteBattle.follower(@battle)
        @sprites["pokemon_#{i}"].y += (orgcord[m] - @sprites["pokemon_#{i}"].oy)*z3 if !dig[m]
        @sprites["pokemon_#{i}"].oy = orgcord[m] if !dig[m]
      end
    end
    sendoutDropPkmn(sendOuts, orgcord, dig, z3, 12)
    # handler for screenshake (and weight animation upon entry)
    heavy = sendoutScreenShake(sendOuts, dig, startBattle, alt, dust)
    # dust animation upon entry of heavy pokemon
    sendoutDustAnim(sendOuts, heavy, dust, alt)
    # shiny animation upon entry
    sendoutShinyPkmn(sendOuts)
    # done
    @firstsendout = false
    return true
  end
  #-----------------------------------------------------------------------------
end
