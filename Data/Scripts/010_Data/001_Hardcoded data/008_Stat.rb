# The id_number value determines which order the stats are iterated through by
# the "each" methods.
# The pbs_order value determines the order in which the stats are written in
# several PBS files, where base stats/IVs/EVs/EV yields are defined. Only stats
# which are yielded by the "each_main" method can have stat numbers defined in
# those places. The values of pbs_order defined below should start with 0 and
# increase without skipping any numbers.
module GameData
  class Stat
    attr_reader :id
    attr_reader :id_number
    attr_reader :real_name
    attr_reader :real_name_brief
    attr_reader :type
    attr_reader :pbs_order

    DATA = {}

    extend ClassMethods
    include InstanceMethods

    def self.load; end
    def self.save; end

    # These stats are defined in PBS files, and should have the :pbs_order
    # property.
    def self.each_main
      self.each { |s| yield s if [:main, :main_battle].include?(s.type) }
    end

    def self.each_main_battle
      self.each { |s| yield s if [:main_battle].include?(s.type) }
    end

    # These stats have associated stat stages in battle.
    def self.each_battle
      self.each { |s| yield s if [:main_battle, :battle].include?(s.type) }
    end

    def initialize(hash)
      @id              = hash[:id]
      @id_number       = hash[:id_number]  || -1
      @real_name       = hash[:name]       || "Unnamed"
      @real_name_brief = hash[:name_brief] || "None"
      @type            = hash[:type]       || :none
      @pbs_order       = hash[:pbs_order]  || -1
    end

    # @return [String] the translated name of this stat
    def name
      return _INTL(@real_name)
    end

    # @return [String] the translated brief name of this stat
    def name_brief
      return _INTL(@real_name_brief)
    end
  end
end

#===============================================================================

GameData::Stat.register({
  :id         => :HP,
  :id_number  => 0,
  :name       => _INTL("HP"),
  :name_brief => _INTL("HP"),
  :type       => :main,
  :pbs_order  => 0
})

GameData::Stat.register({
  :id         => :ATTACK,
  :id_number  => 1,
  :name       => _INTL("Attack"),
  :name_brief => _INTL("Atk"),
  :type       => :main_battle,
  :pbs_order  => 1
})

GameData::Stat.register({
  :id         => :DEFENSE,
  :id_number  => 2,
  :name       => _INTL("Defense"),
  :name_brief => _INTL("Def"),
  :type       => :main_battle,
  :pbs_order  => 2
})

GameData::Stat.register({
  :id         => :SPECIAL_ATTACK,
  :id_number  => 3,
  :name       => _INTL("Special Attack"),
  :name_brief => _INTL("SpAtk"),
  :type       => :main_battle,
  :pbs_order  => 4
})

GameData::Stat.register({
  :id         => :SPECIAL_DEFENSE,
  :id_number  => 4,
  :name       => _INTL("Special Defense"),
  :name_brief => _INTL("SpDef"),
  :type       => :main_battle,
  :pbs_order  => 5
})

GameData::Stat.register({
  :id         => :SPEED,
  :id_number  => 5,
  :name       => _INTL("Speed"),
  :name_brief => _INTL("Spd"),
  :type       => :main_battle,
  :pbs_order  => 3
})

GameData::Stat.register({
  :id         => :ACCURACY,
  :id_number  => 6,
  :name       => _INTL("accuracy"),
  :name_brief => _INTL("Acc"),
  :type       => :battle
})

GameData::Stat.register({
  :id         => :EVASION,
  :id_number  => 7,
  :name       => _INTL("evasiveness"),
  :name_brief => _INTL("Eva"),
  :type       => :battle
})
