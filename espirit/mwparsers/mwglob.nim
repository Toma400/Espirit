import ../records
import ../common

const field_key = "GLOB"

proc parseGLOB* (fr: var string): MWGlobal =
    #[ Parses single GLOB key of .esm/.esp files and returns it as MWGlobal object ]#
    result.header = parseRecordHeader(fr, result)

    result.name  = requiredField[zstring](fr, "NAME", field_key)
    result.ftype = requiredField[char](fr,    "FNAM", field_key)
    result.value = requiredField[float32](fr, "FLTV", field_key)