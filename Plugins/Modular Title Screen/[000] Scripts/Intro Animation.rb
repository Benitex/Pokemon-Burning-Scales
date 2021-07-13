#===============================================================================
# Intro Animations that animate elements based on their ID
#===============================================================================
# Regular fade
class MTS_INTRO_ANIM
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the animation
    @viewport.color = Color.white
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    20.times do
      @viewport.color.alpha -= 13
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# FRLG intro
class MTS_INTRO_ANIM1
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    @x = {}
    @y = {}
    # prepares the animation
    @viewport.color = Color.new(255,255,255,0)
    for key in @scene.keys
      case @scene[key].id
      when "pokemon.static"
        @scene[key].sprite.tone.gray = 255
        @scene[key].sprite.color = Color.white
        @x[key], @y[key] = @scene[key].sprite.x, @scene[key].sprite.y
        @scene[key].sprite.y += @scene[key].sprite.bitmap.height
        @scene[key].sprite.src_rect.height = 24
        @scene[key].sprite.src_rect.y = @scene[key].sprite.bitmap.height
      when "overlay"
        @scene[key].x = @viewport.rect.width
      else
        @scene[key].visible = false
      end
    end
    @sprites["black"] = Sprite.new(@viewport)
    @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    @sprites["black"].z = 90
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    self.wait(28.delta(:add))
    # white streak
    32.delta(:add).times do
      for key in @scene.keys
        next unless @scene[key].id?("pokemon.static")
        @scene[key].sprite.y -= 24.delta(:sub)
        @scene[key].sprite.src_rect.y -= 24.delta(:sub)
      end
      self.wait
    end
    # reposition
    for key in @scene.keys
      next unless @scene[key].id?("pokemon.static")
      @scene[key].sprite.src_rect.y = 0
      @scene[key].sprite.src_rect.height = @scene[key].sprite.bitmap.height
      @scene[key].sprite.color.alpha = 0
      @scene[key].sprite.opacity = 0
      @scene[key].sprite.y = @y[key]
    end
    # fade
    80.delta(:add).times do
      for key in @scene.keys
        next unless @scene[key].id?("pokemon.static")
        @scene[key].sprite.opacity += 5.delta(:sub)
      end
      self.wait
    end
    # flash background
    @viewport.color.alpha = 255
    8.delta(:add).times do
      @viewport.color.alpha -= 32.delta(:sub)
      @sprites["black"].x += (@viewport.rect.width/8).delta(:sub)
      self.wait
    end
    @sprites["black"].visible = false
    self.wait(8.delta(:add))
    # flash overlay
    @viewport.color.alpha = 255
    8.delta(:add).times do
      @viewport.color.alpha -= 32.delta(:sub)
      for key in @scene.keys
        next unless @scene[key].id?("overlay")
        @scene[key].x -= (@viewport.rect.width/8).delta(:sub)
      end
      self.wait
    end
    for key in @scene.keys
      next unless @scene[key].id?("overlay")
      @scene[key].x = 0
    end
    @viewport.color.alpha = 0
    self.wait(8.delta(:add))
    # final flash
    @viewport.color.alpha = 255
    for key in @scene.keys
      @scene[key].visible = true
      @scene[key].sprite.tone.gray = 0 if @scene[key].id?("pokemon.static")
    end
    32.delta(:add).times do
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# HGSS
class MTS_INTRO_ANIM2
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the animation
    @viewport.color = Color.white
    @x, @y = @scene["logo"].x, @scene["logo"].y
    @scene["logo"].position(@x,@y + 32)
    @scene["logo"].logo.opacity = 0
    @scene["logo"].sublogo.opacity = 0
    for key in @scene.keys
      next if key == "logo"
      next if @scene[key].id?("background") || @scene[key].id?("effect.blend")
      @scene[key].visible = false
    end
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    # viewport flash
    20.delta(:add).times do
      @viewport.color.alpha -= 13.delta(:sub)
      self.wait
    end
    @viewport.color.alpha = 0
    # logo positioning
    32.times do
      @scene["logo"].position(@x,@scene["logo"].y-1)
      @scene["logo"].logo.opacity += 8
      @scene["logo"].sublogo.opacity += 8
      self.wait
    end
    @scene["logo"].position(@x,@y)
    # logo flash
    15.delta(:add).times do
      @scene["logo"].logo.color.alpha += 12.delta(:sub)
      @scene["logo"].sublogo.color.alpha += 12.delta(:sub)
      self.wait
    end
    @scene["logo"].logo.color.alpha = 0
    @scene["logo"].sublogo.color.alpha = 0
    # final flash
    @viewport.color.alpha = 255
    self.wait(2.delta(:add))
    for key in @scene.keys
      @scene[key].visible = true
    end
    32.delta(:add).times do
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# ORAS animation
class MTS_INTRO_ANIM3
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the logo for animation
    @x, @y = @scene["logo"].x, @scene["logo"].y
    @scene["logo"].position(@x,@viewport.rect.height/2 + 48)
    @scene["logo"].logo.src_rect.width = 0
    @scene["logo"].sublogo.opacity = 0
    @scene["logo"].sublogo.oy += 64
    # blackens background
    @sprites["black"] = Sprite.new(@viewport)
    @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    @sprites["black"].z = 900
    @sprites["black"].color = Color.new(255,255,255,0)
    # sapphire layer
    @sprites["saph"] = Sprite.new(@viewport)
    @sprites["saph"].bitmap = pbBitmap("Graphics/MODTS/Intros/sapphire")
    @sprites["saph"].z = 900
    @sprites["saph"].opacity = 0
    @sprites["saph"].color = Color.new(255,255,255,0)
    @sprites["crys"] = MTS_Extra_Overlay.new(@viewport)
    @sprites["crys"].z = 900
    # draws logo shine
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = @scene["logo"].logo.bitmap.clone
    @sprites["shine"].z = 999
    @sprites["shine"].ox = @scene["logo"].logo.ox
    @sprites["shine"].oy = @scene["logo"].logo.oy
    @sprites["shine"].x = @scene["logo"].x
    @sprites["shine"].y = @scene["logo"].y
    @sprites["shine"].src_rect.width = 16
    @sprites["shine"].src_rect.x = -16
    @sprites["shine"].color = Color.white
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    # logo reveal
    32.delta(:add).times do
      @scene["logo"].logo.src_rect.width += 16.delta(:sub)
      @sprites["shine"].src_rect.x += 16.delta(:sub)
      @sprites["shine"].x = @scene["logo"].x + @sprites["shine"].src_rect.x
      self.wait
    end
    # logo streaking
    150.delta(:add).times do
      @sprites["black"].color.alpha -= 16.delta(:sub) if @sprites["black"].color.alpha > 0
      @sprites["shine"].src_rect.x += 16.delta(:sub)
      @sprites["shine"].x = @scene["logo"].x + @sprites["shine"].src_rect.x
      if @sprites["shine"].src_rect.x > 1092
        @sprites["shine"].src_rect.x = -16
        @sprites["black"].color.alpha = 255
      end
      self.wait
    end
    # backdrop fade
    92.delta(:add).times do
      @scene["logo"].logo.color.alpha += 3.delta(:sub)
      @sprites["saph"].opacity += 4.delta(:sub)
      @sprites["saph"].color.alpha += 2.delta(:sub) if @sprites["saph"].opacity >= 255
      @sprites["crys"].update if @sprites["saph"].opacity > 32
      @sprites["shine"].src_rect.x += 16.delta(:sub)
      @sprites["shine"].x = @scene["logo"].x + @sprites["shine"].src_rect.x
      @sprites["shine"].src_rect.x = -16 if @sprites["shine"].src_rect.x > 1092
      self.wait
    end
    # reveal screen
    @viewport.color = Color.white
    @scene["logo"].logo.color.alpha = 0
    @sprites["black"].visible = false
    @sprites["saph"].visible = false
    @sprites["crys"].visible = false
    @scene["logo"].position(@x,@y)
    self.wait(2.delta(:add))
    16.delta(:add).times do
      @scene["logo"].sublogo.oy -= 4.delta(:sub)
      @scene["logo"].sublogo.opacity += 16.delta(:sub)
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
    @scene["logo"].sublogo.oy = 0
    @viewport.color.alpha = 0
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# DPPT
class MTS_INTRO_ANIM4
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the animation
    @viewport.color = Color.new(255,255,255,0)
    @x, @y = @scene["logo"].x, @scene["logo"].y
    @scene["logo"].position(@x,@y + 32)
    @scene["logo"].logo.opacity = 0
    @scene["logo"].logo.tone.gray = 255
    @scene["logo"].sublogo.visible = false
    @sprites["black"] = Sprite.new(@viewport)
    @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    @sprites["black"].z = 900
    @sprites["black"].color = Color.new(255,255,255,0)
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    # logo positioning
    32.times do
      @scene["logo"].position(@x,@scene["logo"].y-1)
      @scene["logo"].logo.opacity += 8
      self.wait
    end
    @scene["logo"].position(@x,@y)
    # logo flash
    15.delta(:add).times do
      @scene["logo"].logo.color.alpha += 12.delta(:sub)
      self.wait
    end
    @scene["logo"].logo.color.alpha = 0
    # final flash
    @viewport.color.alpha = 255
    self.wait(2.delta(:add))
    for key in @scene.keys
      @scene[key].visible = true
    end
    @scene["logo"].logo.tone.gray = 0
    @sprites["black"].visible = false
    32.delta(:add).times do
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# Faded zoom
class MTS_INTRO_ANIM5
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the animation
    @viewport.color = Color.black
    @scene["logo"].logo.opacity = 0
    @scene["logo"].logo.zoom_x = 2
    @scene["logo"].logo.zoom_y = 2
    @scene["logo"].sublogo.opacity = 0
    @scene["logo"].sublogo.zoom_x = 2
    @scene["logo"].sublogo.zoom_y = 2
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    # logo positioning
    32.delta(:add).times do
      @viewport.color.alpha -= 256/16.delta(:add)
      @scene["logo"].logo.zoom_x -= 1.0/32.delta(:add)
      @scene["logo"].logo.zoom_y -= 1.0/32.delta(:add)
      @scene["logo"].logo.opacity += 256/32.delta(:add)
      @scene["logo"].sublogo.zoom_x -= 1.0/32.delta(:add)
      @scene["logo"].sublogo.zoom_y -= 1.0/32.delta(:add)
      @scene["logo"].sublogo.opacity += 256/32.delta(:add)
      self.wait
    end
    @scene["logo"].logo.opacity = 255
    @scene["logo"].logo.zoom_x = 1
    @scene["logo"].logo.zoom_y = 1
    @scene["logo"].sublogo.opacity = 255
    @scene["logo"].sublogo.zoom_x = 1
    @scene["logo"].sublogo.zoom_y = 1
    # final flash
    @viewport.color = Color.white
    self.wait(2.delta(:add))
    32.delta(:add).times do
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# XY
class MTS_INTRO_ANIM6
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the animation
    @viewport.color = Color.black
    @scene["logo"].logo.opacity = 0
    @scene["logo"].logo.zoom_x = 1.5
    @scene["logo"].logo.zoom_y = 1.5
    @scene["logo"].sublogo.opacity = 0
    @scene["logo"].sublogo.zoom_x = 1.5
    @scene["logo"].sublogo.zoom_y = 1.5
    for key in @scene.keys
      next unless @scene[key].id?("effect.rays")
      @scene[key].visible = false
    end
    @sprites["black"] = Sprite.new(@viewport)
    @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    @sprites["black"].z = 905
    @sprites["black"].center!(true)
    @sprites["white"] = Sprite.new(@viewport)
    @sprites["white"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    @sprites["white"].z = 905
    # shiny particles
    for i in 0...24
      @sprites["s#{i}"] = Sprite.new(@viewport)
      @sprites["s#{i}"].opacity = 0
      @sprites["s#{i}"].z = 910
    end
    # shine
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine003")
    @sprites["shine"].center!(true)
    @sprites["shine"].y -= 4
    @sprites["shine"].zoom_x = 0
    @sprites["shine"].zoom_y = 0
    @sprites["shine"].z = 920
    @sprites["shine2"] = Sprite.new(@viewport)
    @sprites["shine2"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine002")
    @sprites["shine2"].center!(true)
    @sprites["shine2"].z = 920
    @sprites["shine2"].opacity = 0
    # rays
    @sprites["rays"] = Sprite.new(@viewport)
    @sprites["rays"].bitmap = pbBitmap("Graphics/MODTS/Intros/rays")
    @sprites["rays"].center!(true)
    @sprites["rays"].opacity = 0
    @sprites["rays"].z = 920
    # letters
    @sprites["sil"] = Sprite.new(@viewport)
    @sprites["sil"].bitmap = pbBitmap("Graphics/MODTS/Intros/letterSilhouette")
    @sprites["sil"].center!(true)
    @sprites["sil"].z = 900
    @sprites["sil"].angle -= 8 if $PokemonSystem.screensize < 2
    @sprites["let"] = Sprite.new(@viewport)
    @sprites["let"].bitmap = pbBitmap("Graphics/MODTS/Intros/letter")
    @sprites["let"].center!(true)
    @sprites["let"].z = 930
    @sprites["let"].zoom_x = 0
    @sprites["let"].zoom_y = 0
    @sprites["let"].angle -= 12 if $PokemonSystem.screensize < 2
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    k = 1
    # particle collection
    for i in 0...136.delta(:add)
      @viewport.color.alpha -= 16.delta(:sub)
      # animation for warp rays
      for j in 0...24
        if @sprites["s#{j}"].opacity <= 0
          bmp = pbBitmap("Graphics/MODTS/Particles/shine001")
          w = bmp.width - 8 + rand(17)
          @sprites["s#{j}"].bitmap = Bitmap.new(w,w)
          @sprites["s#{j}"].bitmap.stretch_blt(@sprites["s#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["s#{j}"].center!(true)
          @sprites["s#{j}"].ox = (@viewport.rect.width/2 + rand(64))
          @sprites["s#{j}"].angle = rand(360)
          @sprites["s#{j}"].param = 2 + rand(5)
          @sprites["s#{j}"].opacity = 255
          @sprites["s#{j}"].color = Color.new(255-rand(32),255-rand(32),255-rand(32))
          bmp.dispose
        end
        @sprites["s#{j}"].ox -= (@sprites["s#{j}"].param*2).delta(:sub)
        @sprites["s#{j}"].opacity -= (@sprites["s#{j}"].param*2).delta(:sub)
      end
      @sprites["shine"].zoom_x += 0.001/(Graphics.frame_rate/40.0)
      @sprites["shine"].zoom_y += 0.001/(Graphics.frame_rate/40.0)
      k *= -1 if i%16.delta(:add)==0
      @sprites["shine2"].zoom_x += 0.02*k/(Graphics.frame_rate/40.0)
      @sprites["shine2"].zoom_y += 0.02*k/(Graphics.frame_rate/40.0)
      @sprites["shine2"].opacity += 1
      @sprites["shine"].angle += 4
      @sprites["rays"].opacity += 1
      @sprites["rays"].angle += 0.2
      unless i < 128.delta(:add)
        if i == 130.delta(:add)
          @sprites["black"].bitmap.fill_rect(0,@viewport.rect.height*0.08,@viewport.rect.width,@viewport.rect.height*0.84,Color.new(0,0,0,0))
        end
        @sprites["white"].opacity -= 32.delta(:sub)
        @sprites["let"].zoom_x += 1.0/8.delta(:add)
        @sprites["let"].zoom_y += 1.0/8.delta(:add)
        @sprites["rays"].opacity -= 32.delta(:sub)
        @sprites["shine"].opacity -= 32.delta(:sub)
      end
      self.wait
    end
    # letter animation
    @viewport.color = Color.white
    @sprites["let"].zoom_x = 1
    @sprites["let"].zoom_y = 1
    @sprites["white"].visible = false
    @sprites["shine"].visible = false
    @sprites["shine2"].visible = false
    @sprites["rays"].visible = false
    for j in 0...24
      bmp = pbBitmap("Graphics/MODTS/Particles/shine001")
      w = bmp.width - 8 + rand(17)
      @sprites["s#{j}"].bitmap = Bitmap.new(w,w)
      @sprites["s#{j}"].bitmap.stretch_blt(@sprites["s#{j}"].bitmap.rect,bmp,bmp.rect)
      @sprites["s#{j}"].center!(true)
      @sprites["s#{j}"].angle = rand(360)
      @sprites["s#{j}"].param = 4 + rand(9)
      @sprites["s#{j}"].opacity = 255
      @sprites["s#{j}"].color = Color.new(255-rand(32),255-rand(32),255-rand(32))
      bmp.dispose
    end
    self.wait(2.delta(:add))
    # animation after flash
    for i in 0...128.delta(:add)
      @viewport.color.alpha -= 16.delta(:sub)
      for j in 0...24
        next if @sprites["s#{j}"].opacity <= 0
        @sprites["s#{j}"].ox -= (@sprites["s#{j}"].param).delta(:sub)
        @sprites["s#{j}"].opacity -= (@sprites["s#{j}"].param).delta(:sub)
      end
      @sprites["sil"].zoom_x -= 0.0012/(Graphics.frame_rate/40.0)
      @sprites["sil"].zoom_y -= 0.0012/(Graphics.frame_rate/40.0)
      @sprites["sil"].angle += 0.08/(Graphics.frame_rate/40.0) if $PokemonSystem.screensize < 2
      @sprites["let"].angle += 0.1/(Graphics.frame_rate/40.0) if $PokemonSystem.screensize < 2
      @sprites["let"].zoom_x += 0.001/(Graphics.frame_rate/40.0)
      @sprites["let"].zoom_y += 0.001/(Graphics.frame_rate/40.0)
      self.wait
    end
    # scale up silhouette and move logo
    for i in 0...16.delta(:add)
      @sprites["sil"].zoom_x += 1/(Graphics.frame_rate/40.0)
      @sprites["sil"].zoom_y += 1/(Graphics.frame_rate/40.0)
      @sprites["black"].zoom_x += 0.1/(Graphics.frame_rate/40.0)
      @sprites["black"].zoom_y += 0.1/(Graphics.frame_rate/40.0)
      @sprites["let"].x += (@viewport.rect.width/8).delta(:sub)
      self.wait
    end
    @sprites["sil"].visible = false
    @sprites["black"].visible = false
    @sprites["let"].visible = false
    # brings down the logo
    for i in 0...48.delta(:add)
      @scene["logo"].logo.zoom_x -= 0.5/48.delta(:add)
      @scene["logo"].logo.zoom_y -= 0.5/48.delta(:add)
      @scene["logo"].logo.opacity += 255.0/48.delta(:add)
      @scene["logo"].sublogo.zoom_x -= 0.5/48.delta(:add)
      @scene["logo"].sublogo.zoom_y -= 0.5/48.delta(:add)
      @scene["logo"].sublogo.opacity += 255.0/48.delta(:add)
      self.wait
    end
    # final flash
    @viewport.color.alpha = 255
    @scene["logo"].logo.zoom_x = 1
    @scene["logo"].logo.zoom_y = 1
    @scene["logo"].logo.opacity = 255
    @scene["logo"].sublogo.zoom_x = 1
    @scene["logo"].sublogo.zoom_y = 1
    @scene["logo"].sublogo.opacity = 255
    self.wait(2.delta(:add))
    for key in @scene.keys
      @scene[key].visible = true
    end
    32.delta(:add).times do
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#-------------------------------------------------------------------------------
# Wormhole
class MTS_INTRO_ANIM7
  attr_reader :currentFrame
  # animation constructor
  def initialize(viewport,sprites)
    @viewport = viewport
    @scene = sprites
    @sprites = {}
    @skip = false
    @currentFrame = 0
    # prepares the animation
    @x, @y = @scene["logo"].x, @scene["logo"].y
    @scene["logo"].position(@viewport.rect.width/2,@viewport.rect.height/2 + 42)
    @scene["logo"].logo.zoom_x = 0
    @scene["logo"].logo.zoom_y = 0
    @scene["logo"].sublogo.zoom_x = 0
    @scene["logo"].sublogo.zoom_y = 0
    @sprites["black"] = Sprite.new(@viewport)
    @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    @sprites["black"].z = 900
    # warp rays
    for i in 0...24
      @sprites["r#{i}"] = Sprite.new(@viewport)
      @sprites["r#{i}"].opacity = 0
      @sprites["r#{i}"].z = 910
    end
    # shine
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine003")
    @sprites["shine"].center!(true)
    @sprites["shine"].opacity = 0
    @sprites["shine"].zoom_x = 0
    @sprites["shine"].zoom_y = 0
    @sprites["shine"].z = 920
    # plays animation
    self.play
    # disposes animation
    self.dispose
  end
  # function containing the animation
  def play
    for i in 0...64
      # animation for warp rays
      for j in 0...24
        #next if j > i
        if @sprites["r#{j}"].opacity <= 0 && i < 16
          bmp = pbBitmap("Graphics/MODTS/Particles/ray001")
          w = rand(65) + 16
          @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
          @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["r#{j}"].center!
          @sprites["r#{j}"].x = @viewport.rect.width/2
          @sprites["r#{j}"].y = @viewport.rect.height/2
          @sprites["r#{j}"].ox = (@viewport.rect.height/2 + rand(64))
          @sprites["r#{j}"].zoom_x = 1.5
          @sprites["r#{j}"].zoom_y = 1.5
          @sprites["r#{j}"].angle = rand(360)
          @sprites["r#{j}"].param = 2 + rand(5)
          @sprites["r#{j}"].opacity = 255
          bmp.dispose
        end
        @sprites["r#{j}"].ox -= @sprites["r#{j}"].param*16
        @sprites["r#{j}"].zoom_x -= 0.04*@sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_y -= 0.04*@sprites["r#{j}"].param
        @sprites["r#{j}"].opacity -= 16*@sprites["r#{j}"].param
      end
      # animation for shine
      unless i < 8
        k = i < 24 ? 1 : -1
        @sprites["shine"].opacity += 16*k
        @sprites["shine"].zoom_x += 0.01*k if @sprites["shine"].zoom_x < 0.12
        @sprites["shine"].zoom_y += 0.01*k if @sprites["shine"].zoom_y < 0.12
        @sprites["shine"].angle += 2
      end
      # animation for logos
      unless i < 16 || i >= 26
        @scene["logo"].logo.zoom_x += 0.1
        @scene["logo"].logo.zoom_y += 0.1
        @scene["logo"].sublogo.zoom_x += 0.1
        @scene["logo"].sublogo.zoom_y += 0.1
      end
      unless i < 32
        @scene["logo"].logo.color.alpha += 2
        @scene["logo"].sublogo.color.alpha += 2
      end
      @sprites["black"].opacity -= 4 if @sprites["black"].opacity > 192
      self.wait
    end
    # final flash
    @viewport.color = Color.white
    self.wait(2.delta(:add))
    @scene["logo"].position(@x,@y)
    @scene["logo"].logo.color.alpha = 0
    @scene["logo"].sublogo.color.alpha = 0
    pbDisposeSpriteHash(@sprites)
    32.delta(:add).times do
      @viewport.color.alpha -= 16.delta(:sub)
      self.wait
    end
  end
  # function to update all title screen elements (except for logo)
  def updateScene
    for key in @scene.keys
      next if @scene[key].id?("logo")
      @scene[key].update
    end
  end
  # wait frame function (allows for skipping of animation)
  def wait(frames=1,advance=true)
    return false if @skip
    frames.times do
      @currentFrame += 1 if advance
      self.updateScene
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  # dispose function
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  # end
end
#===============================================================================
