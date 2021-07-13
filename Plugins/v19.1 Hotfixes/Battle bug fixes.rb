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
