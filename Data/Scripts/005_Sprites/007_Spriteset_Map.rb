class ClippableSprite < Sprite_Character
  def initialize(viewport,event,tilemap)
    @tilemap = tilemap
    @_src_rect = Rect.new(0,0,0,0)
    super(viewport,event)
  end

  def update
    super
    @_src_rect = self.src_rect
    tmright = @tilemap.map_data.xsize*Game_Map::TILE_WIDTH-@tilemap.ox
    echoln("x=#{self.x},ox=#{self.ox},tmright=#{tmright},tmox=#{@tilemap.ox}")
    if @tilemap.ox-self.ox<-self.x
      # clipped on left
      diff = -self.x-@tilemap.ox+self.ox
      self.src_rect = Rect.new(@_src_rect.x+diff,@_src_rect.y,
                               @_src_rect.width-diff,@_src_rect.height)
      echoln("clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
    elsif tmright-self.ox<self.x
      # clipped on right
      diff = self.x-tmright+self.ox
      self.src_rect = Rect.new(@_src_rect.x,@_src_rect.y,
                               @_src_rect.width-diff,@_src_rect.height)
      echoln("clipped out right: #{diff} #{tmright+self.ox} #{self.x}")
    else
      echoln("-not- clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
    end
  end
end



class Spriteset_Map
  attr_reader :map
  attr_accessor :tilemap
  @@viewport0 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Panorama
  @@viewport0.z = -100
  @@viewport1 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Map, events, player, fog
  @@viewport1.z = 0
  @@viewport3 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Flashing
  @@viewport3.z = 500

  def Spriteset_Map.viewport   # For access by Spriteset_Global
    return @@viewport1
  end

  def initialize(map=nil)
    @map = (map) ? map : $game_map
    @tilemap = TilemapLoader.new(@@viewport1)
    @tilemap.tileset = pbGetTileset(@map.tileset_name)
    for i in 0...7
      autotile_name = @map.autotile_names[i]
      @tilemap.autotiles[i] = pbGetAutotile(autotile_name)
    end
    @tilemap.map_data = @map.data
    @tilemap.priorities = @map.priorities
    @tilemap.terrain_tags = @map.terrain_tags
    @panorama = AnimatedPlane.new(@@viewport0)
    @fog = AnimatedPlane.new(@@viewport1)
    @fog.z = 3000
    @character_sprites = []
    for i in @map.events.keys.sort
      sprite = Sprite_Character.new(@@viewport1,@map.events[i])
      @character_sprites.push(sprite)
    end
    @weather = RPG::Weather.new(@@viewport1)
    pbOnSpritesetCreate(self,@@viewport1)
    update
  end

  def dispose
    @tilemap.tileset.dispose
    for i in 0...7
      @tilemap.autotiles[i].dispose
    end
    @tilemap.dispose
    @panorama.dispose
    @fog.dispose
    for sprite in @character_sprites
      sprite.dispose
    end
    @weather.dispose
    @tilemap = nil
    @panorama = nil
    @fog = nil
    @character_sprites.clear
    @weather = nil
  end

  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites = anims
  end

  def update
    if @panorama_name!=@map.panorama_name || @panorama_hue!=@map.panorama_hue
      @panorama_name = @map.panorama_name
      @panorama_hue  = @map.panorama_hue
      @panorama.setPanorama(nil) if @panorama.bitmap!=nil
      @panorama.setPanorama(@panorama_name,@panorama_hue) if @panorama_name!=""
      Graphics.frame_reset
    end
    if @fog_name!=@map.fog_name || @fog_hue!=@map.fog_hue
      @fog_name = @map.fog_name
      @fog_hue = @map.fog_hue
      @fog.setFog(nil) if @fog.bitmap!=nil
      @fog.setFog(@fog_name,@fog_hue) if @fog_name!=""
      Graphics.frame_reset
    end
    tmox = (@map.display_x/Game_Map::X_SUBPIXELS).round
    tmoy = (@map.display_y/Game_Map::Y_SUBPIXELS).round
    @tilemap.ox = tmox
    @tilemap.oy = tmoy
    @@viewport1.rect.set(0,0,Graphics.width,Graphics.height)
    @@viewport1.ox = 0
    @@viewport1.oy = 0
    @@viewport1.ox += $game_screen.shake
    @tilemap.update
    @panorama.ox = tmox/2
    @panorama.oy = tmoy/2
    @fog.ox         = tmox+@map.fog_ox
    @fog.oy         = tmoy+@map.fog_oy
    @fog.zoom_x     = @map.fog_zoom/100.0
    @fog.zoom_y     = @map.fog_zoom/100.0
    @fog.opacity    = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.tone       = @map.fog_tone
    @panorama.update
    @fog.update
    for sprite in @character_sprites
      sprite.update
    end
    if self.map!=$game_map
      @weather.fade_in(:None, 0, 20)
    else
      @weather.fade_in($game_screen.weather_type, $game_screen.weather_max, $game_screen.weather_duration)
    end
    @weather.ox   = tmox
    @weather.oy   = tmoy
    @weather.update
    @@viewport1.tone = $game_screen.tone
    @@viewport3.color = $game_screen.flash_color
    @@viewport1.update
    @@viewport3.update
  end
end
