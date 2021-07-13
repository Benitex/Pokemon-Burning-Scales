#===============================================================================
#  New animated and modular Title Screen for Pokemon Essentials
#    by Luka S.J.
#
#  ONLY FOR Essentials v19.x
# ----------------
#  Adds new visual styles to the Pokemon Essentials title screen, and animates
#  depending on the styles selected.
#
#  A lot of time and effort went into making this an extensive and comprehensive
#  resource. So please be kind enough to give credit when using it.
#===============================================================================
class Scene_Intro
  #-----------------------------------------------------------------------------
  # load the title screen
  #-----------------------------------------------------------------------------
  def main
    Graphics.transition(0)
    # refresh input
    Input.update
    # Loads up a species cry for the title screen
    species = ModularTitle::SPECIES
    species = species.upcase.to_sym if species.is_a?(String)
    species = GameData::Species.get(species).id
    @cry = species.nil? ? nil : GameData::Species.cry_filename(species, ModularTitle::SPECIES_FORM)
    # Cycles through the intro pictures
    @skip = false
    self.cyclePics
    # loads the modular title screen
    @screen = ModularTitleScreen.new
    # Plays defined title screen BGM
    @screen.playBGM
    # Plays the title screen intro (is skippable)
    @screen.intro
    # Creates/updates the main title screen loop
    self.update
    Graphics.freeze
  end
  #-----------------------------------------------------------------------------
  # main update loop
  #-----------------------------------------------------------------------------
  def update
    ret = 0
    loop do
      @screen.update
      Graphics.update
      Input.update
      if Input.press?(Input::DOWN) && Input.press?(Input::B) && Input.press?(Input::CTRL)
        ret = 1
        break
      end
      if Input.trigger?(Input::C) || (defined?($mouse) && $mouse.leftClick?)
        ret = 2
        break
      end
    end
    case ret
    when 1
      closeTitleDelete
    when 2
      closeTitle
    end
  end
  #-----------------------------------------------------------------------------
  # close title screen and dispose of elements
  #-----------------------------------------------------------------------------
  def closeTitle
    # Play Pokemon cry
    pbSEPlay(@cry, 100, 100) if @cry
    # Fade out
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes load screen
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end
  #-----------------------------------------------------------------------------
  # close title screen when save delete
  #-----------------------------------------------------------------------------
  def closeTitleDelete
    pbBGMStop(1.0)
    # disposes current title screen
    disposeTitle
    # initializes delete screen
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end
  #-----------------------------------------------------------------------------
  # cycle splash images
  #-----------------------------------------------------------------------------
  def cyclePics
    pics = IntroEventScene::SPLASH_IMAGES
    frames = (Graphics.frame_rate * (IntroEventScene::FADE_TICKS/20.0)).ceil
    sprite = Sprite.new
    sprite.opacity = 0
    for i in 0...pics.length
      bitmap = pbBitmap("Graphics/Titles/#{pics[i]}")
      sprite.bitmap = bitmap
      frames.times do
        sprite.opacity += 255.0/frames
        pbWait(1)
      end
      pbWait((IntroEventScene::SECONDS_PER_SPLASH * Graphics.frame_rate).ceil)
      frames.times do
        sprite.opacity -= 255.0/frames
        pbWait(1)
      end
    end
    sprite.dispose
  end
  #-----------------------------------------------------------------------------
  # dispose of title screen
  #-----------------------------------------------------------------------------
  def disposeTitle
    @screen.dispose
  end
  #-----------------------------------------------------------------------------
  # wait command (skippable)
  #-----------------------------------------------------------------------------
  def wait(frames = 1, advance = true)
    return false if @skip
    frames.times do
      Graphics.update
      Input.update
      @skip = true if Input.trigger?(Input::C)
    end
    return true
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  sprite compatibility
#===============================================================================
class Sprite
  attr_accessor :id
end
#===============================================================================
#  title call override
#===============================================================================
def pbCallTitle
  return Scene_DebugIntro.new if $DEBUG && !ModularTitle::SHOW_IN_DEBUG
  return Scene_Intro.new
end
