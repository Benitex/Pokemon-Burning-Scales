#===============================================================================
#  New animation wrapper for EBDX sprites
#  Creates an animated bitmap (different from regular bitmaps)
#===============================================================================
class BitmapEBDX
  attr_reader :width, :height, :totalFrames, :animationFrames, :currentIndex
  attr_accessor :constrict, :scale, :frameSkip
  #-----------------------------------------------------------------------------
  @@disableBitmapAnimation = false
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(file, scale = 2, skip = 1)
    # failsafe checks
    EliteBattle.log.error("BitmapEBDX filename is nil.") if file == nil
    EliteBattle.log.error("BitmapEBDX does not support GIF files.") if File.extname(file) == ".gif"
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
      EliteBattle.log.error("Unable to construct proper bitmap sheet from `#{@bitmapFile}`")
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
    x = (@constrict.nil? || @width <= @constrict) ? 0 : ((@width-@constrict)/2.0).ceil
    y = (@constrict.nil? || @width <= @constrict) ? 0 : ((@height-@constrict)/2.0).ceil
    w = (@constrict.nil? || @width <= @constrict) ? @width : @constrict
    h = (@constrict.nil? || @width <= @constrict) ? @height : @constrict
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
