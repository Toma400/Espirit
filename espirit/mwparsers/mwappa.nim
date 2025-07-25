import ../records
import ../common
import ../parse

const field_key = "APPA"

proc parseAPPA* (fr: var string): MWApparatus =
    #[ Parses single APPA key of .esm/.esp files and returns it as MWApparatus object ]#
    result.header = parseRecordHeader(fr, result)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = optionalField[zstring](fr, "MODL")
    result.name   = optionalField[zstring](fr, "FNAM")
    result.script = optionalField[zstring](fr, "SCRI")

    if objectField(fr, "AADT", result.data, result.id):
      result.data = MWApparatusData(kind:    readUint32(fr),
                                    quality: readFloat32(fr),
                                    weight:  readFloat32(fr),
                                    value:   readUint32(fr))

    result.icon = optionalField[zstring](fr, "ITEX")