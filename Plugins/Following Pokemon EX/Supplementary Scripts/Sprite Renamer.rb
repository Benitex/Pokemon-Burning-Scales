#-------------------------------------------------------------------------------
# Include Pokemon overworlds for Following Pokemon in sprite renamer
#-------------------------------------------------------------------------------
module SpriteRenamer
  module_function
  #-----------------------------------------------------------------------------
  # Convert Pokemon overworld sprites to new format
  #-----------------------------------------------------------------------------
  def convert_pokemon_ows(src_dir, dest_dir)
    return if !FileTest.directory?(src_dir)
    Dir.mkdir(dest_dir) if !FileTest.directory?(dest_dir)
    for ext in ["Followers/", "Followers shiny/"]
      Dir.mkdir(dest_dir + ext) if !FileTest.directory?(dest_dir + ext)
    end
    # generates a list of all graphic files
    files = readDirectoryFiles(src_dir, ["*.png"])
    # starts automatic renaming
    files.each_with_index do |file, i|
      Graphics.update if i % 100 == 0
      pbSetWindowText(_INTL("Converting Pokémon overworlds {1}/{2}...", i, files.length)) if i % 50 == 0
      next if !file[/^\d{3}[^\.]*\.[^\.]*$/]
      if file[/s/] && !file[/shadow/]
        prefix = "Followers shiny/"
      else
        prefix = "Followers/"
      end
      new_filename = convert_pokemon_filename(file,prefix)
      # moves the files into their appropriate folders
      File.move(src_dir + file, dest_dir + new_filename)
    end
  end
  #-----------------------------------------------------------------------------
  # Add new overworld method to regular sprite converter as well
  #-----------------------------------------------------------------------------
  if defined?(convert_files)
    class << self
      alias __followingpkmn__convert_files convert_files unless method_defined?(:__followingpkmn__convert_files)
    end

    def convert_files(*args)
      __followingpkmn__convert_files(*args)
      convert_pokemon_ows("Graphics/Characters/","Graphics/Characters/")
      pbSetWindowText(nil)
    end
  end
  #-----------------------------------------------------------------------------
end

#-------------------------------------------------------------------------------
# New method for easily get the appropriate Following Pokemon Graphic
#-------------------------------------------------------------------------------
module GameData
  class Species
    def self.ow_sprite_filename(species, form = 0, gender = 0, shiny = false, shadow = false)
      ret = self.check_graphic_file("Graphics/Characters/", species, form,
                                    gender, shiny, shadow, "Followers")
      ret = "Graphics/Characters/Followers/" if nil_or_empty?(ret)
	    return ret
    end
  end
end
