#===============================================================================
# Unown Text.rb
# This file contains methods and classes for handling a menu very similar to
# "Unown Mode" in Pokemon GSC. 
# 
# Methods:
#===============================================================================

#===============================================================================
# Methods for calling Unown Mode
#===============================================================================

# Displays the unown mode scene.
# Only if you have seen unown
def pb_unownmode_scene()
	if $Trainer.pokedex.seen?(:UNOWN)
		unownMode = UnownMode_Scene.new()
		unownMode.pbStartScene()
	end
end

#===============================================================================
# Unown Mode Selector
#===============================================================================
class UnownModeSelectionSprite < MoveSelectionSprite
  def initialize(viewport=nil)
    super(viewport)
    @movesel = AnimatedBitmap.new("Graphics/Unown/cursor_unownmode")
    @frame = 0
    @index = 0
    @preselected = false
    @updating = false
    @spriteVisible = true
    refresh
  end

  def visible=(value)
    super
    @spriteVisible = value if !@updating
  end

  def refresh
    w = @movesel.width
    h = @movesel.height/2
    self.bitmap = @movesel.bitmap
    if self.preselected
      self.src_rect.set(0,h,w,h)
    else
      self.src_rect.set(0,0,w,h)
    end
  end

  def update
    @updating = true
    super
    @movesel.update
    @updating = false
    refresh
  end
end


#===============================================================================
# Unown Mode UI
#===============================================================================
class UnownMode_Scene
	attr_reader :unowntext

	SPRITECOUNT=28
	SPRITESIZE=32
	CHARSIZE=24

	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end

	def pbStartScene()
		@unowntext = ["ANGER","BEAR","CHASE","DIRECT","ENGAGE","FIND","GIVE","HELP","INCREASE","JOIN","KEEP","LAUGH","MAKE","NUZZLE",
						"OBSERVE","PERFORM","QUICKEN","REASSURE","SEARCH","TELL","UNDO","VANISH","WANT","XXXXX","YIELD","ZOOM",
						"?????","!!!!!"]
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@frame = 0
		@alignment = 1
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["background"].setBitmap("Graphics/Unown/unown_mode")
		@sprites["selection"] = UnownModeSelectionSprite.new(@viewport)
		#@sprites["selection"].visible     = false
		@sprites["selection"].preselected = true
		
		@unown = AnimatedBitmap.new(_INTL("Graphics/Unown/unown"))
		@unown_font = AnimatedBitmap.new(_INTL("Graphics/Unown/unown_small"))
		col = Color.new(84,69,51)
		for i in 0..SPRITECOUNT-1
			@sprites["unown#{i}"] = BitmapSprite.new(SPRITESIZE,SPRITESIZE,@viewport)
			@sprites["unown#{i}"].bitmap.blt(0,1,@unown.bitmap,
				  Rect.new(i*SPRITESIZE, 0,SPRITESIZE,SPRITESIZE))
			@sprites["unown#{i}"].color = col
			@sprites["unown#{i}"].visible = $Trainer.pokedex.seen_form?(:UNOWN, 0, i)
		end
		col2 = Color.new(184,169,151)
		for i in 0..10
			@sprites["unownchar#{i}"] = BitmapSprite.new(CHARSIZE,CHARSIZE,@viewport)
			@sprites["unownchar#{i}"].color = col
		end
		
		# position the unown
		@sprites["unown0"].x = 112
		@sprites["unown0"].y = 250
		@sprites["unown1"].x = @sprites["unown0"].x
		@sprites["unown1"].y = @sprites["unown0"].y - SPRITESIZE
		@sprites["unown2"].x = @sprites["unown1"].x
		@sprites["unown2"].y = @sprites["unown1"].y - SPRITESIZE
		@sprites["unown3"].x = @sprites["unown2"].x
		@sprites["unown3"].y = @sprites["unown2"].y - SPRITESIZE
		@sprites["unown4"].x = @sprites["unown3"].x
		@sprites["unown4"].y = @sprites["unown3"].y - SPRITESIZE
		@sprites["unown5"].x = @sprites["unown4"].x
		@sprites["unown5"].y = @sprites["unown4"].y - SPRITESIZE
		@sprites["unown6"].x = @sprites["unown5"].x
		@sprites["unown6"].y = @sprites["unown5"].y - SPRITESIZE
		@sprites["unown7"].x = @sprites["unown6"].x + SPRITESIZE
		@sprites["unown7"].y = @sprites["unown6"].y
		@sprites["unown8"].x = @sprites["unown7"].x + SPRITESIZE
		@sprites["unown8"].y = @sprites["unown7"].y
		@sprites["unown9"].x = @sprites["unown8"].x + SPRITESIZE
		@sprites["unown9"].y = @sprites["unown8"].y
		@sprites["unown10"].x = @sprites["unown9"].x + SPRITESIZE
		@sprites["unown10"].y = @sprites["unown9"].y
		@sprites["unown11"].x = @sprites["unown10"].x + SPRITESIZE
		@sprites["unown11"].y = @sprites["unown10"].y
		@sprites["unown12"].x = @sprites["unown11"].x + SPRITESIZE
		@sprites["unown12"].y = @sprites["unown11"].y
		@sprites["unown13"].x = @sprites["unown12"].x + SPRITESIZE
		@sprites["unown13"].y = @sprites["unown12"].y
		@sprites["unown14"].x = @sprites["unown13"].x + SPRITESIZE
		@sprites["unown14"].y = @sprites["unown13"].y
		@sprites["unown15"].x = @sprites["unown14"].x
		@sprites["unown15"].y = @sprites["unown14"].y + SPRITESIZE
		@sprites["unown16"].x = @sprites["unown15"].x
		@sprites["unown16"].y = @sprites["unown15"].y + SPRITESIZE
		@sprites["unown17"].x = @sprites["unown16"].x
		@sprites["unown17"].y = @sprites["unown16"].y + SPRITESIZE
		@sprites["unown18"].x = @sprites["unown17"].x
		@sprites["unown18"].y = @sprites["unown17"].y + SPRITESIZE
		@sprites["unown19"].x = @sprites["unown18"].x
		@sprites["unown19"].y = @sprites["unown18"].y + SPRITESIZE
		@sprites["unown20"].x = @sprites["unown18"].x
		@sprites["unown20"].y = @sprites["unown19"].y + SPRITESIZE
		@sprites["unown21"].x = @sprites["unown20"].x - SPRITESIZE
		@sprites["unown21"].y = @sprites["unown20"].y + SPRITESIZE
		@sprites["unown22"].x = @sprites["unown21"].x - SPRITESIZE
		@sprites["unown22"].y = @sprites["unown21"].y 
		@sprites["unown23"].x = @sprites["unown22"].x - SPRITESIZE
		@sprites["unown23"].y = @sprites["unown22"].y 
		@sprites["unown24"].x = @sprites["unown23"].x - SPRITESIZE
		@sprites["unown24"].y = @sprites["unown23"].y 
		@sprites["unown25"].x = @sprites["unown24"].x - SPRITESIZE
		@sprites["unown25"].y = @sprites["unown24"].y 
		@sprites["unown26"].x = @sprites["unown25"].x - SPRITESIZE
		@sprites["unown26"].y = @sprites["unown25"].y 
		@sprites["unown27"].x = @sprites["unown26"].x - SPRITESIZE
		@sprites["unown27"].y = @sprites["unown26"].y 
		pbFixUnownForward()
		pbSetCursorPosition()
		pbUpdateUnownSprite()
		pbFadeInAndShow(@sprites) { pbUpdate }
		pbDisplay()
	end
	
	def pbSetUnownSprite(i)
		@sprites["unownchar#{i}"].bitmap.blt(0,1,@unown_font.bitmap,
			Rect.new(i*CHARSIZE, 0,CHARSIZE,CHARSIZE))
	end
	
	def pbUpdateUnownSprite()
		if @sprites["character"] != nil
			@sprites["character"].dispose
		end
		@sprites["character"] = IconSprite.new(0,0,@viewport)
		@sprites["character"].setBitmap("Graphics/Unown/UNOWN_#{@sprites["selection"].index}")
		@sprites["character"].x = 180
		@sprites["character"].y = 106
	end
	
	def pbUpdateUnownText(x,y,text)
		base   = Color.new(248,248,248)
		shadow = Color.new(104,104,104)
	
      # center align
		@sprites["background"].bitmap.clear()
		@sprites["background"].setBitmap("Graphics/Unown/unown_mode")
		width = text.length*CHARSIZE
		x = x - width / 2 
		
		y = y - CHARSIZE / 2
		
		lineadjust = CHARSIZE * text.length * 0.5
		for j in 0..10
			@sprites["unownchar#{j}"].bitmap.clear
			if j < text.length
				# position the unown sprite
				@sprites["unownchar#{j}"].x = x + CHARSIZE*j;
				@sprites["unownchar#{j}"].y = y + (CHARSIZE-1);
				@sprites["unownchar#{j}"].z = 200;
				if text[j] == "!"
				  @sprites["unownchar#{j}"].bitmap.blt(0,1,
					@unown_font.bitmap,
					  Rect.new(26*CHARSIZE, 0,CHARSIZE,CHARSIZE)) 
				elsif text[j] == "?"
				  @sprites["unownchar#{j}"].bitmap.blt(0,1,
					@unown_font.bitmap,
					  Rect.new(27*CHARSIZE, 0,CHARSIZE,CHARSIZE)) 
				else
				  @sprites["unownchar#{j}"].bitmap.blt(0,1,
					@unown_font.bitmap,
					  Rect.new((text.getbyte(j)-65)*CHARSIZE, 0,CHARSIZE,CHARSIZE)) 
				end
			elsif
				  @sprites["unownchar#{j}"].bitmap.blt(0,1,
					@unown_font.bitmap,
					  Rect.new(SPRITECOUNT*CHARSIZE, 0,CHARSIZE,CHARSIZE)) 
			end
		end
			
		overlay = @sprites["background"].bitmap
		pbSetSystemFont(overlay)
		textpos = [["UNOWN MODE",200,-2,0,base,shadow]]
		pbDrawTextPositions(overlay,textpos)
			
	end
	
	def pbSetCursorPosition()
		@sprites["selection"].x = @sprites["unown#{@sprites["selection"].index}"].x-2
		@sprites["selection"].y = @sprites["unown#{@sprites["selection"].index}"].y
		@sprites["selection"].refresh
		pbUpdateUnownSprite()
		pbUpdateUnownText(Graphics.width/2,338,@unowntext[@sprites["selection"].index])
		pbPlayCursorSE
	end
	
	def pbDisplay()
		loop do
			Graphics.update
			Input.update
			pbUpdate
			# movement
			if Input.trigger?(Input::LEFT) ||  Input.trigger?(Input::UP)
				if @sprites["selection"].index > 0
					@sprites["selection"].index-=1
				elsif
					@sprites["selection"].index = SPRITECOUNT - 1
				end
				pbFixUnownBackward()
				pbSetCursorPosition()
			elsif Input.trigger?(Input::RIGHT) ||  Input.trigger?(Input::DOWN)
				if @sprites["selection"].index < SPRITECOUNT - 1
					@sprites["selection"].index+=1
				elsif
					@sprites["selection"].index = 0
				end
				pbFixUnownForward()
				pbSetCursorPosition()
			elsif Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
				Input.update
				pbEndScene()
				break
			end
		end
	end
	
	def pbFixUnownForward()
		loop do
			if @sprites["unown#{@sprites["selection"].index}"].visible
				return
			end
			@sprites["selection"].index+=1
			if @sprites["selection"].index > SPRITECOUNT - 1
				@sprites["selection"].index = 0
			end
			
		end
	end
	
	def pbFixUnownBackward()
		loop do
			if @sprites["unown#{@sprites["selection"].index}"].visible
				return
			end
			@sprites["selection"].index-=1
			if @sprites["selection"].index < 0
				@sprites["selection"].index = SPRITECOUNT - 1
			end
			
		end
	end
	
	def pbEndScene
		pbFadeOutAndHide(@sprites) { pbUpdate }
		pbDisposeSpriteHash(@sprites)
		@unown.dispose
		@unown_font.dispose
		@viewport.dispose
	end
end