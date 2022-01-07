#-------------------------------------------------------------------------------
# New animation to incorporate the HM animation for Following Pokemon
#-------------------------------------------------------------------------------
alias __followingpkmn__pbHiddenMoveAnimation pbHiddenMoveAnimation unless defined?(__followingpkmn__pbHiddenMoveAnimation)
def pbHiddenMoveAnimation(pokemon,followAnim = true)
  ret = __followingpkmn__pbHiddenMoveAnimation(pokemon)
  if ret && followAnim && FollowingPkmn.active? && pokemon == $Trainer.first_able_pokemon
    pbTurnTowardEvent(FollowingPkmn.get, $game_player)
    pbWait(Graphics.frame_rate/5)
    value = $game_player.direction
    FollowingPkmn.move_route([PBMoveRoute::Forward])
    case FollowingPkmn.get.direction
    when 2; pbMoveRoute($game_player,[PBMoveRoute::Up],true)
    when 4; pbMoveRoute($game_player,[PBMoveRoute::Right],true)
    when 6; pbMoveRoute($game_player,[PBMoveRoute::Left],true)
    when 8; pbMoveRoute($game_player,[PBMoveRoute::Down],true)
    end
    pbWait(Graphics.frame_rate/5)
    pbTurnTowardEvent($game_player,FollowingPkmn.get)
    pbWait(Graphics.frame_rate/5)
    case value
    when 2; FollowingPkmn.move_route([PBMoveRoute::TurnDown])
    when 4; FollowingPkmn.move_route([PBMoveRoute::TurnLeft])
    when 6; FollowingPkmn.move_route([PBMoveRoute::TurnRight])
    when 8; FollowingPkmn.move_route([PBMoveRoute::TurnUp])
    end
    pbWait(Graphics.frame_rate/5)
    case value
    when 2; pbMoveRoute($game_player,[PBMoveRoute::TurnDown],true)
    when 4; pbMoveRoute($game_player,[PBMoveRoute::TurnLeft],true)
    when 6; pbMoveRoute($game_player,[PBMoveRoute::TurnRight],true)
    when 8; pbMoveRoute($game_player,[PBMoveRoute::TurnUp],true)
    end
    pbSEPlay("Player jump")
    FollowingPkmn.move_route([PBMoveRoute::Jump,0,0])
    pbWait(Graphics.frame_rate/5)
  end
  return ret
end


#-------------------------------------------------------------------------------
# New sendout animation for Following Pokemon to slide in when sent out for
# the first time in battle. Toggleable.
#-------------------------------------------------------------------------------
class PokeballPlayerSendOutAnimation < PokeBattle_Animation
  def initialize(sprites, viewport, idxTrainer, battler, startBattle, idxOrder=0)
    @idxTrainer     = idxTrainer
    @battler        = battler
    @showingTrainer = startBattle
    @idxOrder       = idxOrder
    @trainer        = @battler.battle.pbGetOwnerFromBattlerIndex(@battler.index)
    @shadowVisible  = sprites["shadow_#{battler.index}"].visible
    @sprites        = sprites
    @viewport       = viewport
    @pictureEx      = []   # For all the PictureEx
    @pictureSprites = []   # For all the sprites
    @tempSprites    = []   # For sprites that exist only for this animation
    @animDone       = false
    if FollowingPkmn.active? && startBattle &&
       battler.index == 0 && FollowingPkmn::SLIDE_INTO_BATTLE
      createFollowerProcesses
    else
      createProcesses
    end
  end

  def createFollowerProcesses
    delay = 0
    delay = 5 if @showingTrainer
    batSprite = @sprites["pokemon_#{@battler.index}"]
    shaSprite = @sprites["shadow_#{@battler.index}"]
    battlerY = batSprite.y
    battler = addSprite(batSprite, PictureOrigin::Bottom)
    battler.setVisible(delay, true)
    battler.setZoomXY(delay, 100, 100)
    battler.setColor(delay, Color.new(0, 0, 0, 0))
    battler.setDelta(0, -240, 0)
    battler.moveDelta(delay, 12, 240, 0)
    battler.setCallback(delay + 12, [batSprite,:pbPlayIntroAnimation])
    if @shadowVisible
      shadow = addSprite(shaSprite, PictureOrigin::Center)
      shadow.setVisible(delay, @shadowVisible)
      shadow.setDelta(0, -Graphics.width/2, 0)
      shadow.setDelta(delay, 12, Graphics.width/2, 0)
    end
  end
end

#-------------------------------------------------------------------------------
# Tiny fix for emote Animations not playing in v19 since people are unable to
# read instructions and can't close RMXP before adding the Following Pokemon
# EX emote animations
#-------------------------------------------------------------------------------
class SpriteAnimation
  def effect?
    return @_animation_duration > 0 if @_animation_duration
  end
end
