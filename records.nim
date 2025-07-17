import indexes

export indexes

const reserved_records* = [
  "ACTI", "ALCH", "APPA", "ARMO", "BODY", "BOOK", "BSGN", "CELL", "CLAS", "CLOT", "CONT", "CREA", "DIAL", "DOOR", "ENCH",
  "FACT", "GLOB", "GMST", "INFO", "INGR", "LAND", "LEVC", "LEVI", "LIGH", "LOCK", "LTEX", "MGEF", "MISC", "NPC_", "PGRD",
  "PROB", "RACE", "REGN", "REPA", "SCPT", "SKIL", "SNDG", "SOUN", "SPEL", "SSCR", "STAT", "TES3", "WEAP"
]

type
  ParseError* = object of Exception

type
  # === Base object : all main records inherit from it ===
  MWRecordHeader* = object
    name*  : string # formally 'array[4, char]', but it's not particularly practical
    size*  : uint32
    dummy* : uint32
    flags* : uint32
  MWRecordData* = object of RootObj
    size* : int # formally uint32, but is parsed into 'int' by 'getLength'
  MWRecord* = object of RootObj
    header*  : MWRecordHeader
    deleted* : bool

  # === Records & subrecords ===
  MWClothData* = object of MWRecordData
    kind*   : uint32  # type (please refer to `MWClothType` enum in -indexes.nim-)
    weight* : float32 # weight
    value*  : uint16  # value
    ench*   : uint16  # enchantment points
  MWClothObj* = object
    #[ TODO: Is this a struct with `mname/fname`, or are those separate? Ref: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format/CLOT ]#
    biped* : uint8       # biped object (please refer to `MWBipedType` enum in -indexes.nim-)
    mname* : string = "" # male name for cloth (optional)
    fname* : string = "" # female name for cloth (optional, `mname` used if absent)
  MWCloth* = object of MWRecord
    id*     : string          # ID
    model*  : string          # model name
    name*   : string = ""     # name (optional)
    script* : string = ""     # script name (optional)
    enchnm* : string = ""     # enchantment name (optional)
    icon*   : string = ""     # icon name (optional)
    data*   : MWClothData
    objs*   : seq[MWClothObj] # objects (repeatable)
  MWMiscData* = object of MWRecordData
    weight* : float32 # weight
    value*  : uint32  # value
    unkn*   : uint32  # unknown field, only uses 0 and 1, but usually unused
  MWMisc* = object of MWRecord
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWMiscData
  MWStatic* = object of MWRecord
    id*    : string # ID
    model* : string # model name
  MWContainer* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    weight*   : float32
    flags*    : uint32      # 0x1 = organic, 0x2 = respawns (organic only), 0x8 = unknown, always set
    contents* : seq[(int32, array[32, char])] # see if struct isn't better
  MWActivator* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
  MWLightData* = object of MWRecordData
    weight*   : float32
    value*    : uint32
    time*     : int32
    radius*   : uint32
    color*    : (uint8, uint8, uint8, uint8) # rgb(a)?
    flags*    : uint32
  MWLight* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    sound*    : string = "" # sound name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWLightData
  MWIngredientData* = object of MWRecordData
    weight*   : float32         # weight
    value*    : uint32          # value
    effindex* : array[4, int32] # effect indexes
    skill*    : array[4, int32] # skill IDs
    attr*     : array[4, int32] # attribute IDs
  MWIngredient* = object of MWRecord
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWIngredientData
  MWPotionData* = object of MWRecordData
    weight*   : float32
    value*    : uint32
    flags*    : uint32 # 0x1 = autocalc
  MWPotionEnch* = object of MWRecordData
    effindex* : uint16
    skill*    : int8   # skill affected (-1 if not applicable)
    attr*     : int8   # attribute affected (-1 if not applicable)
    range*    : uint32 # 0 = self, 1 = touch, 2 = target
    area*     : uint32
    duration* : uint32
    mmin*     : uint32 # magnitude min
    mmax*     : uint32 # magnitude max
  MWPotion* = object of MWRecord
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWPotionData
    ench*   : seq[MWPotionEnch]
  MWBookData* = object of MWRecordData
    weight* : float32 # weight
    value*  : uint32  # value
    flags*  : uint32  # if scroll or not
    skill*  : int32   # -1 if none
    ench*   : uint32  # enchantment points
  MWBook* = object of MWRecord
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    enchnm* : string = "" # enchantment name (optional)
    text*   : string = "" # text contents (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWBookData
  MWLeveledItem* = object of MWRecord
    id*     : string      # ID
    data*   : uint32      # flags (0x1 = Calculate for each item in count | 0x2 = Calculate from all levels <= PC's level)
    nnam*   : uint8       # chance none?
    count*  : uint32 = 0  # count of following items (optional)
    items*  : seq[(string, uint16)] # (item name, PC level)
  MWDoor* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    soundo*   : string = "" # sound name: open (optional)
    soundc*   : string = "" # sound name: close (optional)
  MWLandHeightData* = object of MWRecordData
    hoffset*  : float32
    hdata*    : array[65, array[65, int8]] # height data is not absolute values but uses differences between adjacent pixels
                                           # thus a pixel value of 0 means it has the same height as the last pixel
                                           # note that the Y-direction of the data is from the bottom up
    junk*     : array[3, uint8]
  MWLand* = object of MWRecord
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
  MWLandTexture* = object of MWRecord
    id*       : string      # ID
    index*    : uint32      # although nominally a uint32, uint16s are used as indices in LAND records, so these are effectively restricted to uint16 values
    tex*      : string
  MWRegionSoundChances* = object
    name*     : array[32, char]
    chance*   : uint8
  MWRegion* = object of MWRecord
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
  MWRepairToolData* = object of MWRecordData
    weight*   : float32
    value*    : uint32
    uses*     : uint32
    quality*  : float32
  MWRepairTool* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWRepairToolData
  MWApparatusData* = object of MWRecordData
    kind*     : uint32 # type of apparatus (please refer to `MWApparatusType` enum in -indexes.nim-)
    quality*  : float32
    weight*   : float32
    value*    : uint32
  MWApparatus* = object of MWRecord
    id*       : string      # ID
    model*    : string = "" # model name (optional apparently)
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWApparatusData
  MWLockData* = object of MWRecordData
    weight*   : float32
    value*    : uint32
    quality*  : float32
    uses*     : uint32
  MWLock* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWLockData
  MWProbeData* = object of MWRecordData
    weight*   : float32
    value*    : uint32
    quality*  : float32
    uses*     : uint32
  MWProbe* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWProbeData
  MWSkillData* = object of MWRecordData
    attr*     : uint32             # attribute
    spec*     : uint32             # specialisation
    usev*     : (float32, float32, # use values
                 float32, float32)
  MWSkill* = object of MWRecord
    index*    : uint32      # index
    descr*    : string = "" # description
    data*     : MWSkillData
  MWScriptHeader* = object
    name*     : array[32, char]
    numshort* : uint32 # NumShorts
    numlong*  : uint32 # NumLongs
    numfloat* : uint32 # NumFloats
    size_sdt* : uint32 # ScriptDataSize (same as size of SCDT)
    size_lvr* : uint32 # LocalVarSize (same as size of SCVR)
  MWScriptVariables* = object
    raw*    : string # raw string representation
    shorts* : seq[string]
    longs*  : seq[string]
    floats* : seq[string]
  MWScript* = object of MWRecord
    sheader*  : MWScriptHeader
    vars*     : MWScriptVariables # originally as string (reachable by vars.raw); length derived from header (size_lvr)
    cdata*    : seq[uint8]        # compiled script data; seq as it is derived from header (size_sdt)
    text*     : string
  MWGlobal* = object of MWRecord
    name*     : string
    ftype*    : char     # field type
    value*    : float32  # UESP:
    #[ All globals are stored as floats, regardless of their specified type
    This creates issues with rounding and a loss of precision when using very large positive or negative long values
    Be sure to convert the value to the specified type before using it
    Integer values like zero are often stored as very small float values, rather than a true zero value ]#
  MWStartScript* = object of MWRecord
    name* : string
    data* : string # ASCII digits of unknown meaning
  MWBodyData* = object of MWRecordData
    part*    : uint8 # body part
    vampire* : uint8
    flags*   : uint8 # 1 - female, 2 - playable
    pkind*   : uint8 # body part type
  MWBody* = object of MWRecord
    id*    : string
    model* : string
    race*  : string
    data*  : MWBodyData
  MWGameSetting* = object of MWRecord
    name*   : string  # name[0] directs to type used
    kind*   : char    # not in plugin file, used as support field for name[0] check
    valfl*  : float32 # values (optional)
    vali*   : int32
    vals*   : string
  MWWeaponData* = object of MWRecordData
    weight*  : float32
    value*   : uint32
    kind*    : uint16 # type (please refer to `MWWeaponType` enum in -indexes.nim-)
    health*  : uint16
    speed*   : float32
    reach*   : float32
    enchpts* : uint16 # enchantment points
    chopmin* : uint8  # chop damage
    chopmax* : uint8
    slshmin* : uint8  # slash damage
    slshmax* : uint8
    thrsmin* : uint8  # thrust damage
    thrsmax* : uint8
    flags*   : uint32 # flags, 0 means none (please refer to `MWWeaponFlag` enum in -indexes.nim-)
  MWWeapon* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    enchnm*   : string = "" # enchantment name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWWeaponData
  MWArmorData* = object of MWRecordData
    weight*  : float32
    value*   : uint32
    kind*    : uint32 # type (please refer to `MWWeaponType` enum in -indexes.nim-)
    health*  : uint32
    enchpts* : uint32 # enchantment points
    ar*      : uint32 # armor rating
  MWArmorObj* = object of MWRecordData
    #[ TODO: Is this a struct with `mname/fname`, or are those separate? Ref: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format/CLOT ]#
    biped* : uint8       # biped object (please refer to `MWBipedType` enum in -indexes.nim-)
    mname* : string = "" # male name for cloth (optional)
    fname* : string = "" # female name for cloth (optional, `mname` used if absent)
  MWArmor* = object of MWRecord
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    enchnm*   : string = "" # enchantment name (optional)
    icon*     : string = "" # icon name (optional)
    data*     : MWArmorData
    objs*     : seq[MWArmorObj] # objects (repeatable)
  MWClassData* = object of MWRecordData
    attr*    : array[2, uint32]           # primary attributes
    spec*    : uint32                     # specialisation
    skill*   : array[5, array[2, uint32]] # skills (5 sets of [minor, major])
    flags*   : uint32                     # playability (0 - NPC, 1 - playable)
    flagsac* : uint32                     # auto-calc trade/services flags
  MWClass* = object of MWRecord
    id*    : string      # ID
    name*  : string      # name
    data*  : MWClassData
    descr* : string = "" # description (optional)
  MWRaceData* = object of MWRecordData
    skill*  : array[7, (int32, int32)]   # skill bonuses (ID, bonus) [ID:-1 - empty]
    attr*   : array[8, array[2, uint32]] # attributes (8 IDs of [male, female])
    height* : (float32, float32)         # height (male, female)
    weight* : (float32, float32)         # weight (male, female)
    flags*  : uint32                     # playable/beast
  MWRace* = object of MWRecord
    id*    : string               # ID
    name*  : string = ""          # name (optional)
    power* : seq[array[32, char]] # special power/ability
    descr* : string = ""          # description (optional)
    data*  : MWRaceData
  MWSpellData* = object of MWRecordData
    kind*  : uint32
    cost*  : uint32
    flags* : uint32
  MWSpellEnch* = object of MWRecordData
    effindex* : uint16
    skill*    : int8   # skill affected (-1 if not applicable)
    attr*     : int8   # attribute affected (-1 if not applicable)
    range*    : uint32 # 0 = self, 1 = touch, 2 = target
    area*     : uint32
    duration* : uint32
    mmin*     : uint32 # magnitude min
    mmax*     : uint32 # magnitude max
  MWSpell* = object of MWRecord
    id*   : string           # ID
    name* : string = ""      # name (optional)
    data* : MWSpellData
    ench* : seq[MWSpellEnch]

type
  MWCommonRecord* = MWCloth | MWMisc | MWStatic | MWIngredient  | MWContainer | MWBook       | MWLeveledItem | MWActivator | MWArmor |
                    MWLight | MWDoor | MWPotion | MWLandTexture | MWRegion    | MWRepairTool | MWApparatus   | MWLock      | MWProbe |
                    MWBody  | MWRace | MWClass  | MWWeapon
