begin
  module PBEffects
    #===========================================================================
    # These effects apply to a battler
    #===========================================================================
    AquaRing            = 0
    Attract             = 1
    BanefulBunker       = 2
    BeakBlast           = 3
    Bide                = 4
    BideDamage          = 5
    BideTarget          = 6
    BurnUp              = 7
    Charge              = 8
    ChoiceBand          = 9
    Confusion           = 10
    Counter             = 11
    CounterTarget       = 12
    Curse               = 13
    Dancer              = 14
    DefenseCurl         = 15
    DestinyBond         = 16
    DestinyBondPrevious = 17
    DestinyBondTarget   = 18
    Disable             = 19
    DisableMove         = 20
    Electrify           = 21
    Embargo             = 22
    Encore              = 23
    EncoreMove          = 24
    Endure              = 25
    FirstPledge         = 26
    FlashFire           = 27
    Flinch              = 28
    FocusEnergy         = 29
    FocusPunch          = 30
    FollowMe            = 31
    Foresight           = 32
    FuryCutter          = 33
    GastroAcid          = 34
    GemConsumed         = 35
    Grudge              = 36
    HealBlock           = 37
    HelpingHand         = 38
    HyperBeam           = 39
    Illusion            = 40
    Imprison            = 41
    Ingrain             = 42
    Instruct            = 43
    Instructed          = 44
    KingsShield         = 45
    LaserFocus          = 46
    LeechSeed           = 47
    LockOn              = 48
    LockOnPos           = 49
    MagicBounce         = 50
    MagicCoat           = 51
    MagnetRise          = 52
    MeanLook            = 53
    MeFirst             = 54
    Metronome           = 55
    MicleBerry          = 56
    Minimize            = 57
    MiracleEye          = 58
    MirrorCoat          = 59
    MirrorCoatTarget    = 60
    MoveNext            = 61
    MudSport            = 62
    Nightmare           = 63
    Outrage             = 64
    ParentalBond        = 65
    PerishSong          = 66
    PerishSongUser      = 67
    PickupItem          = 68
    PickupUse           = 69
    Pinch               = 70   # Battle Palace only
    Powder              = 71
    PowerTrick          = 72
    Prankster           = 73
    PriorityAbility     = 74
    PriorityItem        = 75
    Protect             = 76
    ProtectRate         = 77
    Pursuit             = 78
    Quash               = 79
    Rage                = 80
    RagePowder          = 81   # Used along with FollowMe
    Rollout             = 82
    Roost               = 83
    ShellTrap           = 84
    SkyDrop             = 85
    SlowStart           = 86
    SmackDown           = 87
    Snatch              = 88
    SpikyShield         = 89
    Spotlight           = 90
    Stockpile           = 91
    StockpileDef        = 92
    StockpileSpDef      = 93
    Substitute          = 94
    Taunt               = 95
    Telekinesis         = 96
    ThroatChop          = 97
    Torment             = 98
    Toxic               = 99
    Transform           = 100
    TransformSpecies    = 101
    Trapping            = 102   # Trapping move
    TrappingMove        = 103
    TrappingUser        = 104
    Truant              = 105
    TwoTurnAttack       = 106
    Type3               = 107
    Unburden            = 108
    Uproar              = 109
    WaterSport          = 110
    WeightChange        = 111
    Yawn                = 112
    GorillaTactics      = 113
    BallFetch           = 114
    NoRetreat           = 115
    Obstruct            = 116
    JawLock             = 117
    Octolock            = 118
    TarShot             = 119

    #===========================================================================
    # These effects apply to a battler position
    #===========================================================================
    FutureSightCounter        = 0
    FutureSightMove           = 1
    FutureSightUserIndex      = 2
    FutureSightUserPartyIndex = 3
    HealingWish               = 4
    LunarDance                = 5
    Wish                      = 6
    WishAmount                = 7
    WishMaker                 = 8

    #===========================================================================
    # These effects apply to a side
    #===========================================================================
    AuroraVeil         = 0
    CraftyShield       = 1
    EchoedVoiceCounter = 2
    EchoedVoiceUsed    = 3
    LastRoundFainted   = 4
    LightScreen        = 5
    LuckyChant         = 6
    MatBlock           = 7
    Mist               = 8
    QuickGuard         = 9
    Rainbow            = 10
    Reflect            = 11
    Round              = 12
    Safeguard          = 13
    SeaOfFire          = 14
    Spikes             = 15
    StealthRock        = 16
    StickyWeb          = 17
    Swamp              = 18
    Tailwind           = 19
    ToxicSpikes        = 20
    WideGuard          = 21
	StickyWebUser      = 22


    #===========================================================================
    # These effects apply to the battle (i.e. both sides)
    #===========================================================================
    AmuletCoin      = 0
    FairyLock       = 1
    FusionBolt      = 2
    FusionFlare     = 3
    Gravity         = 4
    HappyHour       = 5
    IonDeluge       = 6
    MagicRoom       = 7
    MudSportField   = 8
    PayDay          = 9
    TrickRoom       = 10
    WaterSportField = 11
    WonderRoom      = 12
    NeutralizingGas = 13
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
