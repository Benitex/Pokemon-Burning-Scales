#===============================================================================
# Animated particles and visual effects
#===============================================================================
# Rays: style 1
class MTS_Element_FX1
  attr_accessor :x, :y
  def id; return "effect.rays"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # initializes the required sprites
    for i in 0...16
      @sprites["r#{i}"] = Sprite.new(@viewport)
      @sprites["r#{i}"].opacity = 0
      @sprites["r#{i}"].z = z.nil? ? 30 : z
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates ray particles
    for j in 0...16
      next if j > @fpIndex/2
      if @sprites["r#{j}"].opacity <= 0
        bmp = pbBitmap("Graphics/MODTS/Particles/ray001")
        w = rand(65) + 16
        @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
        @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
        @sprites["r#{j}"].center!
        @sprites["r#{j}"].x = self.x
        @sprites["r#{j}"].y = self.y
        @sprites["r#{j}"].ox = -(64 + rand(17))
        @sprites["r#{j}"].zoom_x = 1
        @sprites["r#{j}"].zoom_y = 1
        @sprites["r#{j}"].angle = rand(360)
        @sprites["r#{j}"].param = 2 + rand(5)
        bmp.dispose
      end
      @sprites["r#{j}"].ox -= @sprites["r#{j}"].param
      @sprites["r#{j}"].zoom_x += 0.001*@sprites["r#{j}"].param
      @sprites["r#{j}"].zoom_y -= 0.001*@sprites["r#{j}"].param
      if @sprites["r#{j}"].ox > -128
        @sprites["r#{j}"].opacity += 8
      else
        @sprites["r#{j}"].opacity -= 2*@sprites["r#{j}"].param
      end
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Smoke: style 1
class MTS_Element_FX2
  attr_accessor :x, :y
  def id; return "effect.smoke"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # initializes the required sprites
    for j in 0...20
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/smoke001")
      @sprites["s#{j}"].center!
      @sprites["s#{j}"].x = self.x
      @sprites["s#{j}"].y = self.y
      @sprites["s#{j}"].opacity = 0
      @sprites["s#{j}"].z = z.nil? ? 30 : z
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates smoke particles
    for j in 0...20
      if @sprites["s#{j}"].opacity <= 0
        @sprites["s#{j}"].opacity = 255
        r = 160 + rand(33)
        cx, cy = randCircleCord(r)
        @sprites["s#{j}"].center!
        @sprites["s#{j}"].x = self.x
        @sprites["s#{j}"].y = self.y
        @sprites["s#{j}"].ex = @sprites["s#{j}"].x - r + cx
        @sprites["s#{j}"].ey = @sprites["s#{j}"].y - r + cy
        @sprites["s#{j}"].toggle = rand(2) == 0 ? 2 : -2
        @sprites["s#{j}"].param = 2 + rand(4)
        z = 1 - rand(41)/100.0
        @sprites["s#{j}"].zoom_x = z
        @sprites["s#{j}"].zoom_y = z
      end
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].ex)*0.02
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].ey)*0.02
      @sprites["s#{j}"].opacity -= @sprites["s#{j}"].param*1.5
      @sprites["s#{j}"].angle += @sprites["s#{j}"].toggle if $PokemonSystem.screensize < 2
      @sprites["s#{j}"].zoom_x -= 0.002
      @sprites["s#{j}"].zoom_y -= 0.002
    end

    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Vacuum Waves: style 1
class MTS_Element_FX3
  attr_accessor :x, :y
  def id; return "effect.vacuum"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # creates vacuum waves
    for j in 0...3
      @sprites["ec#{j}"] = Sprite.new(@viewport)
      @sprites["ec#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ring002")
      @sprites["ec#{j}"].center!
      @sprites["ec#{j}"].x = self.x
      @sprites["ec#{j}"].y = self.y
      @sprites["ec#{j}"].zoom_x = 1.5
      @sprites["ec#{j}"].zoom_y = 1.5
      @sprites["ec#{j}"].opacity = 0
      @sprites["ec#{j}"].z = z.nil? ? 30 : z
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
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
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Rays: style 2
class MTS_Element_FX4
  attr_accessor :x, :y
  def id; return "effect.rays"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # initializes light rays
    rangle = []
    for i in 0...8; rangle.push((360/8)*i +  15); end
    for j in 0...8
      @sprites["r#{j}"] = Sprite.new(@viewport)
      @sprites["r#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ray002")
      @sprites["r#{j}"].ox = 0
      @sprites["r#{j}"].oy = @sprites["r#{j}"].bitmap.height/2
      @sprites["r#{j}"].opacity = 0
      @sprites["r#{j}"].zoom_x = 0
      @sprites["r#{j}"].zoom_y = 0
      @sprites["r#{j}"].x = self.x
      @sprites["r#{j}"].y = self.y
      a = rand(rangle.length)
      @sprites["r#{j}"].angle = rangle[a]
      @sprites["r#{j}"].z = z.nil? ? 30 : z
      rangle.delete_at(a)
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
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
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Shine: style 1
class MTS_Element_FX5
  attr_accessor :x, :y
  def id; return "effect.shine"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # initializes particles
    r = 256
    for j in 0...16
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine001")
      @sprites["s#{j}"].center!
      @sprites["s#{j}"].x = self.x
      @sprites["s#{j}"].y = self.y
      @sprites["s#{j}"].z = z.nil? ? 30 : z
      x, y = randCircleCord(r)
      p = rand(100)
      @sprites["s#{j}"].end_x = @sprites["s#{j}"].x - r + x
      @sprites["s#{j}"].end_y = @sprites["s#{j}"].y - r + y
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].end_x)*(p/100.0)
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].end_y)*(p/100.0)
      @sprites["s#{j}"].speed = 1
      @sprites["s#{j}"].opacity = 255 - 255*(p/100.0)
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates particle effect
    for j in 0...16
      r = 256
      if @sprites["s#{j}"].opacity == 0
        @sprites["s#{j}"].opacity = 255
        @sprites["s#{j}"].speed = 1
        @sprites["s#{j}"].x = self.x
        @sprites["s#{j}"].y = self.y
        x, y = randCircleCord(r)
        @sprites["s#{j}"].end_x = self.x - r + x
        @sprites["s#{j}"].end_y = self.y - r + y
      end
      @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].end_x)*0.01*@sprites["s#{j}"].speed
      @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].end_y)*0.01*@sprites["s#{j}"].speed
      @sprites["s#{j}"].opacity -= 2*@sprites["s#{j}"].speed
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Shine: style 2
class MTS_Element_FX6
  attr_accessor :x, :y
  def id; return "effect.shine"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @toggle = 1
    @sprites = {}
    # initializes particles
    @sprites["shine2"] = Sprite.new(@viewport)
    @sprites["shine2"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine002")
    @sprites["shine2"].center!
    @sprites["shine2"].x = self.x
    @sprites["shine2"].y = self.y
    @sprites["shine2"].z = z.nil? ? 30 : z
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates particle effect
    @toggle *= -1 if @fpIndex%(32) == 0
    @sprites["shine2"].zoom_x += 0.005*@toggle
    @sprites["shine2"].zoom_y += 0.005*@toggle
    @fpIndex += 1 if @fpIndex < 512
    @fpIndex = 0 if @fpIndex >= 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Shine: style 3
class MTS_Element_FX7
  attr_accessor :x, :y
  def id; return "effect.shine"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # initializes particles
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine003")
    @sprites["shine"].center!
    @sprites["shine"].x = self.x
    @sprites["shine"].y = self.y
    @sprites["shine"].z = z.nil? ? 30 : z
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
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
    # updates particle effect
    @sprites["shine"].angle-=1 if $PokemonSystem.screensize < 2
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Rays: style 3
class MTS_Element_FX8
  attr_accessor :x, :y
  def id; return "effect.rays"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @done = false
    @sprites = {}
    # initializes particles
    @shine = {}
    @shine["count"] = 0
    for i in 0...6
      @shine["f#{i}"] = Sprite.new(@viewport)
      @shine["f#{i}"].z = z.nil? ? 50 : z
      @shine["f#{i}"].bitmap = pbBitmap(sprintf("Graphics/MODTS/Particles/flare%03d",i+1))
      @shine["f#{i}"].center!
      @shine["f#{i}"].x = 0
      @shine["f#{i}"].y = 0
      @shine["f#{i}"].opacity = 0
      @shine["f#{i}"].tone = Tone.new(128,128,128)
    end
    x = [-2,20,10]
    y = [-4,-24,-2]
    for i in 0...3
      @shine["s#{i}"] = Sprite.new(@viewport)
      @shine["s#{i}"].z = z.nil? ? 50 : z
      @shine["s#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ray003")
      @shine["s#{i}"].oy = @shine["s#{i}"].bitmap.height/2
      @shine["s#{i}"].angle = 290 + [-10,32,10][i]
      @shine["s#{i}"].zoom_x = 0
      @shine["s#{i}"].zoom_y = 0
      @shine["s#{i}"].opacity = 0
      @shine["s#{i}"].x = x[i]
      @shine["s#{i}"].y = y[i]
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates particle effect
    for j in 0...6
      break if @done
      next if j > @shine["count"]
      @shine["f#{j}"].opacity += (@shine["count"] < 40) ? 32 : -16
      @shine["f#{j}"].x += (6-j)*(j < 5 ? 2 : -2)
      @shine["f#{j}"].y += (6-j)*(j < 5 ? 1 : -1)
      @shine["f#{j}"].tone.red -= 1
      @shine["f#{j}"].tone.green -= 1
      @shine["f#{j}"].tone.blue -= 1
    end
    for i in 0...3
      next if i > @shine["count"]/6
      @shine["s#{i}"].zoom_x += 0.04*[0.5,0.8,0.7][i]
      @shine["s#{i}"].zoom_y += 0.03*[0.5,0.8,0.7][i]
      @shine["s#{i}"].opacity += @shine["s#{i}"].zoom_x < 1 ? 8 : -12
      if @shine["s#{i}"].opacity <= 0
        @shine["s#{i}"].zoom_x = 0
        @shine["s#{i}"].zoom_y = 0
        @shine["s#{i}"].opacity = 0
      end
    end
    if @shine["count"] >= 128
      @done = true
    else
      @shine["count"] += 1
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Electric Sparks
class MTS_Element_FX9
  attr_accessor :x, :y
  def id; return "effect.electric"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # creates all the electricity particles
    @sprites["ele"] = Sprite.new(@viewport)
    @sprites["ele"].bitmap = pbBitmap("Graphics/MODTS/Overlays/special001")
    @sprites["ele"].src_rect.height = 72
    @sprites["ele"].src_rect.y = 72*(rand(@sprites["ele"].bitmap.height/72))
    @sprites["ele"].center!
    @sprites["ele"].x = self.x
    @sprites["ele"].y = self.y
    @sprites["ele"].zoom_x = @viewport.rect.width/@sprites["ele"].bitmap.width
    @sprites["ele"].zoom_y = 2
    @sprites["ele"].z = z.nil? ? 30 : z
    # left group
    for i in 0...16
      @sprites["l#{i}"] = Sprite.new(@viewport)
      @sprites["l#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special001")
      @sprites["l#{i}"].center!
      @sprites["l#{i}"].opacity = 0
      @sprites["l#{i}"].z = z.nil? ? 30 : z
    end
    # right group
    for i in 0...16
      @sprites["r#{i}"] = Sprite.new(@viewport)
      @sprites["r#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special001")
      @sprites["r#{i}"].center!
      @sprites["r#{i}"].opacity = 0
      @sprites["r#{i}"].z = z.nil? ? 30 : z
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = @viewport.rect.width/2
    @y = y.nil? ? @viewport.rect.height*0.6 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates electricity particles
    @sprites["ele"].src_rect.y += 72
    @sprites["ele"].src_rect.y = 0 if @sprites["ele"].src_rect.y >= @sprites["ele"].bitmap.height
    # left group
    for i in 0...16
      next if i > @fpIndex/2
      if @sprites["l#{i}"].opacity <= 0
        @sprites["l#{i}"].x = 0
        @sprites["l#{i}"].y = self.y
        r = 64 + rand(129)
        cx, cy = randCircleCord(r)
        @sprites["l#{i}"].ex = 0 + (cx - r).abs
        @sprites["l#{i}"].ey = self.y - r/2 + cy/2
        z = 0.4 + rand(7)/10.0
        @sprites["l#{i}"].zoom_x = z
        @sprites["l#{i}"].zoom_y = z
        @sprites["l#{i}"].opacity = 255
      end
      @sprites["l#{i}"].opacity -= 8
      @sprites["l#{i}"].x -= (@sprites["l#{i}"].x - @sprites["l#{i}"].ex)*0.1
      @sprites["l#{i}"].y -= (@sprites["l#{i}"].y - @sprites["l#{i}"].ey)*0.1
    end
    # right group
    for i in 0...16
      next if i > @fpIndex/2
      if @sprites["r#{i}"].opacity <= 0
        @sprites["r#{i}"].x = @viewport.rect.width
        @sprites["r#{i}"].y = self.y
        r = 64 + rand(129)
        cx, cy = randCircleCord(r)
        @sprites["r#{i}"].ex = @viewport.rect.width - (cx - r).abs
        @sprites["r#{i}"].ey = self.y - r/2 + cy/2
        z = 0.4 + rand(7)/10.0
        @sprites["r#{i}"].zoom_x = z
        @sprites["r#{i}"].zoom_y = z
        @sprites["r#{i}"].opacity = 255
      end
      @sprites["r#{i}"].opacity -= 8
      @sprites["r#{i}"].x -= (@sprites["r#{i}"].x - @sprites["r#{i}"].ex)*0.1
      @sprites["r#{i}"].y -= (@sprites["r#{i}"].y - @sprites["r#{i}"].ey)*0.1
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Fire particles
class MTS_Element_FX10
  attr_accessor :x, :y
  def id; return "effect.fire"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @frame = 0
    self.position(x,y)
    @sprites = {}
    # initializes the required sprites
    @amt = @viewport.rect.width/32 + 1
    for k in 0...@amt*2
      i = (@amt*2 - 1) - k
      @sprites["f#{i}"] = Sprite.new(@viewport)
      @sprites["f#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special003")
      @sprites["f#{i}"].src_rect.width /= 4
      @sprites["f#{i}"].src_rect.x = rand(4)*@sprites["f#{i}"].src_rect.width
      @sprites["f#{i}"].ox = @sprites["f#{i}"].src_rect.width/2
      @sprites["f#{i}"].oy = @sprites["f#{i}"].src_rect.height
      @sprites["f#{i}"].x = 32*(i%@amt)
      @sprites["f#{i}"].y = self.y
      @sprites["f#{i}"].zoom_y = 0.6 + rand(41)/100.0
      @sprites["f#{i}"].param = rand(@amt*2)
      c = [
        Color.new(234,202,91,0),
        Color.new(236,177,89,0),
        Color.new(200,56,52,0)
      ]
      @sprites["f#{i}"].color = c[rand(c.length)]
      @sprites["f#{i}"].speed = 8
      @sprites["f#{i}"].toggle = 2
      if i >= @amt
        @sprites["f#{i}"].x += 16
        @sprites["f#{i}"].y -= 8
        @sprites["f#{i}"].opacity = 164 - rand(33)
        @sprites["f#{i}"].z = (z.nil? ? 30 : z) - 1
      else
        @sprites["f#{i}"].z = (z.nil? ? 30 : z) - rand(2)
      end
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height + 16 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # updates fire particles
    @frame += 1
    for i in 0...@amt*2
      next if @frame < 3
      @sprites["f#{i}"].src_rect.x += @sprites["f#{i}"].src_rect.width
      @sprites["f#{i}"].src_rect.x = 0 if @sprites["f#{i}"].src_rect.x >= @sprites["f#{i}"].bitmap.width
      next if @sprites["f#{i}"].param > @fpIndex/2
      @sprites["f#{i}"].color.alpha += @sprites["f#{i}"].toggle*@sprites["f#{i}"].speed
      @sprites["f#{i}"].zoom_y += @sprites["f#{i}"].toggle*0.03
      @sprites["f#{i}"].toggle *= -1 if @sprites["f#{i}"].color.alpha <= 0 || @sprites["f#{i}"].color.alpha >= 128
    end
    @frame = 0 if @frame > 2
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Spinning element
class MTS_Element_FX11
  attr_accessor :x, :y
  def id; return "effect.blend"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @sprites = {}
    # initializes the required sprites
    @sprites["cir"] = Sprite.new(@viewport)
    @sprites["cir"].bitmap = pbBitmap("Graphics/MODTS/Particles/radial002")
    @sprites["cir"].center!
    @sprites["cir"].x = self.x
    @sprites["cir"].y = self.y
    @sprites["cir"].z = z.nil? ? 30 : z
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # spins element
    @sprites["cir"].angle += 1 if $PokemonSystem.screensize < 2
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Crazy particles
class MTS_Element_FX12
  attr_accessor :x, :y
  def id; return "effect.crazy"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @radius = @viewport.rect.height/2
    self.position(x,y)
    @sprites = {}
    # draws all the particles
    for j in 0...64
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].z = z.nil? ? 30 : z
      width = 16 + rand(48)
      height = 16 + rand(16)
      @sprites["p#{j}"].bitmap = Bitmap.new(width,height)
      bmp = pbBitmap("Graphics/MODTS/Particles/special004")
      @sprites["p#{j}"].bitmap.stretch_blt(Rect.new(0,0,width,height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["p#{j}"].bitmap.hue_change(rand(360))
      @sprites["p#{j}"].ox = width/2
      @sprites["p#{j}"].oy = height + @radius + rand(32)
      @sprites["p#{j}"].angle = rand(360)
      @sprites["p#{j}"].speed = 1 + rand(4)
      @sprites["p#{j}"].x = self.x
      @sprites["p#{j}"].y = self.y
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # animates all the particles
    for j in 0...64
      @sprites["p#{j}"].angle -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].opacity -= @sprites["p#{j}"].speed
      @sprites["p#{j}"].oy -= @sprites["p#{j}"].speed/2 if @sprites["p#{j}"].oy > @sprites["p#{j}"].bitmap.height
      @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
      @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
      if @sprites["p#{j}"].zoom_x <= 0 || @sprites["p#{j}"].oy <= 0 || @sprites["p#{j}"].opacity <= 0
        @sprites["p#{j}"].angle = rand(360)
        @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height + @radius + rand(32)
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
        @sprites["p#{j}"].opacity = 255
        @sprites["p#{j}"].speed = 1 + rand(4)
      end
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Bubble particles
class MTS_Element_FX13
  attr_accessor :x, :y
  def id; return "effect.bubbles"; end
  def id?(val); return self.id == val; end
  # main method to create the effect
  def initialize(viewport,x=nil,y=nil,z=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    @radius = @viewport.rect.height/2
    self.position(x,y)
    @sprites = {}
    # draws all the particles
    for j in 0...18
      @sprites["b#{j}"] = Sprite.new(@viewport)
      @sprites["b#{j}"].z = z.nil? ? 30 : z
      @sprites["b#{j}"].y = - 32
    end
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # changes visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
    end
  end
  # update method
  def update
    return if self.disposed?
    # animates all the particles
    for i in 0...18
      if @sprites["b#{i}"].y <= -32
        r = rand(12)
        @sprites["b#{i}"].bitmap = Bitmap.new(16 + r*4, 16 + r*4)
        @sprites["b#{i}"].bitmap.draw_circle
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
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#===============================================================================
