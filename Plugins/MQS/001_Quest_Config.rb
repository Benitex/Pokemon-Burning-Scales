#===============================================================================
# Modern Questing System + UI
# If you like quests, this is the resource for you!
#===============================================================================
# Original implemenation by mej71
# Updated for v17.2 and v18/18.1 by derFischae
# Heavily edited for v19/19.1 by ThatWelshOne_
# Some UI components borrowed (with permission) from Marin's Easy Questing Interface
# 
#===============================================================================
# Things you can currently customise without editing the scripts themselves
#===============================================================================

# If true, includes a page of failed quests on the UI
# Set this to false if you don't want to have quests that can be failed
SHOW_FAILED_QUESTS = true

# Name of file in Audio/SE that plays when a quest is activated/advanced to new stage/completed
QUEST_JINGLE = "Mining found all.ogg"

# Name of file in Audio/SE that plays when a quest is failed
QUEST_FAIL = "GUI sel buzzer.ogg"

# Future plans are to add different backgrounds that can be chosen by you

#===============================================================================
# Utility method for setting colors
#===============================================================================

# Useful Hex to 15-bit color converter: http://www.budmelvin.com/dev/15bitconverter.html
# Add in your own colors here!
def colorQuest(color)
  color = color.downcase if color
  return "7DC076EF" if color == "blue"
  return "089D5EBF" if color == "red"
  return "26CC4B56" if color == "green"
  return "6F697395" if color == "cyan"
  return "5CFA729D" if color == "magenta"
  return "135D47BF" if color == "yellow"
  return "56946F5A" if color == "gray"
  return "7FDE6B39" if color == "white"
  return "751272B7" if color == "purple"
  return "0E7F4F3F" if color == "orange"
  return "2D4A5694" # Returns the default dark gray color if all other options are exhausted
end
