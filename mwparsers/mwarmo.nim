import ../records
import ../common
import ../parse

const field_key = "ARMO"

proc parseARMO* (fr: var string): MWArmor =
  #[ Parses single ARMO key of .esm/.esp files and returns it as MWArmor object ]#
  result.header = parseRecordHeader(fr)

  result.id     = requiredField[zstring](fr, "NAME", field_key)
  result.model  = requiredField[zstring](fr, "MODL", field_key)
  result.name   = requiredField[zstring](fr, "FNAM", field_key)
  result.script = optionalField[zstring](fr, "SCRI")

  if objectField(fr, "AODT", result.data):
    result.data = MWArmorData(kind:    readUint32(fr),
                              weight:  readFloat32(fr),
                              value:   readUint32(fr),
                              health:  readUint32(fr),
                              enchpts: readUint32(fr),
                              ar:      readUint32(fr))

  result.icon = optionalField[zstring](fr, "ITEX")

  # while repeatableObjectField(fr, "INDX", result.objs):
  #   let biped_type = readUint8(fr); readStr(fr, 3) # 'biped' apparently allows for uint32, but only uses first byte in practice
  #   result.objs.add(MWArmorObj(biped: biped_type, mname: readStr()), fname: )

  while true:
    if len(fr) >= 4:
      if fr[0..3] == "INDX":
        discard readStr(fr, 4) # INDX
        discard readStr(fr, 4) # loose bytes
        var biped = MWArmorObj(biped: readUint8(fr, 1))
        if len(fr) >= 4: # sometimes INDX is empty, this let us not try to parse new record thinking it's part of INDX
          if not (fr[0..3] in reserved_records): # <---/
            if len(fr) >= 4: # redundant, but repeats rule visually
              if fr[0..3] == "BNAM":
                discard readStr(fr, 4) # BNAM
                let length = readUint8(fr, 1).int # length of string
                discard readStr(fr, 3) # loose bytes
                biped.mname = readStr(fr, length)
            if len(fr) >= 4:
              if fr[0..3] == "CNAM":
                discard readStr(fr, 4) # CNAM
                let length = readUint8(fr, 1).int # length of string
                discard readStr(fr, 3) # loose bytes
                biped.fname = readStr(fr, length)

        result.objs.add(biped)

    if len(fr) >= 4:
      if fr[0..3] == "INDX":
        continue
    break # if nothing, ENAM or new record is found

  result.enchnm = optionalField[zstring](fr, "ENAM")