#===============================================================================
# Main body to handle the the construction and animation of title screen
#===============================================================================
# Main title screen script
# handles the logic of constructing and animating the title screen visuals
class ModularTitleScreen
  # class constructor
  # additively adds new visual elements based on the presence of valid symbol
  # entries in the ModularTitle::MODIFIERS array
  def initialize
    # defines viewport
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    # defines sprite hash
    @sprites = {}
    @intro = nil
    @currentFrame = 0
    @mods = ModularTitle::MODIFIERS
    @mods = ["background5", "logo:sparkle", "overlay:static004", "effect1"] if defined?(firstApr?) && firstApr?
    bg = "BG0"
    backdrop = "nil"
    bg_selected = false
    i = 0; o = 0; m = 0
    for mod in @mods
      arg = mod.to_s.upcase
      x = "nil"; y = "nil"; z = "nil"; zoom = "nil"; file = "nil"; speed="nil"
      #-------------------------------------------------------------------------
      # setting up background
      # uses first available background element
      # if no background modifier has been defined, defaults to stock Essentials
      if arg.include?("BACKGROUND:") # loads specific BG graphic
        next if bg_selected
        cmd = arg.split("_").compact
        backdrop = "\"" + cmd[0].gsub("BACKGROUND:","") + "\""
        bg_selected = true
      elsif arg.include?("BACKGROUND") # loads modifier as object
        next if bg_selected
        cmd = arg.split("_").compact
        s = "BG" + cmd[0].gsub("BACKGROUND","")
        if eval("defined?(MTS_Element_#{s})")
          bg = s
          bg_selected = true
        end
      #-------------------------------------------------------------------------
      # setting up intro animation
      # uses first available element
      elsif arg.include?("INTRO:")
        next if !@intro.nil?
        cmd = arg.split("_").compact
        @intro = cmd[0].gsub("INTRO:","")
      #-------------------------------------------------------------------------
      # setting up background overlay
      # multiple overlays can be added
      # order in which they are defined matters for their Z index
      elsif arg.include?("OVERLAY:") # loads specific overlay graphic
        cmd = arg.split("_").compact
        file = cmd[0].gsub("OVERLAY:","")
        # applies positioning modifiers
        for j in 1...cmd.length
          next if cmd.length < 2
          if cmd[j].include?("Z")
            z = cmd[j].gsub("Z","").to_i
          end
        end
        z = nil if z == "nil"
        @sprites["ol#{o}"] = MTS_Element_OLX.new(@viewport,file,z)
        o += 1
      elsif arg.include?("OVERLAY")
        cmd1 = mod.split("_").compact
        cmd2 = cmd1[0].split(":").compact
        s = "OL" + cmd2[0].upcase.gsub("OVERLAY","")
        f = cmd2.length > 1 ? ("\"" + cmd2[1] + "\"") : "nil"
        # applies positioning modifiers
        for j in 1...cmd1.length
          next if cmd1.length < 2
          if cmd1[j].upcase.include?("Z")
            z = cmd1[j].upcase.gsub("Z","").to_i
          elsif cmd1[j].upcase.include?("S")
            speed = cmd1[j].upcase.gsub("S","").to_i
          end
        end
        if eval("defined?(MTS_Element_#{s})") # loads modifier as object
          @sprites["ol#{o}"] = eval("MTS_Element_#{s}.new(@viewport,#{f},#{z},#{speed})")
          o += 1
        end
      #---------------------------------------------------------------------------
      # setting up additional particle effects
      # multiple overlays can be added
      # order in which they are defined matters for their Z index
      elsif arg.include?("EFFECT")
        cmd = arg.split("_").compact
        s = "FX" + cmd[0].gsub("EFFECT","")
        # applies positioning modifiers
        for j in 1...cmd.length
          next if cmd.length < 2
          if cmd[j].include?("X")
            x = cmd[j].gsub("X","")
          elsif cmd[j].include?("Y")
            y = cmd[j].gsub("Y","")
          elsif cmd[j].include?("Z")
            z = cmd[j].gsub("Z","")
          end
        end
        # loads the sprite class
        if eval("defined?(MTS_Element_#{s})") # loads modifier as object
          @sprites["fx#{i}"] = eval("MTS_Element_#{s}.new(@viewport,#{x},#{y},#{z})")
          i += 1
        end
      #---------------------------------------------------------------------------
      # setting up additional particle effects
      # multiple overlays can be added
      # order in which they are defined matters for their Z index
      elsif arg.include?("MISC")
        cmd = mod.split("_").compact
        mfx = cmd[0].split(":").compact
        s = "MX" + mfx[0].upcase.gsub("MISC","")
        file = "\"" + mfx[1] + "\"" if mfx.length > 1
        # applies positioning modifiers
        for j in 1...cmd.length
          next if cmd.length < 2
          if cmd[j].upcase.include?("X")
            x = cmd[j].upcase.gsub("X","")
          elsif cmd[j].upcase.include?("Y")
            y = cmd[j].upcase.gsub("Y","")
          elsif cmd[j].upcase.include?("Z")
            z = cmd[j].upcase.gsub("Z","")
          elsif cmd[j].upcase.include?("S")
            zoom = cmd[j].upcase.gsub("S","")
          end
        end
        # loads the sprite class
        if eval("defined?(MTS_Element_#{s})") # loads modifier as object
          @sprites["mx#{m}"] = eval("MTS_Element_#{s}.new(@viewport,#{x},#{y},#{z},#{zoom},#{file})")
          m += 1
        end
      end
    end
    @sprites["bg"] = eval("MTS_Element_#{bg}.new(@viewport,#{backdrop})")
    #---------------------------------------------------------------------------
    # setting up game logo
    @sprites["logo"] = MTS_Element_Logo.new(@viewport)
    @sprites["logo"].position
    #---------------------------------------------------------------------------
    # setting up gstart splash text
    @sprites["start"] = Sprite.new(@viewport)
    @sprites["start"].bitmap = pbBitmap("Graphics/MODTS/start")
    @sprites["start"].center!
    @sprites["start"].x = @viewport.rect.width/2
    @sprites["start"].x = ModularTitle::START_POS[0] if ModularTitle::START_POS[0].is_a?(Numeric)
    @sprites["start"].y = @viewport.rect.height*0.85
    @sprites["start"].y = ModularTitle::START_POS[1] if ModularTitle::START_POS[1].is_a?(Numeric)
    @sprites["start"].z = 999
    @sprites["start"].visible = false
    @fade = 8
  end
  # trigger for playing the intro animation
  def intro
    if eval("defined?(MTS_INTRO_ANIM#{@intro})")
      intro = eval("MTS_INTRO_ANIM#{@intro}.new(@viewport,@sprites)")
    else
      intro = MTS_INTRO_ANIM.new(@viewport,@sprites)
    end
    @currentFrame = intro.currentFrame
    @sprites["start"].visible = true
  end
  # main update for all the visual elements
  def updateElements
    for key in @sprites.keys
      @sprites[key].update if @sprites[key].respond_to?(:update)
    end
    @sprites["start"].opacity -= @fade
    @fade *= -1 if @sprites["start"].opacity <= 0 || @sprites["start"].opacity >= 255
  end
  # update for title screen functionality
  def update
    @currentFrame += 1
    self.updateElements
    if !@totalFrames.nil? && @totalFrames >= 0 && @currentFrame >= @totalFrames
      self.restart
    end
  end
  # disposes of all visual elements
  def dispose
    for key in @sprites.keys
      @sprites[key].dispose
    end
    @viewport.dispose
  end
  # plays appropriate BGM
  def playBGM
    #---------------------------------------------------------------------------
    # setting up BGM
    # uses first available BGM modifier
    # if no BGM modifier has been defined, defaults to stock system
    bgm = nil
    for mod in @mods
      arg = mod.to_s.upcase
      if arg.include?("BGM:") # loads specific BG graphic
        bgm = arg.gsub("BGM:","")
        break
      end
    end
    # loads data
    bgm = $data_system.title_bgm.name if bgm.nil?
    @totalFrames = (getPlayTime("Audio/BGM/"+bgm).floor - 1) * Graphics.frame_rate
    pbBGMPlay(bgm)
  end
  # function to restart the game when BGM times out
  def restart
    pbBGMStop(0)
    51.times do
      @viewport.tone.red-=5
      @viewport.tone.green-=5
      @viewport.tone.blue-=5
      self.updateElements
      Graphics.update
    end
    raise Reset.new
  end
end
#===============================================================================
