#==============================================================================
# "v19.1 Hotfixes" plugin
# This file contains fixes for bugs relating to battles.
# These bug fixes are also in the master branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#==============================================================================



#==============================================================================
# Fix for some items not working in battle.
#==============================================================================
class PokeBattle_Battler
  def hasActiveItem?(check_item, ignore_fainted = false)
    return false if !itemActive?(ignore_fainted)
    return check_item.include?(@item_id) if check_item.is_a?(Array)
    return self.item == check_item
  end
  alias hasWorkingItem hasActiveItem?
end

#==============================================================================
# Fix for typo in Mind Blown's AI.
#==============================================================================
class PokeBattle_AI
  alias __hotfixes__pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
  def pbGetMoveScoreFunctionCode(score,move,user,target,skill=100)
    case move.function
    #---------------------------------------------------------------------------
    when "170"   # Mind Blown
      reserves = @battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      if @battle.pbCheckGlobalAbility(:DAMP)
        score -= 100
      elsif skill>=PBTrainerAI.mediumSkill && reserves==0 && foes>0
        score -= 100   # don't want to lose
      elsif skill>=PBTrainerAI.highSkill && reserves==0 && foes==0
        score += 80   # want to draw
      else
        score -= (user.totalhp-user.hp)*75/user.totalhp
      end
    else
	  score = __hotfixes__pbGetMoveScoreFunctionCode(score,move,user,target,skill)
	end
	return score
  end
end

#==============================================================================
# Fix for Mummy treating an ability as an integer rather than a symbol.
#==============================================================================
BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = ability
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if oldAbil != nil
  }
)

#==============================================================================
# Fix for AI bug with Natural Gift when a Pokémon has no item.
#==============================================================================
class PokeBattle_Move_096 < PokeBattle_Move
  def pbBaseType(user)
    item = user.item
    ret = :NORMAL
    if item
      @typeArray.each do |type, items|
        next if !items.include?(item.id)
        ret = type if GameData::Type.exists?(type)
        break
      end
    end
    return ret
  end
end

#==============================================================================
# Fixed error when trying to return an unused item to the Bag in battle.
#==============================================================================
class PokeBattle_Battle
  def pbReturnUnusedItemToBag(item,idxBattler)
    return if !item
    useType = GameData::Item.get(item).battle_use
    return if useType==0 || (useType>=6 && useType<=10)   # Not consumed upon use
    if pbOwnedByPlayer?(idxBattler)
      if $PokemonBag && $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    else
      items = pbGetOwnerItems(idxBattler)
      items.push(item) if items
    end
  end
end

#==============================================================================
# Fixed typo in Relic Song's code that changes Meloetta's form.
#==============================================================================
class PokeBattle_Move_003 < PokeBattle_SleepMove
  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    return if numHits==0
    return if user.fainted? || user.effects[PBEffects::Transform]
    return if @id != :RELICSONG
    return if !user.isSpecies?(:MELOETTA)
    return if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect>0
    newForm = (user.form+1)%2
    user.pbChangeForm(newForm,_INTL("{1} transformed!",user.pbThis))
  end
end

#==============================================================================
# Fixed typo in Conversion's code that treated a type as an item.
#==============================================================================
class PokeBattle_Move_05E < PokeBattle_Move
  def pbEffectGeneral(user)
    newType = @newTypes[@battle.pbRandom(@newTypes.length)]
    user.pbChangeTypes(newType)
    typeName = GameData::Type.get(newType).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
  end
end

#==============================================================================
# Fixed code relating to items initially held by Pokémon in battle.
#==============================================================================
class PokeBattle_Battler
  def setInitialItem(value)
    item_data = GameData::Item.try_get(value)
    new_item = (item_data) ? item_data.id : nil
    @battle.initialItems[@index&1][@pokemonIndex] = new_item
  end

  def setRecycleItem(value)
    item_data = GameData::Item.try_get(value)
    new_item = (item_data) ? item_data.id : nil
    @battle.recycleItems[@index&1][@pokemonIndex] = new_item
  end
end

class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't thieve
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? && !user.initialItem &&
       target.item == target.initialItem
      user.setInitialItem(target.item)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
    user.pbHeldItemTriggerCheck
  end
end

class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    oldUserItem = user.item;     oldUserItemName = user.itemName
    oldTargetItem = target.item; oldTargetItemName = target.itemName
    user.item                             = oldTargetItem
    user.effects[PBEffects::ChoiceBand]   = nil
    user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem)
    target.item                           = oldUserItem
    target.effects[PBEffects::ChoiceBand] = nil
    target.effects[PBEffects::Unburden]   = (!target.item && oldTargetItem)
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? && !user.initialItem &&
       oldTargetItem == target.initialItem
      user.setInitialItem(oldTargetItem)
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!",user.pbThis))
    @battle.pbDisplay(_INTL("{1} obtained {2}.",user.pbThis,oldTargetItemName)) if oldTargetItem
    @battle.pbDisplay(_INTL("{1} obtained {2}.",target.pbThis,oldUserItemName)) if oldUserItem
    user.pbHeldItemTriggerCheck
    target.pbHeldItemTriggerCheck
  end
end

class PokeBattle_Move_0F3 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    itemName = user.itemName
    target.item = user.item
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && user.opposes? && !target.initialItem &&
       user.item == user.initialItem
      target.setInitialItem(user.item)
      user.pbRemoveItem
    else
      user.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!",target.pbThis,itemName,user.pbThis(true)))
    target.pbHeldItemTriggerCheck
  end
end

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      if battle.wildBattle? && !user.initialItem && user.item == b.initialItem
        user.setInitialItem(user.item)
        b.setInitialItem(nil)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
           b.pbThis(true),user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),user.itemName,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability,target,user,move,switched,battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. This doesn't make
    #       sense, so this code doesn't do it.
    next if battle.wildBattle? && target.opposes?
    next if !move.contactMove?
    next if switched.include?(user.index)
    next if user.effects[PBEffects::Substitute]>0 || target.damageState.substitute
    next if target.item || !user.item
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if user.hasActiveAbility?(:STICKYHOLD)
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = nil
    user.effects[PBEffects::Unburden] = true
    if battle.wildBattle? && !target.initialItem && target.item == user.initialItem
      target.setInitialItem(target.item)
      user.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
       user.pbThis(true),target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

BattleHandlers::TargetItemOnHit.add(:STICKYBARB,
  proc { |item,user,target,move,battle|
    next if !move.pbContactMove?(user) || !user.affectedByContactEffect?
    next if user.fainted? || user.item
    user.item = target.item
    target.item = nil
    target.effects[PBEffects::Unburden] = true
    if battle.wildBattle? && !user.opposes?
      if !user.initialItem && user.item == target.initialItem
        user.setInitialItem(user.item)
        target.setInitialItem(nil)
      end
    end
    battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
       target.pbThis,user.itemName,user.pbThis(true)))
  }
)

#==============================================================================
# Fixed Symbiosis not working.
#==============================================================================
class PokeBattle_Battler
  def pbSymbiosis
    return if fainted?
    return if self.item
    @battle.pbPriority(true).each do |b|
      next if b.opposes?
      next if !b.hasActiveAbility?(:SYMBIOSIS)
      next if !b.item || b.unlosableItem?(b.item)
      next if unlosableItem?(b.item)
      @battle.pbShowAbilitySplash(b)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} shared its {2} with {3}!",
           b.pbThis,b.itemName,pbThis(true)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} let it share its {3} with {4}!",
           b.pbThis,b.abilityName,b.itemName,pbThis(true)))
      end
      self.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      @battle.pbHideAbilitySplash(b)
      pbHeldItemTriggerCheck
      break
    end
  end
end

#===============================================================================
# Fixed Roost not removing the Flying type.
#===============================================================================
class PokeBattle_Move_0D6 < PokeBattle_HealingMove
  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::Roost] = true
  end
end

#===============================================================================
# Fixed Normalize not boosting damage in Gen 7+.
#===============================================================================
BattleHandlers::DamageCalcUserAbility.copy(:AERILATE, :NORMALIZE)
