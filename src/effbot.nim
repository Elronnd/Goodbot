import irc, times, asyncdispatch, strutils, future, net, asyncnet

const
    server = "wilhelm.freenode.net"
    nickname = "EFFBot"
    realname = "Goodbot 0.0.1 https://github.com/Elronnd/goodbot"
    channels = @["#esmtest"]


proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
    case event.typ
    of EvConnected:
        discard
    of EvDisconnected, EvTimeout:
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
                client.close

        echo event.raw



proc main() =
    stdout.write("Enter password (echoed): ")

    var client = newAsyncIrc(server, nick = nickname, joinChans = channels, realname = realname, serverPass = stdin.readLine(), callback = onIrcEvent, port=6697.Port)

    let ctx = newContext(protVersion = protTLSv1, verifyMode = CVerifyNone)
    wrapConnectedSocket(ctx, client.sock, handshakeAsClient)

    asyncCheck client.run()

    runForever()

main()
