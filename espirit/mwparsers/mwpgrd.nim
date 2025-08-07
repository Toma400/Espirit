import ../records
import ../common
import ../parse

const field_key = "PGRD"

proc parsePGRD* (fr: var string, header: MWRecordHeader): MWPathgrid =
    #[ Parses single PGRD key of .esm/.esp files and returns it as MWPathgrid object ]#
    setRecordData(result, header)

    var frr = readStr(fr, int(result.header.size))

    if objectField(frr, "DATA", result.data):
      result.data = MWPathgridData(grid_x:       readInt32(frr),
                                   grid_y:       readInt32(frr),
                                   flags:        readUint16(frr),
                                   ppoint_count: readUint16(frr))

    result.cell = requiredField[zstring](frr, "NAME", field_key)

    var pgrc_length = 0
    if len(frr) >= 4:
      if frr[0..3] == "PGRP":
        discard readStr(frr, 4) # PGRP
        discard getLength(frr)

        for _ in 1..int(result.data.ppoint_count):
          let pp = MWPathPoint(x:         readInt32(frr),
                               y:         readInt32(frr),
                               z:         readInt32(frr),
                               flags:     readUint8(frr),
                               con_count: readUint8(frr),
                               unknown:   readUint16(frr))
          pgrc_length += int(pp.con_count)
          result.ppoint.add(pp)

    if len(frr) >= 4:
      if frr[0..3] == "PGRC":
        for _ in 1..pgrc_length:
          result.clist.add(readUint32(frr))