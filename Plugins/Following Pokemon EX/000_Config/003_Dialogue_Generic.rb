
#-------------------------------------------------------------------------------
# These are used to define what the Follower will say when spoken to in general
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Generic Item Dialogue
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  items = [:POTION,:SUPERPOTION,:FULLRESTORE,:REVIVE,:PPUP,
       :PPMAX,:RARECANDY,:REPEL,:MAXREPEL,:ESCAPEROPE,
       :HONEY,:TINYMUSHROOM,:PEARL,:NUGGET,:GREATBALL,
       :ULTRABALL,:THUNDERSTONE,:MOONSTONE,:SUNSTONE,:DUSKSTONE,
       :REDAPRICORN,:BLUAPRICORN,:YLWAPRICORN,:GRNAPRICORN,:PNKAPRICORN,
       :BLKAPRICORN,:WHTAPRICORN
  ]
  # If no message or quantity is specified the default message is used and the quantity of item is 1
  next true if pbPokemonFound(rand(items.length))
}
#-------------------------------------------------------------------------------
# All dialogues with the Music Note animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if random_val == 0
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_sing,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} seems to want to play with {2}.",
      "{1} is singing and humming.",
      "{1} is looking up at {2} with a happy expression.",
      "{1} swayed and danced around as it pleased.",
      "{1} is jumping around in a carefree way!",
      "{1} is showing off its agility!",
      "{1} is moving around happily!",
      "Whoa! {1} suddenly started dancing in happiness!",
      "{1} is steadily keeping up with {2}!",
      "{1} is happy skipping about.",
      "{1} is playfully nibbling at the ground.",
      "{1} is playfully nipping at {2}'s feet!",
      "{1} is following {2} very closely!",
      "{1} turns around and looks at {2}.",
      "{1} is working hard to show off its mighty power!",
      "{1} looks like it wants to run around!",
      "{1} is wandering around enjoying the scenery.",
      "{1} seems to be enjoying this a little bit!",
      "{1} is cheerful!",
      "{1} seems to be singing something?",
      "{1} is dancing around happily!",
      "{1} is having fun dancing a lively jig!",
      "{1} is so happy, it started singing!",
      "{1} looked up and howled!",
      "{1} seems to be feeling optimistic.",
      "It looks like {1} feels like dancing!",
      "{1} Suddenly started to sing! It seems to be feeling great.",
      "It looks like {1} wants to dance with {2}!"
    ]
    value = rand(messages.length)
    case value
    # Special move route to go along with some of the dialogue
    when 3, 9
        pbMoveRoute($game_player,[PBMoveRoute::Wait,65])
        follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,PBMoveRoute::Jump,0,0])
    when 4, 5
        pbMoveRoute($game_player,[PBMoveRoute::Wait,40])
        follower_move_route([
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,PBMoveRoute::Jump,0,0])
    when 6, 17

        follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,PBMoveRoute::TurnUp])
    when 7, 28
        pbMoveRoute($game_player,[PBMoveRoute::Wait,60])
        follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,PBMoveRoute::Jump,0,0])
    when 21, 22
        pbMoveRoute($game_player,[PBMoveRoute::Wait,50])
        follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,PBMoveRoute::Jump,0,0])
    end
    pbMessage(_INTL(messages[value],pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Angry animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if random_val == 1
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Hate,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} let out a roar!",
      "{1} is making a face like it's angry!",
      "{1} seems to be angry for some reason.",
      "{1} chewed on {2}'s feet.",
      "{1} turned to face the other way, showing a defiant expression.",
      "{1} is trying to intimidate {2}'s foes!",
      "{1} wants to pick a fight!",
      "{1} is ready to fight!",
      "It looks like {1} will fight just about anyone right now!",
      "{1} is growling in a way that sounds almost like speech..."
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 6, 7, 8
      pbMoveRoute($game_player,[PBMoveRoute::Wait,25])
      follower_move_route([
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,PBMoveRoute::Jump,0,0])
    end
    pbMessage(_INTL(messages[value],pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Neutral Animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if random_val == 2
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Normal,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} is looking down steadily.",
      "{1} is sniffing around.",
      "{1} is concentrating deeply.",
      "{1} faced {2} and nodded.",
      "{1} is glaring straight into {2}'s eyes.",
      "{1} is surveying the area.",
      "{1} focused with a sharp gaze!",
      "{1} is looking around absentmindedly.",
      "{1} yawned very loudly!",
      "{1} is relaxing comfortably.",
      "{1} is focusing its attention on {2}.",
      "{1} is staring intently at nothing.",
      "{1} is concentrating.",
      "{1} faced {2} and nodded.",
      "{1} is looking at {2}'s footprints.",
      "{1} seems to want to play and is gazing at {2} expectedly.",
      "{1} seems to be thinking deeply about something.",
      "{1} isn't paying attention to {2}...Seems it's thinking about something else.",
      "{1} seems to be feeling serious.",
      "{1} seems disinterested.",
      "{1}'s mind seems to be elsewhere.",
      "{1} seems to be observing the surroundings instead of watching {2}.",
      "{1} looks a bit bored.",
      "{1} has an intense look on its' face.",
      "{1} is staring off into the distance.",
      "{1} seems to be carefully examining {2}'s face.",
      "{1} seems to be trying to communicate with its' eyes.",
      "...{1} seems to have sneezed!",
      "...{1} noticed that {2}'s shoes are a bit dirty.",
      "Seems {1} ate something strange, it's making an odd face... ",
      "{1} seems to be smelling something good.",
      "{1} noticed that {2}' Bag has a little dirt on it...",
      "...... ...... ...... ...... ...... ...... ...... ...... ...... ...... ...... {1} silently nodded!"
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when  1, 5, 7, 20, 21
      pbMoveRoute($game_player,[PBMoveRoute::Wait,35])
      follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnDown])
    end
    pbMessage(_INTL(messages[value],pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Happy animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if random_val == 3
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_Happy,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} began poking {2}.",
      "{1} looks very happy.",
      "{1} happily cuddled up to {2}.",
      "{1} is so happy that it can't stand still.",
      "{1} looks like it wants to lead!",
      "{1} is coming along happily.",
      "{1} seems to be feeling great about walking with {2}!",
      "{1} is glowing with health.",
      "{1} looks very happy.",
      "{1} put in extra effort just for {2}!",
      "{1} is smelling the scents of the surounding air.",
      "{1} is jumping with joy!",
      "{1} is still feeling great!",
      "{1} stretched out its body and is relaxing.",
      "{1} is doing its' best to keep up with {2}.",
      "{1} is happily cuddling up to {2}!",
      "{1} is full of energy!",
      "{1} is so happy that it can't stand still!",
      "{1} is wandering around and listening to the different sounds.",
      "{1} gives {2} a happy look and a smile.",
      "{1} started breathing roughly through its nose in excitement!",
      "{1} is trembling with eagerness!",
      "{1} is so happy, it started rolling around.",
      "{1} looks thrilled at getting attention from {2}.",
      "{1} seems very pleased that {2} is noticing it!",
      "{1} started wriggling its' entire body with excitement!",
      "It seems like {1} can barely keep itself from hugging {2}!",
      "{1} is keeping close to {2}'s feet."
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 3
      pbMoveRoute($game_player,[PBMoveRoute::Wait,45])
      follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,PBMoveRoute::Jump,0,0])
    when 11, 16, 17, 24
      pbMoveRoute($game_player,[PBMoveRoute::Wait,40])
      follower_move_route([
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,
        PBMoveRoute::Jump,0,0,PBMoveRoute::Wait,10,PBMoveRoute::Jump,0,0])
    end
    pbMessage(_INTL(messages[value],pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with the Heart animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if random_val == 4
    $scene.spriteset.addUserAnimation(FollowerSettings::Emo_love,x,y)
    pbMoveRoute($game_player,[PBMoveRoute::Wait,20])
    messages = [
      "{1} suddenly started walking closer to {2}.",
      "Woah! {1} suddenly hugged {2}.",
      "{1} is rubbing up against {2}.",
      "{1} is keeping close to {2}.",
      "{1} blushed.",
      "{1} loves spending time with {2}!",
      "{1} is suddenly playful!",
      "{1} is rubbing against {2}'s legs!",
      "{1} is regarding {2} with adoration!",
      "{1} seems to want some affection from {2}.",
      "{1} seems to want some attention from {2}.",
      "{1} seems happy travelling with {2}.",
      "{1} seems to be feeling affectionate towards {2}.",
      "{1} is looking at {2} with loving eyes.",
      "{1} looks like it wants a treat from {2}.",
      "{1} looks like it wants {2} to pet it!",
      "{1} is rubbing itself against {2} affectionately.",
      "{1} bumps its' head gently against {2}'s hand.",
      "{1} rolls over and looks at {2} expectantly.",
      "{1} is looking at {2} with trusting eyes.",
      "{1} seems to be begging {2} for some affection!",
      "{1} mimicked {2}!"
    ]
    value = rand(messages.length)
    case value
    when 1, 6,
      pbMoveRoute($game_player,[PBMoveRoute::Wait,10])
      follower_move_route([
        PBMoveRoute::Jump,0,0])
    end
    pbMessage(_INTL(messages[value],pkmn.name,$Trainer.name))
    next true
  end
}
#-------------------------------------------------------------------------------
# All dialogues with no animation
#-------------------------------------------------------------------------------
Events.OnTalkToFollower += proc {|pkmn,x,y,random_val|
  if random_val == 5
    messages = [
      "{1} spun around in a circle!",
      "{1} let out a battle cry.",
      "{1} is on the lookout!",
      "{1} is standing patiently.",
      "{1} is looking around restlessly.",
      "{1} is wandering around.",
      "{1} yawned loudly!",
      "{1} is steadily poking at the ground around {2}'s feet.",
      "{1} is looking at {2} and smiling.",
      "{1} is staring intently into the distance.",
      "{1} is keeping up with {2}.",
      "{1} looks pleased with itself.",
      "{1} is still going strong!",
      "{1} is walking in sync with {2}.",
      "{1} started spinning around in circles.",
      "{1} looks at {2} with anticipation.",
      "{1} fell down and looks a little embarrassed.",
      "{1} is waiting to see what {2} will do.",
      "{1} is calmly watching {2}.",
      "{1} is looking to {2} for some kind of cue.",
      "{1} is staying in place, waiting for {2} to make a move.",
      "{1} obediently sat down at {2}'s feet.",
      "{1} jumped in surprise!",
      "{1} jumped a little!"
    ]
    value = rand(messages.length)
    # Special move route to go along with some of the dialogue
    case value
    when 0
      pbMoveRoute($game_player,[PBMoveRoute::Wait,15])
      follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,PBMoveRoute::TurnDown])
    when 2,4
      pbMoveRoute($game_player,[PBMoveRoute::Wait,35])
      follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,10,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,10,PBMoveRoute::TurnDown])
    when 14
      pbMoveRoute($game_player,[PBMoveRoute::Wait,50])
      follower_move_route([
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnDown,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnRight,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnUp,PBMoveRoute::Wait,4,
        PBMoveRoute::TurnLeft,PBMoveRoute::Wait,4,PBMoveRoute::TurnDown])
    when 22, 23
      pbMoveRoute($game_player,[PBMoveRoute::Wait,10])
      follower_move_route([
        PBMoveRoute::Jump,0,0])
    end
    pbMessage(_INTL(messages[value],pkmn.name,$Trainer.name))
    next true
  end
}
