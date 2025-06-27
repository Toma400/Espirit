import std/strformat
import std/strutils
import indexes

export indexes

const reserved_records* = [
  "ACTI", "ALCH", "APPA", "ARMO", "BODY", "BOOK", "BSGN", "CELL", "CLAS", "CLOT", "CONT", "CREA", "DIAL", "DOOR", "ENCH",
  "FACT", "GLOB", "GMST", "INFO", "INGR", "LAND", "LEVC", "LEVI", "LIGH", "LOCK", "LTEX", "MGEF", "MISC", "NPC_", "PGRD",
  "PROB", "RACE", "REGN", "REPA", "SCPT", "SKIL", "SNDG", "SOUN", "SPEL", "SSCR", "STAT", "TES3", "WEAP"
]

type
  MWClothData* = object
    kind*   : uint32  # type (please refer to `MWClothType` enum in -indexes.nim-)
    weight* : float32 # weight
    value*  : uint16  # value
    ench*   : uint16  # enchantment points
  MWClothObj* = object
    #[ TODO: Is this a struct with `mname/fname`, or are those separate? Ref: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format/CLOT ]#
    biped* : uint8       # biped object (please refer to `MWClothBipedType` enum in type section below)
    mname* : string = "" # male name for cloth (optional)
    fname* : string = "" # female name for cloth (optional, `mname` used if absent)
  MWCloth* = object
    id*     : string          # ID
    model*  : string          # model name
    name*   : string = ""     # name (optional)
    script* : string = ""     # script name (optional)
    enchnm* : string = ""     # enchantment name (optional)
    icon*   : string = ""     # icon name (optional)
    data*   : MWClothData
    objs*   : seq[MWClothObj] # objects (repeatable)
  MWMiscData* = object
    weight* : float32 # weight
    value*  : uint32  # value
    unkn*   : uint32  # unknown field, only uses 0 and 1, but usually unused
  MWMisc* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWMiscData
  MWStatic* = object
    id*    : string # ID
    model* : string # model name
  MWContainer* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    weight*   : float32
    flags*    : uint32      # 0x1 = organic, 0x2 = respawns (organic only), 0x8 = unknown, always set
    contents* : seq[(int32, array[32, char])] # see if struct isn't better
  MWActivator* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
  MWLightData* = object
    weight*   : float32
    value*    : uint32
    time*     : int32
    radius*   : uint32
    color*    : (uint8, uint8, uint8, uint8) # rgb(a)?
    flags*    : uint32
  MWLight* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    sound*    : string = "" # sound name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWLightData
  MWIngredientData* = object
    weight*   : float32         # weight
    value*    : uint32          # value
    effindex* : array[4, int32] # effect indexes
    skill*    : array[4, int32] # skill IDs
    attr*     : array[4, int32] # attribute IDs
  MWIngredient* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWIngredientData
  MWPotionData* = object
    weight*   : float32
    value*    : uint32
    flags*    : uint32 # 0x1 = autocalc
  MWPotionEnch* = object
    effindex* : uint16
    skill*    : int8   # skill affected (-1 if not applicable)
    attr*     : int8   # attribute affected (-1 if not applicable)
    range*    : uint32 # 0 = self, 1 = touch, 2 = target
    area*     : uint32
    duration* : uint32
    mmin*     : uint32 # magnitude min
    mmax*     : uint32 # magnitude max
  MWPotion* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWPotionData
    ench*   : seq[MWPotionEnch]
  MWBookData* = object
    weight* : float32 # weight
    value*  : uint32  # value
    flags*  : uint32  # if scroll or not
    skill*  : int32   # -1 if none
    ench*   : uint32  # enchantment points
  MWBook* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    enchnm* : string = "" # enchantment name (optional)
    text*   : string = "" # text contents (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWBookData
  MWLeveledItem* = object
    id*     : string      # ID
    data*   : uint32      # flags (0x1 = Calculate for each item in count | 0x2 = Calculate from all levels <= PC's level)
    nnam*   : uint8       # chance none?
    count*  : uint32 = 0  # count of following items (optional)
    items*  : seq[(string, uint16)] # (item name, PC level)
  MWDoor* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    soundo*   : string = "" # sound name: open (optional)
    soundc*   : string = "" # sound name: close (optional)
  MWLandHeightData* = object
    hoffset*  : float32
    hdata*    : array[65, array[65, int8]] # height data is not absolute values but uses differences between adjacent pixels
                                           # thus a pixel value of 0 means it has the same height as the last pixel
                                           # note that the Y-direction of the data is from the bottom up
    junk*     : array[3, uint8]
  MWLand* = object
    coord*    : (int32, int32)
    data*     : uint32                                   # data types included; if the relevant bit isn't set, the related fields will not be loaded, even if present
                                                           # 0x01 = Includes VNML, VHGT and WNAM
                                                           # 0x02 = Includes VCLR
                                                           # 0x04 = Includes VTEX
    vnormals* : array[65, array[65, (int8, int8, int8)]] # (x, y, z); y-direction of the data is from the bottom up
    hgdata*   : MWLandHeightData                         # heights for terrain
    hgmap*    : array[9,  array[9, uint8]]               # heights for map
    vcolors*  : array[65, array[65, (uint8, uint8, uint8)]]
    vtex*     : array[16, array[16, uint16]]
  MWLandTexture* = object
    id*       : string      # ID
    index*    : uint32      # although nominally a uint32, uint16s are used as indices in LAND records, so these are effectively restricted to uint16 values
    tex*      : string
  MWRegionSoundChances* = object
    name*     : array[32, char]
    chance*   : uint8
  MWRegion* = object
    id*       : string                    # ID
    name*     : string                    # name
    weather*  : (uint8, uint8,            # weather
                 uint8, uint8,
                 uint8, uint8,
                 uint8, uint8,
                 uint8, uint8)              # Bloodmoon/Tribunal only, set to 0 if not available
    sleep_cr* : string                    # sleep creature
    map_col*  : (uint8, uint8,            # map colour
                 uint8, uint8)
    sound_ch* : seq[MWRegionSoundChances] # sound chances
  MWRepairToolData* = object
    weight*   : float32
    value*    : uint32
    uses*     : uint32
    quality*  : float32
  MWRepairTool* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWRepairToolData
  MWApparatusData* = object
    kind*     : uint32 # type of apparatus (please refer to `MWApparatusType` enum in -indexes.nim-)
    quality*  : float32
    weight*   : float32
    value*    : uint32
  MWApparatus* = object
    id*       : string      # ID
    model*    : string = "" # model name (optional apparently)
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWApparatusData
  MWLockData* = object
    weight*   : float32
    value*    : uint32
    quality*  : float32
    uses*     : uint32
  MWLock* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWLockData
  MWProbeData* = object
    weight*   : float32
    value*    : uint32
    quality*  : float32
    uses*     : uint32
  MWProbe* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWProbeData
  MWSkillData* = object
    attr*     : uint32             # attribute
    spec*     : uint32             # specialisation
    usev*     : (float32, float32, # use values
                 float32, float32)
  MWSkill* = object
    index*    : uint32      # index
    descr*    : string = "" # description
    data*     : MWSkillData

# Enum references
# type
#   MWClothType* = enum
#     Pants      = 0
#     Shoes      = 1
#     Shirt      = 2
#     Belt       = 3
#     Robe       = 4
#     RightGlove = 5
#     LeftGlove  = 6
#     Skirt      = 7
#     Ring       = 8
#     Amulet     = 9
#   MWClothBipedType* = enum
#     Head          = 1
#     Hair          = 2
#     Cuirass       = 3
#     Groin         = 4
#     Skirt         = 5
#     RightHand     = 6
#     LeftHang      = 7
#     RightWrist    = 8
#     LeftWrist     = 9
#     Shield        = 10
#     RightForearm  = 11
#     LeftForearm   = 12
#     RightUpperArm = 13
#     LeftUpperArm  = 14
#     RightFoot     = 15
#     LeftFoot      = 16
#     RightAnkle    = 17
#     LeftAnkle     = 18
#     RightKnee     = 19
#     LeftKnee      = 20
#     RightUpperLeg = 21
#     LeftUpperLeg  = 22
#     RightPauldron = 23
#     LeftPauldron  = 24
#     Weapon        = 25
#     Tail          = 26