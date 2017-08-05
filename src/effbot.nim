import irc, asyncdispatch, strutils, future

proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
    case event.typ
    of EvConnected:
        nil
    of EvDisconnected, EvTimeout:
        await client.reconnect()
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

        echo(event.raw)

proc main() =
    var client = newAsyncIrc("wilhelm.freenode.net", nick="EFFBot", joinChans = @["#esmtest"], callback = onIrcEvent)
    asyncCheck client.run()

    runForever()
