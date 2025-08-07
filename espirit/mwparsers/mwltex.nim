import ../records
import ../common

const field_key = "LTEX"

proc parseLTEX* (fr: var string, header: MWRecordHeader): MWLandTexture =
    #[ Parses single LTEX key of .esm/.esp files and returns it as MWLandTexture object ]#
    setRecordData(result, header)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.index = requiredField[uint32](fr,  "INTV", field_key)
    result.tex   = requiredField[zstring](fr, "DATA", field_key)