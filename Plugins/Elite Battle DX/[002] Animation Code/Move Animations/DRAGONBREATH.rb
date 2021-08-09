#-------------------------------------------------------------------------------
#  Dragon Breath
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:DRAGONBREATH) do
  # set up animation
  fp = {}
  rndx = []; rndy = []
  dx = []; dy = []
  @targetSprite.color = Color.new(255,0,0,0)
  for m in 0...2
    rndx.push([]); rndy.push([]); dx.push([]); dy.push([])
    for i in 0...96
      str = ["","_2"][rand(2)]
      str = "Graphics/EBDX/Animations/Moves/eb59"+str
      str = "Graphics/EBDX/Animations/Moves/eb59_3" if m == 1
      fp["#{i}#{m}"] = Sprite.new(@viewport)
      fp["#{i}#{m}"].bitmap = pbBitmap(str)
      fp["#{i}#{m}"].ox = fp["#{i}#{m}"].bitmap.width/2
      fp["#{i}#{m}"].oy = fp["#{i}#{m}"].bitmap.height/2
      fp["#{i}#{m}"].angle = rand(360)
      fp["#{i}#{m}"].opacity = 0
      if m == 0
        fp["#{i}#{m}"].zoom_x = 0.8
        fp["#{i}#{m}"].zoom_y = 0.8
      end
      fp["#{i}#{m}"].z = @targetIsPlayer ? 29 : 19
      rndx[m].push(rand([16,128][m]))
      rndy[m].push(rand([16,128][m]))
      dx[m].push(0)
      dy[m].push(0)
    end
  end
  shake = 4
  # start animation
  for i in 0...96
    pbSEPlay("EBDX/Anim/dragon2") if i==8
    pbSEPlay("EBDX/Anim/dragon1") if i==74
    uax, uay = @userSprite.getAnchor(true)
    cx, cy = @targetSprite.getCenter(true)
    for m in 0...2
      for j in 0...96
        next if j>(i*2)
        if fp["#{j}#{m}"].opacity == 0 && fp["#{j}#{m}"].tone.gray == 0
          dx[m][j] = uax - [8,64][m]*@userSprite.zoom_x*0.5 + rndx[m][j]*@userSprite.zoom_x*0.5
          dy[m][j] = uay - [8,64][m]*@userSprite.zoom_y*0.5 + rndy[m][j]*@userSprite.zoom_y*0.5
          fp["#{j}#{m}"].x = dx[m][j]
          fp["#{j}#{m}"].y = dy[m][j]
          if m == 1
            fp["#{j}#{m}"].opacity = 55 + rand(151)
            z = [0.5,0.75,1,0.3][rand(4)]
            fp["#{j}#{m}"].zoom_x = z
            fp["#{j}#{m}"].zoom_y = z
          end
        end
        x0 = dx[m][j]
        y0 = dy[m][j]
        x2 = cx - [8,64][m]*@targetSprite.zoom_x*0.5 + rndx[m][j]*@targetSprite.zoom_x*0.5
        y2 = cy - [8,64][m]*@targetSprite.zoom_y*0.5 + rndy[m][j]*@targetSprite.zoom_y*0.5
        fp["#{j}#{m}"].x += (x2 - x0)*0.1
        fp["#{j}#{m}"].y += (y2 - y0)*0.1
        fp["#{j}#{m}"].opacity += 51 if m == 0
        fp["#{j}#{m}"].zoom_x += 0.04 if m == 0
        fp["#{j}#{m}"].zoom_y += 0.04 if m == 0
        nextx = fp["#{j}#{m}"].x# + (x2 - x0)*0.1
        nexty = fp["#{j}#{m}"].y# + (y2 - y0)*0.1
        if !@targetIsPlayer
          if nextx > cx && nexty < cy
            fp["#{j}#{m}"].visible = false if m == 0
            fp["#{j}#{m}"].opacity -= 75 if m == 1
            fp["#{j}#{m}"].tone.gray = 1 if m == 1
          end
        else
          if nextx < cx && nexty > cy
            fp["#{j}#{m}"].visible = false if m == 0
            fp["#{j}#{m}"].opacity -= 75 if m == 1
            fp["#{j}#{m}"].tone.gray = 1 if m == 1
          end
        end
      end
    end
    if i >= 58 && i < 74
      @targetSprite.ox += shake
      shake = -4 if @targetSprite.ox > @targetSprite.bitmap.width/2 + 2
      shake = 4 if @targetSprite.ox < @targetSprite.bitmap.width/2 - 2
      @targetSprite.color.alpha += 12
      @targetSprite.still
    end
    @targetSprite.zoom_y += 0.16 if i == 74
    if i >= 74 && i < 90
      @targetSprite.color.alpha -= 12
      @targetSprite.ox = @targetSprite.bitmap.width/2
      @targetSprite.still
      @targetSprite.zoom_y -= 0.01
    end
    @targetSprite.anim = true
    @vector.set(EliteBattle.get_vector(:DUAL)) if i == 32
    @vector.inc = 0.1 if i == 32
    @scene.wait(1, !(i >= 74 && i < 90))
  end
  @targetSprite.ox = @targetSprite.bitmap.width/2
  @vector.reset if !@multiHit
  @vector.inc = 0.2
  pbDisposeSpriteHash(fp)
end
