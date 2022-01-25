#-------------------------------------------------------------------------------
# Make Following Pokemon Independent of Spriteset_Map
#-------------------------------------------------------------------------------
class Spriteset_Map
  alias __followingpkmn__addUserSprite addUserSprite unless method_defined?(:__followingpkmn__addUserSprite)
  def addUserSprite(*args)
    if args[0].is_a?(DependentEventSprites)
      args[0].dispose
      return
    end
    __followingpkmn__addUserSprite(*args)
  end
end

class DependentEventSprites
  def initialize(viewport, map)
    @disposed = false
    @sprites  = []
    @viewport = viewport
    refresh
    @lastUpdate = nil
  end
end

class Spriteset_Global

  attr_reader :followingpkmn_sprites

  alias __followingpkmn__initialize initialize unless private_method_defined?(:__followingpkmn__initialize)
  def initialize(*args)
    __followingpkmn__initialize(*args)
    @followingpkmn_sprites = DependentEventSprites.new(Spriteset_Map.viewport, nil)
  end

  alias __followingpkmn__dispose dispose unless method_defined?(:__followingpkmn__dispose)
  def dispose(*args)
    __followingpkmn__dispose(*args)
    @followingpkmn_sprites.dispose
    @followingpkmn_sprites = nil
  end

  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    @followingpkmn_sprites.update if @followingpkmn_sprites
  end
end
