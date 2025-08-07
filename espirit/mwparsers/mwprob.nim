import ../records
import ../common
import ../parse

const field_key = "PROB"

proc parsePROB* (fr: var string, header: MWRecordHeader): MWProbe =
    #[ Parses single PROB key of .esm/.esp files and returns it as MWProbe object ]#
    setRecordData(result, header)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.model = requiredField[zstring](fr, "MODL", field_key)
    result.name  = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "PBDT", result.data, result.id):
      result.data = MWProbeData(weight:  readFloat32(fr),
                                value:   readUint32(fr),
                                quality: readFloat32(fr),
                                uses:    readUint32(fr))

    result.icon   = optionalField[zstring](fr, "ITEX")
    result.script = optionalField[zstring](fr, "SCRI")