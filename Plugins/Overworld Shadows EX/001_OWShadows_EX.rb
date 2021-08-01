#-------------------------------------------------------------------------------
# Defining Customizable Options for Overworld Shadows
#-------------------------------------------------------------------------------
module OWShadowSettings
  # Set this to true if you want the event name and character name blacklists to be case sensitive.
  CASE_SENSITIVE_BLACKLISTS = false

  # If an event name contains one of these words, it will not have a shadow.
  SHADOWLESS_EVENT_NAME     = ["door", "nurse", "Healing balls", "Mart", "SmashRock",
                               "StrengthBoulder", "CutTree", "HeadbuttTree", "BerryPlant",
                               ".shadowless", ".noshadow", ".sl"]

  # If the character file and event uses contains one of these words in its filename, it will not have a shadow.
  SHADOWLESS_CHARACTER_NAME = ["nil"]

  # If an event stands on a tile with one of these terrain tags, it will not have a shadow.
  # (Names can be seen in the script section "Terrain Tag")
  SHADOWLESS_TERRAIN_NAME   = [:Grass, :DeepWater, :StillWater, :Water, :Waterfall, :WaterfallCrest, :Puddle, :Ice]

  # If an event doesn't have a custom shadow defined, it will use this shadow graphic
  DEFAULT_SHADOW_FILENAME   = "defaultShadow"

  # Defaul shadow graphic used by the player
  PLAYER_SHADOW_FILENAME    = "defaultShadow"
end

#-------------------------------------------------------------------------------
# New Class for Shadow object
#-------------------------------------------------------------------------------
class Sprite_OWShadow
  attr_reader :visible

  def initialize(sprite, event, viewport = nil)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @viewport = viewport
    @disposed = false
    @remove   = false
    name      = ""
    if @event != $game_player
      name = $~[1] if @event.name[/shdw\((.*?)\)/]
      if OWShadowSettings::CASE_SENSITIVE_BLACKLISTS
        @remove = true if OWShadowSettings::SHADOWLESS_EVENT_NAME.any? {|e| @event.name[/#{e}/]}
      else
        @remove = true if OWShadowSettings::SHADOWLESS_EVENT_NAME.any? {|e| @event.name[/#{e}/i]}
      end
    else
      name = OWShadowSettings::PLAYER_SHADOW_FILENAME
    end
    name = OWShadowSettings::DEFAULT_SHADOW_FILENAME if nil_or_empty?(name)
    @ow_shadow_bitmap = AnimatedBitmap.new("Graphics/Characters/Shadows/" + name)
    RPG::Cache.retain("Graphics/Characters/Shadows/" + name)
    update
  end

  def setBitmap(name)
    if !pbResolveBitmap("Graphics/Characters/Shadows/" + name)
      echoln("The Shadow File you are trying to set it absent from /Graphics/Characters/Shadows/")
      return
    end
    @ow_shadow_bitmap = AnimatedBitmap.new("Graphics/Characters/Shadows/" + name)
    RPG::Cache.retain("Graphics/Characters/Shadows/" + name)
    @sprite.dispose if !@sprite.disposed?
    @sprite = nil
    @sprite = Sprite.new(@viewport)
    @sprite.bitmap  = @ow_shadow_bitmap.bitmap
    update
  end

  def dispose
    if !@disposed
      @sprite.dispose if @sprite
      @sprite = nil
      @disposed = true
    end
  end

  def disposed?
    return @disposed
  end

# Calculation of shadow size when jumping
  def jump_sprite
    return unless @sprite
    if @event.jump_distance_left >= 1 && @event.jump_distance_left < @event.jump_peak
      @sprite.zoom_x += 0.1
      @sprite.zoom_y += 0.1
    elsif @event.jump_distance_left >= @event.jump_peak
      @sprite.zoom_x -= 0.05
      @sprite.zoom_y -= 0.05
    end
    @sprite.zoom_x = 1 if @sprite.zoom_x > 1
    @sprite.zoom_x = 0 if @sprite.zoom_x < 0
    @sprite.zoom_y = 1 if @sprite.zoom_y > 1
    @sprite.zoom_y = 0 if @sprite.zoom_y < 0
    if @event.jump_count == 1
      @sprite.zoom_x = 1.0
      @sprite.zoom_y = 1.0
    end
    @sprite.x = @event.screen_x
    @sprite.y = @event.screen_y
    @sprite.z = @rsprite.z - 1
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
  end

  def update
    return if disposed? || !$scene.is_a?(Scene_Map)
    return jump_sprite if @event.jumping?
    remove =  false
    if OWShadowSettings::CASE_SENSITIVE_BLACKLISTS
      remove = true if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any?{|e| @event.character_name[/#{e}/]}
    else
      remove = true if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any?{|e| @event.character_name[/#{e}/i]}
    end
    terrain = $game_map.terrain_tag(@event.x,@event.y)
    remove = true if OWShadowSettings::SHADOWLESS_TERRAIN_NAME.any? {|e| terrain == e} if terrain
    if nil_or_empty?(@event.character_name) || @event.transparent || @remove || remove
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose if !@sprite.disposed?
        @sprite = nil
      end
      return
    end
  	if !@sprite
      # Just-in-time creation of sprite
      @sprite = Sprite.new(@viewport)
      @sprite.bitmap  = @ow_shadow_bitmap.bitmap
    end
    @sprite.x       = @rsprite.x
    @sprite.y       = @rsprite.y
    @sprite.ox      = @ow_shadow_bitmap.width/2
    @sprite.oy      = @ow_shadow_bitmap.height - 2
    @sprite.z       = @rsprite.z-1
    @sprite.zoom_x  = @rsprite.zoom_x
    @sprite.zoom_y  = @rsprite.zoom_y
    @sprite.opacity = @rsprite.opacity
  end
end

#-------------------------------------------------------------------------------
# New Method for setting shadow of any event given the map id and event id
#-------------------------------------------------------------------------------
def pbSetOverworldShadow(name, event_id = nil, map_id = nil)
  return if !$scene.is_a?(Scene_Map)
  return if nil_or_empty?(name)
  if !event_id
    $scene.spritesetGlobal.playersprite.ow_shadow.setBitmap(name)
  else
    map_id = $game_map.map_id if !map_id
    $scene.spritesets[map_id].character_sprites[(event_id - 1)].ow_shadow.setBitmap(name)
  end
end


#-------------------------------------------------------------------------------
# Referencing and initializing Shadow Sprite in Sprite_Character
#-------------------------------------------------------------------------------
class Sprite_Character
  attr_accessor :ow_shadow

# Initializing Shadow with Character
 alias sh_init initialize
  def initialize(viewport, character = nil)
    sh_init(viewport,character)
    @ow_shadow = Sprite_OWShadow.new(self,character,viewport)
    update
  end

# Changing Shadow Visibility with Character
  def visible=(value)
    super(value)
    @reflection.visible = value if @reflection
    @ow_shadow.visible = value if @ow_shadow
  end

# Disposing Shadow with Character
  alias sh_dispose dispose
  def dispose
    sh_dispose
    @ow_shadow.dispose if @ow_shadow
    @ow_shadow = nil
  end

# Updating Shadow with Character
  alias sh_update update
  def update
    sh_update
    @ow_shadow.update if @ow_shadow
  end
end

#-------------------------------------------------------------------------------
# Adding accessors to the Game_Character class
#-------------------------------------------------------------------------------
class Game_Character
  attr_reader :jump_count
  attr_reader :jump_distance
  attr_reader :jump_distance_left
  attr_reader :jump_peak
end

#-------------------------------------------------------------------------------
# Adding accessors to the Scene_Map class
#-------------------------------------------------------------------------------
class Scene_Map
  attr_accessor :spritesets
end

#-------------------------------------------------------------------------------
# Adding accessors to the Game_Character class
#-------------------------------------------------------------------------------
class Spriteset_Map
  attr_accessor :character_sprites
end

echoln("Loaded plugin: Overworld Shadows EX") if !Essentials::VERSION.include?(".")
