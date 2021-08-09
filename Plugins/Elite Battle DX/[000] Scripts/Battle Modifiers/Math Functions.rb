#===============================================================================
#  Elite Battle: DX Utilities for various calculations
#===============================================================================
class Vector
  attr_reader :x, :y
  attr_reader :angle, :scale
  attr_reader :x2, :y2
  attr_accessor :zoom1, :zoom2
  attr_accessor :inc, :set, :battle
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(x = 0, y = 0, angle = 0, scale = 1, zoom1 = 1, zoom2 = 1)
    @battle = false
    @x = x.to_f
    @y = y.to_f
    @angle = angle.to_f
    @scale = scale.to_f
    @zoom1 = zoom1.to_f
    @zoom2 = zoom2.to_f
    @inc = 0.2
    @set = [@x,@y,@scale,@angle,@zoom1,@zoom2]
    @locked = false
    @force = false
    @constant = 1
    self.calculate
  end
  #-----------------------------------------------------------------------------
  #  calculates the final positioning based on recorded vector data
  #-----------------------------------------------------------------------------
  def calculate
    angle = @angle*(Math::PI/180)
    width = Math.cos(angle)*@scale
    height = Math.sin(angle)*@scale
    @x2 = @x + width
    @y2 = @y - height
  end
  #-----------------------------------------------------------------------------
  #  returns finalized positioning of applied vector
  #-----------------------------------------------------------------------------
  def spoof(*args)
    if args[0].is_a?(Array)
      x, y, angle, scale, zoom1, zoom2 = *args[0]
    else
      x, y, angle, scale, zoom1, zoom2 = *args
    end
    angle = angle*(Math::PI/180)
    width = Math.cos(angle)*scale
    height = Math.sin(angle)*scale
    x2 = x + width
    y2 = y - height
    return x2, y2
  end
  #-----------------------------------------------------------------------------
  #  sets vector angle
  #-----------------------------------------------------------------------------
  def angle=(val)
    @angle = val
    self.calculate
  end
  #-----------------------------------------------------------------------------
  #  sets vector scale
  #-----------------------------------------------------------------------------
  def scale=(val)
    @scale = val
    self.calculate
  end
  #-----------------------------------------------------------------------------
  #  sets vector start X position
  #-----------------------------------------------------------------------------
  def x=(val)
    @x = val
    @set[0] = val
    self.calculate
  end
  #-----------------------------------------------------------------------------
  #  sets vector start Y position
  #-----------------------------------------------------------------------------
  def y=(val)
    @y = val
    @set[1] = val
    self.calculate
  end
  #-----------------------------------------------------------------------------
  #  forces vector into position
  #-----------------------------------------------------------------------------
  def force
    @force = true
  end
  #-----------------------------------------------------------------------------
  #  resets vector to original position
  #-----------------------------------------------------------------------------
  def reset
    @inc = 0.2
    self.set(EliteBattle.get_vector(:MAIN, @battle))
  end
  #-----------------------------------------------------------------------------
  #  sets next vector parameters
  #-----------------------------------------------------------------------------
  def set(*args)
    return if EliteBattle::DISABLE_SCENE_MOTION && !@force
    @force = false
    if args[0].is_a?(Array)
      @set = args[0]
    else
      @set = args
    end
    @constant = rand(4) + 1
  end
  #-----------------------------------------------------------------------------
  #  sets both start X and Y
  #-----------------------------------------------------------------------------
  def setXY(x, y)
    @set[0] = x
    @set[1] = y
  end
  #-----------------------------------------------------------------------------
  #  checks if vector is locked into position
  #-----------------------------------------------------------------------------
  def locked?
    return @locked
  end
  #-----------------------------------------------------------------------------
  #  toggles vector lock into position
  #-----------------------------------------------------------------------------
  def lock
    @locked = !@locked
  end
  #-----------------------------------------------------------------------------
  #  updates vector calculation based on incremental speed
  #-----------------------------------------------------------------------------
  def update
    @x += ((@set[0] - @x)*@inc)/self.delta
    @y += ((@set[1] - @y)*@inc)/self.delta
    @angle += ((@set[2] - @angle)*@inc)/self.delta
    @scale += ((@set[3] - @scale)*@inc)/self.delta
    @zoom1 += ((@set[4] - @zoom1)*@inc)/self.delta
    @zoom2 += ((@set[5] - @zoom2)*@inc)/self.delta
    self.calculate
  end
  #-----------------------------------------------------------------------------
  #  gets array of current values
  #-----------------------------------------------------------------------------
  def get
    return [@x, @y, @angle, @scale, @zoom1, @zoom2]
  end
  #-----------------------------------------------------------------------------
  #  checks if vector has moved to next target
  #-----------------------------------------------------------------------------
  def finished?
    return ((@set[0] - @x)*@inc).abs <= 0.00001*@constant
  end
  #-----------------------------------------------------------------------------
  #  get delta shift
  #-----------------------------------------------------------------------------
  def delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# calculates curve based on 3 points and number of frames
#===============================================================================
def calculateCurve(x1, y1, x2, y2, x3, y3, frames = 10)
  output = []
  curve = [x1, y1, x2, y2, x3, y3, x3, y3]
  step = 1.0/frames
  t = 0.0
  frames.times do
    point = getCubicPoint2(curve, t)
    output.push([point[0], point[1]])
    t += step
  end
  return output
end
#===============================================================================
# checks if number is single decimal integer
#===============================================================================
def singleDecInt?(number)
  number *= 10
  return (number%10 == 0)
end
#===============================================================================
#
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  # aligns sprite to target
  #-----------------------------------------------------------------------------
  def alignSprites(sprite, target)
    sprite.ox = sprite.src_rect.width/2
    sprite.oy = sprite.src_rect.height/2
    sprite.x, sprite.y = getCenter(target)
    sprite.zoom_x, sprite.zoom_y = target.zoom_x/2, target.zoom_y/2
  end
  #-----------------------------------------------------------------------------
  # get actual vector positioning depending on battle type and target index
  #-----------------------------------------------------------------------------
  def getRealVector(targetindex, player)
    vector = EliteBattle.get_vector(:BATTLER, player)
    if @battle.doublebattle? || @battle.triplebattle?
      if targetindex%2 == 0 && @battle.pbParty(0).length > 1
        md = (@battle.pbParty(0).length + 1)/2
        vector[0] = vector[0] - 8*((targetindex - md)/2)
      elsif targetindex%2 == 1 && @battle.pbParty(1).length > 1
        md = (@battle.pbParty(1).length + 1)/2 + 1
        vector[0] = vector[0] + 48*((targetindex - md)/2)
      end
    end
    return vector
  end
  #-----------------------------------------------------------------------------
  # clones sprite properties from one sprite to the other
  #-----------------------------------------------------------------------------
  def applySpriteProperties(sprite1, sprite2)
    sprite2.x = sprite1.x
    sprite2.y = sprite1.y
    sprite2.z = sprite1.z
    sprite2.zoom_x = sprite1.zoom_x
    sprite2.zoom_y = sprite1.zoom_y
    sprite2.opacity = sprite1.opacity
    sprite2.angle = sprite1.angle
    sprite2.tone = sprite1.tone
    sprite2.color = sprite1.color
    sprite2.visible = sprite1.visible
  end
  #-----------------------------------------------------------------------------
end
