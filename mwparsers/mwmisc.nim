import ../records
import ../parse

proc parseMISC* (fr: var string): MWMisc =
  #[ Parses singel CLOT key of .esm/.esp files and returns it as MWCloth object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard