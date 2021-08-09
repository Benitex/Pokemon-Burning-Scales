#===============================================================================
#  EBDX UI construction
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  def pbSelectBattler(*args)
    pbDeselectAll(args[0])
  end
  def pbUpdateSelected(*args); end
  def pbDeselectAll(index = nil)
    @battle.battlers.each_with_index do |b, i|
      next if !b
      @sprites["dataBox_#{i}"].selected = false if @sprites["dataBox_#{i}"]
      @sprites["pokemon_#{i}"].selected = false if @sprites["pokemon_#{i}"]
    end
    @sprites["dataBox_#{index}"].selected = true if !index.nil? && @sprites["dataBox_#{index}"]
  end
  #-----------------------------------------------------------------------------
  #  Load all UI elements
  #-----------------------------------------------------------------------------
  def loadUIElements
    # battle data boxes
    @battle.battlers.each_with_index do |b, i|
      next if !b
      @sprites["dataBox_#{i}"] = DataBoxEBDX.new(b, @msgview, @battle.pbPlayer, self)
    end
    # messageBox (window sprite) drawn dynamically based on screen size
    bmp1 = Bitmap.smartWindow(Rect.new(8, 8, 8, 8), Rect.new(0, 0, @viewport.width - 28, 82), "Graphics/EBDX/Pictures/UI/skin1")
    bmp2 = Bitmap.smartWindow(Rect.new(8, 8, 8, 8), Rect.new(0, 0, @viewport.width - 28, 82), "Graphics/EBDX/Pictures/UI/skin2")
    @sprites["messageBox"] = Sprite.new(@msgview)
    @sprites["messageBox"].bitmap = Bitmap.new(@viewport.width - 28, 82*2)
    @sprites["messageBox"].bitmap.blt(0, 0, bmp1, bmp1.rect)
    @sprites["messageBox"].bitmap.blt(0, 82, bmp2, bmp2.rect)
    @sprites["messageBox"].x = @viewport.width/2 - @sprites["messageBox"].src_rect.width/2
    @sprites["messageBox"].y = @viewport.height - 106
    @sprites["messageBox"].z = 99999
    @sprites["messageBox"].src_rect.height /= 2
    @sprites["messageBox"].visible = false
    # help window for other scenes
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 32, 32, @msgview)
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].z = @sprites["messageBox"].z + 1
    # message window (where the actual text is rendered
    @sprites["messageWindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["messageWindow"].letterbyletter = true
    @sprites["messageWindow"].cursorMode = 2
    @sprites["messageWindow"].battlePause
    @sprites["messageWindow"].viewport = @msgview
    @sprites["messageWindow"].z = @sprites["messageBox"].z + 1
    # old command elements
    @sprites["commandWindow"] = CommandMenuDisplay.new(@msgview, 0) # Retained for compatibility
    @sprites["commandWindow"].visible = false # Retained for compatibility
    @sprites["fightWindow"] = FightMenuDisplay.new(@msgview, 0) # Retained for compatibility
    @sprites["fightWindow"].visible = false # Retained for compatibility
    # new command and fight menu UI
    @commandWindow = CommandWindowEBDX.new(@msgview, @battle, self, @safaribattle)
    @fightWindow = FightWindowEBDX.new(@msgview, @battle, self)
    @bagWindow = BagWindowEBDX.new(self, @msgview)
    @playerLineUp = PartyLineupEBDX.new(@viewport, self, @battle, 0)
    @opponentLineUp = PartyLineupEBDX.new(@viewport, self, @battle, 1)
    @targetWindow = TargetWindowEBDX.new(@msgview, @battle, self)
    # hides the new UI
    8.times do
      @commandWindow.hide
      @fightWindow.hide
    end
    # Compatibility for Effect messages
    bitmap = pbBitmap("Graphics/EBDX/Pictures/UI/abilityMessage")
    @sprites["abilityMessage"] = Sprite.new(@msgview)
    @sprites["abilityMessage"].bitmap = Bitmap.new(bitmap.width, bitmap.height); bitmap.dispose
    pbSetSmallFont(@sprites["abilityMessage"].bitmap)
    @sprites["abilityMessage"].oy = @sprites["abilityMessage"].bitmap.height/2
    @sprites["abilityMessage"].zoom_y = 0
    @sprites["abilityMessage"].z = 99999
  end
  #-----------------------------------------------------------------------------
  #  Update specific window
  #-----------------------------------------------------------------------------
  def updateWindow(cw)
    pbGraphicsUpdate
    pbInputUpdate
    pbFrameUpdate(cw)
  end
  #-----------------------------------------------------------------------------
end
