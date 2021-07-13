#===============================================================================
# Static and animated title screen backgrounds
#===============================================================================
# Static
class MTS_Element_BG0
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    file = "background" if file.nil?
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/#{file}")
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # update method
  def update; end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Digital
class MTS_Element_BG1
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @speed = 1
    @sprites = {}
    @tiles = []
    @data = []
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/digital")
    # analyzes background
    f = 16
    avg = 0
    n = 0
    for x in 0...@sprites["bg"].bitmap.width/f
      for y in 0...@sprites["bg"].bitmap.height/f
        px = @sprites["bg"].bitmap.get_pixel(x*f,y*f)
        avg += (px.red + px.green + px.blue)/3.0
        n += 1
      end
    end
    tc = (avg/n) > 128 ? Color.white : Color.black
    # draws all the little tiles
    tile_size = 32.0
    opacity = 55
    offset = 0
    @x = (@viewport.rect.width/tile_size).ceil
    @y = (@viewport.rect.height/tile_size).ceil
    for i in 0...@x
      for j in 0...@y
        sprite = Sprite.new(@viewport)
        sprite.bitmap = Bitmap.new(tile_size,tile_size)
        sprite.bitmap.fill_rect(offset,offset,tile_size-offset*2,tile_size-offset*2,Color.new(tc.red,tc.green,tc.blue,opacity))
        sprite.x = i * tile_size
        sprite.y = j * tile_size
        o = opacity + rand(156)
        sprite.opacity = 0
        @tiles.push(sprite)
        @data.push([o,rand(4)+2])
      end
    end
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    for i in 0...@tiles.length
      @tiles[i].opacity += @data[i][1]
      @data[i][1] *= -1 if @tiles[i].opacity <= 0 || @tiles[i].opacity >= @data[i][0]
    end
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
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
  # end
end
#-------------------------------------------------------------------------------
# Ultra Beast
class MTS_Element_BG2
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = RainbowSprite.new(@viewport)
    @sprites["bg"].setBitmap("Graphics/MODTS/Backgrounds/radiant")
    # creates the circular zoom patterns
    for i in 0...8
      @sprites["h#{i}"] = Sprite.new(@viewport)
      @sprites["h#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ring001")
      @sprites["h#{i}"].center!
      @sprites["h#{i}"].x = @viewport.rect.width/2
      @sprites["h#{i}"].y = @viewport.rect.height/2
      @sprites["h#{i}"].opacity = 0
    end
    # cycles the BG a bit to position the circular patterns
    256.times do
      self.update(true)
    end
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["bg"].update unless skip
    for i in 0...8
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
    @fpIndex += 1 if @fpIndex < 512
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Space dust
class MTS_Element_BG3
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    @fpIndex = 0
    # creates the background
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/clouded")
    @sprites["bg1"].center!
    @sprites["bg1"].x = @viewport.rect.width/2
    @sprites["bg1"].y = @viewport.rect.height/2
    # creates additional set of graphic
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = pbBitmap("Graphics/MODTS/Particles/ring003")
    @sprites["bg2"].center!
    @sprites["bg2"].x = @viewport.rect.width/2
    @sprites["bg2"].y = @viewport.rect.height/2
  end
  # updates the background
  def update
    return if self.disposed?
    # background and shine
    @sprites["bg1"].angle += 1 if $PokemonSystem.screensize < 2
    @sprites["bg2"].angle -= 1 if $PokemonSystem.screensize < 2
    @fpIndex += 1 if @fpIndex < 150
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# XY bg
class MTS_Element_BG4
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/dusk")
    # creates glow
    @tog = 1
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap("Graphics/MODTS/Particles/glow001")
    # creates spinning element
    @sprites["rad"] = Sprite.new(@viewport)
    @sprites["rad"].bitmap = pbBitmap("Graphics/MODTS/Particles/radial001")
    @sprites["rad"].center!(true)
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["rad"].angle += 1 if $PokemonSystem.screensize < 2
    @sprites["glow"].opacity -= @tog
    @tog *= -1 if @sprites["glow"].opacity <= 125 || @sprites["glow"].opacity >= 255
    @fpIndex += 1 if @fpIndex < 512
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Rainbow
class MTS_Element_BG5
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = RainbowSprite.new(@viewport)
    @sprites["bg"].setBitmap("Graphics/MODTS/Backgrounds/rainbow")
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["bg"].update unless skip
    @fpIndex += 1 if @fpIndex < 512
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Panorama
class MTS_Element_BG6
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = Sprite.new(viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/sky")
    @sprites["clouds"] = ScrollingSprite.new(viewport)
    @sprites["clouds"].setBitmap("Graphics/MODTS/Panorama/clouds")
    @sprites["clouds"].speed = 1
    @sprites["clouds"].direction = -1
    @sprites["mountains"] = Sprite.new(viewport)
    @sprites["mountains"].bitmap = pbBitmap("Graphics/MODTS/Panorama/mountains")
    for i in 1..3
      m = 4-i
      @sprites["trees#{m}"] = ScrollingSprite.new(@viewport)
      @sprites["trees#{m}"].setBitmap(sprintf("Graphics/MODTS/Panorama/trees%03d",m))
      @sprites["trees#{m}"].speed = m*2
      @sprites["trees#{m}"].direction = -1
    end
    @sprites["grass"] = ScrollingSprite.new(viewport)
    @sprites["grass"].setBitmap("Graphics/MODTS/Panorama/grass")
    @sprites["grass"].speed = 4
    @sprites["grass"].direction = -1
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    for key in @sprites.keys
      @sprites[key].update
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Crazy
class MTS_Element_BG7
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    # draws the 3 circular patterns that change hue
    for j in 0...3
      @sprites["b#{j}"] = RainbowSprite.new(@viewport)
      @sprites["b#{j}"].setBitmap(sprintf("Graphics/MODTS/Particles/ring%03d",j+4),8)
      @sprites["b#{j}"].center!(true)
      @sprites["b#{j}"].zoom_x = 0.6 + 0.6*j
      @sprites["b#{j}"].zoom_y = 0.6 + 0.6*j
      @sprites["b#{j}"].opacity = 64 + 64*(1+j)
    end
  end
  # updates the background
  def update(skip=false)
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
      @sprites["b#{j}"].update if @fpIndex%8==0
    end
    @fpIndex += 1
    @fpIndex = 0 if @fpIndex >= 64
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Evolution
class MTS_Element_BG8
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # background graphics
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/evolution")
    # particles for the background
    for j in 0...6
      @sprites["l#{j}"] = Sprite.new(@viewport)
      @sprites["l#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ray004")
      @sprites["l#{j}"].y = (@viewport.rect.height/6)*j
      @sprites["l#{j}"].ox = @sprites["l#{j}"].bitmap.width/2
      @sprites["l#{j}"].x = @viewport.rect.width/2
    end
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    # updates line movement
    for j in 0...6
      @sprites["l#{j}"].y = @viewport.rect.height if @sprites["l#{j}"].y <= 0
      t = (@sprites["l#{j}"].y.to_f/@viewport.rect.height)*255
      @sprites["l#{j}"].tone = Tone.new(t,t,t)
      z = ((@sprites["l#{j}"].y.to_f - @viewport.rect.height/2)/(@viewport.rect.height/2))*1.0
      @sprites["l#{j}"].angle = (z < 0) ? 180 : 0
      @sprites["l#{j}"].zoom_y = z.abs
      @sprites["l#{j}"].y -= 2
    end
    @fpIndex += 1
    @fpIndex = 0 if @fpIndex >= 64
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Ethereal
class MTS_Element_BG9
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @sprites = {}
    # background graphics
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/ethereal")
    # particles for the ripple
    for j in 0...4
      @sprites["r#{j}"] = Sprite.new(@viewport)
      @sprites["r#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special005")
      @sprites["r#{j}"].center!
      @sprites["r#{j}"].x = @sprites["bg1"].bitmap.width/2
      @sprites["r#{j}"].y = @sprites["bg1"].bitmap.height*0.84
      @sprites["r#{j}"].zoom_x = 0
      @sprites["r#{j}"].zoom_y = 0
      @sprites["r#{j}"].opacity = 0
    end
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    # updates line ripple
    for j in 0...4
      next if j > @fpIndex/32
      if @sprites["r#{j}"].opacity <= 0
        @sprites["r#{j}"].opacity = 255
        @sprites["r#{j}"].zoom_x = 0
        @sprites["r#{j}"].zoom_y = 0
      end
      @sprites["r#{j}"].zoom_x += 0.01
      @sprites["r#{j}"].zoom_y += 0.01
      @sprites["r#{j}"].opacity -= 2
    end
    @fpIndex += 1 if @fpIndex < 256
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Silhouette
class MTS_Element_BG10
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @speed = 8
    @sprites = {}
    # background graphics
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
    # streak
    @sprites["streak"] = Sprite.new(@viewport)
    @sprites["streak"].bitmap = pbBitmap("Graphics/MODTS/Panorama/streak")
    @sprites["streak"].y = @viewport.rect.height*3
    # silhouette
    @sprites["sil"] = Sprite.new(@viewport)
    @sprites["sil"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/silhouette")
    @sprites["sil"].src_rect.width = @viewport.rect.width
  end
  # updates the background
  def update(skip=false)
    return if self.disposed?
    @sprites["streak"].y -= 16.delta(:sub)
    @sprites["streak"].y = @viewport.rect.height if @sprites["streak"].y < -@viewport.rect.height*16
    @sprites["sil"].src_rect.x += @sprites["sil"].src_rect.width if @fpIndex%@speed == 0
    @sprites["sil"].src_rect.x = 0 if @sprites["sil"].src_rect.x >= @sprites["sil"].bitmap.width
    @fpIndex += 1 
    @fpIndex = 0 if @fpIndex > @speed
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Scrolling: left
class MTS_Element_BG11
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    file = "scrolling" if file.nil?
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = ScrollingSprite.new(@viewport)
    @sprites["bg"].setBitmap("Graphics/MODTS/Backgrounds/"+file)
    @sprites["bg"].speed = 1
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # update method
  def update
    return if self.disposed?
    @sprites["bg"].update
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end

#-------------------------------------------------------------------------------
# Crystal
class MTS_Element_BG12
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    # creates the background layer
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/crystal")
    @sprites["cr"] = MTS_Extra_Overlay.new(@viewport)
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # visibility (not applicable)
  def visible; end
  def visible=(val); end
  # update method
  def update
    return if self.disposed?
    @sprites["cr"].update
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#===============================================================================                           