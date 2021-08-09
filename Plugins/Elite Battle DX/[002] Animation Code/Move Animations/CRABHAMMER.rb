#-------------------------------------------------------------------------------
#  Crabhammer
#-------------------------------------------------------------------------------
EliteBattle.defineMoveAnimation(:CRABHAMMER) do
  vector = @scene.getRealVector(@targetIndex, @targetIsPlayer)
  # set up animation
  fp = {}
  fp["bg"] = Sprite.new(@viewport)
  fp["bg"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
  fp["bg"].bitmap.fill_rect(0,0,fp["bg"].bitmap.width,fp["bg"].bitmap.height,Color.new(57,106,173))
  fp["bg"].opacity = 0
  @vector.set(vector)
  @sprites["battlebg"].defocus
  16.times do
    fp["bg"].opacity += 8
    @scene.wait(1,true)
  end
  fp["hammer1"] = Sprite.new(@viewport)
  fp["hammer1"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb540_2")
  fp["hammer1"].ox = fp["hammer1"].bitmap.width/2
  fp["hammer1"].oy = fp["hammer1"].bitmap.height
  fp["hammer1"].z = @targetSprite.z + 1
  fp["hammer1"].x = @targetSprite.x
  fp["hammer2"] = Sprite.new(@viewport)
  fp["hammer2"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb540_3")
  fp["hammer2"].ox = fp["hammer2"].bitmap.width/2
  fp["hammer2"].oy = fp["hammer2"].bitmap.height - 24
  fp["hammer2"].z = @targetSprite.z + 1
  fp["hammer2"].x = @targetSprite.x
  fp["frame"] = Sprite.new(@viewport)
  fp["frame"].z = @targetSprite.z + 2
  fp["frame"].bitmap = pbBitmap("Graphics/EBDX/Animations/Moves/eb540")
  fp["frame"].src_rect.set(0,0,64,64)
  fp["frame"].ox = 32
  fp["frame"].oy = 32
  fp["frame"].zoom_x = 0.5*@targetSprite.zoom_x
  fp["frame"].zoom_y = 0.5*@targetSprite.zoom_y
  fp["frame"].x, fp["frame"].y = @targetSprite.getCenter(true)
  fp["frame"].opacity = 0
  fp["frame"].tone = Tone.new(255,255,255)
  px = []; py = []
  for i in 0...24
    fp["p#{i}"] = Sprite.new(@viewport)
    fp["p#{i}"].bitmap = Bitmap.new(16,16)
    fp["p#{i}"].bitmap.bmp_circle
    fp["p#{i}"].ox = 8
    fp["p#{i}"].oy = 8
    fp["p#{i}"].opacity = 0
    fp["p#{i}"].z = @targetSprite.z
    px.push(0)
    py.push(0)
  end
  pbSEPlay("Anim/Water1",80)
  for i in 0...64
    fp["hammer1"].y += @targetSprite.y/8.0
    fp["hammer1"].visible = fp["hammer1"].y < @targetSprite.y
    if i >= 2
      fp["hammer2"].y += @targetSprite.y/8.0
      fp["hammer2"].visible = fp["hammer2"].y < @targetSprite.y
    end
    pbSEPlay("EBDX/Anim/normal1",80) if i == 11
    if i.between?(11,15)
      @targetSprite.still
      @targetSprite.zoom_y-=0.05*@targetSprite.zoom_y
      @targetSprite.tone.all -= 12.8
      fp["frame"].zoom_x += 0.1*@targetSprite.zoom_x
      fp["frame"].zoom_y += 0.1*@targetSprite.zoom_y
      fp["frame"].opacity += 51
    end
    fp["frame"].tone = Tone.new(0,0,0) if i == 16
    if i.between?(16,20)
      @targetSprite.still
      @targetSprite.zoom_y+=0.05*@targetSprite.zoom_y
      @targetSprite.tone.all+=12.8
      fp["frame"].angle += 2
    end
    fp["p#{i}"].src_rect.x = 64 if i == 10
    if i >= 20
      fp["frame"].opacity -= 25.5
      fp["frame"].zoom_x += 0.1*@targetSprite.zoom_x
      fp["frame"].zoom_y += 0.1*@targetSprite.zoom_y
      fp["frame"].angle += 2
    end
    for l in 0...24
      next if i < 10
      next if l>((i-10)*8)
      cx, cy = @targetSprite.getCenter(true)
      if fp["p#{l}"].opacity <= 0 && fp["p#{l}"].tone.blue <= 0
        fp["p#{l}"].opacity = 255 - rand(101)
        fp["p#{l}"].x = cx
        fp["p#{l}"].y = cy
        r = rand(2)
        fp["p#{l}"].zoom_x = r==0 ? 1 : 0.5
        fp["p#{l}"].zoom_y = r==0 ? 1 : 0.5
        x = rand(128); y = rand(128)
        px[l] = cx - 64*@targetSprite.zoom_x + x*@targetSprite.zoom_x
        py[l] = cy - 64*@targetSprite.zoom_y + y*@targetSprite.zoom_y
      end
      x2 = px[l]
      y2 = py[l]
      x0 = fp["p#{l}"].x
      y0 = fp["p#{l}"].y
      fp["p#{l}"].x += (x2 - x0)*0.1
      fp["p#{l}"].y += (y2 - y0)*0.1
      fp["p#{l}"].opacity -= 8
      fp["p#{l}"].tone.blue = 1 if fp["p#{l}"].opacity <= 0
    end
    fp["bg"].opacity -= 8 if i >= 48
    @scene.wait
  end
  @sprites["battlebg"].focus
  @vector.reset if !@multiHit
  pbDisposeSpriteHash(fp)
end
