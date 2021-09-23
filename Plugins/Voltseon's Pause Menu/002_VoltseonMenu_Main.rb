#-------------------------------------------------------------------------------
# Base class for defining a menu entry
#-------------------------------------------------------------------------------
class MenuEntry
  attr_reader :name

  # defined by user
  def icon; return MENU_FILE_PATH + @icon; end
  def selectable?; return false; end
  def selected
    pbMessage(_INTL("This is a working Menu Entry for Voltseon's Pause Menu."))
  end
end

#-------------------------------------------------------------------------------
# Base class for defining a menu component
#-------------------------------------------------------------------------------
class Component
  attr_accessor :viewport
  attr_accessor :sprites

  def startComponent(viewport)
    @viewport = viewport
    @sprites = {}
  end

  # To be defined by user
  def shouldDraw?; return false; end
  def refresh; end

  def update; pbUpdateSpriteHash(@sprites); end
  def dispose; pbDisposeSpriteHash(@sprites); end
end

#-------------------------------------------------------------------------------
# Main Pause Menu class
#-------------------------------------------------------------------------------
class VoltseonsPauseMenu_Scene
  attr_accessor :shouldExit
  attr_accessor :shouldRefresh

  def initialize
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @sprites = {}
    # Background
    @sprites["backshade"] = Sprite.new(@viewport)
    @sprites["backshade"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @sprites["backshade"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,BACKGROUND_TINT)
    @sprites["backshade"].z = -10
    # Location window
    @sprites["location"] = Sprite.new(@viewport)
    # Menu arrows
    if pbResolveBitmap(MENU_FILE_PATH + "Backgrounds/arrow_left_#{$PokemonSystem.current_menu_theme}")
      filename = MENU_FILE_PATH + "Backgrounds/arrow_left_#{$PokemonSystem.current_menu_theme}"
    else
      filename = MENU_FILE_PATH + "Backgrounds/arrow_left_#{DEFAULT_MENU_THEME}"
    end
    @sprites["leftarrow"] = AnimatedSprite.new(filename,8,40,28,2,@viewport)
    @sprites["leftarrow"].x       = Graphics.width/2 - @sprites["leftarrow"].bitmap.width - ($PokemonTemp.menu_icon_width/4 * 3)
    @sprites["leftarrow"].y       = Graphics.height - 56
    @sprites["leftarrow"].z       = 2
    @sprites["leftarrow"].visible = true
    @sprites["leftarrow"].play
    if pbResolveBitmap(MENU_FILE_PATH + "Backgrounds/arrow_right_#{$PokemonSystem.current_menu_theme}")
      filename = MENU_FILE_PATH + "Backgrounds/arrow_right_#{$PokemonSystem.current_menu_theme}"
    else
      filename = MENU_FILE_PATH + "Backgrounds/arrow_right_#{DEFAULT_MENU_THEME}"
    end
    @sprites["rightarrow"] = AnimatedSprite.new(filename,8,40,28,2,@viewport)
    @sprites["rightarrow"].x       = Graphics.width/2 + ($PokemonTemp.menu_icon_width/4 * 3)
    @sprites["rightarrow"].y       = Graphics.height - 56
    @sprites["rightarrow"].z       = 2
    @sprites["rightarrow"].visible = true
    @sprites["rightarrow"].play
    # Helpful Variables
    @shouldExit = false
    @shouldRefresh = true
    @hidden = false
    $PokemonTemp.menu_theme_changed = false
  end

  def pbStartScene
    @viewport.z = 99999
    @components = []
    @componentNames = []
    MENU_COMPONENTS.each do |c|
      next if c[/VoltseonsPauseMenu/i]
      component = Object.const_get(c).new
      @components.push(component) if component.shouldDraw?
      @componentNames.push(c)
    end
    @components.each do |component|
      component.startComponent(@viewport)
    end
    @pauseMenu = VoltseonsPauseMenu.new
    @pauseMenu.startComponent(@viewport, @sprites, self)
    pbSEPlay(MENU_OPEN_SOUND)
    pbRefresh
    @pauseMenu.refreshMenu
    pbShowMenu
  end

  def pbHideMenu
    duration = Graphics.frame_rate/6
    duration.times do
      @sprites.each do |key,sprite|
        if key[/backshade/]
          sprite.opacity -= (255/duration)
          sprite.opacity.clamp(0,255)
        elsif key[/location/]
          sprite.x -= (sprite.bitmap.width/duration)
        elsif sprite.y >= (Graphics.height/2)
          sprite.y += ((Graphics.height/2)/duration)
        else
          sprite.y -= ((Graphics.height/2)/duration)
        end
      end
      @components.each do |component|
        sprites = component.sprites
        sprites.each do |_,sprite|
          if sprite.y >= (Graphics.height/2)
            sprite.y += ((Graphics.height/2)/duration)
          else
            sprite.y -= ((Graphics.height/2)/duration)
          end
        end
      end
      Graphics.update
    end
    @hidden = true
  end

  def pbShowMenu
    xvals = {}
    yvals = {}
    if !@hidden
      xvals[:main] = {}
      yvals[:main] = {}
      @componentNames.each do |component|
        xvals[component] = {}
        yvals[component] = {}
      end
      @sprites.each do |key,sprite|
        xvals[:main][key] = sprite.x
        yvals[:main][key] = sprite.y
        if key[/backshade/]
          sprite.opacity = 0
        elsif key[/location/]
          sprite.x -= sprite.bitmap.width
        elsif sprite.y >= (Graphics.height/2)
          sprite.y += (Graphics.height/2)
        else
          sprite.y -= (Graphics.height/2)
        end
      end
      @components.each_with_index do |component,i|
        sprites = component.sprites
        cname = @componentNames[i]
        sprites.each do |key,sprite|
          xvals[cname][key] = sprite.x
          yvals[cname][key] = sprite.y
          if sprite.y >= (Graphics.height/2)
            sprite.y += (Graphics.height/2)
          else
            sprite.y -= (Graphics.height/2)
          end
        end
      end
    end
    duration = Graphics.frame_rate/6
    duration.times do
      @sprites.each do |key,sprite|
        if key[/backshade/]
          sprite.opacity += (255/duration)
          sprite.opacity.clamp(0,255)
        elsif key[/location/]
          sprite.x += (sprite.bitmap.width/duration)
        elsif sprite.y >= (Graphics.height/2)
          sprite.y -= ((Graphics.height/2)/duration)
        else
          sprite.y += ((Graphics.height/2)/duration)
        end
      end
      @components.each do |component|
        sprites = component.sprites
        sprites.each do |_,sprite|
          if sprite.y >= (Graphics.height/2)
            sprite.y -= ((Graphics.height/2)/duration)
          else
            sprite.y += ((Graphics.height/2)/duration)
          end
        end
      end
      Graphics.update
    end
    if !@hidden
      @sprites.each do |key,sprite|
        @sprites[key].x = xvals[:main][key]
        @sprites[key].y = yvals[:main][key]
      end
      @components.each_with_index do |component,i|
        cname = @componentNames[i]
        sprites = component.sprites
        sprites.each do |key,sprite|
          sprites[key].x = xvals[cname][key]
          sprites[key].y = yvals[cname][key]
        end
      end
    end
    @hidden = false
  end

  def update
    @hasTerminated = false
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      @pauseMenu.update {
        @components.each do |component|
          component.update
        end
      }
      return if @hasTerminated # If pbEndScene was already called, don't call it again.
      pbRefresh if @shouldRefresh
      @components.each do |component|
        component.update
      end
      pbUpdateSceneMap
      if @shouldExit
        pbEndScene
        break
      end
    end
  end

  def pbRefresh
    return if @shouldExit
    # Refresh the location text
    @sprites["location"].bitmap.clear if @sprites["location"].bitmap
    if pbResolveBitmap(MENU_FILE_PATH + "Backgrounds/bg_location_#{$PokemonSystem.current_menu_theme}")
      filename = MENU_FILE_PATH + "Backgrounds/bg_location_#{$PokemonSystem.current_menu_theme}"
    else
      filename = MENU_FILE_PATH + "Backgrounds/bg_location_#{DEFAULT_MENU_THEME}"
    end
    @sprites["location"].bitmap = Bitmap.new(filename)
    mapname = $game_map.name
    baseColor = LOCATION_TEXTCOLOR[$PokemonSystem.current_menu_theme].is_a?(Color) ? LOCATION_TEXTCOLOR[$PokemonSystem.current_menu_theme] : Color.new(248,248,248)
    shadowColor = LOCATION_TEXTOUTLINE[$PokemonSystem.current_menu_theme].is_a?(Color) ? LOCATION_TEXTOUTLINE[$PokemonSystem.current_menu_theme] : Color.new(48,48,48)
    xOffset = @sprites["location"].bitmap.width - 64
    pbSetSystemFont(@sprites["location"].bitmap)
    pbDrawTextPositions(@sprites["location"].bitmap,[["#{$game_map.name}",xOffset,4,1,baseColor,shadowColor,true]])
    @sprites["location"].x = -@sprites["location"].bitmap.width + (@sprites["location"].bitmap.text_size($game_map.name).width + 64 + 32)
    @components.each do |component|
      component.refresh
    end
    @shouldRefresh = false
  end

  def pbEndScene
    if !@hidden
      pbSEPlay(MENU_CLOSE_SOUND)
      pbHideMenu
    end
    $game_temp.in_menu = false
    @hasTerminated = true
    @pauseMenu.dispose
    @components.each do |component|
      component.dispose
    end
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#-------------------------------------------------------------------------------
# Overriding the default Pause Menu Screen calls
#-------------------------------------------------------------------------------
class Scene_Map
  def call_menu
    $game_temp.menu_calling = false
    $game_temp.in_menu = true
    $game_player.straighten
    $game_map.update
    if safeExists?(MENU_FILE_PATH) && safeExists?(MENU_FILE_PATH + "Backgrounds/")
      sscene = VoltseonsPauseMenu_Scene.new
    else
      if !$PokemonTemp.menu_warining_done
        pbMessage("Current MENU_FILE_PATH defined for Voltseon's Pause Menu is #{MENU_FILE_PATH}")
        pbMessage("This directory does not exist in your game folder.")
        pbMessage("To rectify this, open the 001_VoltseonMenu_Config.rb using the text editor of your choice, and edit the MENU_FILE_PATH you see there.")
        pbMessage("Opening default pause menu as a failsafe...")
        $PokemonTemp.menu_warining_done = true
      end
      sscene = PokemonPauseMenu_Scene.new
    end
    sscreen = PokemonPauseMenu.new(sscene)
    sscreen.pbStartPokemonMenu
    $game_temp.in_menu = false
  end
end

if safeExists?(MENU_FILE_PATH) && safeExists?(MENU_FILE_PATH + "Backgrounds/")
  class PokemonPauseMenu
    def pbStartPokemonMenu
      @scene.pbStartScene
      @scene.update
    end
  end
end

#-------------------------------------------------------------------------------
# Debug command to change menu themes
#-------------------------------------------------------------------------------
DebugMenuCommands.register("setmenutheme", {
  "parent"      => "playermenu",
  "name"        => _INTL("Set Menu Theme"),
  "description" => _INTL("Change the Menu Theme for Voltseon's Pause Menu..."),
  "effect"      => proc {
    maxval = 0
    loop do
      break if !pbResolveBitmap(MENU_FILE_PATH + "Backgrounds/bg_#{maxval}")
      maxval += 1
    end
    if maxval < 1
      pbMessage("There are no alternate themes to change to.")
      next
    end
    oldval = $PokemonSystem.current_menu_theme
    params = ChooseNumberParams.new
    maxval -= 1
    params.setRange(0, maxval)
    params.setDefaultValue($PokemonSystem.current_menu_theme)
    $PokemonSystem.current_menu_theme = pbMessageChooseNumber(_INTL("Set the menu theme. (0 - {1})", maxval), params)
    pbMessage(_INTL("The menu theme has been set to {1}.", $PokemonSystem.current_menu_theme))
    $PokemonTemp.menu_theme_changed = (oldval != $PokemonSystem.current_menu_theme)
  }
})

#-------------------------------------------------------------------------------
# Options command to change menu themes
#-------------------------------------------------------------------------------
class PokemonOption_Scene
  alias voltseonMenu_pbAddOnOptions pbAddOnOptions
  def pbAddOnOptions(options)
    if CHANGE_THEME_IN_OPTIONS
      maxval = 0
      oldval = $PokemonSystem.current_menu_theme
      loop do
        break if !pbResolveBitmap(MENU_FILE_PATH + "Backgrounds/bg_#{maxval}")
        maxval += 1
      end
      if maxval > 1
        options.push(NumberOption.new(_INTL("Menu Theme"), 1, maxval,
          proc { $PokemonSystem.current_menu_theme },
          proc { |value|
            $PokemonSystem.current_menu_theme = value
            $PokemonTemp.menu_theme_changed = (oldval != $PokemonSystem.current_menu_theme)
          }
        ))
      end
    end
    return voltseonMenu_pbAddOnOptions(options)
  end
end

#-------------------------------------------------------------------------------
# Attribute in PokemonSystem to save the current menu theme in the save file
#-------------------------------------------------------------------------------
class PokemonSystem
  attr_writer :current_menu_theme

  def current_menu_theme
    @current_menu_theme = DEFAULT_MENU_THEME if !@current_menu_theme
    return @current_menu_theme
  end
end

#-------------------------------------------------------------------------------
# Attribute in PokemonTemp to store the last selected  menu option
#-------------------------------------------------------------------------------
class PokemonTemp
  attr_accessor :last_menu_selection
  attr_accessor :menu_warining_done
  attr_accessor :menu_theme_changed
  attr_accessor :menu_icon_width

  def last_menu_selection
    @last_menu_selection = 0 if !@last_menu_selection
    return @last_menu_selection
  end

  def menu_icon_width
    if !@menu_icon_width
      width = 48
      if safeExists?(MENU_FILE_PATH + "menuDebug")
        bmp = RPG::Cache.load_bitmap(MENU_FILE_PATH + "menuDebug")
        width = bmp.width
        bmp.dispose
      end
      @menu_icon_width = width
    end
    return @menu_icon_width
  end
end

# The person reading this is very cool!
# Thanks (:
