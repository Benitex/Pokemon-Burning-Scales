#===============================================================================
#  Message overrides to clear message window
#===============================================================================
module EliteBattle
  #-----------------------------------------------------------------------------
  #  command selection
  #-----------------------------------------------------------------------------
  def self.commandWindow(commands, index = 0, msgwindow = nil)
    ret = -1
    # creates command window
    cmdwindow = Window_CommandPokemonColor.new(commands)
    cmdwindow.index = index
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.z = 99999
    # main loop
    loop do
      # updates graphics, input and OW
      Graphics.update
      Input.update
      pbUpdateSceneMap
      # updates the two windows
      cmdwindow.update
      msgwindow.update if !msgwindow.nil?
      # updates command output
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        ret = -1
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        ret = cmdwindow.index
        break
      end
    end
    # returns command output
    cmdwindow.dispose
    return ret
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
class PokeBattle_Battle
  #-----------------------------------------------------------------------------
  #  basic display command
  #-----------------------------------------------------------------------------
  def pbDisplay(msg, &block)
    @scene.pbDisplayMessage(msg, &block)
    @scene.clearMessageWindow if !@scene.briefmessage
  end
  #-----------------------------------------------------------------------------
  #  paused display command
  #-----------------------------------------------------------------------------
  def pbDisplayPaused(msg, &block)
    @scene.pbDisplayPausedMessage(msg, &block)
    @scene.clearMessageWindow if !@scene.briefmessage
  end
  #-----------------------------------------------------------------------------
  #  brief display command
  #-----------------------------------------------------------------------------
  def pbDisplayBrief(msg, &block)
    @scene.pbDisplayMessage(msg, true, &block)
    @scene.clearMessageWindow if !@scene.briefmessage
  end
  #-----------------------------------------------------------------------------
  #  extended display command
  #-----------------------------------------------------------------------------
  def pbDisplayExtended(msg, &block)
    @scene.pbDisplayMessage(msg, true, &block)
  end
  #-----------------------------------------------------------------------------
  #  confirm message command
  #-----------------------------------------------------------------------------
  def pbDisplayConfirm(msg, &block)
    ret = @scene.pbDisplayConfirmMessage(msg, &block)
    @scene.clearMessageWindow if !@scene.briefmessage
    return ret
  end
  #-----------------------------------------------------------------------------
  #  show choices command
  #-----------------------------------------------------------------------------
  def pbShowCommands(msg, commands, cancancel = true, &block)
    ret = @scene.pbShowCommands(msg, commands, cancancel, &block)
    @scene.clearMessageWindow if !@scene.briefmessage
    return ret
  end
  #-----------------------------------------------------------------------------
  #  set regular windowskin when gaining money
  #-----------------------------------------------------------------------------
  alias pbGainMoney_ebdx pbGainMoney unless self.method_defined?(:pbGainMoney_ebdx)
  def pbGainMoney
    @scene.pbSetMessageMode(false)
    return pbGainMoney_ebdx
  end
  #-----------------------------------------------------------------------------
  #  set regular windowskin when losing money
  #-----------------------------------------------------------------------------
  alias pbLoseMoney_ebdx pbLoseMoney unless self.method_defined?(:pbLoseMoney_ebdx)
  def pbLoseMoney
    @scene.pbSetMessageMode(false)
    return pbLoseMoney_ebdx
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Scene functions for message windows
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  set EBS message mode for dark/light message boxes
  #-----------------------------------------------------------------------------
  def pbSetMessageMode(mode, light = false)
    @messagemode = mode
    base = light ? EliteBattle.get(:messageLightColor) : EliteBattle.get(:messageDarkColor)
    shadow = light ? EliteBattle.get(:messageLightShadow) : EliteBattle.get(:messageDarkShadow)
    @sprites["messageBox"].src_rect.y = @sprites["messageBox"].src_rect.height * (light ? 1 : 0)
    @sprites["messageBox"].y = @viewport.height - 88
    msgwindow = @sprites["messageWindow"]
    msgwindow.baseColor = base
    msgwindow.shadowColor = shadow
    msgwindow.opacity = 0
    msgwindow.x = 24
    msgwindow.width = @viewport.width - 48
    msgwindow.height = 96
    msgwindow.y = @viewport.height - msgwindow.height - 2
  end
  #-----------------------------------------------------------------------------
  #  clear all windows
  #-----------------------------------------------------------------------------
  def clearMessageWindow(force = false)
    unless force
      return if @sendingOut
    end
    @sprites["messageWindow"].text = ""
    @sprites["messageWindow"].refresh
    @sprites["messageBox"].visible = false
    @briefmessage = false
  end
  #-----------------------------------------------------------------------------
  #  check if message box is visible
  #-----------------------------------------------------------------------------
  def windowVisible?
    return @sprites["messageBox"].visible
  end
  #-----------------------------------------------------------------------------
  #  change the viewport on the message box
  #-----------------------------------------------------------------------------
  def changeMessageViewport(viewport = nil)
    @sprites["messageBox"].viewport = (@sprites["messageBox"].viewport == @msgview) ? viewport : @msgview
    @sprites["messageWindow"].viewport = (@sprites["messageWindow"].viewport == @msgview) ? viewport : @msgview
  end
  #-----------------------------------------------------------------------------
  #  update specified window with scene
  #-----------------------------------------------------------------------------
  alias pbFrameUpdate_ebdx pbFrameUpdate unless self.method_defined?(:pbFrameUpdate_ebdx)
  def pbFrameUpdate(cw = nil, &block)
    cw.update if cw
    animateScene(true, &block)
  end
  #-----------------------------------------------------------------------------
  #  show specified window
  #-----------------------------------------------------------------------------
  alias pbShowWindow_ebdx pbShowWindow unless self.method_defined?(:pbShowWindow_ebdx)
  def pbShowWindow(windowtype)
    @sprites["messageBox"].visible = (windowtype == MESSAGE_BOX ||
                                      windowtype == COMMAND_BOX ||
                                      windowtype == FIGHT_BOX)
    @sprites["messageWindow"].visible = (windowtype == MESSAGE_BOX)
  end
  #-----------------------------------------------------------------------------
  #  remove
  #-----------------------------------------------------------------------------
  alias pbWaitMessage_ebdx pbWaitMessage unless self.method_defined?(:pbWaitMessage_ebdx)
  def pbWaitMessage; end
  #-----------------------------------------------------------------------------
  #  basic message display
  #-----------------------------------------------------------------------------
  alias pbDisplay_ebdx pbDisplay unless self.method_defined?(:pbDisplay_ebdx)
  def pbDisplay(msg, brief = false, &block)
    pbDisplayMessage(msg, brief, &block)
    clearMessageWindow
  end
  #-----------------------------------------------------------------------------
  #  choice selection processing
  #-----------------------------------------------------------------------------
  alias pbShowCommands_ebdx pbShowCommands unless self.method_defined?(:pbShowCommands_ebdx)
  def pbShowCommands(msg, commands, defaultValue, &block)
    pbShowWindow(MESSAGE_BOX)
    pbHideAllDataboxes
    dw = @sprites["messageWindow"]
    dw.text = msg
    cw = ChoiceWindowEBDX.new(@msgview, commands, self)
    loop do
      pbUpdate(cw)
      dw.update
      if Input.trigger?(Input::B) && defaultValue >= 0
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          pbSEPlay("EBDX/SE_Select2")
          cw.dispose(self)
          dw.text = ""
          pbShowAllDataboxes
          return defaultValue
        end
      end
      if Input.trigger?(Input::C)
        if dw.busy?
          pbPlayDecisionSE() if dw.pausing?
          dw.resume
        else
          pbSEPlay("EBDX/SE_Select2")
          cw.dispose(self)
          dw.text = ""
          pbShowAllDataboxes
          return cw.index
        end
      end
    end
    pbShowAllDataboxes
  end
  #-----------------------------------------------------------------------------
  #  hide databoxes during move learning
  #-----------------------------------------------------------------------------
  alias pbForgetMove_ebdx pbForgetMove unless self.method_defined?(:pbForgetMove_ebdx)
  def pbForgetMove(*args)
    pbHideAllDataboxes
    ret = pbForgetMove_ebdx(*args)
    pbShowAllDataboxes
    return ret
  end
  #-----------------------------------------------------------------------------
  #  hide databoxes during name entry
  #-----------------------------------------------------------------------------
  alias pbNameEntry_ebdx pbNameEntry unless self.method_defined?(:pbNameEntry_ebdx)
  def pbNameEntry(*args)
    pbHideAllDataboxes
    ret = pbNameEntry_ebdx(*args)
    pbShowAllDataboxes
    return ret
  end
  #-----------------------------------------------------------------------------
  #  show Pokedex on capture
  #-----------------------------------------------------------------------------
  alias pbShowPokedex_ebdx pbShowPokedex unless self.method_defined?(:pbShowPokedex_ebdx)
  def pbShowPokedex(*args)
    pbHideAllDataboxes
    clearMessageWindow
    @sprites["dexdata"] = EliteBattle_Pokedex.new(@dexview, @caughtBattler)
    return true
  end
  #-----------------------------------------------------------------------------
  #  adjust to the top right
  #-----------------------------------------------------------------------------
  def pbTopRightWindow(text)
    window = Window_AdvancedTextPokemon.new(text)
    window.viewport = @msgview
    window.width = 198
    window.y = 0
    window.x = Graphics.width - window.width
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      window.update
      animateScene
      if Input.trigger?(Input::C)
        break
      end
    end
    window.dispose
  end
  #-----------------------------------------------------------------------------
end
