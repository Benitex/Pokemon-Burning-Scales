#===============================================================================
#  Class used to handle regular trainer battle intro animations
#  Chooses randomly from a set of predefined styles
#===============================================================================
class EliteBattle_BasicTrainerAnimations
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport, battletype, foe)
    @viewport = viewport
    trainertype = GameData::TrainerType.get(foe[0].trainer_type)
    # plays random battle intro
    styles = ["anim1", "anim2", "anim3"]
    sel = styles[rand(styles.length)]
    handled = false
    # plays rainbow intro animation if applicable
    handled = self.rainbowIntro(@viewport) if EliteBattle.can_transition?("rainbowIntro", foe[0].trainer_type, :Trainer, foe[0].name, foe[0].partyID) && EliteBattle.get(:smAnim)
    # plays evil team animation if applicable
    filename = sprintf("Graphics/EBDX/Transitions/%s", trainertype.id)
    filename = sprintf("Graphics/EBDX/Transitions/classic%03d", trainertype.id_number) if !pbResolveBitmap(filename)
    if pbResolveBitmap(filename) && foe.length < 2 && EliteBattle.can_transition?("classicVS", foe[0].trainer_type, :Trainer, foe[0].name, foe[0].partyID)
      handled = ClassicVSSequence.new(@viewport, foe[0])
      handled.start
      return true
    elsif EliteBattle.can_transition?("evilTeam", foe[0].trainer_type, :Trainer, foe[0].name, foe[0].partyID)
      return self.evilTeam(@viewport, foe[0].trainer_type)
    # plays team skull animation if applicable
    elsif EliteBattle.can_transition?("teamSkull", foe[0].trainer_type, :Trainer, foe[0].name, foe[0].partyID)
      return self.teamSkull(@viewport, foe[0].trainer_type)
    # plays override if applicable
    elsif !handled && pbBattleAnimationOverride(viewport, battletype, foe)
    # plays random trainer animation
    elsif !handled && self.respond_to?(sel.to_sym)
      eval("self.#{sel}")
    end
    return true
  end
  #-----------------------------------------------------------------------------
  # first variant trainer battle animation
  #-----------------------------------------------------------------------------
  def anim1
    # load ball sprite
    ball = Sprite.new(@viewport)
    ball.bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/ball")
    ball.center!(true)
    ball.zoom_x = 0
    ball.zoom_y = 0
    # spin ball into place
    16.delta_add.times do
      ball.angle += 22.5/self.delta
      ball.zoom_x += 0.0625/self.delta
      ball.zoom_y += 0.0625/self.delta
      pbWait(1)
    end
    ball.angle = 0
    ball.zoom = 1
    # take screenshot
    bmp = Graphics.snap_to_bitmap
    pbWait(8.delta_add)
    # dispose ball sprite
    ball.dispose
    # black background
    black = Sprite.new(@viewport)
    black.bitmap = Bitmap.new(@viewport.width, @viewport.height)
    black.bitmap.fill_rect(0, 0, @viewport.width, @viewport.height, Color.black)
    # split screenshot into two halves
    field1 = Sprite.new(@viewport)
    field1.bitmap = Bitmap.new(@viewport.width, @viewport.height)
    field1.bitmap.blt(0, 0, bmp, @viewport.rect)
    field1.src_rect.height = @viewport.height/2
    field2 = Sprite.new(@viewport)
    field2.bitmap = field1.bitmap.clone
    field2.y = @viewport.height/2
    field2.src_rect.height = @viewport.height/2
    field2.src_rect.y = @viewport.height/2
    # move halves off screen
    16.delta_add.times do
      field1.x -= (@viewport.width/16)/self.delta
      field2.x += (@viewport.width/16)/self.delta
      pbWait(1)
    end
    field1.x = -@viewport.width
    field2.x = @viewport.width
    @viewport.color = Color.black
    # dispose unused sprites
    black.dispose
    field1.dispose
    field2.dispose
  end
  #-----------------------------------------------------------------------------
  # second variant trainer battle animation
  #-----------------------------------------------------------------------------
  def anim2
    # take screenshot and draw black background
    bmp = Graphics.snap_to_bitmap
    black = Sprite.new(@viewport)
    black.bitmap = Bitmap.new(@viewport.width, @viewport.height)
    black.bitmap.fill_rect(0, 0, @viewport.width, @viewport.height, Color.black)
    # split screenshot into two halves
    field1 = Sprite.new(@viewport)
    field1.bitmap = Bitmap.new(@viewport.width, @viewport.height)
    field1.bitmap.blt(0, 0, bmp, @viewport.rect)
    field1.src_rect.height = @viewport.height/2
    field2 = Sprite.new(@viewport)
    field2.bitmap = field1.bitmap.clone
    field2.y = @viewport.height/2
    field2.src_rect.height = @viewport.height/2
    field2.src_rect.y = @viewport.height/2
    # draw ballsprites for transition
    ball1 = Sprite.new(@viewport)
    ball1.bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/ball")
    ball1.center!
    ball1.x = @viewport.width + ball1.ox
    ball1.y = @viewport.height/4
    ball1.zoom_x = 0.5
    ball1.zoom_y = 0.5
    ball2 = Sprite.new(@viewport)
    ball2.bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/ball")
    ball2.center!
    ball2.y = (@viewport.height/4)*3
    ball2.x = -ball2.ox
    ball2.zoom_x = 0.5
    ball2.zoom_y = 0.5
    # move ballsprites on screen
    16.delta_add.times do
      ball1.x -= (@viewport.width/8)/self.delta
      ball2.x += (@viewport.width/8)/self.delta
      pbWait(1)
    end
    # move screenshots
    32.delta_add.times do
      field1.x -= (@viewport.width/16)/self.delta
      field1.y -= (@viewport.height/32)/self.delta
      field2.x += (@viewport.width/16)/self.delta
      field2.y += (@viewport.height/32)/self.delta
      pbWait(1)
    end
    @viewport.color = Color.black
    # dispose unused sprites
    black.dispose
    ball1.dispose
    ball2.dispose
    field1.dispose
    field2.dispose
  end
  #-----------------------------------------------------------------------------
  # third variant trainer battle animation
  #-----------------------------------------------------------------------------
  def anim3
    # hash to store all sprites
    balls = {}
    rects = {}
    # creates blank ball bitmap
    ball = Bitmap.new(@viewport.height/6,@viewport.height/6)
    bmp = pbBitmap("Graphics/EBDX/Transitions/Common/ball")
    ball.stretch_blt(Rect.new(0,0,ball.width,ball.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
    # creates necessary sprites
    for i in 0...6
      # black rectangles
      rects["#{i}"] = Sprite.new(@viewport)
      rects["#{i}"].bitmap = Bitmap.new(2,@viewport.height/6)
      rects["#{i}"].bitmap.fill_rect(0,0,2,@viewport.height/6,Color.black)
      rects["#{i}"].x = (i%2==0) ? -32 : @viewport.width+32
      rects["#{i}"].ox = (i%2==0) ? 0 : 2
      rects["#{i}"].y = (@viewport.height/6)*i
      rects["#{i}"].zoom_x = 0
      # ballsprites
      balls["#{i}"] = Sprite.new(@viewport)
      balls["#{i}"].bitmap = ball
      balls["#{i}"].center!
      balls["#{i}"].x = rects["#{i}"].x
      balls["#{i}"].y = rects["#{i}"].y + rects["#{i}"].bitmap.height/2
    end
    # moves sprites across screen
    for j in 0...28.delta_add
      for i in 0...6
        balls["#{i}"].x += ((i%2==0) ? 24 : -24)/self.delta
        balls["#{i}"].angle -= ((i%2==0) ? 32 : -32)/self.delta
        rects["#{i}"].zoom_x += 12/self.delta
      end
      pbWait(1)
    end
    @viewport.color = Color.black
    # disposes unused sprites
    pbDisposeSpriteHash(balls)
    pbDisposeSpriteHash(rects)
  end
  #-----------------------------------------------------------------------------
  # plays the little rainbow sequence before the animation (can be standalone)
  #-----------------------------------------------------------------------------
  def rainbowIntro(viewport=nil)
    @viewport = viewport if !@viewport && !viewport.nil?
    @sprites = {} if !@sprites
    # takes screenshot
    bmp = Graphics.snap_to_bitmap
    # creates non-blurred overlay
    @sprites["bg1"] = Sprite.new(@viewport)
    @sprites["bg1"].bitmap = Bitmap.new(@viewport.width, @viewport.height)
    @sprites["bg1"].bitmap.blt(0, 0, bmp, @viewport.rect)
    @sprites["bg1"].center!(true)
    # creates blurred overlay
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = @sprites["bg1"].bitmap.clone
    @sprites["bg2"].blur_sprite(3)
    @sprites["bg2"].center!(true)
    @sprites["bg2"].opacity = 0
    # creates rainbow rings
    for i in 1..2
      z = [0.35, 0.1]
      @sprites["glow#{i}"] = Sprite.new(@viewport)
      @sprites["glow#{i}"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/glow")
      @sprites["glow#{i}"].ox = @sprites["glow#{i}"].bitmap.width/2
      @sprites["glow#{i}"].oy = @sprites["glow#{i}"].bitmap.height/2
      @sprites["glow#{i}"].x = @viewport.width/2
      @sprites["glow#{i}"].y = @viewport.height/2
      @sprites["glow#{i}"].zoom_x = z[i-1]
      @sprites["glow#{i}"].zoom_y = z[i-1]
      @sprites["glow#{i}"].opacity = 0
    end
    # main animation
    for i in 0...32.delta_add
      # zooms in the two screenshots
      @sprites["bg1"].zoom_x += 0.02/self.delta
      @sprites["bg1"].zoom_y += 0.02/self.delta
      @sprites["bg2"].zoom_x += 0.02/self.delta
      @sprites["bg2"].zoom_y += 0.02/self.delta
      # fades in the blurry screenshot
      @sprites["bg2"].opacity += 12/self.delta
      # fades to white
      if i >= 16.delta_add
        @sprites["bg2"].tone.all += 16/self.delta
      end
      # zooms in rainbow rings
      if i >= 28.delta_add
        @sprites["glow1"].opacity += 64/self.delta
        @sprites["glow1"].zoom_x += 0.02/self.delta
        @sprites["glow1"].zoom_y += 0.02/self.delta
      end
      Graphics.update
    end
    @viewport.color = Color.new(255, 255, 255, 0)
    # second part of animation
    for i in 0...48.delta_add
      # zooms in rainbow rings
      @sprites["glow1"].zoom_x += 0.02/self.delta
      @sprites["glow1"].zoom_y += 0.02/self.delta
      if i >= 8.delta_add
        @sprites["glow2"].opacity += 64/self.delta
        @sprites["glow2"].zoom_x += 0.02/self.delta
        @sprites["glow2"].zoom_y += 0.02/self.delta
      end
      # fades viewport to white
      if i >= 32.delta_add
        @viewport.color.alpha += 16/self.delta
      end
      Graphics.update
    end
    @viewport.color = Color.white
    # disposes of the elements
    pbDisposeSpriteHash(@sprites)
    EliteBattle.set(:colorAlpha, 255)
    return true
  end
  #-----------------------------------------------------------------------------
  # displays the animation for the evil team logo (can be standalone)
  #-----------------------------------------------------------------------------
  def evilTeam(viewport = nil, trainerid = -1)
    @viewport = viewport if !@viewport && !viewport.nil?
    @sprites = {} if !@sprites
    @viewport.color = Color.new(0, 0, 0, 0)
    # fades viewport to black
    8.delta_add.times do
      @viewport.color.alpha += 32/self.delta
      pbWait(1)
    end
    @viewport.color.alpha = 255
    bitmaps = [
      "Graphics/EBDX/Transitions/EvilTeam/background",
      "Graphics/EBDX/Transitions/EvilTeam/swirl",
      "Graphics/EBDX/Transitions/EvilTeam/ray0",
      "Graphics/EBDX/Transitions/EvilTeam/ray1",
      "Graphics/EBDX/Transitions/EvilTeam/logo0",
      "Graphics/EBDX/Transitions/EvilTeam/logo1",
      "Graphics/EBDX/Transitions/EvilTeam/ring0",
      "Graphics/EBDX/Transitions/EvilTeam/ring1"
    ]
    # try resolve the bitmaps
    bitmaps = checkForTrainerVariant(bitmaps, GameData::TrainerType.get(trainerid))
    # creates background graphic
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(bitmaps[0])
    @sprites["bg"].color = Color.black
    # creates background swirl
    @sprites["bg2"] = Sprite.new(@viewport)
    @sprites["bg2"].bitmap = pbBitmap(bitmaps[1])
    @sprites["bg2"].ox = @sprites["bg2"].bitmap.width/2
    @sprites["bg2"].oy = @sprites["bg2"].bitmap.height/2
    @sprites["bg2"].x = @viewport.width/2
    @sprites["bg2"].y = @viewport.height/2
    @sprites["bg2"].visible = false
    # sets up all particles
    speed = []
    for j in 0...16
      @sprites["e1_#{j}"] = Sprite.new(@viewport)
      bmp = pbBitmap(bitmaps[2])
      @sprites["e1_#{j}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      w = bmp.width/(1 + rand(3))
      @sprites["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
      @sprites["e1_#{j}"].oy = @sprites["e1_#{j}"].bitmap.height/2
      @sprites["e1_#{j}"].angle = rand(360)
      @sprites["e1_#{j}"].opacity = 0
      @sprites["e1_#{j}"].x = @viewport.width/2
      @sprites["e1_#{j}"].y = @viewport.height/2
      speed.push(4 + rand(5))
    end
    # creates logo
    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap(bitmaps[4])
    @sprites["logo"].ox = @sprites["logo"].bitmap.width/2
    @sprites["logo"].oy = @sprites["logo"].bitmap.height/2
    @sprites["logo"].x = @viewport.width/2
    @sprites["logo"].y = @viewport.height/2
    @sprites["logo"].memorize_bitmap
    @sprites["logo"].bitmap = pbBitmap(bitmaps[5])
    @sprites["logo"].zoom_x = 2
    @sprites["logo"].zoom_y = 2
    @sprites["logo"].z = 50
    # creates flash ring graphic
    @sprites["ring"] = Sprite.new(@viewport)
    @sprites["ring"].bitmap = pbBitmap(bitmaps[6])
    @sprites["ring"].ox = @sprites["ring"].bitmap.width/2
    @sprites["ring"].oy = @sprites["ring"].bitmap.height/2
    @sprites["ring"].x = @viewport.width/2
    @sprites["ring"].y = @viewport.height/2
    @sprites["ring"].zoom_x = 0
    @sprites["ring"].zoom_y = 0
    @sprites["ring"].z = 100
    # creates secondary particles
    for j in 0...32
      @sprites["e2_#{j}"] = Sprite.new(@viewport)
      bmp = pbBitmap(bitmaps[3])
      @sprites["e2_#{j}"].bitmap = bmp
      @sprites["e2_#{j}"].oy = @sprites["e2_#{j}"].bitmap.height/2
      @sprites["e2_#{j}"].angle = rand(360)
      @sprites["e2_#{j}"].opacity = 0
      @sprites["e2_#{j}"].x = @viewport.width/2
      @sprites["e2_#{j}"].y = @viewport.height/2
      @sprites["e2_#{j}"].z = 100
    end
    # creates secondary flash ring
    @sprites["ring2"] = Sprite.new(@viewport)
    @sprites["ring2"].bitmap = pbBitmap(bitmaps[7])
    @sprites["ring2"].ox = @sprites["ring2"].bitmap.width/2
    @sprites["ring2"].oy = @sprites["ring2"].bitmap.height/2
    @sprites["ring2"].x = @viewport.width/2
    @sprites["ring2"].y = @viewport.height/2
    @sprites["ring2"].visible = false
    @sprites["ring2"].zoom_x = 0
    @sprites["ring2"].zoom_y = 0
    @sprites["ring2"].z = 100
    # first phase of animation
    for i in 0...32.delta_add
      @viewport.color.alpha -= 8/self.delta if @viewport.color.alpha > 0
      @sprites["logo"].zoom_x -= (1/32.0)/self.delta
      @sprites["logo"].zoom_y -= (1/32.0)/self.delta
      for j in 0...16
        next if j > i/4.delta_add
        if @sprites["e1_#{j}"].ox < -(@viewport.width/2)
          speed[j] = 4 + rand(5)
          @sprites["e1_#{j}"].opacity = 0
          @sprites["e1_#{j}"].ox = 0
          @sprites["e1_#{j}"].angle = rand(360)
          bmp = pbBitmap(bitmaps[3])
          @sprites["e1_#{j}"].bitmap.clear
          w = bmp.width/(1 + rand(3))
          @sprites["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
        end
        @sprites["e1_#{j}"].opacity += speed[j]/self.delta
        @sprites["e1_#{j}"].ox -=  [1, speed[j]/self.delta].max
      end
      pbWait(1)
    end
    # configures logo graphic
    @sprites["logo"].color = Color.white
    @sprites["logo"].restore_bitmap
    @sprites["ring2"].visible = true
    @sprites["bg2"].visible = true
    @viewport.color = Color.white
    # final animation of background and particles
    for i in 0...144.delta_add
      if i >= 128.delta_add
        @viewport.color.alpha += 16/self.delta
      else
        @viewport.color.alpha -= 16/self.delta if @viewport.color.alpha > 0
      end
      @sprites["logo"].color.alpha -= 16/self.delta if @sprites["logo"].color.alpha > 0
      @sprites["bg"].color.alpha -= 8/self.delta if @sprites["bg"].color.alpha > 0
      for j in 0...16
        if @sprites["e1_#{j}"].ox < -(@viewport.width/2)
          speed[j] = 4 + rand(5)
          @sprites["e1_#{j}"].opacity = 0
          @sprites["e1_#{j}"].ox = 0
          @sprites["e1_#{j}"].angle = rand(360)
          bmp = pbBitmap(bitmaps[2])
          @sprites["e1_#{j}"].bitmap.clear
          w = bmp.width/(1 + rand(3))
          @sprites["e1_#{j}"].bitmap.stretch_blt(Rect.new(0,0,w,bmp.height),bmp,Rect.new(0,0,bmp.width,bmp.height))
        end
        @sprites["e1_#{j}"].opacity += speed[j]/self.delta
        @sprites["e1_#{j}"].ox -=  [1, speed[j]/self.delta].max
      end
      for j in 0...32
        next if j > (i*2).delta_add
        @sprites["e2_#{j}"].ox -= 16/self.delta
        @sprites["e2_#{j}"].opacity += 16/self.delta
      end
      @sprites["ring"].zoom_x += 0.1/self.delta
      @sprites["ring"].zoom_y += 0.1/self.delta
      @sprites["ring"].opacity -= 8/self.delta
      @sprites["ring2"].zoom_x += 0.2/self.delta if @sprites["ring2"].zoom_x < 3
      @sprites["ring2"].zoom_y += 0.2/self.delta if @sprites["ring2"].zoom_y < 3
      @sprites["ring2"].opacity -= 16/self.delta
      @sprites["bg2"].angle += 2/self.delta if $PokemonSystem.screensize < 2
      pbWait(1)
    end
    # disposes all sprites
    pbDisposeSpriteHash(@sprites)
    # fades viewport
    8.delta_add.times do
      @viewport.color.red -= (255/8.0)/self.delta
      @viewport.color.green -= (255/8.0)/self.delta
      @viewport.color.blue -= (255/8.0)/self.delta
      pbWait(1)
    end
    @viewport.color = Color.black
    EliteBattle.set(:colorAlpha, 255)
    return true
  end
  #-----------------------------------------------------------------------------
  # plays Team Skull styled intro animation
  #-----------------------------------------------------------------------------
  def teamSkull(viewport = nil, trainerid = -1)
    @viewport = viewport if !@viewport && !viewport.nil?
    # set up initial variables
    @sprites = {} if !@sprites
    @fpIndex = 0
    @spIndex = 0
    pbWait(4)
    # get list of required graphics
    bitmaps = [
      "Graphics/EBDX/Transitions/Skull/background",
      "Graphics/EBDX/Transitions/Skull/smoke",
      "Graphics/EBDX/Transitions/Skull/logo",
      "Graphics/EBDX/Transitions/Skull/shine",
      "Graphics/EBDX/Transitions/Skull/rainbow",
      "Graphics/EBDX/Transitions/Skull/glow",
      "Graphics/EBDX/Transitions/Skull/burst",
      "Graphics/EBDX/Transitions/Skull/ray",
      "Graphics/EBDX/Transitions/Skull/particle",
      "Graphics/EBDX/Transitions/Skull/paint0",
      "Graphics/EBDX/Transitions/Skull/splat0",
      "Graphics/EBDX/Transitions/Skull/splat1",
      "Graphics/EBDX/Transitions/Skull/splat2"
    ]
    # try resolve the bitmaps
    bitmaps = checkForTrainerVariant(bitmaps, GameData::TrainerType.get(trainerid))
    # set up background
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = pbBitmap(bitmaps[0])
    @sprites["bg"].color = Color.new(0,0,0,92)
    # set up smoke particles
    for j in 0...20
      @sprites["s#{j}"] = Sprite.new(@viewport)
      @sprites["s#{j}"].bitmap = pbBitmap(bitmaps[1])
      @sprites["s#{j}"].center!(true)
      @sprites["s#{j}"].opacity = 0
    end
    # set up ray particles
    for i in 0...16
      @sprites["r#{i}"] = Sprite.new(@viewport)
      @sprites["r#{i}"].opacity = 0
    end
    # set up logo
    @sprites["logo"] = Sprite.new(@viewport)
    @sprites["logo"].bitmap = pbBitmap(bitmaps[2])
    @sprites["logo"].center!(true)
    @sprites["logo"].z = 9999
    @sprites["logo"].zoom_x = 2
    @sprites["logo"].zoom_y = 2
    @sprites["logo"].color = Color.black
    # set up logo shine
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap(bitmaps[3])
    @sprites["shine"].center!(true)
    @sprites["shine"].x -= 72
    @sprites["shine"].y -= 64
    @sprites["shine"].z = 99999
    @sprites["shine"].opacity = 0
    @sprites["shine"].zoom_x = 0.6
    @sprites["shine"].zoom_y = 0.4
    @sprites["shine"].angle = 30
    # set up rainbow particle
    @sprites["rainbow"] = Sprite.new(@viewport)
    @sprites["rainbow"].bitmap = pbBitmap(bitmaps[4])
    @sprites["rainbow"].center!(true)
    @sprites["rainbow"].z = 99999
    @sprites["rainbow"].opacity = 0
    # set up logo glow
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].bitmap = pbBitmap(bitmaps[5])
    @sprites["glow"].center!(true)
    @sprites["glow"].opacity = 0
    @sprites["glow"].z = 9
    @sprites["glow"].zoom_x = 0.6
    @sprites["glow"].zoom_y = 0.6
    # set up burst sprite
    @sprites["burst"] = Sprite.new(@viewport)
    @sprites["burst"].bitmap = pbBitmap(bitmaps[6])
    @sprites["burst"].center!(true)
    @sprites["burst"].zoom_x = 0
    @sprites["burst"].zoom_y = 0
    @sprites["burst"].opacity = 0
    @sprites["burst"].z = 999
    @sprites["burst"].color = Color.new(255,255,255,0)
    # set up particles
    for j in 0...24
      @sprites["p#{j}"] = Sprite.new(@viewport)
      @sprites["p#{j}"].bitmap = pbBitmap(bitmaps[8])
      @sprites["p#{j}"].center!(true)
      @sprites["p#{j}"].center!
      z = 1 - rand(81)/100.0
      @sprites["p#{j}"].zoom_x = z
      @sprites["p#{j}"].zoom_y = z
      @sprites["p#{j}"].param = 1 + rand(8)
      r = 256 + rand(65)
      cx, cy = randCircleCord(r)
      @sprites["p#{j}"].ex = @sprites["p#{j}"].x - r + cx
      @sprites["p#{j}"].ey = @sprites["p#{j}"].y - r + cy
      r = rand(33)/100.0
      @sprites["p#{j}"].x = @viewport.width/2 - (@sprites["p#{j}"].ex - @viewport.width/2)*r
      @sprites["p#{j}"].y = @viewport.height/2 - (@viewport.height/2 - @sprites["p#{j}"].ey)*r
      @sprites["p#{j}"].visible = false
    end
    # set up paint strokes
    x = [@viewport.width/3,@viewport.width+32,16,-32,2*@viewport.width/3,@viewport.width+32,0,@viewport.width+64]
    y = [@viewport.height+32,@viewport.height+32,-32,@viewport.height/2,@viewport.height+64,@viewport.height/2,@viewport.height-64,@viewport.height/2+32]
    a = [50,135,-70,10,105,165,-30,190]
    for j in 0...8
      @sprites["sl#{j}"] = Sprite.new(@viewport)
      @sprites["sl#{j}"].bitmap = pbBitmap(bitmaps[9])
      @sprites["sl#{j}"].oy = @sprites["sl#{j}"].bitmap.height/2
      @sprites["sl#{j}"].z = j < 2 ? 999 : 99999
      @sprites["sl#{j}"].ox = -@sprites["sl#{j}"].bitmap.width
      @sprites["sl#{j}"].x = x[j]
      @sprites["sl#{j}"].y = y[j]
      @sprites["sl#{j}"].angle = a[j]
      @sprites["sl#{j}"].param = (@sprites["sl#{j}"].bitmap.width/8)
    end
    # set up paint splats
    for j in 0...12
      @sprites["sp#{j}"] = Sprite.new(@viewport)
      @sprites["sp#{j}"].bitmap = pbBitmap(bitmaps[10 + rand(3)])
      @sprites["sp#{j}"].center!
      @sprites["sp#{j}"].x = rand(@viewport.width)
      @sprites["sp#{j}"].y = rand(@viewport.height)
      @sprites["sp#{j}"].visible = false
      z = 1 + rand(40)/100.0
      @sprites["sp#{j}"].zoom_x = z
      @sprites["sp#{j}"].zoom_y = z
      @sprites["sp#{j}"].z = 99999
    end
    # begin animation
    for i in 0...32
      @viewport.color.alpha -= 16
      @sprites["logo"].zoom_x -= 1/32.0
      @sprites["logo"].zoom_y -= 1/32.0
      @sprites["logo"].color.alpha -= 8
      for j in 0...16
        next if j > @fpIndex/2
        if @sprites["r#{j}"].opacity <= 0
          bmp = pbBitmap(bitmaps[7])
          w = rand(65) + 16
          @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
          @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["r#{j}"].center!(true)
          @sprites["r#{j}"].ox = -(64 + rand(17))
          @sprites["r#{j}"].zoom_x = 1
          @sprites["r#{j}"].zoom_y = 1
          @sprites["r#{j}"].angle = rand(360)
          @sprites["r#{j}"].param = 2 + rand(5)
        end
        @sprites["r#{j}"].ox -= @sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_x += 0.001*@sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_y -= 0.001*@sprites["r#{j}"].param
        if @sprites["r#{j}"].ox > -128
          @sprites["r#{j}"].opacity += 8
        else
          @sprites["r#{j}"].opacity -= 2*@sprites["r#{j}"].param
        end
      end
      if i >= 24
        @sprites["shine"].opacity += 48
        @sprites["shine"].zoom_x += 0.02
        @sprites["shine"].zoom_y += 0.02
      end
      @fpIndex += 1
      Graphics.update
    end
    @viewport.color = Color.new(0,0,0,0)
    for i in 0...128
      @sprites["shine"].opacity -= 16
      @sprites["shine"].zoom_x += 0.02
      @sprites["shine"].zoom_y += 0.02
      if i < 8
        z = (i < 4) ? 0.02 : -0.02
        @sprites["logo"].zoom_x -= z
        @sprites["logo"].zoom_y -= z
      end
      for j in 0...16
        if @sprites["r#{j}"].opacity <= 0
          bmp = pbBitmap(bitmaps[7])
          w = rand(65) + 16
          @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
          @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["r#{j}"].center!(true)
          @sprites["r#{j}"].ox = -(64 + rand(17))
          @sprites["r#{j}"].zoom_x = 1
          @sprites["r#{j}"].zoom_y = 1
          @sprites["r#{j}"].angle = rand(360)
          @sprites["r#{j}"].param = 2 + rand(5)
        end
        @sprites["r#{j}"].ox -= @sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_x += 0.001*@sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_y -= 0.001*@sprites["r#{j}"].param
        if @sprites["r#{j}"].ox > -128
          @sprites["r#{j}"].opacity += 8
        else
          @sprites["r#{j}"].opacity -= 2*@sprites["r#{j}"].param
        end
      end
      for j in 0...24
        @sprites["p#{j}"].visible = true
        next if @sprites["p#{j}"].opacity <= 0
        x = (@sprites["p#{j}"].ex - @viewport.width/2)/(4.0*@sprites["p#{j}"].param)
        y = (@viewport.height/2 - @sprites["p#{j}"].ey)/(4.0*@sprites["p#{j}"].param)
        @sprites["p#{j}"].x -= x
        @sprites["p#{j}"].y -= y
        @sprites["p#{j}"].opacity -= @sprites["p#{j}"].param
      end
      for j in 0...20
        if @sprites["s#{j}"].opacity <= 0
          @sprites["s#{j}"].opacity = 255
          r = 160 + rand(33)
          cx, cy = randCircleCord(r)
          @sprites["s#{j}"].center!(true)
          @sprites["s#{j}"].ex = @sprites["s#{j}"].x - r + cx
          @sprites["s#{j}"].ey = @sprites["s#{j}"].y - r + cy
          @sprites["s#{j}"].toggle = rand(2)==0 ? 2 : -2
          @sprites["s#{j}"].param = 2 + rand(4)
          z = 1 - rand(41)/100.0
          @sprites["s#{j}"].zoom_x = z
          @sprites["s#{j}"].zoom_y = z
        end
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].ex)*0.02
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].ey)*0.02
        @sprites["s#{j}"].opacity -= @sprites["s#{j}"].param*1.5
        @sprites["s#{j}"].angle += @sprites["s#{j}"].toggle if $PokemonSystem.screensize < 2
        @sprites["s#{j}"].zoom_x -= 0.002
        @sprites["s#{j}"].zoom_y -= 0.002
      end
      # phase 2
      @sprites["bg"].color.alpha -= 2
      @sprites["glow"].opacity += (i < 6) ? 48 : -24
      @sprites["glow"].zoom_x += 0.05
      @sprites["glow"].zoom_y += 0.05
      @sprites["rainbow"].zoom_x += 0.01
      @sprites["rainbow"].zoom_y += 0.01
      @sprites["rainbow"].opacity += (i < 16) ? 32 : -16
      @sprites["burst"].zoom_x += 0.2
      @sprites["burst"].zoom_y += 0.2
      @sprites["burst"].color.alpha += 20
      @sprites["burst"].opacity += 16
      if i >= 72
        for j in 0...8
          next if j > @spIndex/6
          @sprites["sl#{j}"].ox += @sprites["sl#{j}"].param if @sprites["sl#{j}"].ox < 0
        end
        for j in 0...12
          next if @spIndex < 4
          next if j > (@spIndex-4)/4
          @sprites["sp#{j}"].visible = true
        end
        @spIndex += 1
      end
      @viewport.color.alpha += 16 if i >= 112
      Graphics.update
    end
    # dispose all sprites
    pbDisposeSpriteHash(@sprites)
    EliteBattle.set(:colorAlpha, 0)
    return true
  end
  #-----------------------------------------------------------------------------
  def delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Integrated VS sequence for trainers
#===============================================================================
class IntegratedVSSequence
  #-----------------------------------------------------------------------------
  # constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport,scene,trainerid)
    @viewport = viewport
    @scene = scene
    @trainerid = trainerid
    @disposed = false
    @started = false
    @i = 0
    @sprites = {}
    # draws the VS text
    @sprites["vs"] = Sprite.new(@viewport)
    @sprites["vs"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/vs")
    @sprites["vs"].center!
    @sprites["vs"].x = 140
    @sprites["vs"].y = 140
    @sprites["vs"].zoom = 2
    @sprites["vs"].opacity = 0
    @sprites["vs"].z = 999
    @sprites["vs"].toggle = 1
    # draws the scrolling background
    @sprites["bg"] = ScrollingSprite.new(@viewport)
    id = GameData::TrainerType.get(@trainerid).id_number
    str = sprintf("vsBar%s", @trainerid)
    str = sprintf("vsBar%03d", id) if !pbResolveBitmap("Graphics/EBDX/Transitions/Common/#{str}")
    str = "vsBar" if !pbResolveBitmap("Graphics/EBDX/Transitions/Common/#{str}")
    @sprites["bg"].setBitmap("Graphics/EBDX/Transitions/Common/#{str}")
    @sprites["bg"].visible = false
    @sprites["bg"].z = 90
    # draws lightning
    @sprites["streak"] = ScrollingSprite.new(@viewport)
    @sprites["streak"].setBitmap("Graphics/EBDX/Transitions/Common/light")
    @sprites["streak"].direction = -1
    @sprites["streak"].speed = 24
    @sprites["streak"].oy = @sprites["streak"].bitmap.height/2
    @sprites["streak"].y = 140
    @sprites["streak"].x = -@viewport.width
    @sprites["streak"].z = 91
    # draws the animated shine ball
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/shine")
    @sprites["shine"].center!
    @sprites["shine"].y = 140
    @sprites["shine"].x = 140
    @sprites["shine"].z = 90
    @sprites["shine"].opacity = 0
    @sprites["shine"].toggle = 1
    # draws trainer accent
    @sprites["trainer_a"] = Sprite.new(@viewport)
    @sprites["trainer_a"].color = Color.new(65,190,226,255*0.8)
    @sprites["trainer_a"].visible = false
    @sprites["trainer_a"].z = 95
  end
  #-----------------------------------------------------------------------------
  # begins animation
  #-----------------------------------------------------------------------------
  def start
    return if self.disposed?
    # positions sprite
    @sprites["trainer_a"].bitmap = @scene.sprites["trainer_0"].bitmap.clone
    @sprites["trainer_a"].ox = @scene.sprites["trainer_0"].ox
    @sprites["trainer_a"].oy = @scene.sprites["trainer_0"].oy
    @sprites["trainer_a"].x = @scene.sprites["trainer_0"].x
    @sprites["trainer_a"].y = @scene.sprites["trainer_0"].y - 1
    # begins animation
    8.times do
      @sprites["shine"].opacity += 32
      @sprites["streak"].x += @viewport.width/8
      @sprites["vs"].zoom -= 0.125
      @sprites["vs"].opacity += 32
      @scene.wait
    end
    @viewport.color = Color.white
    @sprites["bg"].visible = true
    @sprites["trainer_a"].visible = true
    @sprites["streak"].opacity = 255
    @started = true
  end
  #-----------------------------------------------------------------------------
  # main update for animation
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    @sprites["bg"].update
    @sprites["streak"].update
    @sprites["shine"].angle += 8.delta_sub if $PokemonSystem.screensize < 2
    @sprites["shine"].zoom_x -= (0.04*@sprites["shine"].toggle).delta_sub(true)
    @sprites["shine"].zoom_y -= (0.04*@sprites["shine"].toggle).delta_sub(true)
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 0.8 || @sprites["shine"].zoom_x >= 1.2
    # skips the animation that is not called before the end of the whole animation
    return if !@started
    @viewport.color.alpha -= 16.delta_sub if @viewport.color.alpha > 0
    @sprites["trainer_a"].x -= 1 if @i < 12
    @sprites["vs"].x += @sprites["vs"].toggle
    @sprites["vs"].y += @sprites["vs"].toggle
    @sprites["vs"].toggle *= -1 if (@sprites["vs"].x - 140).abs >= 2
    @i += 1 if @i < 128
  end
  #-----------------------------------------------------------------------------
  # iteratively brings the animation to an end
  #-----------------------------------------------------------------------------
  def finish
    return if self.disposed?
    for key in @sprites.keys
      @sprites[key].opacity -= 16
    end
    self.dispose if @sprites["bg"].opacity <= 0
  end
  #-----------------------------------------------------------------------------
  # disposes all sprites
  #-----------------------------------------------------------------------------
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  # checks if disposed
  #-----------------------------------------------------------------------------
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  # compatibility for pbFadeOutAndHide
  #-----------------------------------------------------------------------------
  def color; end
  def color=(val); end
  def delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
end

#===============================================================================
#  The main class responsible for loading up the S/M styled transitions
#  Only for single trainer class battles
#===============================================================================
class SunMoonBattleTransitions
  attr_accessor :speed
  attr_reader :started
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' trainer: %s>', @trainer.inspect)
    return str
  end
  #-----------------------------------------------------------------------------
  # creates the transition handler
  #-----------------------------------------------------------------------------
  def initialize(*args)
    return if args.length < 4
    # sets up main viewports
    @started = false
    @viewport = args[0]
    @viewport.color = Color.new(255,255,255,EliteBattle.get(:colorAlpha))
    EliteBattle.set(:colorAlpha,0)
    @msgview = args[1]
    # sets up variables
    @disposed = false
    @sentout = false
    @scene = args[2]
    @trainer = args[3]
    @trainertype = GameData::TrainerType.get(@trainer.trainer_type)
    @speed = 1
    @frames = 1
    @curFrame = 1
    @sprites = {}
    @evilteam = EliteBattle.can_transition?("evilTeam", @trainertype.id, :Trainer, @trainer.name, @trainer.partyID)
    @teamskull = EliteBattle.can_transition?("teamSkull", @trainertype.id, :Trainer, @trainer.name, @trainer.partyID)
    # retreives additional parameters
    self.getParameters(@trainer)
    # initializes the backdrop
    args = "@viewport,@trainertype,@evilteam,@teamskull"
    var = @variant == "trainer" ? "default" : @variant
    # check if can continue
    unless var.is_a?(String) && !var.empty?
      EliteBattle.log.error("Cannot get VS sequence variant for Sun/Moon battle transition for trainer: #{@trainertype.id}!")
      var = "default"
    end
    # loag background effect
    @sprites["background"] = eval("SunMoon#{var.capitalize}Background.new(#{args})")
    @sprites["background"].speed = 24
    # trainer shadow
    @sprites["shade"] = Sprite.new(@viewport)
    @sprites["shade"].z = 250
    # trainer glow (left)
    @sprites["glow"] = Sprite.new(@viewport)
    @sprites["glow"].z = 250
    # trainer glow (right)
    @sprites["glow2"] = Sprite.new(@viewport)
    @sprites["glow2"].z = 250
    # trainer graphic
    @sprites["trainer_"] = Sprite.new(@viewport)
    @sprites["trainer_"].z = 350
    file = sprintf("Graphics/EBDX/Transitions/%s", @trainertype.id)
    file = sprintf("Graphics/EBDX/Transitions/trainer%03d", @trainertype.id_number) if !pbResolveBitmap(file)
    @sprites["trainer_"].bitmap = pbBitmap(file)
    # splice bitmap
    if @sprites["trainer_"].bitmap.height > @viewport.height
      @frames = (@sprites["trainer_"].bitmap.height.to_f/@viewport.height).ceil
      @sprites["trainer_"].src_rect.height = @viewport.height
    end
    @sprites["trainer_"].ox = @sprites["trainer_"].src_rect.width/2
    @sprites["trainer_"].oy = @sprites["trainer_"].src_rect.height/2
    @sprites["trainer_"].x = @viewport.width/2 if @variant != "plasma"
    @sprites["trainer_"].y = @viewport.height/2
    @sprites["trainer_"].tone = Tone.new(255,255,255)
    @sprites["trainer_"].zoom_x = 1.32 if @variant != "plasma"
    @sprites["trainer_"].zoom_y = 1.32 if @variant != "plasma"
    @sprites["trainer_"].opacity = 0
    # sets a bitmap for the trainer
    bmp = Bitmap.new(@sprites["trainer_"].src_rect.width, @sprites["trainer_"].src_rect.height)
    bmp.blt(0, 0, @sprites["trainer_"].bitmap, Rect.new(0, @sprites["trainer_"].src_rect.height*(@frames-1), @sprites["trainer_"].src_rect.width, @sprites["trainer_"].src_rect.height))
    # colours the shadow
    @sprites["shade"].bitmap = bmp
    @sprites["shade"].center!(true)
    @sprites["shade"].color = Color.new(10,169,245,204)
    @sprites["shade"].color = Color.new(150,115,255,204) if @variant == "elite"
    @sprites["shade"].color = Color.new(115,216,145,204) if @variant == "digital"
    @sprites["shade"].opacity = 0
    @sprites["shade"].visible = false if @variant == "crazy" || @variant == "plasma"
    # creates and colours an outer glow for the trainer
    c = Color.black
    c = Color.white if @variant == "crazy" || @variant == "digital" || @variant == "plasma"
    @sprites["glow"].bitmap = bmp
    @sprites["glow"].center!
    @sprites["glow"].glow(c, 35, false)
    @sprites["glow"].color = c
    @sprites["glow"].y = @viewport.height/2 + @viewport.height
    @sprites["glow"].src_rect.set(0,@viewport.height,@viewport.width/2,0)
    @sprites["glow"].ox = @sprites["glow"].src_rect.width
    @sprites["glow2"].bitmap = @sprites["glow"].bitmap
    @sprites["glow2"].center!
    @sprites["glow2"].ox = 0
    @sprites["glow2"].src_rect.set(@viewport.width/2,0,@viewport.width/2,0)
    @sprites["glow2"].color = c
    @sprites["glow2"].y = @viewport.height/2
    # creates the fade-out ball graphic overlay
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].z = 999999
    @sprites["overlay"].bitmap = Bitmap.new(@viewport.width,@viewport.height)
    @sprites["overlay"].opacity = 0
  end
  #-----------------------------------------------------------------------------
  # starts the animation
  #-----------------------------------------------------------------------------
  def start
    @started = true
    return if self.disposed?
    # fades in viewport
    16.times do
      @viewport.color.alpha -= 16 if @viewport.color.alpha > 0
      if @variant == "plasma"
        @sprites["trainer_"].x += (@viewport.width/3)/8
        self.update
      else
        @sprites["trainer_"].zoom_x -= 0.02
        @sprites["trainer_"].zoom_y -= 0.02
      end
      @sprites["trainer_"].opacity += 32
      self.update
      Graphics.update
    end
    @sprites["trainer_"].zoom_x = 1
    @sprites["trainer_"].zoom_y = 1
    # fades in trainer
    for i in 0...12
      @sprites["trainer_"].tone.all -= 16
      @sprites["background"].reduceAlpha(16)
      self.update
      Graphics.update
    end
    # wait
    maxf = [8, @frames*2].max
    for i in 0...maxf
      if @frames > 1 && @curFrame < @frames && i%2 == 0 && i >= (maxf - 1 - (@frames-1)*2)
        @sprites["trainer_"].src_rect.y += @sprites["trainer_"].src_rect.height
        @curFrame += 1
      end
      if i < 4
        @sprites["trainer_"].tone.all -= 16
        @sprites["background"].reduceAlpha(16)
      end
      self.update
      Graphics.update
    end
    # flashes trainer
    for i in 0...10
      @sprites["trainer_"].tone.all -= 51*(i < 5 ? -1 : 1)
      @sprites["background"].speed = 4 if i == 4
      self.update
      Graphics.update
    end
    # wraps glow around trainer
    16.times do
      @sprites["glow"].src_rect.height += @viewport.height/16
      @sprites["glow"].src_rect.y -= @viewport.height/16
      @sprites["glow"].y -= @viewport.height/16
      @sprites["glow2"].src_rect.height += @viewport.height/16
      self.update
      Graphics.update
    end
    # flashes viewport
    @viewport.color = Color.new(255,255,255,0)
    8.times do
      if @variant != "plasma"
        @sprites["glow"].tone.all += 32
        @sprites["glow2"].tone.all += 32
      end
      self.update
      Graphics.update
    end
    # party line up animation
    if @scene.battle.trainerBattle?
      @scene.pbShowPartyLineup(0)
      @scene.pbShowPartyLineup(1)
    end
    # loads additional background elements
    @sprites["background"].show
    @sprites["glow"].color = Color.white
    @sprites["glow2"].color = Color.white
    if @variant == "plasma"
      @sprites["glow"].color = Color.new(148,90,40)
      @sprites["glow2"].color = Color.new(148,90,40)
    end
    # flashes trainer
    for i in 0...4
      @viewport.color.alpha += 32
      @sprites["trainer_"].tone.all += 255.0/4
      self.update
      Graphics.update
    end
    4.times do
      @viewport.color.alpha += 32
      self.update
      Graphics.update
    end
    # returns everything to normal
    for i in 0...8
      @viewport.color.alpha -= 32
      @sprites["trainer_"].tone.all -= 255.0/8 if @sprites["trainer_"].tone.all > 0
      @sprites["shade"].opacity += 32
      @sprites["shade"].x -= 4
      self.update
      Graphics.update
    end
  end
  #-----------------------------------------------------------------------------
  # main update call
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    @sprites["background"].update
    @sprites["glow"].x = @sprites["trainer_"].x
    @sprites["glow2"].x = @sprites["trainer_"].x
  end
  #-----------------------------------------------------------------------------
  # called before Trainer sends out their Pokemon
  #-----------------------------------------------------------------------------
  def finish
    return if self.disposed?
    @scene.clearMessageWindow(true)
    # final transition
    viewport = @viewport
    zoom = 4.0
    obmp = pbBitmap("Graphics/EBDX/Transitions/Common/ballTransition")
    @sprites["background"].speed = 24
    # zooms in ball graphic overlay
    for i in 0..20
      @sprites["overlay"].bitmap.clear
      ox = (1 - zoom)*viewport.width*0.5
      oy = (1 - zoom)*viewport.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @sprites["overlay"].bitmap.fill_rect(0,0,width,viewport.height,Color.black)
      @sprites["overlay"].bitmap.fill_rect(viewport.width-width,0,width,viewport.height,Color.black)
      @sprites["overlay"].bitmap.fill_rect(0,0,viewport.width,height,Color.black)
      @sprites["overlay"].bitmap.fill_rect(0,viewport.height-height,viewport.width,height,Color.black)
      @sprites["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(obmp.width*zoom).ceil,(obmp.height*zoom).ceil),obmp,Rect.new(0,0,obmp.width,obmp.height))
      @sprites["overlay"].opacity += 64
      zoom -= 4.0/20
      self.update
      Graphics.update
    end
    # disposes of current sprites
    self.dispose
    # re-loads overlay
    @sprites["overlay"] = Sprite.new(@msgview)
    @sprites["overlay"].z = 9999999
    @sprites["overlay"].bitmap = Bitmap.new(@msgview.rect.width, @msgview.rect.height)
    @sprites["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width, @msgview.rect.height, Color.black)
    # show databox for follower
    if !EliteBattle.follower(@scene.battle).nil?
      @scene.sprites["dataBox_#{EliteBattle.follower(@scene.battle)}"].appear
    end
  end
  #-----------------------------------------------------------------------------
  # called during Trainer sendout
  #-----------------------------------------------------------------------------
  def sendout
    return if @sentout
    EliteBattle.set(:smAnim, false)
    # transitions from VS sequence to the battle scene
    zoom = 0
    # zooms out ball graphic overlay
    21.times do
      @sprites["overlay"].bitmap.clear
      ox = (1 - zoom)*@msgview.rect.width*0.5
      oy = (1 - zoom)*@msgview.rect.height*0.5
      width = (ox < 0 ? 0 : ox).ceil
      height = (oy < 0 ? 0 : oy).ceil
      @sprites["overlay"].bitmap.fill_rect(0,0,width,@msgview.rect.height,Color.black)
      @sprites["overlay"].bitmap.fill_rect(@msgview.rect.width-width,0,width,@msgview.rect.height,Color.black)
      @sprites["overlay"].bitmap.fill_rect(0,0,@msgview.rect.width,height,Color.black)
      @sprites["overlay"].bitmap.fill_rect(0,@msgview.rect.height-height,@msgview.rect.width,height,Color.black)
      @sprites["overlay"].bitmap.stretch_blt(Rect.new(ox,oy,(@obmp.width*zoom).ceil,(@obmp.height*zoom).ceil),@obmp,@obmp.rect)
      @sprites["overlay"].opacity -= 12.8
      zoom += 4.0/20
      @scene.wait(1,true)
    end
    # disposes of final graphic
    @sprites["overlay"].dispose
    @sentout = true
  end
  #-----------------------------------------------------------------------------
  # disposes all sprites
  #-----------------------------------------------------------------------------
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  # checks if disposed
  #-----------------------------------------------------------------------------
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  # compatibility for pbFadeOutAndHide
  #-----------------------------------------------------------------------------
  def color; end
  def color=(val); end
  def delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
  # fetches secondary parameters for the animations
  #-----------------------------------------------------------------------------
  def getParameters(trainer)
    # method used to check if battling against a registered evil team member
    @evilteam = EliteBattle.can_transition?("evilTeam", trainer.trainer_type, :Trainer, trainer.name, trainer.partyID)
    # methods used to determine special variants
    @variant = "trainer"
    for ext in EliteBattle.sun_moon_transitions
      @variant = ext if EliteBattle.can_transition?("#{ext}SM", trainer.trainer_type, :Trainer, trainer.name, trainer.partyID)
    end
    # sets up the rest of the variables
    @obmp = pbBitmap("Graphics/EBDX/Transitions/Common/ballTransition")
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Classic VS sequence for trainers
#===============================================================================
class ClassicVSSequence
  #-----------------------------------------------------------------------------
  #  construct the necessary elements
  #-----------------------------------------------------------------------------
  def initialize(viewport, trainer)
    @viewport = viewport
    @trainer = trainer
    @disposed = false
    @started = false
    @sprites = {}
    @trainertype = GameData::TrainerType.get(@trainer.trainer_type)
    # load trainer bitmap
    file = sprintf("Graphics/EBDX/Transitions/%s", @trainertype.id)
    file = sprintf("Graphics/EBDX/Transitions/classic%03d", @trainertype.id_number) if !pbResolveBitmap(file)
    bmp = pbBitmap(file)
    # set up backdrop
    @sprites["backdrop"] = Sprite.new(@viewport)
    @sprites["backdrop"].snap_screen
    @sprites["backdrop"].blur_sprite
    @sprites["backdrop"].center!(true)
    @sprites["backdrop"].color = Color.new(0, 0, 0, 64)
    @sprites["backdrop"].opacity = 0
    # set up overlay
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].full_rect(Color.black)
    @sprites["overlay"].bitmap.fill_rect(0, 92, @viewport.width, 128, Color.new(0, 0, 0, 0))
    @sprites["overlay"].z = 999
    @sprites["overlay"].visible = false
    # set up text overlay
    @sprites["txtol"] = Sprite.new(@viewport)
    @sprites["txtol"].blank_screen
    pbSetSystemFont(@sprites["txtol"].bitmap)
    t = [[@trainer.name, @viewport.width - 40 - (bmp.width/2), 236, 2, Color.white, Color.black]]
    pbDrawTextPositions(@sprites["txtol"].bitmap, t)
    @sprites["txtol"].z = 999
    @sprites["txtol"].visible = false
    # draws the VS text
    @sprites["vs"] = Sprite.new(@viewport)
    @sprites["vs"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/vs")
    @sprites["vs"].center!
    @sprites["vs"].x = 92
    @sprites["vs"].y = 156
    @sprites["vs"].zoom = 2
    @sprites["vs"].opacity = 0
    @sprites["vs"].z = 999
    @sprites["vs"].toggle = 1
    # draws the scrolling background
    @sprites["bg"] = ScrollingSprite.new(@viewport)
    str = sprintf("classicBar%s", @trainertype.id)
    str = sprintf("classicBar%03d", @trainertype.id_number) if !pbResolveBitmap("Graphics/EBDX/Transitions/Common/#{str}")
    str = "classicBar" if !pbResolveBitmap("Graphics/EBDX/Transitions/Common/#{str}")
    @sprites["bg"].setBitmap("Graphics/EBDX/Transitions/Common/#{str}")
    @sprites["bg"].y = 92
    @sprites["bg"].visible = false
    @sprites["bg"].z = 90
    # draws lightning
    @sprites["streak"] = ScrollingSprite.new(@viewport)
    @sprites["streak"].setBitmap("Graphics/EBDX/Transitions/Common/lightC")
    @sprites["streak"].direction = -1
    @sprites["streak"].speed = 24
    @sprites["streak"].y = 92
    @sprites["streak"].x = @viewport.width
    @sprites["streak"].z = 91
    # draws the animated shine ball
    @sprites["shine"] = Sprite.new(@viewport)
    @sprites["shine"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/shine")
    @sprites["shine"].center!
    @sprites["shine"].y = 156
    @sprites["shine"].x = 92
    @sprites["shine"].z = 90
    @sprites["shine"].opacity = 0
    @sprites["shine"].toggle = 1
    # draws trainer accent
    @sprites["trainer_a"] = Sprite.new(@viewport)
    @sprites["trainer_a"].bitmap = bmp
    @sprites["trainer_a"].color = Color.new(65,190,226,255*0.8)
    @sprites["trainer_a"].visible = false
    @sprites["trainer_a"].ox = @sprites["trainer_a"].width
    @sprites["trainer_a"].x = (@viewport.width - 18)
    @sprites["trainer_a"].y = 92
    @sprites["trainer_a"].z = 90
    # draws trainer sprite
    @sprites["trainer"] = Sprite.new(@viewport)
    @sprites["trainer"].bitmap = bmp
    @sprites["trainer"].ox = @sprites["trainer"].width
    @sprites["trainer"].color = Color.black
    @sprites["trainer"].x = (@viewport.width - 40) + @viewport.width + @viewport.width%16
    @sprites["trainer"].y = 92
    @sprites["trainer"].z = 95
  end
  #-----------------------------------------------------------------------------
  #  begin VS animation
  #-----------------------------------------------------------------------------
  def start
    return if self.disposed?
    for i in 0...16.delta_add
      @sprites["backdrop"].opacity += 32/self.delta if @sprites["backdrop"].opacity < 255
      @sprites["streak"].x -= (@viewport.width/8)/self.delta if @sprites["streak"].x > 0
      @sprites["streak"].x = 0 if @sprites["streak"].x < 0
      @sprites["trainer"].x -= (@viewport.width/16)/self.delta
      self.wait
    end
    @sprites["backdrop"].opacity = 255
    @sprites["trainer"].x = (@viewport.width - 40) + @viewport.width%16
    self.wait(4.delta_add)
    8.delta_add.times do
      @sprites["vs"].zoom -= (1.0/8)/self.delta
      @sprites["vs"].opacity += 32/self.delta
      self.wait
    end
    @sprites["vs"].zoom = 1
    @sprites["vs"].opacity = 255
    self.show
    self.wait((Graphics.frame_rate*2).round)
    self.finish
  end
  #-----------------------------------------------------------------------------
  #  main update for animation
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    @viewport.color.alpha -= 8 if @viewport.color.alpha > 0
    @sprites["bg"].update
    @sprites["streak"].update
    @sprites["shine"].opacity += 16/self.delta if @sprites["shine"].opacity < 255
    @sprites["shine"].angle += 8/self.delta if $PokemonSystem.screensize < 2
    @sprites["shine"].zoom_x -= 0.04*@sprites["shine"].toggle/self.delta
    @sprites["shine"].zoom_y -= 0.04*@sprites["shine"].toggle/self.delta
    @sprites["shine"].toggle *= -1 if @sprites["shine"].zoom_x <= 0.8 || @sprites["shine"].zoom_x >= 1.2
    return if !@started
    @sprites["vs"].x += @sprites["vs"].toggle
    @sprites["vs"].y += @sprites["vs"].toggle
    @sprites["vs"].toggle *= -1 if (@sprites["vs"].x - 92).abs >= 2*self.delta
  end
  #-----------------------------------------------------------------------------
  #  show all the required graphics
  #-----------------------------------------------------------------------------
  def show
    @started = true
    @viewport.color = Color.white
    @sprites["trainer"].color.alpha = 0
    for key in @sprites.keys
      @sprites[key].visible = true
    end
  end
  #-----------------------------------------------------------------------------
  #  finish up the animation and dispose of all elements
  #-----------------------------------------------------------------------------
  def finish
    return if self.disposed?
    @viewport.color = Color.new(0, 0, 0, 0)
    16.delta_add.times do
      @viewport.color.alpha += 32/self.delta
      self.wait
    end
    @viewport.color = Color.black
    self.dispose
  end
  #-----------------------------------------------------------------------------
  #  dispose all sprites
  #-----------------------------------------------------------------------------
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  #  checks if disposed
  #-----------------------------------------------------------------------------
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  #  compatibility for pbFadeOutAndHide
  #-----------------------------------------------------------------------------
  def color; end
  def color=(val); end
  def delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
  #  wait for frame skip
  #-----------------------------------------------------------------------------
  def wait(frames = 1)
    frames.times do
      self.update
      Graphics.update
    end
  end
  #-----------------------------------------------------------------------------
end
