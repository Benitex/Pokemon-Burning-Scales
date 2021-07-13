#===============================================================================
# This class holds the information for an individual quest
#===============================================================================
class Quest
  attr_accessor :id
  attr_accessor :stage
  attr_accessor :time
  attr_accessor :location
  attr_accessor :new
  attr_accessor :color
  attr_accessor :story

  def initialize(id,color,story)
    self.id       = id
    self.stage    = 1
    self.time     = Time.now
    self.location = $game_map.name
    self.new      = true
    self.color    = color
    self.story    = story
  end
  
  def stage=(value)
    if value > $quest_data.getMaxStagesForQuest(self.id)
      value = $quest_data.getMaxStagesForQuest(self.id)
    end
    @stage = value
  end
end

#===============================================================================
# This class holds all the trainers quests
#===============================================================================
class Player_Quests
  attr_accessor :active_quests
  attr_accessor :completed_quests
  attr_accessor :failed_quests
  attr_accessor :selected_quest_id
  
  def initialize
    @active_quests     = []
    @completed_quests  = []
    @failed_quests     = []
    @selected_quest_id = 0
  end
  
  # questID should be the symbolic name of the quest, e.g. :Quest1
  def activateQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        pbMessage("You have already started this quest.")
        return
      end
    end
    for i in 0...@completed_quests.length
      if @completed_quests[i].id == quest
        pbMessage("You have already completed this quest.")
        return
      end
    end
    for i in 0...@failed_quests.length
      if @failed_quests[i].id == quest
        pbMessage("You have already failed this quest.")
        return
      end
    end
    @active_quests.push(Quest.new(quest,color,story))
    pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>New quest discovered!</c2>\nCheck your quest log for more details!</ac>",QUEST_JINGLE))
  end
  
  def failQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    found = false
    for i in 0...@completed_quests.length
      if @completed_quests[i].id == quest
        pbMessage("You have already completed this quest.")
        return
      end
    end
    for i in 0...@failed_quests.length
      if @failed_quests[i].id == quest
        pbMessage("You have already failed this quest.")
        return
      end
    end 
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        temp_quest = @active_quests[i]
        temp_quest.color = color if color != nil
        temp_quest.new = true # Setting this back to true makes the "!" icon appear when the quest updates
        temp_quest.time = Time.now
        @failed_quests.push(temp_quest)
        @active_quests.delete_at(i)
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>Quest failed!</c2>\nYour quest log has been updated!</ac>",QUEST_FAIL))
        break
      end
    end
    if !found
      color = colorQuest(nil) if color == nil
      @failed_quests.push(Quest.new(quest,color,story))
    end
  end
  
  def completeQuest(quest,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    found = false
    for i in 0...@completed_quests.length
      if @completed_quests[i].id == quest
        pbMessage("You have already completed this quest.")
        return
      end
    end
    for i in 0...@failed_quests.length
      if @failed_quests[i].id == quest
        pbMessage("You have already failed this quest.")
        return
      end
    end  
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        temp_quest = @active_quests[i]
        temp_quest.color = color if color != nil
        temp_quest.new = true # Setting this back to true makes the "!" icon appear when the quest updates
        temp_quest.time = Time.now
        @completed_quests.push(temp_quest)
        @active_quests.delete_at(i)
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>Quest completed!</c2>\nYour quest log has been updated!</ac>",QUEST_JINGLE))
        break
      end
    end
    if !found
      color = colorQuest(nil) if color == nil
      @completed_quests.push(Quest.new(quest,color,story))
    end
  end
  
  def advanceQuestToStage(quest,stageNum,color,story)
    if !quest.is_a?(Symbol)
      raise _INTL("The 'quest' argument should be a symbol, e.g. ':Quest1'.")
    end
    found = false
    for i in 0...@active_quests.length
      if @active_quests[i].id == quest
        @active_quests[i].stage = stageNum
        @active_quests[i].color = color if color != nil
        @active_quests[i].new = true # Setting this back to true makes the "!" icon appear when the quest updates
        found = true
        pbMessage(_INTL("\\se[{1}]<ac><c2=#{colorQuest("red")}>New task added!</c2>\nYour quest log has been updated!</ac>",QUEST_JINGLE))
      end
      return if found
    end
    if !found
      color = colorQuest(nil) if color == nil
      questNew = Quest.new(quest,color,story)
      questNew.stage = stageNum
      @active_quests.push(questNew)
    end
  end
end

#===============================================================================
# Initiate quest data
#===============================================================================
class PokemonGlobalMetadata  
  def quests
    @quests = Player_Quests.new if !@quests
    return @quests
  end
  
  alias quest_init initialize
  def initialize
    quest_init
    @quests = Player_Quests.new
  end
end

#===============================================================================
# Helper and utility functions for managing quests
#===============================================================================

# Helper function for activating quests
def activateQuest(quest,color=colorQuest(nil),story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.activateQuest(quest,color,story)
end

# Helper function for marking quests as completed
def completeQuest(quest,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.completeQuest(quest,color,story)
end

# Helper function for marking quests as failed
def failQuest(quest,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.failQuest(quest,color,story)
end

# Helper function for advancing quests to given stage
def advanceQuestToStage(quest,stageNum,color=nil,story=false)
  return if !$PokemonGlobal
  $PokemonGlobal.quests.advanceQuestToStage(quest,stageNum,color,story)
end

# Get symbolic names of active quests
# Unused
def getActiveQuests
  active = []
  $PokemonGlobal.quests.active_quests.each do |s|
    active.push(s.id)
  end
  return active
end

# Get symbolic names of completed quests
# Unused
def getCompletedQuests
  completed = []
  $PokemonGlobal.quests.completed_quests.each do |s|
    completed.push(s.id)
  end
  return completed
end

# Get symbolic names of failed quests
# Unused
def getFailedQuests
  failed = []
  $PokemonGlobal.quests.failed_quests.each do |s|
    failed.push(s.id)
  end
  return failed
end

#===============================================================================
# Class that contains utility methods to return quest properties
#===============================================================================
class QuestData

  # Get ID number for quest
  def getID(quest)
    return "#{QuestModule.const_get(quest)[:ID]}"
  end

  # Get quest name
  def getName(quest)
    return "#{QuestModule.const_get(quest)[:Name]}"
  end

  # Get name of quest giver
  def getQuestGiver(quest)
    return "#{QuestModule.const_get(quest)[:QuestGiver]}"
  end

  # Get array of quest stages
  def getQuestStages(quest)
    arr = []
    for key in QuestModule.const_get(quest).keys
      arr.push(key) if key.to_s.include?("Stage")
    end
    return arr
  end

  # Get quest reward
  def getQuestReward(quest)
    return "#{QuestModule.const_get(quest)[:RewardString]}"
  end

  # Get overall quest description
  def getQuestDescription(quest)
    return "#{QuestModule.const_get(quest)[:QuestDescription]}"
  end

  # Get current task location
  def getStageLocation(quest,stage)
    loc = ("Location" + "#{stage}").to_sym
    return "#{QuestModule.const_get(quest)[loc]}"
  end  

  # Get summary of current task
  def getStageDescription(quest,stage)
    stg = ("Stage" + "#{stage}").to_sym
    return "#{QuestModule.const_get(quest)[stg]}"
  end 

  # Get maximum number of tasks for quest
  def getMaxStagesForQuest(quest)
    quests = getQuestStages(quest)
    return quests.length
  end
  
end

# Global variable to make it easier to refer to methods in above class
$quest_data = QuestData.new

#===============================================================================
# Class that contains utility methods to return quest properties
#===============================================================================

# Utility function to check whether the player current has any quests
def hasAnyQuests?
  if $PokemonGlobal.quests.active_quests.length >0 || 
    $PokemonGlobal.quests.completed_quests.length >0 ||
    $PokemonGlobal.quests.failed_quests.length >0
    return true
  end
  return false      
end