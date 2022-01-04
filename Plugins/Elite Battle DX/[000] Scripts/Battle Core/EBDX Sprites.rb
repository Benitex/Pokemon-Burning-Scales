#===============================================================================
#  New sprite class utilizing the animated bitmap wrapper (mainly for UI)
#===============================================================================
class SpriteEBDX < Sprite
  attr_accessor :animatedBitmap
  #-----------------------------------------------------------------------------
  #  set bitmap from file
  #-----------------------------------------------------------------------------
  def setBitmap(file, scale = EliteBattle::FRONT_SPRITE_SCALE, speed = 2)
    @animatedBitmap = BitmapEBDX.new(file, scale, speed)
    self.bitmap = @animatedBitmap.bitmap.clone
  end
  #-----------------------------------------------------------------------------
  #  set bitmap based on species
  #-----------------------------------------------------------------------------
  def setSpeciesBitmap(species, female = false, form = 0, shiny = false, shadow = false, back = false, egg = false)
    if species > 0
      @animatedBitmap = pbLoadSpeciesBitmap(species, female, form, shiny, shadow, back, egg)
    else
      @animatedBitmap = BitmapEBDX.new("Graphics/EBDX/Battlers/000")
    end
    self.bitmap = @animatedBitmap.bitmap.clone
  end
  #-----------------------------------------------------------------------------
  #  animate sprite
  #-----------------------------------------------------------------------------
  def play
    @animatedBitmap.play
    self.bitmap = @animatedBitmap.bitmap.clone
  end
  #-----------------------------------------------------------------------------
  #  set animation speed
  #-----------------------------------------------------------------------------
  def speed=(val)
    return if !self.animatedBitmap
    self.animatedBitmap.setSpeed(val)
  end
  #-----------------------------------------------------------------------------
  #  check if animation is finished
  #-----------------------------------------------------------------------------
  def finished?; return @animatedBitmap.finished?; end
  def animatedBitmap; return @animatedBitmap; end
  #-----------------------------------------------------------------------------
  #  update override for sprite animation
  #-----------------------------------------------------------------------------
  alias update_wrapper update unless self.method_defined?(:update_wrapper)
  def update
    update_wrapper
    return if @animatedBitmap.nil?
    @animatedBitmap.update
    self.bitmap = @animatedBitmap.bitmap.clone
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Custom Sprite class used in the Battle Scene
#===============================================================================
class DynamicPokemonSprite
  attr_accessor :shadow, :sprite, :index
  attr_accessor :showshadow, :hidden, :fainted, :isShadow, :charged, :noshadow
  attr_accessor :status, :anim, :dynamax, :scale_y, :legacy_anim
  attr_reader :loaded, :selected, :isSub, :pulse
  attr_reader :viewport, :pokemon, :species, :form
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' index: %s,', @index)
    str << format(' pokemon: %s>', @pokemon.inspect)
    return str
  end
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(doublebattle, index, viewport = nil, battle = nil)
    @viewport = viewport
    @selected = 0
    @frame = 0; @frame2 = 0; @frame3 = 0; @frame4 = 0
    # additional process variables
    @status = 0
    @form = 0
    @loaded = false
    @dynamax = false
    @battle = battle
    @index = index
    @doublebattle = doublebattle
    @showshadow = true
    @noshadow = false
    @altitude = 0
    @yposition = 0
    @ox = 0
    @oy = 0
    @scale_y = 1
    # creates necessary sprites
    @shadow = Sprite.new(@viewport)
    @sprite = Sprite.new(@viewport)
    @substitute = BitmapEBDX.new("Graphics/EBDX/Battlers/"+((@index%2 == 0) ? "substitute_back" : "substitute"), EliteBattle::FRONT_SPRITE_SCALE)
    @overlay = Sprite.new(@viewport)
    # additional process variables
    @isSub = false
    @lock = false
    @pokemon = nil
    @still = false
    @hidden = false
    @fainted = false
    @anim = false
    @isShadow = false
    @charged = false
    @species = nil
    @anchor = nil
    @legacy_anim = false
    @scale = 2
    @fp = {}
    # loads shadow particles for battler animation
    for i in 0...16
      @fp[i] = Sprite.new(@viewport)
      @fp[i].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebShadow")
      @fp[i].ox = @fp[i].bitmap.width/4
      @fp[i].oy = @fp[i].bitmap.height/2
      @fp[i].src_rect.set(0,0,@fp[i].bitmap.width/2,@fp[i].bitmap.height)
      @fp[i].opacity = 0
    end
    # loads aura charge particles
    for i in 0...12
      @fp["c#{i}"] = Sprite.new(@viewport)
      @fp["c#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebCharged")
      @fp["c#{i}"].ox = @fp["c#{i}"].bitmap.width/8
      @fp["c#{i}"].oy = @fp["c#{i}"].bitmap.height
      @fp["c#{i}"].src_rect.set(0,0,@fp["c#{i}"].bitmap.width/4,@fp["c#{i}"].bitmap.height)
      @fp["c#{i}"].opacity = 0
    end
    # dynamax aura
    for i in 0...16
      @fp["d#{i}"] = Sprite.new(@viewport)
      @fp["d#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebEnergy")
      @fp["d#{i}"].center!
      @fp["d#{i}"].opacity = 0
      @fp["d#{i}"].toggle = 1
    end
    @pulse = 8.0
    @k = 1
  end
  #-----------------------------------------------------------------------------
  #  additional attribute readers
  #-----------------------------------------------------------------------------
  def sideSize; return @battle.pbSideSize(@index); end
  def battleIndex; return @index; end
  def pbSetPosition(*args); end
  def delta; return Graphics.frame_rate/40.0; end
  def x; return @sprite.x; end
  def y; return @sprite.y; end
  def z; return @sprite.z; end
  def ox; return @sprite.ox; end
  def oy; return @sprite.oy; end
  def zoom_x; return @sprite.zoom_x; end
  def zoom_y; return @sprite.zoom_y; end
  def visible; return @sprite.visible; end
  def opacity; return @sprite.opacity; end
  def width; return @bitmap.width; end
  def height; return @bitmap.height; end
  def tone; return @sprite.tone; end
  def bitmap; return @bitmap.bitmap.clone; end
  def actualBitmap; return @bitmap; end
  def disposed?; return @sprite.disposed?; end
  def color; return @sprite.color; end
  def src_rect; return @sprite.src_rect; end
  def blend_type; return @sprite.blend_type; end
  def angle; return @sprite.angle; end
  def mirror; return @sprite.mirror; end
  def src_rect; return @sprite.src_rect; end
  def src_rect=(val)
    @sprite.src_rect=val
  end
  def anchor
    return nil if @anchor.nil?
    # applies scale
    x = self.x - self.ox*self.zoom_x + @anchor[0].to_i*self.zoom_x*@scale
    y = self.y - self.oy*self.zoom_y + @anchor[1].to_i*self.zoom_y*@scale
    return x, y
  end
  #-----------------------------------------------------------------------------
  # locks sprite animation
  #-----------------------------------------------------------------------------
  def lock
    @lock = true
  end
  #-----------------------------------------------------------------------------
  # force set bitmap
  #-----------------------------------------------------------------------------
  def bitmap=(val)
    @bitmap.bitmap = val
  end
  #-----------------------------------------------------------------------------
  # sets X value for sprite
  #-----------------------------------------------------------------------------
  def x=(val)
    @sprite.x = val
    @shadow.x = val if !@legacy_anim
  end
  #-----------------------------------------------------------------------------
  # sets ox
  #-----------------------------------------------------------------------------
  def ox=(val)
    @sprite.ox = val
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets .oy
  #-----------------------------------------------------------------------------
  def oy=(val)
    @sprite.oy=val
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets Y value for sprite
  #-----------------------------------------------------------------------------
  def y=(val)
    @sprite.y = val
    @shadow.y = val if !@legacy_anim
  end
  #-----------------------------------------------------------------------------
  # sets Z value for sprite
  #-----------------------------------------------------------------------------
  def z=(val)
    @shadow.z = (val == 32) ? 31 : 10
    @sprite.z = val < 11 ? 11 : val
  end
  #-----------------------------------------------------------------------------
  # sets horizontal zoom for sprite
  #-----------------------------------------------------------------------------
  def zoom_x=(val)
    @sprite.zoom_x = val
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets vertical zoom for sprite
  #-----------------------------------------------------------------------------
  def zoom_y=(val)
    @sprite.zoom_y = val
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets absolute zoom for sprite
  #-----------------------------------------------------------------------------
  def zoom=(val)
    self.zoom_x = val
    self.zoom_y = val
  end
  #-----------------------------------------------------------------------------
  # set visibility across all sprite elements
  #-----------------------------------------------------------------------------
  def visible=(val)
    return if @hidden
    @sprite.visible = val
    if @fp
      val = false if @hidden || @fainted
      for key in @fp.keys
        if key.is_a?(String) && key.include?("c")
          val = false if !@charged
        else
          val = false if !@isShadow
        end
        @fp[key].visible = val
      end
    end
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # gets target center of battler sprite
  #-----------------------------------------------------------------------------
  def getCenter(zoom = true)
    zoom = zoom ? self.zoom_y : 1
    x = self.x
    y = self.y + (self.bitmap.height - self.oy)*zoom - self.bitmap.height*zoom/2
    return x, y
  end
  #-----------------------------------------------------------------------------
  # gets target anchor of battler sprite
  #-----------------------------------------------------------------------------
  def getAnchor(zoom = true)
    anchor = self.anchor
    return getCenter(zoom) if !anchor
    return anchor
  end
  #-----------------------------------------------------------------------------
  # sets opacity to sprite
  #-----------------------------------------------------------------------------
  def opacity=(val)
    @sprite.opacity = val
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets tone to sprite
  #-----------------------------------------------------------------------------
  def tone=(val)
    @sprite.tone = val
  end
  #-----------------------------------------------------------------------------
  # sets color to all sprites
  #-----------------------------------------------------------------------------
  def color=(val)
    @sprite.color = val
  end
  #-----------------------------------------------------------------------------
  # sets sprite blend type
  #-----------------------------------------------------------------------------
  def blend_type=(val)
    @sprite.blend_type = val
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets sprite angle
  #-----------------------------------------------------------------------------
  def angle=(val)
    @sprite.angle = (val)
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets sprite mirror
  #-----------------------------------------------------------------------------
  def mirror=(val)
    @sprite.mirror = (val)
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # disposes sprite
  #-----------------------------------------------------------------------------
  def dispose
    @sprite.dispose
    @shadow.dispose
    @overlay.dispose
    @substitute.dispose if @substitute
    pbDisposeSpriteHash(@fp) if @fp
  end
  #-----------------------------------------------------------------------------
  # sets selected
  #-----------------------------------------------------------------------------
  def selected=(val)
    @selected = val
    @sprite.visible = true if !@hidden
  end
  #-----------------------------------------------------------------------------
  # applies value across all tone channels
  #-----------------------------------------------------------------------------
  def toneAll(val)
    @sprite.tone.red+=val
    @sprite.tone.green+=val
    @sprite.tone.blue+=val
  end
  #-----------------------------------------------------------------------------
  # loads bitmap based on file
  #-----------------------------------------------------------------------------
  def setBitmap(file, shadow = false)
    self.resetParticles
    @showshadow = shadow
    # loads plain bitmap (new bitmap wrapper)
    @bitmap = BitmapEBDX.new(file)
    # applies bitmap to sprite
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @loaded = true
    # formats battler shadow
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # loads bitmap based on battler data
  #-----------------------------------------------------------------------------
  def setPokemonBitmap(pokemon, back = false, species = nil)
    # resets all particles
    self.resetParticles
    # safety check
    return if !pokemon || pokemon.nil?
    @pokemon = pokemon
    @species = species.nil? ? pokemon.species : species
    @form = (@pokemon.form rescue 0)
    @isShadow = true if @pokemon.shadowPokemon?
    # loads Pokemon bitmap
    if !species.nil?
      @bitmap = pbLoadPokemonBitmapSpecies(pokemon, species, back)
    else
      @bitmap = pbLoadPokemonBitmap(pokemon, back)
    end
    # applies scale
    @scale = back ? EliteBattle::BACK_SPRITE_SCALE : EliteBattle::FRONT_SPRITE_SCALE
    # gets additional scale (if applicable)
    s = EliteBattle.get_data(species, :Species, (back ? :BACKSCALE : :SCALE), (form rescue 0))
    @scale = s if !s.nil? && s.is_a?(Numeric)
    # assigns bitmap to sprite
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    # applies battler positioning on screen
    self.refreshMetrics
    # refreshes process variables
    @fainted = false
    @loaded = true
    @hidden = false
    self.visible = true
    @pulse = 8
    @k = 1
    # formats battler shadow
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # resets additional animation particles to original state
  #-----------------------------------------------------------------------------
  def resetParticles
    if @fp
      for key in @fp.keys
        @fp[key].visible = false
      end
    end
    @isShadow = false
    @charged = false
    @dynamax = false
  end
  #-----------------------------------------------------------------------------
  # refreshes metrics for the Pokemon
  #-----------------------------------------------------------------------------
  def refreshMetrics(metrics = nil, species = nil)
    # applies sprite positioning
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    # allows for additional X or Y positioning through EliteBattle handler
    species = species.nil? ? @pokemon.species : species
    # sauce
    species = :BIDOOF if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
    if species
      x = EliteBattle.get_data(species, :Species, (@index%2 == 0) ? :PX : :EX, (@pokemon.form rescue 0))
      y = EliteBattle.get_data(species, :Species, (@index%2 == 0) ? :PY : :EY, (@pokemon.form rescue 0))
      a = EliteBattle.get_data(species, :Species, :ALTITUDE, (@pokemon.form rescue 0))
      @sprite.ox -= x if !x.nil? && x.is_a?(Numeric)
      @sprite.oy -= y if !y.nil? && y.is_a?(Numeric)
      @sprite.oy += a if !a.nil? && a.is_a?(Numeric)
      # refresh anchor metrics
      anchor = @index%2 == 0 ? :BACKANCHOR : :ANCHOR
      # get anchor from data
      @anchor = EliteBattle.get_data(species, :Species, anchor, (@pokemon.form rescue 0))
    end
    @ox = @sprite.ox
    @oy = @sprite.oy
  end
  def pbSetOrigin
    @sprite.ox = @ox
    @sprite.oy = @oy
  end
  #-----------------------------------------------------------------------------
  # toggles from battler sprite to Substitute sprite
  #-----------------------------------------------------------------------------
  def setSubstitute
    @isSub = true
    @sprite.bitmap = @substitute.bitmap.clone
    @shadow.bitmap = @substitute.bitmap.clone
    @sprite.ox = @substitute.width/2
    @sprite.oy = @substitute.height
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # toggles from Substitute sprite to battler sprite
  #-----------------------------------------------------------------------------
  def removeSubstitute
    @isSub = false
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height
    @sprite.oy += @altitude
    @sprite.oy -= @yposition
    @sprite.oy -= @pokemon.formOffsetY if @pokemon && @pokemon.respond_to?(:formOffsetY)
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # skips one animation frame
  #-----------------------------------------------------------------------------
  def still
    @still = true
  end
  #-----------------------------------------------------------------------------
  # clears entire bitmap
  #-----------------------------------------------------------------------------
  def clear
    @sprite.bitmap.clear
    @bitmap.dispose
  end
  #-----------------------------------------------------------------------------
  # formates the shadow skew and opacity
  #-----------------------------------------------------------------------------
  def formatShadow
    return if @legacy_anim
    sc = @scale_y.nil? ? 1 : @scale_y # safety
    @shadow.zoom_x = @sprite.zoom_x
    @shadow.zoom_y = (@sprite.zoom_y*sc*0.25)*(@index%2 == 0 ? 1 : 0.5)
    @shadow.ox = @sprite.ox - 12
    @shadow.oy = (@sprite.oy - 6)
    @shadow.opacity = @sprite.opacity*0.3
    @shadow.tone = Tone.new(-255,-255,-255,255)
    @shadow.visible = @sprite.visible
    @shadow.mirror = @sprite.mirror
    @shadow.angle = @sprite.angle
    # hides shadow if not toggled
    @shadow.visible = false if !@showshadow || @noshadow
  end
  #-----------------------------------------------------------------------------
  # plays animation frames
  #-----------------------------------------------------------------------------
  def play
    @bitmap.play
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # sets animation frame
  #-----------------------------------------------------------------------------
  def setFrame(frame)
    return if !@bitmap
    @bitmap.to_frame(frame)
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # animates battler sprite
  #-----------------------------------------------------------------------------
  def update(scale_y = nil)
    @scale_y = scale_y if !scale_y.nil?
    # skips animation if sprite is supposed to be still
    if @still
      @still = false
      return
    end
    return if @lock
    return if !@bitmap || @bitmap.disposed?
    # applies proper battler bitmap based on whether or not the battler is behind
    # a Substitute
    if @isSub
      @substitute.update
      @sprite.bitmap = @substitute.bitmap.clone
      @shadow.bitmap = @substitute.bitmap.clone
    else
      @bitmap.update
      @sprite.bitmap = @bitmap.bitmap.clone
      @shadow.bitmap = @bitmap.bitmap.clone
    end
    # applies color overlay based on status condition
    if !@anim && !@pulse.nil?
      @pulse += @k/self.delta
      @k *= -1 if @pulse >= 128 || @pulse <= 8
      case @status
      when 0
        @sprite.color = Color.new(0, 0, 0, 0)
      when 1 #PSN
        @sprite.color = Color.new(109, 55, 130, @pulse)
      when 2 #PAR
        @sprite.color = Color.new(204, 152, 44, @pulse)
      when 3 #FRZ
        @sprite.color = Color.new(56, 160, 193, @pulse)
      when 4 #BRN
        @sprite.color = Color.new(206, 73, 43, @pulse)
      end
      @sprite.color = Color.new(204, 38, 92, @pulse*0.5) if @status < 1 && @dynamax
      @sprite.color = Color.new(221, 68, 92, @pulse) if @status < 1 && @charged
    end
    @anim = false
    # Pokemon sprite blinking when targeted or damaged
    @frame += 1
    @frame = 0 if @frame > 256
    if @selected == 2 # When targeted or damaged
      @sprite.visible = ((@frame/self.delta).round%10 < 7) && !@hidden
    end
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
  # adds smokey shadow effects to battlers
  #-----------------------------------------------------------------------------
  def shadowUpdate
    # decides whether or not to run the animation
    return if !@loaded
    return if self.disposed? || @bitmap.disposed?
    # animates shadow particles
    for i in 0...16
      next if i > @frame2*self.delta/4
      @fp[i].visible = @showshadow
      @fp[i].visible = false if @hidden
      @fp[i].visible = false if !@isShadow
      next if !@isShadow
      if @fp[i].opacity <= 0
        @fp[i].toggle = 2
        z = [0.5,0.6,0.7,0.8,0.9,1.0][rand(6)]
        @fp[i].param = z
        @fp[i].x = self.x - self.bitmap.width*self.zoom_x/2 + rand(self.bitmap.width)*self.zoom_x
        @fp[i].y = self.y - 64*self.zoom_y + rand(64)*self.zoom_y
        @fp[i].z = (rand(2)==0) ? self.z - 1 : self.z + 1
        @fp[i].speed = (rand(2)==0) ? +1 : -1
        @fp[i].src_rect.x = rand(2)*@fp[i].bitmap.width/2
      end
      @fp[i].zoom_x = @fp[i].param*self.zoom_x
      @fp[i].zoom_y = @fp[i].param*self.zoom_y
      @fp[i].param -= 0.01/self.delta
      @fp[i].y -= 1
      @fp[i].opacity += 8*@fp[i].toggle/self.delta
      @fp[i].toggle = -1 if @fp[i].opacity >= 255
    end
    @frame2 += 1 if @frame2 < 128
  end
  #-----------------------------------------------------------------------------
  # adds charged particle animation (for Aura)
  #-----------------------------------------------------------------------------
  def chargedUpdate
    return if !@loaded
    return if self.disposed? || @bitmap.disposed?
    for i in 0...12
      next if i > @frame3*self.delta/16
      @fp["c#{i}"].visible = @showshadow
      @fp["c#{i}"].visible = false if @hidden
      @fp["c#{i}"].visible = false if !@charged
      next if !@charged
      if @fp["c#{i}"].opacity <= 0
        x = @sprite.x - @sprite.ox*@sprite.zoom_x + rand(@sprite.bitmap.width*@sprite.zoom_x)
        y = @sprite.y - @sprite.oy*0.7*@sprite.zoom_y + rand(@sprite.bitmap.height*0.8*@sprite.zoom_y)
        @fp["c#{i}"].x = x
        @fp["c#{i}"].y = y
        @fp["c#{i}"].z = (rand(2)==0) ? self.z - 1 : self.z + 1
        @fp["c#{i}"].src_rect.x = rand(4)*@fp["c#{i}"].bitmap.width/4
        @fp["c#{i}"].zoom_y = 0.6*@sprite.zoom_y
        @fp["c#{i}"].zoom_x = @sprite.zoom_x
        @fp["c#{i}"].opacity = 166 + rand(90)
        @fp["c#{i}"].mirror = (x < @sprite.x) ? false : true
      end
      @fp["c#{i}"].zoom_y += 0.1*@sprite.zoom_y/self.delta
      @fp["c#{i}"].opacity -= 16/self.delta
    end
    @frame3 += 1 if @frame3 < 256
  end
  #-----------------------------------------------------------------------------
  # adds Dynamax energy particles
  #-----------------------------------------------------------------------------
  def energyUpdate
    return if !@loaded
    return if self.disposed? || @bitmap.disposed?
    for i in 0...16
      next if i > @frame4*self.delta/8
      @fp["d#{i}"].visible = @dynamax
      @fp["d#{i}"].visible = false if @hidden
      next if !@dynamax
      if @fp["d#{i}"].opacity <= 0
        x = @sprite.x - @sprite.ox*@sprite.zoom_x + rand(@sprite.bitmap.width*0.4*@sprite.zoom_x) + (@sprite.bitmap.width*0.3*@sprite.zoom_x)
        y = @sprite.y - @sprite.oy*0.7*@sprite.zoom_y - rand(@sprite.oy*0.1*@sprite.zoom_y)
        r = rand(40)/100.0
        @fp["d#{i}"].x = x
        @fp["d#{i}"].y = y
        @fp["d#{i}"].z = (rand(2)==0) ? self.z - 1 : self.z + 1
        @fp["d#{i}"].zoom_y = 0.6 + r
        @fp["d#{i}"].zoom_x = 0.6 + r
        @fp["d#{i}"].opacity = 166 + rand(90)
        @fp["d#{i}"].mirror = (x < @sprite.x) ? false : true
        @fp["d#{i}"].toggle = rand(2) == 0 ? 1 : -1
      end
      @fp["d#{i}"].zoom_x -= 0.02/self.delta
      @fp["d#{i}"].zoom_y -= 0.02/self.delta
      @fp["d#{i}"].opacity -= 8/self.delta
      @fp["d#{i}"].angle += 2*@fp["d#{i}"].toggle/self.delta
    end
    @frame4 += 1 if @frame4 < 256
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Animated trainer sprites (child of DynamicPokemonSprite)
#===============================================================================
class DynamicTrainerSprite  <  DynamicPokemonSprite
  attr_accessor :noshadow
  #-----------------------------------------------------------------------------
  # class constructor
  #-----------------------------------------------------------------------------
  def initialize(doublebattle, index, viewport = nil, trarray = false, trainer = nil)
    @viewport = viewport
    @trarray = trarray
    @trainer = trainer
    @selected = 0
    @frame = 0
    @frame2 = 0
    # additional variables
    @status = 0
    @loaded = false
    @index = index
    @doublebattle = doublebattle
    @showshadow = true
    @noshadow = false
    @altitude = 0
    @yposition = 0
    @shadow = Sprite.new(@viewport)
    @sprite = Sprite.new(@viewport)
    @overlay = Sprite.new(@viewport)
    @lock = false
  end
  #-----------------------------------------------------------------------------
  # gets the total number of animation frames for sprite
  #-----------------------------------------------------------------------------
  # gets the total number of animation frames for sprite
  def totalFrames; @bitmap.animationFrames; end
  # jumps to last animation frame of sprite
  def toLastFrame
    return if !@bitmap
    @bitmap.to_frame("last")
    @sprite.bitmap = @bitmap.bitmap
    @shadow.bitmap = @bitmap.bitmap
    self.formatShadow
  end
  def selected; end
  #-----------------------------------------------------------------------------
  # function to set the Trainer bitmap
  #-----------------------------------------------------------------------------
  def setTrainerBitmap(file = nil)
    # gets trainer ID
    file = GameData::TrainerType.front_sprite_filename(@trainer.trainer_type) if file.nil? && !@trainer.nil?
    trainerid = file.nil? ? nil : EliteBattle.id_from_trainer_file(file) if !file.nil?
    # gets additional scale (if applicable)
    s = EliteBattle.get_trainer_data(trainerid, :SCALE, @trainer)
    scale = (!s.nil? && s.is_a?(Numeric)) ? s : EliteBattle::TRAINER_SPRITE_SCALE
    sp = EliteBattle.get_trainer_data(trainerid, :SPRITESPEED, @trainer)
    speed = (!sp.nil? && sp.is_a?(Numeric)) ? sp : 2
    # loads bitmap
    if !pbResolveBitmap(file)
      tfile = @trainer.nil? ? nil : "Graphics/Trainers/#{@trainer.trainer_type}"
      EliteBattle.log.warn("Could not find the Trainer sprite: #{file.nil? ? tfile : file}")
      file = "Graphics/EBDX/Battlers/000"
    end
    @bitmap = BitmapEBDX.new(file, scale, speed)
    # assigns bitmap
    @sprite.bitmap = @bitmap.bitmap.clone
    @shadow.bitmap = @bitmap.bitmap.clone
    @sprite.ox = @bitmap.width/2
    @sprite.oy = @bitmap.height - 16
    # allows for additional X or Y positioning through script
    x = EliteBattle.get_trainer_data(trainerid, :X, @trainer)
    y = EliteBattle.get_trainer_data(trainerid, :Y, @trainer)
    a = EliteBattle.get_trainer_data(trainerid, :ALTITUDE, @trainer)
    @sprite.ox -= x if !x.nil? && x.is_a?(Numeric)
    @sprite.oy -= y if !y.nil? && y.is_a?(Numeric)
    @sprite.oy += a if !a.nil? && a.is_a?(Numeric)
    # formats the underlying shadow
    self.formatShadow
  end
  #-----------------------------------------------------------------------------
end
