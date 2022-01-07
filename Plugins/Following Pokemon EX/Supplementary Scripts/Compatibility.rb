#-------------------------------------------------------------------------------
# EBDX Compatibility
#-------------------------------------------------------------------------------
module EliteBattle
  def self.follower(battle)
    return nil if !EliteBattle::USE_FOLLOWER_EXCEPTION
    return (FollowingPkmn.active? && battle.scene.firstsendout) ? 0 : nil
  end
end

#-------------------------------------------------------------------------------
# Remove v19.0 and Gen 8 Project v1.0.4 or below compatibility
#-------------------------------------------------------------------------------
module Compiler
  if defined?(convert_files)
    PluginManager.error("Following Pokemon EX is not compatible with Essentials v19. It's only compatible with v19.1")
  end
end

class PokemonEntryScene2
  if !defined?(MODE4)
    PluginManager.error("Plugin Following Pokemon EX requires plugin Generation 8 Project for Essentials v19.1, if installed, to be version v1.1.0 or higher.")
  end
end

if defined?(Essentials::GEN_8_VERSION) && PluginManager.compare_versions(Essentials::GEN_8_VERSION, "1.1.0") < 0
  PluginManager.error("Plugin Following Pokemon EX requires plugin Generation 8 Project for Essentials v19.1, if installed, to be version v1.1.0 or higher.")
end
