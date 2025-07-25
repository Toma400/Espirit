import std/strutils
import ../records
import ../common
import ../parse
import tables

const field_key = "REGN"

proc parseREGN* (fr: var string, deps: OrderedTable[string, uint64]): MWRegion =
    #[ Parses single REGN key of .esm/.esp files and returns it as MWRegion object ]#
    result.header = parseRecordHeader(fr, result)

    var exp = (t: false, b: false) # checks if expansion is used
    for f, _ in deps:
      let  ff = toLowerAscii(f)
      if   ff == "tribunal.esm":  exp[0] = true
      elif ff == "bloodmoon.esm": exp[1] = true

    result.id   = requiredField[zstring](fr, "NAME", field_key)
    result.name = requiredField[zstring](fr, "FNAM", field_key)

    if objectField(fr, "WEAT", result.weather, result.id):
      if exp[0] or exp[1]:
        result.weather = (readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr))
      else:
        result.weather = (readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr),
                          readUint8(fr), readUint8(fr),
                          0,             0)

    result.sleep_cr = optionalField[zstring](fr, "BNAM")
    result.map_col  = requiredField[rgb](fr, "CNAM", field_key)

    var snam: int
    while repeatableObjectField(fr, "SNAM", snam):
      result.sound_ch.add(MWRegionSoundChances(name:   read32Chars(fr),
                                               chance: readUint8(fr)))