import std/strutils
import ../records
import ../parse
import tables

# [ helpers to solve seq > array conversion ] #
proc seq32toArray[char] (s: seq[char]): array[32, char] =
  assert s.len >= result.len # in case seq is for some reason smaller than 32
  for ix in 0..result.len - 1:
      result[ix] = s[ix]

proc parseREGN* (fr: var string, deps: OrderedTable[string, uint64]): MWRegion =
  #[ Parses single REGN key of .esm/.esp files and returns it as MWRegion object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  var exp = (t: false, b: false) # checks if expansion is used
  for f, _ in deps:
    let  ff = toLowerAscii(f)
    if   ff == "tribunal.esm":  exp[0] = true
    elif ff == "bloodmoon.esm": exp[1] = true

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for REGN entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "FNAM":
    raise newException(ParseError, "No FNAM field found for REGN entry.")
  discard readStr(fr, 4) # loose bytes
  result.name = parseZString(fr)

  if readStr(fr, 4) != "WEAT":
    raise newException(ParseError, "No WEAT field found for REGN entry.")
  discard readStr(fr, 4) # loose bytes
  if exp[0] or exp[1]:
    result.weather = (readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr))
  else:
    result.weather = (readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr),
                      readUint8(fr), readUint8(fr),
                      0,             0)

  if fr[0..3] == "BNAM":
    discard readStr(fr, 4) # BNAM
    discard readStr(fr, 4) # loose bytes
    result.sleep_cr = parseZString(fr)

  if readStr(fr, 4) != "CNAM":
    raise newException(ParseError, "No CNAM field found for REGN entry.")
  discard readStr(fr, 4) # loose bytes
  result.map_col = (readUint8(fr), readUint8(fr), readUint8(fr), readUint8(fr))

  while true:
    if len(fr) >= 4:
      if fr[0..3] == "SNAM":
        discard readStr(fr, 4) # SNAM
        discard readStr(fr, 4) # loose bytes
        var seq32 = newSeqOfCap[char](32)
        while true:
          if seq32.len < 32:
            seq32.add(readChar(fr))
          else:
            break
        result.sound_ch.add(MWRegionSoundChances(name:   seq32toArray(seq32),
                                                 chance: readUint8(fr)))
      else: break # if not SNAM anymore
    else: break # if end