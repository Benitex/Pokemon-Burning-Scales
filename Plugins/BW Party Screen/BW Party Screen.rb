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
# Changed color of text
    textpos = [[text,56,(narrowbox) ? -4 : 0,2,Color.new(255,255,255),Color.new(132,132,132)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    self.x = x
    self.y = y
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyCancelSprite < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
# Changed Cancel button position
    super(_INTL("CANCEL"),378,328,false,viewport)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyConfirmSprite < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    # Changed Confirm  button position
    super(_INTL("CONFIRM"),378,308,true,viewport)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPartyCancelSprite2 < PokemonPartyConfirmCancelSprite
  def initialize(viewport=nil)
    # Changed Cancel button position
    super(_INTL("CANCEL"),378,346,true,viewport)
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
    if PARTY_B2W2_STYLE
      @panelbgsprite = AnimatedBitmap.new("Graphics/Pictures/Party/panel_blank_B2W2")
    else
      @panelbgsprite = AnimatedBitmap.new("Graphics/Pictures/Party/panel_blank")
    end
    self.bitmap = @panelbgsprite.bitmap
    @text = nil
  end
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
    if PARTY_B2W2_STYLE
      if @active   # Rounded panel
        @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_round_B2W2")
        @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_round_sel_B2W2")
        @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_round_faint_B2W2")
        @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_round_faint_sel_B2W2")
        @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_round_swap_B2W2")
        @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_round_swap_sel_B2W2")
        @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_round_swap_sel2_B2W2")
      else   # Rectangular panel
        @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_rect_B2W2")
        @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_rect_sel_B2W2")
        @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_rect_faint_B2W2")
        @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_rect_faint_sel_B2W2")
        @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_rect_swap_B2W2")
        @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_rect_swap_sel_B2W2")
        @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_rect_swap_sel2_B2W2")
      end
    else
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
    end
    @hpbgsprite = ChangelingSprite.new(0,0,viewport)
    @hpbgsprite.z = self.z+1
    if PARTY_B2W2_STYLE
      @hpbgsprite.addBitmap("able","Graphics/Pictures/Party/overlay_hp_back_B2W2")
      @hpbgsprite.addBitmap("fainted","Graphics/Pictures/Party/overlay_hp_back_faint_B2W2")
      @hpbgsprite.addBitmap("swap","Graphics/Pictures/Party/overlay_hp_back_swap_B2W2")
      @ballsprite = ChangelingSprite.new(0,0,viewport)
    else
      @hpbgsprite.addBitmap("able","Graphics/Pictures/Party/overlay_hp_back")
      @hpbgsprite.addBitmap("fainted","Graphics/Pictures/Party/overlay_hp_back_faint")
      @hpbgsprite.addBitmap("swap","Graphics/Pictures/Party/overlay_hp_back_swap")
      @ballsprite = ChangelingSprite.new(0,0,viewport)
    end
    @ballsprite.z = self.z+1
    # Removed the balls from summary
    #    @ballsprite.addBitmap("desel","Graphics/Pictures/Party/icon_ball")
    #    @ballsprite.addBitmap("sel","Graphics/Pictures/Party/icon_ball_sel")
    @pkmnsprite = PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.setOffset(PictureOrigin::Center)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z+2
    #---------------------------------------------------------------------------
    # ZUD - Dynamax Icons
    # Updated to ZUD Plugin by Shashu-Greninja
    #---------------------------------------------------------------------------
    _ZUD_DynamaxSize if defined?(Settings::ZUD_COMPAT)
    #---------------------------------------------------------------------------
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
      #-------------------------------------------------------------------------
      # ZUD - Dynamax Icons
      # Updated to ZUD Plugin by Shashu-Greninja
      #-------------------------------------------------------------------------
      _ZUD_DynamaxColor if defined?(Settings::ZUD_COMPAT)
      #-------------------------------------------------------------------------
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
      # Changed color of text
      basecolor   = Color.new(255,255,255)
      shadowcolor = Color.new(132,132,132)
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
            if PARTY_B2W2_STYLE
              @overlaysprite.bitmap.blt(128,54,@hpbar.bitmap,hprect)
            else
              @overlaysprite.bitmap.blt(128,52,@hpbar.bitmap,hprect)
            end
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
      # Changed color of gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"),228,10,0,Color.new(0,239,255),Color.new(0,107,99)])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"),228,10,0,Color.new(231,57,57),Color.new(115,33,49)])
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
        if PARTY_B2W2_STYLE
          pbDrawImagePositions(@overlaysprite.bitmap,[[
             "Graphics/Pictures/Party/overlay_lv",20,72,0,0,22,14]])
        else
          pbDrawImagePositions(@overlaysprite.bitmap,[[
             "Graphics/Pictures/Party/overlay_lv",20,70,0,0,22,14]])
        end
        pbSetSmallFont(@overlaysprite.bitmap)
        if PARTY_B2W2_STYLE
          pbDrawTextPositions(@overlaysprite.bitmap,[
            [@pokemon.level.to_s,42,59,0,basecolor,shadowcolor]
          ])
        else
          pbDrawTextPositions(@overlaysprite.bitmap,[
            [@pokemon.level.to_s,42,57,0,basecolor,shadowcolor]
          ])
        end
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
end

#===============================================================================
# Pokémon party visuals
#===============================================================================
class PokemonParty_Scene
  def pbStartScene(party,starthelptext,annotations=nil,multiselect=false)
    @sprites = {}
    @party = party
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
    if PARTY_B2W2_STYLE
      addBackgroundPlane(@sprites,"partybg","Party/bg_B2W2",@viewport)
    else
      addBackgroundPlane(@sprites,"partybg","Party/bg",@viewport)
    end
    @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
    @sprites["messagebox"].viewport       = @viewport
    @sprites["messagebox"].visible        = false
    # Changed the Windows Box Skin
    @sprites["messagebox"].setSkin("Graphics/Windowskins/bw choice")
    @sprites["messagebox"].letterbyletter = true
    pbBottomLeftLines(@sprites["messagebox"],2)
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new(starthelptext)
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible  = true
    # Changed the Windows Box Skin
    @sprites["helpwindow"].setSkin("Graphics/Windowskins/bw choice")
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

  def pbSetHelpText(helptext)
    helpwindow = @sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    helpwindow.text = helptext
    # Changed help window width
    helpwindow.width = 378
    helpwindow.visible = true
  end
end
