#===============================================================================
#  EBDX debug menu
#===============================================================================
class PokeBattle_Scene
  #-----------------------------------------------------------------------------
  #  debug menu processor
  #-----------------------------------------------------------------------------
  def ebsDebugMenu
    cw = @commandWindow
    # hide UI (animation)
    pbHideAllDataboxes
    cw.hidePlay
    options = ["Debug EBDX Animations", "Debug Scene Vector"]
    # begin main menu loop
    loop do
      @idleTimer = 0 # reset idle timer to prevent scene from moving
      cmd = Kernel.pbShowCommands(@sprites["msgwindow"], options, -1)
      case cmd
      #------------------------------------------------------------------------
      when 0 # debug move animations
        animations = EliteBattle.getDefinedAnimations
        opt = (animations[0] + animations[1]).sort
        loop do
          @idleTimer = 0
          ccd = Kernel.pbShowCommands(@sprites["msgwindow"], opt, -1)
          break if ccd < 0
          sel = opt[ccd]
          user = Kernel.pbShowCommands(@sprites["msgwindow"], ["Opponent","Player"])
          target = 1 - user
          if animations[0].include?(sel) # move animations
            EliteBattle.playMoveAnimation(sel.to_sym, self, user, target, 0, false)
          elsif animations[1].include?(sel) # common animations
            EliteBattle.playCommonAnimation(sel.to_sym, self, user, target, 0)
          end
          self.wait(20, true)
        end
      #------------------------------------------------------------------------
      when 1 # debug scene vector
        @vector.reset
        vector = EliteBattle.get_vector(:MAIN, @battle)
        temp = Sprite.new(@msgview)
        temp.bitmap = Bitmap.new(@msgview.width, @msgview.height)
        pbSetSystemFont(temp.bitmap)
        nav = Sprite.new(@msgview)
        nav.bitmap = Bitmap.new(@msgview.width, @msgview.height)
        pbSetSystemFont(nav.bitmap)
        tempv = vector.clone
        text = [
          ["ARROW KEYS: adjust position", 16, 192 + 56, 0, Color.white, Color.new(0, 0, 0, 125)],
          ["CTRL + <-, ->: adjust angle", 16, 224 + 56, 0, Color.white, Color.new(0, 0, 0, 125)],
          ["ALT + <-, ->: adjust scale", 16, 256 + 56, 0, Color.white, Color.new(0, 0, 0, 125)],
          ["Z + <-, ->: adjust zoom", 16, 288 + 56, 0, Color.white, Color.new(0, 0, 0, 125)],
        ]
        pbDrawTextPositions(nav.bitmap, text)
        loop do
          @idleTimer = 0
          Input.update
          if Input.trigger?(Input::C) # print array
            echoln "Currentl selected vector: #{vector}"
            p "Currently selected vector:", vector
          elsif Input.trigger?(Input::B) # reset vector
            break
          elsif Input.press?(Input::CTRL) # adjust angle
            vector[2] += 1 if Input.repeat?(Input::LEFT) if vector[2] < 60
            vector[2] -= 1 if Input.repeat?(Input::RIGHT) if vector[2] > 1
          elsif Input.press?(Input::ALT) # adjust scale
            vector[3] += 1 if Input.repeat?(Input::RIGHT)
            vector[3] -= 1 if Input.repeat?(Input::LEFT)
          elsif Input.press?(Input::A) # adjust zoom
            vector[4] += 0.1 if Input.repeat?(Input::RIGHT)
            vector[4] -= 0.1 if Input.repeat?(Input::LEFT)
          else # adjust position
            vector[0] += 1 if Input.repeat?(Input::RIGHT)
            vector[0] -= 1 if Input.repeat?(Input::LEFT)
            vector[1] += 1 if Input.repeat?(Input::DOWN)
            vector[1] -= 1 if Input.repeat?(Input::UP)
          end
          if tempv != vector
            @vector.set(vector)
            temp.bitmap.clear
            text = [
              ["X: #{vector[0]}, Y: #{vector[1]}", 16, 16, 0, Color.white, Color.new(0, 0, 0, 125)],
              ["ANGLE: #{vector[2]}, SCALE: #{vector[3]}, ZOOM: #{vector[4]}", 16, 48, 0, Color.white, Color.new(0, 0, 0, 125)],
            ]
            pbDrawTextPositions(temp.bitmap, text)
            tempv = vector.clone
          end
          self.wait(1, true)
        end
        temp.dispose
        nav.dispose
        @vector.reset
      end
      #------------------------------------------------------------------------
      break if cmd < 0
    end
    # revert changes
    cw.showPlay
    pbShowAllDataboxes
  end
  #-----------------------------------------------------------------------------
end
