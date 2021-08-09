#===============================================================================
# setup battle environments
#===============================================================================
EliteBattle.configProcess(:ENVIRONMENTS) do
  echoln "  -> configuring battle environments..."
  #---------------------------------------------------------------------------
  # Battle Room configurations per Environment
  # Cave
  EliteBattle.add_data(:Cave, :Environment, :BACKDROP, EnvironmentEBDX::CAVE)
  # Dark Cave (based on conditional)
  EliteBattle.add_data(proc{ |terrain, environ|
    next environ == :Cave && GameData::MapMetadata.exists?($game_map.map_id) && $PokemonTemp.darknessSprite
  }, :BACKDROP, EnvironmentEBDX::DARKCAVE)
  # Water
  EliteBattle.add_data(:MovingWater, :Environment, :BACKDROP, EnvironmentEBDX::WATER)
  # Underwater
  EliteBattle.add_data(:Underwater, :Environment, :BACKDROP, EnvironmentEBDX::UNDERWATER)
  # Forest
  EliteBattle.add_data(:Forest, :Environment, :BACKDROP, EnvironmentEBDX::FOREST)
  # Mountains
  EliteBattle.add_data(:Rock, :Environment, :BACKDROP, EnvironmentEBDX::MOUNTAIN)
  #---------------------------------------------------------------------------
  # Battle Room configurations per Terrain
  # Mountains
  EliteBattle.add_data(:Rock, :TerrainTag, :BACKDROP, TerrainEBDX::MOUNTAIN)
  # Puddle
  EliteBattle.add_data(:Puddle, :TerrainTag, :BACKDROP, TerrainEBDX::PUDDLE)
  # Sand
  EliteBattle.add_data(:Sand, :TerrainTag, :BACKDROP, TerrainEBDX::DIRT)
  # Tall Grass
  EliteBattle.add_data(proc{ |terrain, environ|
    next [:Grass, :TallGrass].include?(terrain) && environ != :Underwater
  }, :BACKDROP, TerrainEBDX::TALLGRASS)
  # concrete base when in cities
  EliteBattle.add_data(proc{ |terrain, environ|
    next (($game_map.name.downcase).include?("city") || ($game_map.name.downcase).include?("town")) &&
         EliteBattle.outdoor_map?
  }, :BACKDROP, TerrainEBDX::CONCRETE)
  # water base when surfing and no water environment is defined
  EliteBattle.add_data(proc{ |terrain, environ|
    next $PokemonGlobal.surfing && environ != :MovingWater
  }, :BACKDROP, TerrainEBDX::WATER)
end
