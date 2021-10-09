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

#==============================================================================
# Fix for Pokémon editor deleting a moveset move when "changing" which move it
# is to the same move.
#==============================================================================
module MovePoolProperty
  def self.set(_settingname, oldsetting)
    # Get all moves in move pool
    realcmds = []
    realcmds.push([-1, nil, -1, "-"])   # Level, move ID, index in this list, name
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i][0], oldsetting[i][1], i, GameData::Move.get(oldsetting[i][1]).real_name])
    end
    # Edit move pool
    cmdwin = pbListWindow([], 200)
    oldsel = -1
    ret = oldsetting
    cmd = [0, 0]
    commands = []
    refreshlist = true
    loop do
      if refreshlist
        realcmds.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
        commands = []
        realcmds.each_with_index do |entry, i|
          if entry[0] == -1
            commands.push(_INTL("[ADD MOVE]"))
          else
            commands.push(_INTL("{1}: {2}", entry[0], entry[3]))
          end
          cmd[1] = i if oldsel >= 0 && entry[2] == oldsel
        end
      end
      refreshlist = false
      oldsel = -1
      cmd = pbCommands3(cmdwin, commands, -1, cmd[1], true)
      case cmd[0]
      when 1   # Swap move up (if both moves have the same level)
        if cmd[1] < realcmds.length - 1 && realcmds[cmd[1]][0] == realcmds[cmd[1] + 1][0]
          realcmds[cmd[1] + 1][2], realcmds[cmd[1]][2] = realcmds[cmd[1]][2], realcmds[cmd[1] + 1][2]
          refreshlist = true
        end
      when 2   # Swap move down (if both moves have the same level)
        if cmd[1] > 0 && realcmds[cmd[1]][0] == realcmds[cmd[1] - 1][0]
          realcmds[cmd[1] - 1][2], realcmds[cmd[1]][2] = realcmds[cmd[1]][2], realcmds[cmd[1] - 1][2]
          refreshlist = true
        end
      when 0
        if cmd[1] >= 0   # Chose an entry
          entry = realcmds[cmd[1]]
          if entry[0] == -1   # Add new move
            params = ChooseNumberParams.new
            params.setRange(0, GameData::GrowthRate.max_level)
            params.setDefaultValue(1)
            params.setCancelValue(-1)
            newlevel = pbMessageChooseNumber(_INTL("Choose a level."),params)
            if newlevel >= 0
              newmove = pbChooseMoveList
              if newmove
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == newlevel && e[1] == newmove
                end
                if havemove >= 0
                  oldsel = havemove
                else
                  maxid = -1
                  realcmds.each { |e| maxid = [maxid, e[2]].max }
                  realcmds.push([newlevel, newmove, maxid + 1, GameData::Move.get(newmove).real_name])
                end
                refreshlist = true
              end
            end
          else   # Edit existing move
            case pbMessage(_INTL("\\ts[]Do what with this move?"),
               [_INTL("Change level"), _INTL("Change move"), _INTL("Delete"), _INTL("Cancel")], 4)
            when 0   # Change level
              params = ChooseNumberParams.new
              params.setRange(0, GameData::GrowthRate.max_level)
              params.setDefaultValue(entry[0])
              newlevel = pbMessageChooseNumber(_INTL("Choose a new level."), params)
              if newlevel >= 0 && newlevel != entry[0]
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == newlevel && e[1] == entry[1]
                end
                if havemove >= 0   # Move already known at new level; delete this move
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = havemove
                else   # Apply the new level
                  entry[0] = newlevel
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            when 1   # Change move
              newmove = pbChooseMoveList(entry[1])
              if newmove && newmove != entry[1]
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == entry[0] && e[1] == newmove
                end
                if havemove >= 0   # New move already known at level; delete this move
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  cmd[1] = [cmd[1], realcmds.length - 1].min
                  oldsel = havemove
                else   # Apply the new move
                  entry[1] = newmove
                  entry[3] = GameData::Move.get(newmove).real_name
                  oldsel = entry[2]
                end
                refreshlist = true
              end
            when 2   # Delete
              realcmds[cmd[1]] = nil
              realcmds.compact!
              cmd[1] = [cmd[1], realcmds.length - 1].min
              refreshlist = true
            end
          end
        else   # Cancel/quit
          case pbMessage(_INTL("Save changes?"),
             [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
          when 0
            for i in 0...realcmds.length
              realcmds[i].pop   # Remove name
              realcmds[i].pop   # Remove index in this list
            end
            realcmds.compact!
            ret = realcmds
            break
          when 1
            break
          end
        end
      end
    end
    cmdwin.dispose
    return ret
  end
end

#==============================================================================
# Fixed crash when compiling a moves.txt that uses the old format.
#==============================================================================
module Compiler
  module_function

  def compile_trainers(path = "PBS/trainers.txt")
    GameData::Trainer::DATA.clear
    schema = GameData::Trainer::SCHEMA
    max_level = GameData::GrowthRate.max_level
    trainer_names             = []
    trainer_lose_texts        = []
    trainer_hash              = nil
    trainer_id                = -1
    current_pkmn              = nil
    old_format_current_line   = 0
    old_format_expected_lines = 0
    # Read each line of trainers.txt at a time and compile it as a trainer property
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]
        # New section [trainer_type, name] or [trainer_type, name, version]
        if trainer_hash
          if old_format_current_line > 0
            raise _INTL("Previous trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
          end
          if !current_pkmn
            raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
          end
          # Add trainer's data to records
          trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
          GameData::Trainer.register(trainer_hash)
        end
        trainer_id += 1
        line_data = pbGetCsvRecord($~[1], line_no, [0, "esU", :TrainerType])
        # Construct trainer hash
        trainer_hash = {
          :id_number    => trainer_id,
          :trainer_type => line_data[0],
          :name         => line_data[1],
          :version      => line_data[2] || 0,
          :pokemon      => []
        }
        current_pkmn = nil
        trainer_names[trainer_id] = trainer_hash[:name]
      elsif line[/^\s*(\w+)\s*=\s*(.*)$/]
        # XXX=YYY lines
        if !trainer_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Error checking in XXX=YYY lines
        case property_name
        when "Items"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
        when "Pokemon"
          if property_value[1] > max_level
            raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", property_value[1], max_level, FileLineData.linereport)
          end
        when "Name"
          if property_value.length > Pokemon::MAX_NAME_SIZE
            raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", property_value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
          end
        when "Moves"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.uniq!
          property_value.compact!
        when "IV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |iv|
            next if iv <= Pokemon::IV_STAT_LIMIT
            raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", iv, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
          end
        when "EV"
          property_value = [property_value] if !property_value.is_a?(Array)
          property_value.compact!
          property_value.each do |ev|
            next if ev <= Pokemon::EV_STAT_LIMIT
            raise _INTL("Bad EV: {1} (must be 0-{2}).\r\n{3}", ev, Pokemon::EV_STAT_LIMIT, FileLineData.linereport)
          end
          ev_total = 0
          GameData::Stat.each_main do |s|
            next if s.pbs_order < 0
            ev_total += (property_value[s.pbs_order] || property_value[0])
          end
          if ev_total > Pokemon::EV_LIMIT
            raise _INTL("Total EVs are greater than allowed ({1}).\r\n{2}", Pokemon::EV_LIMIT, FileLineData.linereport)
          end
        when "Happiness"
          if property_value > 255
            raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", property_value, FileLineData.linereport)
          end
        end
        # Record XXX=YYY setting
        case property_name
        when "Items", "LoseText"
          trainer_hash[line_schema[0]] = property_value
          trainer_lose_texts[trainer_id] = property_value if property_name == "LoseText"
        when "Pokemon"
          current_pkmn = {
            :species => property_value[0],
            :level   => property_value[1]
          }
          trainer_hash[line_schema[0]].push(current_pkmn)
        else
          if !current_pkmn
            raise _INTL("Pokémon hasn't been defined yet!\r\n{1}", FileLineData.linereport)
          end
          case property_name
          when "Ability"
            if property_value[/^\d+$/]
              current_pkmn[:ability_index] = property_value.to_i
            elsif !GameData::Ability.exists?(property_value.to_sym)
              raise _INTL("Value {1} isn't a defined Ability.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          when "IV", "EV"
            value_hash = {}
            GameData::Stat.each_main do |s|
              next if s.pbs_order < 0
              value_hash[s.id] = property_value[s.pbs_order] || property_value[0]
            end
            current_pkmn[line_schema[0]] = value_hash
          when "Ball"
            if property_value[/^\d+$/]
              current_pkmn[line_schema[0]] = pbBallTypeToItem(property_value.to_i).id
            elsif !GameData::Item.exists?(property_value.to_sym) ||
               !GameData::Item.get(property_value.to_sym).is_poke_ball?
              raise _INTL("Value {1} isn't a defined Poké Ball.\r\n{2}", property_value, FileLineData.linereport)
            else
              current_pkmn[line_schema[0]] = property_value.to_sym
            end
          else
            current_pkmn[line_schema[0]] = property_value
          end
        end
      else
        # Old format - backwards compatibility is SUCH fun!
        if old_format_current_line == 0   # Started an old trainer section
          if trainer_hash
            if !current_pkmn
              raise _INTL("Started new trainer while previous trainer has no Pokémon.\r\n{1}", FileLineData.linereport)
            end
            # Add trainer's data to records
            trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
            GameData::Trainer.register(trainer_hash)
          end
          trainer_id += 1
          old_format_expected_lines = 3
          # Construct trainer hash
          trainer_hash = {
            :id_number    => trainer_id,
            :trainer_type => nil,
            :name         => nil,
            :version      => 0,
            :pokemon      => []
          }
          current_pkmn = nil
        end
        # Evaluate line and add to hash
        old_format_current_line += 1
        case old_format_current_line
        when 1   # Trainer type
          line_data = pbGetCsvRecord(line, line_no, [0, "e", :TrainerType])
          trainer_hash[:trainer_type] = line_data
        when 2   # Trainer name, version number
          line_data = pbGetCsvRecord(line, line_no, [0, "sU"])
          line_data = [line_data] if !line_data.is_a?(Array)
          trainer_hash[:name]    = line_data[0]
          trainer_hash[:version] = line_data[1] if line_data[1]
          trainer_names[trainer_hash[:id_number]] = line_data[0]
        when 3   # Number of Pokémon, items
          line_data = pbGetCsvRecord(line, line_no,
             [0, "vEEEEEEEE", nil, :Item, :Item, :Item, :Item, :Item, :Item, :Item, :Item])
          line_data = [line_data] if !line_data.is_a?(Array)
          line_data.compact!
          old_format_expected_lines += line_data[0]
          line_data.shift
          trainer_hash[:items] = line_data if line_data.length > 0
        else   # Pokémon lines
          line_data = pbGetCsvRecord(line, line_no,
             [0, "evEEEEEUEUBEUUSBU", :Species, nil, :Item, :Move, :Move, :Move, :Move, nil,
                                      {"M" => 0, "m" => 0, "Male" => 0, "male" => 0, "0" => 0,
                                      "F" => 1, "f" => 1, "Female" => 1, "female" => 1, "1" => 1},
                                      nil, nil, :Nature, nil, nil, nil, nil, nil])
          current_pkmn = {
            :species => line_data[0]
          }
          trainer_hash[:pokemon].push(current_pkmn)
          # Error checking in properties
          line_data.each_with_index do |value, i|
            next if value.nil?
            case i
            when 1   # Level
              if value > max_level
                raise _INTL("Bad level: {1} (must be 1-{2}).\r\n{3}", value, max_level, FileLineData.linereport)
              end
            when 12   # IV
              if value > Pokemon::IV_STAT_LIMIT
                raise _INTL("Bad IV: {1} (must be 0-{2}).\r\n{3}", value, Pokemon::IV_STAT_LIMIT, FileLineData.linereport)
              end
            when 13   # Happiness
              if value > 255
                raise _INTL("Bad happiness: {1} (must be 0-255).\r\n{2}", value, FileLineData.linereport)
              end
            when 14   # Nickname
              if value.length > Pokemon::MAX_NAME_SIZE
                raise _INTL("Bad nickname: {1} (must be 1-{2} characters).\r\n{3}", value, Pokemon::MAX_NAME_SIZE, FileLineData.linereport)
              end
            end
          end
          # Write all line data to hash
          moves = [line_data[3], line_data[4], line_data[5], line_data[6]]
          moves.uniq!
          moves.compact!
          ivs = {}
          if line_data[12]
            GameData::Stat.each_main do |s|
              ivs[s.id] = line_data[12] if s.pbs_order >= 0
            end
          end
          current_pkmn[:level]         = line_data[1]
          current_pkmn[:item]          = line_data[2] if line_data[2]
          current_pkmn[:moves]         = moves if moves.length > 0
          current_pkmn[:ability_index] = line_data[7] if line_data[7]
          current_pkmn[:gender]        = line_data[8] if line_data[8]
          current_pkmn[:form]          = line_data[9] if line_data[9]
          current_pkmn[:shininess]     = line_data[10] if line_data[10]
          current_pkmn[:nature]        = line_data[11] if line_data[11]
          current_pkmn[:iv]            = ivs if ivs.length > 0
          current_pkmn[:happiness]     = line_data[13] if line_data[13]
          current_pkmn[:name]          = line_data[14] if line_data[14] && !line_data[14].empty?
          current_pkmn[:shadowness]    = line_data[15] if line_data[15]
          current_pkmn[:poke_ball]     = line_data[16] if line_data[16]
          # Check if this is the last expected Pokémon
          old_format_current_line = 0 if old_format_current_line >= old_format_expected_lines
        end
      end
    }
    if old_format_current_line > 0
      raise _INTL("Unexpected end of file, last trainer not defined with as many Pokémon as expected.\r\n{1}", FileLineData.linereport)
    end
    # Add last trainer's data to records
    if trainer_hash
      trainer_hash[:id] = [trainer_hash[:trainer_type], trainer_hash[:name], trainer_hash[:version]]
      GameData::Trainer.register(trainer_hash)
    end
    # Save all data
    GameData::Trainer.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames, trainer_names)
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerLoseText, trainer_lose_texts)
    Graphics.update
  end
end
