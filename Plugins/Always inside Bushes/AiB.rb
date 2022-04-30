#==============================================================================
# Always inside Bushes - By Kotaro [v19.1]
# Idea based of KleinStudio's "Overworlds always within grass" Script [v17]
#==============================================================================
class Game_Character
    def calculate_bush_depth
      if @tile_id > 0 || @always_on_top || jumping?
        @bush_depth = 0
      else
        deep_bush = regular_bush = false
        xbehind = @x + (@direction == 4 ? 1 : @direction == 6 ? -1 : 0)
        ybehind = @y + (@direction == 8 ? 1 : @direction == 2 ? -1 : 0)
        this_map = (self.map.valid?(@x, @y)) ? [self.map, @x, @y] : $MapFactory.getNewMap(@x, @y)
        if this_map[0].deepBush?(this_map[1], this_map[2]) && self.map.deepBush?(xbehind, ybehind)
          @bush_depth = Game_Map::TILE_HEIGHT
        elsif !moving? && this_map[0].bush?(this_map[1], this_map[2])
          @bush_depth = 12
#==============================================================================
#added part to the existing method #byKota          
        elsif moving? && this_map[0].bush?(this_map[1], this_map[2]) && self.map.bush?(xbehind, ybehind)
          @bush_depth = 12 
#==============================================================================              
        else
          @bush_depth = 0
        end
      end
    end
  end
#==============================================================================