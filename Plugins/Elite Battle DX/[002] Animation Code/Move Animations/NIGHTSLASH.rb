#-------------------------------------------------------------------------------
#  Night Slash
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:NIGHTSLASH) do
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16,true)
  # set up animation
  factor = @targetSprite.zoom_x
  cx, cy = @targetSprite.getCenter(true)
  fp = {}
  dx = []
  dy = []
  fp["bg"] = ScrollingSprite.new(@viewport)
  fp["bg"].speed = 64
  fp["bg"].setBitmap("Graphics/EBDX/Animations/Moves/eb027_bg")
  fp["bg"].opacity = 0
  fp["bg"].z = 50
  for j in 0...12
    fp["s#{j}"] = Sprite.new(@viewport)
    fp["s#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb027_2")
    fp["s#{j}"].ox = fp["s#{j}"].bitmap.width/2
    fp["s#{j}"].oy = fp["s#{j}"].bitmap.height/2
    r = 128*factor
    x, y = randCircleCord(r)
    x = cx - r + x
    y = cy - r + y
    z = [1,0.75,0.5][rand(3)]
    fp["s#{j}"].zoom_x = z
    fp["s#{j}"].zoom_y = z
    fp["s#{j}"].x = cx
    fp["s#{j}"].y = cy
    fp["s#{j}"].z = @targetSprite.z + 1
    fp["s#{j}"].visible = false
    dx.push(x)
    dy.push(y)
  end
  fp["slash"] = Sprite.new(@viewport)
  fp["slash"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb027")
  fp["slash"].oy = fp["slash"].bitmap.height/2
  fp["slash"].y = cy
  fp["slash"].x = @viewport.width
  fp["slash"].opacity = 0
  fp["slash"].z = 50
  # play animation
  pbSEPlay("Anim/gust",90)
  for m in 0...2
    shake = 2
    for i in 0...(m < 1 ? 32 : 16)
      fp["bg"].opacity += 16 if m < 1
      fp["bg"].update
      if m < 1
        fp["slash"].x -= 64 if i >= 28
        fp["slash"].opacity += 64 if i >= 28
      else
        fp["slash"].x += 64 if i >= 12
        fp["slash"].opacity += 64 if i >= 12
      end
      @scene.wait(1,true)
    end
    pbSEPlay("Anim/hit")
    for i in 0...16
      fp["bg"].opacity -= 16
      for j in 0...12
        fp["s#{j}"].visible = true
        fp["s#{j}"].x -= (fp["s#{j}"].x - dx[j])*0.1
        fp["s#{j}"].y -= (fp["s#{j}"].y - dy[j])*0.1
        fp["s#{j}"].zoom_x -= 0.04
        fp["s#{j}"].zoom_y -= 0.04
        fp["s#{j}"].tone.gray += 16
        fp["s#{j}"].tone.red -= 8
        fp["s#{j}"].tone.green -= 8
        fp["s#{j}"].tone.blue -= 8
        fp["s#{j}"].opacity -= 16
      end
      if m < 1
        fp["slash"].x -= 64
      else
        fp["slash"].x += 64
      end
      fp["slash"].opacity -= 32
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
      @scene.wait
    end
    @targetSprite.ox = @targetSprite.bitmap.width/2
    dx.clear
    dy.clear
    fp["slash"].mirror = true
    fp["slash"].ox = fp["slash"].bitmap.width
    fp["slash"].opacity = 0
    fp["slash"].x = 0
    for j in 0...12
      fp["s#{j}"].x = cx
      fp["s#{j}"].y = cy
      fp["s#{j}"].tone = Tone.new(0,0,0,0)
      fp["s#{j}"].opacity = 255
      fp["s#{j}"].visible = false
      z = [1,0.75,0.5][rand(3)]
      fp["s#{j}"].zoom_x = z
      fp["s#{j}"].zoom_y = z
      r = 128*factor
      x, y = randCircleCord(r)
      x = cx - r + x
      y = cy - r + y
      dx.push(x)
      dy.push(y)
    end
  end
  @scene.wait(8)
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
