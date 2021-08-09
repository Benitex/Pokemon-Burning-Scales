#===============================================================================
# Battle Scene class
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  # function to set up the battle room based on battle environment and terrain
  #-----------------------------------------------------------------------------
  def loadBackdrop
    data = EliteBattle.getNextBattleEnv(@battle)
    # applies predefined battle backdrops for Trainer or Pokemon
    if @battle.opponent
      bgdrop = EliteBattle.get_trainer_data(@battle.opponent[0].trainer_type, :BACKDROP, @battle.opponent[0])
    else
      bgdrop = EliteBattle.get_data(@battle.pbParty(1)[0].species, :Species, :BACKDROP, (@battle.pbParty(1)[0].form rescue 0))
    end
    backdrop = bgdrop.clone if !bgdrop.nil?
    # applies global backdrop if cached
    if EliteBattle.get(:nextBattleBack)
      data = EliteBattle.get(:nextBattleBack) if EliteBattle.get(:nextBattleBack).is_a?(Hash)
      data = { "backdrop" => EliteBattle.get(:nextBattleBack) } if EliteBattle.get(:nextBattleBack).is_a?(String)
      data = getConst(EnvironmentEBDX, EliteBattle.get(:nextBattleBack)) if EliteBattle.get(:nextBattleBack).is_a?(Symbol)
    elsif !backdrop.nil?
      data = backdrop.clone
    end
    # adds daylight adjustment if outdoor
    data["outdoor"] = true if !data.has_key?("outdoor") && EliteBattle.outdoor_map? && Settings::TIME_SHADING
    # Apply graphics
    @sprites["battlebg"] = BattleSceneRoom.new(@viewport, self, data)
    # special trainer intro graphic
    @sprites["trainer_Anim"] = ScrollingSprite.new(@viewport)
    # tries to resolve the bitmap before assigning it
    base = pbResolveBitmap("Graphics/EBDX/Transitions/Common/#{base}") ? base : "outdoor"
    # check if there is an assigned background for the trainer intro
    if @battle.opponent
      try = sprintf("%03d", GameData::TrainerType.get(@battle.opponent[0].trainer_type).id_number)
      base = try if pbResolveBitmap("Graphics/EBDX/Transitions/Common/#{try}")
    end
    @sprites["trainer_Anim"].setBitmap("Graphics/EBDX/Transitions/Common/#{base}")
    @sprites["trainer_Anim"].direction = -1
    @sprites["trainer_Anim"].speed = 48
    @sprites["trainer_Anim"].visible = !@smTrainerSequence && @minorAnimation
    @sprites["trainer_Anim"].z = 97
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
module EliteBattle
  #-----------------------------------------------------------------------------
  # returns a data hash of the next (potentially generated) battle environment
  #-----------------------------------------------------------------------------
  def self.getNextBattleEnv(battle = nil)
    battleRules = $PokemonTemp.battleRules
    environ = battleRules["environment"].nil? ? pbGetEnvironment : battleRules["environment"]
    terrain = $game_player.terrain_tag.id
    # base battle scene room data
    # load basic room
    const = (EliteBattle.outdoor_map? ? :OUTDOOR : :INDOOR)
    try = EnvironmentEBDX.const_defined?(const) ? EnvironmentEBDX.const_get(const) : nil
    data = try.clone if !try.nil?
    # applies predefined battle backdrop for map
    try = EliteBattle.get_map_data(:BACKDROP)
    data = try.clone if !try.nil?
    # applies room data for specific environment if defined
    unless [0, 1].include?(environ)
      try = EliteBattle.get_data(environ, :Environment, :BACKDROP)
      data = try.clone if !try.nil?
    end
    # check for fails
    data = {} if data.nil?
    # applies additional terrain data
    try = EliteBattle.get_data(terrain, :TerrainTag, :BACKDROP)
    if !try.nil?
      for key in try.keys
        data[key] = try[key]
      end
    end
    # applies conditional environment/terrain data
    processes = EliteBattle.get(:procData)
    for key in processes.keys
      if key.call(terrain, environ)
        for k in processes[key][:BACKDROP].keys
          data[k] = processes[key][:BACKDROP][k]
        end
      end
    end
    # pushes trees up a little to accomodate base
    if data.has_key?("trees", "base")
      data["trees"][:y] = [108,117,118,122,122,127,127,128,132]
    end
    # cuts down on grass if in double battle
    if data.has_key?("tallGrass") && !battle.nil? && (battle.doublebattle? || battle.triplebattle?)
      data["tallGrass"][:elements] = 5 if data["tallGrass"][:elements] > 5
    end
    return data.nil? ? {} : data
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# custom class to compose and animate the battle background
#===============================================================================
class BattleSceneRoom
  attr_reader :data
  attr_accessor :dynamax
  #-----------------------------------------------------------------------------
  # class constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport, scene, data)
    @viewport = viewport
    @scene = scene
    @battle = @scene.battle
    @doublebattle = @battle.doublebattle?
    @sprites = {}
    @fpIndex = 0
    @wind = 90
    @wWait = 0
    @toggle = 0.5
    @disposed = false
    @strongwind = false
    @dynamax = false
    @weather = nil
    @focused = true
    @queued = nil
    @data = data
    @backup = data.clone
    @defaultvector = EliteBattle.get_vector(:MAIN, @battle)
    @sunny = false
    # draws elements based on data
    self.refresh(data)
  end
  #-----------------------------------------------------------------------------
  # applies data hash to object
  #-----------------------------------------------------------------------------
  def refresh(*args)
    unless args[0].is_a?(Hash)
      @sprites[args[0]] = args[1] if args[0].is_a?(String) && args.length > 1
      return
    end
    @fpIndex = 0
    # disposes sprites if they exist
    pbDisposeSpriteHash(@sprites)
    sx, sy = @scene.vector.spoof(@defaultvector)
    # void sprite
    @sprites["void"] = Sprite.new(@viewport)
    @sprites["void"].z = -10
    @sprites["void"].bitmap = Bitmap.new(@viewport.width, @viewport.height)
    # draws backdrop
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].z = 0
    # draws base
    @baseBmp = nil
    # draws elements from data block (prority added to predefined modules)
    for key in ["backdrop", "base", "water", "spinningLights", "outdoor", "sky", "trees", "tallGrass", "spinLights",
               "lightsA", "lightsB", "lightsC", "vacuum", "bubbles"] # to sort the order
      next if !@data.has_key?(key)
      case key
      when "backdrop" # adds custom background image
        path = pbResolveBitmap(@data["backdrop"]) ? @data["backdrop"] : "Graphics/EBDX/Battlebacks/battlebg/" + @data["backdrop"]
        tbmp = pbBitmap(path)
        @sprites["bg"].bitmap = Bitmap.new(tbmp.width, tbmp.height)
        @sprites["bg"].bitmap.blt(0, 0, tbmp, tbmp.rect)
        tbmp.dispose
      when "base" # blt base onto backdrop
        str = pbResolveBitmap(@data["base"]) ? @data["base"] : "Graphics/EBDX/Battlebacks/base/" + @data["base"]
        @baseBmp = pbBitmap(str) if str
      when "sky" # adds dynamic sky to scene
        self.drawSky
      when "trees" # adds array of trees to scene
        self.drawTrees
      when "tallGrass" # adds array of tall grass to scene
        self.drawGrass
      when "spinLights" # adds PWT styled spinning base lights
        self.drawSpinLights
      when "lightsA" # adds PWT styled stage lights
        self.drawLightsA
      when "lightsB" # adds disco styled stage lights
        self.drawLightsB
      when "lightsC" # adds ambiental scene lights
        self.drawLightsC
      when "water" # adds water animation effect
        self.drawWater
      when "vacuum"
        self.vacuumWaves(@data[key]) # draws vacuum waves
      when "bubbles"
        self.bubbleStream(@data[key]) # draws bubble particles
      end
    end
    # draws additional modules where sequencing is disregarded
    for key in @data.keys
      if key.include?("img")
        self.drawImg(key)
      end
    end
    # applies backdrop positioning
    if @sprites["bg"].bitmap
      @sprites["bg"].center!
      @sprites["bg"].ox = sx/1.5 - 16
      @sprites["bg"].oy = sy/1.5 + 16
      if @baseBmp
        @sprites["bg"].bitmap.blt(0, @sprites["bg"].bitmap.height - @baseBmp.height, @baseBmp, @baseBmp.rect)
      end
      c1 = @sprites["bg"].bitmap.get_pixel(0, 0)
      c2 = @sprites["bg"].bitmap.get_pixel(0, @sprites["bg"].bitmap.height-1)
      @sprites["void"].bitmap.fill_rect(0, 0, @viewport.width, @viewport.height/2, c1)
      @sprites["void"].bitmap.fill_rect(0, @viewport.height/2, @viewport.width, @viewport.height/2, c2)
    end
    # battler sprite positioning
    self.adjustMetrics
    # applies daylight tinting
    self.daylightTint
  end
  #-----------------------------------------------------------------------------
  # sets color of sprite to match the environment
  #-----------------------------------------------------------------------------
  def setColor(target, sprite, color = true)
    return if !target.bitmap || !sprite.ex || !sprite.ey
    c = target.bitmap.get_pixel(sprite.ex, sprite.ey)
    a = (color == "slight") ? 128 : 255
    sprite.colorize(c, a)
  end
  #-----------------------------------------------------------------------------
  # battle room frame update
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    # updates to the spatial warping with respect to the scene vector
    @sprites["bg"].x = @scene.vector.x2
    @sprites["bg"].y = @scene.vector.y2
    sx, sy = @scene.vector.spoof(@defaultvector)
    @sprites["bg"].zoom_x = @scale*((@scene.vector.x2 - @scene.vector.x)*1.0/(sx - @defaultvector[0])*1.0)**0.6
    @sprites["bg"].zoom_y = @scale*((@scene.vector.y2 - @scene.vector.y)*1.0/(sy - @defaultvector[1])*1.0)**0.6
    # updates the vacuum waves
    for j in 0...3
      next if j > @fpIndex/50 || !@sprites["ec#{j}"]
      if @sprites["ec#{j}"].param <= 0
        @sprites["ec#{j}"].param = 1.5
        @sprites["ec#{j}"].opacity = 0
        @sprites["ec#{j}"].ex = 234
      end
      @sprites["ec#{j}"].opacity += (@sprites["ec#{j}"].param < 0.75 ? -4 : 4)/self.delta
      @sprites["ec#{j}"].ex += [1, 2/self.delta].max if (@fpIndex*self.delta)%4 == 0 && @sprites["ec#{j}"].ex < 284
      @sprites["ec#{j}"].ey -= [1, 2/self.delta].min if (@fpIndex*self.delta)%4 == 0 && @sprites["ec#{j}"].ey > 108
      @sprites["ec#{j}"].param -= 0.01/self.delta
    end
    # updates bubble particles
    for j in 0...18
      next if !@sprites["bubble#{j}"]
      if @sprites["bubble#{j}"].ey <= -32
        r = rand(5) + 2
        @sprites["bubble#{j}"].param = 0.16 + 0.01*rand(32)
        @sprites["bubble#{j}"].ey = @sprites["bg"].bitmap.height*0.25 + rand(@sprites["bg"].bitmap.height*0.75)
        @sprites["bubble#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["bubble#{j}"].end_y = 64 + rand(72)
        @sprites["bubble#{j}"].end_x = @sprites["bubble#{j}"].ex
        @sprites["bubble#{j}"].toggle = rand(2) == 0 ? 1 : -1
        @sprites["bubble#{j}"].speed = 1 + 2/((r + 1)*0.4)
        @sprites["bubble#{j}"].z = [2,15,25][rand(3)] + rand(6) - (@focused ? 0 : 100)
        @sprites["bubble#{j}"].opacity = 0
      end
      min = @sprites["bg"].bitmap.height/4
      max = @sprites["bg"].bitmap.height/2
      scale = (2*Math::PI)/((@sprites["bubble#{j}"].bitmap.width/64.0)*(max - min) + min)
      @sprites["bubble#{j}"].opacity += 4 if @sprites["bubble#{j}"].opacity < @sprites["bubble#{j}"].end_y
      @sprites["bubble#{j}"].ey -= [1, @sprites["bubble#{j}"].speed/self.delta].max
      @sprites["bubble#{j}"].ex = @sprites["bubble#{j}"].end_x + @sprites["bubble#{j}"].bitmap.width*0.25*Math.sin(@sprites["bubble#{j}"].ey*scale)*@sprites["bubble#{j}"].toggle
    end
    # update weather particles
    self.updateWeather
    # positions all elements according to the battle backdrop
    self.position
    # updates skyline
    self.updateSky
    # turn off shadows if appropriate
    if @data.has_key?("noshadow") && @data["noshadow"] == true
      # for battler sprites
      @battle.battlers.each_with_index do |b, i|
        next if !b || !@scene.sprites["pokemon_#{i}"]
        @scene.sprites["pokemon_#{i}"].noshadow = true
      end
      # for trainer sprites
      if @battle.opponent
        for t in 0...@battle.opponent.length
          next if !@scene.sprites["trainer_#{t}"]
          @scene.sprites["trainer_#{t}"].noshadow = true
        end
      end
    end
    # adjusts for wind affected elements
    if @strongwind
      @wind -= @toggle*2
      @toggle *= -1 if @wind < 65 || (@wind >= 70 && @toggle < 0)
    else
      @wWait += 1
      if @wWait > Graphics.frame_rate*5
        mod = @toggle*(2 + (@wind >= 88 && @wind <= 92 ? 2 : 0))
        @wind -= mod
        @toggle *= -1 if @wind <= 80 || @wind >= 100
        @wWait = 0 if @wWait > Graphics.frame_rate*5 + 33
      end
    end
    # additional metrics
    @fpIndex += 1
    @fpIndex = 150 if @fpIndex > 255*self.delta
  end
  #-----------------------------------------------------------------------------
  # positions all the elements inside of the room
  #-----------------------------------------------------------------------------
  def position
    for key in @sprites.keys
      next if key == "bg" || key == "0" || key == "void" || key.include?("w_sunny") || key.include?("w_sand") || key.include?("w_fog")
      # updates fancy light effects
      if key.include?("sLight")
        i = key.gsub("sLight","").to_i
        if @sprites["sLight#{i}"] && @scene.vector
          x, y = self.stageLightPos(i)
          @sprites["sLight#{i}"].ex = x
          @sprites["sLight#{i}"].ey = y
          @sprites["sLight#{i}"].update
        end
      end
      x = @sprites["bg"].x - (@sprites["bg"].ox - @sprites[key].ex)*@sprites["bg"].zoom_x
      y = @sprites["bg"].y - (@sprites["bg"].oy - @sprites[key].ey)*@sprites["bg"].zoom_y
      z = @sprites[key].param * @sprites["bg"].zoom_x
      @sprites[key].x = x
      @sprites[key].y = y
      if ["sky", "base", "water"].string_include?(key) || (key.include?("img") && @data[key].try_key?(:flat))
        @sprites[key].zoom_x = @sprites["bg"].zoom_x * (@sprites[key].zx ? @sprites[key].zx : 1)
        @sprites[key].zoom_y = @sprites["bg"].zoom_y * (@sprites[key].zy ? @sprites[key].zy : 1)
      elsif key.include?("sLight") && @sprites[key] && @scene.vector
        z = ((@scene.vector.zoom1**0.6) * ((i%2 == 0) ? 2 : 1) * 1.25)
        @sprites[key].zoom_x = z * @sprites["bg"].zoom_x * @sprites[key].zx
        @sprites[key].zoom_y = z * @sprites["bg"].zoom_y * @sprites[key].zy
      else
        @sprites[key].zoom = z
      end
      # effect for elements blowing side to side with wind
      if (key.include?("grass") || key.include?("tree") || key.include?("img"))
        if key.include?("grass") || key.include?("tree") || (@data[key] && @data[key].has_key?(:effect) && @data[key][:effect] == "wind")
          w = key.include?("tree") ? ((@wind-90)*0.25).to_i + 90 : @wind
          @sprites[key].skew(w)
          @sprites[key].ox = @sprites[key].x_mid
        end
      end
      # effect for rotating elements
      if key.include?("img") && (@data[key].has_key?(:effect) && @data[key][:effect] == "rotate")
        @sprites[key].angle += @sprites[key].direction * @sprites[key].speed/self.delta
      end
      # effect for lighting updates
      if key.include?("aLight") || key.include?("cLight")
        @sprites[key].opacity -= @sprites[key].toggle*@sprites[key].speed/self.delta
        @sprites[key].toggle *= -1 if @sprites[key].opacity <= 95 || @sprites[key].opacity >= @sprites[key].end_x*255
      end
      if key.include?("bLight")
        if @wWait*self.delta % @sprites[key].speed == 0
          @sprites[key].bitmap = @sprites[key].storedBitmap.clone
          @sprites[key].bitmap.hue_change((rand(8)*45/self.delta).round)
          @sprites[key].opacity = (rand(4) < 2 ? 192 : 0)
        end
      end
      @sprites[key].update
    end
  end
  #-----------------------------------------------------------------------------
  # loads all the necessary elements for the outdoor skybox
  #-----------------------------------------------------------------------------
  def drawSky
    # drawing additional skylines
    key = "Day"
    if @data.try_key?("outdoor")
      key = "Dawn" if PBDayNight.isEvening? || PBDayNight.isMorning?
      key = "Night" if PBDayNight.isNight?
    end
    @sprites["sky"] = Sprite.new(@viewport)
    @sprites["sky"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/sky#{key}")
    @sprites["sky"].oy = @sprites["sky"].bitmap.height
    @sprites["sky"].ex = 0
    @sprites["sky"].ey = @sprites["sky"].oy
    @sprites["sky"].param = 1
    # loop for drawing clouds
    for i in [1,0]
      @sprites["cloud#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["cloud#{i}"].setBitmap("Graphics/EBDX/Battlebacks/elements/cloud#{i+1}")
      @sprites["cloud#{i}"].speed = [0.5, 0.5, 0.25][i]
      @sprites["cloud#{i}"].direction = [1, -1, 1][i]
      @sprites["cloud#{i}"].oy = @sprites["cloud#{i}"].bitmap.height
      @sprites["cloud#{i}"].ex = 0
      @sprites["cloud#{i}"].ey = [98, 91, 30][i]
      @sprites["cloud#{i}"].param = 1
      @sprites["cloud#{i}"].visible = !PBDayNight.isNight? || !@data.try_key?("outdoor")
      self.setColor(@sprites["sky"], @sprites["cloud#{i}"])
    end
    # draws the sun
    if !(PBDayNight.isNight? && @data.try_key?("outdoor"))
      @sprites["sun"] = Sprite.new(@viewport)
      @sprites["sun"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/sun")
      @sprites["sun"].ox = @sprites["sun"].bitmap.width/2
      @sprites["sun"].oy = @sprites["sun"].bitmap.height*4
      @sprites["sun"].ex = 208
      @sprites["sun"].ey = @sprites["sky"].ey - 3
      @sprites["sun"].param = 1
    end
    # loop for the stars
    for i in 0...24
      break if !(PBDayNight.isNight? && @data.try_key?("outdoor"))
      @sprites["star#{i}"] = Sprite.new(@viewport)
      @sprites["star#{i}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/star")
      @sprites["star#{i}"].center!
      @sprites["star#{i}"].ex = rand(@sprites["sky"].bitmap.width)
      @sprites["star#{i}"].ey = rand(@sprites["sky"].bitmap.height - 24)
      @sprites["star#{i}"].speed = rand(4) + 1
      @sprites["star#{i}"].param = 0.6 + rand(41)/100.0
      @sprites["star#{i}"].opacity = 125
      @sprites["star#{i}"].end_x = 185 + rand(71)
      @sprites["star#{i}"].toggle = 2
    end
  end
  #-----------------------------------------------------------------------------
  # tints all the elements inside of the scene based on daytime conditions
  #-----------------------------------------------------------------------------
  def daylightTint
    return if !@data.try_key?("sky", "outdoor")
    # apply daytime shading
    for key in @sprites.keys
      next if key.include?("trainer") || key.include?("battler")
      next if key.include?("sky") || key.include?("sun") || key.include?("star") || key.include?("cloud") ||  key.include?("Light") || (@data[key].is_a?(Hash) && @data[key].has_key?(:shading) && !@data[key][:shading])
      if PBDayNight.isNight? && !@sunny
        @sprites[key].tone = Tone.new(-120, -100, -60)
      elsif (PBDayNight.isEvening? || PBDayNight.isMorning?) && !@sunny
        @sprites[key].tone = Tone.new(-16, -52, -56)
      else
        @sprites[key].tone = Tone.new(0, 0, 0)
      end
    end
  end
  #-----------------------------------------------------------------------------
  # frame update for the skybox
  #-----------------------------------------------------------------------------
  def updateSky
    return if !@data.try_key?("sky", "outdoor")
    minutes = Time.now.hour*60 + Time.now.min
    # animates twinkling stars
    for i in 0...24
      break if !(PBDayNight.isNight? && @data.try_key?("outdoor"))
      next if !@sprites["star#{i}"]
      @sprites["star#{i}"].opacity += @sprites["star#{i}"].toggle * @sprites["star#{i}"].speed/self.delta
      @sprites["star#{i}"].toggle *= -1 if @sprites["star#{i}"].opacity <= 125 || @sprites["star#{i}"].opacity >= @sprites["star#{i}"].end_x
    end
    # applies sun positioning if it is rendered
    return if !@sprites["sun"]
    if PBDayNight.isEvening?
      oy = 92 - 68*(minutes - 17*60.0)/(3*60.0)
    elsif PBDayNight.isMorning?
      oy = 24 + 68*(minutes - 5*60.0)/(5*60.0)
    else
      oy = @sprites["sun"].bitmap.height*4
    end
    oy = 23 if oy < 23
    @sprites["sun"].src_rect.height = oy
    @sprites["sun"].oy = oy
  end
  #-----------------------------------------------------------------------------
  # set weather data
  #-----------------------------------------------------------------------------
  def setWeather
    # loop once
    for wth in [["Rain", [:Rain, :HeavyRain]], ["Snow", :Hail], ["StrongWind", :StrongWinds], ["Sunny", [:Sun, :HarshSun]], ["Sandstorm", :Sandstorm], ["Fog", :Fog]]
      proceed = false
      for cond in (wth[1].is_a?(Array) ? wth[1] : [wth[1]])
        proceed = true if @battle.pbWeather == cond
      end
      eval("delete" + wth[0]) unless proceed
      eval("draw"  + wth[0]) if proceed
    end
  end
  #-----------------------------------------------------------------------------
  # frame update for the weather particles
  #-----------------------------------------------------------------------------
  def updateWeather
    self.setWeather
    harsh = [:HEAVYRAIN, :HARSHSUN].include?(@battle.pbWeather)
    # snow particles
    for j in 0...72
      next if !@sprites["w_snow#{j}"]
      if @sprites["w_snow#{j}"].opacity <= 0
        z = rand(32)
        @sprites["w_snow#{j}"].param = 0.24 + 0.01*rand(z/2)
        @sprites["w_snow#{j}"].ey = -rand(64)
        @sprites["w_snow#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["w_snow#{j}"].end_x = @sprites["w_snow#{j}"].ex
        @sprites["w_snow#{j}"].toggle = rand(2) == 0 ? 1 : -1
        @sprites["w_snow#{j}"].speed = 1 + 2/((rand(5) + 1)*0.4)
        @sprites["w_snow#{j}"].z = z - (@focused ? 0 : 100)
        @sprites["w_snow#{j}"].opacity = 255
      end
      min = @sprites["bg"].bitmap.height/4
      max = @sprites["bg"].bitmap.height/2
      scale = (2*Math::PI)/((@sprites["w_snow#{j}"].bitmap.width/64.0)*(max - min) + min)
      @sprites["w_snow#{j}"].opacity -= @sprites["w_snow#{j}"].speed/self.delta
      @sprites["w_snow#{j}"].ey += [1, @sprites["w_snow#{j}"].speed/self.delta].max
      @sprites["w_snow#{j}"].ex = @sprites["w_snow#{j}"].end_x + @sprites["w_snow#{j}"].bitmap.width*0.25*Math.sin(@sprites["w_snow#{j}"].ey*scale)*@sprites["w_snow#{j}"].toggle
    end
    # rain particles
    for j in 0...72
      next if !@sprites["w_rain#{j}"]
      if @sprites["w_rain#{j}"].opacity <= 0
        z = rand(32)
        @sprites["w_rain#{j}"].param = 0.24 + 0.01*rand(z/2)
        @sprites["w_rain#{j}"].ox = 0
        @sprites["w_rain#{j}"].ey = -rand(64)
        @sprites["w_rain#{j}"].ex = 32 + rand(@sprites["bg"].bitmap.width - 64)
        @sprites["w_rain#{j}"].speed = 3 + 2/((rand(5) + 1)*0.4)
        @sprites["w_rain#{j}"].z = z - (@focused ? 0 : 100)
        @sprites["w_rain#{j}"].opacity = 255
      end
      @sprites["w_rain#{j}"].opacity -= @sprites["w_rain#{j}"].speed*(harsh ? 3 : 2)/self.delta
      @sprites["w_rain#{j}"].ox += [1, @sprites["w_rain#{j}"].speed*(harsh ? 8 : 6)/self.delta].max
    end
    # sun particles
    for j in 0...3
      next if !@sprites["w_sunny#{j}"]
      #next if j > @shine["count"]/6
      @sprites["w_sunny#{j}"].zoom_x += 0.04*[0.5, 0.8, 0.7][j]/self.delta
      @sprites["w_sunny#{j}"].zoom_y += 0.03*[0.5, 0.8, 0.7][j]/self.delta
      @sprites["w_sunny#{j}"].opacity += (@sprites["w_sunny#{j}"].zoom_x < 1 ? 8 : -12)/self.delta
      if @sprites["w_sunny#{j}"].opacity <= 0
        @sprites["w_sunny#{j}"].zoom_x = 0
        @sprites["w_sunny#{j}"].zoom_y = 0
        @sprites["w_sunny#{j}"].opacity = 0
      end
    end
    # sandstorm particles
    for j in 0...2
      next if !@sprites["w_sand#{j}"]
      @sprites["w_sand#{j}"].update
    end
    # fog particles
    for j in 0...2
      next if !@sprites["w_fog#{j}"]
      @sprites["w_fog#{j}"].update
    end
  end
  #-----------------------------------------------------------------------------
  # reads data from hashtable and draws all tree objects in room
  #-----------------------------------------------------------------------------
  def drawTrees(data = @data["trees"])
    return if !data.has_key?(:elements)
    bmp = data.has_key?(:bitmap) ? data[:bitmap] : "tree"
    bmp = pbBitmap("Graphics/EBDX/Battlebacks/elements/#{bmp}")
    for i in 0...data[:elements]
      @sprites["tree#{i}"] = Sprite.new(@viewport)
      x0 = data.has_key?(:mirror) && data[:mirror][i] ? bmp.width : 0
      x1 = data.has_key?(:mirror) && data[:mirror][i] ? -bmp.width : bmp.width
      @sprites["tree#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["tree#{i}"].bitmap.stretch_blt(bmp.rect,bmp,Rect.new(x0,0,x1,bmp.height))
      @sprites["tree#{i}"].bottom!
      @sprites["tree#{i}"].ex = data.has_key?(:x) ? data[:x][i] : 0
      @sprites["tree#{i}"].ey = data.has_key?(:y) ? data[:y][i] : 0
      @sprites["tree#{i}"].z = data.has_key?(:z) ? data[:z][i] : 1
      @sprites["tree#{i}"].param = data.has_key?(:zoom) ? data[:zoom][i] : 1
      color = data.has_key?(:colorize) ? data[:colorize] : true
      self.setColor(@sprites["bg"], @sprites["tree#{i}"], color) if color
      @sprites["tree#{i}"].memorize_bitmap
    end; bmp.dispose
  end
  #-----------------------------------------------------------------------------
  # reads data from hashtable and draws all grass objects in room
  #-----------------------------------------------------------------------------
  def drawGrass(data = @data["tallGrass"])
    return if !data.has_key?(:elements)
    bmp = data.has_key?(:bitmap) ? data[:bitmap] : "tallGrass"
    bmp = pbBitmap("Graphics/EBDX/Battlebacks/elements/#{bmp}")
    for i in 0...data[:elements]
      @sprites["grass#{i}"] = Sprite.new(@viewport)
      x0 = data.has_key?(:mirror) && data[:mirror][i] ? bmp.width : 0
      x1 = data.has_key?(:mirror) && data[:mirror][i] ? -bmp.width : bmp.width
      @sprites["grass#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["grass#{i}"].bitmap.stretch_blt(bmp.rect,bmp,Rect.new(x0,0,x1,bmp.height))
      @sprites["grass#{i}"].bottom!
      @sprites["grass#{i}"].ex = data.has_key?(:x) ? data[:x][i] : 0
      @sprites["grass#{i}"].ey = data.has_key?(:y) ? data[:y][i] : 0
      @sprites["grass#{i}"].z = data[:z][i] if data.has_key?(:z)
      @sprites["grass#{i}"].param = data.has_key?(:zoom) ? data[:zoom][i] : 1
      color = data.has_key?(:colorize) ? data[:colorize] : true
      self.setColor(@sprites["bg"], @sprites["grass#{i}"], color) if color
      @sprites["grass#{i}"].memorize_bitmap
    end; bmp.dispose
  end
  #-----------------------------------------------------------------------------
  # function to draw a custom room object based on user-defined parameters
  #-----------------------------------------------------------------------------
  def drawImg(key)
    data = @data[key]
    if data.try_key?(:scrolling) # simple scrolling panorama
      @sprites["#{key}"] = ScrollingSprite.new(@viewport)
    elsif data.try_key?(:sheet) # simple animated sprite sheets
      @sprites["#{key}"] = SpriteSheet.new(@viewport,data.get_key(:frames).nil? ? 1 : data[:frames])
    elsif data.try_key?(:animated) # EBS styled sprite sheets
      @sprites["#{key}"] = SpriteEBDX.new(@viewport)
    elsif data.try_key?(:rainbow) # hue changing sprite
      @sprites["#{key}"] = RainbowSprite.new(@viewport)
    else # regular sprite
      @sprites["#{key}"] = Sprite.new(@viewport)
    end
    @sprites["#{key}"].default!; keys = data.keys;
    if keys.include?(:bitmap) # prioritizes bitmap key from sorted array
      keys.delete(:bitmap); keys.insert(0,:bitmap)
    end
    for m in keys # interprets each parameter
      k = EliteBattle.bg_hash_map(m); next if k.nil? # if parameter can be mapped
      if k == :bitmap # applies bitmap
        path = pbResolveBitmap(data[m]) ? data[m] : "Graphics/EBDX/Battlebacks/elements/" + data[m]
        if data.try_key?(:scrolling) || data.try_key?(:animated) || data.try_key?(:rainbow) || data.try_key?(:sheet)
          @sprites["#{key}"].setBitmap(path,((data.try_key?(:animated) || data.try_key?(:rainbow)) ? 1 : data.get_key(:vertical)))
        else
          @sprites["#{key}"].bitmap = pbBitmap(path)
        end; next
      end # otherwise applies parameter data
      @sprites["#{key}"].send("#{k}=",data[m]) if @sprites["#{key}"].respond_to?(k)
    end
    @sprites["#{key}"].z = 40 if @sprites["#{key}"].z > 40 # caps Z value
    @sprites["#{key}"].bottom! if @sprites["#{key}"].bitmap && !data.try_key?(:ox) && !data.try_key?(:oy) # sets the anchor to bottom middle, unless otherwise defined
    # check if should apply color
    if data.try_key?(:colorize)
      self.setColor(@sprites["bg"], @sprites["#{key}"]) if data[:colorize] == true
      @sprites["#{key}"].colorize(data[:colorize], data[:colorize].alpha) if data[:colorize].is_a?(Color)
    end
    @sprites["#{key}"].memorize_bitmap # saves the sprite's bitmap just in case
  end
  #-----------------------------------------------------------------------------
  # loads the animated elements for PWT styled base lights
  #-----------------------------------------------------------------------------
  def drawSpinLights
    for i in 0...2
      @sprites["sLight#{i}"] = SpriteEBDX.new(@viewport)
      @sprites["sLight#{i}"].default!
      @sprites["sLight#{i}"].setBitmap("Graphics/EBDX/Battlebacks/elements/lightDecor",1)
      @sprites["sLight#{i}"].z = 1
      @sprites["sLight#{i}"].center!
      @sprites["sLight#{i}"].zx = 1
      @sprites["sLight#{i}"].zy = 0.35
    end
  end
  #-----------------------------------------------------------------------------
  # elements for stage lights style A
  #-----------------------------------------------------------------------------
  def drawLightsA(img = true)
    lgt = img.is_a?(String) ? img : "lightA"
    for i in 0...4
      @sprites["aLight#{i}"] = Sprite.new(@viewport)
      @sprites["aLight#{i}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/#{lgt}")
      @sprites["aLight#{i}"].ex = [183, 135, 70, 0][i]
      @sprites["aLight#{i}"].ey = [-2, -15, -15, -16][i]
      @sprites["aLight#{i}"].param = [0.8, 1, 1.25, 1.4][i]
      @sprites["aLight#{i}"].z = [10, 10, 18, 18][i]
      @sprites["aLight#{i}"].opacity = [0.5, 0.7, 0.9, 1][i]*255
      @sprites["aLight#{i}"].end_x = [0.5, 0.7, 0.9, 1][i]
      @sprites["aLight#{i}"].speed = 1*(1 + rand(4))
      @sprites["aLight#{i}"].toggle = 1
    end
  end
  #-----------------------------------------------------------------------------
  # elements for stage lights style B
  #-----------------------------------------------------------------------------
  def drawLightsB(img = true)
    lgt = img.is_a?(String) ? img : "lightB"
    for i in 0...6
      @sprites["bLight#{i}"] = Sprite.new(@viewport)
      @sprites["bLight#{i}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/#{lgt}")
      @sprites["bLight#{i}"].ox = @sprites["bLight#{i}"].bitmap.width/2
      @sprites["bLight#{i}"].ex = [40,104,146,210,256,320][i]
      @sprites["bLight#{i}"].ey = -8
      @sprites["bLight#{i}"].mirror = (i%2 == 1)
      @sprites["bLight#{i}"].speed = (2 + rand(3))*3
      @sprites["bLight#{i}"].memorize_bitmap
      @sprites["bLight#{i}"].param = 1
      @sprites["bLight#{i}"].z = 3
      @sprites["bLight#{i}"].opacity = 0
    end
  end
  #-----------------------------------------------------------------------------
  # elements for ambiental lights style C
  #-----------------------------------------------------------------------------
  def drawLightsC
    for i in 0...8
      c = [2,3,1,3,2,3,1,3]; l = (100-rand(51))/100.0
      @sprites["cLight#{i}"] = Sprite.new(@viewport)
      @sprites["cLight#{i}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/lightC#{c[i]}")
      @sprites["cLight#{i}"].ex = [-2,10,40,60,100,118,160,168][i]
      @sprites["cLight#{i}"].ey = [-22,-46,-8,-32,-14,-40,0,-58][i]
      @sprites["cLight#{i}"].param = 1
      @sprites["cLight#{i}"].z = 10
      @sprites["cLight#{i}"].opacity = l*255
      @sprites["cLight#{i}"].end_x = l
      @sprites["cLight#{i}"].speed = 1*(1 + rand(4))
      @sprites["cLight#{i}"].toggle = 1
    end
  end
  #-----------------------------------------------------------------------------
  # adds subtle water animation to terrain
  #-----------------------------------------------------------------------------
  def drawWater
    for i in 0...2
      @sprites["water#{i}"] = ScrollingSprite.new(@viewport)
      @sprites["water#{i}"].setBitmap("Graphics/EBDX/Battlebacks/elements/water#{i}")
      @sprites["water#{i}"].speed = 0.5
      @sprites["water#{i}"].direction = 1
      @sprites["water#{i}"].ex = 0
      @sprites["water#{i}"].ey = 146
      @sprites["water#{i}"].param = 1
      @sprites["water#{i}"].mirror = i > 0
    end
  end
  #-----------------------------------------------------------------------------
  # draws vacuum waves
  #-----------------------------------------------------------------------------
  def vacuumWaves(img = true)
    lgt = img.is_a?(String) ? img : "dark004"
    for j in 0...3
      @sprites["ec#{j}"] = Sprite.new(@viewport)
      @sprites["ec#{j}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/#{lgt}")
      @sprites["ec#{j}"].center!
      @sprites["ec#{j}"].ex = 234
      @sprites["ec#{j}"].ey = 128
      @sprites["ec#{j}"].param = 1.5
      @sprites["ec#{j}"].opacity = 0
      @sprites["ec#{j}"].z = 1
    end
  end
  #-----------------------------------------------------------------------------
  # draws bubble stream
  #-----------------------------------------------------------------------------
  def bubbleStream(img = true)
    lgt = img.is_a?(String) ? img : "bubble"
    for j in 0...18
      @sprites["bubble#{j}"] = Sprite.new(@viewport)
      @sprites["bubble#{j}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/#{lgt}")
      @sprites["bubble#{j}"].center!
      @sprites["bubble#{j}"].default!
      @sprites["bubble#{j}"].ey = -32
      @sprites["bubble#{j}"].opacity = 0
    end
  end
  #-----------------------------------------------------------------------------
  # check if sky should be tinted lighter
  #-----------------------------------------------------------------------------
  def weatherTint?
    for wth in [:Hail, :Sun, :HarshSun]
      return true if @battle.pbWeather == wth
    end
    return false
  end
  #-----------------------------------------------------------------------------
  # sunny weather handlers
  #-----------------------------------------------------------------------------
  def drawSunny
    @sunny = true
    # refresh daylight tinting
    if @weather != @battle.pbWeather
      @weather = @battle.pbWeather
      self.daylightTint
    end
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all += 16 if @sprites["sky"].tone.all < 96
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 16 if @sprites["cloud#{i}"].tone.all < 96
      end
    end
    # draw particles
    for i in 0...3
      next if @sprites["w_sunny#{i}"]
      @sprites["w_sunny#{i}"] = Sprite.new(@viewport)
      @sprites["w_sunny#{i}"].z = 100
      @sprites["w_sunny#{i}"].bitmap = pbBitmap("Graphics/EBDX/Animations/Weather/ray001")
      @sprites["w_sunny#{i}"].oy = @sprites["w_sunny#{i}"].bitmap.height/2
      @sprites["w_sunny#{i}"].angle = 290 + [-10, 32, 10][i]
      @sprites["w_sunny#{i}"].zoom_x = 0
      @sprites["w_sunny#{i}"].zoom_y = 0
      @sprites["w_sunny#{i}"].opacity = 0
      @sprites["w_sunny#{i}"].x = [-2, 20, 10][i]
      @sprites["w_sunny#{i}"].y = [-4, -24, -2][i]
    end
  end
  def deleteSunny
    @sunny = false
    # refresh daylight tinting
    if @weather != @battle.pbWeather
      @weather = @battle.pbWeather
      self.daylightTint
    end
    # apply sky tone
    if @sprites["sky"] && !weatherTint?
      @sprites["sky"].tone.all -= 4 if @sprites["sky"].tone.all > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 4 if @sprites["cloud#{i}"].tone.all > 0
      end
    end
    for j in 0...3
      next if !@sprites["w_sunny#{j}"]
      @sprites["w_sunny#{j}"].dispose
      @sprites.delete("w_sunny#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # sandstorm weather handlers
  #-----------------------------------------------------------------------------
  def drawSandstorm
    for j in 0...2
      next if @sprites["w_sand#{j}"]
      @sprites["w_sand#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["w_sand#{j}"].default!
      @sprites["w_sand#{j}"].z = 100
      @sprites["w_sand#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/sandstorm#{j}")
      @sprites["w_sand#{j}"].speed = 32
      @sprites["w_sand#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def deleteSandstorm
    for j in 0...2
      next if !@sprites["w_sand#{j}"]
      @sprites["w_sand#{j}"].dispose
      @sprites.delete("w_sand#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # fog weather handlers
  #-----------------------------------------------------------------------------
  def drawFog
    for j in 0...2
      next if @sprites["w_fog#{j}"]
      @sprites["w_fog#{j}"] = ScrollingSprite.new(@viewport)
      @sprites["w_fog#{j}"].default!
      @sprites["w_fog#{j}"].z = 100
      @sprites["w_fog#{j}"].setBitmap("Graphics/EBDX/Animations/Weather/fog#{j}", false, true)
      @sprites["w_fog#{j}"].speed = 2 - j
      @sprites["w_fog#{j}"].min_o = 105
      @sprites["w_fog#{j}"].max_o = 205
      @sprites["w_fog#{j}"].opacity = 205
      @sprites["w_fog#{j}"].direction = j == 0 ? 1 : -1
    end
  end
  def deleteFog
    for j in 0...2
      next if !@sprites["w_fog#{j}"]
      @sprites["w_fog#{j}"].dispose
      @sprites.delete("w_fog#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # snow weather handlers
  #-----------------------------------------------------------------------------
  def drawSnow
    for j in 0...72
      next if @sprites["w_snow#{j}"]
      @sprites["w_snow#{j}"] = Sprite.new(@viewport)
      @sprites["w_snow#{j}"].bitmap = pbBitmap("Graphics/EBDX/Battlebacks/elements/snow")
      @sprites["w_snow#{j}"].center!
      @sprites["w_snow#{j}"].default!
      @sprites["w_snow#{j}"].opacity = 0
    end
  end
  def deleteSnow
    for j in 0...72
      next if !@sprites["w_snow#{j}"]
      @sprites["w_snow#{j}"].dispose
      @sprites.delete("w_snow#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # rain weather handlers
  #-----------------------------------------------------------------------------
  def drawRain
    harsh = @battle.pbWeather == :HEAVYRAIN
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all -= 2 if @sprites["sky"].tone.all > -16
      @sprites["sky"].tone.gray += 16 if @sprites["sky"].tone.gray < 128
      for i in 0..1
        @sprites["cloud#{i}"].tone.all -= 2 if @sprites["cloud#{i}"].tone.all > -16
        @sprites["cloud#{i}"].tone.gray += 16 if @sprites["cloud#{i}"].tone.gray < 128
      end
    end
    for j in 0...72
      next if @sprites["w_rain#{j}"]
      @sprites["w_rain#{j}"] = Sprite.new(@viewport)
      @sprites["w_rain#{j}"].create_rect(harsh ? 28 : 24, 3, Color.white)
      @sprites["w_rain#{j}"].default!
      @sprites["w_rain#{j}"].angle = 80
      @sprites["w_rain#{j}"].oy = 2
      @sprites["w_rain#{j}"].opacity = 0
    end
  end
  def deleteRain
    # apply sky tone
    if @sprites["sky"]
      @sprites["sky"].tone.all += 2 if @sprites["sky"].tone.all < 0
      @sprites["sky"].tone.gray -= 16 if @sprites["sky"].tone.gray > 0
      for i in 0..1
        @sprites["cloud#{i}"].tone.all += 2 if @sprites["cloud#{i}"].tone.all < 0
        @sprites["cloud#{i}"].tone.gray -= 16 if @sprites["cloud#{i}"].tone.gray > 0
      end
    end
    for j in 0...72
      next if !@sprites["w_rain#{j}"]
      @sprites["w_rain#{j}"].dispose
      @sprites.delete("w_rain#{j}")
    end
  end
  #-----------------------------------------------------------------------------
  # strong wind weather handlers
  #-----------------------------------------------------------------------------
  def drawStrongWind; @strongwind = true; end
  def deleteStrongWind; @strongwind = false; end
  #-----------------------------------------------------------------------------
  # records the proper positioning
  #-----------------------------------------------------------------------------
  def adjustMetrics
    @scale = EliteBattle::ROOM_SCALE
    data = EliteBattle.get(:battlerMetrics)
    for j in -2...data.keys.length
      @sprites["battler#{j}"] = Sprite.new(@viewport)
      @sprites["battler#{j}"].default!
      @sprites["trainer_#{j}"] = Sprite.new(@viewport)
      @sprites["trainer_#{j}"].default!
      i = j; i = 0 if j == -2; i = 1 if j == -1
      for param in [:X, :Y, :Z]
        next if !data[i].has_key?(param)
        dat = data[i][param]
        n = [@battle.pbMaxSize - 1, @battle.pbMaxSize(j%2) - 1].min - i/2
        m = (@battle.opponent ? [@battle.pbMaxSize - 1, @battle.pbMaxSize(j%2) - 1, (@battle.opponent.length - 1)].min : n) - i/2
        n = dat.length - 1 if n >= dat.length
        m = dat.length - 1 if m >= dat.length
        n = 0 if n < 0; m = 0 if m < 0
        k = [:X, :Y].include?(param) ? "E#{param.to_s}" : param.to_s
        @sprites["battler#{j}"].send("#{k.downcase}=", dat[n])
        @sprites["trainer_#{j}"].send("#{k.downcase}=", dat[m])
      end
    end
  end
  #-----------------------------------------------------------------------------
  # disposes of all sprites
  #-----------------------------------------------------------------------------
  def dispose
    pbDisposeSpriteHash(@sprites)
    @disposed = true
  end
  #-----------------------------------------------------------------------------
  # checks if room is disposed
  #-----------------------------------------------------------------------------
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  # compatibility layers for scene transitions
  #-----------------------------------------------------------------------------
  def color; return @viewport.color; end
  def color=(val); @viewport.color = val; end
  def visible; return @sprites["bg"].visible; end
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  #-----------------------------------------------------------------------------
  # compatibility layer for move animations with backgrounds
  #-----------------------------------------------------------------------------
  def defocus
    return if @sprites["bg"].z < 0
    for key in @sprites.keys
      @sprites[key].z -= 100
    end
    @focused = false
  end
  def focus
    return if @sprites["bg"].z >= 0
    for key in @sprites.keys
      @sprites[key].z += 100
    end
    @focused = true
  end
  #-----------------------------------------------------------------------------
  # battler sprite positioning
  #-----------------------------------------------------------------------------
  def delta; return Graphics.frame_rate/40.0; end
  def scale_y; return @sprites["bg"].zoom_y; end
  def battler(i); return @sprites["battler#{i}"]; end
  def trainer(i); return @sprites["trainer_#{i}"]; end
  def stageLightPos(j)
    data = EliteBattle.get(:battlerMetrics)
    return if data.nil?
    x = 0; y = 0
    for param in [:X, :Y, :Z]
      next if data[j].nil? || !data[j].has_key?(param)
      dat = data[j][param]
      x = dat[0] if param == :X
      y = dat[0] if param == :Y
    end
    return x, y
  end
  def spoof(vector, index = 1)
    target = self.battler(index)
    bx, by = @scene.vector.spoof(vector)
    # updates to the spatial warping with respect to the scene vector
    dx, dy = @scene.vector.spoof(@defaultvector)
    bzoom_x = @scale*((bx - vector[0])*1.0/(dx - @defaultvector[0])*1.0)**0.6
    bzoom_y = @scale*((by - vector[1])*1.0/(dy - @defaultvector[1])*1.0)**0.6
    x = bx - (@sprites["bg"].ox - target.ex)*bzoom_x
    y = by - (@sprites["bg"].oy - target.ey)*bzoom_y
    return x, y
  end
  #-----------------------------------------------------------------------------
  # change out the data hash and redraw battle environment
  #-----------------------------------------------------------------------------
  def reconfigure(data, transition = Color.black, userIndex = 0, targetIndex = 0, hitnum = 0)
    data = getConst(EnvironmentEBDX, data) if data.is_a?(Symbol)
    # failsafe
    if !data.is_a?(Hash)
      EliteBattle.log.warn("Unable to load battle environment for: #{data}")
      return
    end
    # if with transition
    if transition.is_a?(Symbol)
      @queued = data.clone
      return EliteBattle.playCommonAnimation(transition, @scene, userIndex, targetIndex, hitnum)
    end
    # construct transition animation object
    trans = Sprite.new(@viewport) if !transition.nil?
    if transition.is_a?(Color)
      trans.create_rect(@viewport.width, @viewport.height, transition)
    elsif transition.is_a?(String)
      trans.bitmap = pbBitmap(transition)
    end
    trans.opacity = 0  if !transition.nil?
    # push elements out of focus
    self.defocus
    # fade through transition element
    if !transition.nil?
      8.times { trans.opacity += 32; @scene.wait }
    end
    # set new data Hash
    @data = data.clone
    self.refresh(data)
    self.defocus
    # fade through transition element
    if !transition.nil?
      8.times { trans.opacity -= 32; @scene.wait }
    end
    self.focus
    # dispose of transition element
    trans.dispose if !transition.nil?
  end
  #-----------------------------------------------------------------------------
  # change out data hash (simple)
  #-----------------------------------------------------------------------------
  def configure
    return if @queued.nil? || !@queued.is_a?(Hash)
    @data = @queued.clone
    self.refresh(@data)
    @queued = nil
  end
  #-----------------------------------------------------------------------------
  # reset to original data hash
  #-----------------------------------------------------------------------------
  def reset(transition = Color.black)
    self.reconfigure(@backup, transition)
  end
  #-----------------------------------------------------------------------------
end
