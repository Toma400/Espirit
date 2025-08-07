import ../records
import ../common
import ../parse

const field_key = "LOCK"

proc parseLOCK* (fr: var string, header: MWRecordHeader): MWLock =
    #[ Parses single LOCK key of .esm/.esp files and returns it as MWLock object ]#
    setRecordData(result, header)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.model = requiredField[zstring](fr, "MODL", field_key)
    result.name  = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "LKDT", result.data, result.id):
      result.data = MWLockData(weight:  readFloat32(fr),
                               value:   readUint32(fr),
                               quality: readFloat32(fr),
                               uses:    readUint32(fr))

    result.script = optionalField[zstring](fr, "SCRI")
    result.icon   = optionalField[zstring](fr, "ITEX")