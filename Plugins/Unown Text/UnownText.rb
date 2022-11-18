#===============================================================================
# Unown Text.rb
# This file contains methods and classes for displaying unown text boxes, both
# with and without background, as well as a separate screen for displaying
# pure unown text.
# 
# Methods:
# pb_unowntext(text)
# pb_unowntext(text,align)
# pb_unowntext_bg(text)
# pb_unowntext_bg(text,align)
# pb_unownscene(text)
#===============================================================================

#===============================================================================
# Methods for calling unown text boxes
#===============================================================================
# Displays unown text, left aligned
def pb_unowntext(text = "TEST")
    unownText = Window_UnownText.new(0,0,100,100)
    unownText.alignment = 0
    unownText.text = text
    
    pbSEPlay("GUI sel cursor")
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        break
      end
      if Input.trigger?(Input::USE)
        break
      end
      pbUpdateSceneMap
    end
    
    unownText.dispose
    Input.update
end

# Displays unown text, with defined alignment. Defaults to left.
def pb_unowntext(text = "TEST", align = 0)
    unownText = Window_UnownText.new(0,0,100,100)
    unownText.alignment = align
    unownText.text = text
    
    pbSEPlay("GUI sel cursor")
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        break
      end
      if Input.trigger?(Input::USE)
        break
      end
      pbUpdateSceneMap
    end
    
    unownText.dispose
    Input.update
end  

# Displays unown text with a bg background, left aligned
def pb_unowntext_bg(text = "TEST")
    unownText = Window_UnownText.new(0,0,100,100)
    unownText.alignment = 0
    unownText.bg = true
    unownText.text = text
    
    pbSEPlay("GUI sel cursor")
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        break
      end
      if Input.trigger?(Input::USE)
        break
      end
      pbUpdateSceneMap
    end
    
    unownText.dispose
    Input.update
end
  
# Displays unown text with a bg background. Defaults to left alignment.
def pb_unowntextbg(text = "TEST", align = 0)
    unownText = Window_UnownText.new(0,0,100,100)
    unownText.alignment = align
    unownText.bg = true
    unownText.text = text
    
    pbSEPlay("GUI sel cursor")
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::BACK)
        break
      end
      if Input.trigger?(Input::USE)
        break
      end
      pbUpdateSceneMap
    end
    
    unownText.dispose
    Input.update
end  

# Displays a scene of Unown text
def pb_unownscene(text = "TEST")
	unownText = UnownText_Scene.new()
	unownText.pbStartScene(text)
end
#===============================================================================
# Displays an UnownText window.
#===============================================================================
class Window_UnownText < SpriteWindow_Base
  attr_reader :text
  attr_reader :alignment
  attr_reader :bg
  
  MAXLINELENGTH=14
  SPRITESIZE=32
  SPRITECOUNT=28
  
  def initialize(x,y,width,height,viewport=nil)
    super(x,y,width,height)
    self.viewport=viewport
    self.contents=nil
    @text = ""
    @frame = 0
    @alignment = 0
	@unownsprites = []
    @unownbitmap = nil
    @bg = false
  end
  
  def update

  end
  
  def dispose
    clearBitmaps()
    super
  end
  
  def clearBitmaps
    @unownbitmap.dispose
    for i in 0..self.text.length - 1
      @unownsprites[i].dispose
    end
    self.contents=nil if !self.disposed?
  end
  
  # 0 = left align
  # 1 = center align
  # 2 = right align
  def alignment=(value)
    @alignment=value
  end
  
  # whether or not using the bg sprite
  def bg=(value)
    @bg=value
  end
  
  # sets the unown sprite
  def setSprite(j)
	if @text[j] == '?'
	  @unownsprites[j].bitmap.blt(0,1,
		@unownbitmap.bitmap,Rect.new(26*SPRITESIZE,0,SPRITESIZE,SPRITESIZE))
	elsif @text[j] == '!'
	  @unownsprites[j].bitmap.blt(0,1,
		@unownbitmap.bitmap,Rect.new(27*SPRITESIZE,0,SPRITESIZE,SPRITESIZE))
	elsif @text.getbyte(j) >= 65 && @text.getbyte(j) <= 90
	  @unownsprites[j].bitmap.blt(0,1,
		@unownbitmap.bitmap,
		  Rect.new((@text.getbyte(j)-65)*SPRITESIZE, 0,SPRITESIZE,SPRITESIZE)) 
	else
	  @unownsprites[j].bitmap.blt(0,1,
		@unownbitmap.bitmap,Rect.new(SPRITECOUNT*SPRITESIZE,0,SPRITESIZE,SPRITESIZE))
	end
  end
  
  def text=(value)
	if @unownbitmap != nil
	  @unownbitmap.dispose
	end
  
    if bg
      @unownbitmap = AnimatedBitmap.new(_INTL("Graphics/Unown/unown_bg"))
    else 
      @unownbitmap = AnimatedBitmap.new(_INTL("Graphics/Unown/unown"))
    end
    # set the text value to UPPERCASE
    @text=value.gsub("\n", "~").upcase
    linelength = []
    
    # inserts line breaks based on maxlength
    counter = 0
    line = 0
    zip = 0
    maxwidth = 0
    oldcounter = 0
    
    while counter < @text.length
      if line == MAXLINELENGTH || @text[counter] == "~"
        # move the counter back until you find 
        # a space or line is 0
        if @text[counter] != "~"
          oldcounter = counter
          while @text[counter] != " " && line > 0
            counter-=1
            line-=1
          end
          # this way it doesn't lock if you have no spaces
          # but still need to be split :(
          if line == 0
            counter = oldcounter
            maxwidth = MAXLINELENGTH
          end
          @text.insert(counter, '~')
        end
        if @text[counter-1] == " "
          line-=1
        end
        # sets maximum width of the window
        if line > maxwidth
          maxwidth = line
        end
        linelength[zip] = line
        line = 0
        counter+=1
        zip+=1
      end
      line+=1
      counter+=1
    end
    linelength[zip] = line
    
	@text = @text.gsub("~~", "~")
	
    if maxwidth == 0
      maxwidth = @text.length-1
    end
    
    # set up window properties
    # width and x
    heightval = 0
    if maxwidth+1 < MAXLINELENGTH
      if @text.length > MAXLINELENGTH
        widthval = (maxwidth-1)*SPRITESIZE
      else
        widthval = (maxwidth)*SPRITESIZE
      end
    else
      widthval = (maxwidth-1)*SPRITESIZE
      heightval = 1
    end
    
    self.width = widthval + 80
    self.x = Graphics.width/2 - self.width / 2 
    
    # height and y
    if @text.count('~') > 0
      heightval = @text.count('~')
    end
    
    self.height = SPRITESIZE + 40 + (heightval)*SPRITESIZE
    self.y = Graphics.height/2 - self.height / 2
    
    # set up the characters to be drawn
    line = 0
    counter = 0
    
    if @alignment == 2
      # right alignment
      centerx = self.x + (self.width).floor - SPRITESIZE - 16
      lineadjust = SPRITESIZE * linelength[0]
      for j in 0..self.text.length-1
        # position the unown sprite
        @unownsprites[j] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport);
        @unownsprites[j].x = centerx - lineadjust + 20 + SPRITESIZE * counter;
        @unownsprites[j].y = self.y + 20 + (SPRITESIZE-1) * line;
        @unownsprites[j].z = 200;
		if @text[j] == '~'
			# add a line break
			line+=1
			counter = -1
			if line < linelength.length
			  lineadjust = SPRITESIZE * linelength[line]
			end
		else
			setSprite(j)
		end
              
        counter+=1
      end
    elsif @alignment == 1
      # center align
      centerx = self.x + (self.width * 0.5).floor
      lineadjust = SPRITESIZE * linelength[0] * 0.5 + 20
      for j in 0..self.text.length-1
        # position the unown sprite
        @unownsprites[j] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport);
        @unownsprites[j].x = centerx - lineadjust + 20 + SPRITESIZE * counter;
        @unownsprites[j].y = self.y + 20 + (SPRITESIZE-1) * line;
        @unownsprites[j].z = 200;
		if @text[j] == '~'
			# add a line break
			line+=1
			counter = -1
			if line < linelength.length
			  lineadjust = SPRITESIZE * linelength[line] * 0.5 + 20
			end
		else
			setSprite(j)
		end
              
        counter+=1
      end
    else
      # left alignment
      for j in 0..self.text.length-1
        # position the unown sprite
        @unownsprites[j] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport);
        @unownsprites[j].x = self.x + 20 + SPRITESIZE * counter;
        @unownsprites[j].y = self.y + 20 + (SPRITESIZE-1) * line;
        @unownsprites[j].z = 200;
		if @text[j] == '~'
			# add a line break
			line+=1
			counter = -1
			if line < linelength.length
			  lineadjust = SPRITESIZE * linelength[line]
			end
		else
			setSprite(j)
		end
              
        counter+=1
      end
    end

  end
  
end


#===============================================================================
# Displays an UnownText scene.
#===============================================================================
class UnownText_Scene
	attr_reader :text
	attr_reader :alignment

    MAXLINELENGTH=12
    SPRITESIZE=32
    SPRITECOUNT=28

	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end

	def pbStartScene(text)
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@text = ""
		@frame = 0
		@alignment = 1
		@unownbitmap = nil
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["background"].setBitmap("Graphics/Unown/unown_scene")
		setText(text)
		
		pbFadeInAndShow(@sprites) { pbUpdate }
		pbDisplay()
	end
	
	def pbDisplay()
		loop do
			Graphics.update
			Input.update
			pbUpdate
			if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
				Input.update
				pbEndScene()
				break
			end
		end
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites) { pbUpdate }
		pbDisposeSpriteHash(@sprites)
		if @unownbitmap != nil
		  @unownbitmap.dispose
		end
		@viewport.dispose
	end
  
  # 0 = left align
  # 1 = center align
  # 2 = right align
  def alignment=(value)
    @alignment=value
  end
  
  # whether or not using the bg sprite
  def bg=(value)
    @bg=value
  end
  
  # sets the unown sprite
  def setSprite(j)
	if @text[j] == '?'
	  @sprites["unown#{j}"].bitmap.blt(0,1,
		@unownbitmap.bitmap,Rect.new(26*SPRITESIZE,0,SPRITESIZE,SPRITESIZE))
	elsif @text[j] == '!'
	  @sprites["unown#{j}"].bitmap.blt(0,1,
		@unownbitmap.bitmap,Rect.new(27*SPRITESIZE,0,SPRITESIZE,SPRITESIZE))
	elsif @text.getbyte(j) >= 65 && @text.getbyte(j) <= 90
	  @sprites["unown#{j}"].bitmap.blt(0,1,
		@unownbitmap.bitmap,
		  Rect.new((@text.getbyte(j)-65)*SPRITESIZE, 0,SPRITESIZE,SPRITESIZE)) 
	else
	  @sprites["unown#{j}"].bitmap.blt(0,1,
		@unownbitmap.bitmap,Rect.new(SPRITECOUNT*SPRITESIZE,0,SPRITESIZE,SPRITESIZE))
	end
  end
  
  def setText(value)
	if @unownbitmap != nil
	  @unownbitmap.dispose
	end
    @unownbitmap = AnimatedBitmap.new(_INTL("Graphics/Unown/unown"))
    # set the text value to UPPERCASE
    @text=value.gsub("\n", "~").upcase
    linelength = []
    x = 0
	y = 0
	width = 0
	height = 0
    # inserts line breaks based on maxlength
    counter = 0
    line = 0
    zip = 0
    maxwidth = 0
    oldcounter = 0
    
    while counter < @text.length
      if line == MAXLINELENGTH || @text[counter] == "~"
        # move the counter back until you find 
        # a space or line is 0
        if @text[counter] != "~"
          oldcounter = counter
          while @text[counter] != " " && line > 0
            counter-=1
            line-=1
          end
          # this way it doesn't lock if you have no spaces
          # but still need to be split :(
          if line == 0
            counter = oldcounter
            maxwidth = MAXLINELENGTH
          end
          @text.insert(counter, '~')
        end
        if @text[counter-1] == " "
          line-=1
        end
        # sets maximum width of the window
        if line > maxwidth
          maxwidth = line
        end
        linelength[zip] = line
        line = 0
        counter+=1
        zip+=1
      end
      line+=1
      counter+=1
    end
    linelength[zip] = line
    
	@text = @text.gsub("~~", "~")
	
    if maxwidth == 0
      maxwidth = @text.length-1
    end
    
    # set up window properties
    # width and x
    heightval = 0
    if maxwidth+1 < MAXLINELENGTH
      if @text.length > MAXLINELENGTH
        widthval = (maxwidth-1)*SPRITESIZE
      else
        widthval = (maxwidth)*SPRITESIZE
      end
    else
      widthval = (maxwidth-1)*SPRITESIZE
      heightval = 1
    end
    
    width = widthval + 80
    x = Graphics.width/2 - width / 2 
    
    # height and y
    if @text.count('~') > 0
      heightval = @text.count('~')
    end
    
    height = SPRITESIZE + 40 + (heightval)*SPRITESIZE
    y = Graphics.height/2 - height / 2
    
    # set up the characters to be drawn
    line = 0
    counter = 0
    
    if @alignment == 2
      # right alignment
      centerx = x + (width).floor - SPRITESIZE - 16
      lineadjust = SPRITESIZE * linelength[0]
      for j in 0..text.length-1
        # position the unown sprite
        @sprites["unown#{j}"] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport);
        @sprites["unown#{j}"].x = centerx - lineadjust + 20 + SPRITESIZE * counter;
        @sprites["unown#{j}"].y = y + 20 + (SPRITESIZE-1) * line;
        @sprites["unown#{j}"].z = 200;
		if @text[j] == '~'
			# add a line break
			line+=1
			counter = -1
			if line < linelength.length
			  lineadjust = SPRITESIZE * linelength[line]
			end
		else
			setSprite(j)
		end
              
        counter+=1
      end
    elsif @alignment == 1
      # center align
      centerx = x + (width * 0.5).floor
      lineadjust = SPRITESIZE * linelength[0] * 0.5 + 20
      for j in 0..text.length-1
        # position the unown sprite
        @sprites["unown#{j}"] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport);
        @sprites["unown#{j}"].x = centerx - lineadjust + 20 + SPRITESIZE * counter;
        @sprites["unown#{j}"].y = y + 20 + (SPRITESIZE-1) * line;
        @sprites["unown#{j}"].z = 200;
		if @text[j] == '~'
			# add a line break
			line+=1
			counter = -1
			if line < linelength.length
			  lineadjust = SPRITESIZE * linelength[line] * 0.5 + 20
			end
		else
			setSprite(j)
		end
              
        counter+=1
      end
    else
      # left alignment
      for j in 0..text.length-1
        # position the unown sprite
        @sprites["unown#{j}"] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport);
        @sprites["unown#{j}"].x = x + 20 + SPRITESIZE * counter;
        @sprites["unown#{j}"].y = y + 20 + (SPRITESIZE-1) * line;
        @sprites["unown#{j}"].z = 200;
		if @text[j] == '~'
			# add a line break
			line+=1
			counter = -1
			if line < linelength.length
			  lineadjust = SPRITESIZE * linelength[line]
			end
		else
			setSprite(j)
		end
              
        counter+=1
      end
    end

  end
	
end