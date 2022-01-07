#-------------------------------------------------------------------------------
# These are used to define what the Follower will say when spoken to under
# specific conditions like Status or Weather or Map names
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Amie Compatibility
#-------------------------------------------------------------------------------
if defined?(PkmnAR)
  Events.OnTalkToFollower += proc { |_pkmn, _random_val|
    cmd = pbMessage(_INTL("What would you like to do?"), [
      _INTL("Play"),
      _INTL("Talk"),
      _INTL("Cancel")
    ])
    PkmnAR.show if cmd == 0
    next true if [0, 2].include?(cmd)
  }
end
#-------------------------------------------------------------------------------
# Special Dialogue when statused
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  case pkmn.status
  when :POISON
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_POISON)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} is shivering with the effects of being poisoned.", pkmn.name))
  when :BURN
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1}'s burn looks painful.", pkmn.name))
  when :FROZEN
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} seems very cold. It's frozen solid!", pkmn.name))
  when :SLEEP
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} seems really tired.", pkmn.name))
  when :PARALYSIS
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    pbMessage(_INTL("{1} is standing still and twitching.", pkmn.name))
  end
  next true if pkmn.status != :NONE
}
#-------------------------------------------------------------------------------
# Special hold item on a map which includes battle in the name
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |_pkmn, _random_val|
  if $game_map.name.include?("Battle")
    # This array can be edited and extended to your hearts content.
    items = [:POKEBALL, :POKEBALL, :POKEBALL, :GREATBALL, :GREATBALL, :ULTRABALL]
    # Choose a random item from the items array, give the player 2 of the item
    # with the message "{1} is holding a round object..."
    next true if FollowingPkmn.item(items.sample, 2, _INTL("{1} is holding a round object..."))
  end
}
#-------------------------------------------------------------------------------
# Specific message if the Pokemon is a bug type and the map's name is route 3
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name == "Route 3" && pkmn.hasType?(:BUG)
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} seems highly interested in the trees."),
      _INTL("{1} seems to enjoy the buzzing of the bug Pokémon."),
      _INTL("{1} is jumping around restlessly in the forest.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name is Pokemon Lab
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name == "Pokémon Lab"
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} is touching some kind of switch."),
      _INTL("{1} has a cord in its mouth!"),
      _INTL("{1} seems to want to touch the machinery.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has the players name in it like the
# Player's House
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name.include?($Trainer.name)
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} is sniffing around the room."),
      _INTL("{1} noticed {2}'s mom is nearby."),
      _INTL("{1} seems to want to settle down at home.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Pokecenter or Pokemon Center
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name.include?("Poké Center") ||
     $game_map.name.include?("Pokémon Center")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} looks happy to see the nurse."),
      _INTL("{1} looks a little better just being in the Pokémon Center."),
      _INTL("{1} seems fascinated by the healing machinery."),
      _INTL("{1} looks like it wants to take a nap."),
      _INTL("{1} chirped a greeting at the nurse."),
      _INTL("{1} is watching {2} with a playful gaze."),
      _INTL("{1} seems to be completely at ease."),
      _INTL("{1} is making itself comfortable."),
      _INTL("There's a content expression on {1}'s face.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Forest
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name.include?("Forest")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} seems highly interested in the trees."),
      _INTL("{1} seems to enjoy the buzzing of the bug Pokémon."),
      _INTL("{1} is jumping around restlessly in the forest."),
      _INTL("{1} is wandering around and listening to the different sounds."),
      _INTL("{1} is munching at the grass."),
      _INTL("{1} is wandering around and enjoying the forest scenery."),
      _INTL("{1} is playing around, plucking bits of grass."),
      _INTL("{1} is staring at the light coming through the trees."),
      _INTL("{1} is playing around with a leaf!"),
      _INTL("{1} seems to be listening to the sound of rustling leaves."),
      _INTL("{1} is standing perfectly still and might be imitating a tree..."),
      _INTL("{1} got tangled in the branches and almost fell down!"),
      _INTL("{1} was surprised when it got hit by a branch!")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Gym in it
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name.include?("Gym")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} looks eager to battle!"),
      _INTL("{1} is looking at {2} with a determined gleam in its' eye."),
      _INTL("{1} is trying to intimidate the other trainers."),
      _INTL("{1} trusts {2} to come up with a winning strategy."),
      _INTL("{1} is keeping an eye on the gym leader."),
      _INTL("{1} is ready to pick a fight with someone."),
      _INTL("{1} looks like it might be preparing for a big showdown!"),
      _INTL("{1} wants to show off how strong it is!"),
      _INTL("{1} is...doing warm-up exercises?"),
      _INTL("{1} is growling quietly in contemplation...")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Beach in it
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if $game_map.name.include?("Beach")
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} seems to be enjoying the scenery."),
      _INTL("{1} seems to enjoy the sound of the waves moving the sand."),
      _INTL("{1} looks like it wants to swim!"),
      _INTL("{1} can barely look away from the ocean."),
      _INTL("{1} is staring longingly at the water."),
      _INTL("{1} keeps trying to shove {2} towards the water."),
      _INTL("{1} is excited to be looking at the sea!"),
      _INTL("{1} is happily watching the waves!"),
      _INTL("{1} is playing on the sand!"),
      _INTL("{1} is staring at {2}'s footprints in the sand."),
      _INTL("{1} is rolling around in the sand.")
    ]
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Rainy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if [:Rain, :HeavyRain].include?($game_screen.weather_type)
    if pkmn.hasType?(:FIRE) || pkmn.hasType?(:GROUND) || pkmn.hasType?(:ROCK)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems very upset the weather."),
        _INTL("{1} is shivering..."),
        _INTL("{1} doesn't seem to like being all wet..."),
        _INTL("{1} keeps trying to shake itself dry..."),
        _INTL("{1} moved closer to {2} for comfort."),
        _INTL("{1} is looking up at the sky and scowling."),
        _INTL("{1} seems to be having difficulty moving its body.")
      ]
    elsif pkmn.hasType?(:WATER) || pkmn.hasType?(:GRASS)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems to be enjoying the weather."),
        _INTL("{1} seems to be happy about the rain!"),
        _INTL("{1} seems to be very surprised that it's raining!"),
        _INTL("{1} beamed happily at {2}!"),
        _INTL("{1} is gazing up at the rainclouds."),
        _INTL("Raindrops keep falling on {1}."),
        _INTL("{1} is looking up with its mouth gaping open.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is staring up at the sky."),
        _INTL("{1} looks a bit surprised to see rain."),
        _INTL("{1} keeps trying to shake itself dry."),
        _INTL("The rain doesn't seem to bother {1} much."),
        _INTL("{1} is playing in a puddle!"),
        _INTL("{1} is slipping in the water and almost fell over!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Storm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if :Storm == $game_screen.weather_type
    if pkmn.hasType?(:ELECTRIC)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is staring up at the sky."),
        _INTL("The storm seems to be making {1} excited."),
        _INTL("{1} looked up at the sky and shouted loudly!"),
        _INTL("The storm only seems to be energizing {1}!"),
        _INTL("{1} is happily zapping and jumping in circles!"),
        _INTL("The lightning doesn't bother {1} at all.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is staring up at the sky."),
        _INTL("The storm seems to be making {1} a bit nervous."),
        _INTL("The lightning startled {1}!"),
        _INTL("The rain doesn't seem to bother {1} much."),
        _INTL("The weather seems to be putting {1} on edge."),
        _INTL("{1} was startled by the lightning and snuggled up to {2}!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Snowy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if :Snow == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is watching the snow fall."),
        _INTL("{1} is thrilled by the snow!"),
        _INTL("{1} is staring up at the sky with a smile."),
        _INTL("The snow seems to have put {1} in a good mood."),
        _INTL("{1} is cheerful because of the cold!")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is watching the snow fall."),
        _INTL("{1} is nipping at the falling snowflakes."),
        _INTL("{1} wants to catch a snowflake in its' mouth."),
        _INTL("{1} is fascinated by the snow."),
        _INTL("{1}'s teeth are chattering!"),
        _INTL("{1} made its body slightly smaller because of the cold...")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Blizzard. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if :Blizzard == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is watching the hail fall."),
        _INTL("{1} isn't bothered at all by the hail."),
        _INTL("{1} is staring up at the sky with a smile."),
        _INTL("The hail seems to have put {1} in a good mood."),
        _INTL("{1} is gnawing on a piece of hailstone.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is getting pelted by hail!"),
        _INTL("{1} wants to avoid the hail."),
        _INTL("The hail is hitting {1} painfully."),
        _INTL("{1} looks unhappy."),
        _INTL("{1} is shaking like a leaf!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Sandstorm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if :Sandstorm == $game_screen.weather_type
    if pkmn.hasType?(:ROCK) || pkmn.hasType?(:GROUND)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is coated in sand."),
        _INTL("The weather doesn't seem to bother {1} at all!"),
        _INTL("The sand can't slow {1} down!"),
        _INTL("{1} is enjoying the weather.")
      ]
    elsif pkmn.hasType?(:STEEL)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is coated in sand, but doesn't seem to mind."),
        _INTL("{1} seems unbothered by the sandstorm."),
        _INTL("The sand doesn't slow {1} down."),
        _INTL("{1} doesn't seem to mind the weather.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is covered in sand..."),
        _INTL("{1} spat out a mouthful of sand!"),
        _INTL("{1} is squinting through the sandstorm."),
        _INTL("The sand seems to be bothering {1}.")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Sunny. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, _random_val|
  if :Sun == $game_screen.weather_type
    if pkmn.hasType?(:GRASS)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems pleased to be out in the sunshine."),
        _INTL("{1} is soaking up the sunshine."),
        _INTL("The bright sunlight doesn't seem to bother {1} at all."),
        _INTL("{1} sent a ring-shaped cloud of spores into the air!"),
        _INTL("{1} is stretched out its body and is relaxing in the sunshine."),
        _INTL("{1} is giving off a floral scent.")
      ]
    elsif pkmn.hasType?(:FIRE)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} seems to be happy about the great weather!"),
        _INTL("The bright sunlight doesn't seem to bother {1} at all."),
        _INTL("{1} looks thrilled by the sunshine!"),
        _INTL("{1} blew out a fireball."),
        _INTL("{1} is breathing out fire!"),
        _INTL("{1} is hot and cheerful!")
      ]
    elsif pkmn.hasType?(:DARK)
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is glaring up at the sky."),
        _INTL("{1} seems personally offended by the sunshine."),
        _INTL("The bright sunshine seems to bothering {1}."),
        _INTL("{1} looks upset for some reason."),
        _INTL("{1} is trying to stay in {2}'s shadow."),
        _INTL("{1} keeps looking for shelter from the sunlight.")
      ]
    else
      FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
      messages = [
        _INTL("{1} is squinting in the bright sunshine."),
        _INTL("{1} is starting to sweat."),
        _INTL("{1} seems a little uncomfortable in this weather."),
        _INTL("{1} looks a little overheated."),
        _INTL("{1} seems very hot..."),
        _INTL("{1} shielded its vision against the sparkling light!")
      ]
    end
    pbMessage(_INTL(messages.sample, pkmn.name, $Trainer.name))
    next true
  end
}
