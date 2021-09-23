#-------------------------------------------------------------------------------
# Safari Hud component
#-------------------------------------------------------------------------------
class SafariHud < Component
  def startComponent(viewport)
    super(viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width/2,96,viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x = Graphics.width
    @baseColor   = MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme] || Color.new(248,248,248)
    @shadowColor = MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme] || Color.new(48,48,48)
  end

  def shouldDraw?; return pbInSafari?; end

  def refresh
    text = _INTL("Balls: {1}",pbSafariState.ballcount)
    text2 = (Settings::SAFARI_STEPS>0) ? _INTL("Steps: {1}/{2}", pbSafariState.steps,Settings::SAFARI_STEPS) : ""
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[[text,Graphics.width/2 - 8, 0,1,@baseColor,@shadowColor],[text2,Graphics.width/2 - 8,32,1,@baseColor,@shadowColor]])
  end
end

#-------------------------------------------------------------------------------
# Bug Contest Hud component
#-------------------------------------------------------------------------------
class BugContestHud < Component
  def startComponent(viewport)
    super(viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width/2,96,viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x = Graphics.width
    @baseColor = MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme] || Color.new(248,248,248)
    @shadowColor = MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme] || Color.new(48,48,48)
  end

  def shouldDraw?; return pbInBugContest?; end

  def refresh
    if pbBugContestState.lastPokemon
      text =  _INTL("Caught: {1}", pbBugContestState.lastPokemon.speciesName)
      text2 =  _INTL("Level: {1}", pbBugContestState.lastPokemon.level)
      text3 =  _INTL("Balls: {1}", pbBugContestState.ballcount)
    else
      text = _INTL("Caught: None")
      text2 = _INTL("Balls: {1}", pbBugContestState.ballcount)
      text3 = ""
    end
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[[text,Graphics.width/2 - 8, 0,1,
      @baseColor,@shadowColor],[text2,Graphics.width/2 - 8,32,1,@baseColor,@shadowColor],
      [text3,248,64,1,@baseColor,@shadowColor]])
  end
end

#-------------------------------------------------------------------------------
# Pokemon Party Hud component
#-------------------------------------------------------------------------------
class PokemonPartyHud < Component
  def startComponent(viewport)
    super(viewport)
    # Overlay stuff
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height/2,@viewport)
    @sprites["overlay"].y = (Graphics.height/2)
    @hpbar     = AnimatedBitmap.new(MENU_FILE_PATH + "overlayHp")
    @expbar    = AnimatedBitmap.new(MENU_FILE_PATH + "overlayExp")
    @status    = AnimatedBitmap.new(MENU_FILE_PATH + "overlayStatus")
    @infobmp   = Bitmap.new(MENU_FILE_PATH + "overlayInfo")
    @itembmp   = Bitmap.new(MENU_FILE_PATH + "overlayItem")
    @shinybmp  = Bitmap.new(MENU_FILE_PATH + "overlayShiny")
  end

  def shouldDraw?; return $Trainer.party_count > 0; end

  def refresh
    # Iterate through all the player's Pokémon
    @sprites["overlay"].bitmap.clear
    for i in 0...6
      next if !@sprites["pokemon#{i}"]
      @sprites["pokemon#{i}"].dispose
      @sprites["pokemon#{i}"] = nil
      @sprites.delete("pokemon#{i}")
    end
    for i in 0...$Trainer.party.length
      pokemon = $Trainer.party[i]
      next if !pokemon
      spacing = (Graphics.width/8) * i
      # Pokémon Icon
      @sprites["pokemon#{i}"] = PokemonIconSprite.new(pokemon,@viewport) if !@sprites["pokemon#{i}"]
      @sprites["pokemon#{i}"].x = spacing + (Graphics.width/8)
      @sprites["pokemon#{i}"].y = Graphics.height - 164
      @sprites["pokemon#{i}"].z = -2
      next if pokemon.egg?
      # Information Overlay
      @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 16, Graphics.height/2 - 102,
                          @infobmp, Rect.new(0, 0, @infobmp.width, @infobmp.height))
      # Shiny Icon
      if pokemon.shiny?
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 52, Graphics.height/2 - 142,
                          @shinybmp,Rect.new(0, 0, @shinybmp.width, @shinybmp.height))
      end
      # Item Icon
      if pokemon.hasItem?
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 52, Graphics.height/2 - 116,
                                       @itembmp,Rect.new(0, 0, @itembmp.width, @itembmp.height))
      end
      # Health
      if pokemon.hp>0
        w = (pokemon.hp * 32 * 1.0)/pokemon.totalhp
        w = 1 if w<1
        w = ((w/2).round) * 2
        hpzone = 0
        hpzone = 1 if pokemon.hp<=(pokemon.totalhp/2).floor
        hpzone = 2 if pokemon.hp<=(pokemon.totalhp/4).floor
        hprect = Rect.new(0, hpzone * 4, w, 4)
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 18, Graphics.height/2 - 100, @hpbar.bitmap, hprect)
      end
      # EXP
      if pokemon.exp>0
        minexp = pokemon.growth_rate.minimum_exp_for_level(pokemon.level)
        currentexp = minexp-pokemon.exp
        maxexp = minexp-pokemon.growth_rate.minimum_exp_for_level(pokemon.level + 1)
        w = (currentexp * 24 * 1.0)/maxexp
        w = 1 if w < 1.0
        w = 0 if w.is_a?(Float) && w.nan?
        w = ((w/2).round) * 2 if w > 0 # I heard Pokémon Beekeeper was good
        exprect = Rect.new(0, 0, w, 2)
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 22, Graphics.height/2 - 94, @expbar.bitmap, exprect)
      end
      # Status
      status = 0
      if pokemon.fainted?
        status = GameData::Status::DATA.keys.length / 2
      elsif pokemon.status != :NONE
        status = GameData::Status.get(pokemon.status).id_number
      elsif pokemon.pokerusStage == 1
        status = GameData::Status::DATA.keys.length / 2 + 1
      end
      status -= 1
      if status >= 0
        statusrect = Rect.new(0,8*status,8,8)
        @sprites["overlay"].bitmap.blt(spacing + (Graphics.width/8) + 48, Graphics.height/2 - 106, @status.bitmap, statusrect)
      end
    end
  end

  def dispose
    super
    @infobmp.dispose
    @hpbar.dispose
    @expbar.dispose
    @status.dispose
    @infobmp.dispose
    @itembmp .dispose
    @shinybmp.dispose
  end
end

#-------------------------------------------------------------------------------
# Date and Time Hud component
#-------------------------------------------------------------------------------
class DateAndTimeHud < Component
  def initialize
    @last_time = pbGetTimeNow.strftime("%I:%M %p")
  end

  def startComponent(viewport)
    super(viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width/2,96,viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x = Graphics.width
    @baseColor = MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme] || Color.new(248,248,248)
    @shadowColor = MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme] || Color.new(48,48,48)
  end

  def shouldDraw?; return !(pbInBugContest? || pbInSafari?); end

  def update
    super
    refresh if @last_time != pbGetTimeNow.strftime("%I:%M %p")
  end

  def refresh
    text = _INTL("{1} {2} {3}",Time.now.day.to_i,pbGetAbbrevMonthName(Time.now.month.to_i),Time.now.year.to_i)
    text2 = _INTL("{1}",pbGetTimeNow.strftime("%I:%M %p"))
    @sprites["overlay"].bitmap.clear
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[[text,Graphics.width/2 - 8, 0,1,
      @baseColor,@shadowColor],[text2,Graphics.width/2 - 8,32,1,@baseColor,@shadowColor]])
    @last_time = pbGetTimeNow.strftime("%I:%M %p")
  end
end

#-------------------------------------------------------------------------------
# New Quesst Message Hud component
#-------------------------------------------------------------------------------
class NewQuestHud < Component
  def initialize
    @counter = 0
  end

  def startComponent(viewport)
    super(viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width/2,32,viewport)
    @sprites["overlay"].ox = @sprites["overlay"].bitmap.width
    @sprites["overlay"].x = Graphics.width
    @sprites["overlay"].y = 96
    @sprites["overlay"].oy = 32
    @baseColor = MENU_TEXTCOLOR[$PokemonSystem.current_menu_theme] || Color.new(248,248,248)
    @shadowColor = MENU_TEXTOUTLINE[$PokemonSystem.current_menu_theme] || Color.new(48,48,48)
  end

  def shouldDraw?
    return false if !defined?(hasAnyQuests?)
    return false if !$PokemonGlobal
    return false if !$PokemonGlobal.respond_to?(:quests)
    return $PokemonGlobal.quests.active_quests.any? { |quest| quest.respond_to?(:new) && quest.new }
  end

  def update
    super
    @counter += 1
    if @counter > Graphics.frame_rate/2
      @sprites["overlay"].y += 1 if @counter % (Graphics.frame_rate/8) == 0
    else
      @sprites["overlay"].y -= 1 if @counter % (Graphics.frame_rate/8) == 0
    end
    @counter = 0 if @counter >= Graphics.frame_rate
  end

  def refresh
    numQuests = $PokemonGlobal.quests.active_quests.count { |quest| quest.respond_to?(:new) && quest.new }
    @sprites["overlay"].bitmap.clear
    if numQuests > 0
      text = _INTL("You have {1} new quest{2}!",numQuests, numQuests == 1 ? "" : "s")
      pbSetSmallFont(@sprites["overlay"].bitmap)
      pbDrawTextPositions(@sprites["overlay"].bitmap,[[text,Graphics.width/2 - 8, 0,1,@baseColor,@shadowColor]])
    end
  end
end
