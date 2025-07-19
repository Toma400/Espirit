import ../records
import ../common
import ../parse

const field_key = "BOOK"

proc parseBOOK* (fr: var string): MWBook =
    #[ Parses single BOOK key of .esm/.esp files and returns it as MWBook object ]#
    result.header = parseRecordHeader(fr)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.model = requiredField[zstring](fr, "MODL", field_key)
    result.name  = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "BKDT", result.data, result.id):
      result.data = MWBookData(weight:   readFloat32(fr, 4),
                               value:    readUint32(fr, 4),
                               flags:    readUint32(fr, 4),
                               skill:    readInt32(fr, 4),
                               ench:     readUint32(fr, 4))

    result.script = optionalField[zstring](fr, "SCRI")
    result.icon   = optionalField[zstring](fr, "ITEX")
    result.text   = optionalField[string](fr,  "TEXT")
    result.enchnm = optionalField[zstring](fr, "ENAM")