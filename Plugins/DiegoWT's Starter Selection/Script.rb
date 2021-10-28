#===============================================================================
# DiegoWT's Starter Selection script
#===============================================================================
class DiegoWTsStarterSelection
  def initialize(pkmn1,pkmn2,pkmn3)
    @select = nil
    @frame = 0
    @selframe = 0 
    @endscene = 0
    @pkmn1 = pkmn1; @pkmn2 = pkmn2; @pkmn3 = pkmn3
    
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    
    @sprites["starterbg"] = IconSprite.new(0,0,@viewport)  
    @sprites["starterbg"].opacity = 0
    if StarterSelSettings::INSTYLE == 2 # Set up graphics' style to match BW or HGSS style
      @sprites["starterbg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg_custom")
      @sprites["starterbg"].color = Color.new(255,255,255,105)
    else
      @sprites["starterbg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg")
    end
    
    if StarterSelSettings::TYPE2COLOR # Set up graphics for the background to match with the type color
      @sprites["type1"] = IconSprite.new(0,0,@viewport)    
      @sprites["type1"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/typegradient")
      @sprites["type1"].opacity = 0
      @sprites["type2"] = IconSprite.new(0,0,@viewport)    
      @sprites["type2"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/typegradient")
      @sprites["type2"].mirror = true
      @sprites["type2"].opacity = 0
    else
      @sprites["typebg"] = IconSprite.new(0,0,@viewport)    
      @sprites["typebg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg_custom") if StarterSelSettings::INSTYLE == 2
      @sprites["typebg"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/starterbg")        if StarterSelSettings::INSTYLE == 1
      @sprites["typebg"].color = Color.new(-255,-255,-255,25)                                        if StarterSelSettings::INSTYLE == 1
      @sprites["typebg"].opacity = 0
    end
    
    @sprites["base"] = IconSprite.new(0,138,@viewport)    
    @sprites["base"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/base")
    @sprites["base"].opacity = 0
    
    @sprites["shadow_1"] = IconSprite.new(56,212,@viewport)
    @sprites["shadow_2"] = IconSprite.new(210,212,@viewport)
    @sprites["shadow_3"] = IconSprite.new(364,212,@viewport)
    for i in 1..3
      @sprites["shadow_#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/shadow")
      @sprites["shadow_#{i}"].opacity=0
    end
    
    @sprites["ball_1"] = IconSprite.new(102,188,@viewport)
    @sprites["ball_2"] = IconSprite.new(256,188,@viewport)
    @sprites["ball_3"] = IconSprite.new(410,188,@viewport)
    for i in 1..3
      @sprites["ball_#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/ball#{i}")
      @sprites["ball_#{i}"].ox=@sprites["ball_#{i}"].bitmap.width/2
      @sprites["ball_#{i}"].oy=@sprites["ball_#{i}"].bitmap.height/2
      @sprites["ball_#{i}"].opacity = 0
    end
    
    @sprites["select"] = IconSprite.new(102,188,@viewport) # Outline selection
    @sprites["select"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/sel")
    @sprites["select"].ox = @sprites["select"].bitmap.width/2
    @sprites["select"].oy = @sprites["select"].bitmap.height/2
    @sprites["select"].visible = false
    @sprites["selection"] = IconSprite.new(224,32,@viewport) # Hand selection
    @sprites["selection"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/select")
    @sprites["selection"].visible = false
    
    @sprites["ballbase"] = IconSprite.new(0,0,@viewport)
    @sprites["ballbase"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/ballbase")
    if StarterSelSettings::STARTERCZ >= 1
      @sprites["ballbase"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/ballbase2x")
      @sprites["ballbase"].zoom_x = 0.5
      @sprites["ballbase"].zoom_y = 0.5
    end
    @sprites["ballbase"].ox = @sprites["ballbase"].bitmap.width/2
    @sprites["ballbase"].oy = @sprites["ballbase"].bitmap.height/2
    @sprites["ballbase"].opacity = 0
    
    @data = {}
    @data["pkmn_1"] = Pokemon.new(@pkmn1,StarterSelSettings::STARTERL)
    @data["pkmn_1"].form = StarterSelSettings::STARTER1F
    @data["pkmn_2"] = Pokemon.new(@pkmn2,StarterSelSettings::STARTERL)
    @data["pkmn_2"].form = StarterSelSettings::STARTER2F
    @data["pkmn_3"] = Pokemon.new(@pkmn3,StarterSelSettings::STARTERL)
    @data["pkmn_3"].form = StarterSelSettings::STARTER3F
    for i in 1..3
      @sprites["pkmn_#{i}"] = PokemonSprite.new(@viewport)
      @sprites["pkmn_#{i}"].setOffset(PictureOrigin::Center)
      @pokemon = @data["pkmn_#{i}"]
      @data.values.each { |pkmn| 
        if pkmn.form != 0
          pkmn.calc_stats
          pkmn.reset_moves
        end
      }
      @sprites["pkmn_#{i}"].setPokemonBitmap(@pokemon)
      @sprites["pkmn_#{i}"].opacity = 0
      @sprites["pkmn_#{i}"].z = 2
    end
    @sprites["pkmn_1"].x = StarterSelSettings::STARTER1X + 256
    @sprites["pkmn_1"].y = StarterSelSettings::STARTER1Y + 148
    @sprites["pkmn_2"].x = StarterSelSettings::STARTER2X + 256
    @sprites["pkmn_2"].y = StarterSelSettings::STARTER2Y + 148
    @sprites["pkmn_3"].x = StarterSelSettings::STARTER3X + 256
    @sprites["pkmn_3"].y = StarterSelSettings::STARTER3Y + 148
    
    @sprites["textwnd"] = IconSprite.new(0,272,@viewport)
    if StarterSelSettings::INSTYLE == 2 # Checks for interface style
      @sprites["textwnd"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/window_bw")
    else
      @sprites["textwnd"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/window")
    end
    @sprites["textwnd"].opacity = 0
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].setSkin("Graphics/Windowskins/nil skin")
    if StarterSelSettings::INSTYLE == 2 # Checks for interface style
      @sprites["textbox"].baseColor = Color.new(255,255,255)
      @sprites["textbox"].shadowColor = Color.new(165,165,173)
    else
      @sprites["textbox"].baseColor = Color.new(82,82,90)
      @sprites["textbox"].shadowColor = Color.new(165,165,173)
    end
    @sprites["textbox"].letterbyletter = true
    @sprites["textbox"].text = _INTL("")
    pbSetSystemFont(@sprites["textbox"].contents)
    @oldMsgY = @sprites["textbox"].y
    
    for i in 1..2
      @sprites["choice#{i}"] = IconSprite.new(370,(i-1)*46+174,@viewport)
      if StarterSelSettings::INSTYLE == 2 # Checks for interface style
        @sprites["choice#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/choice_bw")
      else
        @sprites["choice#{i}"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/choice")
      end
      @sprites["choice#{i}"].src_rect = Rect.new((i-1)*140,0,140,48)
      @sprites["choice#{i}"].visible = false
    end
    @sprites["choicesel"] = IconSprite.new(370,174,@viewport)
    if StarterSelSettings::INSTYLE == 2 # Checks for interface style
      @sprites["choicesel"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/choice_bw")
    else
      @sprites["choicesel"].setBitmap("Graphics/Pictures/DiegoWT's Starter Selection/choice")
    end
    @sprites["choicesel"].src_rect = Rect.new(0,96,140,48)
    @sprites["choicesel"].visible = false
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay = @sprites["overlay"].bitmap
    pbSetSystemFont(@overlay)
    
    pbOpenScene
  end
 
  def pbOpenScene
    25.times do
      @sprites["starterbg"].opacity += 200/20
      @sprites["base"].opacity += 255/20
      @sprites["shadow_1"].opacity += 255/20
      @sprites["shadow_2"].opacity += 255/20
      @sprites["shadow_3"].opacity += 255/20
      @sprites["ball_1"].opacity += 255/20
      @sprites["ball_2"].opacity += 255/20
      @sprites["ball_3"].opacity += 255/20
      @sprites["textwnd"].opacity += 255/20
      pbWait(1)
    end
    @sprites["textbox"].text = _INTL("<ac>Choose a Pokémon.</ac>")
    pbStartChoosing
  end
  
  def pbAnimation
    if @frame < 4
      @sprites["ball_#{@select}"].x -= 2
      @sprites["ball_#{@select}"].angle += 2
      @sprites["shadow_#{@select}"].x -= 2
      @sprites["select"].x -= 2
      @sprites["select"].angle += 2
    elsif @frame >= 4 && @frame < 10
      @sprites["ball_#{@select}"].x += 2
      @sprites["ball_#{@select}"].angle -= 2
      @sprites["shadow_#{@select}"].x += 2
      @sprites["select"].x += 2
      @sprites["select"].angle -= 2
    elsif @frame >= 10 && @frame < 15
      @sprites["ball_#{@select}"].x -= 2
      @sprites["ball_#{@select}"].angle += 2
      @sprites["shadow_#{@select}"].x -= 2
      @sprites["select"].x -= 2
      @sprites["select"].angle += 2
    elsif @frame >= 15 && @frame < 16
      @sprites["ball_#{@select}"].x = @oldx
      @sprites["ball_#{@select}"].angle = 0
      @sprites["select"].x = @oldx
      @sprites["select"].angle = 0
      @sprites["shadow_#{@select}"].x = @oldx-46
    elsif @frame == 50
      @frame = 0
    end
    @frame += 1
    if @selframe < 15
      @sprites["selection"].y += 1
    elsif @selframe >= 15 && @selframe < 22
      @sprites["selection"].y -= 2
    elsif @selframe == 22
      @selframe = 0
    end
    @selframe += 1
    intensity = (Graphics.frame_count%40)*12
    intensity = 480-intensity if intensity>240
    @sprites["select"].opacity = intensity
  end
  
  def pbStartChoosing
    @x = [nil,102,256,410]
    @y = [nil,188,188,188]
    while @endscene == 0
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT) ||
        Input.trigger?(Input::ACTION) || Input.trigger?(Input::USE) ||
        Input.trigger?(Input::BACK)
        @select = 2
        @oldx = @sprites["ball_#{@select}"].x
        @frame = 0 
        pbPlayCursorSE
        @sprites["select"].visible = true
        @sprites["selection"].visible = true
        @sprites["select"].x = @x[@select]
        @sprites["select"].y = @y[@select]
        @sprites["selection"].x = @x[@select] - 28
        @sprites["selection"].y = @y[@select] - 154
        @sprites["select"].angle = 0
        pbChoosingScene
      end
    end
  end
  
  def pbChoosingScene
    @frameA = 0
    @framereset = 0
    @anim = 0
    while @endscene == 0
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      pbAnimation
      if Input.trigger?(Input::RIGHT) && @select < 3
        @oldsel = @select
        @select += 1
        @oldx = @sprites["ball_#{@select}"].x
        @frame = 0
        pbPlayCursorSE
        @sprites["ball_1"].x = 102 if @oldsel == 1
        @sprites["ball_2"].x = 256 if @oldsel == 2
        @sprites["ball_3"].x = 410 if @oldsel == 3
        @sprites["ball_#{@oldsel}"].angle = 0
        @sprites["shadow_1"].x = 56 if @oldsel == 1
        @sprites["shadow_2"].x = 210 if @oldsel == 2
        @sprites["shadow_3"].x = 364 if @oldsel == 3
        @sprites["select"].x = @x[@select]
        @sprites["select"].y = @y[@select]
        @selframe = 0
        @sprites["selection"].y = @y[@select] - 154
        @sprites["selection"].x = @x[@select] - 28
        @sprites["select"].angle = 0
      end
      if Input.trigger?(Input::LEFT) && @select > 1
        @oldsel = @select
        @select -= 1
        @oldx = @sprites["ball_#{@select}"].x
        @frame = 0
        pbPlayCursorSE
        @sprites["ball_1"].x = 102 if @oldsel == 1
        @sprites["ball_2"].x = 256 if @oldsel == 2
        @sprites["ball_3"].x = 410 if @oldsel == 3
        @sprites["ball_#{@oldsel}"].angle = 0
        @sprites["shadow_1"].x = 56 if @oldsel == 1
        @sprites["shadow_2"].x = 210 if @oldsel == 2
        @sprites["shadow_3"].x = 364 if @oldsel == 3
        @sprites["select"].x = @x[@select]
        @sprites["select"].y = @y[@select]
        @selframe = 0
        @sprites["selection"].y = @y[@select] - 154
        @sprites["selection"].x = @x[@select] - 28
        @sprites["select"].angle = 0
      end
      if Input.trigger?(Input::C)
        @pokemon = @data["pkmn_#{@select}"]
        pokemon=[@pkmn1,@pkmn2,@pkmn3]
        @pkmn_array = pokemon
        pbPlayDecisionSE
        pbChooseBall
      end
    end
  end
  
  def pbChoiceBoxes(switch)
    # When switch is 0, it will turn on the boxes; when 1, it will turn off
    if switch == 0
      for i in 1..2
        @sprites["choice#{i}"].src_rect = Rect.new((i-1)*140,0,140,48)
        @sprites["choice#{i}"].visible = true
      end
      @sprites["choice1"].src_rect = Rect.new(0,48,140,48)
      @sprites["choicesel"].visible = true
      @sprites["choicesel"].opacity = 255
      @sprites["overlay"].visible = true
      if StarterSelSettings::INSTYLE == 2 # Checks for interface style
        pbDrawTextPositions(@overlay,[
          ["YES",388,178,0,Color.new(255,255,255),Color.new(140,140,140),false,Graphics.width],
          ["NO",388,224,0,Color.new(255,255,255),Color.new(140,140,140),false,Graphics.width]])
      else
        pbDrawTextPositions(@overlay,[
          ["YES",442,184,2,Color.new(255,255,255),Color.new(74,74,74),true,Graphics.width],
          ["NO",442,230,2,Color.new(255,255,255),Color.new(74,74,74),true,Graphics.width]])
      end
      @choicesel = 1
    else switch == 1
      for i in 1..2
        @sprites["choice#{i}"].src_rect = Rect.new((i-1)*140,0,140,48)
        @sprites["choice#{i}"].visible = false
      end
      @sprites["choicesel"].y = 174
      @sprites["choicesel"].visible = false
      @sprites["overlay"].visible = false
      @sel = nil
    end
  end
  
  def pbTypeColor(type)
    # Organizing Type names and background colors
    case type
    when :NORMAL
      @type = "Normal"
      typeColor = Tone.new(95.25,88.5,63.0)
    when :FIGHTING
      @type = "Fighting"
      typeColor = Tone.new(126.75,37.5,31.5)
    when :FLYING
      @type = "Flying"
      typeColor = Tone.new(109.0,90.0,121.0)
    when :POISON
      @type = "Poison"
      typeColor = Tone.new(87.25,31.0,82.75)
    when :GROUND
      @type = "Ground"
      typeColor = Tone.new(108.0,91.0,43.0)
    when :ROCK
      @type = "Rock"
      typeColor = Tone.new(83.0,74.0,28.0)
    when :BUG
      @type = "Bug"
      typeColor = Tone.new(90.0,108.0,2.0)
    when :GHOST
      @type = "Ghost"
      typeColor = Tone.new(58.55,43.0,95.25)
    when :STEEL
      @type = "Steel"
      typeColor = Tone.new(79.5,79.5,79.5)
    when :QMARKS
      @type = "???"
      typeColor = Tone.new(63.0,95.25,79.5)
    when :FIRE
      @type = "Fire"
      typeColor = Tone.new(169.0,93.0,42.0)
    when :WATER
      @type = "Water"
      typeColor = Tone.new(42.0,96.0,169.0)
    when :GRASS
      @type = "Grass"
      typeColor = Tone.new(65.25,118.5,39.0)
    when :ELECTRIC
      @type = "Electric"
      typeColor = Tone.new(135.0,126.0,23.25)
    when :PSYCHIC
      @type = "Psychic"
      typeColor = Tone.new(128.25,51.75,96.0)
    when :ICE
      @type = "Ice"
      typeColor = Tone.new(55.5,102.75,102.75)
    when :DRAGON
      @type = "Dragon"
      typeColor = Tone.new(54.75,43.5,114.75)
    when :DARK
      @type = "Dark"
      typeColor = Tone.new(-23.0,-40.0,-56.0)
    when :FAIRY
      @type = "Fairy"
      typeColor = Tone.new(136.75,41.5,73.0)
    end
    return typeColor  if type = @pokemon.type1
    return type2Color = typeColor if type = @pokemon.type2
  end
  
  def pbChooseBall
    typeColor  = pbTypeColor(@pokemon.type1)
    type1 = @type 
    if @pokemon.type2 != @pokemon.type1 && StarterSelSettings::TYPE2COLOR
      type2Color = pbTypeColor(@pokemon.type2); type2 = @type 
    elsif StarterSelSettings::TYPE2COLOR
      type2Color = typeColor
    end
    
    if StarterSelSettings::TYPE2COLOR
      @sprites["type1"].tone  = typeColor
      @sprites["type2"].tone  = type2Color
    else
      @sprites["typebg"].tone = typeColor
    end
    
    @pkmnname = @pokemon.name
    @sprites["textbox"].y = @sprites["textbox"].y - 16
    if @pokemon.type2 != @pokemon.type1 && StarterSelSettings::TYPE2COLOR
      @sprites["textbox"].text = _INTL("<ac>Will you choose #{@pkmnname}, <br>the dual-type #{type1}/#{type2} Pokémon?</ac>")
    elsif StarterSelSettings::TYPE2COLOR
      @sprites["textbox"].text = _INTL("<ac>Will you choose #{@pkmnname}, <br>the #{type1}-type Pokémon?</ac>")
    else
      @sprites["textbox"].text = _INTL("<ac>Will you choose #{@pkmnname}, <br>the #{type1}-type Pokémon?</ac>")
    end
      
    @sprites["ballbase"].x = @x[@select]
    @sprites["ballbase"].y = @y[@select]
    @anim=0; @framereset=0; @frameA=0; zoom = StarterSelSettings::STARTERCZ - 0.5 if StarterSelSettings::STARTERCZ >= 1
    @sprites["select"].visible = false
    @sprites["selection"].visible = false
    20.times do
      pbUpdateSpriteHash(@sprites)
      pbAnimation if @frame < 16
      if StarterSelSettings::TYPE2COLOR
        @sprites["type1"].opacity += @sprites["starterbg"].opacity/18
        @sprites["type2"].opacity += @sprites["starterbg"].opacity/18 
      else
        @sprites["typebg"].opacity += @sprites["starterbg"].opacity/18
      end
      @sprites["ballbase"].opacity+=255/18
      @sprites["base"].opacity -= 105/10
      for i in 1..3
        @sprites["shadow_#{i}"].opacity -= 155/10
        @sprites["ball_#{i}"].opacity -= 105/10
      end
      pbWait(1)
    end
    20.times do
      pbUpdateSpriteHash(@sprites)
      @sprites["ballbase"].x += 154/20 if @select == 1
      @sprites["ballbase"].x -= 154/20 if @select == 3
      @sprites["base"].y += 40/20
      @sprites["ball_1"].y += 40/20
      @sprites["ball_2"].y += 40/20
      @sprites["ball_3"].y += 40/20
      @sprites["ballbase"].y -= 40/20
      @sprites["ballbase"].zoom_x += zoom/20 if StarterSelSettings::STARTERCZ >= 1
      @sprites["ballbase"].zoom_y += zoom/20 if StarterSelSettings::STARTERCZ >= 1
      pbWait(1)
    end
    2.times do
      pbUpdateSpriteHash(@sprites)
      @sprites["ballbase"].x += 6 if @select == 1
      @sprites["ballbase"].x -= 6 if @select == 3
      pbWait(1)
    end
    @sprites["ballbase"].x = @sprites["ball_2"].x if @select != 1
    GameData::Species.play_cry_from_species(@pkmn_array[@select-1]) if StarterSelSettings::STARTERCRY 
    10.times do
      pbUpdateSpriteHash(@sprites)
      @sprites["pkmn_#{@select}"].opacity += 255/10
      pbWait(1)
    end
    pbChoiceBoxes(0) # Turn on the choice boxes
    confirm = pbConfirm
    if confirm == 1
      @sprites["textbox"].visible = false
      $game_variables[7] = @select if $game_variables[7] == 0
      @endscene = 1
      pbCloseScene
      pbAddPokemon(@data["pkmn_#{@select}"],StarterSelSettings::STARTERL)
    else
      @sprites["textbox"].y = @oldMsgY
      @sprites["textbox"].text = _INTL("<ac>Choose a Pokémon.</ac>")
      10.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["pkmn_#{@select}"].opacity -= 255/10
        pbWait(1)
      end
      2.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["ballbase"].x -= 6 if @select == 1
        @sprites["ballbase"].x += 6 if @select == 3
        pbWait(1)
      end
      20.times do
        pbUpdateSpriteHash(@sprites)
        @sprites["ballbase"].x -= 154/20 if @select == 1
        @sprites["ballbase"].x += 154/20 if @select == 3
        @sprites["base"].y -= 40/20
        @sprites["ball_1"].y -= 40/20
        @sprites["ball_2"].y -= 40/20
        @sprites["ball_3"].y -= 40/20
        @sprites["ballbase"].y += 40/20
        @sprites["ballbase"].zoom_x -= zoom/20 if StarterSelSettings::STARTERCZ >= 1
        @sprites["ballbase"].zoom_y -= zoom/20 if StarterSelSettings::STARTERCZ >= 1
        pbWait(1)
      end
      @sprites["ballbase"].x = @sprites["ball_#{@select}"].x if @select != 1
      @sprites["select"].visible = true
      @sprites["selection"].visible = true
      20.times do
        pbUpdateSpriteHash(@sprites)
        if StarterSelSettings::TYPE2COLOR
          @sprites["type1"].opacity -= @sprites["starterbg"].opacity/18
          @sprites["type2"].opacity -= @sprites["starterbg"].opacity/18
        else
          @sprites["typebg"].opacity -= @sprites["starterbg"].opacity/18
        end
        @sprites["ballbase"].opacity-=255/18
        @sprites["base"].opacity += 105/10
        for i in 1..3
          @sprites["shadow_#{i}"].opacity += 155/10
          @sprites["ball_#{i}"].opacity += 105/10
        end
        pbWait(1)
      end
    end
  end
  
  def pbConfirm
    loop do
      intensity = (Graphics.frame_count%40)*12
      intensity = 480-intensity if intensity>240
      @sprites["choicesel"].opacity = intensity
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
      if Input.trigger?(Input::DOWN) && @choicesel != 2
        pbPlayCursorSE
        @choicesel += 1
        @sprites["choice1"].src_rect = Rect.new(0,0,140,48)
        @sprites["choice2"].src_rect = Rect.new(140,48,140,48)
        @sprites["choicesel"].y += 46
      end
      if Input.trigger?(Input::UP) && @choicesel != 1
        pbPlayCursorSE
        @choicesel -= 1
        @sprites["choice1"].src_rect = Rect.new(0,48,140,48)
        @sprites["choice2"].src_rect = Rect.new(140,0,140,48)
        @sprites["choicesel"].y -= 46
      end
      if Input.trigger?(Input::USE) && @choicesel == 1
        pbChoiceBoxes(1) # Turn off the choice boxes
        @sprites["choicesel"].opacity = 255
        pbPlayDecisionSE
        return 1
      end
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE) && @choicesel == 2
        pbChoiceBoxes(1) # Turn off the choice boxes
        pbPlayCancelSE
        @sprites["choicesel"].opacity = 255
        return
      end
    end
  end
  
  def pbCloseScene
    @sprites["base"].visible = false
    @sprites["shadow_1"].visible = false
    @sprites["shadow_2"].visible = false
    @sprites["shadow_3"].visible = false
    @sprites["ball_1"].visible = false
    @sprites["ball_2"].visible = false
    @sprites["ball_3"].visible = false
    @sprites["select"].visible = false
    @sprites["selection"].visible = false
    25.times do
      @sprites["starterbg"].opacity -= 255/20
      if StarterSelSettings::TYPE2COLOR
        @sprites["type1"].opacity -= 255/20
        @sprites["type2"].opacity -= 255/20
      else
        @sprites["typebg"].opacity -= 255/20
      end
      @sprites["ballbase"].opacity -= 255/20
      @sprites["pkmn_#{@select}"].opacity -= 255/20
      @sprites["textwnd"].opacity -= 255/20
      pbWait(1)
    end
    pbDisposeSpriteHash(@sprites)  
    @viewport.dispose    
  end
end