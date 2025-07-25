import ../records
import ../common
import ../parse

const field_key = "MGEF"

proc parseMGEF* (fr: var string): MWMagicEffect =
    #[ Parses single MGEF key of .esm/.esp files and returns it as MWMagicEffect object ]#
    result.header = parseRecordHeader(fr, result)

    result.index = requiredField[uint32](fr, "INDX", field_key)

    if objectField(fr, "MEDT", result.data):
      result.data = MWMagicEffectData(school:  readUint32(fr),
                                      bcost:   readFloat32(fr),
                                      flags:   readUint32(fr),
                                      red:     readUint32(fr),
                                      green:   readUint32(fr),
                                      blue:    readUint32(fr),
                                      speedx:  readFloat32(fr),
                                      sizex:   readFloat32(fr),
                                      sizecap: readFloat32(fr))

    result.icon  = optionalField[zstring](fr, "ITEX")
    result.partc = optionalField[zstring](fr, "PTEX")
    result.sndb  = optionalField[zstring](fr, "BSND")
    result.sndc  = optionalField[zstring](fr, "CSND")
    result.sndh  = optionalField[zstring](fr, "HSND")
    result.snda  = optionalField[zstring](fr, "ASND")
    result.visc  = optionalField[zstring](fr, "CVFX")
    result.visb  = optionalField[zstring](fr, "BVFX")
    result.vish  = optionalField[zstring](fr, "HVFX")
    result.visa  = optionalField[zstring](fr, "AVFX")
    result.descr = optionalField[string](fr, "DESC")