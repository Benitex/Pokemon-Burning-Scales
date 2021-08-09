#===============================================================================
#  Elite Battle: DX
#    by Luka S.J.
# ----------------
#  Pre-defined battle environment configurations
#
#  Not all configurations are used by default.
#  Edit the appropriate battle scene here to have it reflected
#  or add your own ones.
#===============================================================================
module EnvironmentEBDX
  #-----------------------------------------------------------------------------
  CAVE = {
    "backdrop" => "Cave", "img001" => {
      :scrolling => true, :speed => 2, :direction => -1,
      :bitmap => "decor006",
      :oy => 0, :z => 3, :flat => true, :opacity => 155
    }, "img002" => {
      :scrolling => true, :speed => 1, :direction => 1,
      :bitmap => "decor009",
      :oy => 0, :z => 3, :flat => true, :opacity => 96
    }, "img003" => {
      :scrolling => true, :speed => 0.5, :direction => 1,
      :bitmap => "fog",
      :oy => 0, :z => 4, :flat => true
    }
  }
  #-----------------------------------------------------------------------------
  DARKCAVE = {
    "backdrop" => "CaveDark", "img003" => {
      :scrolling => true, :speed => 0.5, :direction => 1,
      :bitmap => "fog",
      :oy => 0, :z => 4, :flat => true
    }, "bubbles" => "bubbleDark"
  }
  #-----------------------------------------------------------------------------
  WATER = { "backdrop" => "Water", "sky" => true, "water" => true }
  #-----------------------------------------------------------------------------
  UNDERWATER = {
    "backdrop" => "Underwater", "lightsC" => true, "img001" => {
      :bitmap => "forestShade", :z => 1, :flat => true,
      :oy => 0, :y => 94, :sheet => true, :frames => 2, :speed => 16
    }, "tallGrass" => {
      :elements => 5, :bitmap => "seaWeed",
      :x => [124,274,62,248,275],
      :y => [160,140,185,246,174],
      :z => [2,1,17,27,17],
      :zoom => [0.5,0.15,0.6,1,0.5],
      :mirror => [false,true,true,false,true]
    }, "bubbles" => true, "outdoor" => false, "underwater" => true
  }
  #-----------------------------------------------------------------------------
  FOREST = {
    "backdrop" => "Forest", "lightsC" => true, "img001" => {
      :bitmap => "forestShade", :z => 1, :flat => true,
      :oy => 0, :y => 94, :sheet => true, :frames => 2, :speed => 16
    }, "trees" => {
      :bitmap => "treePine", :colorize => false, :elements => 8,
      :x => [92,248,300,40,138,216,274,318],
      :y => [132,132,144,118,112,118,110,110],
      :zoom => [1,1,1.1,0.9,0.8,0.85,0.75,0.75],
      :z => [2,2,2,1,1,1,1,1],
    }, "outdoor" => false
  }
  #-----------------------------------------------------------------------------
  INDOOR = {
    "backdrop" => "IndoorA", "img001" => {
      :bitmap => "decor007",
      :oy => 0, :z => 1, :flat => true, :scrolling => true, :speed => 0.5
    }, "img002" => {
      :bitmap => "decor008",
      :oy => 0, :z => 1, :flat => true, :scrolling => true, :direction => -1
    }, "lightsA" => true, "outdoor" => false
  }
  #-----------------------------------------------------------------------------
  OUTDOOR = {
    "backdrop" => "Field", "sky" => true, "trees" => {
      :elements => 9,
      :x => [150,271,78,288,176,42,118,348,321],
      :y => [108,117,118,126,126,128,136,136,145],
      :zoom => [0.44,0.44,0.59,0.59,0.59,0.64,0.85,0.7,1],
      :mirror => [false,false,true,true,true,false,false,true,false]
    }
  }
  #-----------------------------------------------------------------------------
  DISCO = {
    "backdrop" => "DanceFloor", "img001" => {
      :bitmap => "discoBg",
      :ox => 0, :flat => true, :rainbow => true, :speed => 8
    }, "lightsB" => true, "img002" => {
      :bitmap => "crowd",
      :oy => 32, :y => 102, :z => 2, :flat => false, :sheet => true,
      :vertical => true, :speed => 8, :frames => 2
    }
  }
  #-----------------------------------------------------------------------------
  NET = {
    "backdrop" => "Net", "img001" => {
      :scrolling => true, :vertical => true, :speed => 1,
      :bitmap => "decor003d",
      :oy => 180, :y => 90, :flat => true
    }, "img002" => {
      :bitmap => "crowd_d",
      :oy => 32, :y => 112, :z => 2, :flat => false, :sheet => true,
      :vertical => true, :speed => 8, :frames => 2
    }
  }
  #-----------------------------------------------------------------------------
  MOUNTAIN = {
    "backdrop" => "Mountain", "sky" => true, "trees" => {
      :elements => 8, :bitmap => "treeC", :colorize => "slight",
      :x => [271,78,288,176,42,118,348,321],
      :y => [117,118,122,122,127,127,128,132],
      :zoom => [0.44,0.59,0.59,0.59,0.64,0.85,0.7,1],
      :mirror => [false,true,true,true,false,false,true,false]
    }, "img001" => {
      :bitmap => "mountainC",
      :x => 192, :y => 107
    }
  }
  #-----------------------------------------------------------------------------
  MOUNTAINLAKE = {
    "backdrop" => "Field", "sky" => true, "trees" => {
      :elements => 9,
      :x => [150,271,78,288,176,42,118,348,321],
      :y => [108,117,118,122,122,127,127,128,132],
      :zoom => [0.44,0.44,0.59,0.59,0.59,0.64,0.85,0.7,1],
      :mirror => [false,false,true,true,true,false,false,true,false]
    }, "img001" => {
      :bitmap => "mountain",
      :x => 192, :y => 107
    }, "base" => "Water", "water" => true
  }
  #-----------------------------------------------------------------------------
  DIMENSION = {
    "backdrop" => "Sapphire",
    "vacuum" => "dark006",
    "img001" => {
      :scrolling => true, :vertical => true, :speed => 1,
      :bitmap => "decor003a",
      :oy => 180, :y => 90, :flat => true
    }, "img002" => {
      :bitmap => "shade",
      :oy => 100, :y => 98, :flat => false
    }, "img003" => {
      :scrolling => true, :speed => 16,
      :bitmap => "decor005",
      :oy => 0, :y => 4, :z => 4, :flat => true
    }, "img004" => {
      :scrolling => true, :speed => 16, :direction => -1,
      :bitmap => "decor006",
      :oy => 0, :z => 4, :flat => true
    }, "img005" => {
      :scrolling => true, :speed => 0.5,
      :bitmap => "base001a",
      :oy => 0, :y => 122, :z => 1, :flat => true
    }
  }
  #-----------------------------------------------------------------------------
  CHAMPION = {
    "backdrop" => "Champion",
    "lightsA" => true,
    "img001" => {
      :scrolling => true, :vertical => true, :speed => 1,
      :bitmap => "decor003",
      :oy => 180, :y => 90, :z => 1, :flat => true
    }, "img002" => {
      :bitmap => "decor004",
      :oy => 100, :y => 98, :z => 2, :flat => false
    }, "img003" => {
      :scrolling => true, :speed => 16,
      :bitmap => "decor005",
      :oy => 0, :y => 4, :z => 4, :flat => true
    }, "img004" => {
      :scrolling => true, :speed => 16, :direction => -1,
      :bitmap => "decor006",
      :oy => 0, :z => 4, :flat => true
    }, "img005" => {
      :scrolling => true, :speed => 0.5,
      :bitmap => "base001",
      :oy => 0, :y => 122, :z => 1, :flat => true
    }, "img006" => {
      :bitmap => "pillars001",
      :y => 128, :x => 144, :z => 3
    }, "img007" => {
      :bitmap => "pillars002",
      :y => 192, :x => 144, :z => 18
    },
  }
  #-----------------------------------------------------------------------------
  STAGE = {
    "backdrop" => "IndoorB", "spinLights" => true, "lightsA" => true,
    "img001" => {
      :scrolling => true, :speed => 1,
      :bitmap => "decor001",
      :oy => 0, :z => 1, :flat => true
    }, "img002" => {
      :scrolling => true, :speed => 1, :direction => -1,
      :bitmap => "decor002",
      :oy => 0, :z => 1, :flat => true
    },
  }
  #-----------------------------------------------------------------------------
  DARKNESS = {
    "backdrop" => "Darkness",
    "img001" => {
      :bitmap => "dark001",
      :oy => 70, :ox => 70, :y => 128, :x => 248, :z => 2, :effect => "rotate", :zoom => 0.75
    }, "img002" => {
      :bitmap => "dark002",
      :oy => 120, :ox => 120, :y => 128, :x => 242, :z => 3, :direction => -1, :effect => "rotate", :zoom => 0.75
    }, "img003" => {
      :bitmap => "dark003",
      :oy => 110, :ox => 110, :y => 128, :x => 234, :z => 4, :effect => "rotate"
    }, "img004" => {
      :scrolling => true, :speed => 0.5,
      :bitmap => "darkFog",
      :oy => 0, :y => 0, :z => 5, :flat => true
    }, "vacuum" => true
  }
  #-----------------------------------------------------------------------------
  MAGMA = {
    "backdrop" => "Cave", "img001" => {
      :scrolling => true, :speed => 2, :direction => -1,
      :bitmap => "decor006",
      :oy => 0, :z => 3, :flat => true, :opacity => 155
    }, "img002" => {
      :scrolling => true, :speed => 1, :direction => 1,
      :bitmap => "decor009",
      :oy => 0, :z => 3, :flat => true, :opacity => 96
    }, "img003" => {
      :scrolling => true, :speed => 0.5, :direction => 1,
      :bitmap => "fog",
      :oy => 0, :z => 4, :flat => true
    }, "bubbles" => "bubbleRed", "img005" => {
      :scrolling => true, :speed => 0.5, :direction => -1,
      :bitmap => "base001",
      :oy => 0, :y => 122, :z => 1, :flat => true
    }
  }
  #-----------------------------------------------------------------------------
  SKY = {
    "backdrop" => "sky", "trees" => {
        :bitmap => "cluster", :colorize => false, :elements => 12,
        :x => [26,6,44,4,136,104,372,342,236,180,214,282],
        :y => [184,210,216,258,188,278,212,284,234,238,258,170],
        :mirror => [false,false,true,true,false,false,true,false,false,false,false,false],
        :zoom => [1,1,1,1,1,1,1,1,1,1,1,0.7],
        :z => [2,2,2,2,2,2,2,2,2,2,2,2],
      }, "sky" => true, "noshadow" => true, "img001" => {
        :scrolling => true, :speed => 0.5,
        :bitmap => "base001c",
        :oy => 0, :y => 122, :z => 3, :flat => true
      }
  }
  #-----------------------------------------------------------------------------
  SNOW = {
    "backdrop" => "Snow", "sky" => true, "trees" => {
      :elements => 9,
      :x => [150,271,78,288,176,42,118,348,321],
      :y => [108,117,118,126,126,128,136,136,145],
      :zoom => [0.44,0.44,0.59,0.59,0.59,0.64,0.85,0.7,1],
      :mirror => [false,false,true,true,true,false,false,true,false],
      :colorize => "slight", :bitmap => "treeB"
    }, "img001" => {
      :bitmap => "mountainB",
      :x => 192, :y => 107
    }
  }
end
#===============================================================================
#  Extra additions to the battle scene based on terrain
#===============================================================================
module TerrainEBDX
  #-----------------------------------------------------------------------------
  MOUNTAIN = { "img001" => { :bitmap => "mountain", :x => 192, :y => 107 } }
  #-----------------------------------------------------------------------------
  PUDDLE = { "base" => "Puddle" }
  #-----------------------------------------------------------------------------
  DIRT = { "base" => "Dirt" }
  #-----------------------------------------------------------------------------
  TALLGRASS = {
    "tallGrass" => {
      :elements => 7,
      :x => [124,274,204,62,248,275,182],
      :y => [160,140,140,185,246,174,170],
      :z => [2,1,2,17,27,17,17],
      :zoom => [0.7,0.35,0.5,1,1.5,0.7,1],
      :mirror => [false,true,false,true,false,true,false]
    }
  }
  #-----------------------------------------------------------------------------
  CONCRETE = { "base" => "Concrete" }
  #-----------------------------------------------------------------------------
  WATER = { "base" => "Water", "water" => true }
end
