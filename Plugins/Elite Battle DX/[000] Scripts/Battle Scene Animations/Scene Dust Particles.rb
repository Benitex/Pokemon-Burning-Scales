#===============================================================================
#  Class handling the dust animation when heavy battlers enter scene
#===============================================================================
class EBDustParticle
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' sprite: %s>', @sprite.inspect)
    return str
  end
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport, sprite, factor = 1)
    @viewport = viewport
    @sprite = sprite
    @x = sprite.x; @y = sprite.y; @z = sprite.z
    @factor = sprite.zoom_x
    @index = 0; @fp = {}
    width = sprite.bitmap.width/2 - 16
    @max = 16 + (width/16)
    # initializes all the particles
    for j in 0...@max
      @fp["#{j}"] = Sprite.new(@viewport)
      @fp["#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebDustParticle")
      @fp["#{j}"].ox = @fp["#{j}"].bitmap.width/2
      @fp["#{j}"].oy = @fp["#{j}"].bitmap.height/2
      @fp["#{j}"].opacity = 0
      @fp["#{j}"].angle = rand(360)
      @fp["#{j}"].x = @x - width*@factor + rand(width*2*@factor)
      @fp["#{j}"].y = @y - 16*@factor + rand(32*@factor)
      @fp["#{j}"].z = @z + (@fp["#{j}"].y < @y ? -1 : 1)
      zoom = [1,0.8,0.9,0.7][rand(4)]
      @fp["#{j}"].zoom_x = zoom*@factor
      @fp["#{j}"].zoom_y = zoom*@factor
    end
  end
  #-----------------------------------------------------------------------------
  #  updates animation frame
  #-----------------------------------------------------------------------------
  def update
    i = @index
    for j in 0...@max
      @fp["#{j}"].opacity += 25.5 if i < 10
      @fp["#{j}"].opacity -= 25.5 if i >= 14
      if @fp["#{j}"].x >= @x
        @fp["#{j}"].angle += 4
        @fp["#{j}"].x += 2
      else
        @fp["#{j}"].angle -= 4
        @fp["#{j}"].x -= 2
      end
    end
    @index += 1
  end
  #-----------------------------------------------------------------------------
  #  disposes of particles
  #-----------------------------------------------------------------------------
  def dispose
    pbDisposeSpriteHash(@fp)
  end
  #-----------------------------------------------------------------------------
end
