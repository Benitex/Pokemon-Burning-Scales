#===============================================================================
# setup EBDX metrics
#===============================================================================
EliteBattle.configProcess(:METRICS) do
  # configure metrics data
  next if !File.safeData?("Data/metrics.ebdx")
  echoln "  -> configuring system metrics..."
  metrics = load_data("Data/metrics.ebdx")
  # iterate through all the sections
  for section in metrics.keys
    # configure vectors
    if section.upcase == "VECTORS"
      for vector in metrics[section].keys
        if vector != "__pk__"
          # cache vector
          EliteBattle.add_vector(vector.upcase.to_sym,
            metrics[section][vector]['XY'][0], metrics[section][vector]['XY'][1],
            metrics[section][vector]['ANGLE'][0],
            metrics[section][vector]['SCALE'][0],
            metrics[section][vector]['ZOOM'][0]
          )
        end
      end
    # configure battler position
    elsif section.upcase.include?("BATTLERPOS-")
      index = section.split("-")[-1].to_i
      args = [index]; sel = [:X, :Y, :Z]
      for j in 0...sel.length
        # add coordinate
        args.push(sel[j])
        for set in metrics[section].keys
          args.push(metrics[section][set]["XYZ"][j]) if metrics[section][set]
        end
        EliteBattle.battler_position(*args)
      end
    end
  end
end
