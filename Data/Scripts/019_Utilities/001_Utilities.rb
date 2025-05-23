#===============================================================================
# General purpose utilities
#===============================================================================
def _pbNextComb(comb,length)
  i = comb.length-1
  begin
    valid = true
    for j in i...comb.length
      if j==i
        comb[j] += 1
      else
        comb[j] = comb[i]+(j-i)
      end
      if comb[j]>=length
        valid = false
        break
      end
    end
    return true if valid
    i -= 1
  end while i>=0
  return false
end

# Iterates through the array and yields each combination of _num_ elements in
# the array.
def pbEachCombination(array,num)
  return if array.length<num || num<=0
  if array.length==num
    yield array
    return
  elsif num==1
    for x in array
      yield [x]
    end
    return
  end
  currentComb = []
  arr = []
  for i in 0...num
    currentComb[i] = i
  end
  begin
    for i in 0...num
      arr[i] = array[currentComb[i]]
    end
    yield arr
  end while _pbNextComb(currentComb,array.length)
end

# Returns a language ID
def pbGetLanguage()
  case System.user_language[0..1]
  when "ja" then return 1   # Japanese
  when "en" then return 2   # English
  when "fr" then return 3   # French
  when "it" then return 4   # Italian
  when "de" then return 5   # German
  when "es" then return 7   # Spanish
  when "ko" then return 8   # Korean
  end
  return 2 # Use 'English' by default
end

# Converts a Celsius temperature to Fahrenheit.
def toFahrenheit(celsius)
  return (celsius*9.0/5.0).round+32
end

# Converts a Fahrenheit temperature to Celsius.
def toCelsius(fahrenheit)
  return ((fahrenheit-32)*5.0/9.0).round
end



#===============================================================================
# Constants utilities
#===============================================================================
# Unused
def isConst?(val,mod,constant)
  begin
    return false if !mod.const_defined?(constant.to_sym)
  rescue
    return false
  end
  return (val==mod.const_get(constant.to_sym))
end

# Unused
def hasConst?(mod,constant)
  return false if !mod || constant.nil?
  return mod.const_defined?(constant.to_sym) rescue false
end

# Unused
def getConst(mod,constant)
  return nil if !mod || constant.nil?
  return mod.const_get(constant.to_sym) rescue nil
end

# Unused
def getID(mod,constant)
  return nil if !mod || constant.nil?
  if constant.is_a?(Symbol) || constant.is_a?(String)
    if (mod.const_defined?(constant.to_sym) rescue false)
      return mod.const_get(constant.to_sym) rescue 0
    end
    return 0
  end
  return constant
end

def getConstantName(mod,value)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  for c in mod.constants
    return c.to_s if mod.const_get(c.to_sym)==value
  end
  raise _INTL("Value {1} not defined by a constant in {2}",value,mod.name)
end

def getConstantNameOrValue(mod,value)
  mod = Object.const_get(mod) if mod.is_a?(Symbol)
  for c in mod.constants
    return c.to_s if mod.const_get(c.to_sym)==value
  end
  return value.inspect
end



#===============================================================================
# Event utilities
#===============================================================================
def pbTimeEvent(variableNumber,secs=86400)
  if variableNumber && variableNumber>=0
    if $game_variables
      secs = 0 if secs<0
      timenow = pbGetTimeNow
      $game_variables[variableNumber] = [timenow.to_f,secs]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventDays(variableNumber,days=0)
  if variableNumber && variableNumber>=0
    if $game_variables
      days = 0 if days<0
      timenow = pbGetTimeNow
      time = timenow.to_f
      expiry = (time%86400.0)+(days*86400.0)
      $game_variables[variableNumber] = [time,expiry-time]
      $game_map.refresh if $game_map
    end
  end
end

def pbTimeEventValid(variableNumber)
  retval = false
  if variableNumber && variableNumber>=0 && $game_variables
    value = $game_variables[variableNumber]
    if value.is_a?(Array)
      timenow = pbGetTimeNow
      retval = (timenow.to_f - value[0] > value[1]) # value[1] is age in seconds
      retval = false if value[1]<=0 # zero age
    end
    if !retval
      $game_variables[variableNumber] = 0
      $game_map.refresh if $game_map
    end
  end
  return retval
end

def pbExclaim(event,id=Settings::EXCLAMATION_ANIMATION_ID,tinting=false)
  if event.is_a?(Array)
    sprite = nil
    done = []
    for i in event
      if !done.include?(i.id)
        sprite = $scene.spriteset.addUserAnimation(id,i.x,i.y,tinting,2)
        done.push(i.id)
      end
    end
  else
    sprite = $scene.spriteset.addUserAnimation(id,event.x,event.y,tinting,2)
  end
  while !sprite.disposed?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
end

def pbNoticePlayer(event)
  if !pbFacingEachOther(event,$game_player)
    pbExclaim(event)
  end
  pbTurnTowardEvent($game_player,event)
  pbMoveTowardPlayer(event)
end



#===============================================================================
# Player-related utilities, random name generator
#===============================================================================
# Unused
def pbGetPlayerGraphic
  id = $Trainer.character_ID
  return "" if id < 0 || id >= 8
  meta = GameData::Metadata.get_player(id)
  return "" if !meta
  return GameData::TrainerType.player_front_sprite_filename(meta[0])
end

def pbGetTrainerTypeGender(trainer_type)
  return GameData::TrainerType.get(trainer_type).gender
end

def pbChangePlayer(id)
  return false if id < 0 || id >= 8
  meta = GameData::Metadata.get_player(id)
  return false if !meta
  $Trainer.character_ID = id
  $Trainer.trainer_type = meta[0]
  $game_player.character_name = meta[1]
end

def pbTrainerName(name = nil, outfit = 0)
  pbChangePlayer(0) if $Trainer.character_ID < 0
  if name.nil?
    name = pbEnterPlayerName(_INTL("Your name?"), 0, Settings::MAX_PLAYER_NAME_SIZE)
    if name.nil? || name.empty?
      player_metadata = GameData::Metadata.get_player($Trainer.character_ID)
      trainer_type = (player_metadata) ? player_metadata[0] : nil
      gender = pbGetTrainerTypeGender(trainer_type)
      name = pbSuggestTrainerName(gender)
    end
  end
  $Trainer.name   = name
  $Trainer.outfit = outfit
  $PokemonTemp.begunNewGame = true
end

def pbSuggestTrainerName(gender)
  userName = pbGetUserName()
  userName = userName.gsub(/\s+.*$/,"")
  if userName.length>0 && userName.length<Settings::MAX_PLAYER_NAME_SIZE
    userName[0,1] = userName[0,1].upcase
    return userName
  end
  userName = userName.gsub(/\d+$/,"")
  if userName.length>0 && userName.length<Settings::MAX_PLAYER_NAME_SIZE
    userName[0,1] = userName[0,1].upcase
    return userName
  end
  userName = System.user_name.capitalize
  userName = userName[0, Settings::MAX_PLAYER_NAME_SIZE]
  return userName
  # Unreachable
#  return getRandomNameEx(gender, nil, 1, Settings::MAX_PLAYER_NAME_SIZE)
end

def pbGetUserName
  return System.user_name
end

def getRandomNameEx(type,variable,upper,maxLength=100)
  return "" if maxLength<=0
  name = ""
  50.times {
    name = ""
    formats = []
    case type
    when 0 then formats = %w( F5 BvE FE FE5 FEvE )              # Names for males
    when 1 then formats = %w( vE6 vEvE6 BvE6 B4 v3 vEv3 Bv3 )   # Names for females
    when 2 then formats = %w( WE WEU WEvE BvE BvEU BvEvE )      # Neutral gender names
    else        return ""
    end
    format = formats[rand(formats.length)]
    format.scan(/./) { |c|
      case c
      when "c" # consonant
        set = %w( b c d f g h j k l m n p r s t v w x z )
        name += set[rand(set.length)]
      when "v" # vowel
        set = %w( a a a e e e i i i o o o u u u )
        name += set[rand(set.length)]
      when "W" # beginning vowel
        set = %w( a a a e e e i i i o o o u u u au au ay ay ea ea ee ee oo oo ou ou )
        name += set[rand(set.length)]
      when "U" # ending vowel
        set = %w( a a a a a e e e i i i o o o o o u u ay ay ie ie ee ue oo )
        name += set[rand(set.length)]
      when "B" # beginning consonant
        set1 = %w( b c d f g h j k l l m n n p r r s s t t v w y z )
        set2 = %w( bl br ch cl cr dr fr fl gl gr kh kl kr ph pl pr sc sk sl
           sm sn sp st sw th tr tw vl zh )
        name += (rand(3)>0) ? set1[rand(set1.length)] : set2[rand(set2.length)]
      when "E" # ending consonant
        set1 = %w( b c d f g h j k k l l m n n p r r s s t t v z )
        set2 = %w( bb bs ch cs ds fs ft gs gg ld ls nd ng nk rn kt ks
           ms ns ph pt ps sk sh sp ss st rd rn rp rm rt rk ns th zh)
        name += (rand(3)>0) ? set1[rand(set1.length)] : set2[rand(set2.length)]
      when "f" # consonant and vowel
        set = %w( iz us or )
        name += set[rand(set.length)]
      when "F" # consonant and vowel
        set = %w( bo ba be bu re ro si mi zho se nya gru gruu glee gra glo ra do zo ri
           di ze go ga pree pro po pa ka ki ku de da ma mo le la li )
        name += set[rand(set.length)]
      when "2"
        set = %w( c f g k l p r s t )
        name += set[rand(set.length)]
      when "3"
        set = %w( nka nda la li ndra sta cha chie )
        name += set[rand(set.length)]
      when "4"
        set = %w( una ona ina ita ila ala ana ia iana )
        name += set[rand(set.length)]
      when "5"
        set = %w( e e o o ius io u u ito io ius us )
        name += set[rand(set.length)]
      when "6"
        set = %w( a a a elle ine ika ina ita ila ala ana )
        name += set[rand(set.length)]
      end
    }
    break if name.length<=maxLength
  }
  name = name[0,maxLength]
  case upper
  when 0 then name = name.upcase
  when 1 then name[0, 1] = name[0, 1].upcase
  end
  if $game_variables && variable
    $game_variables[variable] = name
    $game_map.need_refresh = true if $game_map
  end
  return name
end

def getRandomName(maxLength=100)
  return getRandomNameEx(2,nil,nil,maxLength)
end



#===============================================================================
# Regional and National Pokédexes utilities
#===============================================================================
# Returns the ID number of the region containing the player's current location,
# as determined by the current map's metadata.
def pbGetCurrentRegion(default = -1)
  return default if !$game_map
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  map_pos = (map_metadata) ? map_metadata.town_map_position : nil
  return (map_pos) ? map_pos[0] : default
end

# Returns the Regional Pokédex number of the given species in the given Regional
# Dex. The parameter "region" is zero-based. For example, if two regions are
# defined, they would each be specified as 0 and 1.
def pbGetRegionalNumber(region, species)
  dex_list = pbLoadRegionalDexes[region]
  return 0 if !dex_list || dex_list.length == 0
  species_data = GameData::Species.try_get(species)
  return 0 if !species_data
  dex_list.each_with_index do |s, index|
    return index + 1 if s == species_data.species
  end
  return 0
end

# Returns an array of all species in the given Regional Dex in that Dex's order.
def pbAllRegionalSpecies(region_dex)
  return nil if region_dex < 0
  dex_list = pbLoadRegionalDexes[region_dex]
  return nil if !dex_list || dex_list.length == 0
  return dex_list.clone
end

# Returns the number of species in the given Regional Dex. Returns 0 if that
# Regional Dex doesn't exist. If region_dex is a negative number, returns the
# number of species in the National Dex (i.e. all species).
def pbGetRegionalDexLength(region_dex)
  if region_dex < 0
    ret = 0
    GameData::Species.each { |s| ret += 1 if s.form == 0 }
    return ret
  end
  dex_list = pbLoadRegionalDexes[region_dex]
  return (dex_list) ? dex_list.length : 0
end



#===============================================================================
# Other utilities
#===============================================================================
def pbTextEntry(helptext,minlength,maxlength,variableNumber)
  $game_variables[variableNumber] = pbEnterText(helptext,minlength,maxlength)
  $game_map.need_refresh = true if $game_map
end

def pbMoveTutorAnnotations(move, movelist = nil)
  ret = []
  $Trainer.party.each_with_index do |pkmn, i|
    if pkmn.egg?
      ret[i] = _INTL("NOT ABLE")
    elsif pkmn.hasMove?(move)
      ret[i] = _INTL("LEARNED")
    else
      species = pkmn.species
      if movelist && movelist.any? { |j| j == species }
        # Checked data from movelist given in parameter
        ret[i] = _INTL("ABLE")
      elsif pkmn.compatible_with_move?(move)
        # Checked data from Pokémon's tutor moves in pokemon.txt
        ret[i] = _INTL("ABLE")
      else
        ret[i] = _INTL("NOT ABLE")
      end
    end
  end
  return ret
end

def pbMoveTutorChoose(move,movelist=nil,bymachine=false,oneusemachine=false)
  ret = false
  move = GameData::Move.get(move).id
  if movelist!=nil && movelist.is_a?(Array)
    for i in 0...movelist.length
      movelist[i] = GameData::Move.get(movelist[i]).id
    end
  end
  pbFadeOutIn {
    movename = GameData::Move.get(move).name
    annot = pbMoveTutorAnnotations(move,movelist)
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
    loop do
      chosen = screen.pbChoosePokemon
      break if chosen<0
      pokemon = $Trainer.party[chosen]
      if pokemon.egg?
        pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
      elsif pokemon.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
      elsif movelist && !movelist.any? { |j| j==pokemon.species }
        pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
      elsif !pokemon.compatible_with_move?(move)
        pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
      else
        if pbLearnMove(pokemon,move,false,bymachine) { screen.pbUpdate }
          pokemon.add_first_move(move) if oneusemachine && Settings::RELEARNABLE_TR_MOVES
          ret = true
          break
        end
      end
    end
    screen.pbEndScene
  }
  return ret   # Returns whether the move was learned by a Pokemon
end

def pbConvertItemToItem(variable, array)
  item = GameData::Item.get(pbGet(variable))
  pbSet(variable, nil)
  for i in 0...(array.length/2)
    next if item != array[2 * i]
    pbSet(variable, array[2 * i + 1])
    return
  end
end

def pbConvertItemToPokemon(variable, array)
  item = GameData::Item.get(pbGet(variable))
  pbSet(variable, nil)
  for i in 0...(array.length / 2)
    next if item != array[2 * i]
    pbSet(variable, GameData::Species.get(array[2 * i + 1]).id)
    return
  end
end

# Gets the value of a variable.
def pbGet(id)
  return 0 if !id || !$game_variables
  return $game_variables[id]
end

# Sets the value of a variable.
def pbSet(id,value)
  return if !id || id<0
  $game_variables[id] = value if $game_variables
  $game_map.need_refresh = true if $game_map
end

# Runs a common event and waits until the common event is finished.
# Requires the script "Messages"
def pbCommonEvent(id)
  return false if id<0
  ce = $data_common_events[id]
  return false if !ce
  celist = ce.list
  interp = Interpreter.new
  interp.setup(celist,0)
  begin
    Graphics.update
    Input.update
    interp.update
    pbUpdateSceneMap
  end while interp.running?
  return true
end

def pbHideVisibleObjects
  visibleObjects = []
  ObjectSpace.each_object(Sprite) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Viewport) { |o|
    if !pbDisposed?(o) && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Plane) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Tilemap) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  ObjectSpace.each_object(Window) { |o|
    if !o.disposed? && o.visible
      visibleObjects.push(o)
      o.visible = false
    end
  }
  return visibleObjects
end

def pbShowObjects(visibleObjects)
  for o in visibleObjects
    next if pbDisposed?(o)
    o.visible = true
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene = $scene
  $scene = scene
  Graphics.freeze
  oldscene.disposeSpritesets
  visibleObjects = pbHideVisibleObjects
  Graphics.transition(20)
  Graphics.freeze
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition(20)
  Graphics.freeze
  $scene = oldscene
  $scene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition(20)
end

def pbChooseLanguage
  commands=[]
  for lang in Settings::LANGUAGES
    commands.push(lang[0])
  end
  return pbShowCommands(nil,commands)
end

def pbScreenCapture
  t = pbGetTimeNow
  filestart = t.strftime("[%Y-%m-%d] %H_%M_%S.%L")
  capturefile = RTP.getSaveFileName(sprintf("%s.png", filestart))
  Graphics.screenshot(capturefile)
  pbSEPlay("Pkmn exp full") if FileTest.audio_exist?("Audio/SE/Pkmn exp full")
end

# Toca o cry de um pokemon selvagem e inicia uma batalha.
def pbStaticPokemonBattle(species, canRun = true, canLose = false)
  AutomaticLevelScaling.setTemporarySetting("automaticEvolutions", false)
  Pokemon.play_cry(species)
  pbWildBattle(species, 1, 1, canRun, canLose)
end

def pbGetBossLevel
  levelIncrease = 0
  case pbGet(LevelScalingSettings::TRAINER_VARIABLE)
  when 1
    levelIncrease = 5
  when 2
    levelIncrease = 10
  else
    levelIncrease = 20
  end

  return (AutomaticLevelScaling.getScaledLevel + levelIncrease).clamp(1, GameData::GrowthRate.max_level)
end

# Toca o cry de um pokemon selvagem e inicia uma batalha no modo boss do EBDX.
def pbStaticBossBattle(species, partySize = 6, canCatch = true)
  AutomaticLevelScaling.setTemporarySetting("automaticEvolutions", false)
  Pokemon.play_cry(species)

  difficulty = pbGet(LevelScalingSettings::WILD_VARIABLE)
  pbSet(LevelScalingSettings::WILD_VARIABLE, 0)

  EliteBattle.bossBattle(
    species,
    pbGetBossLevel(),
    partySize,
    canCatch
  )

  pbSet(LevelScalingSettings::WILD_VARIABLE, difficulty)
end

def pbVolcaronaBattle
  setBattleRule("canLose")

  EliteBattle.add_data(
    :VOLCARONAP,
    :TRANSITION,
    "bwLegendary"
  )

  difficulty = pbGet(LevelScalingSettings::WILD_VARIABLE)
  pbSet(LevelScalingSettings::WILD_VARIABLE, 0)

  EliteBattle.bossBattle(
    :VOLCARONAP,
    (pbGetBossLevel() + 5).clamp(1, GameData::GrowthRate.max_level),
    6,
    true,
    {
      :ability => :MAGICGUARD,
      :item => :CHARTIBERRY,
      :moves => [ :QUIVERDANCE, :HEATWAVE, :FROSTBREATH, :GIGADRAIN ]
    }
  )

  pbSet(LevelScalingSettings::WILD_VARIABLE, difficulty)
end

# Ativa o efeito do HM Flash.
def activateFlash
  darkness = $PokemonTemp.darknessSprite
  $PokemonGlobal.flashUsed = true
  radiusDiff = 8*20/Graphics.frame_rate
  while darkness.radius < darkness.radiusMax
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += radiusDiff
    darkness.radius = darkness.radiusMax if darkness.radius > darkness.radiusMax
  end
end

# Retorna true caso o último pokemon selvagem enfrentado tenha sido capturado ou derrotado.
def wonBattle?(outcomeVar = 1)
  # Resultados possíveis:
  # 0 - Undecided or aborted.
  # 1 - Player won (the wild Pokémon fainted).
  # 2 - Player lost.
  # 3 - Player or wild Pokémon ran from battle.
  # 4 - Wild Pokémon was caught.
  # 5 - Draw.
  # Capturar ou derrotar o pokemon é considerado vitória.
  return pbGet(outcomeVar) == 1 || pbGet(outcomeVar) == 4
end

# Adiciona um pokemon à party a partir do nível da dificuldade selecionada
def pbAddScaledPokemon(species)
  pbAddPokemon(species, AutomaticLevelScaling.getScaledLevel)
end

# Função para escolher um líder de ginásio para enfrentar no Battle Subway
def getRandomGymLeader(exclude = {})
  gymLeaders = {
    :LEADER_Cheren => "Cheren",
    :LEADER_Lenora => "Lenora",
    :LEADER_Roxie => "Roxie",
    :LEADER_Burgh => "Burgh",
    :LEADER_Clay => "Clay",
    :LEADER_Skyla => "Skyla",
    :LEADER_Brycen => "Brycen",
    :LEADER_Drayden => "Drayden",
    :LEADER_Marlon => "Marlon"
  }

  exclude.each { |key, value|
    gymLeaders.delete(key)
  }

  return 0 if gymLeaders.length == 0
  selectedLeader = rand(gymLeaders.length)
  return [
    gymLeaders.keys[selectedLeader],  # Trainer class
    gymLeaders.values[selectedLeader] # Trainer name
  ]
end

def caughtAllPokemonInRoute4?
  speciesFamilies = [
    [:SANDILE, :KROKOROK, :KROOKODILE],
    [:DARUMAKA, :DARMANITAN],
    [:DRILBUR, :EXCADRILL],
    [:TIMBURR, :GURDURR, :CONKELDURR],
    [:GROWLITHE, :ARCANINE],
    [:ROGGENROLA, :BOLDORE, :GIGALITH],
    [:RUFFLET, :BRAVIARY],
    [:RUFFLET, :GURDURR, :CONKELDURR],
    [:RIOLU, :LUCARIO],
  ]

  for speciesFamily in speciesFamilies
    speciesCaptured = false

    for species in speciesFamily
      if $Trainer.owned?(species)
        speciesCaptured = true
      end
    end

    return false if !speciesCaptured
  end

  return true
end

def caughtAllPandemoniumPokemon?
  speciesFamilies = [
    [:CHARMANDERP, :CHARMELEONP, :CHARIZARDP],
    [:ABSOLP],
    [:DIGLETTP, :DUGTRIOP],
    [:YAMASKP, :YAMASKP_1, :YAMASKP_2],
    [:PUPLIN, :PRINPLIN, :PULINPUPLIN],
    [:VOLCARONAP],
  ]

  for speciesFamily in speciesFamilies
    speciesCaptured = false

    for species in speciesFamily
      if $Trainer.owned?(species)
        speciesCaptured = true
      end
    end

    return false if !speciesCaptured
  end

  return true
end

def removeAllPandemoniumPokemon(includeMeloetta = true)
  speciesFamilies = [
    [:CHARMANDERP, :CHARMELEONP, :CHARIZARDP],
    [:ABSOLP],
    [:DIGLETTP, :DUGTRIOP],
    [:YAMASKP],
    [:PUPLIN, :PRINPLIN, :PULINPUPLIN],
    [:VOLCARONAP],
  ]
  speciesFamilies.push([:MELOETTA]) if includeMeloetta

  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      pkmn = $PokemonStorage[i][j]
      next if !pkmn
      for speciesFamily in speciesFamilies
        for species in speciesFamily
          if pkmn.isSpecies?(species)
            $PokemonStorage.pbDelete(i, j)
            next
          end
        end
      end
    end
  end
end

def removeAllPokemonFromSpecies(species)
  for i in -1...$PokemonStorage.maxBoxes
    for j in 0...$PokemonStorage.maxPokemon(i)
      pkmn = $PokemonStorage[i][j]
      if pkmn != nil && pkmn.isSpecies?(species)
        $PokemonStorage.pbDelete(i, j)
      end
    end
  end
end
