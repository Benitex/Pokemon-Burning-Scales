#===============================================================================
#  Pokemon data battle boxes (Next Generation)
#  UI overhaul
#===============================================================================
class DataBoxEBDX  <  SpriteWrapper
  attr_reader :battler, :animatingHP, :animatingEXP, :expBarWidth, :hpBarWidth
  attr_accessor :selected, :appearing, :inposition
  #-----------------------------------------------------------------------------
  #  constructor
  #-----------------------------------------------------------------------------
  def initialize(battler, viewport = nil, player = nil, scene = nil)
    @viewport = viewport
    @scene = scene
    @battle = scene.battle
    @player = player
    @battler = battler
    @pokemon = @battler.displayPokemon
    @trainer = @battle.opponent ? @battle.opponent[0] : nil
    @doublebattle = @battle.doublebattle?
    @playerpoke = (@battler.index%2) == 0
    @sprites = {}
    @path = "Graphics/EBDX/Pictures/UI/"
    @showexp = @playerpoke && !@doublebattle
    @explevel = 0
    @selected = false
    @appearing = false
    @animatingHP = false
    @starthp = 0.0
    @currenthp = 0.0
    @endhp = 0.0
    @frame = 0
    @loaded = false
    @showing = false
    @hidden = false
    @inposition = false
    @temphide = false
  end
  #-----------------------------------------------------------------------------
  #  PBS metadata
  #-----------------------------------------------------------------------------
  def applyMetrics
    # default variable states
    @showhp = @playerpoke && !@doublebattle
    @expBarWidth = 100
    @hpBarWidth = 168
    @baseBitmap = "dataBox"
    @colors = "barColors"
    @containerBmp = "containers"
    @expandDouble = false
    @hpBarX = 4
    @hpBarY = 2
    @expBarX = 4
    @expBarY = 16
    # calc width in advance
    tbmp = pbBitmap(@path + @baseBitmap)
    # set XY positions
    @defX = @playerpoke ? @viewport.width - tbmp.width : 0
    @defY = @playerpoke ? @viewport.height - 130 : 52
    tbmp.dispose
    # compiles default positioning data for databox
    @data = {
      "status" => {:x => @playerpoke ? -26 : 202, :y => 16, :z => 1},
      "mega" => {:x => @playerpoke ? -10 : 206, :y => -18, :z => 1},
      "container" => {:x => @playerpoke ? 20 : 24, :y => 6, :z => 1},
      "name" => {:x => @playerpoke ? 22 : 26, :y => -24, :z => 9},
      "hp" => {:x => @playerpoke ? 22 : 20, :y => 9, :z => 9}
    }
    # determines which constant to search for
    const = @playerpoke ? :PLAYERDATABOX : :ENEMYDATABOX
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d2 = d1[const] if !d1.nil? && d1.has_key?(const)
    d3 = d1[:ALLDATABOX] if !d1.nil? && d1.has_key?(:ALLDATABOX)
    # looks up globally defined settings
    d4 = EliteBattle.get_data(const, :Metrics, :METRICS)
    d7 = EliteBattle.get_map_data(:DATABOX_METRICS)
    # look up trainer specific metrics
    d6 = @battle.opponent ? EliteBattle.get_trainer_data(@trainer.trainer_type, :DATABOX_METRICS, @trainer) : nil
    # looks up species specific metrics
    d5 = EliteBattle.get_data(@battler.species, :Species, :DATABOX_METRICS, (@battler.form rescue 0))
    # proceeds with parameter definition if available
    for data in [d4, d2, d3, d7, d6, d5, d1]
      if !data.nil?
        # applies a set of predefined keys
        @defX = data[:X] if data.has_key?(:X) && data[:X].is_a?(Numeric)
        @defY = data[:Y] if data.has_key?(:Y) && data[:Y].is_a?(Numeric)
        @showhp = data[:SHOWHP] if (!@doublebattle || (@doublebattle && !@playerpoke && @battle.pbParty(1).length < 2)) && data.has_key?(:SHOWHP)
        @expBarWidth = data[:EXPBARWIDTH] if data.has_key?(:EXPBARWIDTH) && data[:EXPBARWIDTH].is_a?(Numeric)
        @expBarX = data[:EXPBARX] if data.has_key?(:EXPBARX) && data[:EXPBARX].is_a?(Numeric)
        @expBarY = data[:EXPBARY] if data.has_key?(:EXPBARY) && data[:EXPBARY].is_a?(Numeric)
        @hpBarWidth = data[:HPBARWIDTH] if data.has_key?(:HPBARWIDTH) && data[:HPBARWIDTH].is_a?(Numeric)
        @hpBarX = data[:HPBARX] if data.has_key?(:HPBARX) && data[:HPBARX].is_a?(Numeric)
        @hpBarY = data[:HPBARY] if data.has_key?(:HPBARY) && data[:HPBARY].is_a?(Numeric)
        @baseBitmap = data[:BITMAP] if data.has_key?(:BITMAP) && data[:BITMAP].is_a?(String)
        @colors = data[:HPCOLORS] if data.has_key?(:HPCOLORS) && data[:HPCOLORS].is_a?(String)
        @containerBmp = data[:CONTAINER] if data.has_key?(:CONTAINER) && data[:CONTAINER].is_a?(String)
        # expand databox even in doubles
        @expandDouble = data[:EXPANDINDOUBLES] == true ? true : false if data.has_key?(:EXPANDINDOUBLES)
        @showexp = true if @expandDouble && @playerpoke && @battler.pbOwnedByPlayer?
        @showhp = true if @expandDouble && @playerpoke
        # applies a set of possible modifier keys
        for key in data.keys
          next if !key.is_a?(String) || !@data.has_key?(key) || !data[key].is_a?(Hash)
          for m in data[key].keys
            next if !@data[key].has_key?(m)
            @data[key][m] = data[key][m]
          end
        end
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  get specific metric
  #-----------------------------------------------------------------------------
  def getMetric(key,value)
    return (@data.has_key?(key) && @data[key].has_key?(value)) ? @data[key][value] : 0
  end
  #-----------------------------------------------------------------------------
  #  check if databox is disposed
  #-----------------------------------------------------------------------------
  def disposed?
    return @sprites["base"].disposed? if @sprites["base"]
    return true
  end
  #-----------------------------------------------------------------------------
  #  dispose databox
  #-----------------------------------------------------------------------------
  def dispose
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  #  refresh EXP amount
  #-----------------------------------------------------------------------------
  def refreshExpLevel
    if !@battler.pokemon
      @explevel = 0
    else
      growthrate = @battler.pokemon.growth_rate
      startexp = GameData::GrowthRate.get(growthrate).minimum_exp_for_level(@battler.pokemon.level)
      endexp = GameData::GrowthRate.get(growthrate).minimum_exp_for_level(@battler.pokemon.level + 1)
      if startexp == endexp
        @explevel = 0
      else
        @explevel = (@battler.pokemon.exp-startexp)*@expBarWidth/(endexp-startexp)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  get current EXP
  #-----------------------------------------------------------------------------
  def exp
    return @animatingEXP ? @currentexp : @explevel
  end
  #-----------------------------------------------------------------------------
  #  get current HP
  #-----------------------------------------------------------------------------
  def hp
    return @animatingHP ? @currenthp : @battler.hp
  end
  #-----------------------------------------------------------------------------
  #  animate HP
  #-----------------------------------------------------------------------------
  def animateHP(oldhp, newhp)
    @starthp = oldhp.to_f
    @currenthp = oldhp.to_f
    @endhp = newhp.to_f
    @animatingHP = true
  end
  #-----------------------------------------------------------------------------
  #  animate EXP
  #-----------------------------------------------------------------------------
  def animateEXP(oldexp, newexp)
    @currentexp = oldexp
    @endexp = newexp
    @animatingEXP = true
  end
  #-----------------------------------------------------------------------------
  #  check if databox is showing
  #-----------------------------------------------------------------------------
  def show; @showing = false; end
  #-----------------------------------------------------------------------------
  #  apply damage tint
  #-----------------------------------------------------------------------------
  def damage
    @sprites["base"].color = Color.new(221, 82, 71)
  end
  #-----------------------------------------------------------------------------
  #  draw databox elements
  #-----------------------------------------------------------------------------
  def render
    self.applyMetrics
    # used to call the set-up procedure from the battle scene
    self.setUp
    @loaded = true
    self.refreshExpLevel
    # position databox
    rmd = (@sprites["base"].width%8)*(@playerpoke ? -1 : 1)
    self.x = self.defX + (@playerpoke ? @sprites["base"].width : -@sprites["base"].width) + rmd
    self.y = self.defY
    self.refresh
    @loaded = false
  end
  #-----------------------------------------------------------------------------
  #  queue databox for entry animation
  #-----------------------------------------------------------------------------
  def appear
    @inposition = false
    @loaded = true
  end
  #-----------------------------------------------------------------------------
  #  set databox position
  #-----------------------------------------------------------------------------
  def position
    self.x = self.defX
  end
  #-----------------------------------------------------------------------------
  #  get default X position
  #-----------------------------------------------------------------------------
  def defX
    x = @defX
    x += (@battler.index/2)*8 if @playerpoke
    x += (@battle.pbParty(1).length - 1 - @battler.index/2)*8 - (@battle.pbParty(1).length - 1)*8 if !@playerpoke
    return x
  end
  #-----------------------------------------------------------------------------
  #  get default Y position
  #-----------------------------------------------------------------------------
  def defY
    y = @defY
    y -= 50*((2-@battler.index)/2) - 64 + (48*(@battle.pbMaxSize(0) - 1))  + (@expandDouble && @battler.index == 0 ? 20 : 0) if @playerpoke && @battle.pbMaxSize(0) > 1
    y += 50*(@battler.index/2) - 16 if !@playerpoke && @battle.pbMaxSize(1) > 1
    return y
  end
  #-----------------------------------------------------------------------------
  #  configure all the sprite elements for databox
  #-----------------------------------------------------------------------------
  def setUp
    # reset of the set-up procedure
    @loaded = false
    @showing = false
    pbDisposeSpriteHash(@sprites)
    @sprites.clear
    # caches the bitmap used for coloring
    @colors = pbBitmap(@path + @colors)
    # initializes all the necessary components
    @sprites["base"] = Sprite.new(@viewport)
    @sprites["base"].bitmap = pbBitmap(@path+@baseBitmap)
    @sprites["base"].mirror = @playerpoke

    @sprites["status"] = Sprite.new(@viewport)
    @sprites["status"].bitmap = pbBitmap(@path + "status")
    @sprites["status"].z = self.getMetric("status", :z)
    @sprites["status"].src_rect.height /= 5
    @sprites["status"].src_rect.width = 0
    @sprites["status"].ex = self.getMetric("status", :x)
    @sprites["status"].ey = self.getMetric("status", :y)

    @sprites["mega"] = Sprite.new(@viewport)
    @sprites["mega"].z = self.getMetric("mega", :z)
    @sprites["mega"].mirror = @playerpoke
    @sprites["mega"].ex = self.getMetric("mega", :x)
    @sprites["mega"].ey = self.getMetric("mega", :y)

    @sprites["container"] = Sprite.new(@viewport)
    @sprites["container"].bitmap = pbBitmap(@path + @containerBmp)
    @sprites["container"].z = self.getMetric("container", :z)
    @sprites["container"].src_rect.height = @showexp ? 26 : 14
    @sprites["container"].ex = self.getMetric("container", :x)
    @sprites["container"].ey = self.getMetric("container", :y)

    @sprites["hp"] = Sprite.new(@viewport)
    @sprites["hp"].bitmap = Bitmap.new(1, 6)
    @sprites["hp"].z = @sprites["container"].z
    @sprites["hp"].ex = @sprites["container"].ex + @hpBarX
    @sprites["hp"].ey = @sprites["container"].ey + @hpBarY

    @sprites["exp"] = Sprite.new(@viewport)
    @sprites["exp"].bitmap = Bitmap.new(1, 4)
    @sprites["exp"].bitmap.blt(0, 0, @colors, Rect.new(0, 6, 2, 4))
    @sprites["exp"].z = @sprites["container"].z
    @sprites["exp"].ex = @sprites["container"].ex + @expBarX
    @sprites["exp"].ey = @sprites["container"].ey + @expBarY

    @sprites["textName"] = Sprite.new(@viewport)
    @sprites["textName"].bitmap = Bitmap.new(@sprites["container"].bitmap.width + 32, @sprites["base"].bitmap.height)
    @sprites["textName"].z = self.getMetric("name", :z)
    @sprites["textName"].ex = self.getMetric("name", :x) - 16
    @sprites["textName"].ey = self.getMetric("name", :y)
    pbSetSmallFont(@sprites["textName"].bitmap)

    @sprites["caught"] = Sprite.new(@viewport)
    @sprites["caught"].bitmap = pbBitmap(@path + "battleBoxOwned") if !@playerpoke && @battler.owned? && !@scene.battle.opponent
    @sprites["caught"].z = @sprites["container"].z
    @sprites["caught"].ex = @sprites["container"].ex - 18
    @sprites["caught"].ey = @sprites["container"].ey - 2

    @sprites["textHP"] = Sprite.new(@viewport)
    @sprites["textHP"].bitmap = Bitmap.new(@sprites["container"].bitmap.width, @sprites["base"].bitmap.height + 8)
    @sprites["textHP"].z = self.getMetric("hp", :z)
    @sprites["textHP"].ex = self.getMetric("hp", :x)
    @sprites["textHP"].ey = self.getMetric("hp", :y)
    pbSetSmallFont(@sprites["textHP"].bitmap)

    @megaBmp = pbBitmap(@path + "symMega")
    @prKyogre = pbBitmap("Graphics/Pictures/Battle/icon_primal_Kyogre")
    @prGroudon = pbBitmap("Graphics/Pictures/Battle/icon_primal_Groudon")
  end
  #-----------------------------------------------------------------------------
  #  positioning functions
  #-----------------------------------------------------------------------------
  def x; return @sprites["base"].x; end
  def y; return @sprites["base"].y; end
  def z; return @sprites["base"].z; end
  def visible; return @sprites["base"] ? @sprites["base"].visible : false; end
  def opacity; return @sprites["base"].opacity; end
  def color; return @sprites["base"].color; end
  def x=(val)
    return if !@loaded
    # calculates the relative X positions of all elements
    @sprites["base"].x = val
    for key in @sprites.keys
      next if key == "base"
      @sprites[key].x = @sprites["base"].x + @sprites[key].ex
    end
  end
  def y=(val)
    return if !@loaded
    # calculates the relative X positions of all elements
    @sprites["base"].y = val
    for key in @sprites.keys
      next if key == "base" || !@sprites[key]
      @sprites[key].y = @sprites["base"].y + @sprites[key].ey
    end
  end
  def visible=(val)
    for key in @sprites.keys
      next if !@sprites[key]
      @sprites[key].visible = val
    end
  end
  def temphide(val)
    if val
      @temphide = self.visible
      self.visible = false
    else
      self.visible = @temphide
      @temphide = false
    end
  end
  def opacity=(val)
    for key in @sprites.keys
      next if !@sprites[key]
      @sprites[key].opacity = val
    end
  end
  def color=(val)
    for sprite in @sprites.values
      sprite.color = val
    end
  end
  def positionX=(val)
    val = 4 if val < 4
    val = (@viewport.width - @sprites["base"].bitmap.width) if val > (@viewport.width - @sprites["base"].bitmap.width)
    self.x = val
  end
  #-----------------------------------------------------------------------------
  #  update HP bar (performance gains)
  #-----------------------------------------------------------------------------
  def updateHpBar
    return if self.disposed?
    # updates the current state of the HP bar
    zone = 0
    zone = 1 if self.hp <= @battler.totalhp*0.50
    zone = 2 if self.hp <= @battler.totalhp*0.25
    @sprites["hp"].bitmap.blt(0,0,@colors,Rect.new(zone*2,0,2,6))
    hpbar = @battler.totalhp == 0 ? 0 : (self.hp*@hpBarWidth/@battler.totalhp.to_f)
    @sprites["hp"].zoom_x = hpbar
    # updates the HP text
    str = "#{self.hp}/#{@battler.totalhp}"
    @sprites["textHP"].bitmap.clear
    textpos = [[str,@sprites["textHP"].bitmap.width,0,1,Color.white,Color.new(0,0,0,125)]]
    pbDrawTextPositions(@sprites["textHP"].bitmap,textpos) if @showhp
  end
  #-----------------------------------------------------------------------------
  #  update EXP bar (performance gains)
  #-----------------------------------------------------------------------------
  def updateExpBar
    return if self.disposed?
    @sprites["exp"].zoom_x = @showexp ? self.exp : 0
  end
  #-----------------------------------------------------------------------------
  #  refresh databox contents
  #-----------------------------------------------------------------------------
  def refresh
    return if self.disposed?
    # refreshes data
    @pokemon = @battler.displayPokemon
    # failsafe
    return if @pokemon.nil?
    @hidden = EliteBattle.get_data(@pokemon.species, :Species, :HIDENAME, (@pokemon.form rescue 0)) && !$Trainer.owned?(@pokemon.species)
    # exits the refresh if the databox isn't fully set up yet
    return if !@loaded
    # update for HP/EXP bars
    self.updateHpBar
    # clears the current bitmap containing text and adjusts its font
    @sprites["textName"].bitmap.clear
    # used to calculate the potential offset of elements should they exceed the
    # width of the HP bar
    str = ""
    str = _INTL("♂") if @pokemon.gender == 0 && !@hidden
    str = _INTL("♀") if @pokemon.gender == 1 && !@hidden
    w = @sprites["textName"].bitmap.text_size("#{@battler.name.force_encoding("UTF-8")}#{str.force_encoding("UTF-8")}Lv.#{@pokemon.level}").width
    o = (w > @hpBarWidth + 4) ? (w-(@hpBarWidth + 4))/2.0 : 0; o = o.ceil
    # writes the Pokemon's name
    str = @battler.name.nil? ? "" : @battler.name
    str += " "
    color = @pokemon.shiny? ? Color.new(222,197,95) : Color.white
    pbDrawOutlineText(@sprites["textName"].bitmap,18-o,3,@sprites["textName"].bitmap.width-40,@sprites["textName"].bitmap.height,str,color,Color.new(0,0,0,125),0)
    # writes the Pokemon's gender
    x = @sprites["textName"].bitmap.text_size(str).width + 18
    str = ""
    str = _INTL("♂") if @pokemon.gender == 0 && !@hidden
    str = _INTL("♀") if @pokemon.gender == 1 && !@hidden
    color = (@pokemon.gender == 0) ? Color.new(53,107,208) : Color.new(180,37,77)
    pbDrawOutlineText(@sprites["textName"].bitmap,x-o,3,@sprites["textName"].bitmap.width-40,@sprites["textName"].bitmap.height,str,color,Color.new(0,0,0,125),0)
    # writes the Pokemon's level
    str = "Lv.#{@battler.level}"
    pbDrawOutlineText(@sprites["textName"].bitmap,18+o,3,@sprites["textName"].bitmap.width-40,@sprites["textName"].bitmap.height,str,Color.white,Color.new(0,0,0,125),2)
    # changes the Mega symbol graphics (depending on Mega or Primal)
    if @battler.mega?
      @sprites["mega"].bitmap = @megaBmp.clone
    elsif @battler.primal?
      @sprites["mega"].bitmap = @prKyogre.clone if @battler.isSpecies?(:KYOGRE)
      @sprites["mega"].bitmap = @prGroudon.clone if @battler.isSpecies?(:GROUDON)
    elsif @sprites["mega"].bitmap
      @sprites["mega"].bitmap.clear
      @sprites["mega"].bitmap = nil
    end
    self.updateHpBar
    self.updateExpBar
  end
  #-----------------------------------------------------------------------------
  #  update databox
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    # updates the HP increase/decrease animation
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += (@endhp - @currenthp)/10.0.delta_add(false)
        @currenthp = @currenthp.ceil
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= (@currenthp - @endhp)/10.0.delta_add(false)
        @currenthp = @currenthp.floor
        @currenthp = @endhp if @currenthp < @endhp
      end
      self.updateHpBar
      @animatingHP = false if @currenthp == @endhp
    end
    # updates the EXP increase/decrease animation
    if @animatingEXP
      if !@showexp
        @currentexp = @endexp
      elsif @currentexp < @endexp
        @currentexp += (@endexp - @currentexp)/10.0.delta_add(false)
        @currentexp = @currentexp.ceil
        @currentexp = @endexp if @currentexp > @endexp
      elsif @currentexp > @endexp
        @currentexp -= (@currentexp - @endexp)/10.0.delta_add(false)
        @currentexp = @currentexp.floor
        @currentexp = @endexp if @currentexp < @endexp
      end
      self.updateExpBar
      if @currentexp == @endexp
        # tints the databox blue and plays a sound when EXP is full
        if @currentexp >= @expBarWidth
          pbSEPlay("Pkmn exp full")
          @sprites["base"].color = Color.new(61, 141, 179)
          @animatingEXP = false
          refreshExpLevel
          self.refresh
        else
          @animatingEXP = false
        end
      end
    end
    return if !@loaded
    # moves into position
    unless @animatingHP || @animatingEXP || @inposition
      if @playerpoke && self.x > self.defX
        self.x -= @sprites["base"].width/8
      elsif !@playerpoke && self.x < self.defX
        self.x += @sprites["base"].width/8
      end
    end
    # shows status condition
    status = GameData::Status.get(@battler.status).id_number
    @sprites["status"].src_rect.y = @sprites["status"].src_rect.height * (status - 1)
    @sprites["status"].src_rect.width = status > 0 ? @sprites["status"].bitmap.width : 0
    # gets rid of the level up tone
    @sprites["base"].color.alpha -= 16 if @sprites["base"].color.alpha > 0
    # bobbing effect
    if @selected
      @frame += 1
      self.y = self.defY + (@frame <= 8.delta_add ? 2 : 0) - (@frame > 8.delta_add ? 2 : 0)
      @frame = 0 if @frame > 16.delta_add
    else
      self.y = self.defY
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Player Side Safari Zone data box
#===============================================================================
class SafariDataBoxEBDX < SpriteWrapper
  attr_accessor :selected
  attr_reader :appearing
  #-----------------------------------------------------------------------------
  #  safari bar constructor
  #-----------------------------------------------------------------------------
  def initialize(battle, viewport=nil)
    @viewport = viewport
    super(viewport)
    @selected = 0
    @battle = battle
    bmp = pbBitmap("Graphics/EBDX/Pictures/UI/safariBar")
    @spriteX = @viewport.width - bmp.width
    @spriteY = @viewport.height - 184
    # looks up globally defined settings
    data = EliteBattle.get_data(:SAFARI_DATABOX, :Metrics, :METRICS)
    unless data.nil?
      # applies a set of predefined keys
      @spriteX = data[:X] if data.has_key?(:X) && data[:X].is_a?(Numeric)
      @spriteY = data[:Y] if data.has_key?(:Y) && data[:Y].is_a?(Numeric)
    end
    @temphide = false
    @appearing = false
    @contents = BitmapWrapper.new(bmp.width, 78)
    bmp.dispose
    self.bitmap = @contents
    pbSetSmallFont(self.bitmap)
    self.visible = false
    self.z = 50
    refresh
  end
  #-----------------------------------------------------------------------------
  #  hide databox
  #-----------------------------------------------------------------------------
  def temphide(val)
    if val
      @temphide = self.visible
      self.visible = false
    else
      self.visible = @temphide
      @temphide = false
    end
  end
  #-----------------------------------------------------------------------------
  #  toggle the bar to appear
  #-----------------------------------------------------------------------------
  def appear
    refresh
    self.visible = true
    self.opacity = 255
  end
  #-----------------------------------------------------------------------------
  #  refresh bar
  #-----------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    bmp = pbBitmap("Graphics/EBDX/Pictures/UI/safariBar")
    self.bitmap.blt((self.bitmap.width-bmp.width)/2,self.bitmap.height-bmp.height,bmp,Rect.new(0,0,bmp.width,bmp.height))
    str = _INTL("Safari Balls: {1}", @battle.ballCount)
    pbDrawOutlineText(self.bitmap,0,38,self.bitmap.width,self.bitmap.height,str,Color.white,Color.new(0,0,0,125),1)
  end
  #-----------------------------------------------------------------------------
  #  update (temp)
  #-----------------------------------------------------------------------------
  def update; end
  def width; return self.bitmap.width; end
  #-----------------------------------------------------------------------------
end
