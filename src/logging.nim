import times, strutils, tables, strutils

let nhxlog = "version=3.6.0	points=71	deathdnum=0	deathlev=1	maxlvl=1	hp=0	maxhp=12	deaths=1	deathdate=20160305	birthdate=20160302	uid=1003	role=Wiz	race=Hum	gender=Mal	align=Cha	name=Bluescreen	death=killed by a grid bug	conduct=0xfbf	turns=23	achieve=0x0	realtime=69	starttime=1456931741	endtime=1457196535	gender0=Mal	align0=Cha	flags=0x4"

let slexxxlog = "version=slex-2.0.0	points=0	deathdnum=0	deathlev=1	maxlvl=1	hp=6	maxhp=6	deaths=0	deathdate=20170810	birthdate=20170806	uid=1003	role=Psi	race=Unm	gender=Fem	align=Neu	hybrid=MazSok	name=dolores	death=escaped	conduct=0x1fff	turns=1	achieve=0x0	realtime=13	starttime=1502027770	endtime=1502346505	gender0=Fem	align0=Neu	modes=normal"

let nhlog = "3.6.0 71 0 1 1 0 12 1 20160305 20160302 1003 Wiz Hum Mal Cha Bluescreen,killed by a grid bug"
let slashemlog = "0.0.8 0 0 1 1 16 16 0 20160425 20160425 1003 Kni Hum Fem Law Elronnd,quit Conduct=0"



type
    Xlog = object
        version*: string
        points*: int
        deathdnum*: int
        deathlev*: int
        maxlvl*: int
        hp*: int
        maxhp*: int
        deaths*: int
        starttime*, endtime*: Time
        uid*: int
        role*, race*, gender*, align*, hybrid*: string
        name*: string
        death*: string
        conduct*, turns*, achieve*: int

        realtime*: int

        gender0, align0*: string

        wizmode*, discover*, bones*: bool


    Log = object
        version*: string
        points*: int

        deathdnum*, deathlev*, maxlvl*: int

        hp*, maxhp*: int
        deaths*: int

        starttime*, endtime*: Time

        uid*: int        

        role*, race*, gender*, align*, name*, reason*: string

        conduct*: int

   

proc genxlog*(str: string, isslex: bool = false, delim: string = "\t"): Xlog =
    const equals = "="
    var
        tab = initTable[string, string]()
        xlog: Xlog

    let list = str.split(delim)

    for itemp in list:
        let item = itemp.split(equals)
        tab[item[0]] = item[1]

    xlog.version = tab["version"]
    xlog.points = parseInt(tab["points"])
    xlog.deathdnum = parseInt(tab["deathdnum"])
    xlog.deathlev = parseInt(tab["deathlev"])
    xlog.maxlvl = parseInt(tab["maxlvl"])
    xlog.hp = parseInt(tab["hp"])
    xlog.maxhp = parseInt(tab["maxhp"])
    xlog.deaths = parseInt(tab["deaths"])
    xlog.starttime = fromSeconds(parseInt(tab["starttime"]))
    xlog.endtime = fromSeconds(parseInt(tab["endtime"]))
    xlog.uid = parseInt(tab["uid"])
    xlog.role = tab["role"]
    xlog.race = tab["race"]
    xlog.gender = tab["gender"]
    xlog.align = tab["align"]
    xlog.name = tab["name"]
    xlog.death = tab["death"]
    xlog.conduct = parseHexInt(tab["conduct"])
    xlog.turns = parseInt(tab["turns"])
    xlog.achieve = parseHexInt(tab["achieve"])

    xlog.realtime = parseInt(tab["realtime"])
    
    xlog.gender0 = tab["gender0"]
    xlog.align0 = tab["align0"]

    if isslex and tab["hybrid"] != "none":
        xlog.hybrid = tab["hybrid"]

    #wizmode, discover, bones: bool

    return xlog

proc genlog(str: string, isslashem: bool = false, delim: string = " "): Log =
    var log: Log

    let list = str.split(delim)

    log.version = list[0]
    log.points = parseInt(list[1])

    log.deathdnum = parseInt(list[2])
    log.deathlev = parseInt(list[3])
    log.maxlvl = parseInt(list[4])

    log.hp = parseInt(list[5])
    log.maxhp = parseInt(list[6])
    log.deaths = parseInt(list[7])

    log.starttime = toTime(parse(list[8], "yyyyMMdd"))
    log.endtime = toTime(parse(list[9], "yyyyMMdd"))

    log.uid = parseInt(list[10])

    log.role = list[11]
    log.race = list[12]
    log.gender = list[13]
    log.align = list[14]

    let namereason = list[15].split(',')

    log.name = namereason[0]

    # Can't go over into conduct
    if isslashem:
        log.reason = namereason[1] & " " & list[16..^2].join(" ")
    else:
        log.reason = namereason[1] & " " & list[16..^1].join(" ")

    # or a variant
    if isslashem:
        log.conduct = parseInt(list[high(list)].split('=')[1])

    return log
    
        
     

echo genxlog(nhxlog)
echo genlog(slashemlog, true)
echo genlog(nhlog)
