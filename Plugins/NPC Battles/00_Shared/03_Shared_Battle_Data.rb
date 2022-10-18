module GameData
    class BattleData
        attr_reader :id
        attr_reader :script
        attr_reader :settings

        DATA = {}
        
        extend ClassMethods
        include InstanceMethods

        def self.load; end
        def self.save; end

        DEFAULT_SETTINGS = {
            :size0              => 1,
            :size1              => 1,
            :outcome_var        => 1,
            :full_names         => [false,false],
            :random_misses      => false,
            :random_move_effect => false,
            :random_abil_effect => false,
            :random_item_effect => false,
            :random_crits       => false,
            :can_lose           => true,
            :round_offset       => 0,
            :control_player     => true,
            :exp_gain           => false,
            :wild_battle        => false,
        }

        def initialize(hash)
            @id             = hash[:id]
            @settings       = DEFAULT_SETTINGS.clone
            if hash[:settings]
                @settings   = DEFAULT_SETTINGS.clone.merge(hash[:settings])
            end
            @participants   = hash[:participants]
            @script         = hash[:script]
        end

        def initializeBattle
            playerSide = getPlayerSideArray
            opponentSide = getOpponentSideArray
            battle = Scripted_Battle_Data.new(playerSide,opponentSide,@script,@settings)
            return battle
        end

        def getPlayerSideArray
            players = []
            @participants.each{ |scriptKey,participant|
                if participant[:side] == :PLAYER
                    if participant.key?(:trainer_type)
                        trainer  = generateTrainer(participant,scriptKey)
                        players.push(trainer)
                    elsif participant.key?(:species)
                        pokemon = generateWildPokemon(participant,scriptKey)
                        players.push(pokemon)
                    else
                        raise _INTL("{1} is neither a trainer nor a Pokemon!", participant)
                    end
                end
            }
            return players
        end

        def getOpponentSideArray
            opponents = []
            @participants.each{ |scriptKey,participant|
                if participant[:side] == :OPPONENT
                    if participant.key?(:trainer_type)
                        trainer  = generateTrainer(participant,scriptKey)
                        opponents.push(trainer)
                    elsif participant.key?(:species)
                        pokemon = generateWildPokemon(participant,scriptKey)
                        opponents.push(pokemon)
                    else
                         raise _INTL("{1} is neither a trainer nor a Pokemon!", participant) if !trainerData[:party]
                    end
                end
            }
            return opponents
        end

        def generateTrainer(trainerData,scriptKey)
            trainer_type = trainerData[:trainer_type]
            name = trainerData[:name]
            lose_text = trainerData[:lose_text] || nil
            trainer_version = trainerData[:party_id] || 0
            trainer = pbLoadTrainer(trainer_type,name,trainer_version)
            pbMissingTrainer(trainer_type,name,trainer_version) if !trainer && $DEBUG
            raise _INTL("Trainer needs to be defined to use in battles!") if !trainer
            party = []
            if trainerData.key?(:party)
                trainerData[:party].each{ |pokeKey, pokemonData| 
                    newPoke = generatePokemon(pokemonData, pokeKey, trainer)
                    party.push(newPoke)
                }
                trainer.party       = party
            else
                trainer.party.each{|poke|
                    poke.script_key = poke.name
                }
            end
            if trainerData.key?(:display_name)
                trainer.name = trainerData[:display_name]
            end
            trainer.lose_text   = lose_text
            trainer.script_key  = scriptKey
            return trainer
        end

        def generateWildPokemon(pokemonData,scriptKey)
            return generatePokemon(pokemonData,scriptKey, nil)
        end
        
        def generatePokemon(pokemonData,scriptKey, owner = nil,withMoves=true)
            species     = pokemonData[:species]
            level       = pokemonData[:level]
            pokemon = Pokemon.new(species,level,owner,withMoves)
            pokemon.script_key = scriptKey
            if pokemonData.key?(:item)
                pokemon.item = pokemonData[:item]
            end

            if pokemonData.key?(:name)
                pokemon.name = pokemonData[:name] 
            end

            if pokemonData.key?(:abillity)
                pokemon.ability = pokemonData[:abillity]
            end

            return pokemon
        end
    end
end