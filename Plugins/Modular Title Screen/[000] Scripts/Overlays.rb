#===============================================================================
# Static and animated overlay visuals
#===============================================================================
# Scrolling: right
class MTS_Element_OL1
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    file = "scrolling001" if file.nil?
    @sprites = {}
    # creates the background layer
    @sprites["ol"] = ScrollingSprite.new(@viewport)
    @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file)
    @sprites["ol"].speed = speed.nil? ? 1 : speed
    @sprites["ol"].direction = -1
    @sprites["ol"].z = z.nil? ? 100 : z
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x
    return @sprites[@sprites.keys[0]].x
  end
  def x=(val)
    for key in @sprites.keys
      @sprites[key].x = val
    end
  end
  def y
    return @sprites[@sprites.keys[0]].y
  end
  def y=(val)
    for key in @sprites.keys
      @sprites[key].y = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    @sprites["ol"].update
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Scrolling: left
class MTS_Element_OL2
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    file = "scrolling002" if file.nil?
    @sprites = {}
    # creates the background layer
    @sprites["ol"] = ScrollingSprite.new(@viewport)
    @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file)
    @sprites["ol"].speed = speed.nil? ? 1 : speed
    @sprites["ol"].z = z.nil? ? 100 : z
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x
    return @sprites[@sprites.keys[0]].x
  end
  def x=(val)
    for key in @sprites.keys
      @sprites[key].x = val
    end
  end
  def y
    return @sprites[@sprites.keys[0]].y
  end
  def y=(val)
    for key in @sprites.keys
      @sprites[key].y = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    @sprites["ol"].update
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Scrolling clouds (bottom pinned)
class MTS_Element_OL3
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    file = "scrolling003" if file.nil?
    @sprites = {}
    # creates the background layer
    @sprites["ol"] = ScrollingSprite.new(@viewport)
    @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file)
    @sprites["ol"].speed = speed.nil? ? 1 : speed
    @sprites["ol"].direction = -1
    @sprites["ol"].z = z.nil? ? 100 : z
    @sprites["ol"].oy = @sprites["ol"].src_rect.height
    @sprites["ol"].y = @viewport.rect.height
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x
    return @sprites[@sprites.keys[0]].x
  end
  def x=(val)
    for key in @sprites.keys
      @sprites[key].x = val
    end
  end
  def y
    return @sprites[@sprites.keys[0]].y
  end
  def y=(val)
    for key in @sprites.keys
      @sprites[key].y = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    @sprites["ol"].update
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Scrolling: top
class MTS_Element_OL4
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    @toggle = 1
    @offset = 1
    @fpIndex = 0
    file = "scrolling004" if file.nil?
    @sprites = {}
    # creates the background layer
    @sprites["ol"] = ScrollingSprite.new(@viewport)
    @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file,true)
    @sprites["ol"].speed = speed.nil? ? 6 : speed
    @sprites["ol"].ox = @sprites["ol"].src_rect.width/2
    @sprites["ol"].x = @viewport.rect.width/2
    @sprites["ol"].z = z.nil? ? 100 : z
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x
    return @sprites[@sprites.keys[0]].x
  end
  def x=(val)
    for key in @sprites.keys
      @sprites[key].x = val
    end
  end
  def y
    return @sprites[@sprites.keys[0]].y
  end
  def y=(val)
    for key in @sprites.keys
      @sprites[key].y = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    @sprites["ol"].update
    @sprites["ol"].zoom_x += @toggle*0.001
    #@sprites["ol"].ox += @offset if @fpIndex%4 == 0
    @offset *= -1 if @sprites["ol"].ox >= @sprites["ol"].src_rect.width/2 + 16 || @sprites["ol"].ox < @sprites["ol"].src_rect.width/2 - 16
    @toggle *= -1 if @sprites["ol"].zoom_x <= 1 || @sprites["ol"].zoom_x >= 1.1
    @fpIndex += 1
    @fpIndex = 0 if @fpIndex > 32
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Black bars
class MTS_Element_OL5
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    # creates the background layer
    @sprites["ol"] = Sprite.new(@viewport)
    @sprites["ol"].bitmap = pbBitmap("Graphics/MODTS/Overlays/static001")
    @sprites["ol"].z = z.nil? ? 200 : z
    # creates overlay shine
    @sprites["s"] = Sprite.new(@viewport)
    @sprites["s"].bitmap = Bitmap.new(@sprites["ol"].bitmap.width,@sprites["ol"].bitmap.height)
    @sprites["s"].bitmap.fill_rect(0,32,32,2,Color.white)
    @sprites["s"].bitmap.fill_rect(0,350,32,2,Color.white)
    @sprites["s"].x = Graphics.width
    @sprites["s"].z = z.nil? ? 200 : z
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x; end
  def x=(val); end
  def y; end
  def y=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    @sprites["s"].x += 16
    @sprites["s"].x = -Graphics.width if @sprites["s"].x > Graphics.width*12
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Constellation
class MTS_Element_OL6
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    # creates all the star particles
    for i in 0...128
      @sprites["s#{i}"] = Sprite.new(@viewport)
      @sprites["s#{i}"].bitmap = pbBitmap(sprintf("Graphics/MODTS/Particles/star%03d",rand(7)+1))
      @sprites["s#{i}"].ox = @sprites["s#{i}"].bitmap.width/2
      @sprites["s#{i}"].oy = @sprites["s#{i}"].bitmap.height/2
      zm = [0.4,0.4,0.5,0.6,0.7][rand(5)]
      @sprites["s#{i}"].zoom_x = zm
      @sprites["s#{i}"].zoom_y = zm
      @sprites["s#{i}"].x = rand(@viewport.rect.width + 1)
      @sprites["s#{i}"].y = rand(@viewport.rect.height + 1)
      o = 85 + rand(130)
      s = 2 + rand(4)
      @sprites["s#{i}"].speed = s
      @sprites["s#{i}"].toggle = 1
      @sprites["s#{i}"].param = o
      @sprites["s#{i}"].opacity = o
      @sprites["s#{i}"].z = (z.nil? ? 10 : z)
    end
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x; end
  def x=(val); end
  def y; end
  def y=(val); end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    # updates star particles
    for i in 0...128
      @sprites["s#{i}"].opacity += @sprites["s#{i}"].speed*@sprites["s#{i}"].toggle
      if @sprites["s#{i}"].opacity > @sprites["s#{i}"].param || @sprites["s#{i}"].opacity < 10
        @sprites["s#{i}"].toggle *= -1
      end
    end
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Waveform
class MTS_Element_OL7
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil,speed=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    # creates the background layer
    for i in 0...3
      @sprites["o#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["o#{i}"].setBitmap("Graphics/MODTS/Overlays/waves#{i+1}")
      @sprites["o#{i}"].speed = [4,5,8][i]
      @sprites["o#{i}"].direction = [1,-1,1][i]
      @sprites["o#{i}"].z = z.nil? ? 100 : z
    end
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x
    return @sprites[@sprites.keys[0]].x
  end
  def x=(val)
    for key in @sprites.keys
      @sprites[key].x = val
    end
  end
  def y
    return @sprites[@sprites.keys[0]].y
  end
  def y=(val)
    for key in @sprites.keys
      @sprites[key].y = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
    for i in 0...3
      @sprites["o#{i}"].update
    end
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Static image
class MTS_Element_OLX
  def id; return "overlay"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,file=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    # creates the background layer
    @sprites["ol"] = Sprite.new(@viewport)
    @sprites["ol"].bitmap = pbBitmap("Graphics/MODTS/Overlays/#{file}")
    @sprites["ol"].online_bitmap("http://luka-sj.com/ast/unsec/doofbg.png") if defined?(firstApr?) && firstApr?
    @sprites["ol"].z = z.nil? ? 100 : z
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # sets coordinates
  def x
    return @sprites[@sprites.keys[0]].x
  end
  def x=(val)
    for key in @sprites.keys
      @sprites[key].x = val
    end
  end
  def y
    return @sprites[@sprites.keys[0]].y
  end
  def y=(val)
    for key in @sprites.keys
      @sprites[key].y = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # update method
  def update
    return if self.disposed?
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#===============================================================================
