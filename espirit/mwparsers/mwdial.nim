import ../records
import ../common
import ../parse

const field_key  = "DIAL"
const field_keyb = "INFO"

proc parseINFO* (fr: var string, header: MWRecordHeader): MWDialogueTopic =
    #[ Parses single INFO key of .esm/.esp files and returns it as MWDialogueTopic object ]#
    setRecordData(result, header)

    result.id   = requiredField[zstring](fr, "INAM", field_keyb)
    result.prev = requiredField[zstring](fr, "PNAM", field_keyb) # may need to be optional in case first/last entry doesn't have that field
    result.next = requiredField[zstring](fr, "NNAM", field_keyb) # as above

    if optionalObjectField(fr, "DATA", result.data):
      result.data = MWDialogueTopicData(kind: readUint8(fr),
                                        dummy: [readUint8(fr), readUint8(fr), readUint8(fr)],
                                        disp_ji: readUint32(fr),
                                        rank:    readInt8(fr),
                                        gender:  readInt8(fr),
                                        pcrank:  readInt8(fr),
                                        dummy2:  readUint8(fr))

    result.actor  = optionalField[zstring](fr, "ONAM")
    result.race   = optionalField[zstring](fr, "RNAM")
    result.class  = optionalField[zstring](fr, "CNAM")
    result.fact   = optionalField[zstring](fr, "FNAM")
    result.cell   = optionalField[zstring](fr, "ANAM")
    result.pcfact = optionalField[zstring](fr, "DNAM")
    result.sound  = optionalField[zstring](fr, "SNAM")
    result.resp   = optionalField[string](fr, "NAME")
    result.fvstr  = repeatableTriadField[string, uint32, float32](fr, ["SCVR", "INTV", "FLTV"])
    result.rest   = optionalField[string](fr, "BNAM")
    result.qname  = optionalField[uint8](fr, "QSTN")
    result.qfin   = optionalField[uint8](fr, "QSTF")
    result.qres   = optionalField[uint8](fr, "QSTR")

proc parseDIAL* (fr: var string, header: MWRecordHeader, info_seq: var seq[MWDialogueTopic]): MWDialogue =
    #[ Parses single DIAL key of .esm/.esp files and returns it as MWDialogue object ]#
    setRecordData(result, header)

    result.name = requiredField[zstring](fr, "NAME", field_key)
    result.kind = requiredField[uint8](fr, "DATA", field_key)

    while true:
      if len(fr) >= 4:
        if fr[0..3] == "INFO":
          let info_header = parseRecordHeader(fr) # INFO consumed during header parsing
          let info        = parseINFO(fr, info_header)

          result.topics.add(info)
          info_seq.add(info)
        else: break
      else:   break