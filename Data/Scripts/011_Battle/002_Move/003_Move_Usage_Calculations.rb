class PokeBattle_Move
  #=============================================================================
  # Move's type calculation
  #=============================================================================
  def pbBaseType(user)
    ret = @type
    if ret && user.abilityActive?
      ret = BattleHandlers.triggerMoveBaseTypeModifierAbility(user.ability,user,self,ret)
    end
    return ret
  end

  def pbCalcType(user)
    @powerBoost = false
    ret = pbBaseType(user)
    if ret && GameData::Type.exists?(:ELECTRIC)
      if @battle.field.effects[PBEffects::IonDeluge] && ret == :NORMAL
        ret = :ELECTRIC
        @powerBoost = false
      end
      if user.effects[PBEffects::Electrify]
        ret = :ELECTRIC
        @powerBoost = false
      end
    end
    return ret
  end

  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = Effectiveness.calculate_one(moveType, defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Delta Stream's weather
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
    if target.effects[PBEffects::TarShot] && moveType == :FIRE
      ret = Effectiveness::SUPER_EFFECTIVE_ONE if Effectiveness.normal_type?(moveType,target.type1,target.type2)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.not_very_effective_type?(moveType,target.type1,target.type2)
    end
    return ret
  end

  def pbCalcTypeMod(moveType,user,target)
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
       target.pbHasType?(:FLYING) && target.hasActiveItem?(:IRONBALL)
    # Determine types
    tTypes = target.pbTypes(true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |type,i|
        typeMods[i] = pbCalcTypeModSingle(moveType,type,user,target)
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    return ret
  end

  #=============================================================================
  # Accuracy check
  #=============================================================================
  def pbBaseAccuracy(user,target); return @accuracy; end

  # Accuracy calculations for one-hit KO moves and "always hit" moves are
  # handled elsewhere.
  def pbAccuracyCheck(user,target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis]>0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
    baseAcc = pbBaseAccuracy(user,target)
    return true if baseAcc==0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
    evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
    accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
    evasion  = (evasion  * modifiers[:evasion_multiplier]).round
    evasion = 1 if evasion < 1
    # Calculation
    ret = @battle.pbRandom(100) < modifiers[:base_accuracy] * accuracy / evasion
    return ret
  end

  def pbCalcAccuracyModifiers(user,target,modifiers)
    # Ability effects that alter accuracy calculation
    if user.abilityActive?
      BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
         modifiers,user,target,self,@calcType)
    end
    user.eachAlly do |b|
      next if !b.abilityActive?
      BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
         modifiers,user,target,self,@calcType)
    end
    if target.abilityActive? && !@battle.moldBreaker
      BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
         modifiers,user,target,self,@calcType)
    end
    # Item effects that alter accuracy calculation
    if user.itemActive?
      BattleHandlers.triggerAccuracyCalcUserItem(user.item,
         modifiers,user,target,self,@calcType)
    end
    if target.itemActive?
      BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
         modifiers,user,target,self,@calcType)
    end
    # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to
    # specific values
    if @battle.field.effects[PBEffects::Gravity] > 0
      modifiers[:accuracy_multiplier] *= 5 / 3.0
    end
    if user.effects[PBEffects::MicleBerry]
      user.effects[PBEffects::MicleBerry] = false
      modifiers[:accuracy_multiplier] *= 1.2
    end
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
    modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
    modifiers[:accuracy_multiplier] *= 0.6 if @battle.pbWeather == :Fog
  end

  #=============================================================================
  # Critical hit check
  #=============================================================================
  # Return values:
  #   -1: Never a critical hit.
  #    0: Calculate normally.
  #    1: Always a critical hit.
  def pbCritialOverride(user,target); return 0; end

  # Returns whether the move will be a critical hit.
  def pbIsCritical?(user,target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
    # Set up the critical hit ratios
    ratios = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? [24,8,2,1] : [16,8,4,3,2]
    c = 0
    # Ability effects that alter critical hit rate
    if c>=0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
    end
    if c>=0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
    end
    # Item effects that alter critical hit rate
    if c>=0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
    end
    if c>=0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
    end
    return false if c<0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user,target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return true if c>50   # Merciless
    return true if user.effects[PBEffects::LaserFocus]>0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length-1 if c>=ratios.length
    # Calculation
    return @battle.pbRandom(ratios[c])==0
  end

  #=============================================================================
  # Damage calculation
  #=============================================================================
  def pbBaseDamage(baseDmg,user,target);              return baseDmg;    end
  def pbBaseDamageMultiplier(damageMult,user,target); return damageMult; end
  def pbModifyDamage(damageMult,user,target);         return damageMult; end

  def pbGetAttackStats(user,target)
    if specialMove?
      return user.spatk, user.stages[:SPECIAL_ATTACK]+6
    end
    return user.attack, user.stages[:ATTACK]+6
  end

  def pbGetDefenseStats(user,target)
    if specialMove?
      return target.spdef, target.stages[:SPECIAL_DEFENSE]+6
    end
    return target.defense, target.stages[:DEFENSE]+6
  end

  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise || target.damageState.iceface
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
      atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage>6
      defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
    end
    # Calculate all multiplier effects
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      BattleHandlers.triggerDamageCalcUserAbility(user.ability,
         user,target,self,multipliers,baseDmg,type)
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      if target.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
        BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      BattleHandlers.triggerDamageCalcUserItem(user.item,
         user,target,self,multipliers,baseDmg,type)
    end
    if target.itemActive?
      BattleHandlers.triggerDamageCalcTargetItem(target.item,
         user,target,self,multipliers,baseDmg,type)
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    # Mud Sport
    if type == :ELECTRIC
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::MudSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::MudSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::WaterSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::WaterSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Terrain moves
    case @battle.field.terrain
    when :Electric
      multipliers[:base_damage_multiplier] *= 1.3 if type == :ELECTRIC && user.affectedByTerrain?
    when :Grassy
      multipliers[:base_damage_multiplier] *= 1.3 if type == :GRASS && user.affectedByTerrain?
    when :Psychic
      multipliers[:base_damage_multiplier] *= 1.3 if type == :PSYCHIC && user.affectedByTerrain?
    when :Misty
      multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
    end
    # Badge multipliers
    if @battle.internalBattle
      if user.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_ATTACK
          multipliers[:attack_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPATK
          multipliers[:attack_multiplier] *= 1.1
        end
      end
      if target.pbOwnedByPlayer?
        if physicalMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
          multipliers[:defense_multiplier] *= 1.1
        elsif specialMove? && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
          multipliers[:defense_multiplier] *= 1.1
        end
      end
    end
    # Multi-targeting attacks
    if numTargets>1
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    case @battle.pbWeather
    when :Sun, :HarshSun
      if type == :FIRE
        multipliers[:final_damage_multiplier] *= 1.5 if !target.hasUtilityUmbrella?
      elsif type == :WATER
        multipliers[:final_damage_multiplier] /= 2 if !target.hasUtilityUmbrella?
      end
    when :Rain, :HeavyRain
      if type == :FIRE
        multipliers[:final_damage_multiplier] /= 2 if !target.hasUtilityUmbrella?
      elsif type == :WATER
        multipliers[:final_damage_multiplier] *= 1.5 if !target.hasUtilityUmbrella?
      end
    when :Sandstorm
      if target.pbHasType?(:ROCK) && specialMove? && @function != "122"   # Psyshock
        multipliers[:defense_multiplier] *= 1.5
      end
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # Random variance
    if !self.is_a?(PokeBattle_Confusion)
      random = 85+@battle.pbRandom(16)
      multipliers[:final_damage_multiplier] *= random / 100.0
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Recalculate the type modifier for Dragon Darts else it does 1 damage on its
    # second hit on a different target
    if @function == "17C" && @battle.pbSideSize(target.index)>1
      typeMod = self.pbCalcTypeMod(self.calcType,user,target)
      target.damageState.typeMod = typeMod
    end
    # Type effectiveness
    multipliers[:final_damage_multiplier] *= target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] /= 2
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end

  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = (effectChance>0) ? effectChance : @addlEffect
    if Settings::MECHANICS_GENERATION >= 6 || @function != "0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end

  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 10
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
end
