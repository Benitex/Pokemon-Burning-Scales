#===============================================================================
#  Hatching scene
#===============================================================================
class PokemonEggHatch_Scene
  #-----------------------------------------------------------------------------
  # main update function
  #-----------------------------------------------------------------------------
  def update
    self.updateBackground
    @sprites["poke"].update
    return if @frame >= 5
    @sprites["poke"].sprite.bitmap.blt((@sprites["poke"].bitmap.width - @cracks.width)/2,(@sprites["poke"].bitmap.height - @cracks.height)/2,@cracks.bitmap,Rect.new(0,0,@cracks.width,@cracks.height))
  end
  #-----------------------------------------------------------------------------
  # background update function
  #-----------------------------------------------------------------------------
  def updateBackground
    for j in 0...6
      @sprites["l#{j}"].y = @viewport.height if @sprites["l#{j}"].y <= 0
      t = (@sprites["l#{j}"].y.to_f/@viewport.height)*255
      @sprites["l#{j}"].tone = Tone.new(t,t,t)
      z = ((@sprites["l#{j}"].y.to_f - @viewport.height/2)/(@viewport.height/2))*1.0
      @sprites["l#{j}"].angle = (z < 0) ? 180 : 0
      @sprites["l#{j}"].zoom_y = z.abs
      @sprites["l#{j}"].y -= 2
    end
  end
  #-----------------------------------------------------------------------------
  # advancing the frames
  #-----------------------------------------------------------------------------
  def advance
    @frame += 1
    2.times { @cracks.update }
  end
  #-----------------------------------------------------------------------------
  #  applies alteration if applicable
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @imgBg = "hatchbg"
    # looks up species specific metrics
    d1 = EliteBattle.get_data(@pokemon.species, :Species, :HATCHBG, (@pokemon.form rescue 0))
    # proceeds with parameter definition if available
    @imgBg = d1 if d1 && d1.is_a?(String)
  end
  #-----------------------------------------------------------------------------
  # initializes sprites for animation
  #-----------------------------------------------------------------------------
  def pbStartScene(pokemon)
    @path = "Graphics/EBDX/Pictures/Hatching/"
    @frame = 0
    @sprites = {}
    @pokemon = pokemon
    self.applyMetrics
    @nicknamed = false
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @viewport.color = Color.new(0,0,0,0)
    # initial fading transition
    16.times do
      @viewport.color.alpha += 16
      pbWait(1)
    end
    # initializes bars for cutting the screen off
    @sprites["bar1"] = Sprite.new(@viewport)
    @sprites["bar1"].create_rect(@viewport.width,@viewport.height/2,Color.black)
    @sprites["bar1"].z = 99999
    @sprites["bar2"] = Sprite.new(@viewport)
    @sprites["bar2"].create_rect(@viewport.width,@viewport.height/2,Color.black)
    @sprites["bar2"].y = @viewport.height/2
    @sprites["bar2"].z = 99999
    # background graphics
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = pbBitmap(@path + @imgBg)
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = pbBitmap(@path + "overlay")
    @sprites["bg2"].z = 5
    # initializes messages window
    @sprites["msgwindow"] = pbCreateMessageWindow(@viewport)
    @sprites["msgwindow"].visible = false
    @sprites["msgwindow"].z = 9999
    # particles for the background
    for j in 0...6
      @sprites["l#{j}"] = Sprite.new(@viewport)
      @sprites["l#{j}"].bitmap = pbBitmap(@path + "line")
      @sprites["l#{j}"].y = (@viewport.height/6)*j
      @sprites["l#{j}"].ox = @sprites["l#{j}"].bitmap.width/2
      @sprites["l#{j}"].x = @viewport.width/2
    end
    @pokemon.steps_to_hatch = 1
    @sprites["poke"] = DynamicPokemonSprite.new(false, 0, @viewport)
    @sprites["poke"].setPokemonBitmap(@pokemon) # Egg sprite
    @sprites["poke"].z = 50
    @sprites["poke"].ox = @sprites["poke"].bitmap.width/2
    @sprites["poke"].oy = @sprites["poke"].bitmap.height
    @sprites["poke"].x = @viewport.width/2
    @sprites["poke"].y = @viewport.height/2 + @sprites["poke"].bitmap.height*0.5
    @sprites["poke"].showshadow = false
    # get graphics for the egg crack
    crackfilename = sprintf("Graphics/EBDX/Battlers/Eggs/%scracks", @pokemon.species) rescue nil
    if !pbResolveBitmap(crackfilename)
      crackfilename = sprintf("Graphics/EBDX/Battlers/Eggs/%03dcracks", GameData::Species.get(@pokemon.species).id_number)
      if !pbResolveBitmap(crackfilename)
        crackfilename = sprintf("Graphics/EBDX/Battlers/Eggs/000cracks")
      end
    end
    @cracks = BitmapEBDX.new(crackfilename)
    @pokemon.steps_to_hatch = 0
    @viewport.color.alpha = 0
    # set rect sprite
    @sprites["rect"] = Sprite.new(@viewport)
    @sprites["rect"].create_rect(@viewport.width,@viewport.height,Color.white)
    @sprites["rect"].opacity = 0
    @sprites["rect"].z = 100
  end
  #-----------------------------------------------------------------------------
  # main function of the animation sequence
  #-----------------------------------------------------------------------------
  def pbMain
    # stops BGM and displays message
    pbBGMStop()
    pbMEPlay("EBDX/Evolution Start")
    16.times do
      Graphics.update
      self.update
      @sprites["bar1"].y -= @sprites["bar1"].bitmap.height/16
      @sprites["bar2"].y += @sprites["bar2"].bitmap.height/16
    end
    pbBGMPlay("EBDX/Evolution")
    self.wait(32)
    # Egg bounce animation
    2.times do
      3.times do
        @sprites["poke"].zoom_y += 0.04
        wait
      end
      for i in 0...6
        @sprites["poke"].y -= 6 * (i < 3 ? 1 : -1)
        wait
      end
      for i in 0...6
        @sprites["poke"].zoom_y -= 0.04 * (i < 3 ? 2 : -1)
        @sprites["poke"].y -= 2 if i >= 3
        wait
      end
      3.times do
        @sprites["poke"].y += 2
        wait
      end
      self.advance
      pbSEPlay("EBDX/Anim/ice2",80)
      self.wait(24)
    end
    # Egg shake animation
    m = 16; n = 2; k = -1
    for j in 0...3
      self.advance if j < 2
      pbSEPlay("EBDX/Anim/ice2",80) if j < 2
      for i in 0...m
        k *= -1 if i%n == 0
        @sprites["poke"].x += k * 4
        @sprites["rect"].opacity += 64 if j == 2 && i >= (m - 5)
        wait
      end
      k = j < 1 ? 1.5 : 2
      n = 3
      m = 42
      self.wait(24) if j < 1
    end
    # Egg burst animation
    self.advance
    pbSEPlay("Battle recall")
    @sprites["poke"].setPokemonBitmap(@pokemon) # Egg sprite
    @sprites["poke"].ox = @sprites["poke"].bitmap.width/2
    @sprites["poke"].oy = @sprites["poke"].bitmap.height
    @sprites["poke"].x = @viewport.width/2
    @sprites["poke"].y = @viewport.height/2 + @sprites["poke"].bitmap.height*0.5
    @sprites["ring"] = Sprite.new(@viewport)
    @sprites["ring"].z = 200
    @sprites["ring"].bitmap = pbBitmap(@path + "shine7")
    @sprites["ring"].ox = @sprites["ring"].bitmap.width/2
    @sprites["ring"].oy = @sprites["ring"].bitmap.height/2
    @sprites["ring"].color = Color.new(32,92,42)
    @sprites["ring"].opacity = 0
    @sprites["ring"].x = @viewport.width/2
    @sprites["ring"].y = @viewport.height/2
    for j in 0...16
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].z = 200
      @sprites["s#{j}"].bitmap = pbBitmap(@path + "shine6")
      @sprites["s#{j}"].ox = @sprites["s#{j}"].bitmap.width/2
      @sprites["s#{j}"].oy = @sprites["s#{j}"].bitmap.height/2
      @sprites["s#{j}"].color = Color.new(232,92,42)
      @sprites["s#{j}"].x = @viewport.width/2
      @sprites["s#{j}"].y = @viewport.height/2
      @sprites["s#{j}"].opacity = 0
      r = 96 + rand(64)
      x, y = randCircleCord(r)
      @sprites["s#{j}"].end_x = @sprites["s#{j}"].x - r + x
      @sprites["s#{j}"].end_y = @sprites["s#{j}"].y - r + y - 32
      z = 1 - rand(20)*0.01
      @sprites["s#{j}"].zoom_x = z
      @sprites["s#{j}"].zoom_y = z
    end
    16.times do
      for j in 0...16
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].end_x)*0.05
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].end_y)*0.05
        @sprites["s#{j}"].color.alpha -= 16
        @sprites["s#{j}"].opacity += 32
      end
      @sprites["ring"].color.alpha -= 16
      @sprites["ring"].opacity += 32
      @sprites["ring"].zoom_x += 0.5
      @sprites["ring"].zoom_y += 0.5
      wait
    end
    for i in 0...48
      for j in 0...16
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].end_x)*0.05
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].end_y)*0.05
        @sprites["s#{j}"].end_y += 2
        @sprites["s#{j}"].zoom_x -= 0.01
        @sprites["s#{j}"].zoom_y -= 0.01
        @sprites["s#{j}"].opacity -= 16 if i >= 32
      end
      @sprites["ring"].zoom_x += 0.5
      @sprites["ring"].zoom_y += 0.5
      @sprites["ring"].opacity -= 32
      wait
    end
    16.times do
      @sprites["rect"].opacity -= 16
      wait
    end
    self.wait(32)
    # Finish scene
    frames = GameData::Species.cry_length(@pokemon.species, @pokemon.form)
    pbBGMStop()
    GameData::Species.play_cry(@pokemon)
    frames.times do
      Graphics.update
      self.update
    end
    pbMEPlay("EBDX/Capture Success")
    pbBGMPlay("EBDX/Victory Against Wild")
    @sprites["msgwindow"].visible = true
    cmd = [_INTL("Yes"),_INTL("No")]
    pbMessageDisplay(@sprites["msgwindow"],_INTL("\\se[]{1} hatched from the Egg!\\wt[80]",@pokemon.name)) { self.update }
    pbMessageDisplay(@sprites["msgwindow"],_INTL("Would you like to nickname the newly hatched {1}?",@pokemon.name)) { self.update }
    if pbShowCommands(@sprites["msgwindow"],cmd,1,0) { self.update } == 0
      nickname = pbEnterPokemonName(_INTL("{1}'s nickname?",@pokemon.name),0,10,"",@pokemon,true)
      @pokemon.name = nickname if nickname != ""
      @nicknamed = true
    end
    @sprites["msgwindow"].text = ""
    @sprites["msgwindow"].visible = false
  end
  #-----------------------------------------------------------------------------
  # frame wait function
  #-----------------------------------------------------------------------------
  def wait(frames = 1)
    frames.times do
      Graphics.update
      self.update
    end
  end
  #-----------------------------------------------------------------------------
  # close animation sequence
  #-----------------------------------------------------------------------------
  def pbEndScene
    $game_temp.message_window_showing = false if $game_temp
    16.times do
      @viewport.color.alpha += 16
      wait
    end
    pbDisposeSpriteHash(@sprites)
    16.times do
      @viewport.color.alpha -= 16
      pbWait(1)
    end
    @viewport.dispose
  end
  #-----------------------------------------------------------------------------
end
