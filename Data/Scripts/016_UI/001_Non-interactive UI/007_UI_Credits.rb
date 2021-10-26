#==============================================================================
# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre. Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5. Music can
# now be defined. Credits can't be skipped during their first play.
#
## New Edit 25/3/2020 by Maruno.
# Scroll speed is now independent of frame rate. Now supports non-integer values
# for SCROLL_SPEED.
#
## New Edit 21/8/2020 by Marin.
# Now automatically inserts the credits from the plugins that have been
# registered through the PluginManager module.
#==============================================================================
class Scene_Credits
  # Backgrounds to show in credits. Found in Graphics/Titles/ folder
  BACKGROUNDS_LIST       = ["credits5","credits4","credits1"]
  BGM                    = "Credits"
  SCROLL_SPEED           = 40   # Pixels per second
  SECONDS_PER_BACKGROUND = 11
  TEXT_OUTLINE_COLOR     = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR        = Color.new(255, 255, 255, 255)
  TEXT_SHADOW_COLOR      = Color.new(0, 0, 0, 100)

  # This next piece of code is the credits.
  # Start Editing
  CREDIT = <<_END_

Pokemon Burning Scales





Criado por Benito André Pepe, aka Benitex



Agradecimentos especiais:

Agradeço a Shirou Douglas por ensinar
o básico de pokemon essentials.

E a Thundaga, que também inspirou vários recursos 
jogo e presta muitos serviços a comunidade de
fan games pokemon pelo mundo a fora.



Esse jogos foi feito utilizando recursos de:


Autores de gráficos:

Tilesets:

Interiores:
4th gen Indoor Tileset - Akizakura16

Exteriores:
WesleyFG:
BW BUILDINGS TILESET
BW NATURE TILESET
HGSS TILISET MY WORK COMPLETE

Com complementos de:
dirtywiggles - Interior tileset Primal
zetavares852 - Pokemon Gaia Project Tileset 1 (trees)
KingTapir - Sandstream Desert Tileset


Character Customization Resources
Poltergeist

Custom-made Official Gen 4 Day & Night Tones 
VanillaSunshine

Gen 4 OW Sprites by:
Neo-Spriteman
Vanilla Sunshine
PurpleZaffre & Maicerochico
AtomicReactor

Gen 5 Characters in Gen 4 OW style
DiegoWT

Gen 4 and 5 Trainer sprites:
Mr. Gela/theo#7722

Team Plasma Grunt OW(male and female)
PurpleZaffre

Team Plasma battle sprites
xxxSnow

Team Plasma grunt with Articuno wings
Kobi2604

Shadow Trial trainer sprites
Skeizerr

Gen 8 Project:

Battler Sprites:
Gen 1-5 Pokemon Sprites      - veekun
Gen 6 Pokemon Sprites        - All Contributors To Smogon X/Y Sprite Project
Gen 7 Pokemon Sprites        - All Contributors To Smogon Sun/Moon Sprite Project
Gen 8 Pokemon Sprites        - All Contributors To Smogon  Sword/Shield Sprite Project

Overworld Sprites
Gen 1-5 Pokemon Overworlds:
MissingLukey, help-14, Kymoyonian, cSc-A7X, 2and2makes5, Pokegirl4ever, 
Fernandojl, Silver-Skies, TyranitarDark, Getsuei-H, Kid1513, Milomilotic11, Kyt666, kdiamo11, Chocosrawlooid, 
Syledude, Gallanty, Gizamimi-Pichu, 2and2makes5, Zyon17,LarryTurbo, spritesstealer
Gen 6 Pokemon Overworlds     - princess-pheonix, LunarDusk, Wolfang62, TintjeMadelintje101, piphybuilder88
Gen 7 Pokemon Overworlds     - Larry Turbo, princess-pheonix
Gen 8 Pokemon Overworlds     - SageDeoxys, Wolfang62

Icon Sprites
Gen 1-6 Pokemon Icon Sprites - Alaguesia
Gen 7 Pokemon Icon Sprites   - Marin, MapleBranchWing, Contributors to the DS Styled Gen 7+ Repository
Gen 8 Icon Sprites           - Larry Turbo, Leparagon

Cry Credits:
Gen 1-6 Pokemon Cries        - Rhyden
Gen 7 Pokemon Cries          - Marin, Rhyden
Gen 8 Pokemon Cries          - Zeak6464

PBS Credits:
Golisopod User, Zerokid, TheToxic, HM100, KyureJL, ErwanBeurier

ORAS/XY themed battle backgrounds for EBDX
PhoenixOfLight92 for ripping the Gen 6 battlebacks
LackDeJurane for the combined battlebacks

Script Credits:
EBS Bitmap Wrapper - Luka S.J.
Gen 8 Scripts      - Golisopod User, Maruno, Vendily, TheToxic, HM100, Aioross, WolfPP, MFilice, lolface, KyureJL, DarrylBD99, Turn20Negate, TheKandinavian, ErwanBeurier

Compilation of Resources
Golisopod User, UberDunsparce

Porting to v19
Golisopod User


Autores das músicas:

Credits scene:
Marnie’s Theme - Raushna ft. ebee

Mewmore
Route 225 DP – Intro theme
Gladion – Anna's Theme
Boutique XY – Many Nimbasa buildings
Professor Sycamore’s Theme – Desert Resort Entrance
Relic Castle – Relic Castle B2
Lookers Theme – Search for the girl questline
Unwavering Emotions - Storyteller theme

GlitchxCity
Rival Bede – Nimbasa trainers
Snowbelle City – Volcarona Theme
Team Rocket Battle Remix vII - Giovanni theme
Lusamine Battle Remix - Plasma boss battle
Team Plasma Remix - Plasma intelligence battle

Vanilluxe Pavilion
Relic Castle – Relic Castle B3
Po Town - Bikers theme
Mt. Coronet Remix - Caves

Zame
Relic castle - Relic castle B1 floor
Pokemon Center Unova - Pokémon Centers
Castelia City Nighttime - Castelia City
Vast Poni Canyon - Route 4 wild battle
Relic Song - Burning Scales theme
Nimbasa City Gym (Stage) - Nimbasa City Gym pos Elesa
Gate Remastered - Route gates

Kamex
Nimbasa City Jazz Remix - Nimbasa city
Vs. Guzma Remix - Bikers fake leader theme
Vs Lusamine - Plasma boss battle

Raushna
Shopping Mall - Robert Theme
Battle! Champion Lillie - Tournament oponnents
Marnie’s Theme ft. ebee – Credits

Vetrom
Battle Marnie – Bikers and cueballs
Battle! Battle Tower – Musical Theater during the tournament
Battle! Gym Leader Black and White - Gym battles

RetroSpecter
Battle Gladion – Anna's battle theme
Vs champion Diantha - Route 4 trainer battle

Falkonkke
Fur Elise - Beethoven battle

Kunning Fox
Victory is Right Before Your Eyes! - Title Screen
Juniper Pokémon Lab from 'Back to Unova' - Juniper Lab

Seii
Route 111 RSE – Desert Resort theme

Snivys
Join avenue “You’re invited” - Join Avenue

Blue Claw Philharmonic
Ode to Joy (Lofi Hiphop Remix) - Beethoven's house

MarshMix Plaza
Battle vs. Marnie Remix - Bikers leader theme

EuroMIX2
Nimbasa Gym (Give Me What I Need mix) - Nimbasa Gym pre Elesa

John Ferrie Music
Professor Oaks Lab Theme - Oak's Lab first time

Sheddy
Forbidden Melody (Relic Song Remix by sheddy) - Meloetta battle theme

Deplode
Pokemon Relic Song with violins - Meloetta encounter

Pokémon X & Y
Poké Mart Shopping - Route 4

Monster Hunter Rise
Sandy Plains Domain of Dust and Desolation - Desert Resort wild battle


Plugins

Elite Battle: DX - Luka S.J.,Maruno,Marin,Pokecheck.org,PinkCatDragon,Tebited15,BadSamaritan,WolfPP,redblueyellow,Damien,Issei Hyoudou,Nasasu,luckygirl88
Following Pokemon EX - Golisopod User, Help-14, zingzags, Rayd12smitty, Venom12, mej71, PurpleZaffre, Akizakura16, Thundaga, Amrin (Fairies Resource Pack)
Modular Title Screen - Luka S.J.
Voltseon's Pause Menu - Voltseon, Golisopod User, ENLS
Modern Quest System + UI - ThatWelshOne_,mej71,derFischae,Marin
Overworld Shadows EX - Golisopod User, Wolf PP, Marin
Random Pokemon Selector - ThatWelshOne_
Encounter List UI (v19) - ThatWelshOne_,raZ,Marin,Maruno,Nuri Yuri,PurpleZaffre,Savordez,Vendily
B2W2 Bag - Erassus,CharizardThree3/LackDeJurane
BW Party Screen - DeepBlue PacificWaves,Shashu-Greninja, Golisopod User
Pokedex BW Style - DeepBlue PacificWaves, NettoHikari, Xtreme1992
Storage System BW Style - DeepBlue PacificWaves
BW Summary Screen - DeepBlue PacificWaves, Tommaniacal, Lucidious89, Weibrot, Kobi2604, Dirkriptide, Ploaj, Mr. Gela, Shashu-Greninja, Golisopod User
BW Location Signposts - Shashu-Greninja,DeepBlue PacificWaves,Shiney570
BW Text Entry Scene - Shashu-Greninja,DeepBlue PacificWaves,Erassus
v19.1 Hotfixes - Maruno


{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}

"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>Marin
Boushy<s>MiDas Mike
Brother1440<s>Near Fantastica
FL.<s>PinkMan
Genzai Kawakami<s>Popper
Golisopod User<s>Rataime
help-14<s>Savordez
IceGod64<s>SoundSpawn
Jacob O. Wobbrock<s>the__end
KitsuneKouta<s>Venom12
Lisa Anthony<s>Wachunga
Luka S.J.<s> 
and everyone else who helped out

"mkxp-z" by:
Roza
Based on MKXP by Ancurio et al.

"RPG Maker XP" by:
Enterbrain

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak



This is a non-profit fan-made game.
No copyright infringements intended.
Please support the official games!

_END_
# Stop Editing

  def main
    #-------------------------------
    # Animated Background Setup
    #-------------------------------
    @counter = 0.0   # Counts time elapsed since the background image changed
    @bg_index = 0
    @bitmap_height = Graphics.height   # For a single credits text bitmap
    @trim = Graphics.height / 10
    # Number of game frames per background frame
    @realOY = -(Graphics.height - @trim)
    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << pcred[0] + "\n"
        i = 1
        until i >= pcred.size
          plugin_credits << pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n"
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << name + "\n" }
      end
      plugin_credits << "\n"
    end
    CREDIT.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
    credit_lines = CREDIT.split(/\n/)
    #-------------------------------
    # Make background and text sprites
    #-------------------------------
    text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
    text_viewport.z = 99999
    @background_sprite = IconSprite.new(0, 0)
    @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[0])
    @credit_sprites = []
    @total_height = credit_lines.size * 32
    lines_per_bitmap = @bitmap_height / 32
    num_bitmaps = (credit_lines.size.to_f / lines_per_bitmap).ceil
    for i in 0...num_bitmaps
      credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height)
      pbSetSystemFont(credit_bitmap)
      for j in 0...lines_per_bitmap
        line = credit_lines[i * lines_per_bitmap + j]
        next if !line
        line = line.split("<s>")
        xpos = 0
        align = 1   # Centre align
        linewidth = Graphics.width
        for k in 0...line.length
          if line.length > 1
            xpos = (k == 0) ? 0 : 20 + Graphics.width / 2
            align = (k == 0) ? 2 : 0   # Right align : left align
            linewidth = Graphics.width / 2 - 20
          end
          credit_bitmap.font.color = TEXT_SHADOW_COLOR
          credit_bitmap.draw_text(xpos,     j * 32 + 8, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_OUTLINE_COLOR
          credit_bitmap.draw_text(xpos + 2, j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, j * 32,     linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32,     linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_BASE_COLOR
          credit_bitmap.draw_text(xpos,     j * 32,     linewidth, 32, line[k], align)
        end
      end
      credit_sprite = Sprite.new(text_viewport)
      credit_sprite.bitmap = credit_bitmap
      credit_sprite.z      = 9998
      credit_sprite.oy     = @realOY - @bitmap_height * i
      @credit_sprites[i] = credit_sprite
    end
    #-------------------------------
    # Setup
    #-------------------------------
    # Stops all audio but background music
    previousBGM = $game_system.getPlayingBGM
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    pbBGMPlay(BGM)
    Graphics.transition(20)
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    pbBGMFade(2.0)
    Graphics.freeze
    Graphics.transition(20, "fadetoblack")
    @background_sprite.dispose
    @credit_sprites.each { |s| s.dispose if s }
    text_viewport.dispose
    $PokemonGlobal.creditsPlayed = true
    pbBGMPlay(previousBGM)
  end

  # Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::USE) && $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
      pbBGMFade(1.0)
      return true
    end
    return false
  end

  # Checks if credits bitmap has reached its ending point
  def last?
    if @realOY > @total_height + @trim
      $scene = ($game_map) ? Scene_Map.new : nil
      pbBGMFade(2.0)
      return true
    end
    return false
  end

  def update
    delta = Graphics.delta_s
    @counter += delta
    # Go to next slide
    if @counter >= SECONDS_PER_BACKGROUND
      @counter -= SECONDS_PER_BACKGROUND
      @bg_index += 1
      @bg_index = 0 if @bg_index >= BACKGROUNDS_LIST.length
      @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[@bg_index])
    end
    return if cancel?
    return if last?
    @realOY += SCROLL_SPEED * delta
    @credit_sprites.each_with_index { |s, i| s.oy = @realOY - @bitmap_height * i }
  end
end
