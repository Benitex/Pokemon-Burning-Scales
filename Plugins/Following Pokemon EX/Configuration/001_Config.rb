module FollowingPkmn
  # Common event that contains "FollowingPkmn.talk" in  a script command
  # Change this if you want a separate common event to play when talking to
  # Following Pokemon. Otherwise, set this to nil.
  FOLLOWER_COMMON_EVENT     = nil

  # Animation IDs from followers
  # Change this if you are not using the Animations.rxdata provided in the script.
  ANIMATION_COME_OUT        = 30
  ANIMATION_COME_IN         = 29

  ANIMATION_EMOTE_HEART     = 9
  ANIMATION_EMOTE_MUSIC     = 12
  ANIMATION_EMOTE_HAPPY     = 10
  ANIMATION_EMOTE_ELIPSES   = 13
  ANIMATION_EMOTE_ANGRY     = 15
  ANIMATION_EMOTE_POISON    = 17

  # The key the player needs to press to toggle followers. Set this to nil if
  # you want to disable this feature. (:JUMPUP is the A key by default)
  TOGGLE_FOLLOWER_KEY       = :JUMPUP

  # The key the player needs to press to quickly cycle through their party. Set
  # this to nil if you want to disable this feature
  CYCLE_PARTY_KEY           = nil

  # Status tones to be used, if this is true (Red, Green, Blue)
  APPLY_STATUS_TONES        = true
  TONE_BURN                 = [206, 73, 43]
  TONE_POISON               = [109, 55, 130]
  TONE_PARALYSIS            = [204, 152, 44]
  TONE_FROZEN               = [56, 160, 193]
  TONE_SLEEP                = [0, 0, 0]
  # For your custom status conditions, just add it as "TONE_(INTERNAL NAME)"
  # Example: TONE_BLEED, TONE_CONFUSE, TONE_INFATUATION

  # Time Taken for Follower to increase Friendship when first in party (in seconds)
  FRIENDSHIP_TIME_TAKEN     = 125

  # Time Taken for Follower to find an item when first in party (in seconds)
  ITEM_TIME_TAKEN           = 375

  # Whether the Follower always stays in its move cycle (like HGSS) or not.
  ALWAYS_ANIMATE            = true

  # Whether the Follower always faces the player, or not like in HGSS.
  ALWAYS_FACE_PLAYER        = false

  # Whether other events can walk through Follower or no
  IMPASSABLE_FOLLOWER       = true

  # Whether Following Pokemon slides into battle instead of being sent
  # in a Pokeball.
  SLIDE_INTO_BATTLE         = true

  # Show the Ball Opening and Closing animation when Nurse Joy takes your
  # Pokeballs at the Pokecenter.
  SHOW_POKECENTER_ANIMATION = false

  # List of Pokemon that will always appear behind the player when surfing
  # Doesn't include any flying or water types because those are handled already
  SURFING_FOLLOWERS = [
    # Gen 1
    :BEEDRILL, :VENOMOTH, :ABRA, :GEODUDE, :MAGNEMITE, :GASTLY, :HAUNTER,
    :KOFFING, :WEEZING, :PORYGON, :MEWTWO, :MEW,
    # Gen 2
    :MISDREAVUS, :UNOWN, :PORYGON2, :CELEBI,
    # Gen 3
    :DUSTOX, :SHEDINJA, :MEDITITE, :VOLBEAT, :ILLUMISE, :FLYGON, :LUNATONE,
    :SOLROCK, :BALTOY, :CLAYDOL, :CASTFORM, :SHUPPET, :DUSKULL, :CHIMECHO,
    :GLALIE, :BELDUM, :METANG, :LATIAS, :LATIOS, :JIRACHI,
    # Gen 4
    :MISMAGIUS, :BRONZOR, :BRONZONG, :SPIRITOMB, :CARNIVINE, :MAGNEZONE,
    :PORYGONZ, :PROBOPASS, :DUSKNOIR, :FROSLASS, :ROTOM, :UXIE, :MESPRIT,
    :AZELF, :GIRATINA, :CRESSELIA, :DARKRAI,
    # Gen 5
    :MUNNA, :MUSHARNA, :YAMASK, :COFAGRIGUS, :SOLOSIS, :DUOSION, :REUNICLUS,
    :VANILLITE, :VANILLISH, :VANILLUXE, :ELGYEM, :BEHEEYEM, :LAMPENT,
    :CHANDELURE, :CRYOGONAL, :HYDREIGON, :VOLCARONA, :RESHIRAM, :ZEKROM,
    # Gen 6
    :SPRITZEE, :DRAGALGE, :CARBINK, :KLEFKI, :PHANTUMP, :DIANCIE, :HOOPA,
    # Gen 7
    :VIKAVOLT, :CUTIEFLY, :RIBOMBEE, :COMFEY, :DHELMISE, :TAPUKOKO, :TAPULELE,
    :TAPUBULU, :COSMOG, :COSMOEM, :LUNALA, :NIHILEGO, :KARTANA, :NECROZMA,
    :MAGEARNA, :POIPOLE, :NAGANADEL,
    # Gen 8
    :ORBEETLE, :FLAPPLE, :SINISTEA, :POLTEAGEIST, :FROSMOTH, :DREEPY, :DRAKLOAK,
    :DRAGAPULT, :ETERNATUS, :REGIELEKI, :REGIDRAGO, :CALYREX
  ]

  # List of Pokemon that will not appear behind the player when surfing,
  # regardless of whether they are flying type, have levitate or are mentioned
  # in the SURFING_FOLLOWERS.
  SURFING_FOLLOWERS_EXCEPTIONS = [
    # Gen I
    :CHARIZARD, :PIDGEY, :SPEAROW, :FARFETCHD, :DODUO, :DODRIO, :SCYTHER,
    :ZAPDOS_1,
    # Gen II
    :NATU, :XATU, :MURKROW, :DELIBIRD,
    # Gen III
    :TAILLOW, :VIBRAVA, :TROPIUS,
    # Gen IV
    :STARLY, :HONCHKROW, :CHINGLING, :CHATOT, :ROTOM_1, :ROTOM_2, :ROTOM_3,
    :ROTOM_5, :SHAYMIN_1, :ARCEUS_2,
    # Gen V
    :ARCHEN, :DUCKLETT, :EMOLGA, :EELEKTRIK, :EELEKTROSS, :RUFFLET, :VULLABY,
    :LANDORUS_1,
    # Gen VI
    :FLETCHLING, :HAWLUCHA,
    # Gen VII
    :ROWLET, :DARTRIX, :PIKIPEK, :ORICORIO, :SILVALLY_2,
    # Gen VIII
    :ROOKIDEE, :CALYREX_1, :CALYREX_2
  ]
end

#===============================================================================
# DO NOT TOUCH THIS UNDER ANY CIRCUMSTANCES
#===============================================================================
class FollowerEvent < Event
  def trigger(*arg)
    for callback in @callbacks
      ret = callback.call(*arg)
      return ret if ret == true || ret == false
    end
    return -1
  end
end

module Events
  @@OnTalkToFollower = FollowerEvent.new
  def self.OnTalkToFollower;     @@OnTalkToFollower;     end
  def self.OnTalkToFollower=(v); @@OnTalkToFollower = v; end

  @@FollowerRefresh = FollowerEvent.new
  def self.FollowerRefresh;     @@FollowerRefresh;     end
  def self.FollowerRefresh=(v); @@FollowerRefresh = v; end
end
