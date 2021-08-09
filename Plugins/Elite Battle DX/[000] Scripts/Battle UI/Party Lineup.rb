#===============================================================================
#  Class to handle the construction and animation of opposing and player
#  party indicators
#===============================================================================
class PartyLineupEBDX
  attr_reader :loaded
  attr_accessor :toggle
  #-----------------------------------------------------------------------------
  #  class constructor
  #-----------------------------------------------------------------------------
  def initialize(viewport, scene, battle, side)
    @viewport = viewport
    @scene = scene
    @sprites = @scene.sprites
    @battle = battle
    @side = side
    @num = PokeBattle_SceneConstants::NUM_BALLS
    # is the animation appearing or not
    @toggle = true
    @loaded = false
    @disposed = false
    # cache bitmaps
    @partyBar = pbBitmap("Graphics/EBDX/Pictures/UI/partyBar")
    @partyBalls = pbBitmap("Graphics/EBDX/Pictures/UI/partyBalls")
    # draw main line up bar
    @sprites["partyLine_#{@side}"] = Sprite.new(@viewport)
    @sprites["partyLine_#{@side}"].z = 99999
    # draw individual party indicators
    for k in 0...@num
      @sprites["partyLine_#{@side}_#{k}"] = Sprite.new(@viewport)
      @sprites["partyLine_#{@side}_#{k}"].z = 99999
    end
  end
  #-----------------------------------------------------------------------------
  #  refresh both graphics and animation parameters
  #-----------------------------------------------------------------------------
  def refresh
    @toggle = true
    # get party details
    pty = self.party; pty.reverse! if (@side%2 == 1)
    # assign graphic ands position party line
    @sprites["partyLine_#{@side}"].bitmap = @partyBar.clone
    @sprites["partyLine_#{@side}"].mirror = (@side%2 == 0)
    @sprites["partyLine_#{@side}"].ox = @side%2 == 0 ? @partyBar.width : 0
    @sprites["partyLine_#{@side}"].opacity = 255
    @sprites["partyLine_#{@side}"].zoom_x = 1
    # position party balls relative to main party line up
    for k in 0...@num
      @sprites["partyLine_#{@side}_#{k}"].bitmap = Bitmap.new(@partyBalls.height, @partyBalls.height)
      # select the appropriate party line up ball graphic
      if pty[k].nil?
        pin = 3
      elsif pty[k].hp < 1 || pty[k].egg?
        pin = 2
      elsif GameData::Status.get(pty[k].status).id_number > 0
        pin = 1
      else
        pin = 0
      end
      # render ball graphic
      @sprites["partyLine_#{@side}_#{k}"].bitmap.blt(0, 0, @partyBalls, Rect.new(@partyBalls.height*pin, 0, @partyBalls.height, @partyBalls.height))
      @sprites["partyLine_#{@side}_#{k}"].center!
      @sprites["partyLine_#{@side}_#{k}"].ex = (@side%2 == 0 ? 26 : 12) + 24*k + @sprites["partyLine_#{@side}_#{k}"].ox
      @sprites["partyLine_#{@side}_#{k}"].ey = -12 + @sprites["partyLine_#{@side}_#{k}"].oy
      @sprites["partyLine_#{@side}_#{k}"].opacity = 255
      @sprites["partyLine_#{@side}_#{k}"].angle = 0
    end
    # position full line up graphics
    self.x = @side%2 == 0 ? (@viewport.width + @partyBar.width + 10) : (-@partyBar.width - 10)
    mult = (EliteBattle::USE_FOLLOWER_EXCEPTION && EliteBattle.follower(@battle).nil?) ? 0.65 : 0.5
    self.y = @side%2 == 0 ? @viewport.height*mult : @viewport.height*0.3
    # register as loaded
    @loaded = true
  end
  #-----------------------------------------------------------------------------
  #  set X value
  #-----------------------------------------------------------------------------
  def x=(val)
    @sprites["partyLine_#{@side}"].x = val
    for k in 0...@num
      @sprites["partyLine_#{@side}_#{k}"].x = @sprites["partyLine_#{@side}"].x + @sprites["partyLine_#{@side}_#{k}"].ex - @sprites["partyLine_#{@side}"].ox
    end
  end
  #-----------------------------------------------------------------------------
  #  set Y value
  #-----------------------------------------------------------------------------
  def y=(val)
    @sprites["partyLine_#{@side}"].y = val
    for k in 0...@num
      @sprites["partyLine_#{@side}_#{k}"].y = @sprites["partyLine_#{@side}"].y + @sprites["partyLine_#{@side}_#{k}"].ey
    end
  end
  #-----------------------------------------------------------------------------
  #  get X, Y values of party line up
  #-----------------------------------------------------------------------------
  def x; return @sprites["partyLine_#{@side}"].x; end
  def y; return @sprites["partyLine_#{@side}"].y; end
  #-----------------------------------------------------------------------------
  #  get the end X position
  #-----------------------------------------------------------------------------
  def end_x
    return @side%2 == 0 ? @viewport.width + 10 : -10
  end
  #-----------------------------------------------------------------------------
  #  check if animation has yet to be completed
  #-----------------------------------------------------------------------------
  def animating?
    return false if !@loaded
    return @side%2 == 0 ? (self.x > self.end_x) : (self.x < self.end_x) if @toggle
    return @sprites["partyLine_#{@side}"].opacity > 0 if !@toggle
    return false
  end
  #-----------------------------------------------------------------------------
  #  main animation update "loop"
  #-----------------------------------------------------------------------------
  def update
    # exit if animation already finished
    if !self.animating?
      # level icon balls
      for k in 0...@num
        @sprites["partyLine_#{@side}_#{k}"].angle = 0
      end
      return
    end
    # animate appearing
    if @toggle
      self.x += ((@partyBar.width/16)/self.delta) * (@side%2 == 0 ? -1 : 1)
      # rotate icon balls
      for k in 0...@num
        @sprites["partyLine_#{@side}_#{k}"].angle -= ((360/16) * (@side%2 == 0 ? -1 : 1))/self.delta
      end
    # animate removal
    else
      @sprites["partyLine_#{@side}"].zoom_x += (1.0/16)/self.delta
      @sprites["partyLine_#{@side}"].opacity -= 24/self.delta
      # rotate icon balls
      for k in 0...@num
        m = @side%2 == 0 ? -k : (@num - k)
        @sprites["partyLine_#{@side}_#{k}"].angle -= ((360/16) * (@side%2 == 0 ? -1 : 1))/self.delta
        @sprites["partyLine_#{@side}_#{k}"].angle = 0 if @sprites["partyLine_#{@side}_#{k}"].angle >= 360 || @sprites["partyLine_#{@side}_#{k}"].angle <= -360
        @sprites["partyLine_#{@side}_#{k}"].opacity -= 24/self.delta
        @sprites["partyLine_#{@side}_#{k}"].x += (((@partyBar.width/16) * (@side%2 == 0 ? -1 : 1)) - m)/self.delta
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  get full party of the current side
  #-----------------------------------------------------------------------------
  def party
    party = @battle.pbParty(@side).clone
    (@num - party.length).times { party.push(nil) }
    return party
  end
  #-----------------------------------------------------------------------------
  #  dispose and check for disposal
  #-----------------------------------------------------------------------------
  def delta; return Graphics.frame_rate/40.0; end
  def disposed?; return @disposed; end
  def dispose
    return if @disposed
    @partyBar.dispose
    @partyBalls.dispose
    @disposed = true
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Override standard party line up and replace with custom
#===============================================================================
class PokeBattle_Scene
  alias pbShowPartyLineup_ebdx pbShowPartyLineup unless self.method_defined?(:pbShowPartyLineup_ebdx)
  def pbShowPartyLineup(side, fullAnim = false)
    if side%2 == 0
      @playerLineUp.refresh
    else
      @opponentLineUp.refresh
    end
  end
  #-----------------------------------------------------------------------------
end
