#===============================================================================
#  EBS DX Battle Core processing
#===============================================================================
class PokeBattle_Battle
  attr_accessor :battlescene, :opponents, :players
  #-----------------------------------------------------------------------------
  #  compatibility layer
  #-----------------------------------------------------------------------------
  def doublebattle?; return (pbSideSize(0) > 1 || pbSideSize(1) > 1); end
  def triplebattle?; return (pbSideSize(0) > 2 || pbSideSize(1) > 2); end
  def pbMaxSize(index = nil)
    return [pbSideSize(0), pbSideSize(1)].max if index.nil?
    return pbSideSize(index)
  end
  alias pbInitialize_ebdx initialize unless self.method_defined?(:pbInitialize_ebdx)
  def initialize(*args)
    # initialize battle messages
    @midspeech = EliteBattle.get(:nextBattleScript)
    @midspeech.uniq! if @midspeech.is_a?(Array)
    # override
    @battlescene = true
    return pbInitialize_ebdx(*args)
  end
  #-----------------------------------------------------------------------------
  #  Display battle start messages
  #-----------------------------------------------------------------------------
  def pbStartBattleSendOut(sendOuts)
    EliteBattle.set(:smAnim, false) if @opponent && opponent.length > 1
    @scene.sendingOut = true
    # get array of opponents
    foes = wildBattle? ? pbParty(1) : @opponent
    # Wild battlers
    memb = []; text = wildBattle? ? "Oh! A wild " : "You are challenged by "
    foes.each_with_index do |foe, i|
      memb.push(wildBattle? ? foe.name : foe.full_name)
      text += ", " if i > 0 && i < foes.length - 1
      text += " and " if i == foes.length - 1 && foes.length > 1
      text += "{#{i+1}}"
    end
    text += wildBattle? ? " appeared!" : "!"
    pbDisplayPaused(EliteBattle.battle_text(text, *memb))
    if wildBattle? && foes.length < 2
      # set boss immunities
      @battlers[1].immunity = true if EliteBattle.get(:setBoss)
      # additional special S/M styled VS sequence for wild battlers
      @scene.smSpeciesSequence.finish if @scene.smSpeciesSequence
      # plays stat increase
      @scene.raiseSpeciesStats
    elsif foes.length < 2
      # finishes up S/M VS sequence
      @scene.smTrainerSequence.finish if @scene.smTrainerSequence
      @scene.introdone = true
    end
    # Pokemon sendout (opposing trainers first)
    for side in [1, 0]
      next if side == 1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side == 0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t, i|
        next if side == 0 && i == 0   # The player's message is shown last
        msg += "\r\n" if msg.length > 0
        sent = sendOuts[side][i]
        memb = []; text = "{1} sent out "
        sent.each_with_index do |foe, j|
          memb.push(@battlers[foe].name)
          text += ", " if j > 0 && j < sent.length - 1
          text += " and " if j == sent.length - 1 && sent.length > 1
          text += "{#{j+2}}"
        end
        text += "!"
        msg += _INTL(text, t.full_name, *memb)
        toSendOut.concat(sent)
      end
      # Pokemon sendout (player battlers)
      if side == 0
        msg += "\r\n" if msg.length > 0
        sent = sendOuts[side][0]
        memb = []; text = "Go! "
        sent.each_with_index do |foe, j|
          memb.push(@battlers[foe].name)
          text += ", " if j > 0 && j < sent.length - 1
          text += " and " if j == sent.length - 1 && sent.length > 1
          text += "{#{j+1}}"
        end
        text += "!"
        msg += _INTL(text, *memb)
        toSendOut.concat(sent)
      end
      pbDisplayExtended(msg) if msg.length>0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler, @battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  Battle loop processing
  #-----------------------------------------------------------------------------
  alias pbBattleLoop_ebdx pbBattleLoop unless self.method_defined?(:pbBattleLoop_ebdx)
  def pbBattleLoop
    # displays text upon battle start (for wild battles)
    data = EliteBattle.get(:nextBattleData); data = {} if !data.is_a?(Hash)
    if data.has_key?(:WARN) && data[:WARN].is_a?(String) && !@opponent
      memb = []
      @battlers.each_with_index do |b, i|
        next if !b || i%2 == 0
        memb.push(b.name)
      end
      pbDisplay(_INTL(data[:WARN], *memb))
    end
    pbBattleLoop_ebdx
  end
  #-----------------------------------------------------------------------------
  #  replace current battler
  #-----------------------------------------------------------------------------
  alias pbReplace_ebdx pbReplace unless self.method_defined?(:pbReplace_ebdx)
  def pbReplace(index, *args)
    # displays trainer dialogue if applicable
    opt = playerBattler?(@battlers[index]) ? ["last", "beforeLast"] : ["lastOpp", "beforeLastOpp"]
    @scene.pbTrainerBattleSpeech(*opt)
    if !@replaced
      @battlers[index].pbResetForm
      if !@battlers[index].fainted?
        @scene.pbRecall(index)
      end
    end
    pbReplace_ebdx(index, *args)
    @replaced = false
    opt = playerBattler?(@battlers[index]) ? "afterLast" : "afterLastOpp"
    @scene.pbTrainerBattleSpeech(opt)
  end
  #-----------------------------------------------------------------------------
  #  recalls current battler
  #-----------------------------------------------------------------------------
  alias pbRecallAndReplace_ebdx pbRecallAndReplace unless self.method_defined?(:pbRecallAndReplace_ebdx)
  def pbRecallAndReplace(*args)
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech(playerBattler?(@battlers[args[0]]) ? "recall" : "recallOpp")
    @replaced = true
    # specifies sendout toggle
    @scene.sendingOut = true if args[0]%2 == 0
    return pbRecallAndReplace_ebdx(*args)
  end
  #-----------------------------------------------------------------------------
  #  enters command phase
  #-----------------------------------------------------------------------------
  alias pbCommandPhase_ebdx pbCommandPhase unless self.method_defined?(:pbCommandPhase_ebdx)
  def pbCommandPhase
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech("turnStart", "rand")
    pbCommandPhase_ebdx
    @scene.idleTimer = -1
  end
  #-----------------------------------------------------------------------------
  #  enters last phase of the round
  #-----------------------------------------------------------------------------
  alias pbEndOfRoundPhase_ebdx pbEndOfRoundPhase unless self.method_defined?(:pbEndOfRoundPhase_ebdx)
  def pbEndOfRoundPhase
    ret = pbEndOfRoundPhase_ebdx
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech("turnEnd", "rand")
    return ret
  end
  #-----------------------------------------------------------------------------
  #  enters attack phase
  #-----------------------------------------------------------------------------
  alias pbAttackPhase_ebdx pbAttackPhase unless self.method_defined?(:pbAttackPhase_ebdx)
  def pbAttackPhase
    @scene.pbTrainerBattleSpeech("turnAttack")
    ret = pbAttackPhase_ebdx
    @scene.afterAnim = false
    # waits for the scene to return to its original position
    @scene.wait(16, true)
    return ret
  end
  #-----------------------------------------------------------------------------
  #  pokemon capturing
  #-----------------------------------------------------------------------------
  alias pbThrowPokeBall_ebdx_2 pbThrowPokeBall unless self.method_defined?(:pbThrowPokeBall_ebdx_2)
  def pbThrowPokeBall(*args)
    @scene.pbTrainerBattleSpeech("beforeThrowBall")
    @scene.briefmessage = true
    ret = pbThrowPokeBall_ebdx_2(*args)
    @scene.pbTrainerBattleSpeech("afterThrowBall")
    return ret
  end
  #-----------------------------------------------------------------------------
  #  process battle end
  #-----------------------------------------------------------------------------
  alias pbEndOfBattle_ebdx pbEndOfBattle unless self.method_defined?(:pbEndOfBattle_ebdx)
  def pbEndOfBattle
    # displays trainer dialogue if applicable
    @scene.pbTrainerBattleSpeech("loss") if @decision == 2
    ret = pbEndOfBattle_ebdx
    # reset all the EBDX queues
    EliteBattle.reset(:nextBattleScript, :wildSpecies, :wildLevel, :wildForm, :nextBattleBack, :nextUI, :nextBattleData,
                     :wildSpecies, :wildLevel, :wildForm, :setBoss, :cachedBattler, :tviewport)
    EliteBattle.set(:setBoss, false)
    EliteBattle.set(:colorAlpha, 0)
    EliteBattle.set(:smAnim, false)
    # return final output
    return ret
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Extension for the GameData module to quickly grab all the stored keys
#  in the DATA set
#===============================================================================
module GameData
  #-----------------------------------------------------------------------------
  module ClassMethods
    def values(skip_similar = false)
      nkey = []
      for key in self::DATA.keys
        next if skip_similar && nkey.any? { |sym| key.to_s.include?(sym.to_s) }
        nkey.push(key) if key.is_a?(Symbol)
      end
      return nkey
    end
  end
  #-----------------------------------------------------------------------------
  module ClassMethodsSymbols
    def values(skip_similar = false)
      nkey = []
      for key in self::DATA.keys
        next if skip_similar && nkey.any? { |sym| key.to_s.include?(sym.to_s) }
        nkey.push(key) if key.is_a?(Symbol)
      end
      return nkey
    end
  end
  #-----------------------------------------------------------------------------
  module ClassMethodsIDNumbers
    def values(skip_similar = false)
      nkey = []
      for key in self::DATA.keys
        next if skip_similar && nkey.any? { |sym| key.to_s.include?(sym.to_s) }
        nkey.push(key) if key.is_a?(Symbol)
      end
      return nkey
    end
  end
end
