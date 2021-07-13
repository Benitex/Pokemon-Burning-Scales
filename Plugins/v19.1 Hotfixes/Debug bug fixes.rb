#==============================================================================
# "v19.1 Hotfixes" plugin
# This file contains fixes for bugs relating to Debug features or compiling.
# These bug fixes are also in the master branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#==============================================================================



#==============================================================================
# Fix for Trainer Type Editor spamming the console with error messages when it
# can't find a trainer sprite to show for the "New Trainer Type" option.
#==============================================================================
class TrainerTypeLister
  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index < 0
    begin
      if @ids[index].is_a?(Symbol)
        @sprite.setBitmap(GameData::TrainerType.front_sprite_filename(@ids[index]), 0)
      else
        @sprite.setBitmap(nil)
      end
    rescue
      @sprite.setBitmap(nil)
    end
    if @sprite.bitmap
      @sprite.ox = @sprite.bitmap.width / 2
      @sprite.oy = @sprite.bitmap.height / 2
    end
  end
end

#==============================================================================
# Fixed some game data not being cleared before compiling.
#==============================================================================
module Compiler
  class << self
    alias __hotfixes__compile_encounters compile_encounters
    alias __hotfixes__compile_trainers compile_trainers
  end

  module_function

  def compile_encounters(path = "PBS/encounters.txt")
    GameData::Encounter::DATA.clear
	__hotfixes__compile_encounters(path)
  end

  def compile_trainers(path = "PBS/trainers.txt")
    GameData::Trainer::DATA.clear
	__hotfixes__compile_trainers(path)
  end
end

#==============================================================================
# Fix for messages not being reloaded after the game is compiled.
#==============================================================================
module Compiler
  class << self
    alias __hotfixes__compile_all compile_all
  end

  module_function

  def compile_all(mustCompile)
    __hotfixes__compile_all(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
	return if !mustCompile
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
  end
end

#==============================================================================
# Fix for messages in plugin scripts not being extracted for translating.
#==============================================================================
def pbSetTextMessages
  Graphics.update
  begin
    t = Time.now.to_i
    texts=[]
    for script in $RGSS_SCRIPTS
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      scr=Zlib::Inflate.inflate(script[2])
      pbAddRgssScriptTexts(texts,scr)
    end
    if safeExists?("Data/PluginScripts.rxdata")
      plugin_scripts = load_data("Data/PluginScripts.rxdata")
      for plugin in plugin_scripts
        for script in plugin[2]
          if Time.now.to_i - t >= 5
            t = Time.now.to_i
            Graphics.update
          end
          scr = Zlib::Inflate.inflate(script[1]).force_encoding(Encoding::UTF_8)
          pbAddRgssScriptTexts(texts,scr)
        end
      end
    end
    # Must add messages because this code is used by both game system and Editor
    MessageTypes.addMessagesAsHash(MessageTypes::ScriptTexts,texts)
    commonevents = load_data("Data/CommonEvents.rxdata")
    items=[]
    choices=[]
    for event in commonevents.compact
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      begin
        neednewline=false
        lastitem=""
        for j in 0...event.list.size
          list = event.list[j]
          if neednewline && list.code!=401
            if lastitem!=""
              lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1+" " }
              items.push(lastitem)
              lastitem=""
            end
            neednewline=false
          end
          if list.code == 101
            lastitem+="#{list.parameters[0]}"
            neednewline=true
          elsif list.code == 102
            for k in 0...list.parameters[0].length
              choices.push(list.parameters[0][k])
            end
            neednewline=false
          elsif list.code == 401
            lastitem+=" " if lastitem!=""
            lastitem+="#{list.parameters[0]}"
            neednewline=true
          elsif list.code == 355 || list.code == 655
            pbAddScriptTexts(items,list.parameters[0])
          elsif list.code == 111 && list.parameters[0]==12
            pbAddScriptTexts(items,list.parameters[1])
          elsif list.code == 209
            route=list.parameters[1]
            for k in 0...route.list.size
              if route.list[k].code == 45
                pbAddScriptTexts(items,route.list[k].parameters[0])
              end
            end
          end
        end
        if neednewline
          if lastitem!=""
            items.push(lastitem)
            lastitem=""
          end
        end
      end
    end
    if Time.now.to_i - t >= 5
      t = Time.now.to_i
      Graphics.update
    end
    items|=[]
    choices|=[]
    items.concat(choices)
    MessageTypes.setMapMessagesAsHash(0,items)
    mapinfos = pbLoadMapInfos
    mapnames=[]
    for id in mapinfos.keys
      mapnames[id]=mapinfos[id].name
    end
    MessageTypes.setMessages(MessageTypes::MapNames,mapnames)
    for id in mapinfos.keys
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      filename=sprintf("Data/Map%03d.rxdata",id)
      next if !pbRgssExists?(filename)
      map = load_data(filename)
      items=[]
      choices=[]
      for event in map.events.values
        if Time.now.to_i - t >= 5
          t = Time.now.to_i
          Graphics.update
        end
        begin
          for i in 0...event.pages.size
            neednewline=false
            lastitem=""
            for j in 0...event.pages[i].list.size
              list = event.pages[i].list[j]
              if neednewline && list.code!=401
                if lastitem!=""
                  lastitem.gsub!(/([^\.\!\?])\s\s+/) { |m| $1+" " }
                  items.push(lastitem)
                  lastitem=""
                end
                neednewline=false
              end
              if list.code == 101
                lastitem+="#{list.parameters[0]}"
                neednewline=true
              elsif list.code == 102
                for k in 0...list.parameters[0].length
                  choices.push(list.parameters[0][k])
                end
                neednewline=false
              elsif list.code == 401
                lastitem+=" " if lastitem!=""
                lastitem+="#{list.parameters[0]}"
                neednewline=true
              elsif list.code == 355 || list.code==655
                pbAddScriptTexts(items,list.parameters[0])
              elsif list.code == 111 && list.parameters[0]==12
                pbAddScriptTexts(items,list.parameters[1])
              elsif list.code==209
                route=list.parameters[1]
                for k in 0...route.list.size
                  if route.list[k].code==45
                    pbAddScriptTexts(items,route.list[k].parameters[0])
                  end
                end
              end
            end
            if neednewline
              if lastitem!=""
                items.push(lastitem)
                lastitem=""
              end
            end
          end
        end
      end
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
      items|=[]
      choices|=[]
      items.concat(choices)
      MessageTypes.setMapMessagesAsHash(id,items)
      if Time.now.to_i - t >= 5
        t = Time.now.to_i
        Graphics.update
      end
    end
  rescue Hangup
  end
  Graphics.update
end
