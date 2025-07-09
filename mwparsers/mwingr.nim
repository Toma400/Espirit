import ../records
import ../common
import ../parse

const field_key = "INGR"

proc parseINGR* (fr: var string): MWIngredient =
  #[ Parses single INGR key of .esm/.esp files and returns it as MWIngredient object ]#
  result.header = parseRecordHeader(fr)

  result.id    = requiredField[zstring](fr, "NAME", field_key)
  result.model = requiredField[zstring](fr, "MODL", field_key)
  result.name  = optionalField[zstring](fr, "FNAM")

  if objectField(fr, "IRDT", result.data, result.id):
    result.data = MWIngredientData(weight:   readFloat32(fr, 4),
                                   value:    readUint32(fr, 4),
                                   effindex: [readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4)],
                                   skill:    [readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4)],
                                   attr:     [readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4)])

  result.script = optionalField[zstring](fr, "SCRI")
  result.icon   = optionalField[zstring](fr, "ITEX")