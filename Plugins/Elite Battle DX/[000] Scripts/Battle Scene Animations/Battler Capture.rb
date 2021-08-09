#===============================================================================
#  Scene override for custom ball throwing animation when capturing Pokemon
#===============================================================================
class PokeBattle_Scene
  attr_reader :caughtBattler
  #-----------------------------------------------------------------------------
  #  Alias unused functions
  #-----------------------------------------------------------------------------
  def pbThrowAndDeflect(ball, targetBattler); end
  def pbHideCaptureBall(idxBattler); end
  #-----------------------------------------------------------------------------
  #  Pokeball throw animation
  #-----------------------------------------------------------------------------
  def pbThrow(ball, shakes, critical, targetBattler, showplayer = nil)
    @orgPos = nil; @playerfix = false if @safaribattle
    ballframe = 0
    # sprites
    bstr = "Graphics/EBDX/Pictures/Pokeballs/#{ball}"
    ballbmp = pbResolveBitmap(bstr) ? pbBitmap(bstr) : pbBitmap("Graphics/EBDX/Pictures/Pokeballs/POKEBALL")
    spritePoke = @sprites["pokemon_#{targetBattler}"]
    @sprites["ballshadow"] = Sprite.new(@viewport)
    @sprites["ballshadow"].bitmap = Bitmap.new(34, 34)
    @sprites["ballshadow"].bitmap.bmp_circle(Color.black)
    @sprites["ballshadow"].ox = @sprites["ballshadow"].bitmap.width/2
    @sprites["ballshadow"].oy = @sprites["ballshadow"].bitmap.height/2 + 2
    @sprites["ballshadow"].z = 32
    @sprites["ballshadow"].opacity = 255*0.25
    @sprites["ballshadow"].visible = false
    @sprites["captureball"] = Sprite.new(@viewport)
    @sprites["captureball"].bitmap = ballbmp
    @sprites["captureball"].src_rect.set(0, ballframe*40, 41, 40)
    @sprites["captureball"].ox = 20
    @sprites["captureball"].oy = 20
    @sprites["captureball"].z = 32
    @sprites["captureball"].zoom_x = 4
    @sprites["captureball"].zoom_y = 4
    @sprites["captureball"].visible = false
    pokeball = @sprites["captureball"]
    shadow = @sprites["ballshadow"]
    # position "camera"
    sx, sy = @sprites["battlebg"].spoof(EliteBattle.get_vector(:ENEMY), targetBattler)
    curve = calculateCurve(sx-260,sy-160,sx-60,sy-200,sx,sy-140,24)
    # position pokeball
    pokeball.x = sx - 260
    pokeball.y = sy - 100
    pokeball.visible = true
    shadow.x = pokeball.x
    shadow.y = pokeball.y
    shadow.zoom_x = 0
    shadow.zoom_y = 0
    shadow.visible = true
    # throwing animation
    pbHideAllDataboxes(0)
    critical ? pbSEPlay("EBDX/Throw Critical") : pbSEPlay("EBDX/Throw")
    for i in 0...28
      @vector.set(EliteBattle.get_vector(:ENEMY)) if i == 4
      # fade out player in a safari battle
      if @safaribattle && i < 16
        @sprites["player_0"].x -= 75
        @sprites["player_0"].y += 38
        @sprites["player_0"].zoom_x += 0.125
        @sprites["player_0"].zoom_y += 0.125
      end
      # increment ball frame (spinning)
      ballframe += 1
      ballframe = 0 if ballframe > 7
      if i < 24
        pokeball.x = curve[i][0]
        pokeball.y = curve[i][1]
        pokeball.zoom_x -= (pokeball.zoom_x - spritePoke.zoom_x)*0.2
        pokeball.zoom_y -= (pokeball.zoom_y - spritePoke.zoom_y)*0.2
        shadow.x = pokeball.x
        shadow.y = pokeball.y + 140 + 16 + (24-i)
        shadow.zoom_x += 0.8/24
        shadow.zoom_y += 0.3/24
      end
      # update ball spin
      pokeball.src_rect.set(0, ballframe*40, 41, 40)
      self.wait(1, true)
    end
    # additional spin
    for i in 0...4
      pokeball.src_rect.set(0, (7+i)*40, 41, 40)
      self.wait
    end
    pbSEPlay("Battle recall")
    # Burst animation here
    pokeball.z = spritePoke.z-1; shadow.z = pokeball.z-1; spritePoke.showshadow = false
    ballburst = EBBallBurst.new(pokeball.viewport, pokeball.x, pokeball.y, 50, @vector.zoom1, ball)
    ballburst.catching
    clearMessageWindow
    # play burst animation and sprite zoom
    for i in 0...32
      if i < 20
        spritePoke.zoom_x -= 0.075
        spritePoke.zoom_y -= 0.075
        spritePoke.tone.all += 25.5
        spritePoke.y -= 8
      elsif i == 20
        spritePoke.zoom = 0
      end
      ballburst.update
      self.wait
    end
    # dispose of ball burst
    ballburst.dispose
    spritePoke.y += 160
    # reset frame
    pokeball.src_rect.y -= 40; self.wait
    pokeball.src_rect.y = 0; self.wait
    t = 0; i = 51
    # increase tone
    10.times do
      t += i; i =- 51 if t >= 255
      pokeball.tone = Tone.new(t, t, t)
      self.wait
    end
    #################
    pbSEPlay("Battle jump to ball")
    # drop ball to floor
    for i in 0...20
      pokeball.src_rect.y = 40*(((i-6)/2)+1) if i%2 == 0 && i >= 6
      pokeball.y += 7
      shadow.zoom_x += 0.01
      shadow.zoom_y += 0.01
      self.wait
    end
    pokeball.src_rect.y = 0
    pbSEPlay("Battle ball drop")
    # bounce animation
    for i in 0...14
      pokeball.src_rect.y = 40*((i/2)+1) if i%2 == 0
      pokeball.y -= 6 if i < 7
      pokeball.y += 6 if i >= 7
      if i <= 7
        shadow.zoom_x -= 0.005
        shadow.zoom_y -= 0.005
      else
        shadow.zoom_x += 0.005
        shadow.zoom_y += 0.005
      end
      self.wait
    end
    pokeball.src_rect.y = 0
    pbSEPlay("Battle ball drop", 80)
    # ball shake
    [shakes, 3].min.times do
      self.wait(40)
      pbSEPlay("Battle ball shake")
      pokeball.src_rect.y = 11*40
      self.wait
      # change angle sprite
      for i in 0...2
        2.times do
          pokeball.src_rect.y += 40*(i < 1 ? 1 : -1)
          self.wait
        end
      end
      pokeball.src_rect.y = 14*40
      self.wait
      for i in 0...2
        2.times do
          pokeball.src_rect.y += 40*(i < 1 ? 1 : -1)
          self.wait
        end
      end
      pokeball.src_rect.y = 0
      self.wait
    end
    # burst if 3 or less shakes
    if shakes < 4
      clearMessageWindow
      self.wait(40)
      pokeball.src_rect.y = 9*40
      self.wait
      pokeball.src_rect.y += 40
      self.wait
      pbSEPlay("Battle recall")
      spritePoke.showshadow = true
      # generate ball burst for escape
      ballburst = EBBallBurst.new(pokeball.viewport, pokeball.x, pokeball.y, 50, @vector.zoom1, ball)
      for i in 0...32
        if i < 20
          pokeball.opacity -= 25.5
          shadow.opacity -= 4
          spritePoke.zoom_x += 0.075
          spritePoke.zoom_y += 0.075
          spritePoke.tone.all -= 25.5 if spritePoke.tone.all > 0
        end
        # update burst
        ballburst.update
        self.wait
      end
      # dispose and clear messages
      ballburst.dispose
      # reset vector
      @vector.reset
      pbShowAllDataboxes(0)
      20.times do
        if @safaribattle
          @sprites["player_0"].x += 60
          @sprites["player_0"].y -= 30
          @sprites["player_0"].zoom_x -= 0.1
          @sprites["player_0"].zoom_y -= 0.1
        end
        self.wait(1, true)
      end
    else
      clearMessageWindow
      # play animation when wild is caught
      @caughtBattler = @battle.pbParty(1)[targetBattler/2]
      spritePoke.visible = false
      spritePoke.resetParticles
      spritePoke.charged = false
      self.wait(40)
      pbSEPlay("Battle ball drop", 80)
      pokeball.color = Color.new(0, 0, 0, 0)
      fp = {}
      for j in 0...3
        fp["#{j}"] = Sprite.new(pokeball.viewport)
        fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebStar")
        fp["#{j}"].ox = fp["#{j}"].bitmap.width/2
        fp["#{j}"].oy = fp["#{j}"].bitmap.height/2
        fp["#{j}"].x = pokeball.x
        fp["#{j}"].y = pokeball.y
        fp["#{j}"].opacity = 0
        fp["#{j}"].z = pokeball.z + 1
      end
      for i in 0...16
        for j in 0...3
          fp["#{j}"].y -= [3,4,3][j]
          fp["#{j}"].x -= [3,0,-3][j]
          fp["#{j}"].opacity += 32*(i < 8 ? 1 : -1)
          fp["#{j}"].angle += [4,2,-4][j]
        end
        @sprites["dataBox_#{targetBattler}"].opacity -= 25.5
        pokeball.color.alpha += 8
        self.wait
      end
      # if snagging an opponent's battler
      if @battle.opponent
        5.times do
          pokeball.opacity -= 51
          shadow.opacity -= 13
          self.wait
        end
        @vector.reset
        pbShowAllDataboxes(0)
        self.wait(20, true)
      end
      spritePoke.clear
    end
    @playerfix = true if @safaribattle
    self.briefmessage = true
  end
  #-----------------------------------------------------------------------------
  #  Function called when capture is successful
  #-----------------------------------------------------------------------------
  def pbThrowSuccess
    return if @battle.opponent
    @briefmessage = true
    # try to resolve the ME jingle
    me = "EBDX/Capture Success"
    try = @caughtBattler ? EliteBattle.get_data(@caughtBattler.species, :Species, :CAPTUREME) : nil
    me = try if !try.nil?
    # play ME
    pbMEPlay(me)
    # wait for audio frames to complete
    frames = (getPlayTime("Audio/ME/#{me}") * Graphics.frame_rate).ceil + 4
    self.wait(frames)
    pbMEStop
    # return scene to normal
    5.times do
      @sprites["ballshadow"].opacity -= 16
      @sprites["captureball"].opacity -= 52
      self.wait
    end
    @sprites["ballshadow"].dispose
    @sprites["captureball"].dispose
    pbShowAllDataboxes(0)
    @vector.reset
  end
  #-----------------------------------------------------------------------------
end
