#===============================================================================
# Automatic Level Scaling Difficulty class
# By Benitex
#===============================================================================

class Difficulty
  attr_accessor :fixed_increase
  attr_accessor :random_increase

  def initialize(fixed_increase: 0, random_increase: 0)
    @random_increase = random_increase
    @fixed_increase = fixed_increase
  end
end
