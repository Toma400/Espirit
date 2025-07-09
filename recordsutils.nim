import std/strformat
import std/strutils
import records

proc `$`* (record: MWCommonRecord): string =
    result = record.id

proc `$`* (clobj: MWClothObj | MWArmorObj): string =
    result = fmt"{clobj.biped}: {MWBipedType(clobj.biped)} | {clobj.mname}, {clobj.fname}"

proc `$`* (land: MWLand): string =
    result = fmt"X: {land.coord[0]}, Y: {land.coord[1]}"

proc `$`* (sk: MWSkill): string =
    result = fmt"Index: {sk.index}"

proc `$`* (scr: MWScript): string =
    result = fmt"Name: {scr.sheader.name}"

proc `$`* (scr: MWGlobal | MWStartScript | MWGameSetting): string =
    result = fmt"Name: {scr.name}"

proc info* (record: MWCloth): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    if record.objs.len > 0:
      options.add("\n    Objects:")
      for obj in record.objs:
        options.add("\n    - " & $obj)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Kind:   {record.data.kind} [{MWClothType(record.data.kind)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """

proc info* (record: MWMisc): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """

proc info* (record: MWIngredient): string =
    var options = ""
    var effects = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    for c, ef in record.data.effindex:
      if ef != -1:
        var sk = ""
        var at = ""
        if record.data.skill[c] > 0: sk = fmt"[SkillIndex:     {record.data.skill[c]}]"
        if record.data.attr[c]  > 0: at = fmt"[AttributeIndex: {record.data.attr[c]}]"
        effects.add("\n      - " & fmt"{ef} [{MWEffectType(ef)}] {sk}{at}")
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
      Effects:    {effects}
    ====={options}
    """

proc info* (record: MWContainer): string =
    proc getID(a: array[32, char]): string =
      for i in a:
        if i != '\0': result.add(i)

    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.contents.len > 0:
      options.add("\n    Contents:")
      for it in record.contents:
        options.add("\n" & fmt"    - {it[1].getID} [{it[0]}]")
    # TODO: lacks some flags info
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    =====
      Weight: {record.weight}
    ====={options}
    """

proc info* (record: MWActivator | MWDoor): string =
    var script = "[None]"
    if record.script != "":
      script = record.script
    result = fmt"""
    ID:     {record.id}
    Name:   {record.name}
    Model:  {record.model}
    Script: {script}
    """

proc info* (record: MWLight): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.sound != "":
      options.add("\n    Sound:   " & record.sound)
    result = fmt"""
    ID:     {record.id}
    Name:   {record.name}
    Model:  {record.model}
    Icon:   {record.icon}
    =====
      Type:   {record.data.flags} [{MWLightType(record.data.flags)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
      Time:   {record.data.time}
      Radius: {record.data.radius}
      Color:  {record.data.color}
    ====={options}
    """

proc info* (record: MWBook): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """
    # TODO: Not all values added

proc read* (record: MWBook): string =
    proc mwFormat(r: string): string =
      let rep = {"<br>": "\n",
                 "<BR>": "\n"}
      result = r
      for k, v in rep.items:
        result = result.replace(k, v)

    return mwFormat(record.text)

proc info* (record: MWLeveledItem): string =
    var items = ""
    if record.count > 0:
      items.add("\n    Count: " & $record.count)
    if record.items.len > 0:
      items.add("\n    Items:")
    for i in record.items:
      items.add("\n    - " & fmt"{i[0]}: {i[1]}")
    result = fmt"""
    ID:    {record.id}
    ====={items}
    =====
    """

proc info* (record: MWPotion): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """
    # TODO: Not all values added # EFFECTS!!!

proc info* (record: MWLandTexture): string =
    result = fmt"""
    ID:      {record.id}
    Index:   {record.index}
    Texture: {record.tex}
    """

proc info* (record: MWLand): string =
    result = fmt"""
    Coords: X: {record.coord[0]}
            Y: {record.coord[1]}
    Offset: {record.hgdata.hoffset}
    """

proc info* (record: MWRegion): string =
    result = fmt"""
    ID:      {record.id}
    Name:    {record.name}
    Weather:
      - Clear    [{record.weather[0]}]
      - Cloudy   [{record.weather[1]}]
      - Foggy    [{record.weather[2]}]
      - Overcast [{record.weather[3]}]
      - Rain     [{record.weather[4]}]
      - Thunder  [{record.weather[5]}]
      - Ash      [{record.weather[6]}]
      - Blight   [{record.weather[7]}]
      - Snow     [{record.weather[8]}]
      - Blizzard [{record.weather[9]}]
    Map: (R: {record.map_col[0]}, G: {record.map_col[1]}, B: {record.map_col[2]}, A: {record.map_col[3]})
    """
    # TODO: Not all values added # SOUND CHANCES / SLEEP CREATURE? !!!

proc info* (record: MWRepairTool | MWLock | MWProbe): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight:  {record.data.weight}
      Value:   {record.data.value}
      Uses:    {record.data.uses}
      Quality: {record.data.quality}
    ====={options}
    """

proc info* (record: MWApparatus): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Type:    {record.data.kind} [{MWApparatusType(record.data.kind)}]
      Weight:  {record.data.weight}
      Value:   {record.data.value}
      Quality: {record.data.quality}
    ====={options}
    """

proc info* (record: MWSkill): string =
    result = fmt"""
    Name:  {MWSkillType(record.index)}
    Index: {record.index}
    =====
      Attribute:      {record.data.attr} [{MWAttributeType(record.data.attr)}]
      Specialisation: {record.data.spec}
      Use Values:     {record.data.usev}
    =====
    Description:
    {record.descr}
    """

proc info* (record: MWScript): string =
    proc charsToString(ca: array[32, char]): string =
      for c in ca:
        result.add(c)
    proc listMembers(sq: seq[string]): string =
      for sqm in sq:
        result.add("\n")
        result.add(fmt"   - {sqm}")
    proc formatScript(s: string): string =
      let lines  = s.split({'\n', '\r'})
      var lbreak = false
      for i, sl in lines.pairs:
        if i < len(lines):
          if sl != "": # being here, allows for proper script to get in
            lbreak = false
          if lbreak == false:
            result.add("\n")
            result.add(fmt"    {sl}")
          if sl == "": # being here, it allows for one break to happen
            lbreak = true

    result = fmt"""
    Name: {charsToString(record.sheader.name)}
    =====
    Variables:
      Shorts [{record.sheader.numshort}]{listMembers(record.vars.shorts)}
      Longs [{record.sheader.numlong}]{listMembers(record.vars.longs)}
      Floats [{record.sheader.numfloat}]{listMembers(record.vars.floats)}
    =====
    Script:
    '''{formatScript(record.text)}
    '''
    """

proc info* (record: MWGlobal): string =
    result = fmt"""
    Name:  {record.name}
    Type:  {FieldType(record.ftype)}
    Value: {record.value}
    """

proc info* (record: MWStartScript): string =
    result = fmt"""
    Name: {record.name}
    Data: {record.data}
    """

proc info* (record: MWBody): string =
    result = fmt"""
    ID:    {record.id}
    Model: {record.model}
    Race:  {record.race}
    =====
    Data:
      Body Part: {record.data.part} [{MWBodyPartType(record.data.part)}]
      Vampire:   {record.data.vampire}
      Flags:     {record.data.flags} [{MWBodyFlags(record.data.flags)}]
      Type:      {record.data.pkind} [{MWBodyKindType(record.data.pkind)}]
    =====
    """

proc info* (record: MWGameSetting): string =
    result = fmt"""
    Name: {record.name}
    Type: {record.kind} [{FieldType(record.kind)}]
    =====
      Float:  {record.valfl}
      Int:    {record.vali}
      String: {record.vals}
    =====
    """

proc info* (record: MWWeapon): string =
    var options = ""
    if record.data.flags != 0:
      options.add("\n    Flag: " & $MWWeaponFlags(record.data.flags))
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Type:   {record.data.kind} [{MWWeaponType(record.data.kind)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
      Health: {record.data.health}
      Speed:  {record.data.speed}
      Reach:  {record.data.reach}
      Damage:
        Chop:   {record.data.chopmin} - {record.data.chopmax}
        Slash:  {record.data.slshmin} - {record.data.slshmax}
        Thrust: {record.data.thrsmin} - {record.data.thrsmax}
      Enchant Points: {record.data.enchpts}
    ====={options}
    """

proc info* (record: MWArmor): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    if record.objs.len > 0:
      options.add("\n    Objects:")
      for obj in record.objs:
        options.add("\n    - " & $obj)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Type:   {record.data.kind} [{MWArmorType(record.data.kind)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
      AR:     {record.data.ar}
      Health: {record.data.health}
      Enchant Points: {record.data.enchpts}
    ====={options}
    """

proc getMinorSkills* (record: MWClass): array[5, uint32] =
    return [
        record.data.skill[0][0],
        record.data.skill[1][0],
        record.data.skill[2][0],
        record.data.skill[3][0],
        record.data.skill[4][0]
    ]

proc getMajorSkills* (record: MWClass): array[5, uint32] =
    return [
        record.data.skill[0][1],
        record.data.skill[1][1],
        record.data.skill[2][1],
        record.data.skill[3][1],
        record.data.skill[4][1]
    ]

proc info* (record: MWClass): string =
    let fg = yieldServicesTrades(record.data.flagsac)
    var ft = "Trades:"
    var fs = "Services:"
    for f in fg:
        if f <= 16384'u32:
            ft.add("\n" & fmt"      - {f} [{MWServicesTradesType(f)}]")
        else:
            fs.add("\n" & fmt"      - {f} [{MWServicesTradesType(f)}]")
    var at = "Primary attributes:"
    for aa in record.data.attr:
      at.add("\n" & fmt"      - {aa} [{MWAttributeType(aa)}]")
    var sk = "Skills:"
    sk.add("\n      Minor:")
    for mi in getMinorSkills(record):
      sk.add("\n" & fmt"      - {mi} [{MWSkillType(mi)}]")
    sk.add("\n      Major:")
    for ma in getMajorSkills(record):
      sk.add("\n" & fmt"      - {ma} [{MWSkillType(ma)}]")
    result = fmt"""
    ID:   {record.id}
    Name: {record.name}
    =====
    Playable:       {bool(record.data.flags)}
    Specialisation: {record.data.spec} [{MWSpecialisationType(record.data.spec)}]
    {at}
    {sk}
    {ft}
    {fs}
    =====
    Description:
    {record.descr}
    """