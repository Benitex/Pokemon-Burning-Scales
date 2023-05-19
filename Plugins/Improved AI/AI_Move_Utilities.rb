class PokeBattle_AI
  def pbCalcTypeLinear(moveType, user, target)
    ret = pbCalcTypeMod(moveType, user, target)
    # triple-type support
    ret *= ret
    # convert to linear scale
    if ret > 0
      ret = Math.log(ret, 2).round(0)
      # offset values so that 0 = neutral, <0 = not very effective, >0 = super
      ret -= 6
    else
      ret = 0  # Set a default value when ret is non-positive
    end
    return ret
  end
end
