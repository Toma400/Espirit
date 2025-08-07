import ../records
import ../common
import ../parse

const field_key = "ARMO"

proc parseARMO* (fr: var string, header: MWRecordHeader): MWArmor =
    #[ Parses single ARMO key of .esm/.esp files and returns it as MWArmor object ]#
    setRecordData(result, header)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = requiredField[zstring](fr, "MODL", field_key)
    result.name   = requiredField[zstring](fr, "FNAM", field_key)
    result.script = optionalField[zstring](fr, "SCRI")

    if objectField(fr, "AODT", result.data, result.id):
      result.data = MWArmorData(kind:    readUint32(fr),
                                weight:  readFloat32(fr),
                                value:   readUint32(fr),
                                health:  readUint32(fr),
                                enchpts: readUint32(fr),
                                ar:      readUint32(fr))

    result.icon = optionalField[zstring](fr, "ITEX")

    var indx: int
    while repeatableObjectField(fr, "INDX", indx):
      result.objs.add(MWArmorObj(biped: readUint8(fr), # INDX is consumed during loop
                                 mname: optionalField[string](fr, "BNAM"),
                                 fname: optionalField[string](fr, "CNAM"),
                                 size:  indx))

    result.enchnm = optionalField[zstring](fr, "ENAM")