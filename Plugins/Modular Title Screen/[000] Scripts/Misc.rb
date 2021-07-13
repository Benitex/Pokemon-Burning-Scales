#===============================================================================
# Miscellaneos Visual Effects
#===============================================================================
# Trainer running
class MTS_Element_MX1
  attr_accessor :x, :y
  def id; return "trainer"; end
  def id?(val); return self.id == val; end
  # main method to create the visuals
  def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @frame = 0
    @speed = 3
    @sprites = {}
    # initializes trainer sprite
    @sprites["trainer"] = Sprite.new(@viewport)
    @sprites["trainer"].bitmap = pbBitmap(self.getTrainer)
    @sprites["trainer"].src_rect.set(0,0,@sprites["trainer"].bitmap.height,@sprites["trainer"].bitmap.width/6)
    @sprites["trainer"].z = z.nil? ? 100 : z
    @sprites["trainer"].ox = @sprites["trainer"].src_rect.width/2
    @sprites["trainer"].oy = @sprites["trainer"].src_rect.height
    @sprites["trainer"].x = self.x
    @sprites["trainer"].y = self.y
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width*0.8 : x
    @y = y.nil? ? @viewport.rect.height - 28 : y
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  # disposes of everything
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  # get variable trainertype
  def getTrainer
    type = $Trainer ? $Trainer.trainertype : 0
    outfit = $Trainer ? $Trainer.outfit : 0
    bitmapFileName = sprintf("Graphics/MODTS/Panorama/trainer%s_%d",
       getConstantName(PBTrainers,type),outfit) rescue nil
    if !pbResolveBitmap(bitmapFileName)
      bitmapFileName = sprintf("Graphics/MODTS/Panorama/trainer%03d_%d",type,outfit)
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/MODTS/Panorama/trainer%03d",type)
      end
    end
    return bitmapFileName
  end
  # update method
  def update
    return if self.disposed?
    # updates trainer sprite
    @frame += 1
    @frame = 0 if @frame > @speed + 1
    @sprites["trainer"].src_rect.x += @sprites["trainer"].src_rect.width if @frame > @speed
    @sprites["trainer"].src_rect.x = 0 if @sprites["trainer"].src_rect.x >= @sprites["trainer"].bitmap.width
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Pokemon running
class MTS_Element_MX2
  attr_accessor :x, :y
  def id; return "pokemon"; end
  def id?(val); return self.id == val; end
  # main method to create the visuals
  def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @frame = 0
    @speed = 3
    @sprites = {}
    # initializes pokemon sprite
    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = pbBitmap("Graphics/MODTS/Panorama/pokemon")
    @sprites["poke"].src_rect.set(0,0,@sprites["poke"].bitmap.height,@sprites["poke"].bitmap.width/4)
    @sprites["poke"].z = z.nil? ? 100 : z
    @sprites["poke"].ox = @sprites["poke"].src_rect.width/2
    @sprites["poke"].oy = @sprites["poke"].src_rect.height
    @sprites["poke"].x = self.x
    @sprites["poke"].y = self.y
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width*0.56 : x
    @y = y.nil? ? @viewport.rect.height - 16 : y
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
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
    # updates pokemon sprite
    @frame += 1
    @frame = 0 if @frame > @speed + 1
    @sprites["poke"].src_rect.x += @sprites["poke"].src_rect.width if @frame > @speed
    @sprites["poke"].src_rect.x = 0 if @sprites["poke"].src_rect.x >= @sprites["poke"].bitmap.width
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Static Pokemon (with optional glow)
class MTS_Element_MX3
  attr_accessor :x, :y
  def id; return "pokemon"; end
  def id?(val); return self.id == val; end
  # main method to create the visuals
  def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @toggle = 1
    @sprites = {}
    # initializes pokemon sprite
    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = pbBitmap("Graphics/MODTS/Overlays/pokemon")
    @sprites["poke"].z = z.nil? ? 100 : z
    @sprites["poke"].center!
    @sprites["poke"].x = self.x
    @sprites["poke"].y = self.y
    # initializes pokemon glow
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap("Graphics/MODTS/Overlays/pokemonOverlay")
    @sprites["glow"].z = z.nil? ? 100 : z
    @sprites["glow"].center!
    @sprites["glow"].x = self.x
    @sprites["glow"].y = self.y
    @sprites["glow"].opacity = 0
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height/2 : y
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
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
    # updates pokemon glow
    @sprites["glow"].opacity += @toggle
    @toggle *= -1 if @sprites["glow"].opacity <= 0 || @sprites["glow"].opacity >= 192
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Animated Pokemon sprite
class MTS_Element_MX4
  attr_accessor :x, :y
  def id; return "pokemon"; end
  def id?(val); return self.id == val; end
  # main method to create the visuals
  def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
    @viewport = viewport
    @disposed = false
    @fpIndex = 0
    self.position(x,y)
    @toggle = 1
    @sprites = {}
    # checks species validity
    species = ModularTitle::SPECIES
    if species.nil?
      @disposed = true
      return
    end
    # initializes pokemon sprite
    @sprites["poke"] = PokemonSprite.new(@viewport)
    @sprites["poke"].setSpeciesBitmap(species, ModularTitle::SPECIES_FEMALE, ModularTitle::SPECIES_FORM, ModularTitle::SPECIES_SHINY, false, ModularTitle::SPECIES_BACK, false)
    @sprites["poke"].setOffset(PictureOrigin::Bottom)
    @sprites["poke"].z = z.nil? ? 100 : z
    @sprites["poke"].x = self.x
    @sprites["poke"].y = self.y
    s = s.nil? ? 1 : s
    @sprites["poke"].zoom_x = s
    @sprites["poke"].zoom_y = s
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? @viewport.rect.width/2 : x
    @y = y.nil? ? @viewport.rect.height*0.86 : y
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
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
    # updates pokemon sprite
    @sprites["poke"].update
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Static image
class MTS_Element_MX5
  attr_accessor :x, :y
  def id; return "pokemon.static"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
    @viewport = viewport
    @disposed = false
    self.position(x,y)
    @sprites = {}
    # creates the pokemon sprite
    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = pbBitmap("Graphics/MODTS/Overlays/#{file}")
    @sprites["poke"].z = z.nil? ? 100 : z
    @sprites["poke"].x = self.x
    @sprites["poke"].y = self.y
  end
  # positions effect on screen
  def position(x,y)
    @x = x.nil? ? 0 : x
    @y = y.nil? ? 0 : y
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
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
  # fetches sprite
  def sprite; return @sprites["poke"]; end
  def sprite=(val)
    @sprites["poke"] = val
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#-------------------------------------------------------------------------------
# Crystal Overlay
class MTS_Extra_Overlay
  def id; return "background"; end
  def id?(val); return self.id == val; end
  # main method to create the background
  def initialize(viewport)
    @viewport = viewport
    @disposed = false
    @sprites = {}
    @fpIndex = 0
    # creates the pokemon sprite
    for i in 1..26
      o = i < 10 ? 64 : 128
      @sprites["c#{i}"] = Sprite.new(@viewport)
      bmp = pbBitmap(sprintf("Graphics/MODTS/Intros/cr%03d",i))
      @sprites["c#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["c#{i}"].bitmap.blt(0,0,bmp,bmp.rect,o-rand(64))
      bmp.dispose
      @sprites["c#{i}"].opacity = 0
      @sprites["c#{i}"].toggle = 1
      @sprites["c#{i}"].speed = 1 + rand(4)
      @sprites["c#{i}"].param = 128 - rand(92)
      @sprites["c#{i}"].end_y = rand(32)
    end
  end
  # sets z index
  def z=(val)
    for key in @sprites.keys
      @sprites[key].z = val
    end
  end
  # sets visibility
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
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
    for i in 1..26
      next if @fpIndex < @sprites["c#{i}"].end_y
      @sprites["c#{i}"].opacity += @sprites["c#{i}"].toggle*@sprites["c#{i}"].speed
      @sprites["c#{i}"].toggle *= -1 if @sprites["c#{i}"].opacity <= 0 || @sprites["c#{i}"].opacity >= @sprites["c#{i}"].param
    end
    @fpIndex += 1 if @fpIndex < 512
  end
  # checks if disposed
  def disposed?; return @disposed; end
  # end
end
#===============================================================================
