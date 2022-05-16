#===============================================================================
# Nicknaming and storing Pokémon
#===============================================================================
def pbBoxesFull?
  return ($Trainer.party_full? && $PokemonStorage.full?)
end

def pbNickname(pkmn)
  species_name = pkmn.speciesName
  if pbConfirmMessage(_INTL("Would you like to give a nickname to {1}?", species_name))
    pkmn.name = pbEnterPokemonName(_INTL("{1}'s nickname?", species_name),
                                   0, Pokemon::MAX_NAME_SIZE, "", pkmn)
  end
end

def pbStorePokemon(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pkmn.record_first_moves
  if $Trainer.party_full?
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pkmn)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $Trainer.seen_storage_creator
    if storedbox != oldcurbox
      if creator
        pbMessage(_INTL("Box \"{1}\" on {2}'s PC was full.\1", curboxname, creator))
      else
        pbMessage(_INTL("Box \"{1}\" on someone's PC was full.\1", curboxname))
      end
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pkmn.name, boxname))
    else
      if creator
        pbMessage(_INTL("{1} was transferred to {2}'s PC.\1", pkmn.name, creator))
      else
        pbMessage(_INTL("{1} was transferred to someone's PC.\1", pkmn.name))
      end
      pbMessage(_INTL("It was stored in box \"{1}.\"", boxname))
    end
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
end

def pbNicknameAndStore(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.pokedex.set_seen(pkmn.species)
  $Trainer.pokedex.set_owned(pkmn.species)
  pbNickname(pkmn)
  pbStorePokemon(pkmn)
end

#===============================================================================
# Giving Pokémon to the player (will send to storage if party is full)
#===============================================================================
def pbAddPokemon(pkmn, level = 1, see_form = true)
  return false if !pkmn
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return false
  end
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  return true
end

def pbAddPokemonSilent(pkmn, level = 1, see_form = true)
  return false if !pkmn || pbBoxesFull?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  if $Trainer.party_full?
    $PokemonStorage.pbStoreCaught(pkmn)
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
  return true
end

#===============================================================================
# Giving Pokémon/eggs to the player (can only add to party)
#===============================================================================
def pbAddToParty(pkmn, level = 1, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  species_name = pkmn.speciesName
  pbMessage(_INTL("{1} obtained {2}!\\me[Pkmn get]\\wtnp[80]\1", $Trainer.name, species_name))
  pbNicknameAndStore(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  return true
end

def pbAddToPartySilent(pkmn, level = nil, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  pkmn.record_first_moves
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end

def pbAddForeignPokemon(pkmn, level = 1, owner_name = nil, nickname = nil, owner_gender = 0, see_form = true)
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  # Set original trainer to a foreign one
  pkmn.owner = Pokemon::Owner.new_foreign(owner_name || "", owner_gender)
  # Set nickname
  pkmn.name = nickname[0, Pokemon::MAX_NAME_SIZE] if !nil_or_empty?(nickname)
  # Recalculate stats
  pkmn.calc_stats
  if owner_name
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon from {2}.\1", $Trainer.name, owner_name))
  else
    pbMessage(_INTL("\\me[Pkmn get]{1} received a Pokémon.\1", $Trainer.name))
  end
  pbStorePokemon(pkmn)
  $Trainer.pokedex.register(pkmn) if see_form
  $Trainer.pokedex.set_owned(pkmn.species)
  return true
end

def pbGenerateEgg(pkmn, text = "")
  return false if !pkmn || $Trainer.party_full?
  pkmn = Pokemon.new(pkmn, Settings::EGG_LEVEL) if !pkmn.is_a?(Pokemon)
  # Set egg's details
  pkmn.name           = _INTL("Egg")
  pkmn.steps_to_hatch = pkmn.species_data.hatch_steps
  pkmn.obtain_text    = text
  pkmn.calc_stats
  # Add egg to party
  $Trainer.party[$Trainer.party.length] = pkmn
  return true
end
alias pbAddEgg pbGenerateEgg
alias pbGenEgg pbGenerateEgg

#===============================================================================
# Analyse Pokémon in the party
#===============================================================================
# Returns the first unfainted, non-egg Pokémon in the player's party.
def pbFirstAblePokemon(variable_ID)
  $Trainer.party.each_with_index do |pkmn, i|
    next if !pkmn.able?
    pbSet(variable_ID, i)
    return pkmn
  end
  pbSet(variable_ID, -1)
  return nil
end

#===============================================================================
# Return a level value based on Pokémon in a party
#===============================================================================
def pbBalancedLevel(party)
  return 1 if party.length == 0
  # Calculate the mean of all levels
  sum = 0
  party.each { |p| sum += p.level }
  return 1 if sum == 0
  mLevel = GameData::GrowthRate.max_level
  average = sum.to_f / party.length.to_f
  # Calculate the standard deviation
  varianceTimesN = 0
  party.each do |pkmn|
    deviation = pkmn.level - average
    varianceTimesN += deviation * deviation
  end
  # NOTE: This is the "population" standard deviation calculation, since no
  # sample is being taken.
  stdev = Math.sqrt(varianceTimesN / party.length)
  mean = 0
  weights = []
  # Skew weights according to standard deviation
  party.each do |pkmn|
    weight = pkmn.level.to_f / sum.to_f
    if weight < 0.5
      weight -= (stdev / mLevel.to_f)
      weight = 0.001 if weight <= 0.001
    else
      weight += (stdev / mLevel.to_f)
      weight = 0.999 if weight >= 0.999
    end
    weights.push(weight)
  end
  weightSum = 0
  weights.each { |w| weightSum += w }
  # Calculate the weighted mean, assigning each weight to each level's
  # contribution to the sum
  party.each_with_index { |pkmn, i| mean += pkmn.level * weights[i] }
  mean /= weightSum
  mean = mean.round
  mean = 1 if mean < 1
  # Add 2 to the mean to challenge the player
  mean += 2
  # Adjust level to maximum
  mean = mLevel if mean > mLevel
  return mean
end

#===============================================================================
# Calculates a Pokémon's size (in millimeters)
#===============================================================================
def pbSize(pkmn)
  baseheight = pkmn.height
  hpiv = pkmn.iv[:HP] & 15
  ativ = pkmn.iv[:ATTACK] & 15
  dfiv = pkmn.iv[:DEFENSE] & 15
  saiv = pkmn.iv[:SPECIAL_ATTACK] & 15
  sdiv = pkmn.iv[:SPECIAL_DEFENSE] & 15
  spiv = pkmn.iv[:SPEED] & 15
  m = pkmn.personalID & 0xFF
  n = (pkmn.personalID >> 8) & 0xFF
  s = (((ativ ^ dfiv) * hpiv) ^ m) * 256 + (((saiv ^ sdiv) * spiv) ^ n)
  xyz = []
  if s < 10;       xyz = [ 290,   1,     0]
  elsif s < 110;   xyz = [ 300,   1,    10]
  elsif s < 310;   xyz = [ 400,   2,   110]
  elsif s < 710;   xyz = [ 500,   4,   310]
  elsif s < 2710;  xyz = [ 600,  20,   710]
  elsif s < 7710;  xyz = [ 700,  50,  2710]
  elsif s < 17710; xyz = [ 800, 100,  7710]
  elsif s < 32710; xyz = [ 900, 150, 17710]
  elsif s < 47710; xyz = [1000, 150, 32710]
  elsif s < 57710; xyz = [1100, 100, 47710]
  elsif s < 62710; xyz = [1200,  50, 57710]
  elsif s < 64710; xyz = [1300,  20, 62710]
  elsif s < 65210; xyz = [1400,   5, 64710]
  elsif s < 65410; xyz = [1500,   2, 65210]
  else;            xyz = [1700,   1, 65510]
  end
  return (((s - xyz[2]) / xyz[1] + xyz[0]).floor * baseheight / 10).floor
end

#===============================================================================
# Returns true if the given species can be legitimately obtained as an egg
#===============================================================================
def pbHasEgg?(species)
  species_data = GameData::Species.try_get(species)
  return false if !species_data
  species = species_data.species
  # species may be unbreedable, so check its evolution's compatibilities
  evoSpecies = species_data.get_evolutions(true)
  compatSpecies = (evoSpecies && evoSpecies[0]) ? evoSpecies[0][0] : species
  species_data = GameData::Species.try_get(compatSpecies)
  compat = species_data.egg_groups
  return false if compat.include?(:Undiscovered) || compat.include?(:Ditto)
  baby = GameData::Species.get(species).get_baby_species
  return true if species == baby   # Is a basic species
  baby = GameData::Species.get(species).get_baby_species(true)
  return true if species == baby   # Is an egg species without incense
  return false
end

#===============================================================================
# Evolve a Pokemon from an event
#===============================================================================
def pbEvolvePokemonEvent(species,forced_form = -1,check_fainted = Settings::CHECK_EVOLUTION_FOR_FAINTED_POKEMON)
  species = [species] if !species.is_a?(Array)
  $Trainer.party.each do |pkmn|
    next if !species.any? {|s| pkmn.isSpecies?(s) }
    next if !pkmn.able? && check_fainted
    new_species = pkmn.check_evolution_in_event
    next if !new_species
    $game_player.straighten
    pkmn.form = forced_form if forced_form >= 0
    evo = PokemonEvolutionScene.new
    pbFadeOutIn(99999) {
      evo.pbStartScreen(pkmn,new_species)
      evo.pbEvolution
      evo.pbEndScreen
    }
  end
end

#===============================================================================
# Hyper Training
#===============================================================================
def pbHyperTrainer(standard_item ,rare_item, check_level = true,check_badges = true)
  itemName1 = GameData::Item.get(standard_item).name_plural
  itemName2 = GameData::Item.get(rare_item).name_plural
  if !$PokemonBag.pbHasItem?(standard_item) && !$PokemonBag.pbHasItem?(rare_item)
    pbMessage(_INTL("Come back when you have {1} or {2}.",itemName1,itemName2))
    return false
  end
  if check_badges && $Trainer.badge_count < 8
    pbMessage(_INTL("Come back when you have 8 or more badges."))
    return false
  end
  pbMessage(_INTL("Now which Pokémon will I have undergo Hyper Training?"))
  ret = false
  loop do
    pbChoosePokemon(1,3,proc { |pkmn|
      next if !pkmn.able?
      next if (pkmn.level != GameData::GrowthRate.max_level && check_level)
      failed = false
      GameData::Stat.each_main do |s|
        next if pkmn.ivMaxed[s.id] || pkmn.iv[s.id] == Pokemon::IV_STAT_LIMIT
        failed = true
        break
      end
      next failed
      }
    )
    if !pbGet(1) || pbGet(1) < 0
      pbMessage(_INTL("Come back when you're ready to get hyped for some Hyper Training!"))
      ret = false
      break
    end
    pkmn = $Trainer.party[pbGet(1)]
    commands = []; displayCmd = [];
    if $PokemonBag.pbHasItem?(standard_item)
      commands.push(0)
      displayCmd.push(_INTL("{1} :{2}",itemName1,$PokemonBag.pbQuantity(standard_item)))
    end
    if $PokemonBag.pbHasItem?(rare_item)
      commands.push(1)
      displayCmd.push(_INTL("{1} :{2}",itemName2,$PokemonBag.pbQuantity(rare_item)))
    end
    commands.push(2)
    displayCmd.push("Cancel")
    selCmd = pbMessage(_INTL("What would you like to use?"),displayCmd)
    cmd = commands[selCmd]
    case cmd
    when 0
      pbMessage(_INTL("Which stat should I hype up?"))
      statSelected = pbShowStatSelectionCommands(standard_item,pkmn)
      if statSelected.length > 0
        pbMessage(_INTL("The training starts now!"))
        pbFadeOutIn(99999) {
          echoln(statSelected)
          statSelected.each do |s|
            pkmn.ivMaxed[s] = true
          end
          $PokemonBag.pbDeleteItem(standard_item,statSelected.length)
          pbWait(Graphics.frame_rate)
        }
        pbMessage(_INTL("Phew... {1} got stronger from the Hyper Training!",pkmn.name))
        if pbConfirmMessage(_INTL("Want to keep the hype going with some more Hyper Training?"))
          next
        else
          cmd = 2
        end
      else
        cmd = 2
      end
    when 1
      pbMessage(_INTL("The training starts now!"))
      pbFadeOutIn(99999) {
        GameData::Stat.each_main do |s|
          pkmn.ivMaxed[s.id] = true
        end
        $PokemonBag.pbDeleteItem(rare_item,1)
        pbWait(Graphics.frame_rate)
      }
      pbMessage(_INTL("Phew... {1} got stronger from the Hyper Training!",pkmn.name))
      if pbConfirmMessage(_INTL("Want to keep the hype going with some more Hyper Training?"))
        next
      else
        cmd = 2
      end
    end
    if cmd == 2
      pbMessage(_INTL("Come back when you're ready to get hyped for some Hyper Training!"))
      ret = false
      break
    end
  end
  return ret
end

def pbShowStatSelectionCommands(item, pkmn)
  commands = []; displayCmd = [];
  cmdwindow=Window_CommandPokemonEx.new([])
  cmdwindow.z=99999
  cmdwindow.visible=true
  cmdwindow.index = 0
  statSelected = []
  need_refresh = true
  loop do
    if need_refresh
      commands = []; displayCmd = [];
      GameData::Stat.each_main do |s|
        next if pkmn.ivMaxed[s.id] || pkmn.iv[s.id] == Pokemon::IV_STAT_LIMIT
        commands.push(s.id)
        displayCmd.push(_INTL("{1} {2}",statSelected.include?(s.id) ? "[x]" : "[  ]",s.name))
      end
      commands.push(:NONE)
      displayCmd.push("Lets train!")
      cmdwindow.commands = displayCmd
      cmdwindow.resizeToFit(cmdwindow.commands)
      need_refresh = false
    end
    Graphics.update
    Input.update
    cmdwindow.update
    yield if block_given?
    if Input.trigger?(Input::USE)
      cmd = commands[cmdwindow.index]
      break if cmd == :NONE
      if statSelected.include?(cmd)
        statSelected.delete(cmd)
      else
        statSelected.push(cmd)
      end
      if statSelected.length > $PokemonBag.pbQuantity(item)
        pbMessage(_INTL("You don't have enough {1}",GameData::Item.get(item).name_plural))
        statSelected.delete(cmd)
      end
      need_refresh = true
    elsif Input.trigger?(Input::BACK)
      statSelected = []
      break
    end
    pbUpdateSceneMap
  end
  cmdwindow.dispose
  Input.update
  return statSelected
end

#===============================================================================
# Gen 8 Fossil Combiner
#===============================================================================
def pbFossilCombiner
  combos = {
    :DRACOZOLT => [:FOSSILIZEDDRAKE,:FOSSILIZEDBIRD],
    :DRACOVISH => [:FOSSILIZEDDRAKE,:FOSSILIZEDFISH],
    :ARCTOZOLT => [:FOSSILIZEDDINO,:FOSSILIZEDBIRD],
    :ARCTOVISH => [:FOSSILIZEDDINO,:FOSSILIZEDFISH]
  }
  combineables = []
  failed = true
  combos.each do |_,fossil|
    fossil.each { |item| combineables.push(item) if $PokemonBag.pbHasItem?(item) }
    failed = false  if fossil.all? { |item| $PokemonBag.pbHasItem?(item) }
  end
  if failed
    pbMessage(_INTL("Come back when you have 2 fossils that can be combined."))
    return false
  end
  if !pbConfirmMessage(_INTL("Would you like to combine 2 fossils?"))
    pbMessage(_INTL("Come back if you'd like to combine any fossils."))
    return false
  end
  pkmn = nil
  loop do
    combineables.uniq!
    combine_names = combineables.clone.map! { |item| next GameData::Item.get(item).name }
    cmd = pbMessage(_INTL("Which fossil would you like to combine?"),combine_names)
    fossil1 = combineables[cmd]
    combineables2  = combineables.clone
    combineables2.delete(fossil1)
    combine_names2 = combineables2.clone.map! { |item| next GameData::Item.get(item).name }
    cmd = pbMessage(_INTL("Which fossil would you like to combine with {1}?", GameData::Item.get(fossil1).name),
                    combine_names2)
    fossil2 = combineables2[cmd]
    pkmn = nil
    combos.each do |key,items|
      next if !items.include?(fossil1) || !items.include?(fossil2)
      pkmn = key
      break
    end
    if !pkmn
      pbMessage(_INTL("Oh... {1} and {2} cannot be combined.",GameData::Item.get(fossil1).name, GameData::Item.get(fossil2).name))
      next if combineables.length > 2 && pbConfirmMessage(_INTL("Would you like to combine other fossils then?"))
      pbMessage(_INTL("Come back if you'd like to combine any fossils."))
      return false
    end
    if pbConfirmMessage(_INTL("Would you like to combine and restore the {1} and {2}?",GameData::Item.get(fossil1).name, GameData::Item.get(fossil2).name))
      $PokemonBag.pbDeleteItem(fossil1)
      $PokemonBag.pbDeleteItem(fossil2)
      break
    end
    if !pbConfirmMessage(_INTL("Would you like to combine other fossils then?"))
      pbMessage(_INTL("Come back if you'd like to combine any fossils."))
      return false
    end
  end
  pbFadeOutInWithMusic(99999) {
    pbMEPlay("Evolution start")
    pbWait(Graphics.frame_rate)
    pbBGMPlay("Evolution")
    frames = Array.new(3, "\\wt[#{Graphics.frame_rate - 4 + rand(10)}]\\se[Battle catch click]" )
    frames.push("\\wt[#{Graphics.frame_rate + 12}]\\se[Battle ball drop]")
    pbMessage(_INTL("Combining the fossils in 3 ...{1} 2 ...{2} 1 ... {3} and ...{4} !\\wtnp[10]",frames[0],frames[1],frames[2],frames[3]))
    pbWait(8)
    pbMessage(_INTL("\\me[Evolution success]Congratulations! The restoration was successful!"))
  }
  pbMessage(_INTL("Here's your restored Pokémon. Take good care of it!"))
  pbAddPokemon(pkmn,10)
  pbMessage(_INTL("Come back if you'd like to combine any fossils."))
  return true
end
