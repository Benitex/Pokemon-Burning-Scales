#===============================================================================
# Pokémon party buttons and menu
#===============================================================================
class PokemonPartyConfirmCancelSprite < SpriteWrapper
  attr_reader :selected

  def initialize(text,x,y,narrowbox=false,viewport=nil)
    super(viewport)
    @refreshBitmap = true
    @bgsprite = ChangelingSprite.new(0,0,viewport)
    if narrowbox
      @bgsprite.addBitmap("desel","Graphics/Pictures/Party/icon_cancel_narrow")
      @bgsprite.addBitmap("sel","Graphics/Pictures/Party/icon_cancel_narrow_sel")
    else
      @bgsprite.addBitmap("desel","Graphics/Pictures/Party/icon_cancel")
      @bgsprite.addBitmap("sel","Graphics/Pictures/Party/icon_cancel_sel")
    end
    @bgsprite.changeBitmap("desel")
    @overlaysprite = BitmapSprite.new(@bgsprite.bitmap.width,@bgsprite.bitmap.height,viewport)
    @overlaysprite.z = self.z+1
    pbSetSystemFont(@overlaysprite.bitmap)
    @yoffset = 8
    textpos = [[text,56,(narrowbox) ? -4 : 2,2,Color.new(248,248,248),Color.new(40,40,40)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    self.x = x
    self.y = y
  end

  def dispose
    @bgsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def selected=(value)
    if @selected!=value
      @selected = value
      refresh
    end
  end

  def refresh
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.changeBitmap((@selected) ? "sel" : "desel")
      @bgsprite.x     = self.x
      @bgsprite.y     = self.y
      @bgsprite.color = self.color
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyCancelSprite < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CANCEL"),398,328,false,viewport)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyConfirmSprite < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CONFIRM"),398,308,true,viewport)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyCancelSprite2 < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CANCEL"),398,346,true,viewport)
  end
end

#===============================================================================
#
#===============================================================================
class Window_CommandPokemonColor < Window_CommandPokemon
  def initialize(commands,width=nil)
    @colorKey = []
    for i in 0...commands.length
      if commands[i].is_a?(Array)
        @colorKey[i] = commands[i][1]
        commands[i] = commands[i][0]
      end
    end
    super(commands,width)
  end

  def drawItem(index,_count,rect)
    pbSetSystemFont(self.contents) if @starting
    rect = drawCursor(index,rect)
    base   = self.baseColor
    shadow = self.shadowColor
    if @colorKey[index] && @colorKey[index]==1
      base   = Color.new(0,80,160)
      shadow = Color.new(128,192,240)
    end
    pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,
       @commands[index],base,shadow)
  end
end

#===============================================================================
# Blank party panel
#===============================================================================
class PokemonPartyBlankPanel < SpriteWrapper
  attr_accessor :text

  def initialize(_pokemon,index,viewport=nil)
    super(viewport)
    self.x = (index % 2) * Graphics.width / 2
    self.y = 16 * (index % 2) + 96 * (index / 2)
    @panelbgsprite = AnimatedBitmap.new("Graphics/Pictures/Party/panel_blank")
    self.bitmap = @panelbgsprite.bitmap
    @text = nil
  end

  def dispose
    @panelbgsprite.dispose
    super
  end

  def selected; return false; end
  def selected=(value); end
  def preselected; return false; end
  def preselected=(value); end
  def switching; return false; end
  def switching=(value); end
  def refresh; end
end

#===============================================================================
# Pokémon party panel
#===============================================================================
class PokemonPartyPanel < SpriteWrapper
  attr_reader :pokemon
  attr_reader :active
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :text

  def initialize(pokemon,index,viewport=nil)
    super(viewport)
    @pokemon = pokemon
    @active = (index==0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
    self.x = (index % 2) * Graphics.width / 2
    self.y = 16 * (index % 2) + 96 * (index / 2)
    @panelbgsprite = ChangelingSprite.new(0,0,viewport)
    @panelbgsprite.z = self.z
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_round")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_round_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_round_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_round_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_round_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_rect")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_rect_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_rect_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_rect_swap_sel2")
    end
    @hpbgsprite = ChangelingSprite.new(0,0,viewport)
    @hpbgsprite.z = self.z+1
    @hpbgsprite.addBitmap("able","Graphics/Pictures/Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted","Graphics/Pictures/Party/overlay_hp_back_faint")
    @hpbgsprite.addBitmap("swap","Graphics/Pictures/Party/overlay_hp_back_swap")
    @ballsprite = ChangelingSprite.new(0,0,viewport)
    @ballsprite.z = self.z+1
    @ballsprite.addBitmap("desel","Graphics/Pictures/Party/icon_ball")
    @ballsprite.addBitmap("sel","Graphics/Pictures/Party/icon_ball_sel")
    @pkmnsprite = PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.setOffset(PictureOrigin::Center)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z+2
    @helditemsprite = HeldItemIconSprite.new(0,0,@pokemon,viewport)
    @helditemsprite.z = self.z+3
    @overlaysprite = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    @overlaysprite.z = self.z+4
    @hpbar    = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @statuses = AnimatedBitmap.new(_INTL("Graphics/Pictures/statuses"))
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end

  def dispose
    @panelbgsprite.dispose
    @hpbgsprite.dispose
    @ballsprite.dispose
    @pkmnsprite.dispose
    @helditemsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @hpbar.dispose
    @statuses.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def text=(value)
    if @text!=value
      @text = value
      @refreshBitmap = true
      refresh
    end
  end

  def pokemon=(value)
    @pokemon = value
    @pkmnsprite.pokemon = value if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.pokemon = value if @helditemsprite && !@helditemsprite.disposed?
    @refreshBitmap = true
    refresh
  end

  def selected=(value)
    if @selected!=value
      @selected = value
      refresh
    end
  end

  def preselected=(value)
    if @preselected!=value
      @preselected = value
      refresh
    end
  end

  def switching=(value)
    if @switching!=value
      @switching = value
      refresh
    end
  end

  def hp; return @pokemon.hp; end

  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
      if self.selected
        if self.preselected;     @panelbgsprite.changeBitmap("swapsel2")
        elsif @switching;        @panelbgsprite.changeBitmap("swapsel")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("faintedsel")
        else;                    @panelbgsprite.changeBitmap("ablesel")
        end
      else
        if self.preselected;     @panelbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("fainted")
        else;                    @panelbgsprite.changeBitmap("able")
        end
      end
      @panelbgsprite.x     = self.x
      @panelbgsprite.y     = self.y
      @panelbgsprite.color = self.color
    end
    if @hpbgsprite && !@hpbgsprite.disposed?
      @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length>0))
      if @hpbgsprite.visible
        if self.preselected || (self.selected && @switching); @hpbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?;                              @hpbgsprite.changeBitmap("fainted")
        else;                                                 @hpbgsprite.changeBitmap("able")
        end
        @hpbgsprite.x     = self.x+96
        @hpbgsprite.y     = self.y+50
        @hpbgsprite.color = self.color
      end
    end
    if @ballsprite && !@ballsprite.disposed?
      @ballsprite.changeBitmap((self.selected) ? "sel" : "desel")
      @ballsprite.x     = self.x+10
      @ballsprite.y     = self.y
      @ballsprite.color = self.color
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x        = self.x+60
      @pkmnsprite.y        = self.y+40
      @pkmnsprite.color    = self.color
      @pkmnsprite.selected = self.selected
    end
    if @helditemsprite && !@helditemsprite.disposed?
      if @helditemsprite.visible
        @helditemsprite.x     = self.x+62
        @helditemsprite.y     = self.y+48
        @helditemsprite.color = self.color
      end
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    if @refreshBitmap
      @refreshBitmap = false
      @overlaysprite.bitmap.clear if @overlaysprite.bitmap
      basecolor   = Color.new(248,248,248)
      shadowcolor = Color.new(40,40,40)
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos = []
      # Draw Pokémon name
      textpos.push([@pokemon.name,96,10,0,basecolor,shadowcolor])
      if !@pokemon.egg?
        if !@text || @text.length==0
          # Draw HP numbers
          textpos.push([sprintf("% 3d /% 3d",@pokemon.hp,@pokemon.totalhp),224,54,1,basecolor,shadowcolor])
          # Draw HP bar
          if @pokemon.hp>0
            w = @pokemon.hp*96*1.0/@pokemon.totalhp
            w = 1 if w<1
            w = ((w/2).round)*2
            hpzone = 0
            hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
            hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
            hprect = Rect.new(0,hpzone*8,w,8)
            @overlaysprite.bitmap.blt(128,52,@hpbar.bitmap,hprect)
          end
          # Draw status
          status = 0
          if @pokemon.fainted?
            status = GameData::Status::DATA.keys.length / 2
          elsif @pokemon.status != :NONE
            status = GameData::Status.get(@pokemon.status).id_number
          elsif @pokemon.pokerusStage == 1
            status = GameData::Status::DATA.keys.length / 2 + 1
          end
          status -= 1
          if status >= 0
            statusrect = Rect.new(0,16*status,44,16)
            @overlaysprite.bitmap.blt(78,68,@statuses.bitmap,statusrect)
          end
        end
        # Draw gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"),224,10,0,Color.new(0,112,248),Color.new(120,184,232)])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"),224,10,0,Color.new(232,32,16),Color.new(248,168,184)])
        end
        # Draw shiny icon
        if @pokemon.shiny?
          pbDrawImagePositions(@overlaysprite.bitmap,[[
             "Graphics/Pictures/shiny",80,48,0,0,16,16]])
        end
      end
      pbDrawTextPositions(@overlaysprite.bitmap,textpos)
      # Draw level text
      if !@pokemon.egg?
        pbDrawImagePositions(@overlaysprite.bitmap,[[
           "Graphics/Pictures/Party/overlay_lv",20,70,0,0,22,14]])
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@pokemon.level.to_s,42,57,0,basecolor,shadowcolor]
        ])
      end
      # Draw annotation text
      if @text && @text.length>0
        pbSetSystemFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@text,96,52,0,basecolor,shadowcolor]
        ])
      end
    end
    @refreshing = false
  end

  def update
    super
    @panelbgsprite.update if @panelbgsprite && !@panelbgsprite.disposed?
    @hpbgsprite.update if @hpbgsprite && !@hpbgsprite.disposed?
    @ballsprite.update if @ballsprite && !@ballsprite.disposed?
    @pkmnsprite.update if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.update if @helditemsprite && !@helditemsprite.disposed?
  end
end

#===============================================================================
# Pokémon party visuals
#===============================================================================
class PokemonParty_Scene
  attr_accessor :allowBox

  def pbStartScene(party,starthelptext,annotations=nil,multiselect=false)
    @sprites = {}
    @party = party
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
    addBackgroundPlane(@sprites,"partybg","Party/bg",@viewport)
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new(starthelptext)
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible  = true
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbSetHelpText(starthelptext)
    # Add party Pokémon sprites
    for i in 0...Settings::MAX_PARTY_SIZE
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text = annotations[i] if annotations
    end
    if @multiselect
      @sprites["pokemon#{Settings::MAX_PARTY_SIZE}"] = PokemonPartyConfirmSprite.new(@viewport)
      @sprites["pokemon#{Settings::MAX_PARTY_SIZE + 1}"] = PokemonPartyCancelSprite2.new(@viewport)
    else
      @sprites["pokemon#{Settings::MAX_PARTY_SIZE}"] = PokemonPartyCancelSprite.new(@viewport)
    end
    # Select first Pokémon
    @activecmd = 0
    @sprites["pokemon0"].selected = true
    pbFadeInAndShow(@sprites) { update }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    @sprites["helpwindow"].visible = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      self.update
      if @sprites["messagebox"].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites["messagebox"].pausing?
          @sprites["messagebox"].resume
        end
      else
        if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
          break
        end
      end
    end
    @sprites["messagebox"].visible = false
    @sprites["helpwindow"].visible = true
  end

  def pbDisplayConfirm(text)
    ret = -1
    @sprites["messagebox"].text    = text
    @sprites["messagebox"].visible = true
    @sprites["helpwindow"].visible = false
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])) {
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @sprites["messagebox"].height
      cmdwindow.z = @viewport.z+1
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@sprites["messagebox"].busy?
        cmdwindow.update
        self.update
        if !@sprites["messagebox"].busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
            ret = (cmdwindow.index==0)
            break
          end
        end
      end
    }
    @sprites["messagebox"].visible = false
    @sprites["helpwindow"].visible = true
    return ret
  end

  def pbShowCommands(helptext,commands,index=0)
    ret = -1
    helpwindow = @sprites["helpwindow"]
    helpwindow.visible = true
    using(cmdwindow = Window_CommandPokemonColor.new(commands)) {
      cmdwindow.z     = @viewport.z+1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      helpwindow.resizeHeightToFit(helptext,Graphics.width-cmdwindow.width)
      helpwindow.text = helptext
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        self.update
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def pbSetHelpText(helptext)
    helpwindow = @sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    helpwindow.text = helptext
    helpwindow.width = 398
    helpwindow.visible = true
  end

  def pbHasAnnotations?
    return @sprites["pokemon0"].text!=nil
  end

  def pbAnnotate(annot)
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].text = (annot) ? annot[i] : nil
    end
  end

  def pbSelect(item)
    @activecmd = item
    numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
    for i in 0...numsprites
      @sprites["pokemon#{i}"].selected = (i==@activecmd)
    end
  end

  def pbChooseNumber(helptext, maximum, initnum)
    oldtext = @sprites["helpwindow"].text
    ret = UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { update }
    pbSetHelpText(oldtext)
    return ret
  end

  def pbPreSelect(item)
    @activecmd = item
  end

  def pbSwitchBegin(oldid,newid)
    pbSEPlay("GUI party switch")
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    timeTaken = Graphics.frame_rate*4/10
    distancePerFrame = (Graphics.width/(2.0*timeTaken)).ceil
    timeTaken.times do
      oldsprite.x += (oldid&1)==0 ? -distancePerFrame : distancePerFrame
      newsprite.x += (newid&1)==0 ? -distancePerFrame : distancePerFrame
      Graphics.update
      Input.update
      self.update
    end
  end

  def pbSwitchEnd(oldid,newid)
    pbSEPlay("GUI party switch")
    oldsprite = @sprites["pokemon#{oldid}"]
    newsprite = @sprites["pokemon#{newid}"]
    oldsprite.pokemon = @party[oldid]
    newsprite.pokemon = @party[newid]
    timeTaken = Graphics.frame_rate*4/10
    distancePerFrame = (Graphics.width/(2.0*timeTaken)).ceil
    timeTaken.times do
      oldsprite.x -= (oldid&1)==0 ? -distancePerFrame : distancePerFrame
      newsprite.x -= (newid&1)==0 ? -distancePerFrame : distancePerFrame
      Graphics.update
      Input.update
      self.update
    end
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
    pbRefresh
  end

  def pbClearSwitching
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
  end

  def pbSummary(pkmnid,inbattle=false)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene,inbattle)
    screen.pbStartScreen(@party,pkmnid)
    yield if block_given?
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbChooseItem(bag)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).can_hold? })
      yield if block_given?
    }
    return ret
  end

  def pbUseItem(bag,pokemon)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item|
        itm = GameData::Item.get(item)
        next false if !pbCanUseOnPokemon?(itm)
        if itm.is_machine?
          move = itm.move
          next false if pokemon.hasMove?(move) || !pokemon.compatible_with_move?(move)
        end
        next true
      })
      yield if block_given?
    }
    return ret
  end

  def pbChoosePokemon(switching=false,initialsel=-1,canswitch=0)
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].preselected = (switching && i==@activecmd)
      @sprites["pokemon#{i}"].switching   = switching
    end
    @activecmd = initialsel if initialsel>=0
    pbRefresh
    loop do
      Graphics.update
      Input.update
      self.update
      oldsel = @activecmd
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN)
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP)
      if key>=0
        @activecmd = pbChangeSelection(key,@activecmd)
      end
      if @activecmd!=oldsel   # Changing selection
        pbPlayCursorSE
        numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected = (i==@activecmd)
        end
      end
      cancelsprite = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 1 : 0)
      if Input.trigger?(Input::ACTION) && canswitch==1 && @activecmd!=cancelsprite
        pbPlayDecisionSE
        return [1,@activecmd]
      elsif Input.trigger?(Input::ACTION) && canswitch==2
        return -1
      elsif Input.trigger?(Input::SPECIAL) &&
        GameData::Item.exists?(:POKEMONBOXLINK) &&
        $PokemonBag.pbHasItem?(:POKEMONBOXLINK) &&
        @allowBox                               &&
        (Settings::POKEMON_BOX_LINK_SWITCH < 0  ||
         !$game_switches[Settings::POKEMON_BOX_LINK_SWITCH])
         pbPlayDecisionSE
         pbFadeOutIn(99999) {
           scene = PokemonStorageScene.new
           screen = PokemonStorageScreen.new(scene,$PokemonStorage)
           screen.pbStartScreen(0)
         }
         pbHardRefresh
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE if !switching
        return -1
      elsif Input.trigger?(Input::USE)
        if @activecmd==cancelsprite
          (switching) ? pbPlayDecisionSE : pbPlayCloseMenuSE
          return -1
        else
          pbPlayDecisionSE
          return @activecmd
        end
      end
    end
  end

  def pbChangeSelection(key,currentsel)
    numsprites = Settings::MAX_PARTY_SIZE + ((@multiselect) ? 2 : 1)
    case key
    when Input::LEFT
      begin
        currentsel -= 1
      end while currentsel > 0 && currentsel < @party.length && !@party[currentsel]
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length - 1
      end
      currentsel = numsprites - 1 if currentsel < 0
    when Input::RIGHT
      begin
        currentsel += 1
      end while currentsel < @party.length && !@party[currentsel]
      if currentsel == @party.length
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel == numsprites
        currentsel = 0
      end
    when Input::UP
      if currentsel >= Settings::MAX_PARTY_SIZE
        currentsel -= 1
        while currentsel > 0 && currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
          currentsel -= 1
        end
      else
        begin
          currentsel -= 2
        end while currentsel > 0 && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length-1
      end
      currentsel = numsprites - 1 if currentsel < 0
    when Input::DOWN
      if currentsel >= Settings::MAX_PARTY_SIZE - 1
        currentsel += 1
      else
        currentsel += 2
        currentsel = Settings::MAX_PARTY_SIZE if currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel >= numsprites
        currentsel = 0
      end
    end
    return currentsel
  end

  def pbHardRefresh
    oldtext = []
    lastselected = -1
    for i in 0...Settings::MAX_PARTY_SIZE
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected = @party.length-1 if lastselected>=@party.length
    lastselected = 0 if lastselected<0
    for i in 0...Settings::MAX_PARTY_SIZE
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonPartyPanel.new(@party[i],i,@viewport)
      else
        @sprites["pokemon#{i}"] = PokemonPartyBlankPanel.new(@party[i],i,@viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
    pbSelect(lastselected)
  end

  def pbRefresh
    for i in 0...Settings::MAX_PARTY_SIZE
      sprite = @sprites["pokemon#{i}"]
      if sprite
        if sprite.is_a?(PokemonPartyPanel)
          sprite.pokemon = sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
  end

  def pbRefreshSingle(i)
    sprite = @sprites["pokemon#{i}"]
    if sprite
      if sprite.is_a?(PokemonPartyPanel)
        sprite.pokemon = sprite.pokemon
      else
        sprite.refresh
      end
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
end

#===============================================================================
# Pokémon party mechanics
#===============================================================================
class PokemonPartyScreen
  attr_reader :scene
  attr_reader :party

  def initialize(scene,party)
    @scene = scene
    @party = party
  end

  def pbStartScene(helptext,_numBattlersOut,annotations=nil)
    @scene.pbStartScene(@party,helptext,annotations)
  end

  def pbChoosePokemon(helptext=nil)
    @scene.pbSetHelpText(helptext) if helptext
    return @scene.pbChoosePokemon
  end

  def pbPokemonGiveScreen(item)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid = @scene.pbChoosePokemon
    ret = false
    if pkmnid>=0
      ret = pbGiveItemToPokemon(item,@party[pkmnid],self,pkmnid)
    end
    pbRefreshSingle(pkmnid)
    @scene.pbEndScene
    return ret
  end

  def pbPokemonGiveMailScreen(mailIndex)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid = @scene.pbChoosePokemon
    if pkmnid>=0
      pkmn = @party[pkmnid]
      if pkmn.hasItem? || pkmn.mail
        pbDisplay(_INTL("This Pokémon is holding an item. It can't hold mail."))
      elsif pkmn.egg?
        pbDisplay(_INTL("Eggs can't hold mail."))
      else
        pbDisplay(_INTL("Mail was transferred from the Mailbox."))
        pkmn.mail = $PokemonGlobal.mailbox[mailIndex]
        pkmn.item = pkmn.mail.item
        $PokemonGlobal.mailbox.delete_at(mailIndex)
        pbRefreshSingle(pkmnid)
      end
    end
    @scene.pbEndScene
  end

  def pbEndScene
    @scene.pbEndScene
  end

  def pbUpdate
    @scene.update
  end

  def pbHardRefresh
    @scene.pbHardRefresh
  end

  def pbRefresh
    @scene.pbRefresh
  end

  def pbRefreshSingle(i)
    @scene.pbRefreshSingle(i)
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbDisplayConfirm(text)
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return @scene.pbChooseNumber(helptext, maximum, initnum)
  end

  def pbShowCommands(helptext,commands,index=0)
    return @scene.pbShowCommands(helptext,commands,index)
  end

  # Checks for identical species
  def pbCheckSpecies(array)   # Unused
    for i in 0...array.length
      for j in i+1...array.length
        return false if array[i].species==array[j].species
      end
    end
    return true
  end

  # Checks for identical held items
  def pbCheckItems(array)   # Unused
    for i in 0...array.length
      next if !array[i].hasItem?
      for j in i+1...array.length
        return false if array[i].item==array[j].item
      end
    end
    return true
  end

  def pbSwitch(oldid,newid)
    if oldid!=newid
      @scene.pbSwitchBegin(oldid,newid)
      tmp = @party[oldid]
      @party[oldid] = @party[newid]
      @party[newid] = tmp
      @scene.pbSwitchEnd(oldid,newid)
    end
  end

  def pbChooseMove(pokemon,helptext,index=0)
    movenames = []
    for i in pokemon.moves
      next if !i || !i.id
      if i.total_pp<=0
        movenames.push(_INTL("{1} (PP: ---)",i.name))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})",i.name,i.pp,i.total_pp))
      end
    end
    return @scene.pbShowCommands(helptext,movenames,index)
  end

  def pbRefreshAnnotations(ableProc)   # For after using an evolution stone
    return if !@scene.pbHasAnnotations?
    annot = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    @scene.pbAnnotate(annot)
  end

  def pbClearAnnotations
    @scene.pbAnnotate(nil)
  end

  def pbPokemonMultipleEntryScreenEx(ruleset)
    annot = []
    statuses = []
    ordinals = [_INTL("INELIGIBLE"), _INTL("NOT ENTERED"), _INTL("BANNED")]
    positions = [_INTL("FIRST"), _INTL("SECOND"), _INTL("THIRD"), _INTL("FOURTH"),
                 _INTL("FIFTH"), _INTL("SIXTH"), _INTL("SEVENTH"), _INTL("EIGHTH"),
                 _INTL("NINTH"), _INTL("TENTH"), _INTL("ELEVENTH"), _INTL("TWELFTH")]
    for i in 0...Settings::MAX_PARTY_SIZE
      if i < positions.length
        ordinals.push(positions[i])
      else
        ordinals.push("#{i + 1}th")
      end
    end
    return nil if !ruleset.hasValidTeam?(@party)
    ret = nil
    addedEntry = false
    for i in 0...@party.length
      statuses[i] = (ruleset.isPokemonValid?(@party[i])) ? 1 : 2
    end
    for i in 0...@party.length
      annot[i] = ordinals[statuses[i]]
    end
    @scene.pbStartScene(@party,_INTL("Choose Pokémon and confirm."),annot,true)
    loop do
      realorder = []
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j]==i+3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
        statuses[realorder[i]] = i+3
      end
      for i in 0...@party.length
        annot[i] = ordinals[statuses[i]]
      end
      @scene.pbAnnotate(annot)
      if realorder.length==ruleset.number && addedEntry
        @scene.pbSelect(Settings::MAX_PARTY_SIZE)
      end
      @scene.pbSetHelpText(_INTL("Choose Pokémon and confirm."))
      pkmnid = @scene.pbChoosePokemon
      addedEntry = false
      if pkmnid == Settings::MAX_PARTY_SIZE   # Confirm was chosen
        ret = []
        for i in realorder; ret.push(@party[i]); end
        error = []
        break if ruleset.isValid?(ret,error)
        pbDisplay(error[0])
        ret = nil
      end
      break if pkmnid<0   # Cancelled
      cmdEntry   = -1
      cmdNoEntry = -1
      cmdSummary = -1
      commands = []
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry = commands.length]   = _INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry = commands.length] = _INTL("No Entry")
      end
      pkmn = @party[pkmnid]
      commands[cmdSummary = commands.length]   = _INTL("Summary")
      commands[commands.length]                = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands) if pkmn
      if cmdEntry>=0 && command==cmdEntry
        if realorder.length>=ruleset.number && ruleset.number>0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.",ruleset.number))
        else
          statuses[pkmnid] = realorder.length+3
          addedEntry = true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry>=0 && command==cmdNoEntry
        statuses[pkmnid] = 1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbChooseAblePokemon(ableProc,allowIneligible=false)
    annot = []
    eligibility = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      eligibility.push(elig)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret = -1
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
    loop do
      @scene.pbSetHelpText(
         (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid<0
      if !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret = pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbChooseAblePokemonHelp(helptext,ableProc,allowIneligible=false)
    annot = []
    eligibility = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      eligibility.push(elig)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret = -1
    @scene.pbSetHelpText(helptext)
    @scene.pbAnnotate(annot)
    loop do
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid < 0
      if !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret = pkmnid
        break
      end
    end
    pbClearAnnotations
    return ret
  end

  def pbChooseTradablePokemon(ableProc,allowIneligible=false)
    annot = []
    eligibility = []
    for pkmn in @party
      elig = ableProc.call(pkmn)
      elig = false if pkmn.egg? || pkmn.shadowPokemon?
      eligibility.push(elig)
      annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret = -1
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
    loop do
      @scene.pbSetHelpText(
         (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid<0
      if !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret = pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbPokemonScreen
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      @scene.allowBox = true if @scene.respond_to?(:allowBox)
      pkmnid = @scene.pbChoosePokemon(false,-1,1)
      @scene.allowBox = false if @scene.respond_to?(:allowBox)
      break if (pkmnid.is_a?(Numeric) && pkmnid<0) || (pkmnid.is_a?(Array) && pkmnid[1]<0)
      if pkmnid.is_a?(Array) && pkmnid[0]==1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        pkmnid = @scene.pbChoosePokemon(true,-1,2)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
        next
      end
      pkmn = @party[pkmnid]
      commands   = []
      cmdSummary = -1
      cmdDebug   = -1
      cmdMoves   = [-1] * pkmn.numMoves
      cmdSwitch  = -1
      cmdMail    = -1
      cmdItem    = -1
      # Build the commands
      commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      if !pkmn.egg?
        # Check for hidden moves and add any that were found
        pkmn.moves.each_with_index do |m, i|
          if [:MILKDRINK, :SOFTBOILED].include?(m.id) ||
             HiddenMoveHandlers.hasHandler(m.id)
            commands[cmdMoves[i] = commands.length] = [m.name, 1]
          end
        end
      end
      commands[cmdSwitch = commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
        if pkmn.mail
          commands[cmdMail = commands.length]     = _INTL("Mail")
        else
          commands[cmdItem = commands.length]     = _INTL("Item")
        end
      end
      commands[commands.length]                   = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand = false
      cmdMoves.each_with_index do |cmd, i|
        next if cmd < 0 || cmd != command
        havecommand = true
        if [:MILKDRINK, :SOFTBOILED].include?(pkmn.moves[i].id)
          amt = [(pkmn.totalhp/5).floor,1].max
          if pkmn.hp<=amt
            pbDisplay(_INTL("Not enough HP..."))
            break
          end
          @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            movename = pkmn.moves[i].name
            if pkmnid==oldpkmnid
              pbDisplay(_INTL("{1} can't use {2} on itself!",pkmn.name,movename))
            elsif newpkmn.egg?
              pbDisplay(_INTL("{1} can't be used on an Egg!",movename))
            elsif newpkmn.hp==0 || newpkmn.hp==newpkmn.totalhp
              pbDisplay(_INTL("{1} can't be used on that Pokémon.",movename))
            else
              pkmn.hp -= amt
              hpgain = pbItemRestoreHP(newpkmn,amt)
              @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
              pbRefresh
            end
            break if pkmn.hp<=amt
          end
          @scene.pbSelect(oldpkmnid)
          pbRefresh
          break
        elsif pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
          if pbConfirmUseHiddenMove(pkmn,pkmn.moves[i].id)
            @scene.pbEndScene
            if pkmn.moves[i].id == :FLY
              scene = PokemonRegionMap_Scene.new(-1,false)
              screen = PokemonRegionMapScreen.new(scene)
              ret = screen.pbStartFlyScreen
              if ret
                $PokemonTemp.flydata=ret
                return [pkmn,pkmn.moves[i].id]
              end
              @scene.pbStartScene(@party,
                 (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
              break
            end
            return [pkmn,pkmn.moves[i].id]
          end
        end
      end
      next if havecommand
      if cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
      elsif cmdMail>=0 && command==cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail(pkmn.mail,pkmn)
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
        when 1   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        end
      elsif cmdItem>=0 && command==cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? &&
                                                                         !GameData::Item.get(pkmn.item).is_mail?
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem>=0 && command==cmdUseItem   # Use
          item = @scene.pbUseItem($PokemonBag,pkmn) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            if pbGiveItemToPokemon(item,pkmn,self,pkmnid)
              pbRefreshSingle(pkmnid)
            end
          end
        elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
          item = pkmn.item
          itemname = item.name
          @scene.pbSetHelpText(_INTL("Move {1} to where?",itemname))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            break if pkmnid==oldpkmnid
            if newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.item = item
              pkmn.item = nil
              @scene.pbClearSwitching
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif GameData::Item.get(newpkmn.item).is_mail?
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem = newpkmn.item
              newitemname = newitem.name
              if newitem == :LEFTOVERS
                pbDisplay(_INTL("{1} is already holding some {2}.\1",newpkmn.name,newitemname))
              elsif newitemname.starts_with_vowel?
                pbDisplay(_INTL("{1} is already holding an {2}.\1",newpkmn.name,newitemname))
              else
                pbDisplay(_INTL("{1} is already holding a {2}.\1",newpkmn.name,newitemname))
              end
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.item = item
                pkmn.item = newitem
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end

#===============================================================================
# Open the party screen
#===============================================================================
def pbPokemonScreen
  pbFadeOutIn {
    sscene = PokemonParty_Scene.new
    sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
    sscreen.pbPokemonScreen
  }
end

#===============================================================================
# Choose a Pokémon in the party
#===============================================================================
# Choose a Pokémon/egg from the party.
# Stores result in variable _variableNumber_ and the chosen Pokémon's name in
# variable _nameVarNumber_; result is -1 if no Pokémon was chosen
def pbChoosePokemon(variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  chosen = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    if ableProc
      chosen = screen.pbChooseAblePokemon(ableProc,allowIneligible)
    else
      screen.pbStartScene(_INTL("Choose a Pokémon."),false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end

def pbChooseNonEggPokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc { |pkmn| !pkmn.egg? })
end

def pbChooseAblePokemon(variableNumber,nameVarNumber)
  pbChoosePokemon(variableNumber,nameVarNumber,proc { |pkmn| !pkmn.egg? && pkmn.hp>0 })
end

# Same as pbChoosePokemon, but prevents choosing an egg or a Shadow Pokémon.
def pbChooseTradablePokemon(variableNumber,nameVarNumber,ableProc=nil,allowIneligible=false)
  chosen = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    if ableProc
      chosen=screen.pbChooseTradablePokemon(ableProc,allowIneligible)
    else
      screen.pbStartScene(_INTL("Choose a Pokémon."),false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end

def pbChoosePokemonForTrade(variableNumber,nameVarNumber,wanted)
  wanted = GameData::Species.get(wanted).species
  pbChooseTradablePokemon(variableNumber,nameVarNumber,proc { |pkmn|
    next pkmn.species==wanted
  })
end
