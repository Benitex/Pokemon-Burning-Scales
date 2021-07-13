#===============================================================================
# "Triple Triad" mini-game
# By Unknown
#===============================================================================
#===============================================================================
# Card class
#===============================================================================
class TriadCard
  attr_reader :species, :form
  attr_reader :north, :east, :south, :west
  attr_reader :type

  def initialize(species, form = 0)
    @species = species
    @form    = form
    species_data = GameData::Species.get_species_form(@species, @form)
    baseStats = species_data.base_stats
    hp      = baseStats[:HP]
    attack  = baseStats[:ATTACK]
    defense = baseStats[:DEFENSE]
    spAtk   = baseStats[:SPECIAL_ATTACK]
    spDef   = baseStats[:SPECIAL_DEFENSE]
    speed   = baseStats[:SPEED]
    @type  = species_data.type1
    @type  = species_data.type2 if @type == :NORMAL && species_data.type2
    @west  = baseStatToValue(attack + speed / 3)
    @east  = baseStatToValue(defense + hp / 3)
    @north = baseStatToValue(spAtk + speed / 3)
    @south = baseStatToValue(spDef + hp / 3)
  end

  def baseStatToValue(stat)
    return 10 if stat >= 189
    return 9 if stat >= 160
    return 8 if stat >= 134
    return 7 if stat >= 115
    return 6 if stat >= 100
    return 5 if stat >= 86
    return 4 if stat >= 73
    return 3 if stat >= 60
    return 2 if stat >= 45
    return 1
  end

  def attack(panel)
    return [@west, @east, @north, @south][panel]
  end

  def defense(panel)
    return [@east, @west, @south, @north][panel]
  end

  def bonus(opponent)
    case Effectiveness.calculate_one(@type, opponent.type)
    when Effectiveness::INEFFECTIVE            then return -2
    when Effectiveness::NOT_VERY_EFFECTIVE_ONE then return -1
    when Effectiveness::SUPER_EFFECTIVE_ONE    then return 1
    end
    return 0
  end

  def price
    maxValue = [@north, @east, @south, @west].max
    ret = @north * @north + @east * @east + @south * @south + @west * @west
    ret += maxValue * maxValue * 2
    ret *= maxValue
    ret *= (@north + @east + @south + @west)
    ret /= 10   # Ranges from 2 to 24,000
    # Quantize prices to the next highest "unit"
    if ret > 10000;   ret = (1 + ret / 1000) * 1000
    elsif ret > 5000; ret = (1 + ret / 500) * 500
    elsif ret > 1000; ret = (1 + ret / 100) * 100
    elsif ret > 500;  ret = (1 + ret / 50) * 50
    else;             ret = (1 + ret / 10) * 10
    end
    return ret
  end

  def self.createBack(type = nil, noback = false)
    bitmap = BitmapWrapper.new(80, 96)
    if !noback
      cardbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/triad_card_opponent"))
      bitmap.blt(0, 0, cardbitmap.bitmap, Rect.new(0, 0, cardbitmap.width, cardbitmap.height))
      cardbitmap.dispose
    end
    if type
      typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      type_number = GameData::Type.get(type).id_number
      typerect = Rect.new(0, type_number * 28, 64, 28)
      bitmap.blt(8, 50, typebitmap.bitmap, typerect, 192)
      typebitmap.dispose
    end
    return bitmap
  end

  def createBitmap(owner)
    return TriadCard.createBack if owner == 0
    bitmap = BitmapWrapper.new(80, 96)
    if owner == 2   # Opponent
      cardbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/triad_card_opponent"))
    else            # Player
      cardbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/triad_card_player"))
    end
    typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    iconbitmap = AnimatedBitmap.new(GameData::Species.icon_filename(@species, @form))
    numbersbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/triad_numbers"))
    # Draw card background
    bitmap.blt(0, 0, cardbitmap.bitmap, Rect.new(0, 0, cardbitmap.width, cardbitmap.height))
    # Draw type icon
    type_number = GameData::Type.get(@type).id_number
    typerect = Rect.new(0, type_number * 28, 64, 28)
    bitmap.blt(8, 50, typebitmap.bitmap, typerect, 192)
    # Draw Pokémon icon
    bitmap.blt(8, 24, iconbitmap.bitmap, Rect.new(0, 0, 64, 64))
    # Draw numbers
    bitmap.blt(8, 16, numbersbitmap.bitmap, Rect.new(@west * 16, 0, 16, 16))
    bitmap.blt(22, 6, numbersbitmap.bitmap, Rect.new(@north * 16, 0, 16, 16))
    bitmap.blt(36, 16, numbersbitmap.bitmap, Rect.new(@east * 16, 0, 16, 16))
    bitmap.blt(22, 26, numbersbitmap.bitmap, Rect.new(@south * 16, 0, 16, 16))
    cardbitmap.dispose
    typebitmap.dispose
    iconbitmap.dispose
    numbersbitmap.dispose
    return bitmap
  end
end



#===============================================================================
# Duel screen visuals
#===============================================================================
class TriadSquare
  attr_accessor :owner, :card, :type

  def initialize
    @owner = 0
    @card  = nil
    @type  = nil
  end

  def attack(panel)
    return @card.attack(panel)
  end

  def bonus(square)
    return @card.bonus(square.card)
  end

  def defense(panel)
    return @card.defense(panel)
  end
end



# Scene class for handling appearance of the screen
class TriadScene
  def pbStartScene(battle)
    @sprites = {}
    @bitmaps = []
    @battle = battle
    # Allocate viewport
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites,"background","triad_bg",@viewport)
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.newWithSize("",
       0,Graphics.height-64,Graphics.width,64,@viewport)
    for i in 0...@battle.width*@battle.height
      @sprites["sprite#{i}"] = SpriteWrapper.new(@viewport)
      @sprites["sprite#{i}"].x = Graphics.width/2 - 118 + (i%3)*78
      @sprites["sprite#{i}"].y = 36 + (i/3)*94
      @sprites["sprite#{i}"].z = 2
      bm = TriadCard.createBack(@battle.board[i].type,true)
      @bitmaps.push(bm)
      @sprites["sprite#{i}"].bitmap = bm
    end
    @cardBitmaps         = []
    @opponentCardBitmaps = []
    @cardIndexes         = []
    @opponentCardIndexes = []
    @boardSprites        = []
    @boardCards          = []
    for i in 0...@battle.maxCards
      @sprites["player#{i}"] = Sprite.new(@viewport)
      @sprites["player#{i}"].x = Graphics.width-92
      @sprites["player#{i}"].y = 44+44*i
      @sprites["player#{i}"].z = 2
      @cardIndexes.push(i)
    end
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbDrawTextPositions(@sprites["overlay"].bitmap,[
       [@battle.opponentName,52,-2,2,Color.new(248,248,248),Color.new(96,96,96)],
       [@battle.playerName,Graphics.width-52,-2,2,Color.new(248,248,248),Color.new(96,96,96)]
    ])
    @sprites["score"] = Sprite.new(@viewport)
    @sprites["score"].bitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@sprites["score"].bitmap)
    pbBGMPlay("Triple Triad")
    # Fade in all sprites
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbBGMFade(1.0)
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @bitmaps.each { |bm| bm.dispose }
    @viewport.dispose
  end

  def pbDisplay(text)
    @sprites["helpwindow"].text = text
    (Graphics.frame_rate*1.5).floor.times do
      Graphics.update
      Input.update
      pbUpdate
    end
  end

  def pbDisplayPaused(text)
    @sprites["helpwindow"].letterbyletter = true
    @sprites["helpwindow"].text           = text+"\1"
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        if @sprites["helpwindow"].busy?
          pbPlayDecisionSE if @sprites["helpwindow"].pausing?
          @sprites["helpwindow"].resume
        else
          break
        end
      end
    end
    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].text           = ""
  end

  def pbNotifyCards(playerCards,opponentCards)
    @playerCards   = playerCards
    @opponentCards = opponentCards
  end

  def pbChooseTriadCard(cardStorage)
    commands    = []
    chosenCards = []
    for item in cardStorage
      commands.push(_INTL("{1} x{2}", GameData::Species.get(item[0]).name, item[1]))
    end
    command = Window_CommandPokemonEx.newWithSize(commands,0,0,Graphics.width/2,Graphics.height-64,@viewport)
    @sprites["helpwindow"].text = _INTL("Choose {1} cards to use for this duel.",@battle.maxCards)
    preview = Sprite.new(@viewport)
    preview.x = Graphics.width/2 + 20
    preview.y = 60
    preview.z = 4
    index = -1
    for i in 0...@battle.maxCards
      @sprites["player#{i}"] = Sprite.new(@viewport)
      @sprites["player#{i}"].x = Graphics.width-92
      @sprites["player#{i}"].y = 44+44*i
      @sprites["player#{i}"].z = 2
    end
    loop do
      Graphics.update
      Input.update
      pbUpdate
      command.update
      if command.index!=index
        preview.bitmap.dispose if preview.bitmap
        if command.index<cardStorage.length
          item = cardStorage[command.index]
          preview.bitmap = TriadCard.new(item[0]).createBitmap(1)
        end
        index = command.index
      end
      if Input.trigger?(Input::BACK)
        if chosenCards.length>0
          item = chosenCards.pop
          @battle.pbAdd(cardStorage,item)
          commands = []
          for item in cardStorage
            commands.push(_INTL("{1} x{2}", GameData::Species.get(item[0]).name, item[1]))
          end
          command.commands = commands
          index = -1
        else
          pbPlayBuzzerSE
        end
      elsif Input.trigger?(Input::USE)
        break if chosenCards.length==@battle.maxCards
        item = cardStorage[command.index]
        if !item || @battle.pbQuantity(cardStorage,item[0])==0
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          sprite = @sprites["player#{chosenCards.length}"]
          sprite.bitmap.dispose if sprite.bitmap
          @cardBitmaps[chosenCards.length] = TriadCard.new(item[0]).createBitmap(1)
          sprite.bitmap = @cardBitmaps[chosenCards.length]
          chosenCards.push(item[0])
          @battle.pbSubtract(cardStorage,item[0])
          commands = []
          for item in cardStorage
            commands.push(_INTL("{1} x{2}", GameData::Species.get(item[0]).name, item[1]))
          end
          command.commands = commands
          command.index = commands.length-1 if command.index>=commands.length
          index = -1
        end
      end
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        for i in 0...@battle.maxCards
          @sprites["player#{i}"].visible = (i<chosenCards.length)
        end
        if chosenCards.length==@battle.maxCards
          @sprites["helpwindow"].text = _INTL("{1} cards have been chosen.",@battle.maxCards)
          command.visible = false
          command.active  = false
          preview.visible = false
        else
          @sprites["helpwindow"].text = _INTL("Choose {1} cards to use for this duel.",@battle.maxCards)
          command.visible = true
          command.active  = true
          preview.visible = true
        end
      end
    end
    command.dispose
    preview.bitmap.dispose if preview.bitmap
    preview.dispose
    return chosenCards
  end

  def pbShowPlayerCards(cards)
    for i in 0...@battle.maxCards
      @sprites["player#{i}"] = Sprite.new(@viewport)
      @sprites["player#{i}"].x      = Graphics.width-92
      @sprites["player#{i}"].y      = 44+44*i
      @sprites["player#{i}"].z      = 2
      @sprites["player#{i}"].bitmap = TriadCard.new(cards[i]).createBitmap(1)
      @cardBitmaps.push(@sprites["player#{i}"].bitmap)
    end
  end

  def pbShowOpponentCards(cards)
    for i in 0...@battle.maxCards
      @sprites["opponent#{i}"] = Sprite.new(@viewport)
      @sprites["opponent#{i}"].x      = 12
      @sprites["opponent#{i}"].y      = 44+44*i
      @sprites["opponent#{i}"].z      = 2
      @sprites["opponent#{i}"].bitmap = @battle.openHand ? TriadCard.new(cards[i]).createBitmap(2) : TriadCard.createBack
      @opponentCardBitmaps.push(@sprites["opponent#{i}"].bitmap)
      @opponentCardIndexes.push(i)
    end
  end

  def pbViewOpponentCards(numCards)
    @sprites["helpwindow"].text = _INTL("Check opponent's cards.")
    choice     = 0
    lastChoice = -1
    loop do
      if lastChoice!=choice
        y = 44
        for i in 0...@opponentCardIndexes.length
          @sprites["opponent#{@opponentCardIndexes[i]}"].bitmap = @opponentCardBitmaps[@opponentCardIndexes[i]]
          @sprites["opponent#{@opponentCardIndexes[i]}"].x      = (i==choice) ? 28 : 12
          @sprites["opponent#{@opponentCardIndexes[i]}"].y      = y
          @sprites["opponent#{@opponentCardIndexes[i]}"].z      = 2
          y += 44
        end
        lastChoice = choice
      end
      break if choice==-1
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        choice += 1
        choice = 0 if choice>=numCards
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE
        choice -= 1
        choice = numCards-1 if choice<0
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        choice = -1
      end
    end
    return choice
  end

  def pbPlayerChooseCard(numCards)
    if @battle.openHand
      @sprites["helpwindow"].text = _INTL("Choose a card, or check opponent with Z.")
    else
      @sprites["helpwindow"].text = _INTL("Choose a card.")
    end
    choice     = 0
    lastChoice = -1
    loop do
      if lastChoice!=choice
        y = 44
        for i in 0...@cardIndexes.length
          @sprites["player#{@cardIndexes[i]}"].bitmap = @cardBitmaps[@cardIndexes[i]]
          @sprites["player#{@cardIndexes[i]}"].x      = (i==choice) ? Graphics.width-108 : Graphics.width-92
          @sprites["player#{@cardIndexes[i]}"].y      = y
          @sprites["player#{@cardIndexes[i]}"].z      = 2
          y += 44
        end
        lastChoice = choice
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        choice += 1
        choice = 0 if choice>=numCards
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE
        choice -= 1
        choice = numCards-1 if choice<0
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::ACTION) && @battle.openHand
        pbPlayDecisionSE
        pbViewOpponentCards(numCards)
        @sprites["helpwindow"].text = _INTL("Choose a card, or check opponent with Z.")
        choice     = 0
        lastChoice = -1
      end
    end
    return choice
  end

  def pbPlayerPlaceCard(cardIndex)
    @sprites["helpwindow"].text = _INTL("Place the card.")
    boardX = 0
    boardY = 0
    doRefresh = true
    loop do
      if doRefresh
        y = 44
        for i in 0...@cardIndexes.length
          if i==cardIndex   # Card being placed
            @sprites["player#{@cardIndexes[i]}"].x = Graphics.width/2 - 118 + boardX*78
            @sprites["player#{@cardIndexes[i]}"].y = 36 + boardY*94
            @sprites["player#{@cardIndexes[i]}"].z = 4
          else   # Other cards in hand
            @sprites["player#{@cardIndexes[i]}"].x = Graphics.width-92
            @sprites["player#{@cardIndexes[i]}"].y = y
            @sprites["player#{@cardIndexes[i]}"].z = 2
            y += 44
          end
        end
        doRefresh = false
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        boardY += 1
        boardY = 0 if boardY>=@battle.height
        doRefresh = true
      elsif Input.repeat?(Input::UP)
        pbPlayCursorSE
        boardY -= 1
        boardY = @battle.height-1 if boardY<0
        doRefresh = true
      elsif Input.repeat?(Input::LEFT)
        pbPlayCursorSE
        boardX -= 1
        boardX = @battle.width-1 if boardX<0
        doRefresh = true
      elsif Input.repeat?(Input::RIGHT)
        pbPlayCursorSE
        boardX += 1
        boardX = 0 if boardX>=@battle.width
        doRefresh = true
      elsif Input.trigger?(Input::BACK)
        return nil
      elsif Input.trigger?(Input::USE)
        if @battle.isOccupied?(boardX,boardY)
          pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          @sprites["player#{@cardIndexes[cardIndex]}"].z = 2
          break
        end
      end
    end
    return [boardX,boardY]
  end

  def pbEndPlaceCard(position, cardIndex)
    spriteIndex = @cardIndexes[cardIndex]
    boardIndex = position[1]*@battle.width+position[0]
    @boardSprites[boardIndex] = @sprites["player#{spriteIndex}"]
    @boardCards[boardIndex] = TriadCard.new(@playerCards[spriteIndex])
    pbRefresh
    @cardIndexes.delete_at(cardIndex)
    pbUpdateScore
  end

  def pbOpponentPlaceCard(triadCard, position, cardIndex)
    y = 44
    for i in 0...@opponentCardIndexes.length
      sprite = @sprites["opponent#{@opponentCardIndexes[i]}"]
      if i==cardIndex
        @opponentCardBitmaps[@opponentCardIndexes[i]] = triadCard.createBitmap(2)
        sprite.bitmap.dispose if sprite.bitmap
        sprite.bitmap = @opponentCardBitmaps[@opponentCardIndexes[i]]
        sprite.x = Graphics.width/2 - 118 + position[0]*78
        sprite.y = 36 + position[1]*94
        sprite.z = 2
      else
        sprite.x = 12
        sprite.y = y
        sprite.z = 2
        y += 44
      end
    end
  end

  def pbEndOpponentPlaceCard(position, cardIndex)
    spriteIndex = @opponentCardIndexes[cardIndex]
    boardIndex = position[1]*@battle.width+position[0]
    @boardSprites[boardIndex] = @sprites["opponent#{spriteIndex}"]
    @boardCards[boardIndex] = TriadCard.new(@opponentCards[spriteIndex])
    pbRefresh
    @opponentCardIndexes.delete_at(cardIndex)
    pbUpdateScore
  end

  def pbRefresh
    for i in 0...@battle.width*@battle.height
      x = i%@battle.width
      y = i/@battle.width
      if @boardSprites[i]
        owner = @battle.getOwner(x,y)
        @boardSprites[i].bitmap.dispose if @boardSprites[i].bitmap
        @boardSprites[i].bitmap = @boardCards[i].createBitmap(owner)
      end
    end
  end

  def pbUpdateScore
    bitmap = @sprites["score"].bitmap
    bitmap.clear
    playerscore = 0
    oppscore    = 0
    for i in 0...@battle.width*@battle.height
      if @boardSprites[i]
        playerscore += 1 if @battle.board[i].owner==1
        oppscore    += 1 if @battle.board[i].owner==2
      end
    end
    if @battle.countUnplayedCards
      playerscore += @cardIndexes.length
      oppscore    += @opponentCardIndexes.length
    end
    pbDrawTextPositions(bitmap,[
       [_INTL("{1}-{2}",oppscore,playerscore),Graphics.width/2,-2,2,Color.new(248,248,248),Color.new(96,96,96)]
    ])
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
end



#===============================================================================
# Duel screen logic
#===============================================================================
class TriadScreen
  attr_accessor :openHand, :countUnplayedCards
  attr_reader   :width, :height
  attr_reader   :board
  attr_reader   :playerName
  attr_reader   :opponentName

  def initialize(scene)
    @scene = scene
    @width              = 3
    @height             = 3
    @sameWins           = false
    @openHand           = false
    @wrapAround         = false
    @elements           = false
    @randomHand         = false
    @countUnplayedCards = false
    @trade              = 0
  end

  def maxCards
    numcards = @width*@height
    if numcards%2 == 1
      numcards = numcards/2+1
    else
      numcards = numcards/2
    end
    return numcards
  end

  def isOccupied?(x,y)
    return @board[y*@width+x].owner!=0
  end

  def getOwner(x,y)
    return @board[y*@width+x].owner
  end

  def getPanel(x,y)
    return @board[y*@width+x]
  end

  def pbQuantity(items,item)
    return ItemStorageHelper.pbQuantity(items, item)
  end

  def pbAdd(items,item)
    return ItemStorageHelper.pbStoreItem(items,$PokemonGlobal.triads.maxSize,
       $PokemonGlobal.triads.maxPerSlot,item,1)
  end

  def pbSubtract(items, item)
    return ItemStorageHelper.pbDeleteItem(items, item, 1)
  end

  def flipBoard(x,y,attackerParam=nil,recurse=false)
    panels = [x-1,y,x+1,y,x,y-1,x,y+1]
    panels[0] = (@wrapAround ? @width-1 : 0) if panels[0]<0            # left
    panels[2] = (@wrapAround ? 0 : @width-1) if panels[2]>@width-1     # right
    panels[5] = (@wrapAround ? @height-1 : 0) if panels[5]<0           # top
    panels[7] = (@wrapAround ? 0 : @height-1) if panels[7]>@height-1   # bottom
    attacker = attackerParam!=nil ? attackerParam : @board[y*@width+x]
    flips = []
    return nil if attackerParam!=nil && @board[y*@width+x].owner!=0
    return nil if !attacker.card || attacker.owner==0
    for i in 0...4
      defenderX = panels[i*2]
      defenderY = panels[i*2+1]
      defender  = @board[defenderY*@width+defenderX]
      next if !defender.card
      if attacker.owner!=defender.owner
        attack  = attacker.attack(i)
        defense = defender.defense(i)
        if @elements
          # If attacker's type matches the tile's element, add
          # a bonus of 1 (only for original attacker, not combos)
          attack += 1 if !recurse && attacker.type==attacker.card.type
        else
          # Modifier depends on opponent's Pokémon type:
          # +1 - Super effective
          # -1 - Not very effective
          # -2 - Immune
#         attack += attacker.bonus(defender)
        end
        if attack>defense || (attack==defense && @sameWins)
          flips.push([defenderX,defenderY])
          if attackerParam==nil
            defender.owner = attacker.owner
            if @sameWins
              # Combo with the "sameWins" rule
              ret = flipBoard(defenderX,defenderY,nil,true)
              flips.concat(ret) if ret
            end
          else
            if @sameWins
              # Combo with the "sameWins" rule
              ret = flipBoard(defenderX,defenderY,attackerParam,true)
              flips.concat(ret) if ret
            end
          end
        end
      end
    end
    return flips
  end

  # If pbStartScreen includes parameters, it should
  # pass the parameters to pbStartScene.
  def pbStartScreen(opponentName,minLevel,maxLevel,rules=nil,oppdeck=nil,prize=nil)
    raise _INTL("Minimum level must be 0 through 9.") if minLevel<0 || minLevel>9
    raise _INTL("Maximum level must be 0 through 9.") if maxLevel<0 || maxLevel>9
    raise _INTL("Maximum level shouldn't be less than the minimum level.") if maxLevel<minLevel
    if rules && rules.is_a?(Array) && rules.length>0
      for rule in rules
        @sameWins           = true if rule=="samewins"
        @openHand           = true if rule=="openhand"
        @wrapAround         = true if rule=="wrap"
        @elements           = true if rule=="elements"
        @randomHand         = true if rule=="randomhand"
        @countUnplayedCards = true if rule=="countunplayed"
        @trade              = 1    if rule=="direct"
        @trade              = 2    if rule=="winall"
        @trade              = 3    if rule=="noprize"
      end
    end
    @triadCards = []
    count = 0
    for i in 0...$PokemonGlobal.triads.length
      item = $PokemonGlobal.triads[i]
      ItemStorageHelper.pbStoreItem(@triadCards,
         $PokemonGlobal.triads.maxSize,
         $PokemonGlobal.triads.maxPerSlot,
         item[0],item[1]
      )
      count += item[1]   # Add item count to total count
    end
    @board = []
    @playerName   = $Trainer ? $Trainer.name : "Trainer"
    @opponentName = opponentName
    type_keys = GameData::Type::DATA.keys
    for i in 0...@width*@height
      square = TriadSquare.new
      if @elements
        loop do
          trial_type = type_keys[rand(type_keys.length)]
          type_data = GameData::Type.get(trial_type)
          next if type_data.pseudo_type
          square.type = type_data.id
          break
        end
      end
      @board.push(square)
    end
    @scene.pbStartScene(self)   # (param1, param2)
    # Check whether there are enough cards.
    if count<self.maxCards
      @scene.pbDisplayPaused(_INTL("You don't have enough cards."))
      @scene.pbEndScene
      return 0
    end
    # Set the player's cards.
    cards = []
    if @randomHand   # Determine hand at random
      self.maxCards.times do
        randCard = @triadCards[rand(@triadCards.length)]
        pbSubtract(@triadCards,randCard[0])
        cards.push(randCard[0])
      end
      @scene.pbShowPlayerCards(cards)
    else
      cards = @scene.pbChooseTriadCard(@triadCards)
    end
    # Set the opponent's cards.
    if oppdeck && oppdeck.is_a?(Array) && oppdeck.length==self.maxCards   # Preset
      opponentCards = []
      for i in oppdeck
        species_data = GameData::Species.try_get(i)
        if !species_data
          @scene.pbDisplayPaused(_INTL("Opponent has an illegal card, \"{1}\".",i))
          @scene.pbEndScene
          return 0
        end
        opponentCards.push(species_data.id)
      end
    else
      species_keys = GameData::Species::DATA.keys
      candidates = []
      while candidates.length < 200
        card = species_keys[rand(species_keys.length)]
        card_data = GameData::Species.get(card)
        card = card_data.id   # Make sure it's a symbol
        triad = TriadCard.new(card)
        total = triad.north + triad.south + triad.east + triad.west
        # Add random species and its total point count
        candidates.push([card, total])
        if candidates.length < 200 && $Trainer.owned?(card_data.species)
          # Add again if player owns the species
          candidates.push([card, total])
        end
      end
      # sort by total point count
      candidates.sort! { |a,b| a[1] <=> b[1] }
      opponentCards = []
      self.maxCards.times do
        # Choose random card from candidates based on trainer's level
        index = minLevel + rand(20)
        opponentCards.push(candidates[index][0])
      end
    end
    originalCards = cards.clone
    originalOpponentCards = opponentCards.clone
    @scene.pbNotifyCards(cards.clone,opponentCards.clone)
    @scene.pbShowOpponentCards(opponentCards)
    @scene.pbDisplay(_INTL("Choosing the starting player..."))
    @scene.pbUpdateScore
    playerTurn = (rand(2) == 0)
    @scene.pbDisplay(_INTL("{1} will go first.", (playerTurn) ? @playerName : @opponentName))
    for i in 0...@width*@height
      position = nil
      triadCard = nil
      cardIndex = 0
      if playerTurn
        # Player's turn
        while !position
          cardIndex = @scene.pbPlayerChooseCard(cards.length)
          triadCard = TriadCard.new(cards[cardIndex])
          position = @scene.pbPlayerPlaceCard(cardIndex)
        end
      else
        # Opponent's turn
        @scene.pbDisplay(_INTL("{1} is making a move...",@opponentName))
        scores = []
        for cardIndex in 0...opponentCards.length
          square = TriadSquare.new
          square.card = TriadCard.new(opponentCards[cardIndex])
          square.owner = 2
          for i in 0...@width*@height
            x = i % @width
            y = i / @width
            square.type = @board[i].type
            flips = flipBoard(x,y,square)
            if flips!=nil
              scores.push([cardIndex,x,y,flips.length])
            end
          end
        end
        # Sort by number of flips
        scores.sort! { |a,b| (b[3]==a[3]) ? rand(3)-1 : b[3]<=>a[3] }
        scores = scores[0,opponentCards.length]   # Get the best results
        if scores.length==0
          @scene.pbDisplay(_INTL("{1} can't move somehow...",@opponentName))
          playerTurn = !playerTurn
          continue
        end
        result = scores[rand(scores.length)]
        cardIndex = result[0]
        triadCard = TriadCard.new(opponentCards[cardIndex])
        position = [result[1],result[2]]
        @scene.pbOpponentPlaceCard(triadCard,position,cardIndex)
      end
      boardIndex = position[1]*@width+position[0]
      board[boardIndex].card  = triadCard
      board[boardIndex].owner = playerTurn ? 1 : 2
      flipBoard(position[0],position[1])
      if playerTurn
        cards.delete_at(cardIndex)
        @scene.pbEndPlaceCard(position,cardIndex)
      else
        opponentCards.delete_at(cardIndex)
        @scene.pbEndOpponentPlaceCard(position,cardIndex)
      end
      playerTurn = !playerTurn
    end
    # Determine the winner
    playerCount   = 0
    opponentCount = 0
    for i in 0...@width*@height
      playerCount   += 1 if board[i].owner==1
      opponentCount += 1 if board[i].owner==2
    end
    if @countUnplayedCards
      playerCount   += cards.length
      opponentCount += opponentCards.length
    end
    result = 0
    if playerCount==opponentCount
      @scene.pbDisplayPaused(_INTL("The game is a draw."))
      result = 3
      if @trade==1
        # Keep only cards of your color
        for card in originalCards
          $PokemonGlobal.triads.pbDeleteItem(card)
        end
        for i in cards
          $PokemonGlobal.triads.pbStoreItem(i)
        end
        for i in 0...@width*@height
          if board[i].owner==1
            card = GameData::Species.get_species_form(board[i].card.species, board[i].card.form).id
            $PokemonGlobal.triads.pbStoreItem(card)
          end
        end
        @scene.pbDisplayPaused(_INTL("Kept all cards of your color."))
      end
    elsif playerCount>opponentCount
      @scene.pbDisplayPaused(_INTL("{1} won against {2}.",@playerName,@opponentName))
      result = 1
      if prize
        species_data = GameData::Species.try_get(prize)
        if species_data && $PokemonGlobal.triads.pbStoreItem(species_data.id)
          @scene.pbDisplayPaused(_INTL("Got opponent's {1} card.", species_data.name))
        end
      else
        case @trade
        when 0   # Gain 1 random card from opponent's deck
          card = originalOpponentCards[rand(originalOpponentCards.length)]
          if $PokemonGlobal.triads.pbStoreItem(card)
            cardname = GameData::Species.get(card).name
            @scene.pbDisplayPaused(_INTL("Got opponent's {1} card.",cardname))
          end
        when 1   # Keep only cards of your color
          for card in originalCards
            $PokemonGlobal.triads.pbDeleteItem(card)
          end
          for i in cards
            $PokemonGlobal.triads.pbStoreItem(i)
          end
          for i in 0...@width*@height
            if board[i].owner==1
              card = GameData::Species.get_species_form(board[i].card.species, board[i].card.form).id
              $PokemonGlobal.triads.pbStoreItem(card)
            end
          end
          @scene.pbDisplayPaused(_INTL("Kept all cards of your color."))
        when 2   # Gain all opponent's cards
          for card in originalOpponentCards
            $PokemonGlobal.triads.pbStoreItem(card)
          end
          @scene.pbDisplayPaused(_INTL("Got all opponent's cards."))
        end
      end
    else
      @scene.pbDisplayPaused(_INTL("{1} lost against {2}.",@playerName,@opponentName))
      result = 2
      case @trade
      when 0   # Lose 1 random card from your deck
        card = originalCards[rand(originalCards.length)]
        $PokemonGlobal.triads.pbDeleteItem(card)
        cardname = GameData::Species.get(card).name
        @scene.pbDisplayPaused(_INTL("Opponent won your {1} card.",cardname))
      when 1   # Keep only cards of your color
        for card in originalCards
          $PokemonGlobal.triads.pbDeleteItem(card)
        end
        for i in cards
          $PokemonGlobal.triads.pbStoreItem(i)
        end
        for i in 0...@width*@height
          if board[i].owner==1
            card = GameData::Species.get_species_form(board[i].card.species, board[i].card.form).id
            $PokemonGlobal.triads.pbStoreItem(card)
          end
        end
        @scene.pbDisplayPaused(_INTL("Kept all cards of your color.",cardname))
      when 2   # Lose all your cards
        for card in originalCards
          $PokemonGlobal.triads.pbDeleteItem(card)
        end
        @scene.pbDisplayPaused(_INTL("Opponent won all your cards."))
      end
    end
    @scene.pbEndScene
    return result
  end
end



#===============================================================================
# Start duel
#===============================================================================
def pbTriadDuel(name,minLevel,maxLevel,rules=nil,oppdeck=nil,prize=nil)
  ret = 0
  pbFadeOutInWithMusic {
    scene = TriadScene.new
    screen = TriadScreen.new(scene)
    ret = screen.pbStartScreen(name,minLevel,maxLevel,rules,oppdeck,prize)
  }
  return ret
end



#===============================================================================
# Card storage
#===============================================================================
class PokemonGlobalMetadata
  attr_writer :triads

  def triads
    @triads = TriadStorage.new if !@triads
    return @triads
  end
end



class TriadStorage
  attr_reader :items

  def initialize
    @items = []
  end

  def maxSize
    return @items.length + 1
  end

  def maxPerSlot
    return 999
  end

  def empty?
    return @items.length == 0
  end

  def length
    return @items.length
  end

  def [](i)
    return @items[i]
  end

  def getItem(index)
    return nil if index < 0 || index >= @items.length
    return @items[index][0]
  end

  def getCount(index)
    return 0 if index < 0 || index >= @items.length
    return @items[index][1]
  end

  def pbQuantity(item)
    return ItemStorageHelper.pbQuantity(@items, item)
  end

  def pbCanStore?(item, qty = 1)
    return ItemStorageHelper.pbCanStore?(@items, self.maxSize, self.maxPerSlot, item, qty)
  end

  def pbStoreItem(item, qty = 1)
    return ItemStorageHelper.pbStoreItem(@items, self.maxSize, self.maxPerSlot, item, qty)
  end

  def pbDeleteItem(item, qty = 1)
    return ItemStorageHelper.pbDeleteItem(@items, item, qty)
  end
end



#===============================================================================
# Card shop screen
#===============================================================================
def pbBuyTriads
  commands = []
  realcommands = []
  GameData::Species.each do |s|
    next if s.form != 0
    next if !$Trainer.owned?(s.species)
    price = TriadCard.new(s.id).price
    commands.push([price, s.name, _INTL("{1} - ${2}", s.name, price.to_s_formatted), s.id])
  end
  if commands.length == 0
    pbMessage(_INTL("There are no cards that you can buy."))
    return
  end
  commands.sort! { |a, b| a[1] <=> b[1] }   # Sort alphabetically
  for command in commands
    realcommands.push(command[2])
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow = Window_CommandPokemonEx.newWithSize(realcommands,0,0,Graphics.width/2,Graphics.height)
  cmdwindow.z = 99999
  goldwindow = Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\r\n{1}",pbGetGoldString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.x = Graphics.width-goldwindow.width
  goldwindow.y = 0
  goldwindow.z = 99999
  preview = Sprite.new
  preview.x = Graphics.width*3/4-40
  preview.y = Graphics.height/2-48
  preview.z = 4
  preview.bitmap = TriadCard.new(commands[cmdwindow.index][3]).createBitmap(1)
  olditem = commands[cmdwindow.index][3]
  Graphics.frame_reset
  loop do
    Graphics.update
    Input.update
    cmdwindow.active = true
    cmdwindow.update
    goldwindow.update
    if commands[cmdwindow.index][3]!=olditem
      preview.bitmap.dispose if preview.bitmap
      preview.bitmap = TriadCard.new(commands[cmdwindow.index][3]).createBitmap(1)
      olditem = commands[cmdwindow.index][3]
    end
    if Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::USE)
      price    = commands[cmdwindow.index][0]
      item     = commands[cmdwindow.index][3]
      itemname = commands[cmdwindow.index][1]
      cmdwindow.active = false
      cmdwindow.update
      if $Trainer.money<price
        pbMessage(_INTL("You don't have enough money."))
        next
      end
      maxafford = (price<=0) ? 99 : $Trainer.money/price
      maxafford = 99 if maxafford>99
      params = ChooseNumberParams.new
      params.setRange(1,maxafford)
      params.setInitialValue(1)
      params.setCancelValue(0)
      quantity = pbMessageChooseNumber(
         _INTL("The {1} card? Certainly. How many would you like?",itemname),params)
      next if quantity<=0
      price *= quantity
      next if !pbConfirmMessage(_INTL("{1}, and you want {2}. That will be ${3}. OK?",itemname,quantity,price.to_s_formatted))
      if $Trainer.money<price
        pbMessage(_INTL("You don't have enough money."))
        next
      end
      if !$PokemonGlobal.triads.pbCanStore?(item,quantity)
        pbMessage(_INTL("You have no room for more cards."))
        next
      end
      $PokemonGlobal.triads.pbStoreItem(item,quantity)
      $Trainer.money -= price
      goldwindow.text = _INTL("Money:\r\n{1}",pbGetGoldString)
      pbMessage(_INTL("Here you are! Thank you!\\se[Mart buy item]"))
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  preview.bitmap.dispose if preview.bitmap
  preview.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end

def pbSellTriads
  commands = []
  for i in 0...$PokemonGlobal.triads.length
    item = $PokemonGlobal.triads[i]
    speciesname = GameData::Species.get(item[0]).name
    commands.push(_INTL("{1} x{2}", speciesname, item[1]))
  end
  commands.push(_INTL("CANCEL"))
  if commands.length==1
    pbMessage(_INTL("You have no cards."))
    return
  end
  # Scroll right before showing screen
  pbScrollMap(4,3,5)
  cmdwindow = Window_CommandPokemonEx.newWithSize(commands,0,0,Graphics.width/2,Graphics.height)
  cmdwindow.z = 99999
  goldwindow = Window_UnformattedTextPokemon.newWithSize(
     _INTL("Money:\r\n{1}",pbGetGoldString),0,0,32,32)
  goldwindow.resizeToFit(goldwindow.text,Graphics.width)
  goldwindow.x = Graphics.width-goldwindow.width
  goldwindow.y = 0
  goldwindow.z = 99999
  preview = Sprite.new
  preview.x = Graphics.width*3/4-40
  preview.y = Graphics.height/2-48
  preview.z = 4
  item = $PokemonGlobal.triads.getItem(cmdwindow.index)
  preview.bitmap = TriadCard.new(item).createBitmap(1)
  olditem = $PokemonGlobal.triads.getItem(cmdwindow.index)
  done = false
  Graphics.frame_reset
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.active = true
      cmdwindow.update
      goldwindow.update
      item = $PokemonGlobal.triads.getItem(cmdwindow.index)
      if olditem != item
        preview.bitmap.dispose if preview.bitmap
        if item
          preview.bitmap = TriadCard.new(item).createBitmap(1)
        end
        olditem = item
      end
      if Input.trigger?(Input::BACK)
        done = true
        break
      end
      if Input.trigger?(Input::USE)
        if cmdwindow.index>=$PokemonGlobal.triads.length
          done = true
          break
        end
        item = $PokemonGlobal.triads.getItem(cmdwindow.index)
        itemname = GameData::Species.get(item).name
        quantity = $PokemonGlobal.triads.pbQuantity(item)
        price = TriadCard.new(item).price
        if price==0
          pbDisplayPaused(_INTL("The {1} card? Oh, no. I can't buy that.",itemname))
          break
        end
        cmdwindow.active = false
        cmdwindow.update
        if quantity>1
          params = ChooseNumberParams.new
          params.setRange(1,quantity)
          params.setInitialValue(1)
          params.setCancelValue(0)
          quantity = pbMessageChooseNumber(
             _INTL("The {1} card? How many would you like to sell?",itemname),params)
        end
        if quantity>0
          price /= 4
          price *= quantity
          if pbConfirmMessage(_INTL("I can pay ${1}. Would that be OK?",price.to_s_formatted))
            $Trainer.money += price
            goldwindow.text = _INTL("Money:\r\n{1}",pbGetGoldString)
            $PokemonGlobal.triads.pbDeleteItem(item,quantity)
            pbMessage(_INTL("Turned over the {1} card and received ${2}.\\se[Mart buy item]",itemname,price.to_s_formatted))
            commands = []
            for i in 0...$PokemonGlobal.triads.length
              item = $PokemonGlobal.triads[i]
              speciesname = GameData::Species.get(item[0]).name
              commands.push(_INTL("{1} x{2}",speciesname,item[1]))
            end
            commands.push(_INTL("CANCEL"))
            cmdwindow.commands = commands
            break
          end
        end
      end
    end
  end
  cmdwindow.dispose
  goldwindow.dispose
  preview.bitmap.dispose if preview.bitmap
  preview.dispose
  Graphics.frame_reset
  # Scroll right before showing screen
  pbScrollMap(6,3,5)
end

def pbTriadList
  commands = []
  for i in 0...$PokemonGlobal.triads.length
    item = $PokemonGlobal.triads[i]
    speciesname = GameData::Species.get(item[0]).name
    commands.push(_INTL("{1} x{2}",speciesname,item[1]))
  end
  commands.push(_INTL("CANCEL"))
  if commands.length==1
    pbMessage(_INTL("You have no cards."))
    return
  end
  cmdwindow = Window_CommandPokemonEx.newWithSize(commands,0,0,Graphics.width/2,Graphics.height)
  cmdwindow.z = 99999
  sprite = Sprite.new
  sprite.x = Graphics.width/2+40
  sprite.y = 48
  sprite.z = 99999
  done = false
  lastIndex = -1
  while !done
    loop do
      Graphics.update
      Input.update
      cmdwindow.update
      if lastIndex!=cmdwindow.index
        sprite.bitmap.dispose if sprite.bitmap
        if cmdwindow.index<$PokemonGlobal.triads.length
          sprite.bitmap = TriadCard.new($PokemonGlobal.triads.getItem(cmdwindow.index)).createBitmap(1)
        end
        lastIndex = cmdwindow.index
      end
      if Input.trigger?(Input::BACK)
        done = true
        break
      end
      if Input.trigger?(Input::USE)
        if cmdwindow.index>=$PokemonGlobal.triads.length
          done = true
          break
        end
      end
    end
  end
  cmdwindow.dispose
  sprite.dispose
end

#===============================================================================
# Give the player a particular card
#===============================================================================
def pbGiveTriadCard(species, quantity = 1)
  sp = GameData::Species.try_get(species)
  return false if !sp
  return false if !$PokemonGlobal.triads.pbCanStore?(sp.id, quantity)
  $PokemonGlobal.triads.pbStoreItem(sp.id, quantity)
  return true
end
