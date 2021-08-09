#===============================================================================
#  Common Animation: DISTORTION
#===============================================================================
EliteBattle.defineCommonAnimation(:DISTORTION) do
  @scene.wait(2)
  # initial metrics
  bmp = Graphics.snap_to_bitmap
  max = 50; amax = 4; frames = {}; zoom = 1
  # sets viewport color
  @viewport.color = Color.new(255, 255, 155, 0)
  # animates initial viewport color
  20.times do
    @viewport.color.alpha += 2
    Graphics.update
  end
  # animates screen blur pattern
  for i in 0...(max + 20)
    if !(i%2 == 0)
      zoom += (i > max*0.75) ? 0.3 : -0.01
      angle = 0 if angle.nil?
      angle = (i%3 == 0) ? rand(amax*2) - amax : angle
      # creates necessary sprites
      frames[i] = Sprite.new(@viewport)
      frames[i].bitmap = Bitmap.new(@viewport.width, @viewport.height)
      frames[i].bitmap.blt(0, 0, bmp, @viewport.rect)
      frames[i].center!(true)
      frames[i].z = 999999
      frames[i].angle = angle
      frames[i].zoom = zoom
      frames[i].tone = Tone.new(i/4,i/4,i/4)
      frames[i].opacity = 30
    end
    # colors viewport
    if i >= max
      @viewport.color.alpha += 12
      @viewport.color.blue += 5
    end
    Graphics.update
  end
  # ensures viewport goes to black
  frames[(max+19)].tone = Tone.new(255, 255, 255)
  @viewport.color.alpha = 255
  @sprites["battlebg"].configure
  Graphics.update
  # disposes unused sprites
  pbDisposeSpriteHash(frames)
  # animate out
  32.times do
    @viewport.color.alpha -= 8
    @scene.wait
  end
end
