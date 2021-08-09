#===============================================================================
#  Scene override to display animation when recalling battlers
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  Function to trigger battler recal
  #-----------------------------------------------------------------------------
  def pbRecall(battlerindex)
    return if @battle.battlers[battlerindex].fainted?
    balltype = @battle.battlers[battlerindex].pokemon.poke_ball
    poke = @sprites["pokemon_#{battlerindex}"]
    return if poke.fainted
    poke.resetParticles
    pbSEPlay("Battle recall") if !@sprites["pokemon_#{battlerindex}"].hidden
    zoom = poke.zoom_x/20.0
    @sprites["dataBox_#{battlerindex}"].visible = false
    ballburst = EBBallBurst.new(poke.viewport, poke.x, poke.y, 29, poke.zoom_x, balltype)
    ballburst.recall if !@sprites["pokemon_#{battlerindex}"].hidden
    for i in 0...32
      next if @sprites["pokemon_#{battlerindex}"].hidden
      if i < 20
        poke.tone.red += 25.5
        poke.tone.green += 25.5
        poke.tone.blue += 25.5
        if playerBattler?(@battle.battlers[battlerindex])
          @sprites["dataBox_#{battlerindex}"].x += 26
        else
          @sprites["dataBox_#{battlerindex}"].x -= 26
        end
        @sprites["dataBox_#{battlerindex}"].opacity -= 25.5
        poke.zoom_x -= zoom
        poke.zoom_y -= zoom
      end
      ballburst.update
      self.wait
    end
    ballburst.dispose
    ballburst = nil
    poke.visible = false
    # try to remove low HP BGM
    setBGMLowHP(false)
  end
  #-----------------------------------------------------------------------------
  #  Common animation elements for sendouts
  #-----------------------------------------------------------------------------
  #  drop battlers onto the field
  def sendoutDropPkmn(sendOuts, orgcord, dig, z3, drop)
    for j in 0...12
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        next if i == EliteBattle.follower(@battle)
        if j == 11
          @sprites["pokemon_#{i}"].showshadow = true
        elsif j > 0
          @sprites["pokemon_#{i}"].y += drop if !dig[m]
        else
          @sprites["pokemon_#{i}"].y += (orgcord[m] - @sprites["pokemon_#{i}"].oy)*z3 if !dig[m]
          @sprites["pokemon_#{i}"].oy = orgcord[m] if !dig[m]
        end
      end
      self.wait(1, false) if j > 0 && j < 11
    end
  end
  #-----------------------------------------------------------------------------
  #  shake screen upon drop
  #-----------------------------------------------------------------------------
  def sendoutScreenShake(sendOuts, dig, startBattle, alt, dust)
    # main shake
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      val = getBattlerAltitude(battler); val = 0 if val.nil?
      val = 1 if dig[m]
      alt.push(val)
      next if i == EliteBattle.follower(@battle)
      dust["#{i}"] = EBDustParticle.new(@viewport, @sprites["pokemon_#{i}"], (startBattle ? 1 : 2))
      @sprites["pokeball#{i}"].dispose
    end
    # register as heavy shake
    shake = false; heavy = false; onlydig = false; shadowless = false
    sendOuts.each_with_index do |b, m|
      battler = @battlers[b[0]]; i = battler.index
      next if i == EliteBattle.follower(@battle)
      shake = true if alt[m] < 1 && !dig[m]
      heavy = true if battler.pbWeight*0.1 >= 291 && alt[m] < 1 && !dig[m]
    end
    sendOuts.each_with_index {|b, m| onlydig = true if !shake && dig[m] }
    # override for shadowless environments
    if @sprites["battlebg"].data.has_key?("noshadow") && @sprites["battlebg"].data["noshadow"] == true
      shake = false; heavy = false; shadowless = true
    end
    # play SE
    pbSEPlay("EBDX/Drop") if shake && !heavy
    pbSEPlay("EBDX/Drop Heavy") if heavy
    mult = heavy ? 2 : 1
    # move scene
    for j in 0...8
      next if onlydig
      sendOuts.each_with_index do |b, m|
        next if alt[m] < 1 && !shadowless
        battler = @battlers[b[0]]; i = battler.index
        next if i == EliteBattle.follower(@battle)
        @sprites["pokemon_#{i}"].y += ((j/4 < 1) ? 4 : -4)
      end
      if shake
        y = (j/4 < 1) ? 2 : -2
        moveEntireScene(0, (y*mult))
      end
      self.wait(1, false)
    end
    return heavy
  end
  #-----------------------------------------------------------------------------
  #  dust animation upon drop
  #-----------------------------------------------------------------------------
  def sendoutDustAnim(sendOuts, heavy, dust, alt)
    for j in 0..24
      next if !heavy
      sendOuts.each_with_index do |b, m|
        battler = @battlers[b[0]]; i = battler.index
        next if i == EliteBattle.follower(@battle)
        dust["#{i}"].update if battler.pbWeight*0.1 >= 291 && alt[m] < 1
        dust["#{i}"].dispose if j == 24
      end
      self.wait(1, false) if j < 24
    end
    dust = nil
  end
  #-----------------------------------------------------------------------------
  #  shiny animation upon entry
  #-----------------------------------------------------------------------------
  def sendoutShinyPkmn(sendOuts)
    sendOuts.each do |b|
      @sprites["dataBox_#{@battlers[b[0]].index}"].inposition = true
      next if @battlers[b[0]].index == EliteBattle.follower(@battle)
      next if !@battle.showAnims || !shinyBattler?(@battlers[b[0]])
      pbCommonAnimation("Shiny", @battlers[b[0]])
    end
  end
  #-----------------------------------------------------------------------------
end
