import ../records
import ../common
import ../parse

const field_key = "WEAP"

proc parseWEAP* (fr: var string, header: MWRecordHeader): MWWeapon =
    #[ Parses single WEAP key of .esm/.esp files and returns it as MWWeapon object ]#
    setRecordData(result, header)

    result.id    = requiredField[string](fr, "NAME", field_key)
    result.model = requiredField[string](fr, "MODL", field_key)
    result.name  = optionalField[string](fr, "FNAM")

    if objectField(fr, "WPDT", result.data, result.id):
      result.data = MWWeaponData(weight:  readFloat32(fr),
                                 value:   readUint32(fr),
                                 kind:    readUint16(fr),
                                 health:  readUint16(fr),
                                 speed:   readFloat32(fr),
                                 reach:   readFloat32(fr),
                                 enchpts: readUint16(fr),
                                 chopmin: readUint8(fr),
                                 chopmax: readUint8(fr),
                                 slshmin: readUint8(fr),
                                 slshmax: readUint8(fr),
                                 thrsmin: readUint8(fr),
                                 thrsmax: readUint8(fr),
                                 flags:   readUint32(fr))

    result.icon   = optionalField[string](fr, "ITEX")
    result.enchnm = optionalField[string](fr, "ENAM")
    result.script = optionalField[string](fr, "SCRI")