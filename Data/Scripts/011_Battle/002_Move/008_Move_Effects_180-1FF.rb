#===============================================================================
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped contact move by 2 stages. (Obstruct)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Obstruct
  end
end



#===============================================================================
# Lowers target's Defense and Special Defense by 1 stage at the end of each
# turn. Prevents target from retreating. (Octolock)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    return false if damagingMove?
    if target.effects[PBEffects::Octolock] >= 0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Octolock] = user.index
    @battle.pbDisplay(_INTL("{1} can no longer escape because of {2}!", target.pbThis, @name))
  end
end



#===============================================================================
# Ignores move redirection from abilities and moves. (Snipe Shot)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_Move
  def cannotRedirect?; return true; end
end



#===============================================================================
# Consumes berry and raises the user's Defense by 2 stages. (Stuff Cheeks)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_StatUpMove
  def initialize(battle, move)
    super
    @statUp = [:DEFENSE, 2]
  end

  def pbCanChooseMove?(user,commandPhase,showMessages)
    item = user.item
    if !item || !item.is_berry? || !user.itemActive?
      if showMessages
        msg = _INTL("{1} can't use that move because it doesn't have a Berry!", user.pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    return true
  end

  def pbMoveFailed?(user,targets)
    # NOTE: Unnerve does not stop a Pokémon using this move.
    item = user.item
    if !item || !item.is_berry? || !user.itemActive?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return super
  end

  def pbEffectGeneral(user)
    super
    @battle.pbDisplay(_INTL("{1} ate its {2}!", user.pbThis, user.itemName))
    item = user.item
    user.pbConsumeItem(true, false)   # Don't trigger Symbiosis yet
    user.pbHeldItemTriggerCheck(item, false)
  end
end



#===============================================================================
# Forces all active Pokémon to consume their held berries. This move bypasses
# Substitutes. (Teatime)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbMoveFailed?(user, targets)
    failed = true
    targets.each do |b|
      next if !b.item || !b.item.is_berry?
      next if b.semiInvulnerable?
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But nothing happened!"))
      return true
    end
    return false
  end

  def pbOnStartUse(user,targets)
    @battle.pbDisplay(_INTL("It's teatime! Everyone dug in to their Berries!"))
  end

  def pbFailsAgainstTarget?(user, target)
    return true if !target.item || !target.item.is_berry? || target.semiInvulnerable?
    return false
  end

  def pbEffectAgainstTarget(user, target)
    @battle.pbCommonAnimation("EatBerry", target)
    item = target.item
    target.pbConsumeItem(true, false)   # Don't trigger Symbiosis yet
    target.pbHeldItemTriggerCheck(item, false)
  end
end



#===============================================================================
# Decreases Opponent's Defense by 1 stage. Does Double Damage under gravity
# (Grav Apple)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,1]
  end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg = baseDmg * 3 / 2 if @battle.field.effects[PBEffects::Gravity] > 0
    return baseDmg
  end
end



#===============================================================================
# Decrease 1 stage of speed and weakens target to fire moves. (Tar Shot)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.pbCanLowerStatStage?(:SPEED,target,self) && !target.effects[PBEffects::TarShot]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbLowerStatStage(:SPEED,1,target)
    target.effects[PBEffects::TarShot] = true
    @battle.pbDisplay(_INTL("{1} became weaker to fire!",target.pbThis))
  end
end



#===============================================================================
# Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
# (Shell Side Arm)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move_005
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def physicalMove?(thisType = nil); return (@calcCategory == 0); end
  def specialMove?(thisType = nil);  return (@calcCategory == 1); end
  def contactMove?;                  return physicalMove?;        end

  def pbOnStartUse(user, targets)
    target = targets[0]
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Calculate user's effective attacking values
    attack_stage         = user.stages[:ATTACK] + 6
    real_attack          = (user.attack.to_f * stageMul[attack_stage] / stageDiv[attack_stage]).floor
    special_attack_stage = user.stages[:SPECIAL_ATTACK] + 6
    real_special_attack  = (user.spatk.to_f * stageMul[special_attack_stage] / stageDiv[special_attack_stage]).floor
    # Calculate target's effective defending values
    defense_stage         = target.stages[:DEFENSE] + 6
    real_defense          = (target.defense.to_f * stageMul[defense_stage] / stageDiv[defense_stage]).floor
    special_defense_stage = target.stages[:SPECIAL_DEFENSE] + 6
    real_special_defense  = (target.spdef.to_f * stageMul[special_defense_stage] / stageDiv[special_defense_stage]).floor
    # Perform simple damage calculation
    physical_damage = real_attack.to_f / real_defense
    special_damage = real_special_attack.to_f / real_special_defense
    # Determine move's category
    if physical_damage == special_damage
      @calcCategry = @battle.pbRandom(2)
    else
      @calcCategory = (physical_damage > special_damage) ? 0 : 1
    end
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    hitNum = 1 if physicalMove?
    super
  end
end



#===============================================================================
# Hits 3 times and always critical. (Surging Strikes)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_Move
  def multiHitMove?;                   return true; end
  def pbNumHits(user, targets);        return 3;    end
  def pbCritialOverride(user, target); return 1;    end
end

#===============================================================================
# Restore HP and heals any status conditions of itself and its allies
# (Jungle Healing)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if b.status == :NONE && !b.canHeal?
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    return target.status == :NONE && !target.canHeal?
  end

  def pbEffectAgainstTarget(user,target)
    if target.canHeal?
      target.pbRecoverHP(target.totalhp / 4)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.", target.pbThis))
    end
    if target.status != :NONE
      old_status = target.status
      target.pbCureStatus(false)
      case old_status
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from sleep.", target.pbThis))
      when :POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", target.pbThis))
      when :BURN
        @battle.pbDisplay(_INTL("{1}'s burn was healed.", target.pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.", target.pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was thawed out.", target.pbThis))
      end
    end
  end
end



#===============================================================================
# Changes type and base power based on Battle Terrain (Terrain Pulse)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain != :None && user.affectedByTerrain?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    return ret if !user.affectedByTerrain?
    case @battle.field.terrain
    when :Electric
      ret = :ELECTRIC if GameData::Type.exists?(:ELECTRIC)
    when :Grassy
      ret = :GRASS if GameData::Type.exists?(:GRASS)
    when :Misty
      ret = :FAIRY if GameData::Type.exists?(:FAIRY)
    when :Psychic
      ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
    end
    return ret
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end



#===============================================================================
# Burns opposing Pokemon that have increased their stats in that turn before the
# execution of this move (Burning Jealousy)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_BurnMove
  def pbAdditionalEffect(user, target)
    super if target.statsRaised
  end
end



#===============================================================================
# Move has increased Priority in Grassy Terrain (Grassy Glide)
#===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
  def pbPriority(user)
    ret = super
    ret += 1 if @battle.field.terrain == :Grassy && user.affectedByTerrain?
    return ret
  end
end


#===============================================================================
# Power Doubles on Electric Terrain (Rising Voltage)
#===============================================================================
class PokeBattle_Move_18D < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if @battle.field.terrain == :Electric && target.affectedByTerrain?
    return baseDmg
  end
end



#===============================================================================
# Boosts Targets' Attack and Defense (Coaching)
#===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1]
  end

  def pbMoveFailed?(user,targets)
    @validTargets = []
    @battle.eachSameSideBattler(user) do |b|
      next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
              !b.pbCanRaiseStatStage?(:DEFENSE,user,self)
      next if b.index == user.index
      @validTargets.push(b)
    end
    if @validTargets.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    ret = super
    return true if !@validTargets.any? { |b| b.index == target.index }
    return ret
  end
end



#===============================================================================
# Renders item unusable (Corrosive Gas)
#===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    # unlosableItem already checks for whether the item is corroded
    if !target.item || target.unlosableItem?(target.item) ||
       target.effects[PBEffects::Substitute] > 0
      @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
      return true
    end
    if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",
           target.pbThis(true), target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.setCorrodedItem
    target.setRecycleItem(nil)
    target.effects[PBEffects::PickupItem] = nil
    target.effects[PBEffects::PickupUse]  = 0
    @battle.pbDisplay(_INTL("{1} corroded {2}'s {3}!",
       user.pbThis, target.pbThis(true), target.itemName))
  end
end



#===============================================================================
# Power is boosted on Psychic Terrain (Expanding Force)
#===============================================================================
class PokeBattle_Move_190 < PokeBattle_Move
  def pbTarget(user)
    if @battle.field.terrain == :Psychic && user.affectedByTerrain?
      return GameData::Target.get(:AllNearFoes)
    end
    return super
  end

  def pbBaseDamage(baseDmg,user,target)
    if @battle.field.terrain == :Psychic && user.affectedByTerrain?
      baseDmg = baseDmg * 3 / 2
    end
    return baseDmg
  end
end



#===============================================================================
# Boosts Sp Atk on 1st Turn and Attacks on 2nd (Meteor Beam)
#===============================================================================
class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!",user.pbThis))
  end

  def pbChargingTurnEffect(user,target)
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
    end
  end
end



#===============================================================================
# Fails if the Target has no Item (Poltergeist)
#===============================================================================
class PokeBattle_Move_192 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.item || !target.itemActive?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis, target.itemName))
    return false
  end
end



#===============================================================================
# Reduces Defense and Raises Speed after all hits (Scale Shot)
#===============================================================================
class PokeBattle_Move_193 < PokeBattle_Move_0C0
  def pbEffectAfterAllHits(user,target)
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanLowerStatStage?(:DEFENSE,target)
      user.pbLowerStatStage(:DEFENSE,1,user)
    end
  end
end



#===============================================================================
# Double damage if stats were lowered that turn. (Lash Out)
#===============================================================================
class PokeBattle_Move_194 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.statsLowered
    return baseDmg
  end
end



#===============================================================================
# Removes all Terrain. Fails if there is no Terrain (Steel Roller)
#===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :None
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    case @battle.field.terrain
    when :Electric
      @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
    when :Grassy
      @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
    when :Misty
      @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
    when :Psychic
      @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
    end
    @battle.field.terrain = :None
  end
end



#===============================================================================
# Self KO. Boosted Damage when on Misty Terrain (Misty Explosion)
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move_0E0
  def pbBaseDamage(baseDmg,user,target)
    baseDmg = baseDmg * 3 / 2 if @battle.field.terrain == :Misty && user.affectedByTerrain?
    return baseDmg
  end
end



#===============================================================================
# Target becomes Psychic type. (Magic Powder)
#===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if !target.canChangeType? || !GameData::Type.exists?(:PSYCHIC) ||
       !target.pbHasOtherType?(:PSYCHIC) || !target.affectedByPowder?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.pbChangeTypes(:PSYCHIC)
    typeName = GameData::Type.get(:PSYCHIC).name
    @battle.pbDisplay(_INTL("{1}'s type changed to {2}!", target.pbThis, typeName))
  end
end

#===============================================================================
# Target's last move used loses 3 PP. (Eerie Spell)
#===============================================================================
class PokeBattle_Move_198 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    failed = true
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed || m.pp==0 || m.total_pp<=0
      failed = false; break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed
      reduction = [3,m.pp].min
      target.pbSetPP(m,m.pp-reduction)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true),m.name,reduction))
      break
    end
  end
end

#===============================================================================
# The user takes recoil damage equal to 1/2 of its total HP (rounded up, min. 1
# damage). (Steel Beam)
#===============================================================================
class PokeBattle_Move_199 < PokeBattle_RecoilMove
  def pbEffectAfterAllHits(user, target)
    return if !user.takesIndirectDamage?
    amt = (user.totalhp / 2.0).ceil
    amt = 1 if amt < 1
    user.pbReduceHP(amt, false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Deals double damage to Dynamax Pokémon. Dynamax is not implemented though.
# (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
#===============================================================================
class PokeBattle_Move_19A < PokeBattle_Move
end


# NOTE: If you're inventing new move effects, use function code 19B and onwards.
#       Actually, you might as well use high numbers like 500+ (up to FFFF),
#       just to make sure later additions to Essentials don't clash with your
#       new effects.
