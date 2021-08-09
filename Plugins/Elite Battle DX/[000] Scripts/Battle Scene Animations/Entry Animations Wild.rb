#===============================================================================
#  Class used to handle regular wild battle intro animations
#  Chooses a style depending on predefined parameters
#===============================================================================
class EliteBattle_BasicWildAnimations
  #-----------------------------------------------------------------------------
  #  constructor to play Wild entry animation
  #-----------------------------------------------------------------------------
  def initialize(viewport)
    @viewport = viewport
    @species = EliteBattle.get(:wildSpecies)
    @level = EliteBattle.get(:wildLevel)
    @form = EliteBattle.get(:wildForm) || 0
    # animation selection processing for any special transitions
    if !@species.nil?
      if self.isRegi?
        return self.animRegi
      else
        for trans in ["minorLegendary", "bwLegendary", "bwLegendary2"]
          return eval("self.#{trans}") if EliteBattle.can_transition?(trans, @species, :Species, @form)
        end
      end
    end
    # animation selection processing for regular battles
    if (!@level.nil? && @level > $Trainer.party[0].level)
      return self.overlevel
    elsif ($PokemonGlobal && ($PokemonGlobal.surfing || $PokemonGlobal.diving || $PokemonGlobal.fishing))
      return self.water
    elsif ($PokemonEncounters && $PokemonEncounters.has_cave_encounters?)
      return self.cave
    elsif (EliteBattle.outdoor_map?)
      return self.outdoor
    else
      return self.indoor
    end
    # returns false if no animation plays
    return false
  end
  #-----------------------------------------------------------------------------
  #  checks if queued Pokemon species is any of the Regis
  #-----------------------------------------------------------------------------
  def isRegi?
    for poke in [:REGIROCK, :REGISTEEL, :REGICE, :REGIGIGAS]
      return true if @species == poke
    end
    return false
  end
  #-----------------------------------------------------------------------------
  #  returns the internal index of Regis
  #-----------------------------------------------------------------------------
  def regiIndex?
    adj = []
    for poke in [:REGIROCK,:REGISTEEL,:REGICE,:REGIGIGAS]
      adj.push(poke)
    end
    return adj.index(@species)
  end
  #-----------------------------------------------------------------------------
  #  special animation for Regis
  #-----------------------------------------------------------------------------
  def animRegi
    fp = {}
    # gets main index
    index = self.regiIndex?
    # gets viewport size
    width = @viewport.width
    height = @viewport.height
    # sets viewport to black, transparent
    @viewport.color = Color.new(0,0,0,0)
    # defines necessary sprites
    fp["back"] = Sprite.new(@viewport)
    fp["back"].snap_screen
    fp["back"].blur_sprite
    c = index < 3 ? 0 : 255
    fp["back"].color = Color.new(c,c,c,128*(index < 3 ? 1 : 2))
    fp["back"].z = 99999
    fp["back"].opacity = 0
    # positioning matrix for all the Regi dots
    x = [
      [width*0.5,width*0.25,width*0.75,width*0.25,width*0.75,width*0.25,width*0.75],
      [width*0.5,width*0.3,width*0.7,width*0.15,width*0.85,width*0.3,width*0.7],
      [width*0.5,width*0.325,width*0.675,width*0.5,width*0.5,width*0.15,width*0.85],
      [width*0.5,width*0.5,width*0.5,width*0.5,width*0.35,width*0.65,width*0.5]
    ]
    y = [
      [height*0.5,height*0.5,height*0.5,height*0.25,height*0.75,height*0.75,height*0.25],
      [height*0.5,height*0.25,height*0.75,height*0.5,height*0.5,height*0.75,height*0.25],
      [height*0.5,height*0.5,height*0.5,height*0.25,height*0.75,height*0.5,height*0.5],
      [height*0.9,height*0.74,height*0.58,height*0.4,height*0.25,height*0.25,height*0.1]
    ]
    # draws necessary dots
    for j in 0...14
      fp[j] = Sprite.new(@viewport)
      fp[j].bitmap = pbBitmap("Graphics/EBDX/Transitions/Species/regi")
      fp[j].src_rect.set(96*(j/7),100*index,96,100)
      fp[j].ox = fp[j].src_rect.width/2
      fp[j].oy = fp[j].src_rect.height/2
      fp[j].x = x[index][j%7]
      fp[j].y = y[index][j%7]
      fp[j].opacity = 0
      fp[j].z = 99999
    end
    # fades to black
    8.delta_add.times do
      fp["back"].opacity += 32/self.delta
      pbWait(1)
    end
    fp["back"].opacity = 255
    k = -2
    # fades in regi dots
    for i in 0...72.delta_add
      if index < 3
        k += 2 if i.delta_add%8 == 0
      else
        k += (k==3 ? 2 : 1) if i.delta_add%4 == 0
      end
      k = 6 if k > 6
      for j in 0..k
        fp[j].opacity += 32/self.delta
        fp[j+7].opacity += 26/self.delta if fp[j].opacity >= 255
        fp[j].visible = fp[j+7].opacity < 255
      end
      fp["back"].color.alpha += [1, 2/self.delta].max if fp["back"].color.alpha < 255
      pbWait(1)
    end
    # fades viewport to black
    8.delta_add.times do
      @viewport.color.alpha += 32/self.delta
      pbWait(1)
    end
    @viewport.color.alpha = 255
    # disposes unused sprites
    pbDisposeSpriteHash(fp)
    return true
  end
  #-----------------------------------------------------------------------------
  #  wild animation for outdoor battles
  #-----------------------------------------------------------------------------
  def outdoor(variant = false)
    # gets screen size
    hz = 8
    vz = 6
    width = @viewport.width/hz
    height = @viewport.height/vz
    bmp = Graphics.snap_to_bitmap
    # generates all sprite particles
    sps = {}
    if variant
      sps["black"] = Sprite.new(@viewport)
      sps["black"].create_rect(@viewport.width,@viewport.height,Color.black)
    end
    for j in 0...(hz*vz)
      # renders rectangle
      sps[j] = Sprite.new(@viewport)
      sps[j].ox = width/2
      # decides which snaking pattern to take
      pat = j < (hz*vz)/2 ? (j/hz)%2 == 0 : (j/hz)%2 == 1
      # determines positioning
      x = pat ? (width/2 + width*(j%hz)) : (@viewport.width - width/2 - width*(j%hz))
      y = height * (j/hz)
      sps[j].x = x
      sps[j].y = y
      if variant
        sps[j].bitmap = Bitmap.new(width,height)
        sps[j].bitmap.blt(0,0,bmp,Rect.new(x-width/2,y,width,height))
      else
        sps[j].create_rect(width,height,Color.black)
      end
      sps[j].zoom_x = variant ? 1 : 0
    end
    # animates pattern
    for i in 0...40.delta_add
      for j in 0...(hz*vz)
        k = j < (hz*vz)/2 ? j : (hz*vz) - j
        next if k > i*0.75
        if variant
          sps[j].zoom_x -= 0.15/self.delta if sps[j].zoom_x > 0
        else
          sps[j].zoom_x += 0.15/self.delta if sps[j].zoom_x < 1
        end
      end
      pbWait(1)
    end
    # ensures viewport is set to black
    @viewport.color = Color.new(0, 0, 0, 255)
    # disposes unused sprites
    pbDisposeSpriteHash(sps)
    return true
  end
  #-----------------------------------------------------------------------------
  #  wild animation for indoor battles
  #-----------------------------------------------------------------------------
  def indoor
    # draws blank bitmap upon which to draw snaking pattern
    screen = Sprite.new(@viewport)
    screen.bitmap = Bitmap.new(@viewport.width,@viewport.height)
    black = Color.black
    # gets screen size
    width = @viewport.width
    height = @viewport.height/16
    # animates pattern draw
    for i in 1..16.delta_add
      for j in 0...16
        x = (j%2 == 0) ? 0 : @viewport.width - i*(width/16).delta_sub
        screen.bitmap.fill_rect(x,j*height,i*(width/16),height,black)
      end
      pbWait(1)
    end
    # ensures viewport is black
    @viewport.color = Color.new(0, 0, 0, 255)
    pbWait(10)
    # disposes unused sprite
    screen.dispose
    return true
  end
  #-----------------------------------------------------------------------------
  #  wild animation for cave battles
  #-----------------------------------------------------------------------------
  def cave
    # draws blank bitmap upon which to draw snaking pattern
    screen = Sprite.new(@viewport)
    screen.bitmap = Bitmap.new(@viewport.width,@viewport.height)
    black = Color.black
    # gets screen size
    width = @viewport.width/4
    height = @viewport.height/4
    # draws all sprite elements
    sprites = {}
    for i in 0...16
      sprites[i] = Sprite.new(@viewport)
      sprites[i].bitmap = Bitmap.new(width,height)
      sprites[i].bitmap.fill_rect(0,0,width,height,black)
      sprites[i].ox = width/2
      sprites[i].oy = height/2
      sprites[i].x = width/2 + width*(i%4)
      sprites[i].y = @viewport.height - height/2 - height*(i/4)
      sprites[i].zoom_x = 0
      sprites[i].zoom_y = 0
    end
    # pattern sequence definition
    seq = [[0],[4,1],[8,5,2],[12,9,6,3],[13,10,7],[14,11],[15]]
    # animate sequence
    for i in 0...seq.length
      5.delta_add.times do
        for j in 0...seq[i].length
          n = seq[i][j]
          sprites[n].zoom_x += 0.2/self.delta
          sprites[n].zoom_y += 0.2/self.delta
        end
        pbWait(1)
      end
      for j in 0...seq[i].length
        n = seq[i][j]
        sprites[n].zoom = 1
      end
    end
    # ensures viewport is black
    @viewport.color = Color.new(0, 0, 0, 255)
    pbWait(1)
    # disposes unused sprites
    pbDisposeSpriteHash(sprites)
    screen.dispose
    return true
  end
  #-----------------------------------------------------------------------------
  #  wild animation for water encounters
  #-----------------------------------------------------------------------------
  def water
    # gets snapshot of screen
    bmp = Graphics.snap_to_bitmap
    split = 12
    n = @viewport.height/split
    sprites = {}
    # creates black bg
    black = Sprite.new(@viewport)
    black.bitmap = Bitmap.new(@viewport.width,@viewport.height)
    black.bitmap.fill_rect(0,0,black.bitmap.width,black.bitmap.height,Color.black)
    # splits the screen into proper segments
    for i in 0...n
      sprites[i] = Sprite.new(@viewport)
      sprites[i].bitmap = Bitmap.new(@viewport.width, @viewport.height)
      sprites[i].bitmap.blt(0, 0, bmp, @viewport.rect)
      sprites[i].ox = sprites[i].bitmap.width/2
      sprites[i].x = @viewport.width/2
      sprites[i].y = i*split
      sprites[i].src_rect.set(0, i*split, sprites[i].bitmap.width, split)
      sprites[i].color = Color.new(0, 0, 0, 0)
    end
    # animates wave motion
    for f in 0...64.delta_add
      for i in 0...n
        o = Math.sin(f - i*0.5)/self.delta
        sprites[i].x = @viewport.width/2 + 16*o if f >= i*self.delta
        sprites[i].color.alpha += 25.5/self.delta if sprites[i].color.alpha < 255 && f >= (64 - (48-i))
      end
      pbWait(1)
    end
    # ensures viewport is black
    @viewport.color = Color.new(0, 0, 0, 255)
    # disposes unused sprites
    pbDisposeSpriteHash(sprites)
    return true
  end
  #-----------------------------------------------------------------------------
  #  wild animation for minor legendaries
  #-----------------------------------------------------------------------------
  def minorLegendary(special = false)
    # initial metrics
    bmp = Graphics.snap_to_bitmap
    max = 50
    amax = 4
    frames = {}
    zoom = 1
    # sets viewport color
    @viewport.color = special ? Color.new(64, 64, 64, 0) : Color.new(255, 255, 155, 0)
    # animates initial viewport color
    20.delta_add.times do
      @viewport.color.alpha += [1, 2/self.delta].max
      pbWait(1)
    end
    @viewport.color.alpha = 40
    # animates screen blur pattern
    for i in 0...(max + 20).delta_add
      if !(i%2 == 0)
        zoom += ((i > max*0.75*self.delta) ? 0.3 : -0.01)/self.delta
        angle = 0 if angle.nil?
        angle = (i%3 == 0) ? rand(amax*2) - amax : angle
        # creates necessary sprites
        frames[i] = Sprite.new(@viewport)
        frames[i].bitmap = Bitmap.new(@viewport.width, @viewport.height)
        frames[i].bitmap.blt(0, 0, bmp, @viewport.rect)
        frames[i].center!(true)
        frames[i].angle = angle
        frames[i].zoom = zoom
        frames[i].tone = Tone.new(i/4,i/4,i/4)
        frames[i].opacity = 30
      end
      # colors viewport
      if i >= max
        @viewport.color.alpha += 12/self.delta
        if special
          @viewport.color.red -= (64/20.0)/self.delta
          @viewport.color.green -= (64/20.0)/self.delta
          @viewport.color.blue -= (64/20.0)/self.delta
        else
          @viewport.color.blue += 5/self.delta if @viewport.color.blue < 255
        end
      end
      pbWait(1)
    end
    # ensures viewport goes to black
    frames[(max+19).delta_add].tone = Tone.new(255, 255, 255)
    pbWait(10.delta_add)
    10.delta_add.times do
      next if special
      @viewport.color.red -= 25.5/self.delta
      @viewport.color.green -= 25.5/self.delta
      @viewport.color.blue -= 25.5/self.delta
      pbWait(1)
    end
    @viewport.color = Color.new(0, 0, 0)
    # disposes unused sprites
    pbDisposeSpriteHash(frames)
    return true
  end
  #-----------------------------------------------------------------------------
  #  animation for B/W legendaries
  #-----------------------------------------------------------------------------
  def bwLegendary(special = false)
    bmp = pbBitmap("Graphics/EBDX/Transitions/Common/zoomStreak")
    n = 10
    sprites = {}
    # generate black backdrop
    sprites["bg"] = Sprite.new(@viewport)
    sprites["bg"].full_rect(Color.new(0, 0, 0, 128))
    sprites["bg"].opacity = 0
    # generate zoom sphere
    sprites["sp"] = Sprite.new(@viewport)
    sprites["sp"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/zoomSphere")
    sprites["sp"].center!(true)
    sprites["sp"].zoom_x = 0
    sprites["sp"].zoom_y = 0
    sprites["sp"].opacity = 0
    # generate all the sprites
    for i in 0...n
      sprites["s#{i}"] = Sprite.new(@viewport)
      sprites["s#{i}"].bitmap = bmp
      sprites["s#{i}"].oy = 48
      sprites["s#{i}"].ox = sprites["s#{i}"].bitmap.width + @viewport.width/2
      sprites["s#{i}"].x = @viewport.width/2
      sprites["s#{i}"].y = @viewport.height/2
      sprites["s#{i}"].angle = i * (360/n)
    end
    # animate in
    for j in 0...48.delta_add
      for i in 0...n
        if j < 8.delta_add
          sprites["s#{i}"].ox -= (@viewport.width/16)/self.delta
        elsif j < 16.delta_add
          sprites["s#{i}"].src_rect.width -= (sprites["s#{i}"].bitmap.width/8)/self.delta
          sprites["s#{i}"].src_rect.x += (sprites["s#{i}"].bitmap.width/8)/self.delta
          sprites["s#{i}"].ox -= (sprites["s#{i}"].bitmap.width/8)/self.delta
          sprites["s#{i}"].zoom_y -= 0.125/self.delta
          sprites["s#{i}"].tone.all += 32/self.delta
        end
        sprites["s#{i}"].angle -= 4/self.delta if j < 16.delta_add
      end
      # animate @viewport tone
      if j >= 8.delta_add
        @viewport.tone.all += ((j < 32) ? 4 : -32)/self.delta
      end
      # animate sphere
      if j >= 16.delta_add && j < 32.delta_add
        sprites["sp"].zoom_x += 0.2/self.delta
        sprites["sp"].zoom_y += 0.2/self.delta
        sprites["sp"].opacity += 32/self.delta
      end
      sprites["bg"].opacity += 16/self.delta
      pbWait(1)
    end
    # dispose
    pbDisposeSpriteHash(sprites)
    return true
  end
  #-----------------------------------------------------------------------------
  #  animation for B/W legendaries
  #-----------------------------------------------------------------------------
  def bwLegendary2
    sprites = {}
    # generate black backdrop
    sprites["bg"] = Sprite.new(@viewport)
    sprites["bg"].full_rect(Color.new(0, 0, 0, 128))
    sprites["bg"].opacity = 0
    # generate bar sprite
    sprites["bar"] = Sprite.new(@viewport)
    sprites["bar"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/hStreak")
    sprites["bar"].oy = sprites["bar"].bitmap.height/2
    sprites["bar"].y = @viewport.height/2
    sprites["bar"].x = -@viewport.width
    # generate shine sprite
    sprites["s1"] = Sprite.new(@viewport)
    sprites["s1"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/shine2")
    sprites["s1"].center!(true)
    sprites["s1"].zoom = 0
    # generate shine fill sprite
    sprites["s2"] = Sprite.new(@viewport)
    sprites["s2"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/shine")
    sprites["s2"].center!(true)
    sprites["s2"].zoom = 0
    sprites["s2"].opacity = 0
    # begin animation part 1
    4.delta_add.times do
      sprites["bg"].opacity += 64/self.delta
      sprites["bar"].x += (@viewport.width/4)/self.delta
      pbWait(1)
    end
    sprites["bar"].x = 0
    # animate bar out
    8.delta_add.times do
      sprites["bar"].zoom_y -= 0.125/self.delta
      sprites["bar"].opacity -= 8/self.delta
      pbWait(1)
    end
    sprites["bar"].zoom_y = 0
    # animate spark
    for i in 0...8.delta_add
      sprites["s1"].zoom += (i < 4.delta_add ? 0.25 : -0.25)/self.delta
      sprites["s1"].angle += 8/self.delta
      pbWait(1)
    end
    sprites["s1"].zoom = 0
    # animate full shine
    @viewport.color = Color.new(255, 255, 255, 0)
    for i in 0...16.delta_add
      sprites["s2"].zoom += 0.25/self.delta
      sprites["s2"].opacity += 32/self.delta
      @viewport.color.alpha += 32/self.delta if i >= 8.delta_add
      Graphics.update
    end
    @viewport.color = Color.white
    16.delta_add.times { Graphics.update }
    # dispose
    pbDisposeSpriteHash(sprites)
    # fade to black
    16.delta_add.times do
      @viewport.color.red -= 8/self.delta
      @viewport.color.green -= 8/self.delta
      @viewport.color.blue -= 8/self.delta
      Graphics.update
    end
    @viewport.color = Color.black
    2.delta_add.times { Graphics.update }
    return true
  end
  #-----------------------------------------------------------------------------
  #  wild animation for Pokemon that are higher level than your party leader
  #-----------------------------------------------------------------------------
  def overlevel
    # gets screen size
    height = @viewport.height/4
    width = @viewport.width/10
    # creates a sprite of screen
    backdrop = Sprite.new(@viewport)
    backdrop.snap_screen
    # creates blank sprite
    sprite = Sprite.new(@viewport)
    sprite.bitmap = Bitmap.new(@viewport.width, @viewport.height)
    # animates gradient pattern
    for j in 0...4
      y = [0,2,1,3]
      for i in 1..10.delta_add
        sprite.bitmap.fill_rect(0, height*y[j], width*i/self.delta, height, Color.white)
        backdrop.tone.all += 3/self.delta
        pbWait(1)
      end
    end
    # ensures viewport is black
    @viewport.color = Color.new(0, 0, 0, 0)
    10.delta_add.times do
      @viewport.color.alpha += 25.5/self.delta
      pbWait(1)
    end
    @viewport.color.alpha = 255
    # disposes unused sprites
    backdrop.dispose
    sprite.dispose
    return true
  end
  #-----------------------------------------------------------------------------
  def delta; return Graphics.frame_rate/40.0; end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  The main class responsible for loading up the S/M styled Pokemon transitions
#  Only for single Pokemon battles
#===============================================================================
class SunMoonSpeciesTransitions
  attr_accessor :speed
  attr_reader :started
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' pokemon: %s>', @poke.inspect)
    return str
  end
  #-----------------------------------------------------------------------------
  #  creates the transition handler
  #-----------------------------------------------------------------------------
  def initialize(*args)
    return if args.length < 4
    @started = false
    # sets up main viewports
    @viewport = args[0]
    @viewport.color = Color.new(255, 255, 255, EliteBattle.get(:colorAlpha))
    EliteBattle.set(:colorAlpha, 0)
    @msgview = args[1]
    # sets up variables
    @disposed = false
    @sentout = false
    @scene = args[2]
    # sets up Pokemon parameters
    @poke = args[3]
    @form = @poke.form
    @speed = 1
    @sprites = {}
    # retreives additional parameters
    self.getParameters(@poke.species)
    @species = GameData::Species.get(@poke.species)
    # initializes the backdrop
    args = "@viewport,@species"
    var = @variant == "trainer" ? "default" : @variant
    # check if can continue
    unless var.is_a?(String) && !var.empty?
      EliteBattle.log.error("Cannot get VS sequence variant for Sun/Moon battle transition for species: #{@species.id}!")
      var = "default"
    end
    # loag background effect
    @sprites["background"] = eval("SunMoon#{var.capitalize}Background.new(#{args})")
    @sprites["background"].speed = 24
    # graphics for bars covering the viewport
    @sprites["bar1"] = Sprite.new(@viewport)
    @sprites["bar1"].create_rect(@viewport.width,@viewport.height/2,Color.black)
    @sprites["bar1"].z = 999
    @sprites["bar2"] = Sprite.new(@viewport)
    @sprites["bar2"].create_rect(@viewport.width,@viewport.height/2 + 2,Color.black)
    @sprites["bar2"].oy = @sprites["bar2"].bitmap.height
    @sprites["bar2"].y = @viewport.height + 2
    @sprites["bar2"].z = 999
    # "electricity" effect that scrolls horizontally behind the Pokemon
    @sprites["streak"] = ScrollingSprite.new(@viewport)
    @sprites["streak"].setBitmap("Graphics/EBDX/Transitions/Species/light")
    @sprites["streak"].x = @viewport.width
    @sprites["streak"].y = @viewport.height/2
    @sprites["streak"].z = 400
    @sprites["streak"].speed = 64
    @sprites["streak"].oy = @sprites["streak"].bitmap.height/2
    # initializes particles
    for j in 0...24
      n = ["A", "B"][rand(2)]
      @sprites["p#{j}"] = Sprite.new(@viewport)
      str = "Graphics/EBDX/Transitions/Species/particle#{n}#{@species.id}"
      str = "Graphics/EBDX/Transitions/Species/particle#{n}#{@species.id_number}" if !pbResolveBitmap(str)
      str = "Graphics/EBDX/Transitions/Species/particle#{n}" if !pbResolveBitmap(str)
      @sprites["p#{j}"].bitmap = pbBitmap(str)
      @sprites["p#{j}"].ox = @sprites["p#{j}"].bitmap.width/2
      @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height/2
      @sprites["p#{j}"].x = @viewport.width + 48
      y = @viewport.height*0.5*0.72 + rand(0.28*@viewport.height)
      @sprites["p#{j}"].y = y
      @sprites["p#{j}"].speed = rand(4) + 1
      @sprites["p#{j}"].z = 450
      @sprites["p#{j}"].z += 1 if rand(2) == 0
    end
    # determines the extension for the Pokemon bitmap
    str = sprintf("%s_%d", @species.id, @form)
    str = sprintf("%s", @species.id) if !pbResolveBitmap("Graphics/EBDX/Transitions/#{str}")
    str = sprintf("species%03d_%d", @species.id_number, @form) if !pbResolveBitmap("Graphics/EBDX/Transitions/#{str}")
    str = sprintf("species%03d", @species.id_number) if !pbResolveBitmap("Graphics/EBDX/Transitions/#{str}")
    # initializes the necessary Pokemon graphic
    @sprites["poke1"] = Sprite.new(@viewport)
    @sprites["poke1"].bitmap = pbBitmap("Graphics/EBDX/Transitions/#{str}")
    @sprites["poke1"].ox = @sprites["poke1"].bitmap.width/2
    @sprites["poke1"].oy = @sprites["poke1"].bitmap.height*0.35
    @sprites["poke1"].x = @viewport.width/2
    @sprites["poke1"].y = @viewport.height/2
    @sprites["poke1"].glow(Color.new(101,136,194),35,false)
    @sprites["poke1"].src_rect.height = 0
    @sprites["poke1"].toggle = -1
    @sprites["poke1"].z = 350
    @sprites["poke1"].visible = false
    @sprites["poke2"] = Sprite.new(@viewport)
    @sprites["poke2"].bitmap = pbBitmap("Graphics/EBDX/Transitions/#{str}")
    @sprites["poke2"].ox = @sprites["poke2"].bitmap.width/2
    @sprites["poke2"].oy = @sprites["poke2"].bitmap.height*0.35
    @sprites["poke2"].x = @viewport.width
    @sprites["poke2"].y = @viewport.height/2
    @sprites["poke2"].opacity = 0
    @sprites["poke2"].z = 350
  end
  #-----------------------------------------------------------------------------
  #  starts the animation
  #-----------------------------------------------------------------------------
  def start
    @started = true
    return if self.disposed?
    for i in 0...64
      @sprites["background"].reduceAlpha(16) if i < 16
      @sprites["streak"].x -= 64 if @sprites["streak"].x > 0
      @sprites["streak"].update if @sprites["streak"].x <= 0
      @sprites["streak"].opacity -= 16 if i >= 48
      @sprites["bar1"].zoom_y -= 0.02 if @sprites["bar1"].zoom_y > 0.72
      @sprites["bar2"].zoom_y -= 0.02 if @sprites["bar2"].zoom_y > 0.72
      @sprites["poke2"].opacity += 16
      @sprites["poke2"].x -= (@sprites["poke2"].x - @viewport.width/2)*0.1
      for j in 0...24
        next if j > i/2
        @sprites["p#{j}"].x -= 32*@sprites["p#{j}"].speed
      end
      @sprites["background"].update
      Graphics.update
    end
    @sprites["background"].speed = 4
    # changes focus to Pokemon graphic
    for i in 0...8
      @sprites["bar1"].zoom_y -= 0.72/8
      @sprites["bar2"].zoom_y -= 0.72/8
      @sprites["poke1"].y -= 4
      @sprites["poke2"].y -= 4
      if i >= 4
        @viewport.color.alpha += 64
      end
      self.update
      Graphics.update
    end
    # flash and impact of screen
    @sprites["poke1"].oy = @sprites["poke1"].bitmap.height/2
    @sprites["poke1"].y = @viewport.height/2
    @sprites["poke1"].visible = true
    @sprites["poke2"].oy = @sprites["poke2"].bitmap.height/2
    @sprites["poke2"].y = @viewport.height/2
    @sprites["impact"] = Sprite.new(@viewport)
    @sprites["impact"].bitmap = pbBitmap("Graphics/EBDX/Pictures/impact")
    @sprites["impact"].ox = @sprites["impact"].bitmap.width/2
    @sprites["impact"].oy = @sprites["impact"].bitmap.height/2
    @sprites["impact"].x = @viewport.width/2
    @sprites["impact"].y = @viewport.height/2
    @sprites["impact"].z = 999
    @sprites["impact"].opacity = 0
    pbSEPlay(GameData::Species.cry_filename(@species.id, @form))
    @scene.pbShowPartyLineup(0) if EliteBattle::SHOW_LINEUP_WILD
    @sprites["background"].show
    k = -1
    # fades flash
    for i in 0...32
      @viewport.color.alpha -= 16 if @viewport.color.alpha > 0
      @sprites["poke2"].y += k*6 if i < 16
      k *= -1 if i%2 == 0
      @sprites["impact"].opacity += (i < 24) ? 64 : -32
      @sprites["impact"].angle += 180 if i%4 == 0
      @sprites["impact"].mirror = !@sprites["impact"].mirror if i%4 == 2
      self.update
      Graphics.update
    end
  end
  #-----------------------------------------------------------------------------
  #  main update call
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    @sprites["poke1"].src_rect.height += 40 if @sprites["poke1"].src_rect.height < 640
    @sprites["poke1"].opacity -= 2*@sprites["poke1"].toggle
    @sprites["poke1"].toggle *= -1 if @sprites["poke1"].opacity <= 0 || @sprites["poke1"].opacity >= 255
    @sprites["background"].update
  end
  #-----------------------------------------------------------------------------
  #  called before Trainer sends out their Pokemon
  #-----------------------------------------------------------------------------
  def finish
    return if self.disposed?
    @scene.clearMessageWindow(true)
    @sprites["ov1"] = Sprite.new(@viewport)
    @sprites["ov1"].snap_screen
    @sprites["ov1"].center!(true)
    @sprites["ov1"].z = 99999
    @sprites["ov2"] = Sprite.new(@viewport)
    @sprites["ov2"].bitmap = @sprites["ov1"].bitmap.clone
    @sprites["ov2"].blur_sprite(3)
    @sprites["ov2"].center!(true)
    @sprites["ov2"].z = 99999
    @sprites["ov2"].opacity = 0
    # final zooming transition
    for i in 0...32
      @sprites["ov1"].zoom_x += 0.02
      @sprites["ov1"].zoom_y += 0.02
      @sprites["ov2"].zoom_x += 0.02
      @sprites["ov2"].zoom_y += 0.02
      @sprites["ov2"].opacity += 12
      if i >= 16
        @sprites["ov2"].tone.all += 16
      end
      Graphics.update
    end
    @viewport.color = Color.white
    self.dispose
    8.times { Graphics.update }
    EliteBattle.set(:smAnim, false)
    # fades out viewport and shows battlebox
    @scene.sprites["dataBox_1"].appear
    @scene.sprites["dataBox_1"].position
    # apply for Player follower
    if !EliteBattle.follower(@scene.battle).nil?
      @scene.sprites["dataBox_#{EliteBattle.follower(@scene.battle)}"].appear
      @scene.sprites["dataBox_#{EliteBattle.follower(@scene.battle)}"].position
    end
    for i in 0...16
      @viewport.color.alpha -= 16
      @scene.wait
    end
  end
  #-----------------------------------------------------------------------------
  #  disposes all sprites
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
  #  fetches secondary parameters for the animations
  #-----------------------------------------------------------------------------
  def getParameters(species)
    # methods used to determine special variants
    @variant = "trainer"
    for ext in EliteBattle.sun_moon_transitions
      @variant = ext if EliteBattle.can_transition?("#{ext}SM", species, :Species, @form)
    end
  end
  #-----------------------------------------------------------------------------
end
