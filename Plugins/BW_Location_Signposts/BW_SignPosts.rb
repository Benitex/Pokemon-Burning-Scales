#===============================================================================
#BW signposts (original by Shiney570, updated by Shashu Greninja)
#===============================================================================
class LocationWindow

  def initialize(name)
    #Original BW, B2W2 Signposts
    newarr=[]
    for name in TOWN
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr.push(s)
      town=TOWN+newarr
    end
    newarr2=[]
    for name in CITY
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr2.push(s)
      city=CITY+newarr2
    end
    newarr3=[]
    for name in BRIDGE
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr3.push(s)
      bridge=BRIDGE+newarr3
    end
    newarr4=[]
    for name in ROUTE
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr4.push(s)
      route=ROUTE+newarr4
    end
    #Custom Signpost Initializations
    newarr5=[]
    for name in FOREST
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr5.push(s)
      forest=FOREST+newarr5
    end
    newarr6=[]
    for name in CAVE
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr6.push(s)
      cave=CAVE+newarr6
    end
    newarr7=[]
    for name in PORT
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr7.push(s)
      port=PORT+newarr7
    end
    newarr8=[]
    for name in DESERT
      next if !name.is_a?(String)
      s=name.gsub(/^./) { |m| m.upcase }
      newarr8.push(s)
      desert=DESERT+newarr8
    end

    @frames=0
    @currentmap=$game_map.map_id
    name=$game_map.name
    @window=Sprite.new
    @window.z=99999
    @overlay=BitmapSprite.new(Graphics.width,Graphics.height)
    @overlay.z= 99999
    @route_number_icons = AnimatedBitmap.new(_INTL("Graphics/Pictures/Location/icon_numbers"))

    if SHOW_SEASONS == true
        @season=Sprite.new
        if pbIsSpring # Jan, May, Sep
          @season.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Location/","Spring")
        elsif pbIsSummer # Feb, Jun, Oct
          @season.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Location/","Summer")
        elsif pbIsAutumn # Mar, Jul, Nov
          @season.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Location/","Autumn")
        elsif pbIsWinter # Apr, Aug, Dec
          @season.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Location/","Winter")
        end
        @season.y=Settings::SCREEN_HEIGHT
        @season.z=99999
    end

    for i in 0..town.length-1
      if $game_map.name.include?(town[i]) || @currentmap==TOWN[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","town")
      end
    end
    for i in 0..city.length-1
      if $game_map.name.include?(city[i]) || @currentmap==CITY[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","city")
      end
    end
    for i in 0..bridge.length-1
      if $game_map.name.include?(bridge[i]) || @currentmap==BRIDGE[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","bridge")
      end
    end
    for i in 0..route.length-1
      if $game_map.name.include?(route[i]) || @currentmap==ROUTE[i]
        @route_number=$game_map.name.gsub(/[^0-9]/, '')
        if @route_number.to_i >= 100 #Uses wider Route callout for 3-digit route numbers
          @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","route_extended")
          @extended_route = true
        else
          @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","route")
          @extended_route = false
        end
      end
    end
    for i in 0..forest.length-1
      if $game_map.name.include?(forest[i]) || @currentmap==FOREST[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","forest")
      end
    end
    for i in 0..cave.length-1
      if $game_map.name.include?(cave[i]) || @currentmap==CAVE[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","cave")
      end
    end
    for i in 0..port.length-1
      if $game_map.name.include?(forest[i]) || @currentmap==PORT[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","port")
      end
    end
    for i in 0..desert.length-1
      if $game_map.name.include?(cave[i]) || @currentmap==DESERT[i]
        @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","desert")
      end
    end
    if @window.bitmap.nil?
      @window.bitmap=RPG::Cache.load_bitmap("Graphics/Pictures/Location/","none")
    end
    @window.y  = -@window.bitmap.height - 4
    @overlay.y = @window.y
    overlay = @overlay.bitmap
    pbSetSystemFont(@overlay.bitmap)
    if @extended_route
      textos=[
      [name,59+14,8-12,0,Color.new(255,255,255),Color.new(115,115,115)],
      ]
    else
      textos=[
      [name,59,8-12,0,Color.new(255,255,255),Color.new(115,115,115)],
      ]
    end
    pbDrawTextPositions(overlay,textos)
    #Draws the route numbers as Graphics...
    if @route_number != nil
      if @route_number.to_i >= 100 #Different positions according to route number
       pbDrawRouteNumber(@route_number,@window.bitmap,24-16,8+2)
      elsif @route_number.to_i >= 10
       pbDrawRouteNumber(@route_number,@window.bitmap,24-16,8+2)
      else
       pbDrawRouteNumber(@route_number,@window.bitmap,24-6,8+2)
     end
    end
    pbDrawTextPositions(overlay,textos)
  end

  def pbDrawRouteNumber(number,btmp,startX,startY,align=0)
    n = number.to_i.digits.reverse
    charWidth  = @route_number_icons.width/10
    charHeight = @route_number_icons
    .height
    startX -= charWidth*n.length if align==1
    n.each do |i|
      btmp.blt(startX,startY,@route_number_icons.bitmap,Rect.new(i*charWidth,0,charWidth,charHeight))
      startX += charWidth
    end
  end

  def disposed?
   @window.disposed?
   @overlay.disposed?
   if SHOW_SEASONS
     @season.disposed? if @season
   end
  end

  def dispose
    @window.dispose
    @overlay.dispose
    @season.dispose if @season
  end

  def update
    if @currentmap != $game_map.map_id
      dispose
    end
    return if @window.disposed?
    @window.update
    @overlay.update
    if @frames<10
      @window.y+= (@window.bitmap.height+0.1)/10
      @overlay.y+= (@window.bitmap.height+0.1)/10
      @season.y-= @season.bitmap.height/10 if @season
    elsif @frames>=90 && @frames<=100
      @window.y-= (@window.bitmap.height+0.1)/10
      @overlay.y-= (@window.bitmap.height+0.1)/10
      @season.y+= @season.bitmap.height/10 if @season
    elsif @frames>101
      @window.dispose; @overlay.dispose
      @season.dispose if @season
    end
    @frames+=1
  end
end
