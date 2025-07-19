import ../records
import ../common
import ../parse

const field_key = "FACT"

proc getRankData(fr: var string): array[10, MWRankData] =
    for rank in 0..<10:
      result[rank] = MWRankData(attr_mod: (readUint32(fr), readUint32(fr)),
                                pr_skill: readUint32(fr),
                                fv_skill: readUint32(fr),
                                fact_rc:  readUint32(fr))

proc parseFACT* (fr: var string): MWFaction =
    #[ Parses single FACT key of .esm/.esp files and returns it as MWFaction object ]#
    result.header = parseRecordHeader(fr)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.name  = requiredField[zstring](fr, "FNAM", field_key)
    result.ranks = repeatableField[zstring](fr, "RNAM")

    if objectField(fr, "FADT", result.data, result.id):
      result.data = MWFactionData(attr:     (readUint32(fr), readUint32(fr)),
                                  rankdata: getRankData(fr),
                                  skill:    [
                                      readInt32(fr), readInt32(fr), readInt32(fr),
                                      readInt32(fr), readInt32(fr), readInt32(fr),
                                      readInt32(fr)
                                  ],
                                  flags: readUint32(fr))

    result.relations = repeatablePairField[string, int32](fr, ["ANAM", "INTV"])