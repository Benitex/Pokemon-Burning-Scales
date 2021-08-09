#===============================================================================
#  Battle Bag interface
#  UI ovarhaul
#===============================================================================
def pbIsMedicine?(item)
  return [1, 2, 6, 7].include?(GameData::Item.get(item).battle_use) && !GameData::Item.get(item).is_berry?
end

def pbIsBattleItem?(item)
  return [3, 5, 8, 9, 10].include?(GameData::Item.get(item).battle_use)
end
#===============================================================================
#  Main UI class
#===============================================================================
class BagWindowEBDX
  attr_reader :index, :ret, :finished
  attr_accessor :sprites
  #-----------------------------------------------------------------------------
  #  class inspector
  #-----------------------------------------------------------------------------
  def inspect
    str = self.to_s.chop
    str << format(' pocket: %s,', @index)
    str << format(' page: %s,', @page)
    str << format(' item: %s>', @item)
    return str
  end
  #-----------------------------------------------------------------------------
  #  hide bag UI and display scene message
  #-----------------------------------------------------------------------------
  def pbDisplayMessage(msg)
    self.visible = false
    @scene.pbDisplayMessage(msg)
    @scene.clearMessageWindow
    self.visible = true
  end
  def pbDisplay(msg); self.pbDisplayMessage(msg); end
  #-----------------------------------------------------------------------------
  #  configure PBS data for graphics
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @cmdImg = "itemContainer"
    @lastImg = "last"
    @backImg = "back"
    @frameImg = "itemFrame"
    @selImg = "cmdSel"
    @shadeImg = "shade"
    @nameImg = "itemName"
    @confirmImg = "itemConfirm"
    @cancelImg = "itemCancel"
    @iconsImg = "pocketIcons"
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:BAGMENU] if !d1.nil? && d1.has_key?(:BAGMENU)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:BAGMENU, :Metrics, :METRICS)
    # looks up globally defined settings
    d7 = EliteBattle.get_map_data(:BAGMENU_METRICS)
    # look up trainer specific metrics
    d6 = @battle.opponent ? EliteBattle.get_trainer_data(@battle.opponent[0].trainer_type, :BAGMENU_METRICS, @battle.opponent[0]) : nil
    # looks up species specific metrics
    d5 = !@battle.opponent ? EliteBattle.get_data(@battle.battlers[1].species, :Species, :BAGMENU_METRICS, (@battle.battlers[1].form rescue 0)) : nil
    # proceeds with parameter definition if available
    for data in [d2, d7, d6, d5, d1]
      if !data.nil?
        # applies a set of predefined keys
        @cmdImg = data[:POCKETBUTTONS] if data.has_key?(:POCKETBUTTONS) && data[:POCKETBUTTONS].is_a?(String)
        @lastImg = data[:LASTITEM] if data.has_key?(:LASTITEM) && data[:LASTITEM].is_a?(String)
        @backImg = data[:BACKBUTTON] if data.has_key?(:BACKBUTTON) && data[:BACKBUTTON].is_a?(String)
        @frameImg = data[:ITEMFRAME] if data.has_key?(:ITEMFRAME) && data[:ITEMFRAME].is_a?(String)
        @nameImg = data[:POCKETNAME] if data.has_key?(:POCKETNAME) && data[:POCKETNAME].is_a?(String)
        @confirmImg = data[:ITEMCONFIRM] if data.has_key?(:ITEMCONFIRM) && data[:ITEMCONFIRM].is_a?(String)
        @cancelImg = data[:ITEMCANCEL] if data.has_key?(:ITEMCANCEL) && data[:ITEMCANCEL].is_a?(String)
        @selImg = data[:SELECTORGRAPHIC] if data.has_key?(:SELECTORGRAPHIC) && data[:SELECTORGRAPHIC].is_a?(String)
        @shadeImg = data[:SHADE] if data.has_key?(:SHADE) && data[:SHADE].is_a?(String)
        @iconsImg = data[:POCKETICONS] if data.has_key?(:POCKETICONS) && data[:POCKETICONS].is_a?(String)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  construct Bag UI
  #-----------------------------------------------------------------------------
  def initialize(scene, viewport)
    # set up variables
    @scene = scene
    @battle = scene.battle
    $lastUsed = 0 if $lastUsed.nil?; @lastUsed = $lastUsed
    @index = 0; @oldindex = -1; @item = 0; @olditem = -1
    @finished = false
    @disposed = true
    @page = -1; @selPocket = 0
    @ret = nil; @path = "Graphics/EBDX/Pictures/Bag/"
    @baseColor = Color.new(96, 96, 96)
    @shadowColor = nil
    # configure viewport
    @viewport = Viewport.new(0, 0, viewport.width, viewport.height)
    @viewport.z = viewport.z + 5
    # load bitmaps for use
    self.applyMetrics
    # configure initial sprites
    @sprites = {}
    @items = {}
    @sprites["back"] = Sprite.new(viewport)
    @sprites["back"].stretch_screen(@path + @shadeImg)
    @sprites["back"].opacity = 0
    @sprites["back"].z = 99998
    # set up selector sprite
    @sprites["sel"] = SelectorSprite.new(@viewport, 4)
    @sprites["sel"].filename = @path + @selImg
    @sprites["sel"].z = 99999
    # item name sprite
    bmp = pbBitmap(@path + @nameImg)
    @sprites["name"] = Sprite.new(@viewport)
    @sprites["name"].bitmap = Bitmap.new(bmp.width*1.2, bmp.height)
    pbSetSystemFont(@sprites["name"].bitmap)
    @sprites["name"].x = -@sprites["name"].width - @sprites["name"].width%10
    @sprites["name"].y = @viewport.height - 56
    bmp.dispose
    # pocket bitmap
    pbmp = pbBitmap(@path + @cmdImg)
    ibmp = pbBitmap(@path + @iconsImg)
    # item pocket buttons
    for i in 0...4
      @sprites["pocket#{i}"] = Sprite.new(@viewport)
      @sprites["pocket#{i}"].bitmap = Bitmap.new(pbmp.width, pbmp.height/4)
      @sprites["pocket#{i}"].bitmap.blt(0, 0, pbmp, Rect.new(0, (pbmp.height/4)*i, pbmp.width, pbmp.height/4))
      @sprites["pocket#{i}"].bitmap.blt((pbmp.width - ibmp.width)/2, (pbmp.height/4 - ibmp.height/4)/2, ibmp, Rect.new(0, (ibmp.height/4)*i, ibmp.width, ibmp.height/4))
      @sprites["pocket#{i}"].center!
      @sprites["pocket#{i}"].x = ((i%2)*2 + 1)*@viewport.width/4 + ((i%2 == 0) ? -1 : 1)*(@viewport.width/2 - 8)
      @sprites["pocket#{i}"].y = ((i/2)*2 + 2)*@viewport.height/8 + (i%2)*42
    end
    pbmp.dispose
    ibmp.dispose
    # last used item sprite
    @sprites["pocket4"] = Sprite.new(@viewport)
    bmp = pbBitmap(@path + @lastImg)
    @sprites["pocket4"].bitmap = Bitmap.new(bmp.width, bmp.height/2)
    pbSetSystemFont(@sprites["pocket4"].bitmap)
    @sprites["pocket4"].x = 24
    @sprites["pocket4"].ey = @viewport.height - 62
    @sprites["pocket4"].y = @sprites["pocket4"].ey + 80
    bmp.dispose
    self.refresh(true)
    # back button sprite
    @sprites["pocket5"] = Sprite.new(@viewport)
    @sprites["pocket5"].bitmap = pbBitmap(@path + @backImg)
    @sprites["pocket5"].x = @viewport.width - @sprites["pocket5"].width - 16
    @sprites["pocket5"].ey = @viewport.height - 60
    @sprites["pocket5"].y = @sprites["pocket4"].ey + 80
    @sprites["pocket5"].z = 5
    # confirmation buttons
    @sprites["confirm"] = Sprite.new(@viewport)
    bmp = pbBitmap(@path + @confirmImg)
    @sprites["confirm"].bitmap = Bitmap.new(bmp.width, bmp.height)
    pbSetSmallFont(@sprites["confirm"].bitmap); bmp.dispose
    @sprites["confirm"].center!
    @sprites["confirm"].x = @viewport.width/2 - @viewport.width + @viewport.width%8
    @sprites["cancel"] = Sprite.new(@viewport)
    @sprites["cancel"].bitmap = pbBitmap(@path + @cancelImg)
    @sprites["cancel"].center!
    @sprites["cancel"].x = @viewport.width/2 - @viewport.width + @viewport.width%8
    # calculate y values for the confirm/cancel buttons
    maxh = @sprites["confirm"].height + @sprites["cancel"].height + 8
    @sprites["confirm"].y = (@viewport.height - maxh)/2 + @sprites["confirm"].oy
    @sprites["cancel"].y = (@viewport.height - maxh)/2 + maxh - @sprites["cancel"].oy
    # initial target
    @sprites["sel"].target(@sprites["pocket#{@oldindex}"])
  end
  #-----------------------------------------------------------------------------
  #  dispose of the current UI
  #-----------------------------------------------------------------------------
  def dispose
    keys = ["back", "sel", "name", "confirm", "cancel"]
    for i in 0..5
      keys.push("pocket#{i}")
    end
    for key in keys
      @sprites[key].dispose
    end
    pbDisposeSpriteHash(@items)
    @disposed = true
  end
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  #  merge required pockets
  #-----------------------------------------------------------------------------
  def checkPockets
    @mergedPockets = []
    for i in 0...$PokemonBag.pockets.length
      @mergedPockets += $PokemonBag.pockets[i]
    end
  end
  #-----------------------------------------------------------------------------
  #  draw content of selected pocket
  #-----------------------------------------------------------------------------
  def drawPocket(pocket, index)
    @pocket = []
    @pgtrigger = false
    # get a list of all the items
    self.checkPockets
    for item in @mergedPockets
      next if item.nil?
      next if !(ItemHandlers.hasUseInBattle(item[0]) || ItemHandlers.hasBattleUseOnPokemon(item[0]) || ItemHandlers.hasBattleUseOnBattler(item[0]))
      case index
      when 0 # Medicine
        @pocket.push([item[0], item[1]]) if pbIsMedicine?(item[0])
      when 1 # Pokeballs
        @pocket.push([item[0], item[1]]) if GameData::Item.get(item[0]).is_poke_ball?
      when 2 # Berries
        @pocket.push([item[0], item[1]]) if GameData::Item.get(item[0]).is_berry?
      when 3 # Battle Items
        @pocket.push([item[0], item[1]]) if pbIsBattleItem?(item[0])
      end
    end
    # show message if pocket is empty
    if @pocket.length < 1
      pbDisplayMessage(_INTL("You have no usable items in this pocket."))
      return
    end
    # configure variables
    @xpos = []
    @pages = @pocket.length/6
    @pages += 1 if @pocket.length%6 > 0
    @page = 0; @item = 0; @olditem = 0
    @back = false
    @selPocket = pocket
    # dispose sprites if already existing
    pbDisposeSpriteHash(@items)
    @pname = Settings.bag_pocket_names[pocket]
    x = 0; y = 0
    # pocket bitmap
    pbmp = pbBitmap(@path + @cmdImg)
    ibmp = pbBitmap(@path + @frameImg)
    for i in 0...@pocket.length
      @items["#{i}"] = Sprite.new(@viewport)
      # create bitmap and draw all the required contents on it
      @items["#{i}"].bitmap = Bitmap.new(pbmp.width, pbmp.height/4)
      @items["#{i}"].bitmap.blt(0, 0, pbmp, Rect.new(0, (pbmp.height/4)*@index, pbmp.width, pbmp.height/4))
      @items["#{i}"].bitmap.blt((pbmp.width - ibmp.width)/2, (pbmp.height/4 - ibmp.height)/2, ibmp, ibmp.rect)
      pbSetSystemFont(@items["#{i}"].bitmap)
      icon = pbBitmap(GameData::Item.icon_filename(@pocket[i][0]))
      @items["#{i}"].bitmap.blt(pbmp.width - icon.width - (pbmp.width - ibmp.width)/2 - 4, (pbmp.height/4 - icon.height)/2, icon, icon.rect, 164); icon.dispose
      # draw texxt
      text = [
        ["#{GameData::Item.get(@pocket[i][0]).real_name}", pbmp.width/2 - 15, 2*pbmp.height/64 - 8, 2, @baseColor, Color.new(0, 0, 0, 32)],
        ["x#{@pocket[i][1]}", pbmp.width/2 - 12, 8*pbmp.height/64 - 14, 2, @baseColor, Color.new(0, 0, 0, 32)],
      ]
      pbDrawTextPositions(@items["#{i}"].bitmap, text)
      # center sprite
      @items["#{i}"].center!
      # position items
      @items["#{i}"].x = @viewport.width + (x%2 == 0 ? 1 : -1)*8 + (x*2 + 1)*@viewport.width/4 + (i/6)*@viewport.width
      @xpos.push(@items["#{i}"].x - @viewport.width)
      @items["#{i}"].y = (y + 1)*@viewport.height/5 + (y*12)
      @items["#{i}"].opacity = 255
      # increment the position count
      x += 1; y += 1 if x > 1
      x = 0 if x > 1
      y = 0 if y > 2
    end
    pbmp.dispose; ibmp.dispose
    self.name
    @sprites["name"].x = -@sprites["name"].width - @sprites["name"].width%10
  end
  #-----------------------------------------------------------------------------
  #  refresh bitmap contents of item name
  #-----------------------------------------------------------------------------
  def name
    @page = @item/6
    # clean bitmap
    bmp = pbBitmap(@path + @nameImg)
    bitmap = @sprites["name"].bitmap
    bitmap.clear
    bitmap.blt(0, 0, bmp, Rect.new(0,0,320,44))
    # draw text
    text = [
      [@pname, bmp.width/2, -5, 2, Color.white, nil],
      ["#{@page+1}/#{@pages}", bmp.width, -5, 0, Color.white, nil]
    ]
    pbDrawTextPositions(bitmap, text)
    bmp.dispose
  end
  #-----------------------------------------------------------------------------
  #  update item selection menu
  #-----------------------------------------------------------------------------
  def updatePocket
    @page = @item/6
    # animate position of item sprites
    for i in 0...@pocket.length
      @items["#{i}"].x -= (@items["#{i}"].x - (@xpos[i] - @page*@viewport.width))*0.2
      @items["#{i}"].src_rect.y += 1 if @items["#{i}"].src_rect.y < 0
    end
    @sprites["name"].x += @sprites["name"].width/10 if @sprites["name"].x < -24
    @sprites["pocket5"].src_rect.y += 1 if @sprites["pocket5"].src_rect.y < 0
    # process item selection
    if Input.trigger?(Input::LEFT) && !@back
      if ![0, 2, 4].include?(@item)
        @item -= (@item%2 == 0) ? 5 : 1
      else
        @item -= 1 if @item < 0
      end
      @item = 0 if @item < 0
    elsif Input.trigger?(Input::RIGHT) && !@back
      if @page < (@pocket.length)/6
        @item += (@item%2 == 1) ? 5 : 1
      else
        @item += 1 if @item < @pocket.length - 1
      end
      @item = @pocket.length - 1 if @item > @pocket.length - 1
    elsif Input.trigger?(Input::UP)
      if @back
        @item += 4 if (@item%6) < 2
        @back = false
      else
        @item -= 2
        if (@item%6) > 3
          @item += 6
          @back = true
        end
      end
      @item = 0 if @item < 0
      @item = @pocket.length-1 if @item > @pocket.length-1
      @sprites["pocket5"].src_rect.y -= 6 if @back
    elsif Input.trigger?(Input::DOWN)
      if @back
        @item -= 4 if (@item%6) > 3
        @back = false
      else
        @item += 2
        if (@item%6) < 2
          @item -= 6
          @back = true
        end
        @back = true if @item > @pocket.length - 1
      end
      @item = @pocket.length - 1 if @item > @pocket.length - 1
      @item = 0 if @item < 0
      @sprites["pocket5"].src_rect.y -= 6 if @back
    end
    # confirm or cancel input
    if (@back && Input.trigger?(Input::C)) || Input.trigger?(Input::B)
      pbSEPlay("EBDX/SE_Select3")
      @selPocket = 0
      @page = -1; @oldindex = -1
      @back = false; @doubleback = true
    end
    # refresh selected values if index has changed
    if @item != @olditem
      @olditem = @item
      pbSEPlay("EBDX/SE_Select1")
      @sprites["sel"].target(@back ? @sprites["pocket5"] : @items["#{@item}"])
      @items["#{@item}"].src_rect.y -= 6 if !@back
      self.name
    end
  end
  #-----------------------------------------------------------------------------
  #  close current UI level
  #-----------------------------------------------------------------------------
  def closeCurrent
    @selPocket = 0
    @page = -1
    @back = false
    @ret = nil
    self.refresh
  end
  #-----------------------------------------------------------------------------
  #  show bag UI
  #-----------------------------------------------------------------------------
  def show
    @ret = nil
    self.refresh
    for i in 0...6
      @sprites["pocket#{i}"].opacity = 255
    end
    @sprites["pocket4"].y = @sprites["pocket4"].ey + 80
    @sprites["pocket5"].y = @sprites["pocket5"].ey + 80
    pbSEPlay("EBDX/SE_Zoom4", 60)
    8.times do
      for i in 0...4
        @sprites["pocket#{i}"].x += ((i%2 == 0) ? 1 : -1)*@viewport.width/16
      end
      for i in 4...6
        @sprites["pocket#{i}"].y -= 10
      end
      @sprites["back"].opacity += 32
      @sprites["sel"]
      @scene.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  hide bag UI
  #-----------------------------------------------------------------------------
  def hide
    8.times do
      for i in 0...4
        @sprites["pocket#{i}"].x -= ((i%2 == 0) ? 1 : -1)*@viewport.width/16
      end
      for i in 4...6
        @sprites["pocket#{i}"].y += 10
      end
      if @pocket
        for i in 0...@pocket.length
          @items["#{i}"].opacity -= 25.5
        end
      end
      @sprites["name"].x -= 48 if @sprites["name"].x > -380
      @sprites["back"].opacity -= 32
      @sprites["sel"].update
      @scene.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  dig into menu to use item
  #-----------------------------------------------------------------------------
  def useItem?
    # to make sure duplicates are not registered at the beginning
    Input.update
    # render bitmap for item use confirmation
    bitmap = @sprites["confirm"].bitmap
    bitmap.clear; bmp = pbBitmap(@path + @confirmImg)
    bitmap.blt(0, 0, bmp, bmp.rect)
    icon = pbBitmap(GameData::Item.icon_filename(@ret))
    bitmap.blt(20, 30, icon, icon.rect)
    # draw text
    drawTextEx(bitmap, 80, 12, 364, 3, GameData::Item.get(@ret).description, @baseColor, Color.new(0, 0, 0, 32))
    # select confirm message as target
    @sprites["sel"].target(@sprites["confirm"])
    # animate in
    8.times do
      # slide panels into screen
      @sprites["confirm"].x += @viewport.width/8
      @sprites["cancel"].x += @viewport.width/8
      if @pocket
        # fade out panels
        for i in 0...@pocket.length
          @items["#{i}"].opacity -= 32
        end
      end
      for i in 0...4
        @sprites["pocket#{i}"].opacity -= 64 if @sprites["pocket#{i}"].opacity > 0
      end
      # animate bottom items moving off screen
      @sprites["pocket4"].y += 10 if @sprites["pocket4"].y < @sprites["pocket4"].ey + 80
      @sprites["pocket5"].y += 10 if @sprites["pocket5"].y < @sprites["pocket5"].ey + 80
      @sprites["name"].x -= @sprites["name"].width/8
      @sprites["sel"].update
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end
    # ensure pocket name is off screen
    @sprites["name"].x = -@sprites["name"].width
    index = 0; oldindex = 0
    choice = (index == 0) ? "confirm" : "cancel"
    # start the main input loop
    loop do
      @sprites["#{choice}"].src_rect.y += 1 if @sprites["#{choice}"].src_rect.y < 0
      # process directional input
      if Input.trigger?(Input::UP)
        index -= 1
        index = 1 if index < 0
        choice = (index == 0) ? "confirm" : "cancel"
      elsif Input.trigger?(Input::DOWN)
        index += 1
        index = 0 if index > 1
        choice = (index == 0) ? "confirm" : "cancel"
      end
      # process change in index
      if index != oldindex
        oldindex = index
        pbSEPlay("EBDX/SE_Select1")
        @sprites["#{choice}"].src_rect.y -= 6
        @sprites["sel"].target(@sprites["#{choice}"])
      end
      # confirmation and cancellation input
      if Input.trigger?(Input::C)
        pbSEPlay("EBDX/SE_Select2")
        break
      elsif Input.trigger?(Input::B)
        @scene.pbPlayCancelSE()
        index = 1
        break
      end
      Input.update
      @sprites["sel"].update
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end
    # animate exit
    8.times do
      @sprites["confirm"].x -= @viewport.width/8
      @sprites["cancel"].x -= @viewport.width/8
      @sprites["pocket5"].y -= 10 if index > 0
      @sprites["sel"].update
      @scene.animateScene
      @scene.pbGraphicsUpdate
    end
    # refresh old UI (swap cursor to target)
    self.refresh
    # return output
    if index > 0
      @ret = nil
      return false
    else
      @index = 0 if @index == 4 && GameData::Item.get(@lastUsed).id_number == 0
      return true
    end
  end
  #-----------------------------------------------------------------------------
  #  refresh last item use
  #-----------------------------------------------------------------------------
  def refresh(skip = false)
    last = @lastUsed != 0 ? GameData::Item.get(@lastUsed).id_number : 0
    # format text
    i = last > 0 ? 1 : 0
    name = last > 0 ? GameData::Item.get(@lastUsed).real_name : ""
    text = ["", "#{name}"]
    # clean bitmap
    bmp = pbBitmap(@path + @lastImg)
    icon = pbBitmap(GameData::Item.icon_filename(last))
    bitmap = @sprites["pocket4"].bitmap
    bitmap.clear
    bitmap.blt(0, 0, bmp, Rect.new(0, i*bmp.height/2, bmp.width, bmp.height/2))
    bitmap.blt(28, (bmp.height/2 - icon.height)/2 - 2, icon, icon.rect) if last > 0
    icon.dispose
    # draw text
    dtext = [[text[i], bmp.width/2, 0, 2, @baseColor, Color.new(0, 0, 0, 32)]]
    pbDrawTextPositions(bitmap, dtext); bmp.dispose
    @sprites["sel"].target(@sprites["pocket#{@index}"]) unless skip
  end
  #-----------------------------------------------------------------------------
  #  main update function across all levels
  #-----------------------------------------------------------------------------
  def update
    # pocket selection page
    if @selPocket == 0
      self.updateMain
      for i in 0...4
        @sprites["pocket#{i}"].opacity += 51 if @sprites["pocket#{i}"].opacity < 255
      end
      @sprites["back"].opacity += 51 if @sprites["back"].opacity < 255
      @sprites["pocket4"].y -= 8 if @sprites["pocket4"].y > @sprites["pocket4"].ey
      @sprites["pocket5"].y -= 8 if @sprites["pocket5"].y > @sprites["pocket5"].ey
      if @pocket
        for i in 0...@pocket.length
          @items["#{i}"].opacity -= 51 if @items["#{i}"] && @items["#{i}"].opacity > 0
        end
      end
      @sprites["name"].x -= @sprites["name"].width/10 if @sprites["name"].x > -@sprites["name"].width
    # item selection page
    else
      if Input.trigger?(Input::C) && !@back
        self.intoPocket
      end
      self.updatePocket
      for i in 0...4
        @sprites["pocket#{i}"].opacity -= 51 if @sprites["pocket#{i}"].opacity > 0
      end
      @sprites["pocket4"].y += 8 if @sprites["pocket4"].y < (@sprites["pocket4"].ey + 80)
      for i in 0...@pocket.length
        @items["#{i}"].opacity += 51 if @items["#{i}"] && @items["#{i}"].opacity < 255
      end
    end
    # update selection sprite
    @sprites["sel"].update
  end
  #-----------------------------------------------------------------------------
  #  update function during item pocket selection
  #-----------------------------------------------------------------------------
  def updateMain
    last = @lastUsed != 0 ? GameData::Item.get(@lastUsed).id_number : 0
    # move the index around
    if Input.trigger?(Input::LEFT)
      @index -= 1
      @index += 2 if @index%2 == 1
      @index = 3 if @index == 4 && !(last > 0)
    elsif Input.trigger?(Input::RIGHT)
      @index += 1
      @index -= 2 if @index%2 == 0
      @index = 2 if @index == 4 && !(last > 0)
    elsif Input.trigger?(Input::UP)
      @index -= 2
      @index += 6 if @index < 0
      @index = 5 if @index == 4 && !(last > 0)
    elsif Input.trigger?(Input::DOWN)
      @index += 2
      @index -= 6 if @index > 5
      @index = 5 if @index == 4 && !(last > 0)
    end
    # play effects on index change
    if @oldindex != @index
      @oldindex = @index
      @sprites["sel"].target(@sprites["pocket#{@index}"])
      @sprites["pocket#{@index}"].src_rect.y -= 6
      pbSEPlay("EBDX/SE_Select1")
    end
    # slide buttons into original position after selector shift
    for i in 0...6
      @sprites["pocket#{i}"].src_rect.y += 1 if @sprites["pocket#{i}"].src_rect.y < 0
    end
    # set variables
    @doubleback = false
    @finished = false
    # check if confirm or cancel inputs are pressed
    if Input.trigger?(Input::C) && !@doubleback && @index < 5
      self.confirm
    elsif (Input.trigger?(Input::B) || (Input.trigger?(Input::C) && @index==5)) && @selPocket == 0 && !@doubleback
      self.finish
    end
  end
  #-----------------------------------------------------------------------------
  #  finish current bag processing
  #-----------------------------------------------------------------------------
  def finish
    pbSEPlay("EBDX/SE_Select3")
    @finished = true
    Input.update
  end
  #-----------------------------------------------------------------------------
  #  confirm current selection
  #-----------------------------------------------------------------------------
  def confirm
    pbSEPlay("EBDX/SE_Select2")
    if @index < 4
      cmd = [2, 3, 5, 7]
      cmd = [2, 1, 4, 5] if Settings.bag_pocket_names.length == 6
      self.drawPocket(cmd[@index], @index)
      @sprites["sel"].target(@back ? @sprites["pocket5"] : @items["#{@item}"])
    else
      @selPocket = 0
      @page = -1
      @ret = @lastUsed
      @lastUsed = 0 if !($PokemonBag.pbQuantity(@lastUsed) > 1)
    end
  end
  #-----------------------------------------------------------------------------
  #  open selected pocket
  #-----------------------------------------------------------------------------
  def intoPocket
    pbSEPlay("EBDX/SE_Select2")
    @selPocket = 0
    @page = -1
    @lastUsed = 0
    @lastUsed = @pocket[@item][0] if @pocket[@item][1] > 1
    $lastUsed = @lastUsed
    @ret = @pocket[@item][0]
  end
  #-----------------------------------------------------------------------------
  #  set visibility of UI
  #-----------------------------------------------------------------------------
  def visible=(val)
    for key in @sprites.keys
      next if key == "back"
      @sprites[key].visible = val
    end
  end
  #-----------------------------------------------------------------------------
  #  clear sel sprite
  #-----------------------------------------------------------------------------
  def clearSel
    @sprites["sel"].bitmap = Bitmap.new(2, 2)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Item Selection functionality part
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  Item menu functionality handler
  #-----------------------------------------------------------------------------
  alias pbItemMenu_ebdx pbItemMenu unless self.method_defined?(:pbItemMenu_ebdx)
  def pbItemMenu(idxBattler, firstAction)
    # reset system variables
    @idleTimer = -1
    @vector.reset; @vector.inc = 0.2
    ret = 0; retindex = -1; pkmnid = -1
    # update input to prevent misclicks
    Input.update
    # show bag UI
    @bagWindow.show
    # start main loop
    loop do
      # input and scene updates
      Input.update
      @bagWindow.update
      break if @bagWindow.finished
      # jump into next level to confirm item use
      if !@bagWindow.ret.nil? && @bagWindow.useItem?
        # get item data
        item = GameData::Item.get(@bagWindow.ret)
        itemName = item.name
        useType = item.battle_use
        # process item usetype
        case useType
        when 1, 2, 3, 6, 7, 8   # Use on Pokémon/Pokémon's move/battler
          # Auto-choose the Pokémon/battler whose action is being decided if they
          # are the only available Pokémon/battler to use the item on
          case useType
          when 1, 6   # Use on Pokémon
            if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
              ret = item
              break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, @bagWindow
            end
          when 3, 8   # Use on battler
            if @battle.pbPlayerBattlerCount == 1
              ret = item
              break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, @bagWindow
            end
          end
          # Get player's party
          party    = @battle.pbParty(idxBattler)
          partyPos = @battle.pbPartyOrder(idxBattler)
          partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
          modParty = @battle.pbPlayerDisplayParty(idxBattler)
          # Start party screen
          @bagWindow.clearSel
          pkmnScene = PokemonParty_Scene.new
          pkmnScreen = PokemonPartyScreen.new(pkmnScene,modParty)
          pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"), @battle.pbNumPositions(0, 0))
          idxParty = -1
          # Loop while in party screen
          loop do
            # Select a Pokémon
            pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            idxParty = pkmnScreen.pbChoosePokemon
            break if idxParty < 0
            idxPartyRet = -1
            partyPos.each_with_index do |pos, i|
              next if pos != idxParty + partyStart
              idxPartyRet = i
              break
            end
            next if idxPartyRet < 0
            pkmn = party[idxPartyRet]
            next if !pkmn || pkmn.egg?
            idxMove = -1
            if useType == 2 || useType == 7   # Use on Pokémon's move
              idxMove = pkmnScreen.pbChooseMove(pkmn, _INTL("Restore which move?"))
              next if idxMove < 0
            end
            break if yield item.id, useType, idxPartyRet, idxMove, pkmnScene
          end
          pkmnScene.pbEndScene
          break if idxParty >= 0
        when 4, 9   # Use on opposing battler (Poké Balls)
          idxTarget = -1
          if @battle.pbOpposingBattlerCount(idxBattler) == 1
            @battle.eachOtherSideBattler(idxBattler) { |b| idxTarget = b.index }
            ret = item
            break if yield item.id, useType, idxTarget, -1, @bagWindow
          else
            wasTargeting = true
            @bagWindow.sprites["back"].opacity = 0
            idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), {})
            if idxTarget >= 0
              ret = item
              break if yield item.id, useType, idxTarget, -1, self
            end
            # Target invalid/cancelled choosing a target; show the Bag screen again
            wasTargeting = false
          end
          # close out bag scene
          @bagWindow.closeCurrent
        when 5, 10   # Use with no target
          ret = item
          break if yield item.id, useType, idxBattler, -1, @bagWindow
        end
      end
      # end of function
      self.animateScene
      pbGraphicsUpdate
    end
    # close out bag
    @bagWindow.clearSel
    @bagWindow.hide
    $lastUsed = nil if ret.is_a?(Numeric) || (ret.id_number > 0 && $PokemonBag.pbQuantity(ret.id) <= 1)
    # try to remove low HP BGM
    setBGMLowHP(false)
  end
  #-----------------------------------------------------------------------------
end
