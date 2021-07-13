#===============================================================================
#
#===============================================================================
class BaseStatRestriction
  def initialize(mn, mx)
    @mn = mn
    @mx = mx
  end

  def isValid?(pkmn)
    bst = baseStatTotal(pkmn.species)
    return bst >= @mn && bst <= @mx
  end
end

#===============================================================================
#
#===============================================================================
class NonlegendaryRestriction
  def isValid?(pkmn)
    return true if !pkmn.genderless?
    return false if pkmn.species_data.egg_groups.include?(:Undiscovered)
    return true
  end
end

#===============================================================================
#
#===============================================================================
class InverseRestriction
  def initialize(r)
    @r = r
  end

  def isValid?(pkmn)
    return !@r.isValid?(pkmn)
  end
end

#===============================================================================
#
#===============================================================================
=begin
[3/10]
0-266 - 0-500
[106]
267-372 - 380-500
[95]
373-467 - 400-555 (nonlegendary)
468-563 - 400-555 (nonlegendary)
564-659 - 400-555 (nonlegendary)
660-755 - 400-555 (nonlegendary)
756-799 - 580-600 [legendary] (compat1==15 or compat2==15, genderbyte=255)
800-849 - 500-
850-881 - 580-
=end

def withRestr(_rule, minbs, maxbs, legendary)
  ret = PokemonChallengeRules.new.addPokemonRule(BaseStatRestriction.new(minbs, maxbs))
  if legendary == 0
    ret.addPokemonRule(NonlegendaryRestriction.new)
  elsif legendary == 1
    ret.addPokemonRule(InverseRestriction.new(NonlegendaryRestriction.new))
  end
  return ret
end

def pbArrangeByTier(pokemonlist, rule)
  tiers = [
     withRestr(rule,   0, 500, 0),
     withRestr(rule, 380, 500, 0),
     withRestr(rule, 400, 555, 0),
     withRestr(rule, 400, 555, 0),
     withRestr(rule, 400, 555, 0),
     withRestr(rule, 400, 555, 0),
     withRestr(rule, 580, 680, 1),
     withRestr(rule, 500, 680, 0),
     withRestr(rule, 580, 680, 2)
  ]
  tierPokemon = []
  tiers.length.times do
    tierPokemon.push([])
  end
  # Sort each Pokémon into tiers. Which tier a Pokémon is put in deoends on the
  # Pokémon's position within pokemonlist (later = higher tier). pokemonlist is
  # already roughly arranged by rank from weakest to strongest.
  for i in 0...pokemonlist.length
    next if !rule.ruleset.isPokemonValid?(pokemonlist[i])
    validtiers = []
    for j in 0...tiers.length
      validtiers.push(j) if tiers[j].ruleset.isPokemonValid?(pokemonlist[i])
    end
    if validtiers.length > 0
      vt = validtiers.length * i / pokemonlist.length
      tierPokemon[validtiers[vt]].push(pokemonlist[i])
    end
  end
  # Now for each tier, sort the Pokemon in that tier by their BST (lowest first).
  ret = []
  for i in 0...tiers.length
    tierPokemon[i].sort! { |a, b|
      bstA = baseStatTotal(a.species)
      bstB = baseStatTotal(b.species)
      (bstA == bstB) ? a.species <=> b.species : bstA <=> bstB
    }
    ret.concat(tierPokemon[i])
  end
  return ret
end

#===============================================================================
#
#===============================================================================
def pbReplenishBattlePokemon(party, rule)
  while party.length < 20
    pkmn = pbRandomPokemonFromRule(rule, nil)
    found = false
    for pk in party
      next if !isBattlePokemonDuplicate(pkmn, pk)
      found = true
      break
    end
    party.push(pkmn) if !found
  end
end

def isBattlePokemonDuplicate(pk, pk2)
  return false if pk.species != pk2.species
  moves1 = []
  moves2 = []
  for i in 0...Pokemon::MAX_MOVES
    moves1.push((pk.moves[i]) ? pk.moves[i].id : nil)
    moves2.push((pk2.moves[i]) ? pk2.moves[i].id : nil)
  end
  moves1.sort!
  moves2.sort!
  # Accept as same if moves are same and there are MAX_MOVES number of moves each
  return true if moves1 == moves2 && moves1[Pokemon::MAX_MOVES - 1]
  same_evs = true
  GameData::Stat.each_main { |s| same_evs = false if pk.ev[s.id] != pk2.ev[s.id] }
  return pk.item_id == pk2.item_id && pk.nature_id == pk2.nature_id && same_evs
end

def pbRemoveDuplicates(party)
  ret = []
  for pk in party
    found = false
    count = 0
    firstIndex = -1
    for i in 0...ret.length
      pk2 = ret[i]
      if isBattlePokemonDuplicate(pk, pk2)
        found = true
        break
      end
      if pk.species == pk2.species
        firstIndex = i if count == 0
        count += 1
      end
    end
    if !found
      ret.delete_at(firstIndex) if count >= 10
      ret.push(pk)
    end
  end
  return ret
end

#===============================================================================
#
#===============================================================================
def pbGenerateChallenge(rule, tag)
  oldrule = rule
  yield(_INTL("Preparing to generate teams"))
  rule = rule.copy.setNumber(2)
  yield(nil)
  party = load_data(tag + ".rxdata") rescue []
  teams = load_data(tag + "teams.rxdata") rescue []
  if teams.length < 10
    btpokemon = pbGetBTPokemon(tag)
    if btpokemon && btpokemon.length != 0
      suggestedLevel = rule.ruleset.suggestedLevel
      for pk in btpokemon
        pkmn = pk.createPokemon(suggestedLevel, 31, nil)
        party.push(pkmn) if rule.ruleset.isPokemonValid?(pkmn)
      end
    end
  end
  yield(nil)
  party = pbRemoveDuplicates(party)
  yield(nil)
  maxteams = 600
  cutoffrating = 65
  toolowrating = 40
  iterations = 11
  iterations.times do |iter|
    save_data(party, tag + ".rxdata")
    yield(_INTL("Generating teams ({1} of {2})", iter + 1, iterations))
    i = 0
    while i < teams.length
      yield(nil) if i % 10 == 0
      pbReplenishBattlePokemon(party, rule)
      if teams[i].rating < cutoffrating && teams[i].totalGames >= 80
        teams[i] = RuledTeam.new(party, rule)
      elsif teams[i].length < 2
        teams[i] = RuledTeam.new(party, rule)
      elsif i >= maxteams
        teams[i] = nil
        teams.compact!
      elsif teams[i].totalGames >= 250
        # retire
        for j in 0...teams[i].length
          party.push(teams[i][j])
        end
        teams[i] = RuledTeam.new(party,rule)
      elsif teams[i].rating < toolowrating
        teams[i] = RuledTeam.new(party,rule)
      end
      i += 1
    end
    save_data(teams, tag + "teams.rxdata")
    yield(nil)
    while teams.length < maxteams
      yield(nil) if teams.length % 10 == 0
      pbReplenishBattlePokemon(party, rule)
      teams.push(RuledTeam.new(party, rule))
    end
    save_data(party, tag + ".rxdata")
    teams = teams.sort { |a, b| b.rating <=> a.rating }
    yield(_INTL("Simulating battles ({1} of {2})", iter + 1, iterations))
    i = 0
    loop do
      changed = false
      teams.length.times { |j|
        yield(nil)
        other = j
        5.times do
          other = rand(teams.length)
          next if other == j
        end
        next if other == j
        changed = true
        pbRuledBattle(teams[j], teams[other], rule)
      }
      i += 1
      gameCount = 0
      for team in teams
        gameCount += team.games
      end
      yield(nil)
      if gameCount / teams.length >= 12
        for team in teams
          team.updateRating
        end
        break
      end
    end
    teams.sort! { |a, b| b.rating <=> a.rating }
    save_data(teams, tag + "teams.rxdata")
  end
  party = []
  yield(nil)
  teams.sort! { |a, b| a.rating <=> b.rating }
  for team in teams
    next if team.rating <= cutoffrating
    for i in 0...team.length
      party.push(team[i])
    end
  end
  rule = oldrule
  yield(nil)
  party = pbRemoveDuplicates(party)
  yield(_INTL("Writing results"))
  party = pbArrangeByTier(party, rule)
  yield(nil)
  pbTrainerInfo(party, tag, rule) { yield(nil) }
  yield(nil)
end

#===============================================================================
#
#===============================================================================
def pbWriteCup(id, rules)
  return if !$DEBUG
  trlists = (load_data("Data/trainer_lists.dat") rescue [])
  list = []
  for i in 0...trlists.length
    tr = trlists[i]
    if tr[5]
      list.push("*" + (tr[3].sub(/\.txt$/, "")))
    else
      list.push((tr[3].sub(/\.txt$/, "")))
    end
  end
  cmd = 0
  if trlists.length != 0
    cmd = pbMessage(_INTL("Generate Pokémon teams for this challenge?"),
       [_INTL("NO"), _INTL("YES, USE EXISTING"), _INTL("YES, USE NEW")], 1)
  else
    cmd = pbMessage(_INTL("Generate Pokémon teams for this challenge?"),
       [_INTL("YES"), _INTL("NO")], 2)
    if cmd == 0
      cmd = 2
    elsif cmd == 1
      cmd = 0
    end
  end
  return if cmd == 0   # No
  if cmd == 1   # Yes, use existing
    cmd = pbMessage(_INTL("Choose a challenge."), list, -1)
    if cmd >= 0
      pbMessage(_INTL("This challenge will use the Pokémon list from {1}.", list[cmd]))
      for i in 0...trlists.length
        tr = trlists[i]
        while !tr[5] && tr[2].include?(id)
          tr[2].delete(id)
        end
      end
      trlists[cmd][2].push(id) if !trlists[cmd][5]
      save_data(trlists, "Data/trainer_lists.dat")
      Graphics.update
      Compiler.write_trainer_lists
    end
    return
  elsif cmd == 2   # Yes, use new
    return if !pbConfirmMessage(_INTL("This may take a long time. Are you sure?"))
    mw = pbCreateMessageWindow
    t = Time.now
    pbGenerateChallenge(rules, id) { |message|
      if Time.now - t >= 5
        Graphics.update
        t = Time.now
      end
      if message
        pbMessageDisplay(mw, message, false)
        Graphics.update
        t = Time.now
      end
    }
    pbDisposeMessageWindow(mw)
    pbMessage(_INTL("Team generation complete."))
  end
end
