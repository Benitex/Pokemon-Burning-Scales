#-------------------------------------------------------------------------------
# These are used to define what the Follower will say when spoken to under
# specific conditions like Status or Weather or Map names
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Amie Compatibility
#-------------------------------------------------------------------------------
if defined?(pokemonAmieRefresh)
  Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
    cmd = pbMessage("What would you like to do?",["Play","Talk","Cancel"])
    pokemonAmieRefresh if cmd == 0
    next true if [0,2].include?(cmd)
  }
end
#-------------------------------------------------------------------------------
# Special Dialogue when statused
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  case pkmn.status
  when :POISON
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Poison,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    pbMessage(_INTL("{1} is shivering with the effects of being poisoned.",pkmn.name))
  when :BURN
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    pbMessage(_INTL("{1}'s burn looks painful.",pkmn.name))
  when :FROZEN
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    pbMessage(_INTL("{1} seems very cold. It's frozen solid!",pkmn.name))
  when :SLEEP
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal, x, y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    pbMessage(_INTL("{1} seems really tired.",pkmn.name))
  when :PARALYSIS
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    pbMessage(_INTL("{1} is standing still and twitching.",pkmn.name))
  end
  next true if pkmn.status != :NONE
}
#-------------------------------------------------------------------------------
# Special hold item on a map which includes battle in the name
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name.include?("Battle")
    # This array can be edited and extended to your hearts content.
    items = [:POKEBALL,:POKEBALL,:POKEBALL,:GREATBALL,:GREATBALL,:ULTRABALL]
    # Choose a random item from the items array, give the player 2 of the item
    # with the message "{1} is holding a round object..."
    next true if pbPokemonFound(items.sample,2,"{1} is holding a round object...")
  end
}
#-------------------------------------------------------------------------------
# Specific message if the Pokemon is a bug type and the map's name is route 3
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name == "Route 3" && pkmn.hasType?(:BUG)
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_sing,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} seems highly interested in the trees.",
      "{1} seems to enjoy the buzzing of the bug Pokémon.",
      "{1} is jumping around restlessly in the forest."
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name is Pokemon Lab
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name == "Pokémon Lab"
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} is touching some kind of switch.",
      "{1} has a cord in its mouth!",
      "{1} seems to want to touch the machinery."
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has the players name in it like the
# Player's House
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name.include?($Trainer.name)
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} is sniffing around the room.",
      "{1} noticed {2}'s mom is nearby.",
      "{1} seems to want to settle down at home."
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Pokecenter or Pokemon Center
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name.include?("Poké Center") ||
     $game_map.name.include?("Pokémon Center")
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} looks happy to see the nurse.",
      "{1} looks a little better just being in the Pokémon Center.",
      "{1} seems fascinated by the healing machinery.",
      "{1} looks like it wants to take a nap.",
      "{1} chirped a greeting at the nurse.",
      "{1} is watching {2} with a playful gaze.",
      "{1} seems to be completely at ease.",
      "{1} is making itself comfortable.",
      "There's a content expression on {1}'s face."
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Forest
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name.include?("Forest")
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_sing,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} seems highly interested in the trees.",
      "{1} seems to enjoy the buzzing of the bug Pokémon.",
      "{1} is jumping around restlessly in the forest.",
      "{1} is wandering around and listening to the different sounds.",
      "{1} is munching at the grass.",
      "{1} is wandering around and enjoying the forest scenery.",
      "{1} is playing around, plucking bits of grass.",
      "{1} is staring at the light coming through the trees.",
      "{1} is playing around with a leaf!",
      "{1} seems to be listening to the sound of rustling leaves.",
      "{1} is standing perfectly still and might be imitating a tree...",
      "{1} got tangled in the branches and almost fell down!",
      "{1} was surprised when it got hit by a branch!"
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Gym in it
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name.include?("Gym")
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} looks eager to battle!",
      "{1} is looking at {2} with a determined gleam in its' eye.",
      "{1} is trying to intimidate the other trainers.",
      "{1} trusts {2} to come up with a winning strategy.",
      "{1} is keeping an eye on the gym leader.",
      "{1} is ready to pick a fight with someone.",
      "{1} looks like it might be preparing for a big showdown!",
      "{1} wants to show off how strong it is!",
      "{1} is...doing warm-up exercises?",
      "{1} is growling quietly in contemplation..."
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message if the map name has Beach in it
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if $game_map.name.include?("Beach")
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} seems to be enjoying the scenery.",
      "{1} seems to enjoy the sound of the waves moving the sand.",
      "{1} looks like it wants to swim!",
      "{1} can barely look away from the ocean.",
      "{1} is staring longingly at the water.",
      "{1} keeps trying to shove {2} towards the water.",
      "{1} is excited to be looking at the sea!",
      "{1} is happily watching the waves!",
      "{1} is playing on the sand!",
      "{1} is staring at {2}'s footprints in the sand.",
      "{1} is rolling around in the sand."
    ]
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Rainy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if [:Rain,:HeavyRain].include?($game_screen.weather_type)
    if pkmn.hasType?(:FIRE) || pkmn.hasType?(:GROUND) || pkmn.hasType?(:ROCK)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} seems very upset the weather.",
        "{1} is shivering...",
        "{1} doesn’t seem to like being all wet...",
        "{1} keeps trying to shake itself dry...",
        "{1} moved closer to {2} for comfort.",
        "{1} is looking up at the sky and scowling.",
        "{1} seems to be having difficulty moving its body."
      ]
    elsif pkmn.hasType?(:WATER) || pkmn.hasType?(:GRASS)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} seems to be enjoying the weather.",
        "{1} seems to be happy about the rain!",
        "{1} seems to be very surprised that it’s raining!",
        "{1} beamed happily at {2}!",
        "{1} is gazing up at the rainclouds.",
        "Raindrops keep falling on {1}.",
        "{1} is looking up with its mouth gaping open."
      ]
    else
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is staring up at the sky.",
        "{1} looks a bit surprised to see rain.",
        "{1} keeps trying to shake itself dry.",
        "The rain doesn't seem to bother {1} much.",
        "{1} is playing in a puddle!",
        "{1} is slipping in the water and almost fell over!"
      ]
    end
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Storm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if :Storm == $game_screen.weather_type
    if pkmn.hasType?(:ELECTRIC)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is staring up at the sky.",
        "The storm seems to be making {1} excited.",
        "{1} looked up at the sky and shouted loudly!",
        "The storm only seems to be energizing {1}!",
        "{1} is happily zapping and jumping in circles!",
        "The lightning doesn't bother {1} at all."
      ]
    else
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is staring up at the sky.",
        "The storm seems to be making {1} a bit nervous.",
        "The lightning startled {1}!",
        "The rain doesn't seem to bother {1} much.",
        "The weather seems to be putting {1} on edge.",
        "{1} was startled by the lightning and snuggled up to {2}!"
      ]
    end
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Snowy. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if :Snow == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is watching the snow fall.",
        "{1} is thrilled by the snow!",
        "{1} is staring up at the sky with a smile.",
        "The snow seems to have put {1} in a good mood.",
        "{1} is cheerful because of the cold!"
      ]
    else
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is watching the snow fall.",
        "{1} is nipping at the falling snowflakes.",
        "{1} wants to catch a snowflake in its' mouth.",
        "{1} is fascinated by the snow.",
        "{1}’s teeth are chattering!",
        "{1} made its body slightly smaller because of the cold..."
      ]
    end
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Blizzard. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if :Blizzard == $game_screen.weather_type
    if pkmn.hasType?(:ICE)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is watching the hail fall.",
        "{1} isn't bothered at all by the hail.",
        "{1} is staring up at the sky with a smile.",
        "The hail seems to have put {1} in a good mood.",
        "{1} is gnawing on a piece of hailstone."
      ]
    else
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is getting pelted by hail!",
        "{1} wants to avoid the hail.",
        "The hail is hitting {1} painfully.",
        "{1} looks unhappy.",
        "{1} is shaking like a leaf!"
      ]
    end
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Sandstorm. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if :Sandstorm == $game_screen.weather_type
    if pkmn.hasType?(:ROCK) || pkmn.hasType?(:GROUND)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is coated in sand.",
        "The weather doesn't seem to bother {1} at all!",
        "The sand can't slow {1} down!",
        "{1} is enjoying the weather."
      ]
    elsif pkmn.hasType?(:STEEL)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is coated in sand, but doesn't seem to mind.",
        "{1} seems unbothered by the sandstorm.",
        "The sand doesn't slow {1} down.",
        "{1} doesn't seem to mind the weather."
      ]
    else
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is covered in sand...",
        "{1} spat out a mouthful of sand!",
        "{1} is squinting through the sandstorm.",
        "The sand seems to be bothering {1}."
      ]
    end
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# Specific message when the weather is Sunny. Pokemon of different types
# have different reactions to the weather.
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if :Sun == $game_screen.weather_type
    if pkmn.hasType?(:GRASS)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} seems pleased to be out in the sunshine.",
        "{1} is soaking up the sunshine.",
        "The bright sunlight doesn't seem to bother {1} at all.",
        "{1} sent a ring-shaped cloud of spores into the air!",
        "{1} is stretched out its body and is relaxing in the sunshine.",
        "{1} is giving off a floral scent."
      ]
    elsif pkmn.hasType?(:FIRE)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} seems to be happy about the great weather!",
        "The bright sunlight doesn't seem to bother {1} at all.",
        "{1} looks thrilled by the sunshine!",
        "{1} blew out a fireball.",
        "{1} is breathing out fire!",
        "{1} is hot and cheerful!"
      ]
    elsif pkmn.hasType?(:DARK)
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is glaring up at the sky.",
        "{1} seems personally offended by the sunshine.",
        "The bright sunshine seems to bothering {1}.",
        "{1} looks upset for some reason.",
        "{1} is trying to stay in {2}'s shadow.",
        "{1} keeps looking for shelter from the sunlight.",
      ]
    else
      $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
      pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
      messages = [
        "{1} is squinting in the bright sunshine.",
        "{1} is starting to sweat.",
        "{1} seems a little uncomfortable in this weather.",
        "{1} looks a little overheated.",
        "{1} seems very hot...",
        "{1} shielded its vision against the sparkling light!",
       ]
    end
    pbMessage(_INTL(messages.sample,pkmn.name,$Trainer.name))
    next true
  end
}
