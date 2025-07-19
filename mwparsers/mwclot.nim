import ../records
import ../common
import ../parse

const field_key = "CLOT"

proc parseCLOT* (fr: var string): MWCloth =
    #[ Parses singel CLOT key of .esm/.esp files and returns it as MWCloth object ]#
    result.header = parseRecordHeader(fr)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.model = requiredField[zstring](fr, "MODL", field_key)
    result.name  = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "CTDT", result.data, result.id):
      result.data = MWClothData(kind:   readUint32(fr, 4),
                                weight: readFloat32(fr, 4),
                                value:  readUint16(fr, 2),
                                ench:   readUint16(fr, 2))

    result.script = optionalField[zstring](fr, "SCRI")
    result.icon   = optionalField[zstring](fr, "ITEX")

    var indx: int
    while repeatableObjectField(fr, "INDX", indx):
      result.objs.add(MWArmorObj(biped: readUint8(fr), # INDX is consumed during loop
                                 mname: optionalField[string](fr, "BNAM"),
                                 fname: optionalField[string](fr, "CNAM"),
                                 size:  indx))

    result.enchnm = optionalField[zstring](fr, "ENAM")