#-------------------------------------------------------------------------------
#  Rockslide
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ROCKSLIDE) do
  indexes = []
  max = @battle.pbSideSize(@targetIsPlayer ? 0 : 1)
  for i in 0...max
    i = (@targetIsPlayer ? i*2 : (i*2 + 1))
    indexes.push(i) if @sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].actualBitmap
  end
  vector = @scene.battle.doublebattle? ? EliteBattle.get_vector(:BATTLER, @targetIsPlayer) : @scene.getRealVector(@targetIndex, @targetIsPlayer)
  @vector.set(vector)
  @scene.wait(16, true)
  # set up animation
  dy = @vector.y2/12
  fp = {}; da = []; factors = []
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
      factors.push(1)
      next
    end
    factors.push(@targetSprite.zoom_x)
  end
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
    for j in 0...96
      fp["r#{m}#{j}"] = Sprite.new(@viewport)
      fp["r#{m}#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb504")
      fp["r#{m}#{j}"].ox = fp["r#{m}#{j}"].bitmap.width/2
      fp["r#{m}#{j}"].oy = fp["r#{m}#{j}"].bitmap.height/2
      r = 64*factors[m]
      z = [1,0.5,0.75,0.25][rand(4)]
      fp["r#{m}#{j}"].zoom_x = z
      fp["r#{m}#{j}"].zoom_y = z
      fp["r#{m}#{j}"].x = @targetSprite.x - r + rand(r*2)
      fp["r#{m}#{j}"].y = rand(32*factors[m])
      fp["r#{m}#{j}"].visible = false
      fp["r#{m}#{j}"].angle = rand(360)
      fp["r#{m}#{j}"].z = @targetSprite.z + 1
      da.push(rand(2)==0 ? 1 : -1)
    end
    width = @targetSprite.bitmap.width/2 - 16
    max = 16# + (width/16)
    for j in 0...max
      fp["d#{m}#{j}"] = Sprite.new(@viewport)
      fp["d#{m}#{j}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/ebDustParticle")
      fp["d#{m}#{j}"].ox = fp["d#{m}#{j}"].bitmap.width/2
      fp["d#{m}#{j}"].oy = fp["d#{m}#{j}"].bitmap.height/2
      fp["d#{m}#{j}"].opacity = 0
      fp["d#{m}#{j}"].angle = rand(360)
      fp["d#{m}#{j}"].x = @targetSprite.x - width*factors[m] + rand(width*2*factors[m])
      fp["d#{m}#{j}"].y = @targetSprite.y - 16*factors[m] + rand(32*factors[m])
      fp["d#{m}#{j}"].z = @targetSprite.z + (fp["d#{m}#{j}"].y < @targetSprite.y ? -1 : 1)
      zoom = [1,0.8,0.9,0.7][rand(4)]
      fp["d#{m}#{j}"].zoom_x = zoom*factors[m]
      fp["d#{m}#{j}"].zoom_y = zoom*factors[m]
    end
  end
  k = [-1,-1]
  # start animation
  for i in 0...80
    pbSEPlay("EBDX/Anim/rock2",70) if i%8==0
    for m in 0...indexes.length
      @targetSprite = @sprites["pokemon_#{indexes[m]}"]
      next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
      for j in 0...96
        next if j>(i*2)
        fp["r#{m}#{j}"].y += dy
        fp["r#{m}#{j}"].visible = fp["r#{m}#{j}"].y < @targetSprite.y - 16*factors[m]
        fp["r#{m}#{j}"].angle += 8*da[j]
      end
      for j in 0...max
        next if i < 8
        next if j>(i-8)/2
        fp["d#{m}#{j}"].opacity += 25.5 if i < 18+j*2
        fp["d#{m}#{j}"].opacity -= 25.5 if i >= 22+j*2
        if fp["d#{m}#{j}"].x >= @targetSprite.x
          fp["d#{m}#{j}"].angle += 4
          fp["d#{m}#{j}"].x += 2
        else
          fp["d#{m}#{j}"].angle -= 4
          fp["d#{m}#{j}"].x -= 2
        end
      end
      if i >= 8 && i < 64
        k[m] *= -1 if i%4==0
        @targetSprite.zoom_y -= 0.04*k[m]*factors[m]
        @targetSprite.zoom_x += 0.02*k[m]*factors[m]
        @targetSprite.still
      end
    end
    @scene.wait
  end
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
