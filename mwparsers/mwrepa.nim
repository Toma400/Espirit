import ../records
import ../common
import ../parse

const field_key = "REPA"

proc parseREPA* (fr: var string): MWRepairTool =
    #[ Parses single REPA key of .esm/.esp files and returns it as MWRepairTool object ]#
    result.header = parseRecordHeader(fr, result)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = requiredField[zstring](fr, "MODL", field_key)
    result.name   = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "RIDT", result.data, result.id):
      result.data = MWRepairToolData(weight:  readFloat32(fr),
                                     value:   readUint32(fr),
                                     uses:    readUint32(fr),
                                     quality: readFloat32(fr))

    result.icon   = optionalField[zstring](fr, "ITEX")
    result.script = optionalField[zstring](fr, "SCRI")