import ../records
import ../common
import ../parse

# [ helpers to solve seq > array conversion ] #
proc seq65toArray[T] (s: seq[(T, T, T)]): array[65, (T, T, T)] =
  assert s.len >= result.len # in case seq is for some reason smaller than 65
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq65toArray[T] (s: seq[array[65, (T, T, T)]]): array[65, array[65, (T, T, T)]] =
  assert s.len >= result.len # in case seq is for some reason smaller than 65
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq65toArray (s: seq[int8]): array[65, int8] =
  assert s.len >= result.len # in case seq is for some reason smaller than 65
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq65toArray (s: seq[array[65, int8]]): array[65, array[65, int8]] =
  assert s.len >= result.len # in case seq is for some reason smaller than 65
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq9toArray (s: seq[uint8]): array[9, uint8] =
  assert s.len >= result.len # in case seq is for some reason smaller than 9
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq9toArray (s: seq[array[9, uint8]]): array[9, array[9, uint8]] =
  assert s.len >= result.len # in case seq is for some reason smaller than 9
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq16toArray (s: seq[uint16]): array[16, uint16] =
  assert s.len >= result.len # in case seq is for some reason smaller than 16
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc seq16toArray (s: seq[array[16, uint16]]): array[16, array[16, uint16]] =
  assert s.len >= result.len # in case seq is for some reason smaller than 16
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc parseLAND* (fr: var string): MWLand =
  #[ Parses single LAND key of .esm/.esp files and returns it as MWLand object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "INTV":
    raise newException(ParseError, "No INTV field found for LAND entry.")
  discard readStr(fr, 4) # loose bytes
  result.coord = (readInt32(fr), readInt32(fr))

  if readStr(fr, 4) != "DATA":
    raise newException(ParseError, "No DATA field found for LAND entry.")
  discard readStr(fr, 4) # loose bytes
  result.data = readUint32(fr)

  if len(fr) >= 4:
    if fr[0..3] == "VNML":
      discard readStr(fr, 4) # VNML
      discard readStr(fr, 4) # loose bytes

      var int_arr = newSeqOfCap[(int8, int8, int8)](65)
      var ext_arr = newSeqOfCap[array[65, (int8, int8, int8)]](65)

      while true:
        if ext_arr.len == 65:
          result.vnormals = seq65toArray(ext_arr)
          break # [65][65] array is finished

        if int_arr.len < 65:
          int_arr.add((readInt8(fr), readInt8(fr), readInt8(fr)))
        else:
          if ext_arr.len < 65:
            ext_arr.add(seq65toArray(int_arr))

  if len(fr) >= 4:
    if fr[0..3] == "VHGT":
      discard readStr(fr, 4) # VHGT
      discard readStr(fr, 4) # loose bytes

      let offset  = readFloat32(fr)
      var int_arr = newSeqOfCap[int8](65)
      var ext_arr = newSeqOfCap[array[65, int8]](65)

      proc processJunk (frr: var string): array[3, uint8] =
        result = [readUint8(frr), readUint8(frr), readUint8(frr)]

      while true:
        if ext_arr.len == 65:
          result.hgdata = MWLandHeightData(hoffset: offset,
                                           hdata:   seq65toArray(ext_arr),
                                           junk:    processJunk(fr))
          break # [65][65] array is finished

        if int_arr.len < 65:
          int_arr.add(readInt8(fr))
        else:
          if ext_arr.len < 65:
            ext_arr.add(seq65toArray(int_arr))

  if len(fr) >= 4:
    if fr[0..3] == "WNAM":
      discard readStr(fr, 4) # WNAM
      discard readStr(fr, 4) # loose bytes

      var int_arr = newSeqOfCap[uint8](9)
      var ext_arr = newSeqOfCap[array[9, uint8]](9)

      while true:
        if ext_arr.len == 9:
          result.hgmap = seq9toArray(ext_arr)
          break # [9][9] array is finished

        if int_arr.len < 9:
          int_arr.add((readUint8(fr)))
        else:
          if ext_arr.len < 9:
            ext_arr.add(seq9toArray(int_arr))

  if len(fr) >= 4:
    if fr[0..3] == "VLCR":
      discard readStr(fr, 4) # VLCR
      discard readStr(fr, 4) # loose bytes

      var int_arr = newSeqOfCap[(uint8, uint8, uint8)](65)
      var ext_arr = newSeqOfCap[array[65, (uint8, uint8, uint8)]](65)

      while true:
        if ext_arr.len == 65:
          result.vcolors = seq65toArray(ext_arr)
          break # [65][65] array is finished

        if int_arr.len < 65:
          int_arr.add((readUint8(fr), readUint8(fr), readUint8(fr)))
        else:
          if ext_arr.len < 65:
            ext_arr.add(seq65toArray(int_arr))

  if len(fr) >= 4:
    if fr[0..3] == "VTEX":
      discard readStr(fr, 4) # VTEX
      discard readStr(fr, 4) # loose bytes

      var int_arr = newSeqOfCap[uint16](16)
      var ext_arr = newSeqOfCap[array[16, uint16]](16)

      while true:
        if ext_arr.len == 16:
          result.vtex = seq16toArray(ext_arr)
          break # [16][16] array is finished

        if int_arr.len < 16:
          int_arr.add((readUint16(fr)))
        else:
          if ext_arr.len < 16:
            ext_arr.add(seq16toArray(int_arr))