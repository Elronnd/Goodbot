import times, strutils, tables, strutils

let nhlog = "version=3.6.0	points=71	deathdnum=0	deathlev=1	maxlvl=1	hp=0	maxhp=12	deaths=1	deathdate=20160305	birthdate=20160302	uid=1003	role=Wiz	race=Hum	gender=Mal	align=Cha	name=Bluescreen	death=killed by a grid bug	conduct=0xfbf	turns=23	achieve=0x0	realtime=69	starttime=1456931741	endtime=1457196535	gender0=Mal	align0=Cha	flags=0x4"

let slexlog = "version=slex-2.0.0	points=0	deathdnum=0	deathlev=1	maxlvl=1	hp=6	maxhp=6	deaths=0	deathdate=20170810	birthdate=20170806	uid=1003	role=Psi	race=Unm	gender=Fem	align=Neu	hybrid=MazSok	name=dolores	death=escaped	conduct=0x1fff	turns=1	achieve=0x0	realtime=13	starttime=1502027770	endtime=1502346505	gender0=Fem	align0=Neu	modes=normal"
#let slexlog = "version=slex-1.9.3	points=766570	deathdnum=8	deathlev=10	maxlvl=13	hp=178	maxhp=178	deaths=1	deathdate=20170526	birthdate=20170520	uid=1003	role=Mah	race=Hax	gender=Mal	align=Law	hybrid=none	name=BSOD2	death=quit	conduct=0x900	turns=27281	achieve=0x28200	realtime=100385	starttime=1495240241	endtime=1495801330	gender0=Mal	align0=Law	modes=normal"



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

    if "hybrid" in tab and tab["hybrid"] != "none":
        xlog.hybrid = tab["hybrid"]

    #wizmode, discover, bones: bool

    return xlog


echo genxlog(nhlog)
