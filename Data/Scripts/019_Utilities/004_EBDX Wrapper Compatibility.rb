#-------------------------------------------------------------------------------
#  New bitmap wrapper by Luka S.J. EBDX sprites
#  Creates an animated bitmap (different from regular bitmaps)
#-------------------------------------------------------------------------------
class EBDXBitmapWrapper
  attr_reader :width, :height, :totalFrames, :animationFrames, :currentIndex
  attr_accessor :constrict, :scale, :frameSkip, :constrict_x, :constrict_y
  #-----------------------------------------------------------------------------
  @@disableBitmapAnimation = false
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(file, scale = Settings::FRONT_BATTLER_SPRITE_SCALE, skip = 1)
    # failsafe checks
    raise "EBDXBitmapWrapper filename is nil." if file.nil?
    raise "EBDXBitmapWrapper does not support GIF files." if File.extname(file) == ".gif"
    #---------------------------------------------------------------------------
    @scale = scale
    @constrict = nil
    @width = 0
    @height = 0
    @frame = 0
    @frames = 2
    @frameSkip = skip
    @direction = 1
    @animationFinish = false
    @totalFrames = 0
    @currentIndex = 0
    @changed_hue = false
    @speed = 1
      # 0 - not moving at all
      # 1 - normal speed
      # 2 - medium speed
      # 3 - slow speed
    @bitmapFile = file
    # initializes full Pokemon bitmap
    @bitmaps = []
    #---------------------------------------------------------------------------
    self.refresh
    #---------------------------------------------------------------------------
  end
  #-----------------------------------------------------------------------------
  #  check if already a bitmap
  #-----------------------------------------------------------------------------
  def is_bitmap?
    return @bitmapFile.is_a?(BitmapWrapper) || @bitmapFile.is_a?(Bitmap)
  end
  #-----------------------------------------------------------------------------
  #  returns proper object values when requested
  #-----------------------------------------------------------------------------
  def delta; return Graphics.frame_rate/40.0; end
  def length; return @totalFrames; end
  def disposed?; return @bitmaps.length < 1; end
  def dispose
    for bmp in @bitmaps
      bmp.dispose
    end
    @bitmaps.clear
    @tempBmp.dispose if @tempBmp && !@tempBmp.disposed?
  end
  def copy; return @bitmaps[@currentIndex].clone; end
  def bitmap
    return @bitmapFile if self.is_bitmap? && !@bitmapFile.disposed?
    return nil if self.disposed?
    # applies constraint if applicable
    x, y, w, h = self.box
    @tempBmp.clear
    @tempBmp.blt(x, y, @bitmaps[@currentIndex], Rect.new(x, y, w, h))
    return @tempBmp
  end
  def bitmap=(val)
    return if !val.is_a?(String)
    @bitmapFile = val
    self.refresh
  end
  def each; end
  def alter_bitmap(index); return @strip[index]; end
  #-----------------------------------------------------------------------------
  #  preparation and compiling of spritesheet for sprite alterations
  #-----------------------------------------------------------------------------
  def prepare_strip
    @strip = []
    bmp = Bitmap.new(@bitmapFile)
    for i in 0...@totalFrames
      bitmap = Bitmap.new(@width, @height)
      bitmap.stretch_blt(Rect.new(0, 0, @width, @height), bmp, Rect.new((@width/@scale)*i, 0, @width/@scale, @height/@scale))
      @strip.push(bitmap)
    end
  end
  def compile_strip
    self.refresh(@strip)
  end
  #-----------------------------------------------------------------------------
  #  creates custom loop if defined in data
  #-----------------------------------------------------------------------------
  def compile_loop(data)
    # temporarily load the full file
    f_bmp = Bitmap.new(@bitmapFile)
    r = f_bmp.height; w = 0; x = 0
    @width = r*@scale
    @height = r*@scale
    bitmaps = []
    # calculate total bitmap width
    for p in data
      w += p[:range].to_a.length * p[:repeat] * r
    end
    # compile strip from data
    for m in 0...data.length
      range = data[m][:range].to_a
      repeat = data[m][:repeat]
      # offset based on previous frames
      x += m > 0 ? (data[m-1][:range].to_a.length * data[m-1][:repeat] * r) : 0
      for i in 0...repeat
        for j in 0...range.length
          # create new bitmap
          bitmap = Bitmap.new(@width, @height)
          # draws frame from repeated ranges
          bitmap.stretch_blt(Rect.new(0, 0, @width, @height), f_bmp, Rect.new(range[j]*r, 0, r, r))
          bitmaps.push(bitmap)
        end
      end
    end
    f_bmp.dispose
    self.refresh(bitmaps)
  end
  #-----------------------------------------------------------------------------
  #  refreshes the metric parameters
  #-----------------------------------------------------------------------------
  def refresh(bitmaps = nil)
    # dispose existing
    self.dispose
    # temporarily load the full file
    if bitmaps.nil? && @bitmapFile.is_a?(String)
      # calculate initial metrics
      f_bmp = Bitmap.new(@bitmapFile)
      @width = f_bmp.height*@scale
      @height = f_bmp.height*@scale
      # construct frames
      for i in 0...(f_bmp.width.to_f/f_bmp.height).ceil
        x = i*f_bmp.height
        bitmap = Bitmap.new(@width, @height)
        bitmap.stretch_blt(Rect.new(0, 0, @width, @height), f_bmp, Rect.new(x, 0, f_bmp.height, f_bmp.height))
        @bitmaps.push(bitmap)
      end
      f_bmp.dispose
    else
      @bitmaps = bitmaps
    end
    if @bitmaps.length < 1 && !self.is_bitmap?
      raise "Unable to construct proper bitmap sheet from `#{@bitmapFile}`"
    end
    # calculates the total number of frames
    if !self.is_bitmap?
      @totalFrames = @bitmaps.length
      @animationFrames = @totalFrames*@frames
      @tempBmp = Bitmap.new(@bitmaps[0].width, @bitmaps[0].width)
    end
  end
  #-----------------------------------------------------------------------------
  #  reverses the animation
  #-----------------------------------------------------------------------------
  def reverse
    if @direction  >  0
      @direction = -1
    elsif @direction < 0
      @direction = +1
    end
  end
  #-----------------------------------------------------------------------------
  #  sets speed of animation
  #-----------------------------------------------------------------------------
  def setSpeed(value)
    @speed = value
  end
  #-----------------------------------------------------------------------------
  #  jumps animation to specific frame
  #-----------------------------------------------------------------------------
  def to_frame(frame)
    # checks if specified string parameter
    if frame.is_a?(String)
      if frame == "last"
        frame = @totalFrames - 1
      else
        frame = 0
      end
    end
    # sets frame
    frame = @totalFrames - 1 if frame >= @totalFrames
    frame = 0 if frame < 0
    @currentIndex = frame
  end
  #-----------------------------------------------------------------------------
  #  changes the hue of the bitmap
  #-----------------------------------------------------------------------------
  def hue_change(value)
    for bmp in @bitmaps
      bmp.hue_change(value)
    end
    @changed_hue = true
  end
  def changedHue?; return @changed_hue; end
  #-----------------------------------------------------------------------------
  #  performs animation loop once
  #-----------------------------------------------------------------------------
  def play
    return if self.finished?
    self.update
  end
  #-----------------------------------------------------------------------------
  #  checks if animation is finished
  #-----------------------------------------------------------------------------
  def finished?
    return (@currentIndex >= @totalFrames - 1)
  end
  #-----------------------------------------------------------------------------
  #  fetches the constraints for the sprite
  #-----------------------------------------------------------------------------
  def box
    if !@constrict_x.nil? && @constrict_x <= @width
      x = ((@width-@constrict_x)/2.0).ceil
      w = @constrict_x
    elsif !@constrict.nil? && @constrict <= @width
      x = ((@width-@constrict)/2.0).ceil
      w = @constrict
    else
      x = 0
      w = @width
    end
    if !@constrict_y.nil? && @constrict_y <= @height
      y = ((@height-@constrict_y)/2.0).ceil
      h = @constrict_y
    elsif !@constrict.nil? && @constrict <= @height
      y = ((@height-@constrict)/2.0).ceil
      h = @constrict
    else
      y = 0
      h = @height
    end
    return x, y, w, h
  end
  #-----------------------------------------------------------------------------
  #  performs sprite animation
  #-----------------------------------------------------------------------------
  def update
    return false if @@disableBitmapAnimation
    return false if self.disposed?
    return false if @speed < 1
    case @speed
    # frame skip
    when 2
      @frames = 4
    when 3
      @frames = 5
    else
      @frames = 2
    end
    @frame += 1
    if @frame >= @frames*@frameSkip*self.delta
      # processes animation speed
      @currentIndex += @direction
      @currentIndex = 0 if @currentIndex >= @totalFrames
      @currentIndex = @totalFrames - 1 if @currentIndex < 0
      @frame = 0
    end
  end
  #-----------------------------------------------------------------------------
  #  returns bitmap to original state
  #-----------------------------------------------------------------------------
  def deanimate
    @frame = 0
    @currentIndex = 0
  end
  #-----------------------------------------------------------------------------
  #  disables animation completely
  #-----------------------------------------------------------------------------
  def disable_animation(val = true)
    @@disableBitmapAnimation = val
  end
  #-----------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
#  aliasing the old Pokemon Sprite Functions and fixing UI overflow issues
#-------------------------------------------------------------------------------
if !defined?(EliteBattle)
  #-----------------------------------------------------------------------------
  #  All Pokemon Sprite files now return EBSBitmapWrapper
  #-----------------------------------------------------------------------------
  module GameData
    class Species
      def self.front_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
        filename = self.front_sprite_filename(species, form, gender, shiny, shadow)
        sp_data  = GameData::Species.get_species_form(species, form)
        scale    = sp_data ? sp_data.front_sprite_scale : Settings::FRONT_BATTLER_SPRITE_SCALE
        return (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
      end

      def self.back_sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false)
        filename = self.back_sprite_filename(species, form, gender, shiny, shadow)
        sp_data  = GameData::Species.get_species_form(species, form)
        scale    = sp_data ? sp_data.back_sprite_scale : Settings::BACK_BATTLER_SPRITE_SCALE
        return (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
      end

      def self.egg_sprite_bitmap(species, form = 0)
        filename = self.egg_sprite_filename(species, form)
        sp_data  = GameData::Species.get_species_form(species, form)
        scale    = sp_data ? sp_data.front_sprite_scale : Settings::FRONT_BATTLER_SPRITE_SCALE
        return (filename) ? EBDXBitmapWrapper.new(filename, scale) : nil
      end

      def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
        species = pkmn.species if !species
        species = GameData::Species.get(species).species   # Just to be sure it's a symbol
        return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
        if back
          ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
        else
          ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
        end
        alter_bitmap_function = nil
        alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap") if ret && ret.totalFrames == 1
        return ret if !alter_bitmap_function
        ret.prepare_strip
        for i in 0...ret.totalFrames
          alter_bitmap_function.call(pkmn, ret.alter_bitmap(i))
        end
        ret.compile_strip
        return ret
      end
    end
  end

  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap
  #-----------------------------------------------------------------------------
  class PokemonSprite < SpriteWrapper
    def constrict(amt, deanimate = false)
      if amt.is_a?(Array)
        @_iconbitmap.constrict_x = amt[0] if @_iconbitmap.respond_to?(:constrict_x)
        @_iconbitmap.constrict_y = amt[1] if @_iconbitmap.respond_to?(:constrict_y)
        @_iconbitmap.constrict   = amt.max if @_iconbitmap.respond_to?(:constrict)
      else
        @_iconbitmap.constrict = amt if @_iconbitmap.respond_to?(:constrict)
      end
      @_iconbitmap.setSpeed(0) if @_iconbitmap.respond_to?(:setSpeed) && deanimate
      @_iconbitmap.deanimate if @_iconbitmap.respond_to?(:deanimate) && deanimate
    end
  end

  #-----------------------------------------------------------------------------
  #  fix misalignment and add box constraints in Pokedex Info Screen
  #-----------------------------------------------------------------------------
  class PokemonPokedexInfo_Scene
    alias pbUpdateDummyPokemon_gen8 pbUpdateDummyPokemon
    def pbUpdateDummyPokemon
      pbUpdateDummyPokemon_gen8
      return if defined?(EliteBattle)
      sp_data = GameData::Species.get_species_form(@species, @form)
      @sprites["infosprite"].constrict([208, 200])
      @sprites["formfront"].constrict([200, 196]) if @sprites["formfront"]
      if @sprites["formback"]
        @sprites["formback"].constrict([300, 294])
        if sp_data.back_sprite_scale != sp_data.front_sprite_scale
          @sprites["formback"].setOffset(PictureOrigin::Center)
          @sprites["formback"].y = @sprites["formfront"].y if @sprites["formfront"]
          @sprites["formback"].zoom_x = (sp_data.front_sprite_scale.to_f / sp_data.back_sprite_scale)
          @sprites["formback"].zoom_y = (sp_data.front_sprite_scale.to_f / sp_data.back_sprite_scale)
        end
      end
    end
  end

  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap in Pokedex Menu
  #-----------------------------------------------------------------------------
  class PokemonPokedex_Scene
    alias setIconBitmap_gen8 setIconBitmap
    def setIconBitmap(*args)
      setIconBitmap_gen8(*args)
      @sprites["icon"].constrict([224, 216]) if !defined?(EliteBattle)
    end
  end


  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap in Storage Menu
  #-----------------------------------------------------------------------------
  class PokemonStorageScene
    alias pbUpdateOverlay_gen8 pbUpdateOverlay
    def pbUpdateOverlay(*args)
      pbUpdateOverlay_gen8(*args)
      @sprites["pokemon"].constrict(168, true) if !defined?(EliteBattle)
    end
  end

  #-----------------------------------------------------------------------------
  #  Adding Box constraints to the Pokemon Sprite Bitmap in Summary Screen
  #-----------------------------------------------------------------------------
  class PokemonSummary_Scene
    def pbFadeInAndShow(sprites)
      @sprites["pokemon"].constrict([208, 164]) if @sprites["pokemon"] if !defined?(EliteBattle)
      numFrames = (Graphics.frame_rate*0.4).floor
      alphaDiff = (255.0/numFrames).ceil
      pbDeactivateWindows(sprites) {
        for j in 0..numFrames
          pbSetSpritesToColor(sprites,Color.new(0,0,0,((numFrames-j)*alphaDiff)))
          (block_given?) ? yield : pbUpdateSpriteHash(sprites)
        end
      }
    end

    alias pbChangePokemon_gen8 pbChangePokemon
    def pbChangePokemon
      pbChangePokemon_gen8
      @sprites["pokemon"].constrict([208, 164]) if !defined?(EliteBattle)
    end
  end
end

PluginManager.register({
  :name => "Generation 8 Project for Essentials v19.1",
  :version => "#{Essentials::GEN_8_VERSION}",
  :credits => ["Golisopod User", "Vendily", "TheToxic",
               "HM100", "Aioross", "WolfPP", "MFilice",
               "lolface", "KyureJL", "DarrylBD99",
               "Turn20Negate", "TheKandinavian",
               "ErwanBeurier", "Luka S.J.", "Maruno"]
})

Essentials::ERROR_TEXT += "[Generation 8 Project v#{Essentials::GEN_8_VERSION}]\r\n"
