import ../records
import ../common
import ../parse

const field_key = "CONT"

proc parseCONT* (fr: var string): MWContainer =
    #[ Parses single CONT key of .esm/.esp files and returns it as MWContainer object ]#
    result.header = parseRecordHeader(fr, result)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = requiredField[zstring](fr, "MODL", field_key)
    result.name   = optionalField[zstring](fr, "FNAM")
    result.weight = requiredField[float32](fr, "CNDT", field_key)
    result.flags  = requiredField[uint32](fr, "FLAG", field_key)

    var npco: int
    while repeatableObjectField(fr, "NPCO", npco):
      result.contents.add(MWContainerObject(count: readInt32(fr),
                                            name:  read32Chars(fr),
                                            size:  npco))

    result.script = optionalField[zstring](fr, "SCRI")