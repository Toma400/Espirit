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
    kind*   : uint32  # type (please refer to `MWClothType` enum in type section below)
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

type
  MWRecord* = MWCloth | MWMisc | MWStatic | MWIngredient | MWContainer | MWBook | MWLeveledItem | MWActivator | MWLight | MWDoor | MWPotion | MWLandTexture | MWRegion

type
  ParseError* = object of Exception

proc `$`* (record: MWRecord): string =
    result = record.id

proc `$`* (clobj: MWClothObj): string =
    result = fmt"{clobj.biped}: {MWClothBipedType(clobj.biped)} | {clobj.mname}, {clobj.fname}"

proc `$`* (land: MWLand): string =
    result = fmt"X: {land.coord[0]}, Y: {land.coord[1]}"

proc info* (record: MWCloth): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    if record.objs.len > 0:
      options.add("\n    Objects:")
      for obj in record.objs:
        options.add("\n    - " & $obj)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Kind:   {record.data.kind} [{MWClothType(record.data.kind)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """

proc info* (record: MWMisc): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """

proc info* (record: MWIngredient): string =
    var options = ""
    var effects = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    for c, ef in record.data.effindex:
      if ef != -1:
        var sk = ""
        var at = ""
        if record.data.skill[c] > 0: sk = fmt"[SkillIndex:     {record.data.skill[c]}]"
        if record.data.attr[c]  > 0: at = fmt"[AttributeIndex: {record.data.attr[c]}]"
        effects.add("\n      - " & fmt"{ef} [{MWEffectType(ef)}] {sk}{at}")
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
      Effects:    {effects}
    ====={options}
    """

proc info* (record: MWContainer): string =
    proc getID(a: array[32, char]): string =
      for i in a:
        if i != '\0': result.add(i)

    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.contents.len > 0:
      options.add("\n    Contents:")
      for it in record.contents:
        options.add("\n" & fmt"    - {it[1].getID} [{it[0]}]")
    # TODO: lacks some flags info
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    =====
      Weight: {record.weight}
    ====={options}
    """

proc info* (record: MWActivator | MWDoor): string =
    var script = "[None]"
    if record.script != "":
      script = record.script
    result = fmt"""
    ID:     {record.id}
    Name:   {record.name}
    Model:  {record.model}
    Script: {script}
    """

proc info* (record: MWLight): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.sound != "":
      options.add("\n    Sound:   " & record.sound)
    result = fmt"""
    ID:     {record.id}
    Name:   {record.name}
    Model:  {record.model}
    Icon:   {record.icon}
    =====
      Type:   {record.data.flags} [{MWLightType(record.data.flags)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
      Time:   {record.data.time}
      Radius: {record.data.radius}
      Color:  {record.data.color}
    ====={options}
    """

proc info* (record: MWBook): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """
    # TODO: Not all values added

proc read* (record: MWBook): string =
    proc mwFormat(r: string): string =
      let rep = {"<br>": "\n",
                 "<BR>": "\n"}
      result = r
      for k, v in rep.items:
        result = result.replace(k, v)

    return mwFormat(record.text)

proc info* (record: MWLeveledItem): string =
    var items = ""
    if record.count > 0:
      items.add("\n    Count: " & $record.count)
    if record.items.len > 0:
      items.add("\n    Items:")
    for i in record.items:
      items.add("\n    - " & fmt"{i[0]}: {i[1]}")
    result = fmt"""
    ID:    {record.id}
    ====={items}
    =====
    """

proc info* (record: MWPotion): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """
    # TODO: Not all values added # EFFECTS!!!

proc info* (record: MWLandTexture): string =
    result = fmt"""
    ID:      {record.id}
    Index:   {record.index}
    Texture: {record.tex}
    """

proc info* (record: MWLand): string =
    result = fmt"""
    Coords: X: {record.coord[0]}
            Y: {record.coord[1]}
    Offset: {record.hgdata.hoffset}
    """

proc info* (record: MWRegion): string =
    result = fmt"""
    ID:      {record.id}
    Name:    {record.name}
    Weather:
      - Clear    [{record.weather[0]}]
      - Cloudy   [{record.weather[1]}]
      - Foggy    [{record.weather[2]}]
      - Overcast [{record.weather[3]}]
      - Rain     [{record.weather[4]}]
      - Thunder  [{record.weather[5]}]
      - Ash      [{record.weather[6]}]
      - Blight   [{record.weather[7]}]
      - Snow     [{record.weather[8]}]
      - Blizzard [{record.weather[9]}]
    Map: (R: {record.map_col[0]}, G: {record.map_col[1]}, B: {record.map_col[2]}, A: {record.map_col[3]})
    """
    # TODO: Not all values added # SOUND CHANCES / SLEEP CREATURE? !!!