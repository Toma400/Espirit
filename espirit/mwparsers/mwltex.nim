import ../records
import ../common

const field_key = "LTEX"

proc parseLTEX* (fr: var string): MWLandTexture =
    #[ Parses single LTEX key of .esm/.esp files and returns it as MWLandTexture object ]#
    result.header = parseRecordHeader(fr, result)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.index = requiredField[uint32](fr,  "INTV", field_key)
    result.tex   = requiredField[zstring](fr, "DATA", field_key)