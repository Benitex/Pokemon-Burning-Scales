#==============================================================================
# "v19.1 Hotfixes" plugin
# This file contains fixes for miscellaneous bugs.
# These bug fixes are also in the master branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#==============================================================================

Essentials::ERROR_TEXT += "[v19.1 Hotfixes 1.0.2]\r\n"

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
# wrong value as the preferred type and usually crashing
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
