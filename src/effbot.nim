import irc, times, asyncdispatch, strutils, future, net, asyncnet

const
    server = "wilhelm.freenode.net"

proc sslreconnect2*(irc: AsyncIrc, timeout = 5000) {.async.} =
    irc.sock.close()

    await irc.reconnect()

    let ctx = newContext(protVersion = protTLSv1, verifyMode = CVerifyNone)
    wrapConnectedSocket(ctx, irc.sock, handshakeAsClient)

proc sslreconnect*(irc: AsyncIrc, timeout = 5000) {.async.} =
    ## Reconnects to an IRC server.
    ##
    ## ``Timeout`` specifies the time to wait in miliseconds between multiple
    ## consecutive reconnections.
    ##
    ## This should be used when an ``EvDisconnected`` event occurs.

    let secSinceReconnect = epochTime() - irc.lastReconnect
    if secSinceReconnect < (timeout/1000):
        await sleepAsync(timeout - int(secSinceReconnect * 1000))

    irc.sock.close()
    irc.sock = newAsyncSocket()

    let ctx = newContext(protVersion = protTLSv1, verifyMode = CVerifyNone)
#    wrapConnectedSocket(ctx, irc.sock, handshakeAsClient)
#    wrapSocket(ctx, irc.sock)

    await irc.connect()
    wrapConnectedSocket(ctx, irc.sock, handshakeAsClient)
    irc.lastReconnect = epochTime()


proc onIrcEvent(client: AsyncIrc, event: IrcEvent) {.async.} =
    case event.typ
    of EvConnected:
        nil
    of EvDisconnected, EvTimeout:
        await client.sslreconnect()
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

            of "!reconn":
                await client.sslreconnect()

        echo(event.raw)

proc main() =
    var client = newAsyncIrc("wilhelm.freenode.net", nick="EFFBot", joinChans = @["#esmtest"], callback = onIrcEvent, port=6697.Port)

    let ctx = newContext(protVersion = protTLSv1, verifyMode = CVerifyNone)
    wrapConnectedSocket(ctx, client.sock, handshakeAsClient)

    asyncCheck client.run()

    runForever()

main()
