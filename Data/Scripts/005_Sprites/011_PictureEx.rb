class PictureOrigin
  TopLeft     = 0
  Center      = 1
  TopRight    = 2
  BottomLeft  = 3
  LowerLeft   = 3
  BottomRight = 4
  LowerRight  = 4
  Top         = 5
  Bottom      = 6
  Left        = 7
  Right       = 8
end



class Processes
  XY         = 0
  DeltaXY    = 1
  Z          = 2
  Curve      = 3
  Zoom       = 4
  Angle      = 5
  Tone       = 6
  Color      = 7
  Hue        = 8
  Opacity    = 9
  Visible    = 10
  BlendType  = 11
  SE         = 12
  Name       = 13
  Origin     = 14
  Src        = 15
  SrcSize    = 16
  CropBottom = 17
end



def getCubicPoint2(src,t)
  x0  = src[0];  y0 = src[1]
  cx0 = src[2]; cy0 = src[3]
  cx1 = src[4]; cy1 = src[5]
  x1  = src[6];  y1 = src[7]

  x1 = cx1+(x1-cx1)*t
  x0 = x0+(cx0-x0)*t
  cx0 = cx0+(cx1-cx0)*t
  cx1 = cx0+(x1-cx0)*t
  cx0 = x0+(cx0-x0)*t
  cx = cx0+(cx1-cx0)*t
  # a = x1 - 3 * cx1 + 3 * cx0 - x0
  # b = 3 * (cx1 - 2 * cx0 + x0)
  # c = 3 * (cx0 - x0)
  # d = x0
  # cx = a*t*t*t + b*t*t + c*t + d
  y1 = cy1+(y1-cy1)*t
  y0 = y0+(cy0-y0)*t
  cy0 = cy0+(cy1-cy0)*t
  cy1 = cy0+(y1-cy0)*t
  cy0 = y0+(cy0-y0)*t
  cy = cy0+(cy1-cy0)*t
  # a = y1 - 3 * cy1 + 3 * cy0 - y0
  # b = 3 * (cy1 - 2 * cy0 + y0)
  # c = 3 * (cy0 - y0)
  # d = y0
  # cy = a*t*t*t + b*t*t + c*t + d
  return [cx,cy]
end



#===============================================================================
# PictureEx
#===============================================================================
class PictureEx
  attr_accessor :x              # x-coordinate
  attr_accessor :y              # y-coordinate
  attr_accessor :z              # z value
  attr_accessor :zoom_x         # x directional zoom rate
  attr_accessor :zoom_y         # y directional zoom rate
  attr_accessor :angle          # rotation angle
  attr_accessor :tone           # tone
  attr_accessor :color          # color
  attr_accessor :hue            # filename hue
  attr_accessor :opacity        # opacity level
  attr_accessor :visible        # visibility boolean
  attr_accessor :blend_type     # blend method
  attr_accessor :name           # file name
  attr_accessor :origin         # starting point
  attr_reader   :src_rect       # source rect
  attr_reader   :cropBottom     # crops sprite to above this y-coordinate
  attr_reader   :frameUpdates   # Array of processes updated in a frame

  def initialize(z)
    # process: [type, delay, total_duration, frame_counter, cb, etc.]
    @processes     = []
    @x             = 0.0
    @y             = 0.0
    @z             = z
    @zoom_x        = 100.0
    @zoom_y        = 100.0
    @angle         = 0
    @rotate_speed  = 0
    @tone          = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @color         = Color.new(0, 0, 0, 0)
    @hue           = 0
    @opacity       = 255.0
    @visible       = true
    @blend_type    = 0
    @name          = ""
    @origin        = PictureOrigin::TopLeft
    @src_rect      = Rect.new(0,0,-1,-1)
    @cropBottom    = -1
    @frameUpdates  = []
  end

  def callback(cb)
    if cb.is_a?(Proc);      cb.call(self)
    elsif cb.is_a?(Array);  cb[0].method(cb[1]).call(self)
    elsif cb.is_a?(Method); cb.call(self)
    end
  end

  def setCallback(delay, cb=nil)
    delay = ensureDelayAndDuration(delay)
    @processes.push([nil,delay,0,0,cb])
  end

  def running?
    return @processes.length>0
  end

  def totalDuration
    ret = 0
    for process in @processes
      dur = process[1]+process[2]
      ret = dur if dur>ret
    end
    ret *= 20.0/Graphics.frame_rate
    return ret.to_i
  end

  def ensureDelayAndDuration(delay, duration=nil)
    delay = self.totalDuration if delay<0
    delay *= Graphics.frame_rate/20.0
    if !duration.nil?
      duration *= Graphics.frame_rate/20.0
      return delay.to_i, duration.to_i
    end
    return delay.to_i
  end

  def ensureDelay(delay)
    return ensureDelayAndDuration(delay)
  end

  # speed is the angle to change by in 1/20 of a second. @rotate_speed is the
  # angle to change by per frame.
  # NOTE: This is not compatible with manually changing the angle at a certain
  #       point. If you make a sprite auto-rotate, you should not try to alter
  #       the angle another way too.
  def rotate(speed)
    @rotate_speed = speed*20.0/Graphics.frame_rate
    while @rotate_speed<0; @rotate_speed += 360; end
    @rotate_speed %= 360
  end

  def erase
    self.name = ""
  end

  def clearProcesses
    @processes = []
  end

  def adjustPosition(xOffset, yOffset)
    for process in @processes
      next if process[0]!=Processes::XY
      process[5] += xOffset
      process[6] += yOffset
      process[7] += xOffset
      process[8] += yOffset
    end
  end

  def move(delay, duration, origin, x, y, zoom_x=100.0, zoom_y=100.0, opacity=255)
    setOrigin(delay,duration,origin)
    moveXY(delay,duration,x,y)
    moveZoomXY(delay,duration,zoom_x,zoom_y)
    moveOpacity(delay,duration,opacity)
  end

  def moveXY(delay, duration, x, y, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::XY,delay,duration,0,cb,@x,@y,x,y])
  end

  def setXY(delay, x, y, cb=nil)
    moveXY(delay,0,x,y,cb)
  end

  def moveCurve(delay, duration, x1, y1, x2, y2, x3, y3, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::Curve,delay,duration,0,cb,[@x,@y,x1,y1,x2,y2,x3,y3]])
  end

  def moveDelta(delay, duration, x, y, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::DeltaXY,delay,duration,0,cb,@x,@y,x,y])
  end

  def setDelta(delay, x, y, cb=nil)
    moveDelta(delay,0,x,y,cb)
  end

  def moveZ(delay, duration, z, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::Z,delay,duration,0,cb,@z,z])
  end

  def setZ(delay, z, cb=nil)
    moveZ(delay,0,z,cb)
  end

  def moveZoomXY(delay, duration, zoom_x, zoom_y, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::Zoom,delay,duration,0,cb,@zoom_x,@zoom_y,zoom_x,zoom_y])
  end

  def setZoomXY(delay, zoom_x, zoom_y, cb=nil)
    moveZoomXY(delay,0,zoom_x,zoom_y,cb)
  end

  def moveZoom(delay, duration, zoom, cb=nil)
    moveZoomXY(delay,duration,zoom,zoom,cb)
  end

  def setZoom(delay, zoom, cb=nil)
    moveZoomXY(delay,0,zoom,zoom,cb)
  end

  def moveAngle(delay, duration, angle, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::Angle,delay,duration,0,cb,@angle,angle])
  end

  def setAngle(delay, angle, cb=nil)
    moveAngle(delay,0,angle,cb)
  end

  def moveTone(delay, duration, tone, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    target = (tone) ? tone.clone : Tone.new(0,0,0,0)
    @processes.push([Processes::Tone,delay,duration,0,cb,@tone.clone,target])
  end

  def setTone(delay, tone, cb=nil)
    moveTone(delay,0,tone,cb)
  end

  def moveColor(delay, duration, color, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    target = (color) ? color.clone : Color.new(0,0,0,0)
    @processes.push([Processes::Color,delay,duration,0,cb,@color.clone,target])
  end

  def setColor(delay, color, cb=nil)
    moveColor(delay,0,color,cb)
  end

  # Hue changes don't actually work.
  def moveHue(delay, duration, hue, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::Hue,delay,duration,0,cb,@hue,hue])
  end

  # Hue changes don't actually work.
  def setHue(delay, hue, cb=nil)
    moveHue(delay,0,hue,cb)
  end

  def moveOpacity(delay, duration, opacity, cb=nil)
    delay, duration = ensureDelayAndDuration(delay,duration)
    @processes.push([Processes::Opacity,delay,duration,0,cb,@opacity,opacity])
  end

  def setOpacity(delay, opacity, cb=nil)
    moveOpacity(delay,0,opacity,cb)
  end

  def setVisible(delay, visible, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::Visible,delay,0,0,cb,visible])
  end

  # Only values of 0 (normal), 1 (additive) and 2 (subtractive) are allowed.
  def setBlendType(delay, blend, cb=nil)
    delay = ensureDelayAndDuration(delay)
    @processes.push([Processes::BlendType,delay,0,0,cb,blend])
  end

  def setSE(delay, seFile, volume=nil, pitch=nil, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::SE,delay,0,0,cb,seFile,volume,pitch])
  end

  def setName(delay, name, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::Name,delay,0,0,cb,name])
  end

  def setOrigin(delay, origin, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::Origin,delay,0,0,cb,origin])
  end

  def setSrc(delay, srcX, srcY, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::Src,delay,0,0,cb,srcX,srcY])
  end

  def setSrcSize(delay, srcWidth, srcHeight, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::SrcSize,delay,0,0,cb,srcWidth,srcHeight])
  end

  # Used to cut Pokémon sprites off when they faint and sink into the ground.
  def setCropBottom(delay, y, cb=nil)
    delay = ensureDelay(delay)
    @processes.push([Processes::CropBottom,delay,0,0,cb,y])
  end

  def update
    procEnded = false
    @frameUpdates.clear
    for i in 0...@processes.length
      process = @processes[i]
      # Decrease delay of processes that are scheduled to start later
      if process[1]>=0
        # Set initial values if the process will start this frame
        if process[1]==0
          case process[0]
          when Processes::XY
            process[5] = @x
            process[6] = @y
          when Processes::DeltaXY
            process[5] = @x
            process[6] = @y
            process[7] += @x
            process[8] += @y
          when Processes::Curve
            process[5][0] = @x
            process[5][1] = @y
          when Processes::Z
            process[5] = @z
          when Processes::Zoom
            process[5] = @zoom_x
            process[6] = @zoom_y
          when Processes::Angle
            process[5] = @angle
          when Processes::Tone
            process[5] = @tone.clone
          when Processes::Color
            process[5] = @color.clone
          when Processes::Hue
            process[5] = @hue
          when Processes::Opacity
            process[5] = @opacity
          end
        end
        # Decrease delay counter
        process[1] -= 1
        # Process hasn't started yet, skip to the next one
        next if process[1]>=0
      end
      # Update process
      @frameUpdates.push(process[0]) if !@frameUpdates.include?(process[0])
      fra = (process[2]==0) ? 1 : process[3]   # Frame counter
      dur = (process[2]==0) ? 1 : process[2]   # Total duration of process
      case process[0]
      when Processes::XY, Processes::DeltaXY
        @x = process[5] + fra * (process[7] - process[5]) / dur
        @y = process[6] + fra * (process[8] - process[6]) / dur
      when Processes::Curve
        @x, @y = getCubicPoint2(process[5],fra.to_f/dur)
      when Processes::Z
        @z = process[5] + fra * (process[6] - process[5]) / dur
      when Processes::Zoom
        @zoom_x = process[5] + fra * (process[7] - process[5]) / dur
        @zoom_y = process[6] + fra * (process[8] - process[6]) / dur
      when Processes::Angle
        @angle = process[5] + fra * (process[6] - process[5]) / dur
      when Processes::Tone
        @tone.red   = process[5].red + fra * (process[6].red - process[5].red) / dur
        @tone.green = process[5].green + fra * (process[6].green - process[5].green) / dur
        @tone.blue  = process[5].blue + fra * (process[6].blue - process[5].blue) / dur
        @tone.gray  = process[5].gray + fra * (process[6].gray - process[5].gray) / dur
      when Processes::Color
        @color.red   = process[5].red + fra * (process[6].red - process[5].red) / dur
        @color.green = process[5].green + fra * (process[6].green - process[5].green) / dur
        @color.blue  = process[5].blue + fra * (process[6].blue - process[5].blue) / dur
        @color.alpha = process[5].alpha + fra * (process[6].alpha - process[5].alpha) / dur
      when Processes::Hue
        @hue = (process[6] - process[5]).to_f / dur
      when Processes::Opacity
        @opacity = process[5] + fra * (process[6] - process[5]) / dur
      when Processes::Visible
        @visible = process[5]
      when Processes::BlendType
        @blend_type = process[5]
      when Processes::SE
        pbSEPlay(process[5],process[6],process[7])
      when Processes::Name
        @name = process[5]
      when Processes::Origin
        @origin = process[5]
      when Processes::Src
        @src_rect.x = process[5]
        @src_rect.y = process[6]
      when Processes::SrcSize
        @src_rect.width  = process[5]
        @src_rect.height = process[6]
      when Processes::CropBottom
        @cropBottom = process[5]
      end
      # Increase frame counter
      process[3] += 1
      if process[3]>process[2]
        # Process has ended, erase it
        callback(process[4]) if process[4]
        @processes[i] = nil
        procEnded = true
      end
    end
    # Clear out empty spaces in @processes array caused by finished processes
    @processes.compact! if procEnded
    # Add the constant rotation speed
    if @rotate_speed != 0
      @frameUpdates.push(Processes::Angle) if !@frameUpdates.include?(Processes::Angle)
      @angle += @rotate_speed
      while @angle<0; @angle += 360; end
      @angle %= 360
    end
  end
end



#===============================================================================
#
#===============================================================================
def setPictureSprite(sprite, picture, iconSprite=false)
  return if picture.frameUpdates.length==0
  for i in 0...picture.frameUpdates.length
    case picture.frameUpdates[i]
    when Processes::XY, Processes::DeltaXY
      sprite.x = picture.x.round
      sprite.y = picture.y.round
    when Processes::Z
      sprite.z = picture.z
    when Processes::Zoom
      sprite.zoom_x = picture.zoom_x / 100.0
      sprite.zoom_y = picture.zoom_y / 100.0
    when Processes::Angle
      sprite.angle = picture.angle
    when Processes::Tone
      sprite.tone = picture.tone
    when Processes::Color
      sprite.color = picture.color
    when Processes::Hue
      # This doesn't do anything.
    when Processes::BlendType
      sprite.blend_type = picture.blend_type
    when Processes::Opacity
      sprite.opacity = picture.opacity
    when Processes::Visible
      sprite.visible = picture.visible
    when Processes::Name
      sprite.name = picture.name if iconSprite && sprite.name != picture.name
    when Processes::Origin
      case picture.origin
      when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
        sprite.ox = 0
      when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
        sprite.ox = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.width/2 : 0
      when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
        sprite.ox = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.width : 0
      end
      case picture.origin
      when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
        sprite.oy = 0
      when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
        sprite.oy = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.height/2 : 0
      when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
        sprite.oy = (sprite.bitmap && !sprite.bitmap.disposed?) ? sprite.src_rect.height : 0
      end
    when Processes::Src
      next unless iconSprite && sprite.src_rect
      sprite.src_rect.x = picture.src_rect.x
      sprite.src_rect.y = picture.src_rect.y
    when Processes::SrcSize
      next unless iconSprite && sprite.src_rect
      sprite.src_rect.width  = picture.src_rect.width
      sprite.src_rect.height = picture.src_rect.height
    end
  end
  if iconSprite && sprite.src_rect && picture.cropBottom>=0
    spriteBottom = sprite.y-sprite.oy+sprite.src_rect.height
    if spriteBottom>picture.cropBottom
      sprite.src_rect.height = [picture.cropBottom-sprite.y+sprite.oy,0].max
    end
  end
end

def setPictureIconSprite(sprite, picture)
  setPictureSprite(sprite,picture,true)
end
