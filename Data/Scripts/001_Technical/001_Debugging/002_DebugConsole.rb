# To use the console, use the executable explicitly built
# with the console enabled on Windows. On Linux and macOS,
# just launch the executable directly from a terminal.
module Console
  def self.setup_console
    return unless $DEBUG
    echoln "GPU Cache Max: #{Bitmap.max_size}"
    echoln "-------------------------------------------------------------------------------"
    echoln "#{System.game_title} Output Window"
    echoln "-------------------------------------------------------------------------------"
    echoln "If you can see this window, you are running the game in Debug Mode. This means"
    echoln "that you're either playing a debug version of the game, or you're playing from"
    echoln "within RPG Maker XP."
    echoln ""
    echoln "Closing this window will close the game. If you want to get rid of this window,"
    echoln "run the program from the Shell, or download a release version of the game."
    echoln ""
    echoln "You are using v#{Essentials::GEN_8_VERSION} of the Generation 8 Project for Essentials v19.1"
    echoln ""
    echoln "-------------------------------------------------------------------------------"
    echoln "Debug Output:"
    echoln "-------------------------------------------------------------------------------"
    echoln ""
  end

  def self.readInput
    return gets.strip
  end

  def self.readInput2
    return self.readInput
  end

  def self.get_input
    echo self.readInput2
  end
end

module Kernel
  def echo(string)
    return unless $DEBUG
    printf(string.is_a?(String) ? string : string.inspect)
  end

  def echoln(string)
    echo(string)
    echo("\r\n")
  end
end

Console.setup_console
