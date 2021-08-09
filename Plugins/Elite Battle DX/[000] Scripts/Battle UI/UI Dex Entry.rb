#===============================================================================
#  EBDX UI animation on battler capture
#===============================================================================
class EliteBattle_Pokedex
  #-----------------------------------------------------------------------------
  #  constructs class
  #-----------------------------------------------------------------------------
  def initialize(viewport, battler)
    @viewport = viewport
    @viewport.color = Color.new(0, 0, 0, 0)
    16.times do
      @viewport.color.alpha += 16
      Graphics.update
    end
    @path = "Graphics/EBDX/Pictures/Pokedex/"
    @pokemon = battler
    @species = @pokemon.species
    @pkmnbmp = pbLoadPokemonBitmap(@pokemon)
    @sprites = {}
    @disposed = false
    @typebitmap = pbBitmap("Graphics/EBDX/Pictures/UI/types2")
    self.applyMetrics
    self.drawPage
    self.drawNick
    self.main
  end
  #-----------------------------------------------------------------------------
  #  draws page contents
  #-----------------------------------------------------------------------------
  def drawPage
    # queue dex data
    species_data = GameData::Species.get_species_form(@species, @pokemon.form)
    # draw UI background
    @sprites["bg"] = ScrollingSprite.new(@viewport)
    @sprites["bg"].setBitmap(@path + @imgBg)
    @sprites["bg"].speed = 1
    @sprites["bg"].color = Color.new(0, 0, 0, 0)
    # draw Pokemon sprite
    @sprites["poke"] = Sprite.new(@viewport)
    @sprites["poke"].bitmap = @pkmnbmp.bitmap
    @sprites["poke"].center!
    @sprites["poke"].x = 90
    @sprites["poke"].y = 122
    @sprites["poke"].z = 10
    @sprites["poke"].mirror = true
    # draw sprite silhouette
    @sprites["sil"] = Sprite.new(@viewport)
    @sprites["sil"].bitmap = @pkmnbmp.bitmap
    @sprites["sil"].center!
    @sprites["sil"].x = 90
    @sprites["sil"].y = 122
    @sprites["sil"].z = 10
    @sprites["sil"].mirror = true
    @sprites["sil"].color = Color.black
    # draw UI overlay
    @sprites["contents"] = Sprite.new(@viewport)
    @sprites["contents"].bitmap = Bitmap.new(@viewport.width, @viewport.height)
    @sprites["contents"].color = Color.new(0, 0, 0, 0)
    # draw UI highlight
    @sprites["highlight"] = Sprite.new(@viewport)
    @sprites["highlight"].bitmap = pbBitmap(@path + @imgHh)
    @sprites["highlight"].color = Color.new(0, 0, 0, 0)
    @sprites["highlight"].opacity = 0
    @sprites["highlight"].toggle = 1
    # set up overlay bitmap
    pbSetSystemFont(@sprites["contents"].bitmap)
    overlay = @sprites["contents"].bitmap
    olbmp = pbBitmap(@path + @imgOl)
    overlay.blt(0, 0, olbmp, olbmp.rect)
    olbmp.dispose
    # draw overlay contents
    base   = Color.new(88, 88, 80)
    shadow = Color.new(168, 184, 184)
    textpos = []
    # region and dexlist config
    region = -1
    if Settings::USE_CURRENT_REGION_DEX
      region = pbGetCurrentRegion
      region = -1 if region >= $Trainer.pokedex.dexes_count - 1
    else
      region = $PokemonGlobal.pokedexDex   # National Dex -1, regional Dexes 0, 1, etc.
    end
    dexnum = pbGetRegionalNumber(region, @species)
    dexnumshift = Settings::DEXES_WITH_OFFSETS.include?(region)
    dexlist = [[@species, GameData::Species.get(@species).name, 0, 0, dexnum, dexnumshift]]
    # dex number
    indexText = "???"
    if dexlist[0][4] > 0
      indexNumber = dexlist[0][4]
      indexNumber -= 1 if dexlist[0][5]
      indexText = sprintf("%03d", indexNumber)
    end
    # push text into array
    textpos.push([_INTL("{1}   {2}", indexText, species_data.real_name), 262, 30, 0, base, shadow])
    textpos.push([_INTL("Height"), 274, 158, 0, base, shadow])
    textpos.push([_INTL("Weight"), 274, 190, 0, base, shadow])
    # Pokemon kind
    textpos.push([_INTL("{1} Pokémon", species_data.category), 262, 66, 0, base, shadow])
    # height and weight
    height = species_data.height
    weight = species_data.weight
    if System.user_language[3..4] == "US"   # If the user is in the United States
      inches = (height/0.254).round
      pounds = (weight/0.45359).round
      textpos.push([_ISPRINTF("{1:d}'{2:02d}''", inches/12, inches%12), 482, 158, 1, base, shadow])
      textpos.push([_ISPRINTF("{1:4.1f} lbs.", pounds/10.0), 482, 190, 1, base, shadow])
    else
      textpos.push([_ISPRINTF("{1:.1f} m", height/10.0), 482, 158, 1, base, shadow])
      textpos.push([_ISPRINTF("{1:.1f} kg", weight/10.0), 482, 190, 1, base, shadow])
    end
    # Pokédex entry text
    drawTextEx(overlay, 32, 250, Graphics.width - 60, 4, species_data.pokedex_entry, base, shadow)
    # footprint
    footprintfile = GameData::Species.footprint_filename(@species, @pokemon.form)
    if footprintfile
      footprint = pbBitmap(footprintfile)
      overlay.blt(214, 154, footprint, footprint.rect)
      footprint.dispose
    end
    # Draw the type icon(s)
    type1 = GameData::Type.get(species_data.type1).id_number
    type2 = GameData::Type.get(species_data.type2).id_number
    height = @typebitmap.height/GameData::Type.values.length
    type1rect = Rect.new(0, type1*height, @typebitmap.width, height)
    type2rect = Rect.new(0, type2*height, @typebitmap.width, height)
    overlay.blt(292, 122, @typebitmap, type1rect)
    overlay.blt(376, 122, @typebitmap, type2rect) if type1 != type2
    # draw all text
    pbDrawTextPositions(overlay, textpos)
  end
  #-----------------------------------------------------------------------------
  #  draws nicknaming page
  #-----------------------------------------------------------------------------
  def drawNick
    @sprites["color"] = Sprite.new(@viewport)
    @sprites["color"].bitmap = pbBitmap(@path + @imgDk)
    @sprites["color"].z = 5
    @sprites["color"].opacity = 0
    for i in [3,2,1]
      @sprites["c#{i}"] = Sprite.new(@viewport)
      @sprites["c#{i}"].bitmap = pbBitmap(@path + sprintf("#{@imgEl}%03d",i))
      @sprites["c#{i}"].center!
      @sprites["c#{i}"].x = @viewport.width/2
      @sprites["c#{i}"].y = @sprites["poke"].y
      @sprites["c#{i}"].z = 5
      @sprites["c#{i}"].speed = i*0.001
      @sprites["c#{i}"].toggle = 1
      @sprites["c#{i}"].opacity = 0
    end
  end
  #-----------------------------------------------------------------------------
  #  applies alteration if applicable
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @imgBg = "dexBg"
    @imgOl = "dexOverlay"
    @imgDk = "dexEnd"
    @imgEl = "dexElement"
    @imgHh = "dexHighlight"
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:DEX_CAPTURE] if !d1.nil? && d1.has_key?(:DEX_CAPTURE)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:DEX_CAPTURE, :Metrics, :METRICS)
    # looks up species specific metrics
    d5 = EliteBattle.get_data(@species, :Species, :DEX_CAPTURE, (@pokemon.form rescue 0))
    # proceeds with parameter definition if available
    for data in [d2, d1,d5]
      if !data.nil?
        # applies a set of predefined keys
        @imgBg = data[:BACKGROUND] if data.has_key?(:BACKGROUND) && data[:BACKGROUND].is_a?(String)
        @imgOl = data[:OVERLAY] if data.has_key?(:OVERLAY) && data[:OVERLAY].is_a?(String)
        @imgHh = data[:HIGHLIGHT] if data.has_key?(:HIGHLIGHT) && data[:HIGHLIGHT].is_a?(String)
        @imgDk = data[:END_SCREEN] if data.has_key?(:END_SCREEN) && data[:END_SCREEN].is_a?(String)
        @imgEl = data[:ELEMENTS] if data.has_key?(:ELEMENTS) && data[:ELEMENTS].is_a?(String)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  main loop of scene
  #-----------------------------------------------------------------------------
  def main
    # fade in scene
    16.times do
      self.update
      @viewport.color.alpha -= 16
      Graphics.update
    end
    # hide silhouette
    h = (@sprites["sil"].bitmap.height/32.0).ceil
    32.times do
      self.update
      @sprites["sil"].src_rect.height -= h
      Graphics.update
    end
    # play cry
    GameData::Species.cry_filename_from_pokemon(@pokemon)
    # begin loop
    loop do
      Graphics.update
      Input.update
      self.update
      break if Input.trigger?(Input::C)
    end
    # moves Pokemon sprite to middle of screen
    w = (@viewport.width/2 - @sprites["poke"].x)/32
    32.times do
      @sprites["contents"].color.alpha += 16
      @sprites["bg"].color.alpha += 16
      @sprites["highlight"].color.alpha += 16
      @sprites["poke"].x += w
      @sprites["color"].opacity += 8
      for i in 1..3
        @sprites["c#{i}"].opacity += 8
      end
      self.update
      Graphics.update
    end
    @sprites["poke"].x = @viewport.width/2
    Graphics.update
  end
  #-----------------------------------------------------------------------------
  #  updates scene
  #-----------------------------------------------------------------------------
  def update
    return if self.disposed?
    @sprites["bg"].update
    @sprites["highlight"].opacity += @sprites["highlight"].toggle*8
    @sprites["highlight"].toggle *= -1 if @sprites["highlight"].opacity <= 0 || @sprites["highlight"].opacity >= 255
    for i in 1..3
      @sprites["c#{i}"].zoom_x -= @sprites["c#{i}"].speed * @sprites["c#{i}"].toggle
      @sprites["c#{i}"].zoom_y -= @sprites["c#{i}"].speed * @sprites["c#{i}"].toggle
      @sprites["c#{i}"].toggle *= -1 if @sprites["c#{i}"].zoom_x <= 0.96 || @sprites["c#{i}"].zoom_x >= 1.04
    end
  end
  #-----------------------------------------------------------------------------
  #  disposes of all sprites
  #-----------------------------------------------------------------------------
  def dispose
    @pkmnbmp.dispose
    pbDisposeSpriteHash(@sprites)
    @disposed = true
  end
  #-----------------------------------------------------------------------------
  #  checks if room is disposed
  #-----------------------------------------------------------------------------
  def disposed?; return @disposed; end
  #-----------------------------------------------------------------------------
  #  compatibility layers for scene transitions
  #-----------------------------------------------------------------------------
  def color; return @viewport.color; end
  def color=(val); @viewport.color = val; end
  def visible; return @sprites["bg"].visible; end
  def visible=(val)
    for key in @sprites.keys
      @sprites[key].visible = val
    end
  end
  #-----------------------------------------------------------------------------
end
