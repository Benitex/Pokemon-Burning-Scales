#===============================================================================
#  function used to alter selected graphics based on trainer context
#===============================================================================
def checkForTrainerVariant(files, trainerid, evilteam = false, teamskull = false)
  for i in 0...files.length
    str = sprintf("%s%s", files[i], trainerid.id)
    str = sprintf("%s%03d", files[i], trainerid.id_number) if !pbResolveBitmap(str)
    str2 = sprintf("%s_%s", files[i], trainerid.id)
    str2 = sprintf("%s_%03d", files[i], trainerid.id_number) if !pbResolveBitmap(str2)
    evl = files[i] + "Evil"
    skl = files[i] + "Skull"
    files[i] = evl if pbResolveBitmap(evl) && evilteam
    files[i] = skl if pbResolveBitmap(skl) && teamskull
    files[i] = str if pbResolveBitmap(str)
    files[i] = str2 if pbResolveBitmap(str2)
  end
  return files
end
#===============================================================================
#  New class used to render the Sun & Moon styled VS background
#===============================================================================
class SunMoonDefaultBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @teamskull = teamskull
    @disposed = false
    @speed = 1
    @sprites = {}
    # reverts to default
    files = ["Graphics/EBDX/Transitions/Default/background",
          "Graphics/EBDX/Transitions/Default/layer",
          "Graphics/EBDX/Transitions/Default/final"
         ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the 3 background layers
    for i in 0...3
      @sprites["bg#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["bg#{i}"].setBitmap(files[i], false, (i > 0))
      @sprites["bg#{i}"].z = 200
      @sprites["bg#{i}"].center!(true)
      @sprites["bg#{i}"].angle = - 8 if $PokemonSystem.screensize < 2
      @sprites["bg#{i}"].color = Color.black
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    for i in 0...3
      @sprites["bg#{i}"].speed = val*(i + 1)
    end
  end
  # updates the background
  def update
    return if self.disposed?
    for i in 0...3
      @sprites["bg#{i}"].update
    end
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for i in 0...3
      @sprites["bg#{i}"].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show; end
end
#===============================================================================
#  New class used to render the special Sun & Moon styled VS background
#===============================================================================
class SunMoonSpecialBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    # get files
    files = [
      "Graphics/EBDX/Transitions/Special/background",
      "Graphics/EBDX/Transitions/Special/ring",
      "Graphics/EBDX/Transitions/Special/particle"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background
    @sprites["background"] = RainbowSprite.new(@viewport)
    @sprites["background"].setBitmap(files[0])
    @sprites["background"].color = Color.black
    @sprites["background"].z = 200
    @sprites["background"].center!(true)
    # handles the particles for the animation
    @vsFp = {}
    @fpDx = []
    @fpDy = []
    @fpIndex = 0
    # loads ring effect
    @sprites["ring"] = Sprite.new(@viewport)
    @sprites["ring"].bitmap = pbBitmap(files[1])
    @sprites["ring"].center!
    @sprites["ring"].x = @viewport.width/2
    @sprites["ring"].y = @viewport.height
    @sprites["ring"].zoom_x = 0
    @sprites["ring"].zoom_y = 0
    @sprites["ring"].z = 500
    @sprites["ring"].visible = false
    @sprites["ring"].color = Color.black
    # loads sparkle particles
    for j in 0...32
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap(files[2])
      @sprites["s#{j}"].center!
      @sprites["s#{j}"].opacity = 0
      @sprites["s#{j}"].z = 220
      @sprites["s#{j}"].color = Color.black
      @fpDx.push(0)
      @fpDy.push(0)
    end
    @fpSpeed = []
    @fpOpac = []
    # loads scrolling particles
    for j in 0...3
      k = j+1
      speed = 2 + rand(5)
      @sprites["p#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["p#{j}"].setBitmap("Graphics/EBDX/Transitions/Special/glow#{j}")
      @sprites["p#{j}"].speed = speed*4
      @sprites["p#{j}"].direction = -1
      @sprites["p#{j}"].opacity = 0
      @sprites["p#{j}"].z = 220
      @sprites["p#{j}"].zoom_y = 1 + rand(10)*0.005
      @sprites["p#{j}"].color = Color.black
      @sprites["p#{j}"].center!(true)
      @fpSpeed.push(speed)
      @fpOpac.push(4) if j > 0
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    val = 16 if val > 16
    for j in 0...3
      @sprites["p#{j}"].speed = val*2
    end
  end
  # updates the background
  def update
    return if self.disposed?
    # updates background
    @sprites["background"].update
    # updates ring
    if @sprites["ring"].visible && @sprites["ring"].opacity > 0
      @sprites["ring"].zoom_x += 0.2
      @sprites["ring"].zoom_y += 0.2
      @sprites["ring"].opacity -= 16
    end
    # updates sparkle particles
    for j in 0...32
      next if !@sprites["ring"].visible
      next if !@sprites["s#{j}"] || @sprites["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @sprites["s#{j}"].opacity <= 1
        width = @viewport.width
        height = @viewport.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @sprites["s#{j}"].zoom_x = z
        @sprites["s#{j}"].zoom_y = z
        @sprites["s#{j}"].x = x
        @sprites["s#{j}"].y = y
        @sprites["s#{j}"].opacity = 255
        @sprites["s#{j}"].angle = rand(360)
      end
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @fpDx[j])*0.05
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @fpDy[j])*0.05
      @sprites["s#{j}"].opacity -= @sprites["s#{j}"].opacity*0.05
      @sprites["s#{j}"].zoom_x -= @sprites["s#{j}"].zoom_x*0.05
      @sprites["s#{j}"].zoom_y -= @sprites["s#{j}"].zoom_y*0.05
    end
    # updates scrolling particles
    for j in 0...3
      next if !@sprites["p#{j}"] || @sprites["p#{j}"].disposed?
      @sprites["p#{j}"].update
      if j == 0
        @sprites["p#{j}"].opacity += 5 if @sprites["p#{j}"].opacity < 155
      else
        @sprites["p#{j}"].opacity += @fpOpac[j-1]*(@fpSpeed[j]/2)
      end
      next if @fpIndex < 24
      @fpOpac[j-1] *= -1 if (@sprites["p#{j}"].opacity >= 255 || @sprites["p#{j}"].opacity < 65)
    end
    @fpIndex += 1 if @fpIndex < 150
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for j in 0...3
      @sprites["p#{j}"].visible = true
    end
    @sprites["ring"].visible = true
    @fpIndex = 0
  end
end
#===============================================================================
#  New class used to render the Sun & Moon kahuna VS background
#===============================================================================
class SunMoonEliteBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @fpIndex = 0
    # checks for appropriate files
    bg = ["Graphics/EBDX/Transitions/Elite/background",
          "Graphics/EBDX/Transitions/Elite/vacuum",
          "Graphics/EBDX/Transitions/Elite/shine"
         ]
    # gets specific graphics
    bg = checkForTrainerVariant(bg, trainerid, @evilteam, @teamskull)
    # creates the background
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = pbBitmap(bg[0])
    @sprites["background"].center!(true)
    @sprites["background"].color = Color.black
    @sprites["background"].z = 200
    # creates particles flying out of the center
    for j in 0...16
      @sprites["e#{j}"] = Sprite.new(@viewport)
      bmp = pbBitmap("Graphics/EBDX/Transitions/Elite/particle")
      @sprites["e#{j}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      w = bmp.width/(1 + rand(3))
      @sprites["e#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["e#{j}"].oy = @sprites["e#{j}"].bitmap.height/2
      @sprites["e#{j}"].angle = rand(360)
      @sprites["e#{j}"].opacity = 0
      @sprites["e#{j}"].x = @viewport.width/2
      @sprites["e#{j}"].y = @viewport.height/2
      @sprites["e#{j}"].speed = (4 + rand(5))
      @sprites["e#{j}"].z = 220
      @sprites["e#{j}"].color = Color.black
    end
    # creates vacuum waves
    for j in 0...3
      @sprites["ec#{j}"] = Sprite.new(@viewport)
      @sprites["ec#{j}"].bitmap = pbBitmap(bg[1])
      @sprites["ec#{j}"].center!(true)
      @sprites["ec#{j}"].zoom_x = 1.5
      @sprites["ec#{j}"].zoom_y = 1.5
      @sprites["ec#{j}"].opacity = 0
      @sprites["ec#{j}"].z = 205
      @sprites["ec#{j}"].color = Color.black
    end
    # creates center glow
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(bg[2])
    @sprites["shine"].center!(true)
    @sprites["shine"].z = 210
    @sprites["shine"].visible = false
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    # background and shine
    @sprites["background"].angle += 1 if $PokemonSystem.screensize < 2
    @sprites["shine"].angle -= 1 if $PokemonSystem.screensize < 2
    # updates (and resets) the particles flying from the center
    for j in 0...16
      next if !@sprites["shine"].visible
      if @sprites["e#{j}"].ox < -(@sprites["e#{j}"].viewport.width/2)
        @sprites["e#{j}"].speed = 4 + rand(5)
        @sprites["e#{j}"].opacity = 0
        @sprites["e#{j}"].ox = 0
        @sprites["e#{j}"].angle = rand(360)
        bmp = pbBitmap("Graphics/EBDX/Transitions/Elite/particle")
        @sprites["e#{j}"].bitmap.clear
        w = bmp.width/(1 + rand(3))
        @sprites["e#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      end
      @sprites["e#{j}"].opacity += @sprites["e#{j}"].speed
      @sprites["e#{j}"].ox -=  @sprites["e#{j}"].speed
    end
    # updates the vacuum waves
    for j in 0...3
      next if j > @fpIndex/50
      if @sprites["ec#{j}"].zoom_x <= 0
        @sprites["ec#{j}"].zoom_x = 1.5
        @sprites["ec#{j}"].zoom_y = 1.5
        @sprites["ec#{j}"].opacity = 0
      end
      @sprites["ec#{j}"].opacity +=  8
      @sprites["ec#{j}"].zoom_x -= 0.01
      @sprites["ec#{j}"].zoom_y -= 0.01
    end
    @fpIndex += 1 if @fpIndex < 150
  end
  # used to show other elements
  def show
    @sprites["shine"].visible = true
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end

end
#===============================================================================
#  New class used to render the Mother Beast Lusamine styled VS background
#===============================================================================
class SunMoonCrazyBackground
  attr_accessor :speed
  # main method to create the background
  def initialize(viewport,trainerid,evilteam=false,teamskull=false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    # draws a black backdrop
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].create_rect(@viewport.width,@viewport.height,Color.black)
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.black
    # draws the 3 circular patterns that change hue
    for j in 0...3
      @sprites["b#{j}"] = RainbowSprite.new(@viewport)
      @sprites["b#{j}"].setBitmap("Graphics/EBDX/Transitions/Crazy/ring#{j}",8)
      @sprites["b#{j}"].center!(true)
      @sprites["b#{j}"].zoom_x = 0.6 + 0.6*j
      @sprites["b#{j}"].zoom_y = 0.6 + 0.6*j
      @sprites["b#{j}"].opacity = 64 + 64*(1+j)
      @sprites["b#{j}"].z = 250
      @sprites["b#{j}"].color = Color.black
    end
    # draws all the particles
    for j in 0...64
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].z = 300
      width = 16 + rand(48)
      height = 16 + rand(16)
      @sprites["p#{j}"].bitmap = Bitmap.new(width,height)
      bmp = pbBitmap("Graphics/EBDX/Transitions/Crazy/particle")
      @sprites["p#{j}"].bitmap.stretch_blt(Rect.new(0,0,width,height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["p#{j}"].bitmap.hue_change(rand(360))
      @sprites["p#{j}"].ox = width/2
      @sprites["p#{j}"].oy = height + 192 + rand(32)
      @sprites["p#{j}"].angle = rand(360)
      @sprites["p#{j}"].speed = 1 + rand(4)
      @sprites["p#{j}"].x = @viewport.width/2
      @sprites["p#{j}"].y = @viewport.height/2
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].color = Color.black
    end
    @frame = 0
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    # updates the 3 circular patterns changing their hue
    for j in 0...3
      @sprites["b#{j}"].zoom_x -= 0.025
      @sprites["b#{j}"].zoom_y -= 0.025
      @sprites["b#{j}"].opacity -= 4
      if @sprites["b#{j}"].zoom_x <= 0 || @sprites["b#{j}"].opacity <= 0
        @sprites["b#{j}"].zoom_x = 2.25
        @sprites["b#{j}"].zoom_y = 2.25
        @sprites["b#{j}"].opacity = 255
      end
      @sprites["b#{j}"].update if @frame%8==0
    end
    # animates all the particles
    for j in 0...64
      @sprites["p#{j}"].angle -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].opacity -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].oy -= @sprites["p#{j}"].speed/2 if @sprites["p#{j}"].oy > @sprites["p#{j}"].bitmap.height
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
      if @sprites["p#{j}"].zoom_x <= 0 || @sprites["p#{j}"].oy <= 0 || @sprites["p#{j}"].opacity <= 0
        @sprites["p#{j}"].angle = rand(360)
        @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height + 192 + rand(32)
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/192.0)*1.5
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].speed = 1 + rand(4)
      end
    end
    @frame += 1
    @frame = 0 if @frame > 128
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show; end

end
#===============================================================================
#  New class used to render the ultra squad Sun & Moon styled VS background
#===============================================================================
class SunMoonUltraBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @fpIndex = 0
    @sprites = {}
    # allows for custom graphics as well
    files = ["Graphics/EBDX/Transitions/Ultra/background",
             "Graphics/EBDX/Transitions/Ultra/overlay",
             "Graphics/EBDX/Transitions/Ultra/shine",
             "Graphics/EBDX/Transitions/Ultra/ring",
             "Graphics/EBDX/Transitions/Ultra/particle"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background layer
    @sprites["background"] = RainbowSprite.new(@viewport)
    @sprites["background"].setBitmap(files[0],2)
    @sprites["background"].color = Color.black
    @sprites["background"].z = 200
    @sprites["background"].center!(true)
    @sprites["paths"] = RainbowSprite.new(@viewport)
    @sprites["paths"].setBitmap(files[1],2)
    @sprites["paths"].center!(true)
    @sprites["paths"].color = Color.black
    @sprites["paths"].z = 200
    @sprites["paths"].opacity = 215
    @sprites["paths"].toggle = 1
    @sprites["paths"].visible = false
    # creates the shine effect
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[2])
    @sprites["shine"].center!(true)
    @sprites["shine"].color = Color.black
    @sprites["shine"].z = 200
    # creates the hexagonal zoom patterns
    for i in 0...12
      @sprites["h#{i}"] = Sprite.new(@viewport)
      @sprites["h#{i}"].bitmap = pbBitmap(files[3])
      @sprites["h#{i}"].center!(true)
      @sprites["h#{i}"].color = Color.black
      @sprites["h#{i}"].z = 220
      z = 1
      @sprites["h#{i}"].zoom_x = z
      @sprites["h#{i}"].zoom_y = z
      @sprites["h#{i}"].opacity = 255
    end
    for i in 0...16
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[4])
      @sprites["p#{i}"].oy = @sprites["p#{i}"].bitmap.height/2
      @sprites["p#{i}"].x = @viewport.width/2
      @sprites["p#{i}"].y = @viewport.height/2
      @sprites["p#{i}"].angle = rand(360)
      @sprites["p#{i}"].color = Color.black
      @sprites["p#{i}"].z = 210
      @sprites["p#{i}"].visible = false
    end
    160.times do
      self.update(true)
    end
  end
  # sets the speed of the sprites
  def speed=(val)
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    if !skip
      @sprites["background"].update
      @sprites["shine"].angle -= 1 if $PokemonSystem.screensize < 2
      @sprites["paths"].update
      @sprites["paths"].opacity -= @sprites["paths"].toggle*2
      @sprites["paths"].toggle *= -1 if @sprites["paths"].opacity <= 85 || @sprites["paths"].opacity >= 215
    end
    for i in 0...12
      next if i > @fpIndex/32
      if @sprites["h#{i}"].opacity <= 0
        @sprites["h#{i}"].zoom_x = 1
        @sprites["h#{i}"].zoom_y = 1
        @sprites["h#{i}"].opacity = 255
      end
      @sprites["h#{i}"].zoom_x += 0.003*(@sprites["h#{i}"].zoom_x**2)
      @sprites["h#{i}"].zoom_y += 0.003*(@sprites["h#{i}"].zoom_y**2)
      @sprites["h#{i}"].opacity -= 1
    end
    for i in 0...16
      next if i > @fpIndex/8
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].ox = 0
        @sprites["p#{i}"].angle = rand(360)
        @sprites["p#{i}"].zoom_x = 1
        @sprites["p#{i}"].zoom_y = 1
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 2
      @sprites["p#{i}"].ox -= 4
      @sprites["p#{i}"].zoom_x += 0.001
      @sprites["p#{i}"].zoom_y += 0.001
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for i in 0...16
      @sprites["p#{i}"].visible = true
    end
    @sprites["paths"].visible = true
  end
end
#===============================================================================
#  New class used to render a custom Sun & Moon styled VS background
#===============================================================================
class SunMoonDigitalBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    # allows for custom graphics as well
    files = ["Graphics/EBDX/Transitions/Digital/background",
             "Graphics/EBDX/Transitions/Digital/particle",
             "Graphics/EBDX/Transitions/Digital/shine"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.black
    @sprites["bg"].center!(true)
    for i in 0...16
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[1])
      @sprites["p#{i}"].z = 205
      @sprites["p#{i}"].color = Color.black
      @sprites["p#{i}"].oy = @sprites["p#{i}"].bitmap.height/2
      @sprites["p#{i}"].x = @viewport.width/2
      @sprites["p#{i}"].y = @viewport.height/2
      @sprites["p#{i}"].angle = rand(16)*22.5
      @sprites["p#{i}"].visible = false
    end
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[2])
    @sprites["shine"].center!
    @sprites["shine"].x = @viewport.width/2
    @sprites["shine"].y = @viewport.height/2
    @sprites["shine"].color = Color.black
    @sprites["shine"].z = 210
    @sprites["shine"].toggle = 1
    # draws all the little tiles
    tile_size = 32.0
    opacity = 25
    offset = 2
    @x = (@viewport.width/tile_size).ceil
    @y = (@viewport.height/tile_size).ceil
    for i in 0...@x
      for j in 0...@y
        sprite = Sprite.new(@viewport)
        sprite.bitmap = Bitmap.new(tile_size,tile_size)
        sprite.bitmap.fill_rect(offset,offset,tile_size-offset*2,tile_size-offset*2,Color.new(255,255,255,opacity))
        sprite.x = i * tile_size
        sprite.y = j * tile_size
        sprite.color = Color.black
        sprite.visible = false
        sprite.z = 220
        o = opacity + rand(156)
        sprite.opacity = 0
        @tiles.push(sprite)
        @data.push([o,rand(5)+4])
      end
    end
  end
  # sets the speed of the sprites
  def speed=(val)
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    for i in 0...@tiles.length
      @tiles[i].opacity += @data[i][1]
      @data[i][1] *= -1 if @tiles[i].opacity <= 0 || @tiles[i].opacity >= @data[i][0]
    end
    for i in 0...16
      next if i > @fpIndex/16
      if @sprites["p#{i}"].ox < - @viewport.width/2
        @sprites["p#{i}"].angle = rand(16)*22.5
        @sprites["p#{i}"].ox = 0
        @sprites["p#{i}"].opacity = 255
        @sprites["p#{i}"].zoom_x = 1
        @sprites["p#{i}"].zoom_y = 1
      end
      @sprites["p#{i}"].zoom_x += 0.001
      @sprites["p#{i}"].zoom_y += 0.001
      @sprites["p#{i}"].opacity -= 4
      @sprites["p#{i}"].ox -= 4
    end
    @sprites["shine"].zoom_x += 0.04*@sprites["shine"].toggle
    @sprites["shine"].zoom_y += 0.04*@sprites["shine"].toggle
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 1 || @sprites["shine"].zoom_x >= 1.4
    @fpIndex += 1 if @fpIndex < 256
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for tile in @tiles
      tile.color.alpha -= factor
    end
    for key in @sprites.keys
      next if key == "bg"
      @sprites[key].color.alpha -= factor
    end
    self.update
  end
  # disposes of everything
  def dispose
    @disposed = true
    for tile in @tiles
      tile.dispose
    end
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for i in 0...16
      @sprites["p#{i}"].visible = true
    end
    for tile in @tiles
      tile.visible = true
    end
    @sprites["bg"].color.alpha = 0
  end
end
#===============================================================================
#  New class used to render a custom Sun & Moon styled VS background
#===============================================================================
class SunMoonPlasmaBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    # allows for custom graphics as well
    files = ["Graphics/EBDX/Transitions/Plasma/background",
             "Graphics/EBDX/Transitions/Plasma/beam",
             "Graphics/EBDX/Transitions/Plasma/streaks",
             "Graphics/EBDX/Transitions/Plasma/shine",
             "Graphics/EBDX/Transitions/Plasma/particle"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.black
    @sprites["bg"].center!(true)
    # creates plasma beam
    for i in 0...2
      @sprites["beam#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["beam#{i}"].setBitmap(files[i+1])
      @sprites["beam#{i}"].speed = [32,48][i]
      @sprites["beam#{i}"].center!
      @sprites["beam#{i}"].x = @viewport.width/2
      @sprites["beam#{i}"].y = @viewport.height/2 - 16
      @sprites["beam#{i}"].zoom_y = 0
      @sprites["beam#{i}"].z = 210
      @sprites["beam#{i}"].color = Color.black
    end
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[3])
    @sprites["shine"].center!
    @sprites["shine"].x = @viewport.width
    @sprites["shine"].y = @viewport.height/2 - 16
    @sprites["shine"].z = 220
    @sprites["shine"].visible = false
    @sprites["shine"].toggle = 1
    for i in 0...32
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[4])
      @sprites["p#{i}"].center!
      @sprites["p#{i}"].opacity = 0
      @sprites["p#{i}"].z = 215
      @sprites["p#{i}"].visible = false
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    @speed = val
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["shine"].angle += 8 if $PokemonSystem.screensize < 2
    @sprites["shine"].zoom_x -= 0.04*@sprites["shine"].toggle
    @sprites["shine"].zoom_y -= 0.04*@sprites["shine"].toggle
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 0.8 || @sprites["shine"].zoom_x >= 1.2
    for i in 0...2
      @sprites["beam#{i}"].update
    end
    for i in 0...32
      next if i > @fpIndex/4
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].x = @sprites["shine"].x
        @sprites["p#{i}"].y = @sprites["shine"].y
        r = 256 + rand(129)
        cx, cy = randCircleCord(r)
        @sprites["p#{i}"].ex = @sprites["shine"].x - (cx - r).abs
        @sprites["p#{i}"].ey = @sprites["shine"].y - r/2 + cy/2
        z = 0.4 + rand(7)/10.0
        @sprites["p#{i}"].zoom_x = z
        @sprites["p#{i}"].zoom_y = z
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 8
      @sprites["p#{i}"].x -= (@sprites["p#{i}"].x - @sprites["p#{i}"].ex)*0.1
      @sprites["p#{i}"].y -= (@sprites["p#{i}"].y - @sprites["p#{i}"].ey)*0.1
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      next if key == "bg"
      @sprites[key].color.alpha -= factor
    end
    for i in 0...2
      @sprites["beam#{i}"].zoom_y += 0.1 if @sprites["beam#{i}"].color.alpha <= 164 && @sprites["beam#{i}"].zoom_y < 1
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    @sprites["bg"].color.alpha = 0
    for key in @sprites.keys
      @sprites[key].visible = true
    end
  end
end
#===============================================================================
#  New class used to render a custom Sun & Moon styled VS background
#===============================================================================
class SunMoonGoldBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    # allows for custom graphics as well
    files = ["Graphics/EBDX/Transitions/Gold/background",
             "Graphics/EBDX/Transitions/Gold/swirl",
             "Graphics/EBDX/Transitions/Gold/particleA"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.black
    @sprites["bg"].center!(true)

    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(files[1])
    @sprites["shine"].center!(true)
    @sprites["shine"].z = 210
    @sprites["shine"].toggle = 1
    for i in 0...32
      @sprites["p#{i}"] = Sprite.new(@viewport)
      @sprites["p#{i}"].bitmap = pbBitmap(files[2])
      @sprites["p#{i}"].center!
      @sprites["p#{i}"].opacity = 0
      @sprites["p#{i}"].z = 215
      @sprites["p#{i}"].visible = false
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    @speed = val
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["shine"].angle += 2 if $PokemonSystem.screensize < 2
    @sprites["shine"].zoom_x -= 0.005*@sprites["shine"].toggle
    @sprites["shine"].zoom_y -= 0.005*@sprites["shine"].toggle
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 0.9 || @sprites["shine"].zoom_x >= 1.1
    for i in 0...32
      next if i > @fpIndex/4
      if @sprites["p#{i}"].opacity <= 0
        @sprites["p#{i}"].x = @sprites["shine"].x
        @sprites["p#{i}"].y = @sprites["shine"].y
        r = 192 + rand(64)
        cx, cy = randCircleCord(r)
        @sprites["p#{i}"].ex = @sprites["shine"].x - (cx - r)
        @sprites["p#{i}"].ey = @sprites["shine"].y - r/2 + cy/2
        z = 0.8 + rand(7)/10.0
        @sprites["p#{i}"].zoom_x = z
        @sprites["p#{i}"].zoom_y = z
        @sprites["p#{i}"].opacity = 255
      end
      @sprites["p#{i}"].opacity -= 6
      @sprites["p#{i}"].x -= (@sprites["p#{i}"].x - @sprites["p#{i}"].ex)*0.08
      @sprites["p#{i}"].y -= (@sprites["p#{i}"].y - @sprites["p#{i}"].ey)*0.08
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      @sprites[key].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for key in @sprites.keys
      @sprites[key].visible = true
    end
  end
end
#===============================================================================
#  New class used to render a custom Sun & Moon styled VS background
#===============================================================================
class SunMoonCrystalBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    @fpIndex = 0
    @fpDx = []
    @fpDy = []
    # allows for custom graphics as well
    files = ["Graphics/EBDX/Transitions/Crystal/background",
             "Graphics/EBDX/Transitions/Crystal/overlay"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(files[0])
    @sprites["bg"].z = 200
    @sprites["bg"].color = Color.black
    @sprites["bg"].center!(true)
    # creates overlay
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = pbBitmap(files[1])
    @sprites["overlay"].z = 200
    @sprites["overlay"].color = Color.black
    @sprites["overlay"].visible = false
    @sprites["overlay"].opacity = 0
    @sprites["overlay"].toggle = 1
    @sprites["overlay"].center!(true)
    # draws the crystalline shine
    for i in 1..26
      o = i < 10 ? 64 : 128
      @sprites["c#{i}"] = Sprite.new(@viewport)
      bmp = pbBitmap(sprintf("Graphics/EBDX/Transitions/Crystal/cr%03d",i))
      @sprites["c#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["c#{i}"].bitmap.blt(0,0,bmp,bmp.rect,o-rand(64))
      bmp.dispose
      @sprites["c#{i}"].opacity = 0
      @sprites["c#{i}"].toggle = 1
      @sprites["c#{i}"].speed = 1 + rand(4)
      @sprites["c#{i}"].param = 128 - rand(92)
      @sprites["c#{i}"].end_y = rand(32)
      @sprites["c#{i}"].z = 200
      @sprites["c#{i}"].center!(true)
    end
    # loads sparkle particles
    for j in 0...32
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Crystal/particle")
      @sprites["s#{j}"].ox = @sprites["s#{j}"].bitmap.width/2
      @sprites["s#{j}"].oy = @sprites["s#{j}"].bitmap.height/2
      @sprites["s#{j}"].opacity = 0
      @sprites["s#{j}"].z = 220
      @sprites["s#{j}"].color = Color.black
      @sprites["s#{j}"].visible = false
      @fpDx.push(0)
      @fpDy.push(0)
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    @speed = val
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @speed = 16 if @speed > 16
    # updates overlay
    @sprites["overlay"].opacity += 4*@sprites["overlay"].toggle
    @sprites["overlay"].toggle *= -1 if @sprites["overlay"].opacity <= 0 || @sprites["overlay"].opacity >= 255
    # updates crystal particles
    for i in 1..26
      next if @fpIndex < @sprites["c#{i}"].end_y
      @sprites["c#{i}"].opacity += @sprites["c#{i}"].toggle*@sprites["c#{i}"].speed*(@speed/4)
      @sprites["c#{i}"].toggle *= -1 if @sprites["c#{i}"].opacity <= 0 || @sprites["c#{i}"].opacity >= @sprites["c#{i}"].param
    end
    # updates sparkle particles
    for j in 0...32
      next if !@sprites["s#{j}"] || @sprites["s#{j}"].disposed?
      next if j > @fpIndex/4
      if @sprites["s#{j}"].opacity <= 1
        width = @viewport.width
        height = @viewport.height
        x = rand(width*0.75) + width*0.125
        y = rand(height*0.50) + height*0.25
        @fpDx[j] = x + rand(width*0.125)*(x < width/2 ? -1 : 1)
        @fpDy[j] = y - rand(height*0.25)
        z = [1,0.75,0.5,0.25][rand(4)]
        @sprites["s#{j}"].zoom_x = z
        @sprites["s#{j}"].zoom_y = z
        @sprites["s#{j}"].x = x
        @sprites["s#{j}"].y = y
        @sprites["s#{j}"].opacity = 255
        @sprites["s#{j}"].angle = rand(360)
      end
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @fpDx[j])*0.05
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @fpDy[j])*0.05
      @sprites["s#{j}"].opacity -= @sprites["s#{j}"].opacity*0.05
      @sprites["s#{j}"].zoom_x -= @sprites["s#{j}"].zoom_x*0.05
      @sprites["s#{j}"].zoom_y -= @sprites["s#{j}"].zoom_y*0.05
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for key in @sprites.keys
      next if key == "bg"
      @sprites[key].color.alpha -= factor
    end
    self.update
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    @sprites["bg"].color.alpha = 0
    @sprites["overlay"].visible = true
    for j in 0...32
      @sprites["s#{j}"].visible = true
    end
  end
end
#===============================================================================
#  New class used to render the Sun & Moon styled VS background
#===============================================================================
class SunMoonSpaceBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @teamskull = teamskull
    @disposed = false
    @speed = 1
    @sprites = {}
    # reverts to default
    files = [
      "Graphics/EBDX/Transitions/Space/background"
    ]
    # gets specific graphics
    files = checkForTrainerVariant(files, trainerid, @evilteam, @teamskull)
    # creates the background
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = pbBitmap(files[0])
    @sprites["bg1"].color = Color.black
    @sprites["bg1"].z = 200
    @sprites["bg1"].center!(true)
    # creates all the star particles
    for i in 0...64
      @sprites["s#{i}"] = Sprite.new(@viewport)
      @sprites["s#{i}"].bitmap = pbBitmap(sprintf("Graphics/EBDX/Transitions/Space/star%03d",rand(6)+1))
      @sprites["s#{i}"].center!
      zm = [0.4,0.4,0.5,0.6,0.7][rand(5)]
      @sprites["s#{i}"].zoom_x = zm
      @sprites["s#{i}"].zoom_y = zm
      @sprites["s#{i}"].x = rand(@viewport.width + 1)
      @sprites["s#{i}"].y = rand(@viewport.height + 1)
      o = 85 + rand(130)
      s = 2 + rand(4)
      @sprites["s#{i}"].speed = s
      @sprites["s#{i}"].toggle = 1
      @sprites["s#{i}"].param = o
      @sprites["s#{i}"].opacity = o
      @sprites["s#{i}"].z = 200
      @sprites["s#{i}"].visible = false
    end
    # initializes particles
    @sprites["shine2"] = Sprite.new(@viewport)
    @sprites["shine2"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Space/shine002")
    @sprites["shine2"].center!(true)
    @sprites["shine2"].z = 200
    @sprites["shine2"].toggle = 1
    @sprites["shine2"].speed = 1
    # initializes particles
    for j in 0...16
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Space/shine001")
      @sprites["p#{j}"].center!(true)
      @sprites["p#{j}"].z = 200
      x, y = randCircleCord(256)
      p = rand(100)
      @sprites["p#{j}"].end_x = @sprites["p#{j}"].x - 256 + x
      @sprites["p#{j}"].end_y = @sprites["p#{j}"].y - 256 + y
      @sprites["p#{j}"].x -= (@sprites["p#{j}"].x - @sprites["p#{j}"].end_x)*(p/100.0)
      @sprites["p#{j}"].y -= (@sprites["p#{j}"].y - @sprites["p#{j}"].end_y)*(p/100.0)
      @sprites["p#{j}"].speed = 4
      @sprites["p#{j}"].opacity = 255 - 255*(p/100.0)
    end
  end
  # sets the speed of the sprites
  def speed=(val)
    @sprites["shine2"].speed = val/4
  end
  # updates the background
  def update
    return if self.disposed?
    # updates star particles
    for i in 0...64
      @sprites["s#{i}"].opacity += @sprites["s#{i}"].speed*@sprites["s#{i}"].toggle
      if @sprites["s#{i}"].opacity > @sprites["s#{i}"].param || @sprites["s#{i}"].opacity < 10
        @sprites["s#{i}"].toggle *= -1
      end
    end
    # updates particle effect
    for j in 0...16
      if @sprites["p#{j}"].opacity == 0
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].center!(true)
        x, y = randCircleCord(256)
        @sprites["p#{j}"].end_x = @sprites["p#{j}"].x - 256 + x
        @sprites["p#{j}"].end_y = @sprites["p#{j}"].y - 256 + y
      end
      @sprites["p#{j}"].x -= (@sprites["p#{j}"].x - @sprites["p#{j}"].end_x)*0.01*@sprites["p#{j}"].speed
      @sprites["p#{j}"].y -= (@sprites["p#{j}"].y - @sprites["p#{j}"].end_y)*0.01*@sprites["p#{j}"].speed
      @sprites["p#{j}"].opacity -= 2*@sprites["p#{j}"].speed
    end
    # updates particle effect
    @sprites["shine2"].toggle *= -1 if @sprites["shine2"].zoom_x >= 1.16 || @sprites["shine2"].zoom_x <= 0.84
    @sprites["shine2"].zoom_x += 0.005*@sprites["shine2"].toggle*@sprites["shine2"].speed
    @sprites["shine2"].zoom_y += 0.005*@sprites["shine2"].toggle*@sprites["shine2"].speed
  end
  # used to fade in from black
  def reduceAlpha(factor)
    @sprites["bg1"].color.alpha -= factor
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    for i in 0...64
      @sprites["s#{i}"].visible = true
    end
  end
end
#===============================================================================
#  New class used to render the Sun & Moon styled VS background
#===============================================================================
class SunMoonForestBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @teamskull = teamskull
    @disposed = false
    @speed = 1
    @fpIndex = 0
    @sprites = {}
    # reverts to default
    # reverts to default
    bg = ["Graphics/EBDX/Transitions/Forest/background",
          "Graphics/EBDX/Transitions/Forest/overlay",
          "Graphics/EBDX/Transitions/Forest/glow",
          "Graphics/EBDX/Transitions/Forest/radial",
          "Graphics/EBDX/Transitions/Forest/shine",
          "Graphics/EBDX/Transitions/Forest/ray"
         ]
    # gets specific graphics
    bg = checkForTrainerVariant(bg, trainerid, @evilteam, @teamskull)
    # creates the background
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = pbBitmap(bg[0])
    @sprites["bg1"].color = Color.black
    @sprites["bg1"].z = 200
    @sprites["bg1"].center!(true)
    # creates glow
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap(bg[2])
    @sprites["glow"].color = Color.black
    @sprites["glow"].toggle = 1
    @sprites["glow"].z = 200
    @sprites["glow"].center!(true)
    # creates spinning element
    @sprites["rad"] = Sprite.new(@viewport)
    @sprites["rad"].bitmap = pbBitmap(bg[3])
    @sprites["rad"].center!(true)
    #@sprites["rad"].color = Color.black
    @sprites["rad"].z = 200
    # creates the overlay
    @sprites["ol1"] = Sprite.new(@viewport)
    @sprites["ol1"].bitmap = pbBitmap(bg[1])
    @sprites["ol1"].z = 202
    @sprites["ol1"].visible = false
    @sprites["ol1"].center!(true)
    # initializes particles
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(bg[4])
    @sprites["shine"].center!(true)
    @sprites["shine"].z = 200
    # initializes light rays
    rangle = []
    for i in 0...8; rangle.push((360/8)*i +  15); end
    for j in 0...8
      @sprites["r#{j}"] = Sprite.new(@viewport)
      @sprites["r#{j}"].bitmap = pbBitmap(bg[5])
      @sprites["r#{j}"].ox = 0
      @sprites["r#{j}"].oy = @sprites["r#{j}"].bitmap.height/2
      @sprites["r#{j}"].opacity = 0
      @sprites["r#{j}"].zoom_x = 0
      @sprites["r#{j}"].zoom_y = 0
      @sprites["r#{j}"].x = @viewport.width/2
      @sprites["r#{j}"].y = @viewport.height/2
      a = rand(rangle.length)
      @sprites["r#{j}"].angle = rangle[a]
      @sprites["r#{j}"].z = 200
      @sprites["r#{j}"].visible = false
      rangle.delete_at(a)
    end
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    # updates the rays
    for j in 0...8
      next if j > @fpIndex/8
      if @sprites["r#{j}"].opacity == 0
        @sprites["r#{j}"].opacity = 255
        @sprites["r#{j}"].zoom_x = 0
        @sprites["r#{j}"].zoom_y = 0
      end
      @sprites["r#{j}"].opacity -= 3
      @sprites["r#{j}"].zoom_x += 0.02
      @sprites["r#{j}"].zoom_y += 0.02
    end
    # updates particle effect
    @sprites["shine"].angle -= 1 if $PokemonSystem.screensize < 2
    # bg animation
    @sprites["rad"].angle += 1 if $PokemonSystem.screensize < 2
    @sprites["glow"].opacity -= @sprites["glow"].toggle
    @sprites["glow"].toggle *= -1 if @sprites["glow"].opacity <= 125 || @sprites["glow"].opacity >= 255
    @fpIndex += 1 if @fpIndex < 256
  end
  # used to fade in from black
  def reduceAlpha(factor)
    @sprites["bg1"].color.alpha -= factor
    @sprites["glow"].color.alpha -= factor
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    @sprites["ol1"].visible = true
    for j in 0...8
      @sprites["r#{j}"].visible = true
    end
    @sprites["shine"].visible = true
  end
end
#===============================================================================
#  New class used to render the Sun & Moon styled VS background
#===============================================================================
class SunMoonWavesBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @teamskull = teamskull
    @disposed = false
    @reveal = false
    @speed = 1
    @sprites = {}
    # reverts to default
    bg = ["Graphics/EBDX/Transitions/Waves/waves1",
          "Graphics/EBDX/Transitions/Waves/waves2",
          "Graphics/EBDX/Transitions/Waves/waves3",
          "Graphics/EBDX/Transitions/Waves/background"
         ]
    # gets specific graphics
    bg = checkForTrainerVariant(bg, trainerid, @evilteam, @teamskull)
    # create background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(bg[3])
    @sprites["bg"].color = Color.new(0, 0, 0, 160)
    @sprites["bg"].z = 200
    @sprites["bg"].center!(true)
    # creates the 3 wave layers
    for i in 0...3
      @sprites["w#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["w#{i}"].direction = 1 * (i%2 == 0 ? 1 : -1)
      @sprites["w#{i}"].speed = 6 + 4*(i)
      @sprites["w#{i}"].setBitmap(bg[i])
      @sprites["w#{i}"].z = 210
      @sprites["w#{i}"].center!(true)
      @sprites["w#{i}"].color = Color.black
    end
    # create bubbles
    for i in 0...18
      @sprites["b#{i}"] = Sprite.new(@viewport)
      @sprites["b#{i}"].z = 205
      @sprites["b#{i}"].y = -32
    end
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    for i in 0...3
      @sprites["w#{i}"].update
    end
    return if !@reveal
    for i in 0...18
      if @sprites["b#{i}"].y <= -32
        r = rand(12)
        @sprites["b#{i}"].bitmap = Bitmap.new(16 + r*4, 16 + r*4)
        @sprites["b#{i}"].bitmap.bmp_circle
        @sprites["b#{i}"].center!
        @sprites["b#{i}"].y = @viewport.height + 32
        @sprites["b#{i}"].x = 32 + rand(@viewport.width - 64)
        @sprites["b#{i}"].ex = @sprites["b#{i}"].x
        @sprites["b#{i}"].toggle = rand(2) == 0 ? 1 : -1
        @sprites["b#{i}"].speed = 1 + 10/((r + 1)*0.4)
        @sprites["b#{i}"].opacity = 32 + rand(65)
      end
      min = @viewport.height/4
      max = @viewport.height/2
      scale = (2*Math::PI)/((@sprites["b#{i}"].bitmap.width/64.0)*(max - min) + min)
      @sprites["b#{i}"].y -= @sprites["b#{i}"].speed
      @sprites["b#{i}"].x = @sprites["b#{i}"].ex + @sprites["b#{i}"].bitmap.width*0.25*Math.sin(@sprites["b#{i}"].y*scale)*@sprites["b#{i}"].toggle
    end
  end
  # used to fade in from black
  def reduceAlpha(factor)
    for i in 0...3
      @sprites["w#{i}"].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    @sprites["bg"].color.alpha = 0
    @reveal = true
  end
end
#===============================================================================
#  New class used to render the Sun & Moon styled VS background
#===============================================================================
class SunMoonFlamesBackground
  attr_reader :speed
  # main method to create the background
  def initialize(viewport, trainerid, evilteam = false, teamskull = false)
    @viewport = viewport
    @trainerid = trainerid
    @evilteam = evilteam
    @teamskull = teamskull
    @disposed = false
    @reveal = false
    @speed = 1
    @frame = 0
    @fpIndex = 0
    @sprites = {}
    # reverts to default
    bg = ["Graphics/EBDX/Transitions/Flames/fire",
          "Graphics/EBDX/Transitions/Flames/streak",
          "Graphics/EBDX/Transitions/Flames/background",
          "Graphics/EBDX/Transitions/Flames/overlay"
         ]
    # gets specific graphics
    bg = checkForTrainerVariant(bg, trainerid, @evilteam, @teamskull)
    # create background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(bg[2])
    @sprites["bg"].color = Color.new(0, 0, 0, 160)
    @sprites["bg"].z = 200
    @sprites["bg"].center!(true)
    @sprites["ol"] = Sprite.new(@viewport)
    @sprites["ol"].bitmap = pbBitmap(bg[3])
    @sprites["ol"].color = Color.black
    @sprites["ol"].z = 220
    @sprites["ol"].center!(true)
    # create streak
    @sprites["st"] = Sprite.new(@viewport)
    @sprites["st"].bitmap = pbBitmap(bg[1])
    @sprites["st"].z = 220
    @sprites["st"].visible = false
    @sprites["st"].center!(true)
    # create fire particles
    @amt = @viewport.rect.width/32 + 1
    for k in 0...@amt*2
      i = (@amt*2 - 1) - k
      @sprites["f#{i}"] = Sprite.new(@viewport)
      @sprites["f#{i}"].bitmap = pbBitmap(bg[0])
      @sprites["f#{i}"].src_rect.width /= 4
      @sprites["f#{i}"].src_rect.x = rand(4)*@sprites["f#{i}"].src_rect.width
      @sprites["f#{i}"].ox = @sprites["f#{i}"].src_rect.width/2
      @sprites["f#{i}"].x = 32*(i%@amt)
      @sprites["f#{i}"].y = @viewport.height - 108
      @sprites["f#{i}"].param = rand(@amt*2)
      @sprites["f#{i}"].color = Color.black
      @sprites["f#{i}"].speed = 8
      @sprites["f#{i}"].toggle = 2
      if i >= @amt
        @sprites["f#{i}"].x += 16
        @sprites["f#{i}"].opacity = 164 - rand(33)
        @sprites["f#{i}"].z = 210
      else
        @sprites["f#{i}"].src_rect.height -= 8
        @sprites["f#{i}"].z = 210 - rand(2)
      end
      @sprites["f#{i}"].oy = @sprites["f#{i}"].src_rect.height
      @sprites["f#{i}"].zoom_y = 0.6 + rand(41)/100.0
    end
  end
  # sets the speed of the sprites
  def speed=(val); end
  # updates the background
  def update
    return if self.disposed?
    @sprites["st"].x += 32
    @sprites["st"].x = -@viewport.width if @sprites["st"].x > @viewport.width*8
    # updates fire particles
    @frame += 1
    for i in 0...@amt*2
      next if @frame < 3
      @sprites["f#{i}"].src_rect.x += @sprites["f#{i}"].src_rect.width
      @sprites["f#{i}"].src_rect.x = 0 if @sprites["f#{i}"].src_rect.x >= @sprites["f#{i}"].bitmap.width
      next if @sprites["f#{i}"].param > @fpIndex/2
      @sprites["f#{i}"].color.alpha += @sprites["f#{i}"].toggle*@sprites["f#{i}"].speed if @reveal
      @sprites["f#{i}"].zoom_y += @sprites["f#{i}"].toggle*0.02
      @sprites["f#{i}"].toggle *= -1 if @sprites["f#{i}"].color.alpha <= 0 || @sprites["f#{i}"].color.alpha >= 128
    end
    @frame = 0 if @frame > 2
    @fpIndex += 1 if @fpIndex < 512
    return if !@reveal

  end
  # used to fade in from black
  def reduceAlpha(factor)
    @sprites["bg"].color.alpha -= factor
    for i in 0...@amt*2
      @sprites["f#{i}"].color.alpha -= factor
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # used to show other elements
  def show
    @sprites["bg"].color.alpha = 0
    @sprites["ol"].color.alpha = 0
    @sprites["st"].visible = true
    for i in 0...@amt*2
      c = [
        Color.new(234,202,91,0),
        Color.new(236,177,89,0),
        Color.new(200,56,52,0)
      ]
      @sprites["f#{i}"].color = c[rand(c.length)]
    end
    @reveal = true
  end
end
