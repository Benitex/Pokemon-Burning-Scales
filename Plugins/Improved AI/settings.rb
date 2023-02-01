#===============================================================================
# Settings
#===============================================================================
module Settings
  #-----------------------------------------------------------------------------
  # Exponents
  #-----------------------------------------------------------------------------
  # These determine how much more weight should be applied to higher-scoring
  # moves.
  #
  # The exact power applied is determined by the opponent's skill level. The
  # higher the number, the more the game favors the highest-scoring move.
  # 
  # Increasing this value too much can lead to integer overflow. Please avoid
  # values over 12.
  #-----------------------------------------------------------------------------
  MIN_EXPONENT = 1.5
  MAX_EXPONENT = 6.0
end
