class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias improvedAI_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "AddSpikesToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3 && move.statusMove?
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) } && move.statusMove?
        score -= 90   # Opponent can't switch in any Pokemon
      elsif user.pbOpposingSide.effects[PBEffects::Spikes] < 3
        score += 15 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [40, 32, 24][user.pbOpposingSide.effects[PBEffects::Spikes]]
      end
    #---------------------------------------------------------------------------
    when "AddToxicSpikesToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90  # Opponent can't switch in any Pokemon
      else
        score += 10 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [26, 13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
      end
    #---------------------------------------------------------------------------
    when "AddStealthRocksToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::StealthRock] && move.statusMove?
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) } && move.statusMove?
        score -= 90   # Opponent can't switch in any Pokemon
      elsif !user.pbOpposingSide.effects[PBEffects::StealthRock]
        score += 25 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      end
    #---------------------------------------------------------------------------
    when "AddStickyWebToFoeSide"
      if user.pbOpposingSide.effects[PBEffects::StickyWeb]
        score -= 95
      else
        score += 15 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      end
    #---------------------------------------------------------------------------
    when "StartSunWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Sun
        score -= 90
      else
        user.eachMove do |m|
          score += 20 if m.damagingMove? && m.type == :FIRE
          score += 40 if m.function == "TwoTurnAttackOneTurnInSun"
        end
        
        score += 40 if user.item == :HEATROCK
        score += 40 if user.ability == :CHLOROPHYLL || user.ability == :FLOWERGIFT || user.ability == :SOLARPOWER || user.ability == :PROTOSYNTHESIS || user.ability == :ORICHALCUMPULSE
        score += 10 if user.ability == :LEAFGUARD
        score -= 20 if user.ability == :DRYSKIN
      end
    #---------------------------------------------------------------------------
    when "StartRainWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Rain
        score -= 90
      else
        user.eachMove do |m|
          score += 20 if m.damagingMove? && m.type == :WATER
          score += 25 if m.function == "ParalyzeTargetAlwaysHitsInRainHitsTargetInSky" || m.function == "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
        end
        
        score += 40 if user.item == :DAMPROCK
        score += 40 if user.ability == :SWIFTSWIM
        score += 20 if user.ability == :WATERDISH || user.ability == :DRYSKIN
        score += 10 if user.ability == :HYDRATION
      end
    #---------------------------------------------------------------------------
    when "StartSandstormWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Sandstorm
        score -= 90
      else
        if user.pbHasType?(:ROCK) && skill >= PBTrainerAI.highSkill
          score += 40
        elsif user.pbHasType?(:STEEL) || user.pbHasType?(:GROUND) || user.pbHasType?(:ROCK)
          score += 15
        elsif user.ability != :SANDRUSH && user.ability != :SANDFORCE && user.ability != :SANDVEIL
          score -= 90
        end
        
        score += 40 if user.item == :SMOOTHROCK
        score += 40 if user.ability == :SANDRUSH || user.ability == :SANDFORCE
        score += 20 if user.ability == :SANDVEIL
      end
    #---------------------------------------------------------------------------
    when "StartHailWeather"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Hail
        score -= 90
      else
        user.eachMove do |m|
          score += 30 if m.function == "FreezeTargetAlwaysHitsInHail" || m.function == "StartWeakenDamageAgainstUserSideIfHail"
        end
        
        if PluginManager.installed?("Generation 9 Pack") && Settings::HAIL_MODE != 1 && user.pbHasType?(:ICE) && skill >= PBTrainerAI.highSkill
          score += 40
        elsif user.pbHasType?(:ICE)
          score += 15
        elsif !(PluginManager.installed?("Generation 9 Pack") && Settings::HAIL_MODE == 0) && user.ability != :SLUSHRUSH && user.ability != :ICEBODY && user.ability != :SNOWCLOAK
          score -= 90
        end
        
        score += 40 if user.item == :ICYROCK
        score += 40 if user.ability == :SLUSHRUSH
        score += 20 if user.ability == :ICEBODY || user.ability == :SNOWCLOAK
      end
    #---------------------------------------------------------------------------
    when "StartWeakenPhysicalDamageAgainstUserSide"
    if user.pbOwnSide.effects[PBEffects::Reflect] > 0
      score -= 90
    elsif user.item == :LIGHTCLAY
      score += 320
    end
    #---------------------------------------------------------------------------
    when "StartWeakenSpecialDamageAgainstUserSide"
    if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
      score -= 90
    elsif user.item == :LIGHTCLAY
      score += 340
    end
    #---------------------------------------------------------------------------
    when "StartWeakenDamageAgainstUserSideIfHail"
      if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || user.effectiveWeather != :Hail
        score -= 90
      elsif user.item == :LIGHTCLAY
        score += 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "StartElectricTerrain"
        if @battle.field.terrain == :Electric
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    when "StartGrassyTerrain"
        if @battle.field.terrain == :Grassy
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    when "StartMistyTerrain"
        if @battle.field.terrain == :Misty
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    when "StartPsychicTerrain"
        if @battle.field.terrain == :Psychic
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    else
      return improvedAI_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end