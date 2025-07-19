import ../records
import ../common
import ../parse

const field_key = "SKIL"

proc parseSKIL* (fr: var string): MWSkill =
    #[ Parses singel SKIL key of .esm/.esp files and returns it as MWSkill object ]#
    result.header = parseRecordHeader(fr)

    result.index = requiredField[uint32](fr, "INDX", field_key)

    if objectField(fr, "SKDT", result.data):
      result.data = MWSkillData(attr: readUint32(fr),
                                spec: readUint32(fr),
                                usev: (readFloat32(fr),
                                       readFloat32(fr),
                                       readFloat32(fr),
                                       readFloat32(fr)))

    result.descr = optionalField[zstring](fr, "DESC")