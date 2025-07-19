import mwparsers/mwstat
import mwparsers/mwmisc
import mwparsers/mwingr
import mwparsers/mwlevi
import mwparsers/mwcont
import mwparsers/mwbook
import mwparsers/mwacti
import mwparsers/mwclot
import mwparsers/mwligh
import mwparsers/mwdoor
import mwparsers/mwalch
import mwparsers/mwland
import mwparsers/mwltex
import mwparsers/mwregn
import mwparsers/mwrepa
import mwparsers/mwappa
import mwparsers/mwprob
import mwparsers/mwlock
import mwparsers/mwskil
import mwparsers/mwscpt
import mwparsers/mwglob
import mwparsers/mwsscr
import mwparsers/mwbody
import mwparsers/mwgmst
import mwparsers/mwarmo
import mwparsers/mwweap
import mwparsers/mwclas
import mwparsers/mwrace
import mwparsers/mwbsgn
import mwparsers/mwmgef
import mwparsers/mwench
import mwparsers/mwspel
import mwparsers/mwfact
import mwparsers/mwsoun
import mwparsers/mwsndg
import mwparsers/mwcrea
import mwparsers/mwlevc
import mwparsers/mwnpc
import std/strformat
import std/strutils
import std/os
import formats
import records
import recordsutils
import streams
import tables
import parse

export tables
export records
export recordsutils

# srcs: https://stackoverflow.com/questions/33107332/writing-reading-binary-file-in-nim
#       https://stackoverflow.com/questions/26845538/parsing-a-binary-file-what-is-a-modern-way
# uesp: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format
# dscd: https://discord.com/channels/210394599246659585/210894929868619778/1211364857169977344

type
  PluginHeader = object
    bytestr* : string

  MWPlugin = object
    name*   : string
    master* : bool
    head*   : PluginHeader
    deps*   : OrderedTable[string, uint64] # esm dependencies as [.esm file, bytes size]
    fin*    : bool                         # whether it was read fully to the last byte
    rem*    : string                       # remaining string (non-empty only if fin == true)
    # Plugin regular records
    clot*   : seq[MWCloth]           # clothes (see `MWCloth` in records.nim for reference)
    misc*   : seq[MWMisc]            # misc items (see `MWMisc` in records.nim for reference)
    stat*   : seq[MWStatic]          # statics (see `MWStatic` in records.nim for reference)
    cont*   : seq[MWContainer]       # containers (see `MWContainer` in records.nim for reference)
    acti*   : seq[MWActivator]       # activators (see `MWActivator` in records.nim for reference)
    ligh*   : seq[MWLight]           # lights (see `MWLight` in records.nim for reference)
    ingr*   : seq[MWIngredient]      # ingredients (see `MWIngredient` in records.nim for reference)
    alch*   : seq[MWPotion]          # potion (see `MWPotion` in records.nim for reference)
    book*   : seq[MWBook]            # books (see `MWBook` in records.nim for reference)
    repa*   : seq[MWRepairTool]      # repair tools (see `MWRepairTool` in records.nim for reference)
    appa*   : seq[MWApparatus]       # apparatuses (see `MWApparatus` in records.nim for reference)
    lock*   : seq[MWLock]            # locks (see `MWLock` in records.nim for reference)
    prob*   : seq[MWProbe]           # probes (see `MWProbe` in records.nim for reference)
    levi*   : seq[MWLeveledItem]     # leveled items (see `MWLeveledItem` in records.nim for reference)
    door*   : seq[MWDoor]            # doors (see `MWDoor` in records.nim for reference)
    land*   : seq[MWLand]            # lands (see `MWLand` in records.nim for reference)
    ltex*   : seq[MWLandTexture]     # land textures (see `MWLandTexture` in records.nim for reference)
    regn*   : seq[MWRegion]          # regions (see `MWRegion` in records.nim for reference)
    skil*   : seq[MWSkill]           # skills (see `MWSkill` in records.nim for reference)
    scpt*   : seq[MWScript]          # scripts (see `MWScript` in records.nim for reference)
    glob*   : seq[MWGlobal]          # globals (see `MWGlobal` in records.nim for reference)
    sscr*   : seq[MWStartScript]     # start scripts (see `MWStartScript` in records.nim for reference)
    body*   : seq[MWBody]            # body parts (see `MWBody` in records.nim for reference)
    gmst*   : seq[MWGameSetting]     # game settings (see `MWGameSetting` in records.nim for reference)
    weap*   : seq[MWWeapon]          # weapons (see `MWWeapon` in records.nim for reference)
    armo*   : seq[MWArmor]           # armors (see `MWArmor` in records.nim for reference)
    clas*   : seq[MWClass]           # classes (see `MWClass` in records.nim for reference)
    race*   : seq[MWRace]            # races (see `MWRace` in records.nim for reference)
    bsgn*   : seq[MWBirthsign]       # birthsigns (see `MWBirthsign` in records.nim for reference)
    mgef*   : seq[MWMagicEffect]     # magic effects (see `MWMagicEffect` in records.nim for reference)
    ench*   : seq[MWEnchantment]     # enchantments (see `MWEnchantment` in records.nim for reference)
    spel*   : seq[MWSpell]           # spells (see `MWSpell` in records.nim for reference)
    fact*   : seq[MWFaction]         # factions (see `MWFaction` in records.nim for reference)
    soun*   : seq[MWSound]           # sounds (see `MWSound` in records.nim for reference)
    sndg*   : seq[MWSoundGenerator]  # sound generators (see `MWSoundGenerator` in records.nim for reference)
    crea*   : seq[MWCreature]        # creatures (see `MWCreature` in records.nim for reference)
    levc*   : seq[MWLeveledCreature] # leveled creatures (see `MWLeveledCreature` in records.nim for reference)
    npc*    : seq[MWNPC]             # NPCs (see `MWNPC` in records.nim for reference)

proc `$`* (plugin: MWPlugin): string =
    var deps = ""
    for k, _ in plugin.deps:
      deps.add("\n" & "* " & k)
    result = fmt"""
    [{plugin.name}]
    Dependencies: {deps}

    Data:
    * statics:           {plugin.stat.len}
    * containers:        {plugin.cont.len}
    * activators:        {plugin.acti.len}
    * lights:            {plugin.ligh.len}
    * miscs:             {plugin.misc.len}
    * clothes:           {plugin.clot.len}
    * armors:            {plugin.armo.len}
    * ingredients:       {plugin.ingr.len}
    * potions:           {plugin.alch.len}
    * books:             {plugin.book.len}
    * weapons:           {plugin.weap.len}
    * repair tools:      {plugin.repa.len}
    * apparatuses:       {plugin.appa.len}
    * locks:             {plugin.lock.len}
    * probes:            {plugin.prob.len}
    * leveled items:     {plugin.levi.len}
    * doors:             {plugin.door.len}
    * land:              {plugin.land.len}
    * land textures:     {plugin.ltex.len}
    * regions:           {plugin.regn.len}
    * skills:            {plugin.skil.len}
    * scripts:           {plugin.scpt.len}
    * globals:           {plugin.glob.len}
    * start scripts:     {plugin.sscr.len}
    * game settings:     {plugin.gmst.len}
    * body parts:        {plugin.body.len}
    * classes:           {plugin.clas.len}
    * races:             {plugin.race.len}
    * birthsigns:        {plugin.bsgn.len}
    * magic effects:     {plugin.mgef.len}
    * enchantments:      {plugin.ench.len}
    * spells:            {plugin.spel.len}
    * factions:          {plugin.fact.len}
    * sounds:            {plugin.soun.len}
    * sound generators:  {plugin.sndg.len}
    * creatures:         {plugin.crea.len}
    * leveled creatures: {plugin.levc.len}
    * NPCs:              {plugin.npc.len}
    """.unindent()

proc newPluginHeader(header_string: string): PluginHeader =
    result.bytestr = header_string

proc newMWPlugin* (path: string): MWPlugin =
    let fs : FileStream = newFileStream(path)
    var fr : string     = fs.readAll()        # file read: string here == seq[bytes]

    if readStr(fr, 4) != "TES3": # initial .esp check
      raise newException(ParseError, fmt"File scanned does not follow correct Morrowind .esp/.esm plugin record format. File path: {path}.")
    close(fs)

    if endswith(toLowerAscii(path), ".esp"):
      result.name   = path.replace(".esp", "")
      result.master = false
    elif endsWith(toLowerAscii(path), ".esm"):
      result.name   = path.replace(".esm", "")
      result.master = true
    else: raise newException(ParseError, fmt"Cannot verify file: {path}. Make sure the file scanned is of .esp/.esm format.")

    discard readStr(fr, 12) # loose bytes
    if readStr(fr, 4) != "HEDR": # check for header
      raise newException(ParseError, fmt"File header for file: {path} not found.")
    discard readStr(fr, 4) # loose bytes

    result.head = newPluginHeader(fr.read(300)) # 300 bytes after initial check (w/o TES3 header)
    result.fin  = true                          # default, will be overwritten later if 'false'

    # records
    while fr.len > 0:
      if fr.len < 4:
        result.fin = false
        break
      case fr[0..3]: # checks record type (consumed during record header parsing)
        of "MAST": parseMAST(fr, result.deps)
        of "CLOT": result.clot.add(parseCLOT(fr))
        of "STAT": result.stat.add(parseSTAT(fr))
        of "MISC": result.misc.add(parseMISC(fr))
        of "INGR": result.ingr.add(parseINGR(fr))
        of "CONT": result.cont.add(parseCONT(fr))
        of "LEVI": result.levi.add(parseLEVI(fr))
        of "BOOK": result.book.add(parseBOOK(fr))
        of "ACTI": result.acti.add(parseACTI(fr))
        of "LIGH": result.ligh.add(parseLIGH(fr))
        of "DOOR": result.door.add(parseDOOR(fr))
        of "ALCH": result.alch.add(parseALCH(fr))
        of "LAND": result.land.add(parseLAND(fr))
        of "LTEX": result.ltex.add(parseLTEX(fr))
        of "REGN": result.regn.add(parseREGN(fr, result.deps))
        of "CELL": discard readStr(fr, 12 + 29 + 4) # for `tesannwyn.esp` compatibility only (+4 for "CELL")
        of "WEAP": result.weap.add(parseWEAP(fr))
        of "ARMO": result.armo.add(parseARMO(fr))
        of "REPA": result.repa.add(parseREPA(fr))
        of "APPA": result.appa.add(parseAPPA(fr))
        of "LOCK": result.lock.add(parseLOCK(fr))
        of "PROB": result.prob.add(parsePROB(fr))
        of "SKIL": result.skil.add(parseSKIL(fr))
        of "SCPT": result.scpt.add(parseSCPT(fr))
        of "GLOB": result.glob.add(parseGLOB(fr))
        of "SSCR": result.sscr.add(parseSSCR(fr))
        of "BODY": result.body.add(parseBODY(fr))
        of "GMST": result.gmst.add(parseGMST(fr))
        of "CLAS": result.clas.add(parseCLAS(fr))
        of "RACE": result.race.add(parseRACE(fr))
        of "SPEL": result.spel.add(parseSPEL(fr))
        of "ENCH": result.ench.add(parseENCH(fr))
        of "MGEF": result.mgef.add(parseMGEF(fr))
        of "BSGN": result.bsgn.add(parseBSGN(fr))
        of "FACT": result.fact.add(parseFACT(fr))
        of "SOUN": result.soun.add(parseSOUN(fr))
        of "SNDG": result.sndg.add(parseSNDG(fr))
        of "CREA": result.crea.add(parseCREA(fr))
        of "LEVC": result.levc.add(parseLEVC(fr))
        of "NPC_": result.npc.add(parseNPC(fr))
        else:
          result.fin = false
          break

    if result.fin == false: result.rem = fr