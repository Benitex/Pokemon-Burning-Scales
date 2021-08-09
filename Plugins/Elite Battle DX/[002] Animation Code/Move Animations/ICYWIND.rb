#-------------------------------------------------------------------------------
#  Icy Wind
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:ICYWIND) do
  indexes = []
  max = @battle.pbSideSize(@targetIsPlayer ? 0 : 1)
  for i in 0...max
    i = (@targetIsPlayer ? i*2 : (i*2 + 1))
    indexes.push(i) if @sprites["pokemon_#{i}"] && @sprites["pokemon_#{i}"].actualBitmap
  end
  # set up animation
  fp = {}
  rndx = [[],[]]; rndy = [[],[]]
  irndx = [[],[]]; irndy = [[],[]]
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(100,128,142))
  fp["bg"].opacity = 0
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    for i in 0...16
      fp["#{m}#{i}"] = Sprite.new(@viewport)
      fp["#{m}#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb250")
      fp["#{m}#{i}"].ox = fp["#{m}#{i}"].bitmap.width/2
      fp["#{m}#{i}"].oy = fp["#{m}#{i}"].bitmap.width/2
      fp["#{m}#{i}"].opacity = 0
      fp["#{m}#{i}"].z = (@targetIsPlayer ? 29 : 19)
      rndx[m].push(rand(64))
      rndy[m].push(rand(64))
    end
  end
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
    for i in 0...8
      fp["i#{m}#{i}"] = Sprite.new(@viewport)
      fp["i#{m}#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb248")
      fp["i#{m}#{i}"].src_rect.set(0,0,26,42)
      fp["i#{m}#{i}"].ox = 13
      fp["i#{m}#{i}"].oy = 21
      fp["i#{m}#{i}"].opacity = 0
      fp["i#{m}#{i}"].z = (@targetIsPlayer ? 29 : 19)
      fp["i#{m}#{i}"].zoom_x = (@targetSprite.zoom_x)/2
      fp["i#{m}#{i}"].zoom_y = (@targetSprite.zoom_y)/2
      irndx[m].push(rand(128))
      irndy[m].push(rand(128))
    end
  end
  shake = [2,2]
  @sprites["battlebg"].defocus
  # start animation
  for i in 0...152
    for m in 0...indexes.length
      @targetSprite = @sprites["pokemon_#{indexes[m]}"]
      next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
      for j in 0...16
        if fp["#{m}#{j}"].opacity == 0 && fp["#{m}#{j}"].tone.gray == 0
          fp["#{m}#{j}"].zoom_x = @userSprite.zoom_x
          fp["#{m}#{j}"].zoom_y = @userSprite.zoom_y
          cx, cy = @userSprite.getAnchor
          fp["#{m}#{j}"].x = cx
          fp["#{m}#{j}"].y = cy
        end
        cx, cy = @targetSprite.getCenter(true)
        next if j>(i/4)
        x2 = cx - 32*@targetSprite.zoom_x + rndx[m][j]*@targetSprite.zoom_x
        y2 = cy - 32*@targetSprite.zoom_y + rndy[m][j]*@targetSprite.zoom_y
        x0 = fp["#{m}#{j}"].x
        y0 = fp["#{m}#{j}"].y
        fp["#{m}#{j}"].x += (x2 - x0)*0.1
        fp["#{m}#{j}"].y += (y2 - y0)*0.1
        fp["#{m}#{j}"].zoom_x -= (fp["#{m}#{j}"].zoom_x - @targetSprite.zoom_x)*0.1
        fp["#{m}#{j}"].zoom_y -= (fp["#{m}#{j}"].zoom_y - @targetSprite.zoom_y)*0.1
        fp["#{m}#{j}"].angle += 2
        if (x2 - x0)*0.1 < 1 && (y2 - y0)*0.1 < 1
          fp["#{m}#{j}"].opacity -= 8
          fp["#{m}#{j}"].tone.gray += 8
          fp["#{m}#{j}"].angle += 2
        else
          fp["#{m}#{j}"].opacity += 12
        end
      end
    end
    if i >= 132
      fp["bg"].opacity -= 7
    else
      fp["bg"].opacity += 2 if fp["bg"].opacity < 255*0.5
    end
    pbSEPlay("Anim/Ice7", 80) if i == 96
    pbSEPlay("Anim/Wind8", 70) if i == 12
    if i >= 96
      for m in 0...indexes.length
        @targetSprite = @sprites["pokemon_#{indexes[m]}"]
        next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
        cx, cy = @targetSprite.getCenter(true)
        if i >= 132
          @targetSprite.tone.red -= 4.8
          @targetSprite.tone.green -= 4.8
          @targetSprite.tone.blue -= 4.8
        else
          @targetSprite.tone.red += 4.8 if @targetSprite.tone.red < 96
          @targetSprite.tone.green += 4.8 if @targetSprite.tone.green < 96
          @targetSprite.tone.blue += 4.8 if @targetSprite.tone.blue < 96
        end
        @targetSprite.ox += shake[m]
        shake[m] = -2 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
        shake[m] = 2 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
        @targetSprite.still
        for k in 0...8
          if fp["i#{m}#{k}"].opacity == 0 && fp["i#{m}#{k}"].src_rect.x == 0
            fp["i#{m}#{k}"].x = cx - 64*@targetSprite.zoom_x + irndx[m][k]*@targetSprite.zoom_x
            fp["i#{m}#{k}"].y = cy - 64*@targetSprite.zoom_y + irndy[m][k]*@targetSprite.zoom_y
          end
          fp["i#{m}#{k}"].src_rect.x += 26 if i%4==0 && fp["i#{m}#{k}"].opacity >= 255
          fp["i#{m}#{k}"].src_rect.x = 78 if fp["i#{m}#{k}"].src_rect.x > 78
          if fp["i#{m}#{k}"].src_rect.x==78
            fp["i#{m}#{k}"].opacity -= 24
            fp["i#{m}#{k}"].zoom_x += 0.02
            fp["i#{m}#{k}"].zoom_y += 0.02
          elsif fp["i#{m}#{k}"].opacity >= 255
            fp["i#{m}#{k}"].opacity -= 24
            pbSEPlay("Anim/Ice1",50)
          else
            fp["i#{m}#{k}"].opacity += 45 if (i-96)/2 > k
          end
        end
      end
    end
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 24
    @vector.inc = 0.1 if i == 24
    @scene.wait(1,true)
  end
  @sprites["battlebg"].focus
  for m in 0...indexes.length
    @targetSprite = @sprites["pokemon_#{indexes[m]}"]
    next if !@targetSprite || @targetSprite.disposed? || @targetSprite.fainted || !@targetSprite.visible
    @targetSprite.ox = @targetSprite.bitmap.width/2
    @targetSprite.tone = Tone.new(0,0,0,0)
  end
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
