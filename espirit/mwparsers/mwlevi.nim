import ../records
import ../common

const field_key = "LEVI"

proc parseLEVI* (fr: var string): MWLeveledItem =
    #[ Parses single LEVI key of .esm/.esp files and returns it as MWLeveledItem object ]#
    result.header = parseRecordHeader(fr, result)

    result.id      = requiredField[zstring](fr, "NAME", field_key)
    result.flags   = requiredField[uint32](fr, "DATA", field_key)
    result.nchance = requiredField[uint8](fr, "NNAM", field_key)
    result.count   = optionalField[uint32](fr, "INDX")
    result.items   = repeatablePairField[zstring, uint16](fr, ["INAM", "INTV"])