import ../records
import ../common
import ../parse

const field_key = "BODY"

proc parseBODY* (fr: var string): MWBody =
  #[ Parses single BODY key of .esm/.esp files and returns it as MWBody object ]#
  result.header = parseRecordHeader(fr)

  result.id    = requiredField[zstring](fr, "NAME", field_key)
  result.model = requiredField[zstring](fr, "MODL", field_key)
  result.name  = requiredField[zstring](fr, "FNAM", field_key)

  if objectField(fr, "BYDT", result.data, result.id):
    result.data = MWBodyData(part:    readUint8(fr),
                             vampire: readUint8(fr),
                             flags:   readUint8(fr),
                             pkind:   readUint8(fr))