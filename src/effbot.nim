import irc, asyncdispatch, asyncfile, asyncnet, strutils, future, net
import logging

const
    server = "wilhelm.freenode.net"
    nickname = "EFFBot"
    realname = "Goodbot 0.0.1 https://github.com/Elronnd/goodbot"
    channels = @["#esmtest"]

var done = false


proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
    case event.typ
    of EvConnected:
        discard
    of EvDisconnected, EvTimeout:
        done = true
        discard sleepAsync(1000)
        raise newException(Exception, "Disconnected.")
    of EvMsg:
        proc reply(msg: string): Future[void] =
            client.privmsg(event.origin, msg)

        if event.cmd == MPrivMsg:
            var msg = event.params[event.params.high]

            case msg:
            of "!ping": await reply("pong!")

            of "!lag": await reply(if client.getLag != -1.0: $int(client.getLag * 1000.0) & "ms" else: "Unknown lag")

            of "!users":
                await client.privmsg(event.origin, "Users: " &
                    client.getUserList(event.origin).join(", "))

            of "!quit":
                done = true
                discard sleepAsync(1000)
                client.close

        echo event.raw

proc checkxlog(fn, abbrev: string, client: AsyncIrc, chans: seq[string], isxlog: bool = true, isslashem: bool = false) {.async.} =
    var
        line, formattedline: string
        log: Log
        xlog: Xlog

    const waittime = 0.1

    let fp = openAsync(fn, fmRead)
    fp.setFilePos(fp.getFileSize)

    while not done:
        await sleepAsync(int(waittime * 1000))

        line = await fp.readLine

        if line.len > 0:
            if isxlog:
                xlog = genxlog(line, isslashem)

                formattedline = "[$#] $# ($# $# $# $#$#), $# points, T:$#, $#" % [abbrev, xlog.name, xlog.role, xlog.race, xlog.gender, xlog.align, if xlog.hybrid != nil: " " & xlog.hybrid else: "", $xlog.points, $xlog.turns, xlog.reason]

            else:
                log = genlog(line, isslashem)

                formattedline = "[$#] $# ($# $# $# $#), $# points, $#" % [abbrev, log.name, log.role, log.race, log.gender, log.align, $log.points, log.reason]

            for chan in chans:
                await client.privmsg(chan, formattedline)

            echo line
            echo formattedline

    fp.close

proc main() =
    stdout.write("Enter password (echoed): ")

    let client = newAsyncIrc(server, nick = nickname, joinChans = channels, realname = realname, serverPass = stdin.readLine, callback = onIrcEvent, port=6697.Port)

    let ctx = newContext(protVersion = protTLSv1, verifyMode = CVerifyNone)
    wrapConnectedSocket(ctx, client.sock, handshakeAsClient)

    asyncCheck client.run()
#fn, abbrev: string, client: AsyncIrc, chans: seq[string], isxlog: bool = true, isslashem: bool = false
    asyncCheck checkxlog("slexlog", abbrev="slex", client, @["#esmtest"], isslashem = true)
    asyncCheck checkxlog("nhlog", abbrev="nh", client, @["#esmtest"])
    asyncCheck checkxlog("log", abbrev="s007", client, @["#esmtest"], isxlog = false, isslashem = true)

    # this is essentially what runForever() does but it does while true.
    while not done:
        poll()


main()
