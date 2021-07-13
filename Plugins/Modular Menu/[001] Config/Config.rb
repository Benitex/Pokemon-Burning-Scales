#-------------------------------------------------------------------------------
#  Your own entries for the pause menu
#
#  To add a new menu entry to the list, register a function block with:
#
#  ModularMenu.add_entry(:NAME, "button text", "icon name") do |menu|
#    # code you want to run
#    # when the entry in the menu is selected
#  end
#
#  To add a condition whether or not the menu entry should appear,
#  register a condition with:
#
#  ModularMenu.add_condition(:NAME) { next (conditional statement here) }
#-------------------------------------------------------------------------------
#  PokeDex
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:POKEDEX, _INTL("Pokédex"), "menuPokedex") do |menu|
  if Settings::USE_CURRENT_REGION_DEX
    pbFadeOutIn(99999){
      scene = PokemonPokedex_Scene.new
      screen = PokemonPokedexScreen.new(scene)
      screen.pbStartScreen
      menu.refresh
    }
  else
    if $Trainer.pokedex.accessible_dexes.length == 1
      $PokemonGlobal.pokedexDex = $Trainer.pokedex.accessible_dexes[0]
      pbFadeOutIn(99999) {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.refresh
      }
    else
      pbFadeOutIn(99999) {
        scene = PokemonPokedexMenu_Scene.new
        screen = PokemonPokedexMenuScreen.new(scene)
        screen.pbStartScreen
        menu.refresh
      }
    end
  end
end
# condition to satisfy
ModularMenu.add_condition(:POKEDEX) { next $Trainer.pokedex && $Trainer.pokedex.accessible_dexes.length > 0 }
#-------------------------------------------------------------------------------
#  Party Screen
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:POKEMON, _INTL("Pokémon"), "menuPokemon") do |menu|
  sscene = PokemonParty_Scene.new
  sscreen = PokemonPartyScreen.new(sscene,$Trainer.party)
  hiddenmove = nil
  pbFadeOutIn(99999) {
    hiddenmove = sscreen.pbPokemonScreen
    if hiddenmove
      menu.pbEndScene
      menu.endscene = false
    end
  }
  if hiddenmove
    Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
    menu.close = true
  end
end
# condition to satisfy
ModularMenu.add_condition(:POKEMON) { next $Trainer.party.length > 0 }
#-------------------------------------------------------------------------------
#  Bag Screen
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:BAG, _INTL("Bag"), "menuBag") do |menu|
  item = 0
  scene = PokemonBag_Scene.new
  screen = PokemonBagScreen.new(scene,$PokemonBag)
  pbFadeOutIn(99999) {
    item = screen.pbStartScreen
    if item
      menu.pbEndScene
      menu.endscene = false
    end
  }
  if item
    Kernel.pbUseKeyItemInField(item)
    menu.close = true
  end
end
#-------------------------------------------------------------------------------
#  QuestList
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:QUESTLIST, _INTL("Quests"), "menuQuests") do |menu|
  pbPlayDecisionSE
  pbFadeOutIn(99999) {
    pbViewQuests
    menu.refresh
  }
end
#-------------------------------------------------------------------------------
#  PokeGear
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:POKERADAR, _INTL("PokéRadar"), "menuPokegear") do |menu|
  scene = EncounterList_Scene.new
  screen = EncounterList_Screen.new(scene)
  screen.pbStartScreen
end
# condition to satisfy
ModularMenu.add_condition(:POKERADAR) { next $Trainer.has_pokegear }
#-------------------------------------------------------------------------------
#  Trainer Card
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:TRAINER, _INTL("\\PN"), "menuTrainer") do |menu|
  scene = PokemonTrainerCard_Scene.new
  screen = PokemonTrainerCardScreen.new(scene)
  pbFadeOutIn(99999) {
    screen.pbStartScreen
  }
end
#-------------------------------------------------------------------------------
#  Save Screen
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:SAVE, _INTL("Save"), "menuSave") do |menu|
  scene = PokemonSave_Scene.new
  screen = PokemonSaveScreen.new(scene)
  menu.pbEndScene
  menu.endscene = false
  if screen.pbSaveScreen
    menu.close = true
  else
    menu.pbStartScene
    menu.pbShowMenu
    menu.close = false
  end
end
# condition to satisfy
ModularMenu.add_condition(:SAVE) { next !$game_system || !$game_system.save_disabled && !(pbInSafari? || pbInBugContest?) }
#-------------------------------------------------------------------------------
#  Quit Safari-Zone
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:QUIT, _INTL("\\CONTEST"), "menuQuit") do |menu|
  if pbInSafari?
    if Kernel.pbConfirmMessage(_INTL("Would you like to leave the Safari Game right now?"))
      menu.pbEndScene
      menu.endscene = false
      menu.close = true
      pbSafariState.decision = 1
      pbSafariState.pbGoToStart
    end
  else
    if Kernel.pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
      menu.pbEndScene
      menu.endscene = false
      menu.close = true
      pbBugContestState.pbStartJudging
      next
    end
  end
end
# condition to satisfy
ModularMenu.add_condition(:QUIT) { next pbInSafari? || pbInBugContest? }
#-------------------------------------------------------------------------------
#  Options Screen
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:OPTIONS, _INTL("Options"), "menuOptions") do |menu|
  scene = PokemonOption_Scene.new
  screen = PokemonOptionScreen.new(scene)
  pbFadeOutIn(99999) {
    screen.pbStartScreen
    pbUpdateSceneMap
  }
end
#-------------------------------------------------------------------------------
#  Debug Menu
#-------------------------------------------------------------------------------
ModularMenu.add_entry(:DEBUG, _INTL("Debug"), "menuDebug") do |menu|
  pbFadeOutIn(99999) {
    pbDebugMenu
    menu.refresh
  }
end
# condition to satisfy
ModularMenu.add_condition(:DEBUG) { next $DEBUG }
