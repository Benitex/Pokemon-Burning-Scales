class PokeBattle_Battler
  #=============================================================================
  # Creating a battler
  #=============================================================================
  def initialize(btl,idxBattler)
    @battle      = btl
    @index       = idxBattler
    @captured    = false
    @dummy       = false
    @stages      = {}
    @effects     = []
    @damageState = PokeBattle_DamageState.new
    pbInitBlank
    pbInitEffects(false)
  end

  def pbInitBlank
    @name           = ""
    @species        = 0
    @form           = 0
    @level          = 0
    @hp = @totalhp  = 0
    @type1 = @type2 = nil
    @ability_id     = nil
    @item_id        = nil
    @gender         = 0
    @attack = @defense = @spatk = @spdef = @speed = 0
    @status         = :NONE
    @statusCount    = 0
    @pokemon        = nil
    @pokemonIndex   = -1
    @participants   = []
    @moves          = []
    @iv             = {}
    GameData::Stat.each_main { |s| @iv[s.id] = 0 }
  end

  # Used by Future Sight only, when Future Sight's user is no longer in battle.
  def pbInitDummyPokemon(pkmn,idxParty)
    raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
    @name         = pkmn.name
    @species      = pkmn.species
    @form         = pkmn.form
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    # ability and item intentionally not copied across here
    @gender       = pkmn.gender
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @speed        = pkmn.speed
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @pokemon      = pkmn
    @pokemonIndex = idxParty
    @participants = []
    # moves intentionally not copied across here
    @iv           = {}
    GameData::Stat.each_main { |s| @iv[s.id] = pkmn.iv[s.id] }
    @dummy        = true
  end

  def pbInitialize(pkmn,idxParty,batonPass=false)
    pbInitPokemon(pkmn,idxParty)
    pbInitEffects(batonPass)
    @damageState.reset
  end

  def pbInitPokemon(pkmn,idxParty)
    raise _INTL("An egg can't be an active Pokémon.") if pkmn.egg?
    @name          = pkmn.name
    @species       = pkmn.species
    @form          = pkmn.form
    @level         = pkmn.level
    @hp            = pkmn.hp
    @totalhp       = pkmn.totalhp
    @type1         = pkmn.type1
    @type2         = pkmn.type2
    @ability_id    = pkmn.ability_id
    @item_id       = pkmn.item_id
    @gender        = pkmn.gender
    @attack        = pkmn.attack
    @defense       = pkmn.defense
    @spatk         = pkmn.spatk
    @spdef         = pkmn.spdef
    @speed         = pkmn.speed
    @status        = pkmn.status
    @statusCount   = pkmn.statusCount
    @pokemon       = pkmn
    @pokemonIndex  = idxParty
    @participants  = []   # Participants earn Exp. if this battler is defeated
    @moves         = []
    @damage_done   = 0
    @critical_hits = 0
    pkmn.moves.each_with_index do |m,i|
      if (isSpecies?(:ZACIAN) || isSpecies?(:ZAMAZENTA)) && @form == 1 && m.id == :IRONHEAD
        moveID = isSpecies?(:ZACIAN) ? :BEHEMOTHBLADE : :BEHEMOTHBASH
        @moves[i] = PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(moveID))
        @moves[i].realMove = m
        maxPP =  GameData::Move.get(moveID).total_pp
        @moves[i].total_pp =  maxPP + (maxPP * m.ppup / 5)
        calcPP = ((m.pp/m.total_pp.to_f) * @moves[i].total_pp).to_i
        pbSetPP(@moves[i],calcPP)
      else
        @moves[i] = PokeBattle_Move.from_pokemon_move(@battle,m)
      end
    end
    @iv          = {}
    GameData::Stat.each_main { |s| @iv[s.id] = pkmn.iv[s.id] }
  end

  def pbInitEffects(batonPass)
    if batonPass
      # These effects are passed on if Baton Pass is used, but they need to be
      # reapplied
      @effects[PBEffects::LaserFocus] = (@effects[PBEffects::LaserFocus]>0) ? 2 : 0
      @effects[PBEffects::LockOn]     = (@effects[PBEffects::LockOn]>0) ? 2 : 0
      if @effects[PBEffects::PowerTrick]
        @attack,@defense = @defense,@attack
      end
      # These effects are passed on if Baton Pass is used, but they need to be
      # cancelled in certain circumstances anyway
      @effects[PBEffects::Telekinesis] = 0 if isSpecies?(:GENGAR) && mega?
      @effects[PBEffects::GastroAcid]  = false if unstoppableAbility?
    else
      # These effects are passed on if Baton Pass is used
      @stages[:ATTACK]          = 0
      @stages[:DEFENSE]         = 0
      @stages[:SPEED]           = 0
      @stages[:SPECIAL_ATTACK]  = 0
      @stages[:SPECIAL_DEFENSE] = 0
      @stages[:ACCURACY]        = 0
      @stages[:EVASION]         = 0
      @effects[PBEffects::AquaRing]          = false
      @effects[PBEffects::Confusion]         = 0
      @effects[PBEffects::Curse]             = false
      @effects[PBEffects::Embargo]           = 0
      @effects[PBEffects::FocusEnergy]       = 0
      @effects[PBEffects::GastroAcid]        = false
      @effects[PBEffects::HealBlock]         = 0
      @effects[PBEffects::Ingrain]           = false
      @effects[PBEffects::LaserFocus]        = 0
      @effects[PBEffects::LeechSeed]         = -1
      @effects[PBEffects::LockOn]            = 0
      @effects[PBEffects::LockOnPos]         = -1
      @effects[PBEffects::MagnetRise]        = 0
      @effects[PBEffects::PerishSong]        = 0
      @effects[PBEffects::PerishSongUser]    = -1
      @effects[PBEffects::PowerTrick]        = false
      @effects[PBEffects::Substitute]        = 0
      @effects[PBEffects::Telekinesis]       = 0
      @effects[PBEffects::NoRetreat]         = false
    end
    @fainted               = (@hp==0)
    @initialHP             = 0
    @lastAttacker          = []
    @lastFoeAttacker       = []
    @lastHPLost            = 0
    @lastHPLostFromFoe     = 0
    @tookDamage            = false
    @tookPhysicalHit       = false
    @statsRaised           = false
    @statsLowered          = false
    @lastMoveUsed          = nil
    @lastMoveUsedType      = nil
    @lastRegularMoveUsed   = nil
    @lastRegularMoveTarget = -1
    @lastRoundMoved        = -1
    @lastMoveFailed        = false
    @lastRoundMoveFailed   = false
    @movesUsed             = []
    @turnCount             = 0
    @effects[PBEffects::Attract]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer attracted to self
      b.effects[PBEffects::Attract] = -1 if b.effects[PBEffects::Attract]==@index
    end
    @effects[PBEffects::BanefulBunker]       = false
    @effects[PBEffects::BeakBlast]           = false
    @effects[PBEffects::Bide]                = 0
    @effects[PBEffects::BideDamage]          = 0
    @effects[PBEffects::BideTarget]          = -1
    @effects[PBEffects::BurnUp]              = false
    @effects[PBEffects::Charge]              = 0
    @effects[PBEffects::ChoiceBand]          = nil
    @effects[PBEffects::Counter]             = -1
    @effects[PBEffects::CounterTarget]       = -1
    @effects[PBEffects::Dancer]              = false
    @effects[PBEffects::DefenseCurl]         = false
    @effects[PBEffects::DestinyBond]         = false
    @effects[PBEffects::DestinyBondPrevious] = false
    @effects[PBEffects::DestinyBondTarget]   = -1
    @effects[PBEffects::Disable]             = 0
    @effects[PBEffects::DisableMove]         = nil
    @effects[PBEffects::Electrify]           = false
    @effects[PBEffects::Encore]              = 0
    @effects[PBEffects::EncoreMove]          = nil
    @effects[PBEffects::Endure]              = false
    @effects[PBEffects::FirstPledge]         = 0
    @effects[PBEffects::FlashFire]           = false
    @effects[PBEffects::Flinch]              = false
    @effects[PBEffects::FocusPunch]          = false
    @effects[PBEffects::FollowMe]            = 0
    @effects[PBEffects::Foresight]           = false
    @effects[PBEffects::FuryCutter]          = 0
    @effects[PBEffects::GemConsumed]         = nil
    @effects[PBEffects::Grudge]              = false
    @effects[PBEffects::HelpingHand]         = false
    @effects[PBEffects::HyperBeam]           = 0
    @effects[PBEffects::Illusion]            = nil
    if hasActiveAbility?(:ILLUSION)
      idxLastParty = @battle.pbLastInTeam(@index)
      if idxLastParty >= 0 && idxLastParty != @pokemonIndex
        @effects[PBEffects::Illusion]        = @battle.pbParty(@index)[idxLastParty]
      end
    end
    @effects[PBEffects::Imprison]            = false
    @effects[PBEffects::Instruct]            = false
    @effects[PBEffects::Instructed]          = false
    @effects[PBEffects::KingsShield]         = false
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self
      next if !b.effects[PBEffects::LockOn]
      next if b.effects[PBEffects::LockOnPos] != @index
      b.effects[PBEffects::LockOn]    = 0
      b.effects[PBEffects::LockOnPos] = -1
    end
    @effects[PBEffects::Octolock]            = -1
    @battle.eachBattler do |b|   # Other battlers no longer locked by self
      b.effects[PBEffects::Octolock] = -1 if b.effects[PBEffects::Octolock] == @index
    end
    @effects[PBEffects::JawLock]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer blocked by self
      b.effects[PBEffects::JawLock] = -1 if b.effects[PBEffects::JawLock] == @index
    end
    @effects[PBEffects::MagicBounce]         = false
    @effects[PBEffects::MagicCoat]           = false
    @effects[PBEffects::MeanLook]            = -1
    @battle.eachBattler do |b|   # Other battlers no longer blocked by self
      b.effects[PBEffects::MeanLook] = -1 if b.effects[PBEffects::MeanLook]==@index
    end
    @effects[PBEffects::MeFirst]             = false
    @effects[PBEffects::Metronome]           = 0
    @effects[PBEffects::MicleBerry]          = false
    @effects[PBEffects::Minimize]            = false
    @effects[PBEffects::MiracleEye]          = false
    @effects[PBEffects::MirrorCoat]          = -1
    @effects[PBEffects::MirrorCoatTarget]    = -1
    @effects[PBEffects::MoveNext]            = false
    @effects[PBEffects::MudSport]            = false
    @effects[PBEffects::Nightmare]           = false
    @effects[PBEffects::Outrage]             = 0
    @effects[PBEffects::ParentalBond]        = 0
    @effects[PBEffects::PickupItem]          = nil
    @effects[PBEffects::PickupUse]           = 0
    @effects[PBEffects::Pinch]               = false
    @effects[PBEffects::Powder]              = false
    @effects[PBEffects::Prankster]           = false
    @effects[PBEffects::PriorityAbility]     = false
    @effects[PBEffects::PriorityItem]        = false
    @effects[PBEffects::Protect]             = false
    @effects[PBEffects::ProtectRate]         = 1
    @effects[PBEffects::Pursuit]             = false
    @effects[PBEffects::Quash]               = 0
    @effects[PBEffects::Rage]                = false
    @effects[PBEffects::RagePowder]          = false
    @effects[PBEffects::Rollout]             = 0
    @effects[PBEffects::Roost]               = false
    @effects[PBEffects::SkyDrop]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer Sky Dropped by self
      b.effects[PBEffects::SkyDrop] = -1 if b.effects[PBEffects::SkyDrop]==@index
    end
    @effects[PBEffects::SlowStart]           = 0
    @effects[PBEffects::SmackDown]           = false
    @effects[PBEffects::Snatch]              = 0
    @effects[PBEffects::SpikyShield]         = false
    @effects[PBEffects::Spotlight]           = 0
    @effects[PBEffects::Stockpile]           = 0
    @effects[PBEffects::StockpileDef]        = 0
    @effects[PBEffects::StockpileSpDef]      = 0
    @effects[PBEffects::Taunt]               = 0
    @effects[PBEffects::ThroatChop]          = 0
    @effects[PBEffects::Torment]             = false
    @effects[PBEffects::Toxic]               = 0
    @effects[PBEffects::Transform]           = false
    @effects[PBEffects::TransformSpecies]    = 0
    @effects[PBEffects::Trapping]            = 0
    @effects[PBEffects::TrappingMove]        = nil
    @effects[PBEffects::TrappingUser]        = -1
    @battle.eachBattler do |b|   # Other battlers no longer trapped by self
      next if b.effects[PBEffects::TrappingUser]!=@index
      b.effects[PBEffects::Trapping]     = 0
      b.effects[PBEffects::TrappingUser] = -1
    end
    @effects[PBEffects::Truant]              = false
    @effects[PBEffects::TwoTurnAttack]       = nil
    @effects[PBEffects::Type3]               = nil
    @effects[PBEffects::Unburden]            = false
    @effects[PBEffects::Uproar]              = 0
    @effects[PBEffects::WaterSport]          = false
    @effects[PBEffects::WeightChange]        = 0
    @effects[PBEffects::Yawn]                = 0
    @effects[PBEffects::GorillaTactics]      = nil
    @effects[PBEffects::BallFetch]           = nil
    @effects[PBEffects::Obstruct]            = false
    @effects[PBEffects::TarShot]             = false
  end

  #=============================================================================
  # Refreshing a battler's properties
  #=============================================================================
  def pbUpdate(fullChange=false)
    return if !@pokemon
    @pokemon.calc_stats
    @level          = @pokemon.level
    @hp             = @pokemon.hp
    @totalhp        = @pokemon.totalhp
    if !@effects[PBEffects::Transform]
      @attack       = @pokemon.attack
      @defense      = @pokemon.defense
      @spatk        = @pokemon.spatk
      @spdef        = @pokemon.spdef
      @speed        = @pokemon.speed
      if fullChange
        @type1      = @pokemon.type1
        @type2      = @pokemon.type2
        @ability_id = @pokemon.ability_id
      end
    end
  end

  # Used to erase the battler of a Pokémon that has been caught.
  def pbReset
    @pokemon      = nil
    @pokemonIndex = -1
    @hp           = 0
    pbInitEffects(false)
    @participants = []
    # Reset status
    @status       = :NONE
    @statusCount  = 0
    # Reset choice
    @battle.pbClearChoice(@index)
  end

  # Update which Pokémon will gain Exp if this battler is defeated.
  def pbUpdateParticipants
    return if fainted? || !@battle.opposes?(@index)
    eachOpposing do |b|
      @participants.push(b.pokemonIndex) if !@participants.include?(b.pokemonIndex)
    end
  end
end
