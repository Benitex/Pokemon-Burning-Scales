#==============================================================================
# "v19.1 Hotfixes" plugin
# This file contains fixes for miscellaneous bugs.
# These bug fixes are also in the master branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#==============================================================================

Essentials::ERROR_TEXT += "[v19.1 Hotfixes 1.0.7]\r\n"

#==============================================================================
# Fix for Vs. animation not playing, and a trainer's trainer type possibly
# being an integer rather than a symbol.
#==============================================================================
def pbBattleAnimationOverride(viewport,battletype=0,foe=nil)
  ##### VS. animation, by Luka S.J. #####
  ##### Tweaked by Maruno           #####
  if (battletype==1 || battletype==3) && foe.length==1   # Against single trainer
    tr_type = foe[0].trainer_type
    if tr_type
      tbargraphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
      tgraphic    = sprintf("vsTrainer_%s", tr_type.to_s) rescue nil
      if pbResolveBitmap("Graphics/Transitions/" + tbargraphic) && pbResolveBitmap("Graphics/Transitions/" + tgraphic)
        player_tr_type = $Trainer.trainer_type
        outfit = $Trainer.outfit
        # Set up
        viewplayer = Viewport.new(0,Graphics.height/3,Graphics.width/2,128)
        viewplayer.z = viewport.z
        viewopp = Viewport.new(Graphics.width/2,Graphics.height/3,Graphics.width/2,128)
        viewopp.z = viewport.z
        viewvs = Viewport.new(0,0,Graphics.width,Graphics.height)
        viewvs.z = viewport.z
        fade = Sprite.new(viewport)
        fade.bitmap  = RPG::Cache.transition("vsFlash")
        fade.tone    = Tone.new(-255,-255,-255)
        fade.opacity = 100
        overlay = Sprite.new(viewport)
        overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
        pbSetSystemFont(overlay.bitmap)
        pbargraphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
        if !pbResolveBitmap("Graphics/Transitions/" + pbargraphic)
          pbargraphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
        end
        xoffset = ((Graphics.width/2)/10)*10
        bar1 = Sprite.new(viewplayer)
        bar1.bitmap = RPG::Cache.transition(pbargraphic)
        bar1.x      = -xoffset
        bar2 = Sprite.new(viewopp)
        bar2.bitmap = RPG::Cache.transition(tbargraphic)
        bar2.x      = xoffset
        vs = Sprite.new(viewvs)
        vs.bitmap  = RPG::Cache.transition("vs")
        vs.ox      = vs.bitmap.width/2
        vs.oy      = vs.bitmap.height/2
        vs.x       = Graphics.width/2
        vs.y       = Graphics.height/1.5
        vs.visible = false
        flash = Sprite.new(viewvs)
        flash.bitmap  = RPG::Cache.transition("vsFlash")
        flash.opacity = 0
        # Animate bars sliding in from either side
        slideInTime = (Graphics.frame_rate*0.25).floor
        for i in 0...slideInTime
          bar1.x = xoffset*(i+1-slideInTime)/slideInTime
          bar2.x = xoffset*(slideInTime-i-1)/slideInTime
          pbWait(1)
        end
        bar1.dispose
        bar2.dispose
        # Make whole screen flash white
        pbSEPlay("Vs flash")
        pbSEPlay("Vs sword")
        flash.opacity = 255
        # Replace bar sprites with AnimatedPlanes, set up trainer sprites
        bar1 = AnimatedPlane.new(viewplayer)
        bar1.bitmap = RPG::Cache.transition(pbargraphic)
        bar2 = AnimatedPlane.new(viewopp)
        bar2.bitmap = RPG::Cache.transition(tbargraphic)
        pgraphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
        if !pbResolveBitmap("Graphics/Transitions/" + pgraphic)
          pgraphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
        end
        player = Sprite.new(viewplayer)
        player.bitmap = RPG::Cache.transition(pgraphic)
        player.x      = -xoffset
        trainer = Sprite.new(viewopp)
        trainer.bitmap = RPG::Cache.transition(tgraphic)
        trainer.x      = xoffset
        trainer.tone   = Tone.new(-255,-255,-255)
        # Dim the flash and make the trainer sprites appear, while animating bars
        animTime = (Graphics.frame_rate*1.2).floor
        for i in 0...animTime
          flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
          bar1.ox -= 32*20/Graphics.frame_rate
          bar2.ox += 32*20/Graphics.frame_rate
          if i>=animTime/2 && i<slideInTime+animTime/2
            player.x = xoffset*(i+1-slideInTime-animTime/2)/slideInTime
            trainer.x = xoffset*(slideInTime-i-1+animTime/2)/slideInTime
          end
          pbWait(1)
        end
        player.x = 0
        trainer.x = 0
        # Make whole screen flash white again
        flash.opacity = 255
        pbSEPlay("Vs sword")
        # Make the Vs logo and trainer names appear, and reset trainer's tone
        vs.visible = true
        trainer.tone = Tone.new(0,0,0)
        trainername = foe[0].name
        textpos = [
           [$Trainer.name,Graphics.width/4,(Graphics.height/1.5)+4,2,
              Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
           [trainername,(Graphics.width/4)+(Graphics.width/2),(Graphics.height/1.5)+4,2,
              Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
        ]
        pbDrawTextPositions(overlay.bitmap,textpos)
        # Fade out flash, shudder Vs logo and expand it, and then fade to black
        animTime = (Graphics.frame_rate*2.75).floor
        shudderTime = (Graphics.frame_rate*1.75).floor
        zoomTime = (Graphics.frame_rate*2.5).floor
        shudderDelta = [4*20/Graphics.frame_rate,1].max
        for i in 0...animTime
          if i<shudderTime   # Fade out the white flash
            flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
          elsif i==shudderTime   # Make the flash black
            flash.tone = Tone.new(-255,-255,-255)
          elsif i>=zoomTime   # Fade to black
            flash.opacity += 52*20/Graphics.frame_rate if flash.opacity<255
          end
          bar1.ox -= 32*20/Graphics.frame_rate
          bar2.ox += 32*20/Graphics.frame_rate
          if i<shudderTime
            j = i%(2*Graphics.frame_rate/20)
            if j>=0.5*Graphics.frame_rate/20 && j<1.5*Graphics.frame_rate/20
              vs.x += shudderDelta
              vs.y -= shudderDelta
            else
              vs.x -= shudderDelta
              vs.y += shudderDelta
            end
          elsif i<zoomTime
            vs.zoom_x += 0.4*20/Graphics.frame_rate
            vs.zoom_y += 0.4*20/Graphics.frame_rate
          end
          pbWait(1)
        end
        # End of animation
        player.dispose
        trainer.dispose
        flash.dispose
        vs.dispose
        bar1.dispose
        bar2.dispose
        overlay.dispose
        fade.dispose
        viewvs.dispose
        viewopp.dispose
        viewplayer.dispose
        viewport.color = Color.new(0,0,0,255)
        return true
      end
    end
  end
  return false
end

class Trainer
  def initialize(name, trainer_type)
    @trainer_type = GameData::TrainerType.get(trainer_type).id
    @name         = name
    @id           = rand(2 ** 16) | rand(2 ** 16) << 16
    @language     = pbGetLanguage
    @party        = []
  end
end

class Player < Trainer
  def trainer_type
    if @trainer_type.is_a?(Integer)
      @trainer_type = GameData::Metadata.get_player(@character_ID || 0)[0]
    end
    return @trainer_type
  end
end

#==============================================================================
# Fixed player's feet remaining invisible after being in tall grass and
# performing a map transfer to elsewhere.
#==============================================================================
class Game_Character
  alias __hotfixes__moveto moveto
  def moveto(x, y)
    __hotfixes__moveto(x, y)
    calculate_bush_depth
  end
end

#==============================================================================
# Fixed error when showing a Pokémon to the Move Relearner who doesn't have any
# level-up moves it can relearn.
#==============================================================================
class Pokemon
  def can_relearn_move?
    return false if egg? || shadowPokemon?
    this_level = self.level
    getMoveList.each { |m| return true if m[0] <= this_level && !hasMove?(m[1]) }
    @first_moves.each { |m| return true if !hasMove?(m) }
    return false
  end
end

#==============================================================================
# Fixed problems when you have multiple dependent events and one is removed.
#==============================================================================
class DependentEvents
  def removeEvent(event)
    events=$PokemonGlobal.dependentEvents
    mapid=$game_map.map_id
    for i in 0...events.length
      if events[i][2]==mapid &&          # Refer to current map
         events[i][0]==event.map_id &&   # Event's map ID is original ID
         events[i][1]==event.id
        events[i]=nil
        @realEvents[i]=nil
        @lastUpdate+=1
      end
    end
    events.compact!
    @realEvents.compact!
  end

  def removeEventByName(name)
    events=$PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][8]==name   # Arbitrary name given to dependent event
        events[i]=nil
        @realEvents[i]=nil
        @lastUpdate+=1
      end
    end
    events.compact!
    @realEvents.compact!
  end
end

#==============================================================================
# Fixed bad code when checking if a trainer has a Pokémon of a given type.
#==============================================================================
class Trainer
  def has_pokemon_of_type?(type)
    return false if !GameData::Type.exists?(type)
    type = GameData::Type.get(type).id
    return pokemon_party.any? { |p| p && p.hasType?(type) }
  end
end

#==============================================================================
# Fixed error in code used by Pickup.
#==============================================================================
def pbDynamicItemList(*args)
  ret = []
  for i in 0...args.length
    ret.push(args[i]) if GameData::Item.exists?(args[i])
  end
  return ret
end

#==============================================================================
# Fixed abilities that force wild encounters with a particular type using the
# wrong value as the preferred type and usually crashing.
#==============================================================================
class PokemonEncounters
  def choose_wild_pokemon(enc_type, chance_rolls = 1)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    enc_list = @encounter_tables[enc_type]
    return nil if !enc_list || enc_list.length == 0
    # Static/Magnet Pull prefer wild encounters of certain types, if possible.
    # If they activate, they remove all Pokémon from the encounter table that do
    # not have the type they favor. If none have that type, nothing is changed.
    first_pkmn = $Trainer.first_pokemon
    if first_pkmn
      favored_type = nil
      case first_pkmn.ability_id
      when :STATIC
        favored_type = :ELECTRIC if GameData::Type.exists?(:ELECTRIC) && rand(100) < 50
      when :MAGNETPULL
        favored_type = :STEEL if GameData::Type.exists?(:STEEL) && rand(100) < 50
      end
      if favored_type
        new_enc_list = []
        enc_list.each do |enc|
          species_data = GameData::Species.get(enc[1])
          t1 = species_data.type1
          t2 = species_data.type2
          new_enc_list.push(enc) if t1 == favored_type || t2 == favored_type
        end
        enc_list = new_enc_list if new_enc_list.length > 0
      end
    end
    enc_list.sort! { |a, b| b[0] <=> a[0] }   # Highest probability first
    # Calculate the total probability value
    chance_total = 0
    enc_list.each { |a| chance_total += a[0] }
    # Choose a random entry in the encounter table based on entry probabilities
    rnd = 0
    chance_rolls.times do
      r = rand(chance_total)
      rnd = r if r > rnd   # Prefer rarer entries if rolling repeatedly
    end
    encounter = nil
    enc_list.each do |enc|
      rnd -= enc[0]
      next if rnd >= 0
      encounter = enc
      break
    end
    # Get the chosen species and level
    level = rand(encounter[2]..encounter[3])
    # Some abilities alter the level of the wild Pokémon
    if first_pkmn
      case first_pkmn.ability_id
      when :HUSTLE, :PRESSURE, :VITALSPIRIT
        level = encounter[3] if rand(100) < 50   # Highest possible level
      end
    end
    # Black Flute and White Flute alter the level of the wild Pokémon
    if Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
      if $PokemonMap.blackFluteUsed
        level = [level + rand(1..4), GameData::GrowthRate.max_level].min
      elsif $PokemonMap.whiteFluteUsed
        level = [level - rand(1..4), 1].max
      end
    end
    # Return [species, level]
    return [encounter[1], level]
  end
end

#==============================================================================
# Fixed error when trying to make a roaming Pokémon roam.
#==============================================================================
def pbRoamPokemon
  $PokemonGlobal.roamPokemon = [] if !$PokemonGlobal.roamPokemon
  # Start all roamers off in random maps
  if !$PokemonGlobal.roamPosition
    $PokemonGlobal.roamPosition = {}
    for i in 0...Settings::ROAMING_SPECIES.length
      next if !GameData::Species.exists?(Settings::ROAMING_SPECIES[i][0])
      keys = pbRoamingAreas(i).keys
      $PokemonGlobal.roamPosition[i] = keys[rand(keys.length)]
    end
  end
  # Roam each Pokémon in turn
  for i in 0...Settings::ROAMING_SPECIES.length
    pbRoamPokemonOne(i)
  end
end

#==============================================================================
# Fixed Poké Radar rustling grass not always causing a wild encounter when
# stepping in it.
#==============================================================================
class PokemonEncounters
  def encounter_triggered?(enc_type, repel_active = false, triggered_by_step = true)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    return false if $game_system.encounter_disabled
    return false if !$Trainer
    return false if $DEBUG && Input.press?(Input::CTRL)
    # Check if enc_type has a defined step chance/encounter table
    return false if !@step_chances[enc_type] || @step_chances[enc_type] == 0
    return false if !has_encounter_type?(enc_type)
    # Poké Radar encounters always happen, ignoring the minimum step period and
    # trigger probabilities
    return true if pbPokeRadarOnShakingGrass
    # Get base encounter chance and minimum steps grace period
    encounter_chance = @step_chances[enc_type].to_f
    min_steps_needed = (8 - encounter_chance / 10).clamp(0, 8).to_f
    # Apply modifiers to the encounter chance and the minimum steps amount
    if triggered_by_step
      encounter_chance += @chance_accumulator / 200
      encounter_chance *= 0.8 if $PokemonGlobal.bicycle
    end
    if !Settings::FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS
      encounter_chance /= 2 if $PokemonMap.blackFluteUsed
      min_steps_needed *= 2 if $PokemonMap.blackFluteUsed
      encounter_chance *= 1.5 if $PokemonMap.whiteFluteUsed
      min_steps_needed /= 2 if $PokemonMap.whiteFluteUsed
    end
    first_pkmn = $Trainer.first_pokemon
    if first_pkmn
      case first_pkmn.item_id
      when :CLEANSETAG
        encounter_chance *= 2.0 / 3
        min_steps_needed *= 4 / 3.0
      when :PUREINCENSE
        encounter_chance *= 2.0 / 3
        min_steps_needed *= 4 / 3.0
      else   # Ignore ability effects if an item effect applies
        case first_pkmn.ability_id
        when :STENCH, :WHITESMOKE, :QUICKFEET
          encounter_chance /= 2
          min_steps_needed *= 2
        when :SNOWCLOAK
          if GameData::Weather.get($game_screen.weather_type).category == :Hail
            encounter_chance /= 2
            min_steps_needed *= 2
          end
        when :SANDVEIL
          if GameData::Weather.get($game_screen.weather_type).category == :Sandstorm
            encounter_chance /= 2
            min_steps_needed *= 2
          end
        when :SWARM
          encounter_chance *= 1.5
          min_steps_needed /= 2
        when :ILLUMINATE, :ARENATRAP, :NOGUARD
          encounter_chance *= 2
          min_steps_needed /= 2
        end
      end
    end
    # Wild encounters are much less likely to happen for the first few steps
    # after a previous wild encounter
    if triggered_by_step && @step_count < min_steps_needed
      @step_count += 1
      return false if rand(100) >= encounter_chance * 5 / (@step_chances[enc_type] + @chance_accumulator / 200)
    end
    # Decide whether the wild encounter should actually happen
    return true if rand(100) < encounter_chance
    # If encounter didn't happen, make the next step more likely to produce one
    if triggered_by_step
      @chance_accumulator += @step_chances[enc_type]
      @chance_accumulator = 0 if repel_active
    end
    return false
  end

  def allow_encounter?(enc_data, repel_active = false)
    return false if !enc_data
    return true if pbPokeRadarOnShakingGrass
    # Repel
    if repel_active
      first_pkmn = (Settings::REPEL_COUNTS_FAINTED_POKEMON) ? $Trainer.first_pokemon : $Trainer.first_able_pokemon
      if first_pkmn && enc_data[1] < first_pkmn.level
        @chance_accumulator = 0
        return false
      end
    end
    # Some abilities make wild encounters less likely if the wild Pokémon is
    # sufficiently weaker than the Pokémon with the ability
    first_pkmn = $Trainer.first_pokemon
    if first_pkmn
      case first_pkmn.ability_id
      when :INTIMIDATE, :KEENEYE
        return false if enc_data[1] <= first_pkmn.level - 5 && rand(100) < 50
      end
    end
    return true
  end
end

ItemHandlers::UseInField.add(:POKERADAR,proc { |item|
  next (pbUsePokeRadar) ? 1 : 0
})

#==============================================================================
# Fixed typo in def addBackgroundOrColoredPlane.
#==============================================================================
def addBackgroundOrColoredPlane(sprites,planename,background,color,viewport=nil)
  bitmapName=pbResolveBitmap("Graphics/Pictures/#{background}")
  if bitmapName==nil
    # Plane should exist in any case
    sprites[planename]=ColoredPlane.new(color,viewport)
  else
    sprites[planename]=AnimatedPlane.new(viewport)
    sprites[planename].setBitmap(bitmapName)
    for spr in sprites.values
      if spr.is_a?(Window)
        spr.windowskin=nil
      end
    end
  end
end

#==============================================================================
# Fixed crash when choosing Pokémon for NPC Bug Catching Contest participants.
#==============================================================================
class PokemonEncounters
  def choose_wild_pokemon_for_map(map_ID, enc_type)
    if !enc_type || !GameData::EncounterType.exists?(enc_type)
      raise ArgumentError.new(_INTL("Encounter type {1} does not exist", enc_type))
    end
    # Get the encounter table
    encounter_data = GameData::Encounter.get(map_ID, $PokemonGlobal.encounter_version)
    return nil if !encounter_data
    enc_list = encounter_data.types[enc_type]
    return nil if !enc_list || enc_list.length == 0
    # Calculate the total probability value
    chance_total = 0
    enc_list.each { |a| chance_total += a[0] }
    # Choose a random entry in the encounter table based on entry probabilities
    rnd = rand(chance_total)
    encounter = nil
    enc_list.each do |enc|
      rnd -= enc[0]
      next if rnd >= 0
      encounter = enc
      break
    end
    # Return [species, level]
    level = rand(encounter[2]..encounter[3])
    return [encounter[1], level]
  end
end

#==============================================================================
# Fixed the event command "Return to Title Screen"/resting in a Battle Facility
# run causing issues when trying to continue the game again immediately.
#==============================================================================
module SaveData
  class Value
    def mark_as_unloaded
      @loaded = false
    end
  end

  def self.mark_values_as_unloaded
    @values.each do |value|
      value.mark_as_unloaded unless value.load_in_bootup?
    end
  end
end

alias __hotfixes__pbCallTitle pbCallTitle
def pbCallTitle
  $game_temp.to_title = false if $game_temp
  SaveData.mark_values_as_unloaded
  return __hotfixes__pbCallTitle
end

#==============================================================================
# Fixed Pokédex search not considering the properties of alternate forms of
# species if they were the ones last looked at.
#==============================================================================
class PokemonPokedex_Scene
  def pbGetDexList
    region = pbGetPokedexRegion
    regionalSpecies = pbAllRegionalSpecies(region)
    if !regionalSpecies || regionalSpecies.length == 0
      # If no Regional Dex defined for the given region, use the National Pokédex
      regionalSpecies = []
      GameData::Species.each { |s| regionalSpecies.push(s.id) if s.form == 0 }
    end
    shift = Settings::DEXES_WITH_OFFSETS.include?(region)
    ret = []
    regionalSpecies.each_with_index do |species, i|
      next if !species
      next if !pbCanAddForModeList?($PokemonGlobal.pokedexMode, species)
      _gender, form = $Trainer.pokedex.last_form_seen(species)
      species_data = GameData::Species.get_species_form(species, form)
      color  = species_data.color
      type1  = species_data.type1
      type2  = species_data.type2 || type1
      shape  = species_data.shape
      height = species_data.height
      weight = species_data.weight
      ret.push([species, species_data.name, height, weight, i + 1, shift, type1, type2, color, shape])
    end
    return ret
  end
end

#==============================================================================
# Fixed bad code in evolution method HappinessMoveType.
#==============================================================================
GameData::Evolution.register({
  :id            => :HappinessMoveType,
  :parameter     => :Type,
  :minimum_level => 1,   # Needs any level up
  :level_up_proc => proc { |pkmn, parameter|
    if pkmn.happiness >= 220
      next pkmn.moves.any? { |m| m && m.type == parameter }
    end
  }
})

#===============================================================================
# Fixed particle effects on events not working.
#===============================================================================
def pbEventCommentInput(*args)
  parameters = []
  list = args[0].list   # List of commands for event or event page
  elements = args[1]    # Number of elements
  trigger = args[2]     # Trigger
  return nil if list == nil
  return nil unless list.is_a?(Array)
  for item in list
    next unless item.code == 108 || item.code == 408
    if item.parameters[0] == trigger
      start = list.index(item) + 1
      finish = start + elements
      for id in start...finish
        next if !list[id]
        parameters.push(list[id].parameters[0])
      end
      return parameters
    end
  end
  return nil
end

#===============================================================================
# Fixed Sweet Scent not working.
#===============================================================================
def pbSweetScent
  if $game_screen.weather_type != :None
    pbMessage(_INTL("The sweet scent faded for some reason..."))
    return
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  count = 0
  viewport.color.red   = 255
  viewport.color.green = 0
  viewport.color.blue  = 0
  viewport.color.alpha -= 10
  alphaDiff = 12 * 20 / Graphics.frame_rate
  loop do
    if count==0 && viewport.color.alpha<128
      viewport.color.alpha += alphaDiff
    elsif count>Graphics.frame_rate/4
      viewport.color.alpha -= alphaDiff
    else
      count += 1
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
    break if viewport.color.alpha<=0
  end
  viewport.dispose
  enctype = $PokemonEncounters.encounter_type
  if !enctype || !$PokemonEncounters.encounter_possible_here? ||
     !pbEncounter(enctype)
    pbMessage(_INTL("There appears to be nothing here..."))
  end
end

#===============================================================================
# Fixed overworld weather moving relative to the screen rather than the map.
#===============================================================================
module RPG
  class Weather
    def update_sprite_position(sprite, index, is_new_sprite = false)
      return if !sprite || !sprite.bitmap || !sprite.visible
      delta_t = Graphics.delta_s
      lifetimes = (is_new_sprite) ? @new_sprite_lifetimes : @sprite_lifetimes
      if lifetimes[index] >= 0
        lifetimes[index] -= delta_t
        if lifetimes[index] <= 0
          reset_sprite_position(sprite, index, is_new_sprite)
          return
        end
      end
      # Determine which weather type this sprite is representing
      weather_type = (is_new_sprite) ? @target_type : @type
      # Update visibility/position/opacity of sprite
      if @weatherTypes[weather_type][0].category == :Rain && (index % 2) != 0   # Splash
        sprite.opacity = (lifetimes[index] < 0.2) ? 255 : 0   # 0.2 seconds
      else
        dist_x = @weatherTypes[weather_type][0].particle_delta_x * delta_t
        dist_y = @weatherTypes[weather_type][0].particle_delta_y * delta_t
        sprite.x += dist_x
        sprite.y += dist_y
        if weather_type == :Snow
          sprite.x += dist_x * (sprite.y - @oy) / (Graphics.height * 3)   # Faster when further down screen
          sprite.x += [2, 1, 0, -1][rand(4)] * dist_x / 8   # Random movement
          sprite.y += [2, 1, 1, 0, 0, -1][index % 6] * dist_y / 10   # Variety
        end
        sprite.x -= Graphics.width if sprite.x - @ox > Graphics.width
        sprite.x += Graphics.width if sprite.x - @ox < -sprite.width
        sprite.y -= Graphics.height if sprite.y - @oy > Graphics.height
        sprite.y += Graphics.height if sprite.y - @oy < -sprite.height
        sprite.opacity += @weatherTypes[weather_type][0].particle_delta_opacity * delta_t
        x = sprite.x - @ox
        y = sprite.y - @oy
        # Check if sprite is off-screen; if so, reset it
        if sprite.opacity < 64 || x < -sprite.bitmap.width || y > Graphics.height
          reset_sprite_position(sprite, index, is_new_sprite)
        end
      end
    end

    def recalculate_tile_positions
      delta_t = Graphics.delta_s
      weather_type = @type
      if @fading && @fade_time >= [FADE_OLD_TONE_END - @time_shift, 0].max
        weather_type = @target_type
      end
      @tile_x += @weatherTypes[weather_type][0].tile_delta_x * delta_t
      @tile_y += @weatherTypes[weather_type][0].tile_delta_y * delta_t
      while @tile_x < @ox - @weatherTypes[weather_type][2][0].width
        @tile_x += @weatherTypes[weather_type][2][0].width
      end
      while @tile_x > @ox
        @tile_x -= @weatherTypes[weather_type][2][0].width
      end
      while @tile_y < @oy - @weatherTypes[weather_type][2][0].height
        @tile_y += @weatherTypes[weather_type][2][0].height
      end
      while @tile_y > @oy
        @tile_y -= @weatherTypes[weather_type][2][0].height
      end
    end

    def update_tile_position(sprite, index)
      return if !sprite || !sprite.bitmap || !sprite.visible
      sprite.x = @tile_x.round + (index % @tiles_wide) * sprite.bitmap.width
      sprite.y = @tile_y.round + (index / @tiles_wide) * sprite.bitmap.height
      sprite.x += @tiles_wide * sprite.bitmap.width if sprite.x - @ox < -sprite.bitmap.width
      sprite.y -= @tiles_tall * sprite.bitmap.height if sprite.y - @oy > Graphics.height
      sprite.visible = true
      if @fading && @type != @target_type
        if @fade_time >= FADE_OLD_TILES_START && @fade_time < FADE_OLD_TILES_END
          if @time_shift == 0   # There were old tiles to fade out
            fraction = (@fade_time - [FADE_OLD_TILES_START - @time_shift, 0].max) / (FADE_OLD_TILES_END - FADE_OLD_TILES_START)
            sprite.opacity = 255 * (1 - fraction)
          end
        elsif @fade_time >= [FADE_NEW_TILES_START - @time_shift, 0].max &&
              @fade_time < [FADE_NEW_TILES_END - @time_shift, 0].max
          fraction = (@fade_time - [FADE_NEW_TILES_START - @time_shift, 0].max) / (FADE_NEW_TILES_END - FADE_NEW_TILES_START)
          sprite.opacity = 255 * fraction
        else
          sprite.opacity = 0
        end
      else
        sprite.opacity = (@max > 0) ? 255 : 0
      end
    end
  end
end