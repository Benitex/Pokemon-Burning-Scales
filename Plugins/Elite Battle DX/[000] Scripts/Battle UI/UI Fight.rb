#===============================================================================
#  Fight Menu functionality part
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  main fight menu override
  #-----------------------------------------------------------------------------
  def pbFightMenu(idxBattler, megaEvoPossible = false)
    # refresh current UI
    battler = @battle.battlers[idxBattler]
    self.clearMessageWindow
    @fightWindow.battler = battler
    @fightWindow.megaButton if megaEvoPossible && @battle.pbCanMegaEvolve?(idxBattler)
    # last chosen move
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
      moveIndex = @lastMove[idxBattler]
    end
    @fightWindow.index = (battler.moves[moveIndex].id != 0) ? moveIndex : 0
    # setup button bitmaps
    @fightWindow.generateButtons
    # play UI animation
    @sprites["dataBox_#{idxBattler}"].selected = true
    pbSEPlay("EBDX/SE_Zoom4", 50)
    @fightWindow.showPlay
    loop do
      oldIndex = @fightWindow.index
      # General update
      self.updateWindow(@fightWindow)
      # Update selected command
      if (Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT))
        @fightWindow.index = [0, 1, 2, 3][[1, 0, 3, 2].index(@fightWindow.index)]
        @fightWindow.index = (@fightWindow.nummoves - 1) if @fightWindow.index < 0
        @fightWindow.index = 0 if @fightWindow.index > (@fightWindow.nummoves - 1)
      elsif (Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN))
        @fightWindow.index = [0, 1, 2, 3][[2, 3, 0, 1].index(@fightWindow.index)]
        @fightWindow.index = 0 if @fightWindow.index < 0
        @fightWindow.index = (@fightWindow.nummoves - 1) if @fightWindow.index > (@fightWindow.nummoves - 1)
      elsif Input.trigger?(Input::LEFT) && @fightWindow.index < 4
        if @fightWindow.index > 0
          @fightWindow.index -= 1
        else
          @fightWindow.index = @fightWindow.nummoves - 1
          @fightWindow.refreshpos = true
        end
      elsif Input.trigger?(Input::RIGHT) && @fightWindow.index < 4
        if @fightWindow.index < (@fightWindow.nummoves - 1)
          @fightWindow.index += 1
        else
          @fightWindow.index = 0
        end
      end
      # play SE
      pbSEPlay("EBDX/SE_Select1") if @fightWindow.index != oldIndex
      # Actions
      if Input.trigger?(Input::C)                                               # Confirm choice
        pbSEPlay("EBDX/SE_Select2")
        break if yield @fightWindow.index
      elsif Input.trigger?(Input::B)                                            # Cancel fight menu
        pbPlayCancelSE
        break if yield -1
      elsif Input.trigger?(Input::A)                                            # Toggle Mega Evolution
        if megaEvoPossible
            @fightWindow.megaButtonTrigger
            pbSEPlay("EBDX/SE_Select3")
          end
          break if yield -2
      end
    end
    # reset parameters
    self.pbResetParams if @ret > -1
    # hide window
    @fightWindow.hidePlay
    # unselect databoxes
    self.pbDeselectAll
    # set last used move
    @lastMove[idxBattler] = @fightWindow.index
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Fight Menu (Next Generation)
#  UI ovarhaul
#===============================================================================
class FightWindowEBDX
  attr_accessor :index
  attr_accessor :battler
  attr_accessor :refreshpos
  attr_reader :nummoves
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' index: %s>', @index)
    return str
  end
  #-----------------------------------------------------------------------------
  #  constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport = nil, battle = nil, scene = nil)
    @viewport = viewport
    @battle = battle
    @scene = scene
    @index = 0
    @oldindex = -1
    @over = false
    @refreshpos = false
    @battler = nil
    @nummoves = 0

    @opponent = nil
    @player = nil
    @opponent = @battle.battlers[1] if !@battle.doublebattle?
    @player = @battle.battlers[0] if !@battle.doublebattle?

    @path = "Graphics/EBDX/Pictures/UI/"
    self.applyMetrics

    @buttonBitmap = pbBitmap(@path + @cmdImg)
    @typeBitmap = pbBitmap(@path + @typImg)
    @catBitmap = pbBitmap(@path + @catImg)

    @background = Sprite.new(@viewport)
    @background.create_rect(@viewport.width,64,Color.new(0,0,0,150))
    @background.bitmap = pbBitmap(@path + @barImg) if !@barImg.nil?
    @background.y = Graphics.height - @background.bitmap.height
    @background.z = 100

    @megaButton = Sprite.new(@viewport)
    @megaButton.bitmap = pbBitmap(@path + @megaImg)
    @megaButton.z = 101
    @megaButton.src_rect.width /= 2
    @megaButton.center!
    @megaButton.x = 30
    @megaButton.y = @viewport.height - @background.bitmap.height/2 + 100

    @sel = SpriteSheet.new(@viewport,4)
    @sel.setBitmap(pbSelBitmap(@path + @selImg,Rect.new(0,0,192,68)))
    @sel.speed = 4
    @sel.ox = @sel.src_rect.width/2
    @sel.oy = @sel.src_rect.height/2
    @sel.z = 199
    @sel.visible = false

    @button = {}
    @moved = false
    @showMega = false

    eff = [_INTL("Normal damage"),_INTL("Not very effective"),_INTL("Super effective"),_INTL("No effect")]
    @typeInd = Sprite.new(@viewport)
    @typeInd.bitmap = Bitmap.new(192,24*4)
    pbSetSmallFont(@typeInd.bitmap)
    for i in 0...4
      pbDrawOutlineText(@typeInd.bitmap,0,24*i + 5,192,24,eff[i],Color.white,Color.black,1)
    end
    @typeInd.src_rect.set(0,0,192,24)
    @typeInd.ox = 192/2
    @typeInd.oy = 16
    @typeInd.z = 103
    @typeInd.visible = false

  end
  #-----------------------------------------------------------------------------
  #  PBS metadata
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @cmdImg = "moveSelButtons"
    @selImg = "cmdSel"
    @typImg = "types"
    @catImg = "category"
    @megaImg = "megaButton"
    @barImg = nil
    @showTypeAdvantage = false
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:FIGHTMENU] if !d1.nil? && d1.has_key?(:FIGHTMENU)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:FIGHTMENU, :Metrics, :METRICS)
    # looks up globally defined settings
    d7 = EliteBattle.get_map_data(:FIGHTMENU_METRICS)
    # look up trainer specific metrics
    d6 = @battle.opponent ? EliteBattle.get_trainer_data(@battle.opponent[0].trainer_type, :FIGHTMENU_METRICS, @battle.opponent[0]) : nil
    # looks up species specific metrics
    d5 = !@battle.opponent ? EliteBattle.get_data(@battle.battlers[1].species, :Species, :FIGHTMENU_METRICS, (@battle.battlers[1].form rescue 0)) : nil
    # proceeds with parameter definition if available
    for data in [d2, d7, d6, d5, d1]
      if !data.nil?
        # applies a set of predefined keys
        @megaImg = data[:MEGABUTTONGRAPHIC] if data.has_key?(:MEGABUTTONGRAPHIC) && data[:MEGABUTTONGRAPHIC].is_a?(String)
        @cmdImg = data[:BUTTONGRAPHIC] if data.has_key?(:BUTTONGRAPHIC) && data[:BUTTONGRAPHIC].is_a?(String)
        @selImg = data[:SELECTORGRAPHIC] if data.has_key?(:SELECTORGRAPHIC) && data[:SELECTORGRAPHIC].is_a?(String)
        @barImg = data[:BARGRAPHIC] if data.has_key?(:BARGRAPHIC) && data[:BARGRAPHIC].is_a?(String)
        @typImg = data[:TYPEGRAPHIC] if data.has_key?(:TYPEGRAPHIC) && data[:TYPEGRAPHIC].is_a?(String)
        @catImg = data[:CATEGORYGRAPHIC] if data.has_key?(:CATEGORYGRAPHIC) && data[:CATEGORYGRAPHIC].is_a?(String)
        @showTypeAdvantage = data[:SHOWTYPEADVANTAGE] if data.has_key?(:SHOWTYPEADVANTAGE)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  render move info buttons
  #-----------------------------------------------------------------------------
  def generateButtons
    @moves = @battler.moves
    @nummoves = 0
    @oldindex = -1
    @x = []; @y = []
    for i in 0...4
      @button["#{i}"].dispose if @button["#{i}"]
      @nummoves += 1 if @moves[i] && @moves[i].id
      @x.push(@viewport.width/2 + (i%2==0 ? -1 : 1)*(@viewport.width/2 + 99))
      @y.push(@viewport.height - 90 + (i/2)*44)
    end
    for i in 0...4
      @y[i] += 22 if @nummoves < 3
    end
    @button = {}
    for i in 0...@nummoves
      # get numeric values of required variables
      movedata = GameData::Move.get(@moves[i].id)
      category = movedata.physical? ? 0 : (movedata.special? ? 1 : 2)
      type = GameData::Type.get(movedata.type).id_number
      # create sprite
      @button["#{i}"] = Sprite.new(@viewport)
      @button["#{i}"].param = category
      @button["#{i}"].z = 102
      @button["#{i}"].bitmap = Bitmap.new(198*2, 74)
      @button["#{i}"].bitmap.blt(0, 0, @buttonBitmap, Rect.new(0, type*74, 198, 74))
      @button["#{i}"].bitmap.blt(198, 0, @buttonBitmap, Rect.new(198, type*74, 198, 74))
      @button["#{i}"].bitmap.blt(65, 46, @catBitmap, Rect.new(0, category*22, 38, 22))
      @button["#{i}"].bitmap.blt(3, 46, @typeBitmap, Rect.new(0, type*22, 72, 22))
      baseColor = @buttonBitmap.get_pixel(5, 32 + (type*74)).darken(0.4)
      pbSetSmallFont(@button["#{i}"].bitmap)
      pbDrawOutlineText(@button["#{i}"].bitmap, 198, 10, 196, 42,"#{movedata.real_name}", Color.white, baseColor, 1)
      pp = "#{@moves[i].pp}/#{movedata.total_pp}"
      pbDrawOutlineText(@button["#{i}"].bitmap, 0, 48, 191, 26, pp, Color.white, baseColor, 2)
      pbSetSystemFont(@button["#{i}"].bitmap)
      text = [[movedata.real_name, 99, 4, 2, baseColor, Color.new(0, 0, 0, 24)]]
      pbDrawTextPositions(@button["#{i}"].bitmap, text)
      @button["#{i}"].src_rect.set(198, 0, 198, 74)
      @button["#{i}"].ox = @button["#{i}"].src_rect.width/2
      @button["#{i}"].x = @x[i]
      @button["#{i}"].y = @y[i]
    end
  end
  #-----------------------------------------------------------------------------
  #  unused
  #-----------------------------------------------------------------------------
  def formatBackdrop; end
  def shiftMode=(val); end
  #-----------------------------------------------------------------------------
  #  show fight menu animation
  #-----------------------------------------------------------------------------
  def show
    @sel.visible = false
    @typeInd.visible = false
    @background.y -= (@background.bitmap.height/8)
    for i in 0...@nummoves
      @button["#{i}"].x += ((i%2 == 0 ? 1 : -1)*@viewport.width/16)
    end
  end
  def showPlay
    @megaButton.src_rect.x = 0
    @background.y = @viewport.height
    8.times do
      self.show; @scene.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  hide fight menu animation
  #-----------------------------------------------------------------------------
  def hide
    @sel.visible = false
    @typeInd.visible = false
    @background.y += (@background.bitmap.height/8)
    @megaButton.y += 12
    for i in 0...@nummoves
      @button["#{i}"].x -= ((i%2 == 0 ? 1 : -1)*@viewport.width/16)
    end
    @showMega = false
    @megaButton.src_rect.x = 0
  end
  def hidePlay
    8.times do
      self.hide; @scene.wait(1, true)
    end
    @megaButton.y = @viewport.height - @background.bitmap.height/2 + 100
  end
  #-----------------------------------------------------------------------------
  #  toggle mega button visibility
  #-----------------------------------------------------------------------------
  def megaButton
    @showMega = true
  end
  #-----------------------------------------------------------------------------
  #  trigger mega button
  #-----------------------------------------------------------------------------
  def megaButtonTrigger
    @megaButton.src_rect.x += @megaButton.src_rect.width
    @megaButton.src_rect.x = 0 if @megaButton.src_rect.x > @megaButton.src_rect.width
    @megaButton.src_rect.y = -4
  end
  #-----------------------------------------------------------------------------
  #  update fight menu
  #-----------------------------------------------------------------------------
  def update
    @sel.visible = true
    if @showMega
      @megaButton.y -= 10 if @megaButton.y > @viewport.height - @background.bitmap.height/2
      @megaButton.src_rect.y += 1 if @megaButton.src_rect.y < 0
    end
    if @oldindex != @index
      @button["#{@index}"].src_rect.y = -4
      if @showTypeAdvantage && !(@battle.doublebattle? || @battle.triplebattle?)
        move = @battler.moves[@index]
        @modifier = move.pbCalcTypeMod(move.type, @player, @opponent)
      end
      @oldindex = @index
    end
    for i in 0...@nummoves
      @button["#{i}"].src_rect.x = 198*(@index == i ? 0 : 1)
      @button["#{i}"].y = @y[i]
      @button["#{i}"].src_rect.y += 1 if @button["#{i}"].src_rect.y < 0
      next if i != @index
      if [0,1].include?(i)
        @button["#{i}"].y = @y[i] - ((@nummoves < 3) ? 14 : 30)
      elsif [2,3].include?(i)
        @button["#{i}"].y = @y[i] - 30
        @button["#{i-2}"].y = @y[i-2] - 30
      end
    end
    @sel.x = @button["#{@index}"].x
    @sel.y = @button["#{@index}"].y + @button["#{@index}"].src_rect.height/2 - 1
    @sel.update
    if @showTypeAdvantage && !(@battle.doublebattle? || @battle.triplebattle?)
      @typeInd.visible = true
      @typeInd.y = @button["#{@index}"].y
      @typeInd.x = @button["#{@index}"].x
      eff = 0
      if @button["#{@index}"].param == 2 # status move
        eff = 4
      elsif @modifier == 0 # No effect
        eff = 3
      elsif @modifier < 8
        eff = 1   # "Not very effective"
      elsif @modifier > 8
        eff = 2   # "Super effective"
      end
      @typeInd.src_rect.y = 24 * eff
    end
  end
  #-----------------------------------------------------------------------------
  #  visibility functions
  #-----------------------------------------------------------------------------
  def dispose
    @buttonBitmap.dispose
    @catBitmap.dispose
    @typeBitmap.dispose
    @background.dispose
    @megaButton.dispose
    @typeInd.dispose
    pbDisposeSpriteHash(@button)
  end
  #-----------------------------------------------------------------------------
end
