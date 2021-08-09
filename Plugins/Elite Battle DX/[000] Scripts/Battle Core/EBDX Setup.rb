#===============================================================================
#  Main Utility Module for Elite Battle: DX
#-------------------------------------------------------------------------------
#  used to store and manipulate all of the configurable data and much more
#===============================================================================
module EliteBattle
  @@configData = {}
  #-----------------------------------------------------------------------------
  #  function used to store PBS config
  #-----------------------------------------------------------------------------
  def self.configProcess(id, process = nil, &block)
    # raise error message for incorrectly defined moves
    if process.nil? && block.nil?
      EliteBattle.log.error("EBDX: No code block defined PBS config #{id}!")
    end
    # register regular move animation
    @@configData[id] = !process.nil? ? process : block
  end
  #-----------------------------------------------------------------------------
  #  check if configuration is defined
  #-----------------------------------------------------------------------------
  def self.configPresent?(name)
    return @@configData.has_key?(name.upcase.to_sym)
  end
  #-----------------------------------------------------------------------------
  # common configurations for PBS
  #-----------------------------------------------------------------------------
  def self.commonConfig(metrics, args, key)
    # set up common PBS configs
    confs = {
      "DATABOX" => {
        :smod => [''],
        :set => ['ShowHP', 'ExpBarWidth', 'HPBarWidth', 'Bitmap', 'HPColors', 'Container']
      },
      "COMMANDMENU" => {
        :set => ['BarGraphic', 'SelectorGraphic', 'ButtonGraphic']
      },
      "FIGHTMENU" => {
        :set => ['BarGraphic', 'SelectorGraphic', 'ButtonGraphic', 'MegaButtonGraphic', 'TypeGraphic', 'CategoryGraphic', 'ShowTypeAdvantage']
      },
      "TARGEMENU" => {
        :set => ['SelectorGraphic', 'ButtonGraphic']
      },
      "BAGMENU" => {
        :set => ['PocketButtons', 'LastItem', 'BackButton', 'ItemFrame', 'PocketName', 'SelectorGraphic', 'ItemConfirm', 'ItemCancel', 'Shade', 'PocketIcons']
      }
    }
    # go through all the common keys
    for ckey in confs.keys
      options = {}
      # additional XY modifiers
      if confs[ckey].has_key?(:smod)
        for smod in confs[ckey][:smod]
          next if !metrics[key][ckey] || !metrics[key][ckey][(smod + 'XY')]
          options[(smod.upcase + 'X').to_sym] = metrics[key][ckey][(smod + 'XY')][0]
          options[(smod.upcase + 'Y').to_sym] = metrics[key][ckey][(smod + 'XY')][1]
        end
      end
      # iterate through the sets of data
      if confs[ckey].has_key?(:set)
        for set in confs[ckey][:set]
          next if !metrics[key][ckey] || !metrics[key][ckey][set]
          options[set.upcase.to_sym] = metrics[key][ckey][set][0]
        end
      end
      # add options
      if options.keys.length > 0
        args.push((ckey + "_METRICS").to_sym); args.push(options)
      end
    end
    # return array output
    return args
  end
  #-----------------------------------------------------------------------------
  # setup EBDX data
  #-----------------------------------------------------------------------------
  def self.setupData
    echoln "Setting up compiled Elite Battle: DX data...\r\n"
    # setup PBS config
    for key in @@configData.keys
      @@configData[key].call
    end
  end
end
#===============================================================================
# run data setup
module Game
  #-----------------------------------------------------------------------------
  class << Game
    alias initialize_ebdx initialize
  end
  #-----------------------------------------------------------------------------
  def self.initialize
    # run Essentials compiler
    initialize_ebdx
    # append EBDX version number
    version = PluginManager.version("Elite Battle: DX")
    Essentials::ERROR_TEXT += "[EBDX v#{version}]\r\n"
    # run compiled data
    EliteBattle.setupData
    # run any data temporarily cached
    CompilerEBDX.addFromCached
    echoln "\r\nSuccessfully loaded all Elite Battle: DX data.\r\n"
  end
  #-----------------------------------------------------------------------------
end
