class PokeBattle_AI
  #=============================================================================
  # Main move-choosing method (moves with higher scores are more likely to be
  # chosen)
  #=============================================================================

  def pbChooseMoves(idxBattler)
    user        = @battle.battlers[idxBattler]
    wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
    skill       = 0
    exponent    = 1
    if !wildBattler
      skill     = @battle.pbGetOwnerFromBattlerIndex(user.index).skill_level || 0
      # Set the exponent to a number in the range based on the opponent's skill level
      exponent  = Settings::MIN_EXPONENT + (Settings::MAX_EXPONENT - Settings::MIN_EXPONENT) * (skill/100.0)
    end

    # Get scores and targets for each move
    # NOTE: A move is only added to the choices array if it has a non-zero score.
    choices         = []
    weightedChoices = []
    user.eachMoveWithIndex do |_m, i|
      next if !@battle.pbCanChooseMove?(idxBattler, i, false)
      if wildBattler
        pbRegisterMoveWild(user, i, choices)
        weightedChoices.push(choices[choices.length-1])
      else
        pbRegisterMoveTrainer(user, i, choices, skill)
        #weightedChoices.push(choices[choices.length-1])
      end
    end
    # Figure out useful information about the choices
    totalScore         = 0
    totalWeightedScore = 0
    maxScore           = 0
    maxWeightedScore   = 0
    choices.each do |c|
      totalScore += c[1]
      maxScore = c[1] if maxScore < c[1]
      # Populate the weightedChoices array
      if !wildBattler
        weightedChoices.push([])
        c.each do |i|
          weightedChoices[weightedChoices.length-1].push(i)
        end
        # By applying an exponent to the score, higher values become much more favored by the RNG
        # The raw score is divided by 50 before applying the exponent to reduce the risk of overflow
        weightedChoices[weightedChoices.length-1][1] = ((c[1]/50.0) ** exponent).floor()
      end
    end
    weightedChoices.each do |c|
      totalWeightedScore += c[1]
      maxWeightedScore = c[1] if maxScore < c[1]
    end
    # Log the available choices
    if $INTERNAL
      logMsg = "[AI] Move choices for #{user.pbThis(true)} (#{user.index}): raw: ("
      choices.each_with_index do |c, i|
        logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
        logMsg += " (target #{c[2]})" if c[2] >= 0
        logMsg += ", " if i < choices.length - 1
      end
      logMsg += "), weighted: ("
      weightedChoices.each_with_index do |c, i|
        logMsg += "#{user.moves[c[0]].name}=#{c[1]}"
        logMsg += " (target #{c[2]})" if c[2] >= 0
        logMsg += ", " if i < choices.length - 1
      end
      logMsg += ")"
      PBDebug.log(logMsg)
    end

    # Decide whether all choices are bad, and if so, try switching instead
    if !wildBattler && skill >= PBTrainerAI.highSkill
      badMoves = false
        if $INTERNAL
          PBDebug.log("MaxScore: #{maxScore}, TotalScore: #{totalScore}, turnCount: #{user.turnCount}")
        end
      if ((maxScore <= 30 && user.turnCount > 1) ||
         (maxScore <= 60 && user.turnCount > 3)) && pbAIRandom(100) < 80
        badMoves = true
      end
      if !badMoves && totalScore < 100 && user.turnCount > 1
        badMoves = true
        choices.each do |c|
          next if !user.moves[c[0]].damagingMove?
          badMoves = false
          break
        end
        badMoves = false if badMoves && pbAIRandom(100) < 10
      end
      if badMoves && pbEnemyShouldWithdrawEx?(idxBattler, true)
        if $INTERNAL
          PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will switch due to terrible moves")
        end
        return
      end
    end
    # If there are no calculated choices, pick one at random
    if choices.length == 0
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) doesn't want to use any moves; picking one at random")
      user.eachMoveWithIndex do |_m, i|
        next if !@battle.pbCanChooseMove?(idxBattler, i, false)
        choices.push([i, 100, -1])   # Move index, score, target
      end
      if choices.length == 0   # No moves are physically possible to use; use Struggle
        @battle.pbAutoChooseMove(user.index)
      end
    end
    # Randomly choose a move from the choices and register it
    randNum = pbAIRandom(totalScore)
    choices.each do |c|
      randNum -= c[1]
      next if randNum >= 0
      @battle.pbRegisterMove(idxBattler, c[0], false)
      @battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
      break
    end
    # Choose a move based off of the weighted score values
    if !wildBattler && maxScore > 100
      randNum = pbAIRandom(totalWeightedScore)
      if $INTERNAL
        logMsg = "(randNum = #{randNum.to_s}; "
        PBDebug.log(logMsg)
      end
      weightedChoices.each do |c|
        randNum -= c[1]
        if $INTERNAL
          logMsg = "#{user.moves[c[0]].name}: -#{c[1]} = #{randNum.to_s}; "
          PBDebug.log(logMsg)
        end
        next if randNum >= 0
        @battle.pbRegisterMove(idxBattler, c[0], false)
        @battle.pbRegisterTarget(idxBattler, c[2]) if c[2] >= 0
        if $INTERNAL
          logMsg = "selected #{user.moves[c[0]].name})"
          PBDebug.log(logMsg)
        end
        break
      end
    end
    # Log the result
    if @battle.choices[idxBattler][2]
      PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use #{@battle.choices[idxBattler][2].name}")
    end
  end
  
  #=============================================================================
  # Add to a move's score based on how much damage it will deal (as a percentage
  # of the target's current HP)
  #=============================================================================
  def pbGetMoveScoreDamage(score, move, user, target, skill)
    return 0 if score <= 0
    # Calculate how much damage the move will do (roughly)
    baseDmg = pbMoveBaseDamage(move, user, target, skill)
    realDamage = pbRoughDamage(move, user, target, skill, baseDmg)
    # Account for accuracy of move
    accuracy = pbRoughAccuracy(move, user, target, skill)
    realDamage *= accuracy / 100.0
    # Two-turn attacks waste 2 turns to deal one lot of damage
    if move.chargingTurnMove? || move.function == "AttackAndSkipNextTurn"   # Hyper Beam
      realDamage *= 2 / 3   # Not halved because semi-invulnerable during use or hits first turn
    end
    # Prefer flinching external effects (note that move effects which cause
    # flinching are dealt with in the function code part of score calculation)
    if skill >= PBTrainerAI.mediumSkill && !move.flinchingMove? &&
       !target.hasActiveAbility?(:INNERFOCUS) &&
       !target.hasActiveAbility?(:SHIELDDUST) &&
       target.effects[PBEffects::Substitute] == 0
      canFlinch = false
      if user.hasActiveItem?([:KINGSROCK, :RAZORFANG]) ||
         user.hasActiveAbility?(:STENCH)
        canFlinch = true
      end
      realDamage *= 1.1 if canFlinch
    end
    # Convert damage to percentage of target's remaining HP
    damagePercentage = realDamage * 100.0 / target.hp
    # Don't prefer weak attacks
    damagePercentage /= 2 if damagePercentage<20
    # Prefer damaging attack if level difference is significantly high
    damagePercentage *= 1.2 if user.level - 10 > target.level
    # Adjust score
    damagePercentage = 120 if damagePercentage > 120   # Treat all lethal moves the same
    damagePercentage += 40 if damagePercentage > 100   # Prefer moves likely to be lethal
    score += damagePercentage.to_i
    # prefer super effective moves
    score += pbCalcTypeLinear(move.type, user, target) * 13
    return score
  end
end
