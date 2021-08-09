#===============================================================================
# setup global move animation map
#===============================================================================
EliteBattle.configProcess(:ANIMATIONMAP) do
  # configure metrics data
  next if !File.safeData?("Data/animationmap.ebdx")
  echoln "  -> configuring global move animation mapping..."
  map = load_data("Data/animationmap.ebdx")
  for key in map.keys
    type = key.upcase.to_sym
    vals = {
      'physicalMove' => EliteBattle.class_variable_get(:@@physical),
      'specialMove' => EliteBattle.class_variable_get(:@@special),
      'statusMove' => EliteBattle.class_variable_get(:@@status),
      'multiHitMove' => EliteBattle.class_variable_get(:@@multihit),
      'allOpposing' => EliteBattle.class_variable_get(:@@allOpp),
      'nonUser' => EliteBattle.class_variable_get(:@@nonUsr)
    }
    # go through each parameter
    for v in vals.keys
      next if !map[key]["__pk__"][v]
      vals[v][type] = map[key]["__pk__"][v][0].upcase.to_sym
    end
  end
end
