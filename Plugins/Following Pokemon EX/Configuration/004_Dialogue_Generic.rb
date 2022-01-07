#-------------------------------------------------------------------------------
# These are used to define what the Follower will say when spoken to in general
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Generic Item Dialogue
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |_pkmn, _random_val|
  items = [
    :POTION,        :SUPERPOTION,  :FULLRESTORE,    :REVIVE,        :PPUP,
    :PPMAX,         :RARECANDY,    :REPEL,          :MAXREPEL,      :ESCAPEROPE,
    :HONEY,         :TINYMUSHROOM, :PEARL,          :NUGGET,        :GREATBALL,
    :ULTRABALL,     :THUNDERSTONE, :MOONSTONE,      :SUNSTONE,      :DUSKSTONE,
    :REDAPRICORN,   :BLUEAPRICORN, :YELLOWAPRICORN, :GREENAPRICORN, :PINKAPRICORN,
    :BLACKAPRICORN, :WHITEAPRICORN
  ]
  # If no message or quantity is specified the default message is used and the quantity of item is 1
  next true if FollowingPkmn.item(items.sample)
}
#-------------------------------------------------------------------------------
# All dialogues with the Music Note animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, random_val|
  if random_val == 0
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_MUSIC)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} seems to want to play with {2}."),
      _INTL("{1} is singing and humming."),
      _INTL("{1} is looking up at {2} with a happy expression."),
      _INTL("{1} swayed and danced around as it pleased."),
      _INTL("{1} is jumping around in a carefree way!"),
      _INTL("{1} is showing off its agility!"),
      _INTL("{1} is moving around happily!"),
      _INTL("Whoa! {1} suddenly started dancing in happiness!"),
      _INTL("{1} is steadily keeping up with {2}!"),
      _INTL("{1} is happy skipping about."),
      _INTL("{1} is playfully nibbling at the ground."),
      _INTL("{1} is playfully nipping at {2}'s feet!"),
      _INTL("{1} is following {2} very closely!"),
      _INTL("{1} turns around and looks at {2}."),
      _INTL("{1} is working hard to show off its mighty power!"),
      _INTL("{1} looks like it wants to run around!"),
      _INTL("{1} is wandering around enjoying the scenery."),
      _INTL("{1} seems to be enjoying this a little bit!"),
      _INTL("{1} is cheerful!"),
      _INTL("{1} seems to be singing something?"),
      _INTL("{1} is dancing around happily!"),
      _INTL("{1} is having fun dancing a lively jig!"),
      _INTL("{1} is so happy, it started singing!"),
      _INTL("{1} looked up and howled!"),
      _INTL("{1} seems to be feeling optimistic."),
      _INTL("It looks like {1} feels like dancing!"),
      _INTL("{1} suddenly started to sing! It seems to be feeling great."),
      _INTL("It looks like {1} wants to dance with {2}!")
    ]
    value = rand(messages.length)
    case value
    # Special move route to go along with some of the dialogue
    when 3, 9
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 65])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0
      ])
    when 4, 5
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 40])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    when 6, 17
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 40])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp
      ])
    when 7, 28
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 60])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    when 21, 22
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 50])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Angry animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, random_val|
  if random_val == 1
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ANGRY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} let out a roar!"),
      _INTL("{1} is making a face like it's angry!"),
      _INTL("{1} seems to be angry for some reason."),
      _INTL("{1} chewed on {2}'s feet."),
      _INTL("{1} turned to face the other way, showing a defiant expression."),
      _INTL("{1} is trying to intimidate {2}'s foes!"),
      _INTL("{1} wants to pick a fight!"),
      _INTL("{1} is ready to fight!"),
      _INTL("It looks like {1} will fight just about anyone right now!"),
      _INTL("{1} is growling in a way that sounds almost like speech...")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 6, 7, 8
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 25])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Neutral Animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, random_val|
  if random_val == 2
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_ELIPSES)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} is looking down steadily."),
      _INTL("{1} is sniffing around."),
      _INTL("{1} is concentrating deeply."),
      _INTL("{1} faced {2} and nodded."),
      _INTL("{1} is glaring straight into {2}'s eyes."),
      _INTL("{1} is surveying the area."),
      _INTL("{1} focused with a sharp gaze!"),
      _INTL("{1} is looking around absentmindedly."),
      _INTL("{1} yawned very loudly!"),
      _INTL("{1} is relaxing comfortably."),
      _INTL("{1} is focusing its attention on {2}."),
      _INTL("{1} is staring intently at nothing."),
      _INTL("{1} is concentrating."),
      _INTL("{1} faced {2} and nodded."),
      _INTL("{1} is looking at {2}'s footprints."),
      _INTL("{1} seems to want to play and is gazing at {2} expectedly."),
      _INTL("{1} seems to be thinking deeply about something."),
      _INTL("{1} isn't paying attention to {2}...Seems it's thinking about something else."),
      _INTL("{1} seems to be feeling serious."),
      _INTL("{1} seems disinterested."),
      _INTL("{1}'s mind seems to be elsewhere."),
      _INTL("{1} seems to be observing the surroundings instead of watching {2}."),
      _INTL("{1} looks a bit bored."),
      _INTL("{1} has an intense look on its face."),
      _INTL("{1} is staring off into the distance."),
      _INTL("{1} seems to be carefully examining {2}'s face."),
      _INTL("{1} seems to be trying to communicate with its eyes."),
      _INTL("... {1} seems to have sneezed!"),
      _INTL("... {1} noticed that {2}'s shoes are a bit dirty."),
      _INTL("Seems {1} ate something strange, it's making an odd face... "),
      _INTL("{1} seems to be smelling something good."),
      _INTL("{1} noticed that {2}'s Bag has a little dirt on it..."),
      _INTL("...... ...... ...... ...... ...... ...... ...... ...... ...... ...... ...... {1} silently nodded!")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 1, 5, 7, 20, 21
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 35])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnDown
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Happy animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, random_val|
  if random_val == 3
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HAPPY)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} began poking {2}."),
      _INTL("{1} looks very happy."),
      _INTL("{1} happily cuddled up to {2}."),
      _INTL("{1} is so happy that it can't stand still."),
      _INTL("{1} looks like it wants to lead!"),
      _INTL("{1} is coming along happily."),
      _INTL("{1} seems to be feeling great about walking with {2}!"),
      _INTL("{1} is glowing with health."),
      _INTL("{1} looks very happy."),
      _INTL("{1} put in extra effort just for {2}!"),
      _INTL("{1} is smelling the scents of the surounding air."),
      _INTL("{1} is jumping with joy!"),
      _INTL("{1} is still feeling great!"),
      _INTL("{1} stretched out its body and is relaxing."),
      _INTL("{1} is doing its best to keep up with {2}."),
      _INTL("{1} is happily cuddling up to {2}!"),
      _INTL("{1} is full of energy!"),
      _INTL("{1} is so happy that it can't stand still!"),
      _INTL("{1} is wandering around and listening to the different sounds."),
      _INTL("{1} gives {2} a happy look and a smile."),
      _INTL("{1} started breathing roughly through its nose in excitement!"),
      _INTL("{1} is trembling with eagerness!"),
      _INTL("{1} is so happy, it started rolling around."),
      _INTL("{1} looks thrilled at getting attention from {2}."),
      _INTL("{1} seems very pleased that {2} is noticing it!"),
      _INTL("{1} started wriggling its entire body with excitement!"),
      _INTL("It seems like {1} can barely keep itself from hugging {2}!"),
      _INTL("{1} is keeping close to {2}'s feet.")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 3
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 45])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    when 11, 16, 17, 24
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 40])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Heart animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, random_val|
  if random_val == 4
    FollowingPkmn.animation(FollowingPkmn::ANIMATION_EMOTE_HEART)
    pbMoveRoute($game_player, [PBMoveRoute::Wait, 20])
    messages = [
      _INTL("{1} suddenly started walking closer to {2}."),
      _INTL("Woah! {1} suddenly hugged {2}."),
      _INTL("{1} is rubbing up against {2}."),
      _INTL("{1} is keeping close to {2}."),
      _INTL("{1} blushed."),
      _INTL("{1} loves spending time with {2}!"),
      _INTL("{1} is suddenly playful!"),
      _INTL("{1} is rubbing against {2}'s legs!"),
      _INTL("{1} is regarding {2} with adoration!"),
      _INTL("{1} seems to want some affection from {2}."),
      _INTL("{1} seems to want some attention from {2}."),
      _INTL("{1} seems happy travelling with {2}."),
      _INTL("{1} seems to be feeling affectionate towards {2}."),
      _INTL("{1} is looking at {2} with loving eyes."),
      _INTL("{1} looks like it wants a treat from {2}."),
      _INTL("{1} looks like it wants {2} to pet it!"),
      _INTL("{1} is rubbing itself against {2} affectionately."),
      _INTL("{1} bumps its head gently against {2}'s hand."),
      _INTL("{1} rolls over and looks at {2} expectantly."),
      _INTL("{1} is looking at {2} with trusting eyes."),
      _INTL("{1} seems to be begging {2} for some affection!"),
      _INTL("{1} mimicked {2}!")
    ]
    value = rand(messages.length)
    case value
    when 1, 6,
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 10])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with no animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc { |pkmn, random_val|
  if random_val == 5
    messages = [
      _INTL("{1} spun around in a circle!"),
      _INTL("{1} let out a battle cry."),
      _INTL("{1} is on the lookout!"),
      _INTL("{1} is standing patiently."),
      _INTL("{1} is looking around restlessly."),
      _INTL("{1} is wandering around."),
      _INTL("{1} yawned loudly!"),
      _INTL("{1} is steadily poking at the ground around {2}'s feet."),
      _INTL("{1} is looking at {2} and smiling."),
      _INTL("{1} is staring intently into the distance."),
      _INTL("{1} is keeping up with {2}."),
      _INTL("{1} looks pleased with itself."),
      _INTL("{1} is still going strong!"),
      _INTL("{1} is walking in sync with {2}."),
      _INTL("{1} started spinning around in circles."),
      _INTL("{1} looks at {2} with anticipation."),
      _INTL("{1} fell down and looks a little embarrassed."),
      _INTL("{1} is waiting to see what {2} will do."),
      _INTL("{1} is calmly watching {2}."),
      _INTL("{1} is looking to {2} for some kind of cue."),
      _INTL("{1} is staying in place, waiting for {2} to make a move."),
      _INTL("{1} obediently sat down at {2}'s feet."),
      _INTL("{1} jumped in surprise!"),
      _INTL("{1} jumped a little!")
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 0
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 15])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown
      ])
    when 2, 4
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 35])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 10,
        PBMoveRoute::TurnDown
      ])
    when 14
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 50])
      FollowingPkmn.move_route([
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnRight,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnUp,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnLeft,
        PBMoveRoute::Wait, 4,
        PBMoveRoute::TurnDown
      ])
    when 22, 23
      pbMoveRoute($game_player, [PBMoveRoute::Wait, 10])
      FollowingPkmn.move_route([
        PBMoveRoute::Jump, 0, 0
      ])
    end
    pbMessage(_INTL(messages[value], pkmn.name, $Trainer.name))
    next true
  end
}
