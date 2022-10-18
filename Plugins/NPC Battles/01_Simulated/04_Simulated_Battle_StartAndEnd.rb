class PokeBattle_Simulated_Battle
  #=============================================================================
  # Send out all battlers at the start of battle
  #=============================================================================
  def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        pbDisplayPaused(_INTL("Oh! A wild {1} appeared!",foeParty[0].name))
      when 2
        pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,
           foeParty[1].name))
      when 3
        pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,
           foeParty[1].name,foeParty[2].name))
      end
    else   # Trainer battle
      playerNames = []

      for i in @player
          name = @useFullPlayerNames ? i.fullname : i.name
          playerNames.push(name)
      end
      
      opponentNames = []
      for i in @opponent
          name = @useFullOpponentNames ? i.fullname : i.name
          opponentNames.push(name)
      end
      
      playerSide =  playerNames[0] + " is"
      case playerNames.length
        when 2
          playerSide =  playerNames[0] + " and " + playerNames[1] + " are"
        when 3
          playerSide =  playerNames[0] + ", " + playerNames[1] + " and " + playerNames[2] + " are"
      end  
      
      case opponentNames.length
      when 1
        pbDisplayPaused(_INTL("{1} challenged by {2}!",playerSide,opponentNames[0]))
      when 2
        pbDisplayPaused(_INTL("{1} challenged by {2} and {3}!",playerSide,opponentNames[0],
           opponentNames[1]))
      when 3
        pbDisplayPaused(_INTL("{1} challenged by {2}, {3} and {4}!",
           playerSide,opponentNames[0],opponentNames[1],opponentNames[2]))
      end
    end
    # Send out Pokémon (opposing trainers first)
    for side in [1,0]
      next if side==1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side==0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t,i|
        next if side==0 && i==0   # The player's message is shown last
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!",pbGetNameOf(t,true),@battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!",pbGetNameOf(t,true),
             @battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!",pbGetNameOf(t,true),
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side==0
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!",@battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!",@battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length>0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler,@battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts,false)
    end
  end

  

  #=============================================================================
  # Main battle loop
  #=============================================================================
  def pbBattleLoop
    @turnCount = 0
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log("***Round #{@turnCount+1}***")
      if @debug && @turnCount>=100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.log("")
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision>0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision>0
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision>0
      @turnCount += 1
    end
    pbEndOfBattle
  end

  #=============================================================================
  # End of battle
  #=============================================================================

  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
    
    if !wildBattle?
    playerNames = []
        for i in @player
          name = @useFullPlayerNames ? i.fullname : i.name
          playerNames.push(name)
        end
      
        opponentNames = []
        for i in @opponent
          name = @useFullOpponentNames ? i.fullname : i.name
          opponentNames.push(name)
        end
      
        playerSide =  playerNames[0]
        case playerNames.length
          when 2
            playerSide =  playerNames[0] + " and " + playerNames[1]
          when 3
            playerSide =  playerNames[0] + ", " + playerNames[1] + " and " + playerNames[2]
        end  
    end
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player Side won***")
      if !@endMessage.nil?
        pbDisplayPaused(formatText(@endMessage))
      end
      playerSideWin(playerSide,opponentNames)
    ##### Giving Up #####
    when 6,7
      PBDebug.log("")
      PBDebug.log("***Player forfeited***") if @decision==6
      PBDebug.log("***Opponent forfeited***") if @decision==7
      forfeiter = @decision==6 ? playerSide : opponentNames
      if @endMessage.nil?
        pbDisplayPaused(_INTL("#{forfeiter} gave up!"))
      else
        pbDisplayPaused(formatText(@endMessage))
      end
      if @decision==7
        playerSideWin(playerSide,opponentNames)
      else
        playerSideLose(playerSide,opponentNames)
      end
      
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if !@endMessage.nil?
        pbDisplayPaused(formatText(@endMessage))
      end
      playerSideLose(playerSide,opponentNames)
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    return @decision
  end
  
  
  def playerSideWin(playerSide,opponentNames)
    if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("{1} defeated {2}!",playerSide,opponentNames[0]))
        when 2
          pbDisplayPaused(_INTL("{1} defeated {2} and {3}!",playerSide,opponentNames[0],
             opponentNames[1]))
        when 3
          pbDisplayPaused(_INTL("{1} defeated {2}, {3} and {4}!",playerSide,opponentNames[0],
             opponentNames[1],opponentNames[2]))
        end
        @opponent.each_with_index do |t,i|
          msg = (@endSpeeches[i] && @endSpeeches[i]!="") ? @endSpeeches[i] : nil
          next if msg.nil?
          @scene.pbShowOpponent(i)
          pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name)) 
        end
      end
        
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
  end
  
  def playerSideLose(playerSide,opponentNames)
    if @internalBattle
        pbDisplayPaused(_INTL("#{playerSide} have no more Pokémon that can fight!")) if @decision!=6
        if trainerBattle?
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("{1} lost against {2}!",playerSide,opponentNames[0]))
          when 2
            pbDisplayPaused(_INTL("{1} lost against {2} and {3}!",playerSide,
               opponentNames[0],opponentNames[1]))
          when 3
            pbDisplayPaused(_INTL("{1} lost against {2}, {3} and {4}!",playerSide,
               opponentNames[0],opponentNames[1],opponentNames[2]))
          end
        end
        @player.each_with_index do |t,i|
            
            msg = (@playerEndspeeches[i] && @playerEndspeeches[i]!="") ? @playerEndspeeches[i] : nil
            next if msg.nil?
            # @scene.pbShowTrainerForMessage(i,"player_")
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name)) if !msg.nil?
          end
        pbDisplayPaused(_INTL("#{playerSide} blacked out!")) if !@canLose
      end
  end
  
  
end