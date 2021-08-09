#===============================================================================
#  Command Choices
#  UI ovarhaul
#===============================================================================
class ChoiceWindowEBDX
  attr_accessor :index
  attr_reader :over
  #-----------------------------------------------------------------------------
  #  initialize the choice boxes
  #-----------------------------------------------------------------------------
  def initialize(viewport,commands,scene)
    @commands = commands
    @scene = scene
    @index = 0
    offset = 0
    @path = "Graphics/EBDX/Pictures/UI/"
    @viewport = viewport
    @sprites = {}
    @visibility = [false,false,false,false]
    baseColor = Color.white
    shadowColor = Color.new(0,0,0,192)
    # apply styling from PBS
    self.applyMetrics
    # generate sprites
    @sprites["sel"] = SpriteSheet.new(@viewport,4)
    @sprites["sel"].setBitmap(pbSelBitmap(@path+@selImg,Rect.new(0,0,92,38)))
    @sprites["sel"].speed = 4
    @sprites["sel"].ox = @sprites["sel"].src_rect.width/2
    @sprites["sel"].oy = @sprites["sel"].src_rect.height/2
    @sprites["sel"].z = 99999
    @sprites["sel"].visible = false
    # fill sprites with text
    bmp = pbBitmap(@path+@btnImg)
    for i in 0...@commands.length
      k = @commands.length - 1 - i
      @sprites["choice#{i}"] = Sprite.new(@viewport)
      @sprites["choice#{i}"].x = Graphics.width - bmp.width - 14 + bmp.width/2
      @sprites["choice#{i}"].y = Graphics.height - 136 - k*(bmp.height+4) + bmp.height/2
      @sprites["choice#{i}"].z = 99998
      @sprites["choice#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
      @sprites["choice#{i}"].center!
      @sprites["choice#{i}"].opacity = 0
      choice = @sprites["choice#{i}"].bitmap
      pbSetSystemFont(choice)
      choice.blt(0,0,bmp,bmp.rect)
      pbDrawOutlineText(choice,0,8,bmp.width,bmp.height,@commands[i],baseColor,shadowColor,1)
    end
    bmp.dispose
  end
  #-----------------------------------------------------------------------------
  #  apply styling from PBS
  #-----------------------------------------------------------------------------
  def applyMetrics
    # sets default values
    @btnImg = "btnEmpty"
    @selImg = "cmdSel"
    # looks up next cached metrics first
    d1 = EliteBattle.get(:nextUI)
    d1 = d1[:CHOICE_MENU] if !d1.nil? && d1.has_key?(:CHOICE_MENU)
    # looks up globally defined settings
    d2 = EliteBattle.get_data(:CHOICE_MENU, :Metrics, :METRICS)
    # proceeds with parameter definition if available
    for data in [d2, d1]
      if !data.nil?
        # applies a set of predefined keys
        @btnImg = data[:BUTTONS] if data.has_key?(:BUTTONS) && data[:BUTTONS].is_a?(String)
        @selImg = data[:SELECTOR] if data.has_key?(:SELECTOR) && data[:SELECTOR].is_a?(String)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  dispose of the sprites
  #-----------------------------------------------------------------------------
  def dispose(scene)
    2.times do
      @sprites["sel"].opacity -= 128
      for i in 0...@commands.length
        @sprites["choice#{i}"].opacity -= 128
      end
      scene.animateScene(true)
      scene.pbGraphicsUpdate
    end
    pbDisposeSpriteHash(@sprites)
  end
  #-----------------------------------------------------------------------------
  #  update choice selection
  #-----------------------------------------------------------------------------
  def update
    @sprites["sel"].visible = true
    @sprites["sel"].x = @sprites["choice#{@index}"].x
    @sprites["sel"].y = @sprites["choice#{@index}"].y - 2
    @sprites["sel"].update
    if Input.trigger?(Input::UP)
      pbSEPlay("EBDX/SE_Select1")
      @index -= 1
      @index = @commands.length-1 if @index < 0
      @sprites["choice#{@index}"].src_rect.y -= 6
    elsif Input.trigger?(Input::DOWN)
      pbSEPlay("EBDX/SE_Select1")
      @index += 1
      @index = 0  if @index >= @commands.length
      @sprites["choice#{@index}"].src_rect.y -= 6
    end
    for i in 0...@commands.length
      @sprites["choice#{i}"].opacity += 128 if @sprites["choice#{i}"].opacity < 255
      @sprites["choice#{i}"].src_rect.y += 1 if @sprites["choice#{i}"].src_rect.y < 0
    end
  end
  def shiftMode=(val); end
  #-----------------------------------------------------------------------------
end
