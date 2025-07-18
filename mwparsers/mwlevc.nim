import ../records
import ../common

const field_key = "LEVC"

proc parseLEVC* (fr: var string): MWLeveledCreature =
  #[ Parses single LEVC key of .esm/.esp files and returns it as MWLeveledCreature object ]#
  result.header = parseRecordHeader(fr)

  result.id      = requiredField[zstring](fr, "NAME", field_key)
  result.flags   = requiredField[uint32](fr, "DATA", field_key)
  result.nchance = requiredField[uint8](fr, "NNAM", field_key)
  result.count   = optionalField[uint32](fr, "INDX")
  result.crea    = repeatablePairField[zstring, uint16](fr, ["CNAM", "INTV"])