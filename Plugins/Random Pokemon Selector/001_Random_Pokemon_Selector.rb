def pbChooseRandomPokemon(whiteList=nil, blackList=nil, addList=nil,
                          base_only=true, choose_gen=nil)

  # If blackList is set to "suggested", then set to mythical and legendary Pokémon
  if blackList == "suggested"
    blackList = getLegendOrMythic
  end

  # Option for a second black list, useful if suggested black list is requested and the user wants to add into that array rather than rewrite it
  # addList is ignored if blackList is not specified
  if addList && blackList
    blackList += addList
  end

  # Set blackList to empty array if it doesn't exist by this point
  blackList = [] if !blackList

  # Set choose_gen to array of values from 1 to 8 if it doesn't exist
  choose_gen = (1..8).to_a if !choose_gen

  # Blank array to be filled
  arr = []

  # If whiteList is given, push into above blank array
  # If base_only is true, then only pick species from whiteList if they are the base form
  # Exclude any species on the black list
  # If whiteList is not defined, then start from all species
  # Restrict to species from generations specified in choose_gen array
  # Repeated from above wrt black list and base forms
  if whiteList
    whiteList.each_with_index do |s, i|
      whiteList[i] = GameData::Species.try_get(s)
    end
    if base_only
      whiteList.each { |s| arr.push(s.id) if !blackList.include?(s.id) && s.id == s.get_baby_species }
    else
      whiteList.each { |s| arr.push(s.id) if !blackList.include?(s.id) }
    end
  else
    if base_only
      GameData::Species.each do |s|
        arr.push(s.id) if choose_gen.include?(s.generation) && !blackList.include?(s.id) && s.id == s.get_baby_species && s.form == 0
      end
    else
      GameData::Species.each do |s|
        arr.push(s.id) if choose_gen.include?(s.generation) && !blackList.include?(s.id) && s.form == 0
      end
    end
  end

  # Pull random entry from array
  pkmn = arr[rand(arr.length)]
  return pkmn

end

# Returns array of mythical and legendary Pokémon
def getLegendOrMythic
  arr = [:ARTICUNO, :ZAPDOS, :MOLTRES,
  :RAIKOU, :ENTEI, :SUICUNE,
  :REGIROCK, :REGICE, :REGISTEEL,
  :LATIAS, :LATIOS,
  :UXIE, :MESPRIT, :AZELF,
  :HEATRAN, :REGIGIGAS, :CRESSELIA,
  :COBALION, :TERRAKION, :VIRIZION,
  :TORNADUS, :THUNDURUS, :LANDORUS,
  :TYPENULL, :SILVALLY,
  :TAPUKOKO, :TAPULELE, :TAPUBULU, :TAPUFINI,
  :NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE,
  :CELESTEELA, :KARTANA, :GUZZLORD, :POIPOLE,
  :NAGANADEL, :STAKATAKA, :BLACEPHALON,
  :KUBFU, :URSHIFU,
  :REGIELEKI, :REGIDRAGO,
  :GLASTRIER, :SPECTRIER,
  :MEWTWO, :LUGIA, :HOOH,
  :KYOGRE, :GROUDON, :RAYQUAZA,
  :DIALGA, :PALKIA, :GIRATINA,
  :RESHIRAM, :ZEKROM, :KYUREM,
  :XERNEAS, :YVELTAL, :ZYGARDE,
  :COSMOG, :COSMOEM,
  :SOLGALEO, :LUNALA, :NECROZMA,
  :ZACIAN, :ZAMAZENTA,
  :ETERNATUS, :CALYREX,
  :MEW, :CELEBI, :JIRACHI,
  :DEOXYS, :PHIONE, :MANAPHY,
  :DARKRAI, :SHAYMIN, :ARCEUS,
  :VICTINI, :KELDEO, :MELOETTA, :GENESECT,
  :DIANCIE, :HOOPA, :VOLCANION,
  :MAGEARNA, :MARSHADOW, :ZERAORA,
  :MELTAN, :MELMETAL, :ZARUDE]
  return arr
end

# Unused utility method that returns the base stat total (BST) for given Pokémon
def getBaseStatTotal(pokemon)
  baseTotal = 0
  GameData::Stat.each_main do |s|
    baseTotal += pokemon.base_stats[s.id]
  end
  return baseTotal
end
