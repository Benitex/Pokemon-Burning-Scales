#===============================================================================
#  Scene override for Safari Zone visuals
#===============================================================================
class PokeBattle_Scene
  attr_reader :scene
  #-----------------------------------------------------------------------------
  #  Safari Zone visuals
  #-----------------------------------------------------------------------------
  def pbSafariStart
    @briefmessage = false
    @sprites["dataBox_0"] = SafariDataBoxEBDX.new(@battle, @msgview)
    @sprites["dataBox_0"].x = @viewport.width + 10 + @sprites["dataBox_0"].width%10
    @sprites["dataBox_0"].y = @viewport.height - 180
    @sprites["dataBox_0"].appear
    11.times do
      @sprites["dataBox_0"].x -= @sprites["dataBox_0"].width/10
      self.wait
    end
    pbRefresh
  end
  #-----------------------------------------------------------------------------
  #  Safari command menu
  #-----------------------------------------------------------------------------
  alias pbSafariCommandMenu_ebdx pbSafariCommandMenu unless self.method_defined?(:pbSafariCommandMenu_ebdx)
  def pbSafariCommandMenu(index)
    @orgPos = [@vector.x, @vector.y, @vector.angle, @vector.scale, @vector.zoom1] if @orgPos.nil?
    cmd = pbSafariCommandMenu_ebdx(index)
    @idleTimer = -1
    @vector.reset
    @vector.inc = 0.2
    return cmd
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Safari Zone compatibility
#===============================================================================
class PokeBattle_SafariZone
  attr_accessor :opponents, :players, :scene, :battlescene
  alias initialize_ebdx initialize unless self.method_defined?(:initialize_ebdx)
  def initialize(*args)
    args[0].safaribattle = true
    @battlescene = true
    @maxSize = args[2].length
    initialize_ebdx(*args)
  end
  def doublebattle?; return (@maxSize > 1); end
  def triplebattle?; return (@maxSize > 2); end
  def pbMaxSize(index = nil); return @maxSize; end
  def pbWeather; return self.weather; end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Throw Bait animation compatibility
#===============================================================================
class ThrowBaitAnimation < PokeBattle_Animation
  include PokeBattle_BallAnimationMixin
  #-----------------------------------------------------------------------------
  #  initialization
  #-----------------------------------------------------------------------------
  def initialize(sprites, viewport, battler)
    @battler = battler
    @trainer = battler.battle.pbGetOwnerFromBattlerIndex(battler.index)
    super(sprites, viewport)
  end
  #-----------------------------------------------------------------------------
  #  compatibility for PictureEX
  #-----------------------------------------------------------------------------
  def addSprite(s)
    num = @pictureEx.length
    picture = PictureEx.new(s.z)
    picture.x       = s.x
    picture.y       = s.y
    picture.visible = s.visible
    picture.tone    = s.tone.clone
    @pictureEx[num] = picture
    @pictureSprites[num] = s
    return picture
  end
  #-----------------------------------------------------------------------------
  #  create animation process
  #-----------------------------------------------------------------------------
  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    traSprite = @sprites["player_0"]
    ballPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index, batSprite.sideSize)
    ballStartX = traSprite.x + traSprite.src_rect.width/2
    ballStartY = traSprite.y + 48
    ballMidX   = 0   # Unused in arc calculation
    ballMidY   = 122
    ballEndX   = ballPos[0] - 40
    ballEndY   = ballPos[1] - 4
    # Set up bait sprite
    ball = addNewSprite(ballStartX, ballStartY,
       "Graphics/Battle animations/safari_bait", PictureOrigin::Center)
    ball.setZ(0, batSprite.z + 1)
    delay = ball.totalDuration   # 0 or 7
    # Bait arc animation
    ball.setSE(delay, "Battle throw")
    createBallTrajectory(ball, delay, 12,
       ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    ball.setZ(9, batSprite.z + 1)
    delay = ball.totalDuration
    ball.moveOpacity(delay + 8, 2, 0)
    ball.setVisible(delay + 10, false)
    # Set up battler sprite
    battler = addSprite(batSprite)
    # Show Pokémon jumping before eating the bait
    delay = ball.totalDuration + 3
    2.times do
      battler.setSE(delay, "player jump")
      battler.moveDelta(delay, 3, 0, -16)
      battler.moveDelta(delay + 4, 3, 0, 16)
      delay = battler.totalDuration + 1
    end
    # Show Pokémon eating the bait
    delay = battler.totalDuration + 3
    2.times do
      battler.moveAngle(delay, 7, 5)
      battler.moveAngle(delay + 7, 7, 0)
      delay = battler.totalDuration
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Throw Rock animation compatibility
#===============================================================================
class ThrowRockAnimation < PokeBattle_Animation
  include PokeBattle_BallAnimationMixin
  #-----------------------------------------------------------------------------
  #  initialization
  #-----------------------------------------------------------------------------
  def initialize(sprites, viewport, battler)
    @battler = battler
    @trainer = battler.battle.pbGetOwnerFromBattlerIndex(battler.index)
    super(sprites, viewport)
  end
  #-----------------------------------------------------------------------------
  #  create animation process
  #-----------------------------------------------------------------------------
  def createProcesses
    # Calculate start and end coordinates for battler sprite movement
    batSprite = @sprites["pokemon_#{@battler.index}"]
    traSprite = @sprites["player_0"]
    ballStartX = traSprite.x + traSprite.src_rect.width/2
    ballStartY = traSprite.y + 48
    ballMidX   = 0   # Unused in arc calculation
    ballMidY   = 122
    ballEndX   = batSprite.x
    ballEndY   = batSprite.y - batSprite.bitmap.height/2
    # Set up bait sprite
    ball = addNewSprite(ballStartX, ballStartY,
       "Graphics/Battle animations/safari_rock", PictureOrigin::Center)
    ball.setZ(0, batSprite.z + 1)
    delay = ball.totalDuration   # 0 or 7
    # Bait arc animation
    ball.setSE(delay, "Battle throw")
    createBallTrajectory(ball, delay, 12,
       ballStartX, ballStartY, ballMidX, ballMidY, ballEndX, ballEndY)
    ball.setZ(9, batSprite.z + 1)
    delay = ball.totalDuration
    ball.setSE(delay,"Battle damage weak")
    ball.moveOpacity(delay + 2, 2, 0)
    ball.setVisible(delay + 4, false)
    # Set up anger sprite
    anger = addNewSprite(ballEndX - 42, ballEndY - 36,
       "Graphics/Battle animations/safari_anger", PictureOrigin::Center)
    anger.setVisible(0, false)
    anger.setZ(0, batSprite.z + 1)
    # Show anger appearing
    delay = ball.totalDuration+5
    2.times do
      anger.setSE(delay, "Player jump")
      anger.setVisible(delay, true)
      anger.moveZoom(delay, 3, 130)
      anger.moveZoom(delay + 3, 3, 100)
      anger.setVisible(delay + 6, false)
      anger.setDelta(delay + 6, 96, -16)
      delay = anger.totalDuration + 3
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Safari Zone battler compatibility
#===============================================================================
class PokeBattle_FakeBattler
  #-----------------------------------------------------------------------------
  #  get Pokemon object
  #-----------------------------------------------------------------------------
  def displayPokemon
    return self.pokemon
  end
  #-----------------------------------------------------------------------------
  #  get Pokemon form
  #-----------------------------------------------------------------------------
  def form
    return self.pokemon.form
  end
  #-----------------------------------------------------------------------------
  #  get species
  #-----------------------------------------------------------------------------
  def displaySpecies
    return self.species
  end
  #-----------------------------------------------------------------------------
  #  get gender
  #-----------------------------------------------------------------------------
  def displayGender
    return self.gender
  end
  #-----------------------------------------------------------------------------
  #  get form
  #-----------------------------------------------------------------------------
  def displayForm
    return self.form
  end
  #-----------------------------------------------------------------------------
  #  check if super shiny
  #-----------------------------------------------------------------------------
  def superShiny?
    return self.pokemon && self.pokemon.superShiny?
  end
  #-----------------------------------------------------------------------------
end
