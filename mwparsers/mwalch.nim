import ../records
import ../common
import ../parse

const field_key = "ALCH"

proc parseALCH* (fr: var string): MWPotion =
    #[ Parses single ALCH key of .esm/.esp files and returns it as MWPotion object ]#
    result.header = parseRecordHeader(fr, result)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = optionalField[zstring](fr, "MODL")
    result.icon   = optionalField[zstring](fr, "TEXT")
    result.script = optionalField[zstring](fr, "SCRI")
    result.name   = optionalField[zstring](fr, "FNAM")

    if optionalObjectField(fr, "ALDT", result.data):
      result.data = MWPotionData(weight: readFloat32(fr),
                                 value:  readUint32(fr),
                                 flags:  readUint32(fr))

    var enam: int # length of each ENAM record
    while repeatableObjectField(fr, "ENAM", enam):
      result.ench.add(MWPotionEnch(effindex: readUint16(fr),
                                   skill:    readInt8(fr),
                                   attr:     readInt8(fr),
                                   range:    readUint32(fr),
                                   area:     readUint32(fr),
                                   duration: readUint32(fr),
                                   mmin:     readUint32(fr),
                                   mmax:     readUint32(fr),
                                   size:     enam))
