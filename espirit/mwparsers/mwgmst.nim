import ../records
import ../common

const field_key = "GMST"

proc parseGMST* (fr: var string, header: MWRecordHeader): MWGameSetting =
    #[ Parses single GMST key of .esm/.esp files and returns it as MWGameSetting object ]#
    setRecordData(result, header)

    result.name = requiredField[string](fr, "NAME", field_key)
    result.kind = result.name[0]

    result.valfl = optionalField[float32](fr, "FLTV")
    result.vali  = optionalField[int32](fr,   "INTV")
    result.vals  = optionalField[string](fr,  "STRV")