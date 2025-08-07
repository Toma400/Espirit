import ../records
import ../common
import ../parse

const field_key = "ENCH"

proc parseENCH* (fr: var string, header: MWRecordHeader): MWEnchantment =
    #[ Parses single ENCH key of .esm/.esp files and returns it as MWEnchantment object ]#
    setRecordData(result, header)

    result.id    = requiredField[zstring](fr, "NAME", field_key)

    if objectField(fr, "ENDT", result.data, result.id):
      result.data = MWEnchantmentData(kind:   readUint32(fr),
                                      cost:   readUint32(fr),
                                      charge: readUint32(fr),
                                      flags:  readUint32(fr))

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