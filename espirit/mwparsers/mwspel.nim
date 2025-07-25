import ../records
import ../common
import ../parse

const field_key = "SPEL"

proc parseSPEL* (fr: var string): MWSpell =
    #[ Parses single SPEL key of .esm/.esp files and returns it as MWSpell object ]#
    result.header = parseRecordHeader(fr, result)

    result.id   = requiredField[zstring](fr, "NAME", field_key)
    result.name = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "SPDT", result.data, result.id):
      result.data = MWSpellData(kind:  readUint32(fr),
                                cost:  readUint32(fr),
                                flags: readUint32(fr))

    var enam: int # length of each ENAM record
    while repeatableObjectField(fr, "ENAM", enam):
      result.ench.add(MWSpellEnch(effindex: readUint16(fr),
                                  skill:    readInt8(fr),
                                  attr:     readInt8(fr),
                                  range:    readUint32(fr),
                                  area:     readUint32(fr),
                                  duration: readUint32(fr),
                                  mmin:     readUint32(fr),
                                  mmax:     readUint32(fr),
                                  size:     enam))