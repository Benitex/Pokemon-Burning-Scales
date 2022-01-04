#===============================================================================
#  Nuzlocke functionality for EBS DX
#-------------------------------------------------------------------------------
#  creates a Nuzlocke Game Mode complete with all the proper rules
#===============================================================================
module EliteBattle
  @nuzlocke = false
  #-----------------------------------------------------------------------------
  #  check if nuzlocke is on
  #-----------------------------------------------------------------------------
  def self.nuzlocke?
    return $PokemonGlobal && $PokemonGlobal.isNuzlocke
  end
  def self.nuzlockeOn?
    return self.nuzlocke? && self.get(:nuzlocke)
  end
  #-----------------------------------------------------------------------------
  #  toggle nuzlocke state
  #-----------------------------------------------------------------------------
  def self.toggle_nuzlocke(force = nil)
    @nuzlocke = force.nil? ? !@nuzlocke : force
  end
  #-----------------------------------------------------------------------------
  #  recurring function to get the very first species in the evolutionary line
  #-----------------------------------------------------------------------------
  def self.getFirstEvo(species)
    return nil if species.nil?
    prev = GameData::Species.get(species).get_previous_species
    return species if prev == species
    return self.getFirstEvo(prev)
  end
  #-----------------------------------------------------------------------------
  #  recurring function to get every evolution after defined species
  #-----------------------------------------------------------------------------
  def self.getNextEvos(species)
    return [] if species.nil?
    evo = GameData::Species.get(species).get_evolutions; all = []
    return [species] if evo.length < 1
    for arr in evo
      all += [arr[0]]
      all += self.getNextEvos(arr[0])
    end
    return all.uniq
  end
  #-----------------------------------------------------------------------------
  #  function to get all species inside an evolutionary line
  #-----------------------------------------------------------------------------
  def self.getEvolutionaryLine(species)
    species = self.getFirstEvo(species)
    return [species] + self.getNextEvos(species)
  end
  #-----------------------------------------------------------------------------
  #  checks if an evo line has been caught so far
  #-----------------------------------------------------------------------------
  def self.checkEvoNuzlocke?(species)
    return false if !$PokemonGlobal || !$PokemonGlobal.nuzlockeData
    for poke in self.getEvolutionaryLine(species)
      return true if $Trainer.owned?(poke)
    end
    return false
  end
  #-----------------------------------------------------------------------------
  #  starts nuzlocke mode
  #-----------------------------------------------------------------------------
  def self.startNuzlocke(skip = false)
    ret = $PokemonGlobal && $PokemonGlobal.isNuzlocke
    ret = self.nuzlockeSelection unless skip
    $PokemonGlobal.qNuzlocke = ret
    # sets the nuzlocke to true if already has a bag and Pokeballs
    for i in GameData::Item.values
      break if !$PokemonBag
      if GameData::Item.get(i).is_poke_ball? && $PokemonBag.pbHasItem?(i)
        @nuzlocke = ret
        $PokemonGlobal.isNuzlocke = ret
        break
      end
    end
    # creates global variable
    $PokemonGlobal.nuzlockeData = {} if $PokemonGlobal.nuzlockeData.nil?
  end
  #-----------------------------------------------------------------------------
  #  creates an UI to select the nuzlocke options
  #-----------------------------------------------------------------------------
  def self.nuzlockeSelection
    # list of all possible rules
    modifiers = [:NOREVIVE, :PERMADEATH, :ONEROUTE, :DUPSCLAUSE, :STATIC, :SHINY]
    # list of rule descriptions
    desc = [
      _INTL("Cannot revive fainted battlers"),
      _INTL("Auto-delete fainted battlers"),
      _INTL("One encounter per map"),
      _INTL("Disregard duplicate species (line)"),
      _INTL("Exclude static from encounter limit"),
      _INTL("Exclude shiny from encounter limit")
    ]
    # default
    added = [:NOREVIVE, :DUPSCLAUSE, :ONEROUTE, :STATIC, :SHINY]; cmd = 0
    # creates help text message window
    msgwindow = pbCreateMessageWindow(nil, "choice 1")
    msgwindow.text = _INTL("Select the Nuzlocke Rules you wish to apply.")
    # main loop
    loop do
      # generates all commands
      commands = []
      for i in 0...modifiers.length
        commands.push(_INTL("{1} {2}",(added.include?(modifiers[i])) ? "[X]" : "[  ]",desc[i]))
      end
      commands.push(_INTL("Done"))
      # goes to command window
      cmd = self.commandWindow(commands, cmd, msgwindow)
      # processes return
      if cmd < 0
        clear = pbConfirmMessage("Do you wish to cancel the Nuzlocke selection?")
        added.clear if clear
        next unless clear
      end
      break if cmd < 0 || cmd >= (commands.length - 1)
      if cmd >= 0 && cmd < (commands.length - 1)
        if added.include?(modifiers[cmd])
          added.delete(modifiers[cmd])
        else
          added.push(modifiers[cmd])
        end
      end
    end
    # disposes of message window
    pbDisposeMessageWindow(msgwindow)
    # adds nuzlocke rules
    $PokemonGlobal.nuzlockeRules = added
    EliteBattle.add_data(:NUZLOCKE, :RULES, added)
    # shows message
    msg = _INTL("Your selected Nuzlocke rules have been applied.")
    msg = _INTL("No Nuzlocke rules have been applied.") if added.length < 1
    msg = _INTL("Your selection has been cancelled.") if cmd < 0
    pbMessage(msg)
    Input.update
    return added.length > 0
  end
  #-----------------------------------------------------------------------------
  #  clear the randomizer content
  #-----------------------------------------------------------------------------
  def self.resetNuzlocke
    EliteBattle.reset(:nuzlocke)
    if $PokemonGlobal
      $PokemonGlobal.qNuzlocke = nil
      $PokemonGlobal.nuzlockeData = nil
      $PokemonGlobal.isNuzlocke = nil
      $PokemonGlobal.nuzlockeRules = nil
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  adding nuzlocke functionality to battler specific classes
#===============================================================================
class Pokemon
  attr_accessor :permaFaint
  #-----------------------------------------------------------------------------
  #  modifies returned HP
  #-----------------------------------------------------------------------------
  alias hpget_ebdx_nuzlocke hp unless self.method_defined?(:hpget_ebdx_nuzlocke)
  def hp
    return (self.permaFaint && EliteBattle.get(:nuzlocke)) ? 0 : hpget_ebdx_nuzlocke
  end
  #-----------------------------------------------------------------------------
  #  if HP falls to (or below 0) permanent faint is in effect
  #-----------------------------------------------------------------------------
  alias hpset_ebdx_nuzlocke hp= unless self.method_defined?(:hpset_ebdx_nuzlocke)
  def hp=(val)
    data = EliteBattle.get_data(:NUZLOCKE, :Metrics, :RULES); data = [] if data.nil?
    self.permaFaint = true if EliteBattle.get(:nuzlocke) && (data.include?(:NOREVIVE) || data.include?(:PEMADEATH)) && val <= 0
    hpset_ebdx_nuzlocke((self.permaFaint && EliteBattle.get(:nuzlocke)) ? 0 : val)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
class PokeBattle_Battler
  #-----------------------------------------------------------------------------
  #  modifies returned HP
  #-----------------------------------------------------------------------------
  alias hpget_ebdx_nuzlocke hp unless self.method_defined?(:hpget_ebdx_nuzlocke)
  def hp
    return (@pokemon && @pokemon.permaFaint && EliteBattle.get(:nuzlocke)) ? 0 : hpget_ebdx_nuzlocke
  end
  #-----------------------------------------------------------------------------
  #  if HP falls to (or below 0) permanent faint is in effect
  #-----------------------------------------------------------------------------
  alias hpset_ebdx_nuzlocke hp= unless self.method_defined?(:hpset_ebdx_nuzlocke)
  def hp=(val)
    data = EliteBattle.get_data(:NUZLOCKE, :Metrics, :RULES); data = [] if data.nil?
    @pokemon.permaFaint = true if EliteBattle.get(:nuzlocke) && (data.include?(:NOREVIVE) || data.include?(:PEMADEATH)) && val <= 0
    hpset_ebdx_nuzlocke((@pokemon.permaFaint && EliteBattle.get(:nuzlocke)) ? 0 : val)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  registers battler for map if fainted in battle
#===============================================================================
class PokeBattle_Scene
  attr_accessor :firstFainted
  #-----------------------------------------------------------------------------
  #  registers defeated battler on map
  #-----------------------------------------------------------------------------
  alias pbFaintBattler_ebdx_nuzlocke pbFaintBattler unless self.method_defined?(:pbFaintBattler_ebdx_nuzlocke)
  def pbFaintBattler(battler)
    if !@battle.opponent && !playerBattler?(battler)
      data = EliteBattle.get_data(:NUZLOCKE, :Metrics, :RULES); data = [] if data.nil?
      unless (@battle.pbParty(1).length == 2  && !self.firstFainted)
        if EliteBattle.get(:nuzlocke) && data.include?(:ONEROUTE) && battler.index%2 == 1
          evo = EliteBattle.checkEvoNuzlocke?(battler.pokemon.species) && data.include?(:DUPSCLAUSE)
          static = data.include?(:STATIC) && !$nonStaticEncounter
          shiny = data.include?(:SHINY) && battler.shiny?
          map = $PokemonGlobal.nuzlockeData[$game_map.map_id]
          $PokemonGlobal.nuzlockeData[$game_map.map_id] = true if map.nil? && !static && !evo && !shiny
        end
      end
      self.firstFainted = true
    end
    # returns original function
    return pbFaintBattler_ebdx_nuzlocke(battler)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  adding nuzlocke functionality to delete fainted battlers from party
#  (applied after battle is finished)
#===============================================================================
class PokeBattle_Battle
  #-----------------------------------------------------------------------------
  #  deletes all fainted battlers after battle (if rule is applied)
  #-----------------------------------------------------------------------------
  alias pbEndOfBattle_ebdx_nuzlocke pbEndOfBattle unless self.method_defined?(:pbEndOfBattle_ebdx_nuzlocke)
  def pbEndOfBattle
    ret = pbEndOfBattle_ebdx_nuzlocke
    # applies permadeath
    data = EliteBattle.get_data(:NUZLOCKE, :Metrics, :RULES); data = [] if data.nil?
    if EliteBattle.get(:nuzlocke) && data.include?(:PERMADEATH)
      for i in 0...$Trainer.party.length
        k = $Trainer.party.length - 1 - i
        if $Trainer.party[k].hp <= 0
          $PokemonBag.pbStoreItem($Trainer.party[k].item, 1) if $Trainer.party[k].item
          $Trainer.party.delete_at(k)
          $PokemonTemp.evolutionLevels.delete_at(k)
        end
      end
    end
    return ret
  end
  #-----------------------------------------------------------------------------
  #  allows for the catching of only one Pokemon per route
  #-----------------------------------------------------------------------------
  alias pbThrowPokeBall_ebdx_nuzlocke pbThrowPokeBall unless self.method_defined?(:pbThrowPokeBall_ebdx_nuzlocke)
  def pbThrowPokeBall(*args)
    # part to disable Pokeball throwing if already caught
    data = EliteBattle.get_data(:NUZLOCKE, :Metrics, :RULES); data = [] if data.nil?
    if EliteBattle.get(:nuzlocke) && data.include?(:ONEROUTE)
      static = data.include?(:STATIC) && !$nonStaticEncounter
      shiny = data.include?(:SHINY) && @battlers[args[0]].shiny?
      map = $PokemonGlobal.nuzlockeData[$game_map.map_id]
      return pbDisplay(_INTL("Nuzlocke rules prevent you from catching a wild Pokémon on a map you already had an encounter on!")) if !map.nil? && !static && !shiny
    end
    pbThrowPokeBall_ebdx_nuzlocke(*args)
    # part that registers caught Pokemon for map
    if EliteBattle.get(:nuzlocke) && data.include?(:ONEROUTE) && @decision == 4
      $PokemonGlobal.nuzlockeData[$game_map.map_id] = true unless static || shiny
    end
  end
  #-----------------------------------------------------------------------------
  #  registers Pokemon for nuzlocke map when fleeing
  #-----------------------------------------------------------------------------
  alias pbRun_ebdx_nuzlocke pbRun unless self.method_defined?(:pbRun_ebdx_nuzlocke)
  def pbRun(*args)
    data = EliteBattle.get_data(:NUZLOCKE, :Metrics, :RULES); data = [] if data.nil?
    battler = nil
    for i in 0...self.pbSideSize(1)
      if @battlers[i+1] && @battlers[i+1].hp > 0
        battler = @battlers[i+1]
        break
      end
    end
    if EliteBattle.get(:nuzlocke) && data.include?(:ONEROUTE) && !self.opponent
      evo = battler.nil? ? false : EliteBattle.checkEvoNuzlocke?(battler.displaySpecies) && data.include?(:DUPSCLAUSE)
      static = data.include?(:STATIC) && !$nonStaticEncounter
      shiny = false
      eachOtherSideBattler(args[0]) do |b|
        shiny = true if data.include?(:SHINY) && b.shiny?
      end
      map = $PokemonGlobal.nuzlockeData[$game_map.map_id]
      $PokemonGlobal.nuzlockeData[$game_map.map_id] = true if map.nil? && !static && !evo && !shiny
    end
    # returns original function
    return pbRun_ebdx_nuzlocke(*args)
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  losing the nuzlocke
#===============================================================================
alias pbStartOver_ebdx_nuzlocke pbStartOver unless defined?(pbStartOver_ebdx_nuzlocke)
def pbStartOver(*args)
  if EliteBattle.get(:nuzlocke)
    pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]All your Pokémon have fainted. You have lost the Nuzlocke challenge! The challenge will now be turned off."))
    EliteBattle.set(:nuzlocke, false)
    $PokemonGlobal.isNuzlocke = false
    pbStartOver_ebdx_nuzlocke(*args)
  end
  return pbStartOver_ebdx_nuzlocke(*args)
end
#===============================================================================
#  additional entry to Global Metadata for randomized data storage
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :qNuzlocke
  attr_accessor :nuzlockeData
  attr_accessor :isNuzlocke
  attr_accessor :nuzlockeRules
end
#===============================================================================
#  starts nuzlocke only after obtaining a Pokeball
#===============================================================================
class PokemonBag
  alias pbStoreItem_ebdx_nuzlocke pbStoreItem unless self.method_defined?(:pbStoreItem_ebdx_nuzlocke)
  def pbStoreItem(*args)
    ret = pbStoreItem_ebdx_nuzlocke(*args)
    item = args[0]
    if $PokemonGlobal && $PokemonGlobal.qNuzlocke && GameData::Item.get(item).is_poke_ball?
      EliteBattle.set(:nuzlocke, true)
      EliteBattle.add_data(:NUZLOCKE, :RULES, $PokemonGlobal.nuzlockeRules) if !$PokemonGlobal.nuzlockeRules.nil?
      $PokemonGlobal.isNuzlocke = true
    end
    return ret
  end
end
#===============================================================================
#  refresh cache on load
#===============================================================================
class PokemonLoadScreen
  alias pbStartLoadScreen_ebdx_nuzlocke pbStartLoadScreen unless self.method_defined?(:pbStartLoadScreen_ebdx_nuzlocke)
  def pbStartLoadScreen
    ret = pbStartLoadScreen_ebdx_nuzlocke
    if $PokemonGlobal && $PokemonGlobal.isNuzlocke
      EliteBattle.set(:nuzlocke, true)
      EliteBattle.add_data(:NUZLOCKE, :RULES, $PokemonGlobal.nuzlockeRules) if !$PokemonGlobal.nuzlockeRules.nil?
    end
    return ret
  end
end
