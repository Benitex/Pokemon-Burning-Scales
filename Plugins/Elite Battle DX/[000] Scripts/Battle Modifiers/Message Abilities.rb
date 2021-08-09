#===============================================================================
#  EBDX Ability Messages override
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  Show message splash
  #-----------------------------------------------------------------------------
  def pbShowAbilitySplash(battler = nil, ability = nil)
    # gets the info parameters
    return if battler.nil? || !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    effect = (ability.is_a?(String)) ? ability : GameData::Ability.get(battler.ability).real_name
    # constructs necessary bitmap
    bitmap = pbBitmap("Graphics/EBDX/Pictures/UI/abilityMessage")
    rect = playerBattler?(battler) ? Rect.new(0, bitmap.height/2, bitmap.width, bitmap.height/2) : Rect.new(0, 0, bitmap.width, bitmap.height/2)
    baseColor = EliteBattle.get(:messageDarkColor)
    @sprites["abilityMessage"].bitmap.clear
    @sprites["abilityMessage"].bitmap.blt(0, bitmap.height/2, bitmap, rect)
    bitmap = @sprites["abilityMessage"].bitmap
    # draws text with outline
    pbDrawOutlineText(bitmap, 28, 4, bitmap.width - 38, bitmap.font.size, _INTL("{1}'s", battler.name), baseColor, Color.new(0, 0, 0, 125), 0)
    pbDrawOutlineText(bitmap, 0, bitmap.height/2 + 4, bitmap.width - 28, bitmap.font.size, "#{effect}", baseColor, Color.new(0, 0, 0, 125), 2)
    # positions message box
    width = bitmap.width
    @sprites["abilityMessage"].x = playerBattler?(battler) ? (-width - width%10) : (Graphics.width + width%10)
    @sprites["abilityMessage"].y = @sprites["dataBox_#{battler.index}"].y
    pbSEPlay("EBDX/Ability Message")
    @sprites["abilityMessage"].zoom_y = 0
    10.times do
      @sprites["abilityMessage"].x += (playerBattler?(battler) ? 1 : -1)*(width/10)
      @sprites["abilityMessage"].zoom_y += 0.1
      self.wait(1, true)
    end
    # flashes message box
    @sprites["abilityMessage"].tone = Tone.new(255, 255, 255)
    16.times do
      @sprites["abilityMessage"].tone.all -= 16 if @sprites["abilityMessage"].tone.all > 0
      self.wait(1, true)
    end
  end
  #-----------------------------------------------------------------------------
  #  Hide message splash
  #-----------------------------------------------------------------------------
  def pbHideAbilitySplash(battler = nil)
    return if battler.nil? || !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    10.times do
      @sprites["abilityMessage"].x += (playerBattler?(battler) ? -1 : 1)*(@sprites["abilityMessage"].bitmap.width/10)
      @sprites["abilityMessage"].zoom_y -= 0.1
      self.wait(1, true)
    end
    @sprites["abilityMessage"].zoom_y = 0
  end
  #-----------------------------------------------------------------------------
  #  Replace message splash
  #-----------------------------------------------------------------------------
  def pbReplaceAbilitySplash(battler)
    return if battler.nil? || !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    pbShowAbilitySplash(battler)
  end
  #-----------------------------------------------------------------------------
end
