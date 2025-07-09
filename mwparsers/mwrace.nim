import ../records
import ../common
import ../parse

const field_key = "RACE"

proc parseRACE* (fr: var string): MWRace =
  #[ Parses single STAT key of .esm/.esp files and returns it as MWStatic object ]#
  result.header = parseRecordHeader(fr)

  result.id   = requiredField[zstring](fr, "NAME", field_key)
  result.name = optionalField[zstring](fr, "FNAM")

  if objectField(fr, "RADT", result.data, result.id):
    discard

  result.power = repeatableField[char32](fr, "NPCS")
  result.descr = optionalField[string](fr, "DESC")
