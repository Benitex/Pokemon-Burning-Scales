#-------------------------------------------------------------------------------
#  Air Slash
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:AIRSLASH) do
  # inital configuration
  pbSEPlay("EBDX/Anim/flying1",80)
  @vector.set(@scene.getRealVector(@targetIndex, @targetIsPlayer))
  @scene.wait(16, true)
  factor = @targetSprite.zoom_x
  # set up animation
  fp = {}
  cx, cy = @targetSprite.getCenter(true)
  da = []; dx = []; dy = []; doj = []
  for i in 0...32
    fp["#{i}"] = Sprite.new(@viewport)
    fp["#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb159_2")
    fp["#{i}"].ox = 12
    fp["#{i}"].oy = 1
    fp["#{i}"].opacity = 0
    fp["#{i}"].z = @targetSprite.z + 1
    r = 128*factor
    z = [1,1.25,0.75,1.5][rand(4)]
    fp["#{i}"].zoom_x = z
    #fp["#{i}"].zoom_y = factor
    fp["#{i}"].x = cx
    fp["#{i}"].y = cy
    fp["#{i}"].tone = Tone.new(255,255,255)
    da.push(rand(2)==0 ? 1 : -1)
    dx.push(cx - r + rand(r*2))
    dy.push(cy - r + rand(r*2))
    doj.push(rand(4)+1)
  end
  fp["slash"] = Sprite.new(@viewport)
  fp["slash"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb159")
  fp["slash"].ox = fp["slash"].bitmap.width/2
  fp["slash"].oy = fp["slash"].bitmap.height/2
  fp["slash"].x = cx
  fp["slash"].y = cy
  #fp["slash"].zoom_x = factor
  #fp["slash"].zoom_y = factor
  fp["slash"].z = @targetSprite.z
  fp["slash"].src_rect.height = 0
  pbSEPlay("EBDX/Anim/normal3",80)
  # start animation
  shake = 2
  for i in 0...48
    fp["slash"].src_rect.height += 48 if i < 8
    for j in 0...32
      fp["#{j}"].angle += 32*da[j]
      fp["#{j}"].tone.red -= 8 if fp["#{j}"].tone.red > 0
      fp["#{j}"].tone.green -= 8 if fp["#{j}"].tone.green > 0
      fp["#{j}"].tone.blue -= 8 if fp["#{j}"].tone.blue > 0
      fp["#{j}"].opacity += 16*(i < 24 ? 4 : -1*doj[j])
      fp["#{j}"].x -= (fp["#{j}"].x - dx[j])*0.05
      fp["#{j}"].y -= (fp["#{j}"].y - dy[j])*0.05
    end
    if i >= 4
      fp["slash"].tone.red += 16 if fp["slash"].tone.red < 255
      fp["slash"].tone.green += 16 if fp["slash"].tone.green < 255
      fp["slash"].tone.blue += 16 if fp["slash"].tone.blue < 255
      fp["slash"].opacity -= 32 if i >= 8
    end
    if i >= 8
      @targetSprite.ox += shake
      shake = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.still
    end
    @scene.wait
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  pbDisposeSpriteHash(fp)
  @vector.reset if !@multiHit
end
