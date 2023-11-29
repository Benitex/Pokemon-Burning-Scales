class PokeBattle_AI
  def pbCalcTypeLinear(moveType, user, target)
    ret = pbCalcTypeMod(moveType, user, target)
    return 0 if ret <= 0
    # triple-type support
    ret *= ret
    # convert to linear scale
    ret = Math.log(ret, 2).round(0)
    # offset values so that 0 = neutral, <0 = not very effective, >0 = super
    ret -= 6
    return ret
  end

  def pbCheckMoveImmunity(score, move, user, target, skill)
    type = pbRoughType(move, user, skill)
    typeMod = pbCalcTypeMod(type, user, target)
    # Type effectiveness
    return true if (move.damagingMove? && Effectiveness.ineffective?(typeMod)) || score <= 0
    # Immunity due to ability/item/other effects
    if skill >= PBTrainerAI.mediumSkill
      case type
      when :GROUND
        return true if target.airborne? && !move.hitsFlyingTargets? || target.hasActiveAbility?(:EARTHEATER)
      when :FIRE
        return true if target.hasActiveAbility?(:FLASHFIRE)
      when :WATER
        return true if target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB])
      when :GRASS
        return true if target.hasActiveAbility?(:SAPSIPPER)
      when :ELECTRIC
        return true if target.hasActiveAbility?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
      end
      return true if move.damagingMove? && Effectiveness.not_very_effective?(typeMod) &&
                     target.hasActiveAbility?(:WONDERGUARD)
      return true if move.damagingMove? && user.index != target.index && !target.opposes?(user) &&
                     target.hasActiveAbility?(:TELEPATHY)
      return true if move.statusMove? && move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(user)
      return true if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
      return true if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if target.hasActiveAbility?(:OVERCOAT)
        return true if target.hasActiveItem?(:SAFETYGOGGLES)
      end
      return true if move.statusMove? && target.effects[PBEffects::Substitute] > 0 &&
                     !move.ignoresSubstitute?(user) && user.index != target.index
      return true if move.statusMove? && Settings::MECHANICS_GENERATION >= 7 &&
                     user.hasActiveAbility?(:PRANKSTER) && target.pbHasType?(:DARK) &&
                     target.opposes?(user)
      return true if move.priority > 0 && @battle.field.terrain == :Psychic &&
                     target.affectedByTerrain? && target.opposes?(user)
    end
    return false
  end
end