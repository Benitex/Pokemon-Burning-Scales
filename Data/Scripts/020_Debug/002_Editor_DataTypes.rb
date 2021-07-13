#===============================================================================
# Data type properties
#===============================================================================
module UndefinedProperty
  def self.set(_settingname,oldsetting)
    pbMessage(_INTL("This property can't be edited here at this time."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module ReadOnlyProperty
  def self.set(_settingname,oldsetting)
    pbMessage(_INTL("This property cannot be edited."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



class UIntProperty
  def initialize(maxdigits)
    @maxdigits = maxdigits
  end

  def set(settingname,oldsetting)
    params = ChooseNumberParams.new
    params.setMaxDigits(@maxdigits)
    params.setDefaultValue(oldsetting || 0)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.",settingname),params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end



class LimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0,@maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1} (0-#{@maxvalue}).",settingname),params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end



class LimitProperty2
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting = 0 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0,@maxvalue)
    params.setDefaultValue(oldsetting)
    params.setCancelValue(-1)
    ret = pbMessageChooseNumber(_INTL("Set the value for {1} (0-#{@maxvalue}).",settingname),params)
    return (ret>=0) ? ret : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? value.inspect : "-"
  end
end



class NonzeroLimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(1,@maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.",settingname),params)
  end

  def defaultValue
    return 1
  end

  def format(value)
    return value.inspect
  end
end



module BooleanProperty
  def self.set(settingname,_oldsetting)
    return pbConfirmMessage(_INTL("Enable the setting {1}?",settingname)) ? true : false
  end

  def self.format(value)
    return value.inspect
  end
end



module BooleanProperty2
  def self.set(_settingname,_oldsetting)
    ret = pbShowCommands(nil,[_INTL("True"),_INTL("False")],-1)
    return (ret>=0) ? (ret==0) : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value) ? _INTL("True") : (value!=nil) ? _INTL("False") : "-"
  end
end



module StringProperty
  def self.set(settingname,oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,250,Graphics.width)
  end

  def self.format(value)
    return value
  end
end



class LimitStringProperty
  def initialize(limit)
    @limit = limit
  end

  def format(value)
    return value
  end

  def set(settingname,oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,@limit)
  end
end



class EnumProperty
  def initialize(values)
    @values = values
  end

  def set(settingname,oldsetting)
    commands = []
    for value in @values
      commands.push(value)
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.",settingname),commands,-1)
    return oldsetting if cmd<0
    return cmd
  end

  def defaultValue
    return 0
  end

  def format(value)
    return (value) ? @values[value] : value.inspect
  end
end



# Unused
class EnumProperty2
  def initialize(value)
    @module = value
  end

  def set(settingname,oldsetting)
    commands = []
    for i in 0..@module.maxValue
      commands.push(getConstantName(@module, i))
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.", settingname), commands, -1, nil, oldsetting)
    return oldsetting if cmd < 0
    return cmd
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? getConstantName(@module, value) : "-"
  end
end



class GameDataProperty
  def initialize(value)
    raise _INTL("Couldn't find class {1} in module GameData.", value.to_s) if !GameData.const_defined?(value.to_sym)
    @module = GameData.const_get(value.to_sym)
  end

  def set(settingname, oldsetting)
    commands = []
    i = 0
    @module.each do |data|
      if data.respond_to?("id_number")
        commands.push([data.id_number, data.name, data.id])
      else
        commands.push([i, data.name, data.id])
      end
      i += 1
    end
    return pbChooseList(commands, oldsetting, oldsetting, -1)
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value && @module.exists?(value)) ? @module.get(value).real_name : "-"
  end
end



module BGMProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MusicFileLister.new(true,oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module MEProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MusicFileLister.new(false,oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module WindowskinProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,GraphicsLister.new("Graphics/Windowskins/",oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module TrainerTypeProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, TrainerTypeLister.new(0, false))
    return chosenmap || oldsetting
  end

  def self.format(value)
    return (value && GameData::TrainerType.exists?(value)) ? GameData::TrainerType.get(value).real_name : "-"
  end
end



module SpeciesProperty
  def self.set(_settingname,oldsetting)
    ret = pbChooseSpeciesList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Species.exists?(value)) ? GameData::Species.get(value).real_name : "-"
  end
end



class SpeciesFormProperty
  def initialize(default_value)
    @default_value = default_value
  end

  def set(_settingname,oldsetting)
    ret = pbChooseSpeciesFormList(oldsetting || nil)
    return ret || oldsetting
  end

  def defaultValue
    return @default_value
  end

  def format(value)
    if value && GameData::Species.exists?(value)
      species_data = GameData::Species.get(value)
      if species_data.form > 0
        return sprintf("%s_%d", species_data.real_name, species_data.form)
      else
        return species_data.real_name
      end
    end
    return "-"
  end
end



module TypeProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseTypeList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Type.exists?(value)) ? GameData::Type.get(value).real_name : "-"
  end
end



module MoveProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseMoveList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Move.exists?(value)) ? GameData::Move.get(value).real_name : "-"
  end
end



class MovePropertyForSpecies
  def initialize(pokemondata)
    @pokemondata = pokemondata
  end

  def set(_settingname, oldsetting)
    ret = pbChooseMoveListForSpecies(@pokemondata[0], oldsetting || nil)
    return ret || oldsetting
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value && GameData::Move.exists?(value)) ? GameData::Move.get(value).real_name : "-"
  end
end



module GenderProperty
  def self.set(_settingname,_oldsetting)
    ret = pbShowCommands(nil,[_INTL("Male"),_INTL("Female")],-1)
    return (ret>=0) ? ret : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return _INTL("-") if !value
    return (value==0) ? _INTL("Male") : (value==1) ? _INTL("Female") : "-"
  end
end



module ItemProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseItemList((oldsetting) ? oldsetting : nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Item.exists?(value)) ? GameData::Item.get(value).real_name : "-"
  end
end



class IVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname, oldsetting)
    oldsetting = {} if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      oldsetting[s.pbs_order] = 0 if !oldsetting[s.pbs_order]
      properties[s.pbs_order] = [s.name, LimitProperty2.new(@limit),
                                 _INTL("Individual values for the Pokémon's {1} stat (0-{2}).", s.name, @limit)]
      data[s.pbs_order] = oldsetting[s.id]
      stat_ids[s.pbs_order] = s.id
    end
    pbPropertyList(settingname, data, properties, false)
    ret = {}
    stat_ids.each_with_index { |s, i| ret[s] = data[i] || 0 }
    return ret
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(',')
  end
end



class EVsProperty
  def initialize(limit)
    @limit = limit
  end

  def set(settingname, oldsetting)
    oldsetting = {} if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      oldsetting[s.pbs_order] = 0 if !oldsetting[s.pbs_order]
      properties[s.pbs_order] = [s.name, LimitProperty2.new(@limit),
                                 _INTL("Effort values for the Pokémon's {1} stat (0-{2}).", s.name, @limit)]
      data[s.pbs_order] = oldsetting[s.id]
      stat_ids[s.pbs_order] = s.id
    end
    loop do
      pbPropertyList(settingname, data, properties, false)
      evtotal = 0
      data.each { |value| evtotal += value if value }
      break if evtotal <= Pokemon::EV_LIMIT
      pbMessage(_INTL("Total EVs ({1}) are greater than allowed ({2}). Please reduce them.", evtotal, Pokemon::EV_LIMIT))
    end
    ret = {}
    stat_ids.each_with_index { |s, i| ret[s] = data[i] || 0 }
    return ret
  end

  def defaultValue
    return nil
  end

  def format(value)
    return "-" if !value
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(',')
  end
end



class BallProperty
  def initialize(pokemondata)
    @pokemondata = pokemondata
  end

  def set(_settingname,oldsetting)
    return pbChooseBallList(oldsetting)
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? GameData::Item.get(value).name : "-"
  end
end



module CharacterProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,GraphicsLister.new("Graphics/Characters/",oldsetting))
    return (chosenmap && chosenmap!="") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module PlayerProperty
  def self.set(settingname,oldsetting)
    oldsetting = [nil,"xxx","xxx","xxx","xxx","xxx","xxx","xxx"] if !oldsetting
    properties = [
       [_INTL("Trainer Type"), TrainerTypeProperty, _INTL("Trainer type of this player.")],
       [_INTL("Sprite"),       CharacterProperty,   _INTL("Walking character sprite.")],
       [_INTL("Cycling"),      CharacterProperty,   _INTL("Cycling character sprite.")],
       [_INTL("Surfing"),      CharacterProperty,   _INTL("Surfing character sprite.")],
       [_INTL("Running"),      CharacterProperty,   _INTL("Running character sprite.")],
       [_INTL("Diving"),       CharacterProperty,   _INTL("Diving character sprite.")],
       [_INTL("Fishing"),      CharacterProperty,   _INTL("Fishing character sprite.")],
       [_INTL("Field Move"),   CharacterProperty,   _INTL("Using a field move character sprite.")]
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module MapSizeProperty
  def self.set(settingname,oldsetting)
    oldsetting = [0,""] if !oldsetting
    properties = [
       [_INTL("Width"),         NonzeroLimitProperty.new(30), _INTL("The width of this map in Region Map squares.")],
       [_INTL("Valid Squares"), StringProperty,               _INTL("A series of 1s and 0s marking which squares are part of this map (1=part, 0=not part).")],
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def chooseMapPoint(map,rgnmap=false)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  title = Window_UnformattedTextPokemon.newWithSize(_INTL("Click a point on the map."),
     0, Graphics.height - 64, Graphics.width, 64, viewport)
  title.z = 2
  if rgnmap
    sprite=RegionMapSprite.new(map,viewport)
  else
    sprite=MapSprite.new(map,viewport)
  end
  sprite.z=2
  ret=nil
  loop do
    Graphics.update
    Input.update
    xy=sprite.getXY
    if xy
      ret=xy
      break
    end
    if Input.trigger?(Input::BACK)
      ret=nil
      break
    end
  end
  sprite.dispose
  title.dispose
  return ret
end



module MapCoordsProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap>=0
      mappoint = chooseMapPoint(chosenmap)
      return (mappoint) ? [chosenmap,mappoint[0],mappoint[1]] : oldsetting
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module MapCoordsFacingProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap>=0
      mappoint = chooseMapPoint(chosenmap)
      if mappoint
        facing = pbMessage(_INTL("Choose the direction to face in."),
           [_INTL("Down"),_INTL("Left"),_INTL("Right"),_INTL("Up")],-1)
        return (facing>=0) ? [chosenmap,mappoint[0],mappoint[1],[2,4,6,8][facing]] : oldsetting
      else
        return oldsetting
      end
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module RegionMapCoordsProperty
  def self.set(_settingname,oldsetting)
    regions = self.getMapNameList
    selregion = -1
    if regions.length==0
      pbMessage(_INTL("No region maps are defined."))
      return oldsetting
    elsif regions.length==1
      selregion = regions[0][0]
    else
      cmds = []
      for region in regions
        cmds.push(region[1])
      end
      selcmd = pbMessage(_INTL("Choose a region map."),cmds,-1)
      if selcmd>=0
        selregion = regions[selcmd][0]
      else
        return oldsetting
      end
    end
    mappoint = chooseMapPoint(selregion,true)
    return (mappoint) ? [selregion,mappoint[0],mappoint[1]] : oldsetting
  end

  def self.format(value)
    return value.inspect
  end

  def self.getMapNameList
    mapdata = pbLoadTownMapData
    ret=[]
    for i in 0...mapdata.length
      next if !mapdata[i]
      ret.push(
         [i,pbGetMessage(MessageTypes::RegionNames,i)]
      )
    end
    return ret
  end
end



module WeatherEffectProperty
  def self.set(_settingname,oldsetting)
    oldsetting = [:None, 100] if !oldsetting
    options = []
    ids = []
    default = 0
    GameData::Weather.each do |w|
      default = ids.length if w.id == oldsetting[0]
      options.push(w.real_name)
      ids.push(w.id)
    end
    cmd = pbMessage(_INTL("Choose a weather effect."), options, -1, nil, default)
    return nil if cmd < 0 || ids[cmd] == :None
    params = ChooseNumberParams.new
    params.setRange(0, 100)
    params.setDefaultValue(oldsetting[1])
    number = pbMessageChooseNumber(_INTL("Set the probability of the weather."), params)
    return [ids[cmd], number]
  end

  def self.format(value)
    return (value) ? GameData::Weather.get(value[0]).real_name + ",#{value[1]}" : "-"
  end
end



module MapProperty
  def self.set(settingname,oldsetting)
    chosenmap = pbListScreen(settingname,MapLister.new(oldsetting ? oldsetting : 0))
    return (chosenmap>0) ? chosenmap : oldsetting
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return value.inspect
  end
end



module ItemNameProperty
  def self.set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       (oldsetting) ? oldsetting : "",false,30)
  end

  def self.defaultValue
    return "???"
  end

  def self.format(value)
    return value
  end
end



module PocketProperty
  def self.set(_settingname, oldsetting)
    commands = Settings.bag_pocket_names.clone
    commands.shift
    cmd = pbMessage(_INTL("Choose a pocket for this item."), commands, -1)
    return (cmd >= 0) ? cmd + 1 : oldsetting
  end

  def self.defaultValue
    return 1
  end

  def self.format(value)
    return _INTL("No Pocket") if value == 0
    return (value) ? Settings.bag_pocket_names[value] : value.inspect
  end
end



module BaseStatsProperty
  def self.set(settingname,oldsetting)
    return oldsetting if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      properties[s.pbs_order] = [_INTL("Base {1}", s.name), NonzeroLimitProperty.new(255),
                                 _INTL("Base {1} stat of the Pokémon.", s.name)]
      data[s.pbs_order] = oldsetting[s.id] || 10
      stat_ids[s.pbs_order] = s.id
    end
    if pbPropertyList(settingname, data, properties, true)
      ret = {}
      stat_ids.each_with_index { |s, i| ret[s] = data[i] || 10 }
      oldsetting = ret
    end
    return oldsetting
  end

  def self.defaultValue
    ret = {}
    GameData::Stat.each_main { |s| ret[s.id] = 10 if s.pbs_order >= 0 }
    return ret
  end

  def self.format(value)
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(',')
  end
end



module EffortValuesProperty
  def self.set(settingname,oldsetting)
    return oldsetting if !oldsetting
    properties = []
    data = []
    stat_ids = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      properties[s.pbs_order] = [_INTL("{1} EVs", s.name), LimitProperty.new(255),
                                 _INTL("Number of {1} Effort Value points gained from the Pokémon.", s.name)]
      data[s.pbs_order] = oldsetting[s.id] || 0
      stat_ids[s.pbs_order] = s.id
    end
    if pbPropertyList(settingname, data, properties, true)
      ret = {}
      stat_ids.each_with_index { |s, i| ret[s] = data[i] || 0 }
      oldsetting = ret
    end
    return oldsetting
  end

  def self.defaultValue
    ret = {}
    GameData::Stat.each_main { |s| ret[s.id] = 0 if s.pbs_order >= 0 }
    return ret
  end

  def self.format(value)
    array = []
    GameData::Stat.each_main do |s|
      next if s.pbs_order < 0
      array[s.pbs_order] = value[s.id] || 0
    end
    return array.join(',')
  end
end



module AbilityProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseAbilityList((oldsetting) ? oldsetting : nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Ability.exists?(value)) ? GameData::Ability.get(value).real_name : "-"
  end
end



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
              if newmove
                havemove = -1
                realcmds.each do |e|
                  havemove = e[2] if e[0] == entry[0] && e[1] == newmove
                end
                if havemove >= 0   # New move already known at level; delete this move
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
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

  def self.defaultValue
    return []
  end

  def self.format(value)
    ret = ""
    for i in 0...value.length
      ret << "," if i > 0
      ret << sprintf("%s,%s", value[i][0], GameData::Move.get(value[i][1]).real_name)
    end
    return ret
  end
end



module EggMovesProperty
  def self.set(_settingname, oldsetting)
    # Get all egg moves
    realcmds = []
    realcmds.push([nil, _INTL("[ADD MOVE]"), -1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i], GameData::Move.get(oldsetting[i]).real_name, 0])
    end
    # Edit egg moves list
    cmdwin = pbListWindow([], 200)
    oldsel = nil
    ret = oldsetting
    cmd = 0
    commands = []
    refreshlist = true
    loop do
      if refreshlist
        realcmds.sort! { |a, b| (a[2] == b[2]) ? a[1] <=> b[1] : a[2] <=> b[2] }
        commands = []
        realcmds.each_with_index do |entry, i|
          commands.push(entry[1])
          cmd = i if oldsel && entry[0] == oldsel
        end
      end
      refreshlist = false
      oldsel = nil
      cmd = pbCommands2(cmdwin, commands, -1, cmd, true)
      if cmd >= 0   # Chose an entry
        entry = realcmds[cmd]
        if entry[2] == -1   # Add new move
          newmove = pbChooseMoveList
          if newmove
            if realcmds.any? { |e| e[0] == newmove }
              oldsel = newmove   # Already have move; just move cursor to it
            else
              realcmds.push([newmove, GameData::Move.get(newmove).name, 0])
            end
            refreshlist = true
          end
        else   # Edit move
          case pbMessage(_INTL("\\ts[]Do what with this move?"),
             [_INTL("Change move"), _INTL("Delete"), _INTL("Cancel")], 3)
          when 0   # Change move
            newmove = pbChooseMoveList(entry[0])
            if newmove
              if realcmds.any? { |e| e[0] == newmove }   # Already have move; delete this one
                realcmds[cmd] = nil
                realcmds.compact!
                cmd = [cmd, realcmds.length - 1].min
              else   # Change move
                realcmds[cmd] = [newmove, GameData::Move.get(newmove).name, 0]
              end
              oldsel = newmove
              refreshlist = true
            end
          when 1   # Delete
            realcmds[cmd] = nil
            realcmds.compact!
            cmd = [cmd, realcmds.length - 1].min
            refreshlist = true
          end
        end
      else   # Cancel/quit
        case pbMessage(_INTL("Save changes?"),
           [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0
          for i in 0...realcmds.length
            realcmds[i] = realcmds[i][0]
          end
          realcmds.compact!
          ret = realcmds
          break
        when 1
          break
        end
      end
    end
    cmdwin.dispose
    return ret
  end

  def self.defaultValue
    return []
  end

  def self.format(value)
    ret = ""
    for i in 0...value.length
      ret << "," if i > 0
      ret << GameData::Move.get(value[i]).real_name
    end
    return ret
  end
end



class EvolutionsProperty
  def initialize
    @methods = []
    @evo_ids = []
    GameData::Evolution.each do |e|
      @methods.push(e.real_name)
      @evo_ids.push(e.id)
    end
  end

  def edit_parameter(evo_method, value = nil)
    param_type = GameData::Evolution.get(evo_method).parameter
    return nil if param_type.nil?
    ret = value
    case param_type
    when :Item
      ret = pbChooseItemList(value)
    when :Move
      ret = pbChooseMoveList(value)
    when :Species
      ret = pbChooseSpeciesList(value)
    when :Type
      ret = pbChooseTypeList(value)
    when :Ability
      ret = pbChooseAbilityList(value)
    else
      params = ChooseNumberParams.new
      params.setRange(0, 65535)
      params.setDefaultValue(value) if value
      params.setCancelValue(-1)
      ret = pbMessageChooseNumber(_INTL("Choose a parameter."), params)
      ret = nil if ret < 0
    end
    return ret
  end

  def set(_settingname,oldsetting)
    ret = oldsetting
    cmdwin = pbListWindow([])
    commands = []
    realcmds = []
    realcmds.push([-1,0,0,-1])
    for i in 0...oldsetting.length
      realcmds.push([oldsetting[i][0],oldsetting[i][1],oldsetting[i][2],i])
    end
    refreshlist = true
    oldsel = -1
    cmd = [0,0]
    loop do
      if refreshlist
        realcmds.sort! { |a,b| a[3]<=>b[3] }
        commands = []
        for i in 0...realcmds.length
          if realcmds[i][3]<0
            commands.push(_INTL("[ADD EVOLUTION]"))
          else
            level = realcmds[i][2]
            evo_method_data = GameData::Evolution.get(realcmds[i][1])
            param_type = evo_method_data.parameter
            if param_type.nil?
              commands.push(_INTL("{1}: {2}",
                 GameData::Species.get(realcmds[i][0]).name, evo_method_data.real_name))
            else
              if !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
                level = getConstantName(param_type, level)
              end
              level = "???" if !level || (level.is_a?(String) && level.empty?)
              commands.push(_INTL("{1}: {2}, {3}",
                 GameData::Species.get(realcmds[i][0]).name, evo_method_data.real_name, level.to_s))
            end
          end
          cmd[1] = i if oldsel>=0 && realcmds[i][3]==oldsel
        end
      end
      refreshlist = false
      oldsel = -1
      cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
      if cmd[0]==1   # Swap evolution up
        if cmd[1]>0 && cmd[1]<realcmds.length-1
          realcmds[cmd[1]+1][3],realcmds[cmd[1]][3] = realcmds[cmd[1]][3],realcmds[cmd[1]+1][3]
          refreshlist = true
        end
      elsif cmd[0]==2   # Swap evolution down
        if cmd[1]>1
          realcmds[cmd[1]-1][3],realcmds[cmd[1]][3] = realcmds[cmd[1]][3],realcmds[cmd[1]-1][3]
          refreshlist = true
        end
      elsif cmd[0]==0
        if cmd[1]>=0
          entry = realcmds[cmd[1]]
          if entry[3]==-1   # Add new evolution path
            pbMessage(_INTL("Choose an evolved form, method and parameter."))
            newspecies = pbChooseSpeciesList
            if newspecies
              newmethodindex = pbMessage(_INTL("Choose an evolution method."),@methods,-1)
              if newmethodindex >= 0
                newmethod = @evo_ids[newmethodindex]
                newparam = edit_parameter(newmethod)
                if newparam || GameData::Evolution.get(newmethod).parameter.nil?
                  existing_evo = -1
                  for i in 0...realcmds.length
                    existing_evo = realcmds[i][3] if realcmds[i][0]==newspecies &&
                                                     realcmds[i][1]==newmethod &&
                                                     realcmds[i][2]==newparam
                  end
                  if existing_evo >= 0
                    oldsel = existing_evo
                  else
                    maxid = -1
                    realcmds.each { |i| maxid = [maxid,i[3]].max }
                    realcmds.push([newspecies,newmethod,newparam,maxid+1])
                    oldsel = maxid+1
                  end
                  refreshlist = true
                end
              end
            end
          else   # Edit evolution
            case pbMessage(_INTL("\\ts[]Do what with this evolution?"),
               [_INTL("Change species"),_INTL("Change method"),
                _INTL("Change parameter"),_INTL("Delete"),_INTL("Cancel")],5)
            when 0   # Change species
              newspecies = pbChooseSpeciesList(entry[0])
              if newspecies
                existing_evo = -1
                for i in 0...realcmds.length
                  existing_evo = realcmds[i][3] if realcmds[i][0]==newspecies &&
                                                   realcmds[i][1]==entry[1] &&
                                                   realcmds[i][2]==entry[2]
                end
                if existing_evo >= 0
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = existing_evo
                else
                  entry[0] = newspecies
                  oldsel = entry[3]
                end
                refreshlist = true
              end
            when 1   # Change method
              default_index = 0
              @evo_ids.each_with_index { |evo, i| default_index = i if evo == entry[1] }
              newmethodindex = pbMessage(_INTL("Choose an evolution method."),@methods,-1,nil,default_index)
              if newmethodindex >= 0
                newmethod = @evo_ids[newmethodindex]
                existing_evo = -1
                for i in 0...realcmds.length
                  existing_evo = realcmds[i][3] if realcmds[i][0]==entry[0] &&
                                                   realcmds[i][1]==newmethod &&
                                                   realcmds[i][2]==entry[2]
                end
                if existing_evo >= 0
                  realcmds[cmd[1]] = nil
                  realcmds.compact!
                  oldsel = existing_evo
                elsif newmethod != entry[1]
                  entry[1] = newmethod
                  entry[2] = 0
                  oldsel = entry[3]
                end
                refreshlist = true
              end
            when 2   # Change parameter
              if GameData::Evolution.get(entry[1]).parameter.nil?
                pbMessage(_INTL("This evolution method doesn't use a parameter."))
              else
                newparam = edit_parameter(entry[1], entry[2])
                if newparam
                  existing_evo = -1
                  for i in 0...realcmds.length
                    existing_evo = realcmds[i][3] if realcmds[i][0]==entry[0] &&
                                                     realcmds[i][1]==entry[1] &&
                                                     realcmds[i][2]==newparam
                  end
                  if existing_evo >= 0
                    realcmds[cmd[1]] = nil
                    realcmds.compact!
                    oldsel = existing_evo
                  else
                    entry[2] = newparam
                    oldsel = entry[3]
                  end
                  refreshlist = true
                end
              end
            when 3   # Delete
              realcmds[cmd[1]] = nil
              realcmds.compact!
              cmd[1] = [cmd[1],realcmds.length-1].min
              refreshlist = true
            end
          end
        else
          cmd2 = pbMessage(_INTL("Save changes?"),
             [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
          if cmd2==0 || cmd2==1
            if cmd2==0
              for i in 0...realcmds.length
                realcmds[i].pop
                realcmds[i] = nil if realcmds[i][0]==-1
              end
              realcmds.compact!
              ret = realcmds
            end
            break
          end
        end
      end
    end
    cmdwin.dispose
    return ret
  end

  def defaultValue
    return []
  end

  def format(value)
    ret = ""
    for i in 0...value.length
      ret << "," if i > 0
      param = value[i][2]
      evo_method_data = GameData::Evolution.get(value[i][1])
      param_type = evo_method_data.parameter
      if param_type.nil?
        param = ""
      elsif !GameData.const_defined?(param_type.to_sym) && param_type.is_a?(Symbol)
        param = getConstantName(param_type, param)
      else
        param = param.to_s
      end
      param = "" if !param
      ret << sprintf("#{GameData::Species.get(value[i][0]).name},#{evo_method_data.real_name},#{param}")
    end
    return ret
  end
end



module EncounterSlotProperty
  def self.set(setting_name, data)
    max_level = GameData::GrowthRate.max_level
    if !data
      data = [20, nil, 5, 5]
      GameData::Species.each do |species_data|
        data[1] = species_data.species
        break
      end
    end
    data[3] = data[2] if !data[3]
    properties = [
      [_INTL("Probability"),   NonzeroLimitProperty.new(999),       _INTL("Relative probability of choosing this slot.")],
      [_INTL("Species"),       SpeciesFormProperty.new(data[1]),    _INTL("A Pokémon species/form.")],
      [_INTL("Minimum level"), NonzeroLimitProperty.new(max_level), _INTL("Minimum level of this species (1-{1}).", max_level)],
      [_INTL("Maximum level"), NonzeroLimitProperty.new(max_level), _INTL("Maximum level of this species (1-{1}).", max_level)]
    ]
    pbPropertyList(setting_name, data, properties, false)
    if data[2] > data[3]
      data[3], data[2] = data[2], data[3]
    end
    return data
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return "-" if !value
    species_data = GameData::Species.get(value[1])
    if species_data.form > 0
      if value[2] == value[3]
        return sprintf("%d, %s_%d (Lv.%d)", value[0],
           species_data.real_name, species_data.form, value[2])
      end
      return sprintf("%d, %s_%d (Lv.%d-%d)", value[0],
         species_data.real_name, species_data.form, value[2], value[3])
    end
    if value[2] == value[3]
      return sprintf("%d, %s (Lv.%d)", value[0], species_data.real_name, value[2])
    end
    return sprintf("%d, %s (Lv.%d-%d)", value[0], species_data.real_name, value[2], value[3])
  end
end



#===============================================================================
# Core property editor script
#===============================================================================
def pbPropertyList(title,data,properties,saveprompt=false)
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], Graphics.width / 2)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(title,
     list.width, 0, Graphics.width / 2, 64, viewport)
  title.z = 2
  desc = Window_UnformattedTextPokemon.newWithSize("",
     list.width, title.height, Graphics.width / 2, Graphics.height - title.height, viewport)
  desc.z = 2
  selectedmap = -1
  retval = nil
  commands = []
  for i in 0...properties.length
    propobj = properties[i][1]
    commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
  end
  list.commands = commands
  list.index    = 0
  begin
    loop do
      Graphics.update
      Input.update
      list.update
      desc.update
      if list.index!=selectedmap
        desc.text = properties[list.index][2]
        selectedmap = list.index
      end
      if Input.trigger?(Input::ACTION)
        propobj = properties[selectedmap][1]
        if propobj!=ReadOnlyProperty && !propobj.is_a?(ReadOnlyProperty) &&
           pbConfirmMessage(_INTL("Reset the setting {1}?",properties[selectedmap][0]))
          if propobj.respond_to?("defaultValue")
            data[selectedmap] = propobj.defaultValue
          else
            data[selectedmap] = nil
          end
        end
        commands.clear
        for i in 0...properties.length
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
        end
        list.commands = commands
      elsif Input.trigger?(Input::BACK)
        selectedmap = -1
        break
      elsif Input.trigger?(Input::USE)
        propobj = properties[selectedmap][1]
        oldsetting = data[selectedmap]
        newsetting = propobj.set(properties[selectedmap][0],oldsetting)
        data[selectedmap] = newsetting
        commands.clear
        for i in 0...properties.length
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
        end
        list.commands = commands
        break
      end
    end
    if selectedmap==-1 && saveprompt
      cmd = pbMessage(_INTL("Save changes?"),
         [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd==2
        selectedmap = list.index
      else
        retval = (cmd==0)
      end
    end
  end while selectedmap!=-1
  title.dispose
  list.dispose
  desc.dispose
  Input.update
  return retval
end
