import ../records
import ../common

const field_key = "STAT"

proc parseSTAT* (fr: var string, header: MWRecordHeader): MWStatic =
    #[ Parses single STAT key of .esm/.esp files and returns it as MWStatic object ]#
    setRecordData(result, header)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.model = requiredField[zstring](fr, "MODL", field_key)