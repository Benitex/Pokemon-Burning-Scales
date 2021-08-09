#===============================================================================
#  Compiler Module for Elite Battle: DX
#-------------------------------------------------------------------------------
#  used to compile PBS data and interpret them on run-time
#===============================================================================
module CompilerEBDX
  #-----------------------------------------------------------------------------
  # get base maps to compile
  #-----------------------------------------------------------------------------
  def self.getCompileMaps
    files = []
    Dir.get("PBS/EBDX", "*.txt", false).each do |d|
      f = d.split(".")[0]
      files.push(f) if !files.include?(f) && EliteBattle.configPresent?(f)
    end
    return files
  end
  #-----------------------------------------------------------------------------
  # compile all the necessary PBS data
  #-----------------------------------------------------------------------------
  def self.compile(mustCompile = false)
    return if !$DEBUG || !Dir.safe?("PBS/EBDX") || safeExists?("Game.rgssad")
    pbSetWindowText("Compiling EBDX data")
    pbs = Dir.get("PBS/EBDX", "*.txt", false)
    # show message
    echoln ""
    comp = false
    # iterate through possible PBS files
    for filename in self.getCompileMaps
      #------------------------------------------------------------------------
      refresh = !safeExists?("Data/#{filename}.ebdx")
      refresh = true if Input.press?(Input::CTRL) || mustCompile
      # main handler for base file
      refresh = true if !refresh && safeExists?("PBS/EBDX/#{filename}.txt") && File.mtime("PBS/EBDX/#{filename}.txt") > File.mtime("Data/#{filename}.ebdx")
      # iterate through all possible packs
      for f in pbs
        # skip if main or not part of current iterable
        next if f == "#{filename}.txt" || !f.start_with?(filename) || refresh
        refresh = true if File.mtime("PBS/EBDX/#{f}") > File.mtime("Data/#{filename}.ebdx")
      end
      # refresh if compiled data is older than compiled scripts
      refresh = true if !refresh && safeExists?("Data/#{filename}.ebdx") && safeExists?("Data/PluginScripts.rxdata") && File.mtime("Data/PluginScripts.rxdata") > File.mtime("Data/#{filename}.ebdx")
      #------------------------------------------------------------------------
      next if !refresh
      # show message
      if !comp
        echoln "Compiling Elite Battle: DX data...\r\n"; comp = true
      end
      echoln "  -> compiling `#{filename.downcase}.txt` data..."
      read = {}
      # read main PBS
      read.deep_merge!(Env.interpret("PBS/EBDX/#{filename}.txt")) if safeExists?("PBS/EBDX/#{filename}.txt")
      # iterate through all possible packs
      for f in pbs
        # skip if main or not part of current iterable
        next if f == "#{filename}.txt" || !f.start_with?(filename)
        read.deep_merge!(Env.interpret("PBS/EBDX/#{f}"))
      end
      #------------------------------------------------------------------------
      # compile PBS data
      save_data(read, "Data/#{filename}.ebdx")
    end
    # clean up
    GC.start
    echoln comp ? "\r\nCompiled all Elite Battle: DX data.\r\n" : "\r\nAll Elite Battle: DX data already compiled.\r\n"
    EliteBattle.set(:compiled, true)
    pbSetWindowText(nil)
  end
  #-----------------------------------------------------------------------------
  # interpret all the data from cache
  #-----------------------------------------------------------------------------
  def self.addFromCached
    return if !$DEBUG
    # get cache
    cache = EliteBattle.get(:cachedData)
    for ch in cache
      # run each from cache
      EliteBattle.add_data(*ch)
    end
    # clear cache
    cache.clear
    EliteBattle.set(:cachedData, [])
    # force start garbage collector
    GC.start
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
# run compiler
module Compiler
  #-----------------------------------------------------------------------------
  class << Compiler
    alias compile_all_ebdx compile_all
  end
  #-----------------------------------------------------------------------------
  def self.compile_all(mustCompile)
    # run Essentials compiler
    compile_all_ebdx(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
    # compile EBDX
    CompilerEBDX.compile(mustCompile)
  end
  #-----------------------------------------------------------------------------
end
