#===============================================================================
#  Additions to the Pokemon class for additional functionality
#===============================================================================
class Pokemon
  attr_accessor :superHue
  attr_accessor :superVariant
  attr_accessor :forceSuper
  attr_accessor :dynamax
  attr_accessor :gfactor
  #-----------------------------------------------------------------------------
  #  function to implement perfect IV overide
  #-----------------------------------------------------------------------------
  alias initialize_ebdx initialize unless self.method_defined?(:initialize_ebdx)
  def initialize(*args)
    initialize_ebdx(*args)
    # adjust next IVs if applicable
    d1 = EliteBattle.get(:nextBattleData)
    d1 = (d1 && d1[:PERFECT_IVS]) ? d1[:PERFECT_IVS] : nil
    d2 = EliteBattle.get_data(self.species, :Species, :PERFECT_IVS)
    # try to apply perfect IVs
    for data in [d1, d2]
      next if !data.is_a?(Numeric) || data < 1 || self.shiny?
      stats = self.iv.keys.clone
      # apply stats
      [data, stats.length].min.times do
        i = rand(stats.length)
        self.iv[stats[i]] = Pokemon::IV_STAT_LIMIT
        stats.delete_at(i)
      end
    end
    # re-calculate stats
    self.calc_stats
  end
  #-----------------------------------------------------------------------------
  #  function to implement additional shiny variants
  #-----------------------------------------------------------------------------
  alias shiny_ebdx shiny? unless self.method_defined?(:shiny_ebdx)
  def shiny?
    self.adjust_shiny
    return self.superShiny? ? true : shiny_ebdx
  end
  #-----------------------------------------------------------------------------
  #  function to check whether additional shiny variant is applied
  #-----------------------------------------------------------------------------
  def superShiny?
    return self.superHue.is_a?(Numeric) ? true : false
  end
  #-----------------------------------------------------------------------------
  #  make the Pokemon a super shiny variant and adjust values
  #-----------------------------------------------------------------------------
  def adjust_shiny
    # exit if already generated
    return if !self.superVariant.nil?
    self.superVariant = false
    self.superHue = false
    # get cached battle data
    data = EliteBattle.get(:nextBattleData)
    data = {} if !data.is_a?(Hash)
    # force shiny based on cached data
    sRate = data.has_key?(:SHINY_RATE) ? data[:SHINY_RATE] : 0
    self.shiny = true if sRate > 0 && (rand(100000) < sRate*1000)
    # get super shiny rate
    ssRate = data.has_key?(:SUPER_SHINY_RATE) ? data[:SUPER_SHINY_RATE] : EliteBattle::SUPER_SHINY_RATE
    # apply super variant
    if self.shiny_ebdx && ssRate && ssRate > 0
      if self.forceSuper || (rand(100000) < ssRate*1000)
        self.superHue = (1 + rand(7))*45
        self.superVariant = (rand(2) == 0) ? true : false
      end
    end
    # adjust IVs if applicable
    self.adjust_shiny_iv
  end
  #-----------------------------------------------------------------------------
  #  adjust IV values for shiny Pokemon
  #-----------------------------------------------------------------------------
  def adjust_shiny_iv
    return if !self.shiny_ebdx
    # check cached data as well
    d1 = EliteBattle.get(:nextBattleData)
    d1 = (d1 && d1[:PERFECT_IVS]) ? d1[:PERFECT_IVS] : nil
    d2 = EliteBattle.get_data(self.species, :Species, :PERFECT_IVS)
    # set perfect IVs for shiny mons
    perfect = self.superShiny? ? EliteBattle::PERFECT_IV_SUPER : EliteBattle::PERFECT_IV_SHINY
    perfect = [perfect, (d1 ? d1 : 0), (d2 ? d2 : 0)].max
    return if !perfect.is_a?(Numeric) || perfect < 1
    stats = self.iv.keys.clone
    # apply stats
    [perfect, stats.length].min.times do
      i = rand(stats.length)
      self.iv[stats[i]] = Pokemon::IV_STAT_LIMIT
      stats.delete_at(i)
    end
    # recalculate stats
    self.calc_stats
  end
  #-----------------------------------------------------------------------------
  #  Adjustment to stat re-calculation
  #-----------------------------------------------------------------------------
  def calc_stats(basestat = nil, boss = false)
    base_stats = basestat.is_a?(Array) ? basestat.clone : self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    # Format stat multipliers due to nature
    nature_mod = {}
    GameData::Stat.each_main { |s| nature_mod[s.id] = 100 }
    this_nature = self.nature_for_stats
    if this_nature
      this_nature.stat_changes.each { |change| nature_mod[change[0]] += change[1] }
    end
    # Calculate stats
    stats = {}; i = 0
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = (calcHP(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id]) * (boss ? boss[s.id] : 1)).round
      else
        stats[s.id] = (calcStat(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id], nature_mod[s.id]) * (boss ? boss[s.id] : 1)).round
      end
    end
    hpDiff = @totalhp - @hp
    @totalhp = stats[:HP]
    @hp      = @totalhp - hpDiff
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end
  #-----------------------------------------------------------------------------
  #  sauce
  #-----------------------------------------------------------------------------
  alias name_ebdx name unless self.method_defined?(:name_ebdx)
  def name
    return _INTL("Bidoof") if GameData::Species.exists?(:BIDOOF) && defined?(firstApr?) && firstApr?
    hide = EliteBattle.get_data(self.species, :Species, :HIDENAME, (self.form rescue 0)) && !$Trainer.owned?(self.species)
    return hide ? _INTL("???") : self.name_ebdx
  end
  #-----------------------------------------------------------------------------
end
