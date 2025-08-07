import ../records
import ../common
import ../parse

const field_key = "LIGH"

proc parseLIGH* (fr: var string, header: MWRecordHeader): MWLight =
    #[ Parses singel LIGH key of .esm/.esp files and returns it as MWLight object ]#
    setRecordData(result, header)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = requiredField[zstring](fr, "MODL", field_key)
    result.name   = optionalField[zstring](fr, "FNAM")
    result.icon   = optionalField[zstring](fr, "ITEX")

    if objectField(fr, "LHDT", result.data, result.id):
      result.data = MWLightData(weight: readFloat32(fr, 4),
                                value:  readUint32(fr, 4),
                                time:   readInt32(fr, 4),
                                radius: readUint32(fr, 4),
                                color:  readRGB(fr),
                                flags:  readUint32(fr, 4))

    result.sound  = optionalField[zstring](fr, "SNAM")
    result.script = optionalField[zstring](fr, "SCRI")