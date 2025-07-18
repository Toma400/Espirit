import ../records
import ../common
import ../parse

const field_key = "SNDG"

proc parseSNDG* (fr: var string): MWSoundGenerator =
  #[ Parses single SNDG key of .esm/.esp files and returns it as MWSoundGenerator object ]#
  result.header = parseRecordHeader(fr)

  result.id     = requiredField[zstring](fr, "NAME", field_key)
  result.kind   = requiredField[uint32](fr, "DATA", field_key)
  result.crea   = optionalField[zstring](fr, "CNAM")
  result.snd_id = optionalField[zstring](fr, "SNAM")