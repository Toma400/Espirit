import ../records
import ../common
import ../parse

const field_key = "CELL"

proc parseFormReference(fr: var string): MWFormReference =
    result.ref_id  = readUint32(fr) # FRMR should be consumed before calling (in `if optionalObjectField` condition)
    result.obj_id  = requiredField[zstring](fr, "NAME", "FRMR")
    result.blocked = optionalField[uint8](fr, "UNAM")
    result.scale   = optionalField[float32](fr, "XSCL")
    result.npc     = optionalPairField[zstring, zstring](fr, ["ANAM", "BNAM"])
    result.faction = optionalPairField[zstring, uint32](fr, ["CNAM", "INDX"])
    result.soul    = optionalField[zstring](fr, "XSOL")
    result.charge  = optionalField[float32](fr, "XCHG")
    if fr[0..3] == "INTV":   # optional
      discard readStr(fr, 4) # consumes INTV
      discard readStr(fr, 4) # consumes length ('loose bytes')
      result.rem = readStr(fr, 4)
    result.value   = optionalField[uint32](fr, "NAM9")

    # using below to struct-ify a pair of struct and zstring (hence getting field name on zstring)
    var dodt: int
    while repeatableObjectField(fr, "DODT", dodt):
      result.dest.add(MWCellTravelDestination(pos_x:    readFloat32(fr),
                                              pos_y:    readFloat32(fr),
                                              pos_z:    readFloat32(fr),
                                              rot_x:    readFloat32(fr),
                                              rot_y:    readFloat32(fr),
                                              rot_z:    readFloat32(fr),
                                              prv_dest: optionalField[zstring](fr, "DNAM")))

    result.lockdif  = optionalField[uint32](fr, "FLTV")
    result.keyname  = optionalField[zstring](fr, "KNAM")
    result.trpname  = optionalField[zstring](fr, "TNAM")
    result.disabled = optionalField[uint8](fr, "ZNAM")

    if optionalObjectField(fr, "DATA", result.pos):
      result.pos = MWReferencePosition(pos_x: readFloat32(fr),
                                       pos_y: readFloat32(fr),
                                       pos_z: readFloat32(fr),
                                       rot_x: readFloat32(fr),
                                       rot_y: readFloat32(fr),
                                       rot_z: readFloat32(fr))

proc parseCELL* (fr: var string): MWCell =
    #[ Parses single CELL key of .esm/.esp files and returns it as MWCell object ]#
    result.header = parseRecordHeader(fr, result)

    result.name  = requiredField[zstring](fr, "NAME", field_key)

    if objectField(fr, "DATA", result.data, result.name):
      result.data = MWCellData(flags:  readUint32(fr),
                               grid_x: readInt32(fr),
                               grid_y: readInt32(fr))

    result.region = optionalField[zstring](fr, "RGNN")
    result.mapcol = optionalField[rgb](fr, "NAM5")
    result.waterh = optionalField[float32](fr, "WHGT")

    if optionalObjectField(fr, "AMBI", result.light):
      result.light = MWAmbientLight(ambcol: readRGB(fr),
                                    suncol: readRGB(fr),
                                    fogcol: readRGB(fr),
                                    fogden: readFloat32(fr))

    var mvrf: int
    while repeatableObjectField(fr, "MVRF", mvrf):
      var obj: MWMovedReference
      obj.ref_id = readUint32(fr)
      obj.cell   = optionalField[string](fr, "CNAM")
      obj.coords = optionalField[(int32, int32)](fr, "CNDT")
      if optionalObjectField(fr, "FRMR", obj.ref_obj):
        obj.ref_obj = parseFormReference(fr)

      result.ref_mv.add(obj)

    var frmr: int
    while repeatableObjectField(fr, "FRMR", frmr):
      result.ch_pers.add(parseFormReference(fr))

    result.ch_tcnt = optionalField[uint32](fr, "NAM0")

    while repeatableObjectField(fr, "FRMR", frmr):
      result.ch_temp.add(parseFormReference(fr))

    if result.ch_tcnt != 0:
      if len(result.ch_temp) != result.ch_tcnt.int:
        #raise newException(ParseError, "Different count of temporary children for record: " & result.name & " | Real count: " & $len(result.ch_temp) & " | Expected count: " & $result.ch_tcnt)
        echo("Different count of temporary children for record: " & result.name & " | Real count: " & $len(result.ch_temp) & " | Expected count: " & $result.ch_tcnt)