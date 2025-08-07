import ../records
import ../common

const field_key = "SSCR"

proc parseSSCR* (fr: var string, header: MWRecordHeader): MWStartScript =
    #[ Parses single SSCR key of .esm/.esp files and returns it as MWStartScript object ]#
    setRecordData(result, header)

    result.data = requiredField[string](fr, "DATA", field_key)
    result.name = requiredField[string](fr, "NAME", field_key)