#===============================================================================
#  System for scripted battles
#===============================================================================
class PokeBattle_Battle
  attr_reader :midspeech
  #-----------------------------------------------------------------------------
  #  compiles additional trainer speech if applicable
  #-----------------------------------------------------------------------------
  def endspeech=(msg)
    @endspeech = msg
    @endspeech = @midspeech[0]["endspeech"] if @midspeech && @midspeech.is_a?(Array) && @midspeech[0].is_a?(Hash) && @midspeech[0].has_key?("endspeech")
  end
  #-----------------------------------------------------------------------------
  #  compatibility for double trainer battles
  #-----------------------------------------------------------------------------
  def endspeech2=(msg)
    @endspeech2 = msg
    @endspeech2 = @midspeech[1]["endspeech"] if @midspeech && @midspeech.is_a?(Array) && @midspeech[1].is_a?(Hash) && @midspeech[1].has_key?("endspeech")
  end
  #-----------------------------------------------------------------------------
  #  shows message before opponent uses item
  #-----------------------------------------------------------------------------
  alias pbUseItemOnPokemon_ebdx pbUseItemOnPokemon unless self.method_defined?(:pbUseItemOnPokemon_ebdx)
  def pbUseItemOnPokemon(*args)
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech("itemOpp") if args[2].index%2 == 1
    return pbUseItemOnPokemon_ebdx(*args)
  end
  #-----------------------------------------------------------------------------
  #  shows message after player uses
  #-----------------------------------------------------------------------------
  alias pbUseItemOnBattler_ebdx pbUseItemOnBattler unless self.method_defined?(:pbUseItemOnBattler_ebdx)
  def pbUseItemOnBattler(*args)
    ret = pbUseItemOnBattler_ebdx(*args)
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech("item")
    return ret
  end
  #-----------------------------------------------------------------------------
  #  shows message before Mega Evolution
  #-----------------------------------------------------------------------------
  alias pbMegaEvolve_ebdx pbMegaEvolve unless self.method_defined?(:pbMegaEvolve_ebdx)
  def pbMegaEvolve(index)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasMega? rescue false)
    return if (@battlers[index].isMega? rescue true)
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech(playerBattler?(@battlers[index]) ? "mega" : "megaOpp")
    return pbMegaEvolve_ebdx(index)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#
#===============================================================================
class PokeBattle_Battler
  #-----------------------------------------------------------------------------
  #  shows message before using attack
  #-----------------------------------------------------------------------------
  alias pbUseMove_ebdx pbUseMove unless self.method_defined?(:pbUseMove_ebdx)
  def pbUseMove(*args)
    # displays trainer dialogue if applicable
    @battle.scene.pbTrainerBattleSpeech(playerBattler?(self) ? "attack": "attackOpp")
    @battle.scene.briefmessage = true
    return pbUseMove_ebdx(*args)
  end

  alias pbFaint_ebdx pbFaint unless self.method_defined?(:pbFaint_ebdx)
  def pbFaint(*args)
    show = !@fainted
    @battle.scene.briefmessage = true
    ret = pbFaint_ebdx(*args)
    # displays trainer dialogue if applicable
    @battle.scene.pbTrainerBattleSpeech(playerBattler?(self) ? "fainted" : "faintedOpp") if show
    return ret
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  # function used to determine when to display characters in scene and show
  # additional scripted dialogue
  #-----------------------------------------------------------------------------
  def pbTrainerBattleSpeech(*filters)
    return if !@battle.midspeech || !@battle.midspeech.is_a?(Array)
    @briefmessage = false
    ret = false
    max = @battle.opponent ? @battle.opponent.length : @battle.pbSideSize(1)
    # iterate through potential double battler indexes
    for index in 0...[@battle.midspeech.length, max].min
      handled = false
      # skip if unable to interface
      next if !@battle.midspeech[index] || !@battle.midspeech[index].is_a?(Hash)
      for key in @battle.midspeech[index].keys.sort
        next if @battle.midspeech[index][key].nil?
        # checks through filters
        skip = filters.length > 0
        for filter in filters
          if key.include?(filter)
            next if (filter.include?("Opp") && !key.include?("Opp")) || (key.include?("Opp") && !filter.include?("Opp"))
            skip = false
            break
          end
        end
        next if skip || handled
        # turn progression dialogue
        if key.include?("turnStart") || key.include?("turnEnd")
          turn = key.gsub("Start", "")
          turn = turn.gsub("End", "")
          turn = turn.gsub("turn", "").to_i
          if turn == @battle.turnCount
            pbTrainerSpeak(@battle.midspeech[index][key], nil, index)
            @battle.midspeech[index][key] = nil
            @battle.midspeech[index].delete(key)
            handled = true; ret = true
            next
          end
        # random chance message
        elsif key.include?("rand")
          chance = key.gsub("rand", "").to_i
          if rand(chance) == 0
            pbTrainerSpeak(@battle.midspeech[index][key], nil, index)
            @battle.midspeech[index][key] = nil
            @battle.midspeech[index].delete(key)
            handled = true; ret = true
            next
          end
        # last Pokemon is sent out
        elsif key.include?("last") || key.include?("afterLast") || key.include?("beforeLast")
          lin = key.include?("Opp") ? 1 : 0
          if @battle.pbParty(lin).length > 1 && @battle.pbAbleCount(lin) == 1
            pbTrainerSpeak(@battle.midspeech[index][key], nil, index)
            @battle.midspeech[index][key] = nil
            @battle.midspeech[index].delete(key)
            handled = true; ret = true
            next
          end
        # any other specified dialogue popups
        else
          pbTrainerSpeak(@battle.midspeech[index][key], nil, index)
          @battle.midspeech[index][key] = nil
          @battle.midspeech[index].delete(key)
          handled = true; ret = true
          next
        end
      end
    end
    return ret
  end
  #-----------------------------------------------------------------------------
  # function to process actual speech
  #-----------------------------------------------------------------------------
  def pbTrainerSpeak(msg, bgm = nil, index = 0)
    # in case the dialogue is a hash for bgm change as well as text display
    file = (msg.is_a?(Hash) && msg.has_key?(:file)) ? msg[:file] : nil
    bgm = msg[:bgm] if msg.is_a?(Hash) && msg.has_key?(:bgm)
    msg = msg[:text] if msg.is_a?(Hash) && msg.has_key?(:text)
    # play specified BGM
    pbBGMPlay(bgm) if !bgm.nil?
    self.custom_bgm = bgm if !bgm.nil?
    # safety check
    if msg.is_a?(Proc)
      wrapper = CallbackWrapper.new
      wrapper.set({
        :battle => @battle, :scene => self, :sprites => @sprites,
        :battlers => @battle.battlers, :opponent => @battle.opponent,
        :viewport => @viewport, :vector => self.vector
      })
      return wrapper.execute(msg)
    end
    return pbBattleCommonEvent(msg) if msg.is_a?(Integer)
    return if !msg.is_a?(String) && !msg.is_a?(Array)
    msg = [msg] if !msg.is_a?(Array)
    # show opponent Trainer on screen
    clearMessageWindow
    pbShowOpponent(index, true, file) if (@battle.opponent && @battle.opponent[index]) || !file.nil?
    # display message
    for m in msg
      @battle.pbDisplayPaused(m)
    end
    clearMessageWindow
    # hide opponent Trainer off screen
    pbHideOpponent(true, true) if (@battle.opponent && @battle.opponent[index]) || !file.nil?
  end
  #-----------------------------------------------------------------------------
  #  visuals to show opponent in scene
  #-----------------------------------------------------------------------------
  def pbShowOpponent(index = 0, speech = false, file = nil)
    return unless (@battle.opponent && @battle.opponent[index]) || !file.nil?
    pbSetMessageMode(false, true)
    trainerfile = @battle.opponent ? GameData::TrainerType.front_sprite_filename(@battle.opponent[index].trainer_type) : nil
    trainerfile = "Graphics/Trainers/#{file}" if !file.nil?
    trainerfile = "Graphics/EBDX/Battlers/000" if trainerfile.nil?
    # hide databoxes
    pbHideAllDataboxes
    # hide old trainer first if necessary
    pbHideOpponent if @sprites["opponent"]
    # draws opponent sprite
    trainer = (@battle.opponent && @battle.opponent[index]) ? @battle.opponent[index] : nil
    @sprites["opponent"] = DynamicTrainerSprite.new(false, -1, @viewport, false, trainer)
    @sprites["opponent"].setTrainerBitmap(trainerfile) if !trainerfile.nil?
    @sprites["opponent"].toLastFrame
    @sprites["opponent"].lock
    @sprites["opponent"].z = 11
    # hide shadow if applicable
    if @sprites["battlebg"].data.has_key?("noshadow") && @sprites["battlebg"].data["noshadow"] == true
      @sprites["opponent"].noshadow = true
    end
    v = (@battle.doublebattle? && speech) ? 3 : -1
    ox = @sprites["battlebg"].battler(v).x + (speech ? 200 : 160) + (@battle.doublebattle? && speech ? 96 : 0)
    oy = @sprites["battlebg"].battler(v).y - (speech ? 2 : -40)
    @sprites["opponent"].x = ox
    @sprites["opponent"].y = oy
    @sprites["opponent"].opacity = 0
    # draws black boxes
    @sprites["box1"] = Sprite.new(@viewport)
    @sprites["box1"].z = 99999
    @sprites["box1"].create_rect(2, 32 ,Color.black)
    @sprites["box1"].zoom_x = 0
    @sprites["box1"].x = -2
    @sprites["box2"] = Sprite.new(@viewport)
    @sprites["box2"].z = 99999
    @sprites["box2"].create_rect(2, 32, Color.black)
    @sprites["box2"].zoom_x = 0
    @sprites["box2"].ox = 2
    @sprites["box2"].x = @viewport.width + 2
    @sprites["box2"].y = @viewport.height - 32
    x = v > 0 ? -8 : -6
    for i in 0...20.delta_add
      k = 20.delta_add/20.0
      moveEntireScene(x, (speech ? +2 : -1), true, true) if i%k > 0 || k == 1
      @sprites["opponent"].opacity += 12.8.delta_sub(false)
      @sprites["opponent"].x += x if i%k > 0 || k == 1
      @sprites["opponent"].y += (speech ? 2 : -1) if i%k > 0 || k == 1
      @sprites["box1"].zoom_x += (@viewport.width/16).delta_sub(false) if speech
      @sprites["box2"].zoom_x += (@viewport.width/16).delta_sub(false) if speech
      self.wait(1, true)
    end
    @sprites["opponent"].x = ox + x*20
    @sprites["opponent"].y = oy + (speech ? 2 : -1)*20
    @sprites["box1"].zoom_x = @viewport.width if speech
    @sprites["box2"].zoom_x = @viewport.width if speech
  end
  #-----------------------------------------------------------------------------
  #  visuals to hide opponent in scene
  #-----------------------------------------------------------------------------
  def pbHideOpponent(showboxes = false, speech = false)
    return if !@sprites["opponent"] || @sprites["opponent"].disposed?
    pbSetMessageMode(false)
    v = (@battle.doublebattle? && speech) ? 3 : -1
    x = v > 0 ? 8 : 6
    for i in 0...20.delta_add
      k = 20.delta_add/20.0
      moveEntireScene(x, (speech ? -2 : +1), true, true) if i%k > 0 || k == 1
      @sprites["opponent"].opacity -= 12.8.delta_sub(false)
      @sprites["opponent"].x += x if i%k > 0 || k == 1
      @sprites["opponent"].y -= (speech ? 2 : -1) if i%k > 0 || k == 1
      @sprites["box1"].zoom_x -= (@viewport.width/16).delta_sub(false) if speech
      @sprites["box2"].zoom_x -= (@viewport.width/16).delta_sub(false) if speech
      self.wait(1, true)
    end
    @sprites["opponent"].opacity = 0
    @sprites["box1"].zoom_x = 0 if speech
    @sprites["box2"].zoom_x = 0 if speech
    # show databoxes
    pbShowAllDataboxes
    # dispose sprites
    @sprites["opponent"].dispose
    @sprites["box1"].dispose
    @sprites["box2"].dispose
  end
  #-----------------------------------------------------------------------------
  def pbBattleCommonEvent(id)
    # generate temp assets
    tview = Viewport.new(0, 0, Graphics.width, Graphics.height)
    tview.z = 100001
    tview.color = Color.black
    # fade out
    4.times do
      tview.color.alpha += 64
      wait
    end
    # reposition viewports
    @viewport.rect.x = -Graphics.width
    @msgview.rect.x = -Graphics.width
    EliteBattle.get(:tviewport).color.alpha = 0
    tview.color.alpha = 0
    # run event
    pbCommonEvent(id)
    # reposition viewports
    @viewport.rect.x = 0
    @msgview.rect.x = 0
    EliteBattle.get(:tviewport).color.alpha = 255
    tview.color.alpha = 255
    # fade in
    4.times do
      tview.color.alpha -= 64
      wait
    end
    # dispose temp assets
    tview.dispose
  end
  #-----------------------------------------------------------------------------
  def pbTrainerSpeakFancy(msg, trainer, backdrop)
    msg = [msg] if !msg.is_a?(Array)
    backdrop = pbBitmap("Graphics/EBDX/Transitions/Common/" + backdrop)
    trainer = [trainer] if !trainer.is_a?(Array)
    pbHideAllDataboxes
    @fancyMsg = FancyMessage.new(msg, trainer, backdrop, self)
    @fancyMsg.speak
    @fancyMsg.dispose
    pbShowAllDataboxes
  end
end
#===============================================================================
#  trainer full name double spacing bug fix
#===============================================================================
class Trainer
  #-----------------------------------------------------------------------------
  #  applies bugfix
  #-----------------------------------------------------------------------------
  alias fullname_ebdx fullname unless self.method_defined?(:fullname_ebdx)
  def fullname
    return fullname_ebdx.gsub("  ","")
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  AI override to send out ace last
#===============================================================================
class PokeBattle_AI
  #-----------------------------------------------------------------------------
  def pbChooseBestNewEnemy(idxBattler, party, enemies)
    return -1 if !enemies || enemies.length == 0
    best    = -1
    bestSum = 0
    # get opponent info
    opponent = @battle.pbGetOwnerFromBattlerIndex(idxBattler)
    selAce = EliteBattle.get_trainer_data(opponent.trainer_type, :ACE, opponent) if !opponent.nil?
    selAce = nil if !selAce.is_a?(Numeric) || selAce < 1 || selAce > 6
    # loop through possible selections
    enemies.each do |i|
      pkmn = party[i]
      # skip ace if not last sendout
      if !selAce.nil?
        cnt = 0
        party.each { |pl| cnt += 1 if pl.able? }
        next if i == selAce - 1 && cnt > 2
      end
      sum  = 0
      pkmn.moves.each do |m|
        next if m.base_damage == 0
        @battle.battlers[idxBattler].eachOpposing do |b|
          bTypes = b.pbTypes(true)
          sum += Effectiveness.calculate(m.type, bTypes[0], bTypes[1], bTypes[2])
        end
      end
      if best == -1 || sum > bestSum
        best = i
        bestSum = sum
      end
    end
    return best
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
class FancyMessage
  #-----------------------------------------------------------------------------
  #  set up fancy message
  #-----------------------------------------------------------------------------
  def initialize(msg, trainer, backdrop, scene)
    @msg = msg
    @scene = scene
    @battle = @scene.battle
    @viewport = @scene.dexview
    @trainer = trainer
    @disposed = false
    @sprites = {}
    @sprites["bg"] = Sprite.new(@viewport)
    @sprites["bg"].bitmap = backdrop
    @sprites["bg"].x = -32
    @sprites["str"] = ScrollingSprite.new(@viewport)
    @sprites["str"].setBitmap("Graphics/EBDX/Transitions/Common/streaks.png")
    @sprites["str"].direction = -1
    @sprites["tr"] = Sprite.new(@viewport)
    @sprites["tr"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/" + trainer[0])
    @sprites["tr"].z = 150
    @sprites["tr"].x = 32
    # draws black boxes
    @sprites["box1"] = Sprite.new(@viewport)
    @sprites["box1"].z = 100
    @sprites["box1"].create_rect(2, 32, Color.black)
    @sprites["box1"].zoom_x = 0
    @sprites["box1"].x = -2
    @sprites["box2"] = Sprite.new(@viewport)
    @sprites["box2"].z = 100
    @sprites["box2"].create_rect(2, 32, Color.black)
    @sprites["box2"].zoom_x = 0
    @sprites["box2"].ox = 2
    @sprites["box2"].x = @viewport.width + 2
    @sprites["box2"].y = @viewport.height - 32
    @sprites["fade"] = Sprite.new(@viewport)
    @sprites["fade"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/fade.png")
    @sprites["fade"].ox = @sprites["fade"].bitmap.width/2
    @sprites["fade"].x = -@sprites["fade"].ox
    @sprites["fade"].z = 99999
    self.visible = false
  end
  #-----------------------------------------------------------------------------
  #  speak the text
  #-----------------------------------------------------------------------------
  def speak
    # fade in animation
    16.times do
      self.update(false)
      @scene.wait
    end
    # display messages
    @scene.pbSetMessageMode(false, true)
    for i in 0...@msg.length
      if i < @trainer.length && i > 0
        @sprites["tr"].bitmap = pbBitmap("Graphics/EBDX/Transitions/Common/" + @trainer[i])
      end
      @battle.pbDisplayPaused(@msg[i])
    end
    @scene.pbSetMessageMode(false)
    @scene.clearMessageWindow
    # fade out animation
    @sprites["fade"].x = -@sprites["fade"].ox
    4.times do
      @sprites["fade"].x += @sprites["fade"].bitmap.width/8
      self.update
      @scene.wait
    end
    self.visible = false
    4.times do
      @sprites["fade"].x += @sprites["fade"].bitmap.width/8
      @scene.wait
    end
  end
  #-----------------------------------------------------------------------------
  #  update the message effects
  #-----------------------------------------------------------------------------
  def update(box = true)
    # animate bars
    if @sprites["bg"].visible && box
      @sprites["box1"].zoom_x += @viewport.width/16 if @sprites["box1"].zoom_x < @viewport.width
      @sprites["box2"].zoom_x += @viewport.width/16 if @sprites["box2"].zoom_x < @viewport.width
    end
    # updates rest of scene
    @sprites["bg"].x += 2 if @sprites["bg"].visible && @sprites["bg"].x < 0
    @sprites["tr"].x -= 2 if @sprites["tr"].visible && @sprites["tr"].x > 0
    @sprites["str"].update if @sprites["str"].visible
    # fade
    @sprites["fade"].x += @sprites["fade"].bitmap.width/8 if @sprites["fade"].x < (@viewport.width + @sprites["fade"].ox)
    if (@sprites["fade"].x >= @viewport.width/2 && !@sprites["bg"].visible)
      self.visible = true
    end
  end
  #-----------------------------------------------------------------------------
  #  set visibility
  #-----------------------------------------------------------------------------
  def visible=(val)
    for key in @sprites.keys
      next if key.include?("box") || key == "fade"
      @sprites[key].visible = val
    end
  end
  #-----------------------------------------------------------------------------
  #  dispose of content
  #-----------------------------------------------------------------------------
  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
  end
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
end
