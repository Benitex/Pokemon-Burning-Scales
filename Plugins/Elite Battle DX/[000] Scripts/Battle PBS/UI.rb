#===============================================================================
# setup EBDX UI
#===============================================================================
EliteBattle.configProcess(:UI) do
  # configure metrics data
  next if !File.safeData?("Data/ui.ebdx")
  echoln "  -> configuring UI data..."
  metrics = load_data("Data/ui.ebdx")
  # iterate through all the sections
  for section in metrics.keys
    if ["PLAYERDATABOX", "ENEMYDATABOX", "BOSSDATABOX"].include?(section.upcase)
      options = {}
      for key in metrics[section].keys
        # primary section
        if key == "__pk__"
          for smod in ['', 'HPBar', 'EXPBar']
            options[(smod.upcase + 'X').to_sym] = metrics[section][key][(smod + 'XY')][0] if metrics[section][key][(smod + 'XY')]
            options[(smod.upcase + 'Y').to_sym] = metrics[section][key][(smod + 'XY')][1] if metrics[section][key][(smod + 'XY')]
          end
          for set in ['ShowHP', 'ExpBarWidth', 'HPBarWidth', 'Bitmap', 'HPColors', 'Container', 'ExpandInDoubles']
            options[set.upcase.to_sym] = metrics[section][key][set][0] if metrics[section][key][set]
          end
        # every other section
        elsif metrics[section][key]['XYZ']
          options[key.downcase] = { :x => metrics[section][key]['XYZ'][0], :y => metrics[section][key]['XYZ'][1], :z => metrics[section][key]['XYZ'][2]}
        end
      end
      # register options
      EliteBattle.add_data(section.upcase.to_sym, :METRICS, options)
    # configure command menu
    elsif section.upcase == "COMMANDMENU"
      options = {}
      # primary section
      for set in ['BarGraphic', 'SelectorGraphic', 'ButtonGraphic', 'PartyLineGraphic']
        options[set.upcase.to_sym] = metrics[section]["__pk__"][set][0] if metrics[section]["__pk__"] && metrics[section]["__pk__"][set]
      end
      # register options
      EliteBattle.add_data(section.upcase.to_sym, :METRICS, options)
    # configure fight menu
    elsif section.upcase == "FIGHTMENU"
      options = {}
      # primary section
      for set in ['BarGraphic', 'SelectorGraphic', 'ButtonGraphic', 'MegaButtonGraphic', 'TypeGraphic', 'CategoryGraphic', 'ShowTypeAdvantage']
        options[set.upcase.to_sym] = metrics[section]["__pk__"][set][0] if metrics[section]["__pk__"] && metrics[section]["__pk__"][set]
      end
      # register options
      EliteBattle.add_data(section.upcase.to_sym, :METRICS, options)
    # configure target menu
    elsif section.upcase == "TARGETMENU"
      options = {}
      # primary section
      for set in ['SelectorGraphic', 'ButtonGraphic']
        options[set.upcase.to_sym] = metrics[section]["__pk__"][set][0] if metrics[section]["__pk__"] && metrics[section]["__pk__"][set]
      end
      # register options
      EliteBattle.add_data(section.upcase.to_sym, :METRICS, options)
    # configure bag UI
    elsif section.upcase == "BAGMENU"
      options = {}
      # primary section
      for set in ['PocketButtons', 'LastItem', 'BackButton', 'ItemFrame', 'PocketName', 'SelectorGraphic', 'ItemConfirm', 'ItemCancel', 'Shade', 'PocketIcons']
        options[set.upcase.to_sym] = metrics[section]["__pk__"][set][0] if metrics[section]["__pk__"] && metrics[section]["__pk__"][set]
      end
      # register options
      EliteBattle.add_data(section.upcase.to_sym, :METRICS, options)
    end
  end
end
