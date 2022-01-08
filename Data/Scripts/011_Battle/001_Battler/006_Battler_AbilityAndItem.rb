class PokeBattle_Battler
  #=============================================================================
  # Called when a Pokémon (self) is sent into battle or its ability changes.
  #=============================================================================
  def pbEffectsOnSwitchIn(switchIn=false)
    # Healing Wish/Lunar Dance/entry hazards
    @battle.pbOnActiveOne(self) if switchIn
    # Primal Revert upon entering battle
    @battle.pbPrimalReversion(@index) if !fainted?
    # Ending primordial weather, checking Trace
    pbContinualAbilityChecks(true)
    # Abilities that trigger upon switching in
    if (!fainted? && unstoppableAbility?) || abilityActive?
      BattleHandlers.triggerAbilityOnSwitchIn(self.ability,self,@battle)
    end
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Items that trigger upon switching in (Air Balloon message)
    if switchIn && itemActive?
      BattleHandlers.triggerItemOnSwitchIn(self.item,self,@battle)
    end
    # Berry check, status-curing ability check
    pbHeldItemTriggerCheck if switchIn
    pbAbilityStatusCureCheck
  end

  #=============================================================================
  # Called when a Pokémon enters battle, and when Ally Switch is used.
  #=============================================================================
  def pbEffectsOnEnteringPosition
    position = @battle.positions[@index]
    # Healing Wish
    if position.effects[PBEffects::HealingWish]
      if canHeal? || self.status != :NONE
        @battle.pbCommonAnimation("HealingWish", self)
        @battle.pbDisplay(_INTL("The healing wish came true for {1}!", pbThis(true)))
        pbRecoverHP(@totalhp)
        pbCureStatus(false)
        position.effects[PBEffects::HealingWish] = false
      elsif Settings::MECHANICS_GENERATION < 8
        position.effects[PBEffects::HealingWish] = false
      end
    end
    # Lunar Dance
    if position.effects[PBEffects::LunarDance]
      full_pp = true
      eachMove { |m| full_pp = false if m.pp < m.total_pp }
      if canHeal? || self.status != :NONE || !full_pp
        @battle.pbCommonAnimation("LunarDance", self)
        @battle.pbDisplay(_INTL("{1} became cloaked in mystical moonlight!", pbThis))
        pbRecoverHP(@totalhp)
        pbCureStatus(false)
        eachMove { |m| m.pp = m.total_pp }
        position.effects[PBEffects::LunarDance] = false
      elsif Settings::MECHANICS_GENERATION < 8
        position.effects[PBEffects::LunarDance] = false
      end
    end
  end

  #=============================================================================
  # Ability effects
  #=============================================================================
  def pbAbilitiesOnSwitchOut
    if abilityActive?
      BattleHandlers.triggerAbilityOnSwitchOut(self.ability,self,false)
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    # Treat self as fainted
    @hp = 0
    @fainted = true
    # Neutralizing Gas
    pbCheckNeutralizingGas if hasActiveAbility?(:NEUTRALIZINGGAS, true)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  def pbAbilitiesOnFainting
    # Self fainted; check all other battlers to see if their abilities trigger
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      BattleHandlers.triggerAbilityChangeOnBattlerFainting(b.ability,b,self,@battle)
    end
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      BattleHandlers.triggerAbilityOnBattlerFainting(b.ability,b,self,@battle)
    end
    pbCheckNeutralizingGas if hasActiveAbility?(:NEUTRALIZINGGAS, true)
  end

  # Used for Emergency Exit/Wimp Out.
  def pbAbilitiesOnDamageTaken(oldHP,newHP=-1)
    return false if !abilityActive?
    newHP = @hp if newHP<0
    return false if oldHP<@totalhp/2 || newHP>=@totalhp/2   # Didn't drop below half
    ret = BattleHandlers.triggerAbilityOnHPDroppedBelowHalf(self.ability,self,@battle)
    return ret   # Whether self has switched out
  end

  def pbAbilityOnTerrainChange(ability_changed = false)
    return if !abilityActive?
    BattleHandlers.triggerAbilityOnTerrainChange(self.ability, self, @battle, ability_changed)
  end

  # Used for Rattled's Gen 8 effect. Called when Intimidate is triggered.
  def pbAbilitiesOnIntimidated
    return if !abilityActive?
    BattleHandlers.triggerAbilityOnIntimidated(self.ability, self, @battle)
  end

  # Called when a Pokémon (self) enters battle, at the end of each move used,
  # and at the end of each round.
  def pbContinualAbilityChecks(onSwitchIn=false)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Trace
    if hasActiveAbility?(:TRACE)
      # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
      #       in and not at any later times, even if a traceable ability turns
      #       up later. Essentials ignores this, and allows Trace to trigger
      #       whenever it can even in the old battle mechanics.
      choices = []
      @battle.eachOtherSideBattler(@index) do |b|
        next if b.ungainableAbility? ||
                [:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(b.ability_id)
        choices.push(b)
      end
      if choices.length>0
        choice = choices[@battle.pbRandom(choices.length)]
        @battle.pbShowAbilitySplash(self)
        self.ability = choice.ability
        @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,choice.pbThis(true),choice.abilityName))
        @battle.pbHideAbilitySplash(self)
        if !onSwitchIn && (unstoppableAbility? || abilityActive?)
          BattleHandlers.triggerAbilityOnSwitchIn(self.ability,self,@battle)
        end
      end
    end
  end

  #=============================================================================
  # Ability curing
  #=============================================================================
  # Cures status conditions, confusion and infatuation.
  def pbAbilityStatusCureCheck
    if abilityActive?
      BattleHandlers.triggerStatusCureAbility(self.ability,self)
    end
  end

  #=============================================================================
  # Ability change
  #=============================================================================
  def pbOnAbilityChanged(oldAbil)
    if @effects[PBEffects::Illusion] && oldAbil == :ILLUSION
      @effects[PBEffects::Illusion] = nil
      if !@effects[PBEffects::Transform]
        @battle.scene.pbChangePokemon(self, @pokemon)
        @battle.pbDisplay(_INTL("{1}'s {2} wore off!", pbThis, GameData::Ability.get(oldAbil).name))
        @battle.pbSetSeen(self)
      end
    end
    @effects[PBEffects::GastroAcid] = false if unstoppableAbility?
    @effects[PBEffects::SlowStart]  = 0 if self.ability != :SLOWSTART
    @effects[PBEffects::Truant]     = false if self.ability != :TRUANT
    @effects[PBEffects::ChoiceBand] = nil if self.ability != :GORILLATACTICS
    # Revert form if Flower Gift/Forecast was lost
    pbCheckFormOnWeatherChange(true)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
  end

  # Checking whether Neutralizing Gas is active or not
  def pbCheckNeutralizingGas
    return if @battle.field.effects[PBEffects::NeutralizingGas] < 0
    return if @battle.field.effects[PBEffects::NeutralizingGas] != self.index
    @battle.pbDisplay(_INTL("The effects of {1} wore off!", abilityName))
    @battle.field.effects[PBEffects::NeutralizingGas] = -1
    @battle.pbEndPrimordialWeather
    @battle.pbPriority(true).each do |b|
      next if b.index == self.index || b.fainted?
      next if !b.unstoppableAbility? && !b.abilityActive?
      BattleHandlers.triggerAbilityOnSwitchIn(b.ability, b, @battle)
    end
  end

  #=============================================================================
  # Held item consuming/removing
  #=============================================================================
  def canConsumeBerry?
    return false if @battle.pbCheckOpposingAbility(:UNNERVE,@index)
    return false if @battle.pbCheckOpposingAbility(:ASONEICE,@index)
    return false if @battle.pbCheckOpposingAbility(:ASONEGHOST,@index)
    return true
  end

  def canConsumePinchBerry?(check_gluttony = true)
    return false if !canConsumeBerry?
    return true if @hp <= @totalhp / 4
    return true if @hp <= @totalhp / 2 && (!check_gluttony || hasActiveAbility?(:GLUTTONY))
    return false
  end

  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent = true)
    @effects[PBEffects::ChoiceBand] = nil if !hasActiveAbility?(:GORILLATACTICS)
    @effects[PBEffects::Unburden]   = true if self.item && hasActiveAbility?(:UNBURDEN)
    setInitialItem(nil) if permanent && self.item == self.initialItem
    self.item = nil
  end

  def pbConsumeItem(recoverable=true,symbiosis=true,belch=true)
    PBDebug.log("[Item consumed] #{pbThis} consumed its held #{itemName}")
    if recoverable
      setRecycleItem(@item_id)
      @effects[PBEffects::PickupItem] = @item_id
      @effects[PBEffects::PickupUse]  = @battle.nextPickupUse
    end
    setBelched if belch && self.item.is_berry?
    pbRemoveItem
    pbSymbiosis if symbiosis
  end

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

  # item_to_use is an item ID or GameData::Item object. own_item is whether the
  # item is held by self. fling is for Fling only.
  def pbHeldItemTriggered(item_to_use, own_item = true, fling = false)
    # Cheek Pouch
    if hasActiveAbility?(:CHEEKPOUCH) && GameData::Item.get(item_to_use).is_berry? && canHeal?
      @battle.pbShowAbilitySplash(self)
      pbRecoverHP(@totalhp / 3)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1}'s HP was restored.", pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.", pbThis, abilityName))
      end
      @battle.pbHideAbilitySplash(self)
    end
    pbConsumeItem if own_item
    pbSymbiosis if !own_item && !fling   # Bug Bite/Pluck users trigger Symbiosis
  end

  #=============================================================================
  # Held item trigger checks
  #=============================================================================
  # NOTE: A Pokémon using Bug Bite/Pluck, and a Pokémon having an item thrown at
  #       it via Fling, will gain the effect of the item even if the Pokémon is
  #       affected by item-negating effects.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbHeldItemTriggerCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    pbItemHPHealCheck(item_to_use, fling)
    pbItemStatusCureCheck(item_to_use, fling)
    pbItemEndOfMoveCheck(item_to_use, fling)
    # For Enigma Berry, Kee Berry and Maranga Berry, which have their effects
    # when forcibly consumed by Pluck/Fling.
    if item_to_use
      itm = item_to_use || self.item
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(itm, self, @battle, true)
        pbHeldItemTriggered(itm, false, fling)
      end
    end
  end

  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemHPHealCheck(item_to_use = nil, fling = false)
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerHPHealItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    elsif !item_to_use
      pbItemTerrainStatBoostCheck
    end
  end

  # Cures status conditions, confusion, infatuation and the other effects cured
  # by Mental Herb.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemStatusCureCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerStatusCureItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Called at the end of using a move.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemEndOfMoveCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerEndOfMoveItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    elsif BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Used for White Herb (restore lowered stats). Only called by Moody and Sticky
  # Web, as all other stat reduction happens because of/during move usage and
  # this handler is also called at the end of each move's usage.
  # item_to_use is an item ID for Bug Bite/Pluck and Fling, and nil otherwise.
  # fling is for Fling only.
  def pbItemStatRestoreCheck(item_to_use = nil, fling = false)
    return if fainted?
    return if !item_to_use && !itemActive?
    itm = item_to_use || self.item
    if BattleHandlers.triggerEndOfMoveStatRestoreItem(itm, self, @battle, !item_to_use.nil?)
      pbHeldItemTriggered(itm, item_to_use.nil?, fling)
    end
  end

  # Called when the battle terrain changes and when a Pokémon loses HP.
  def pbItemTerrainStatBoostCheck
    return if !itemActive?
    if BattleHandlers.triggerTerrainStatBoostItem(self.item, self, @battle)
      pbHeldItemTriggered(self.item)
    end
  end

  # Used for Adrenaline Orb. Called when Intimidate is triggered (even if
  # Intimidate has no effect on the Pokémon).
  def pbItemOnIntimidatedCheck
    return if !itemActive?
    if BattleHandlers.triggerItemOnIntimidated(self.item, self, @battle)
      pbHeldItemTriggered(self.item)
    end
  end
end
