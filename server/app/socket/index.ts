import { Socket, Server as SocketServer } from 'socket.io';
import { SessionService } from '../service/session.service';

export default (server: SocketServer, socket: Socket, service: SessionService) => {

    socket.on('session.checkIn', async (data: Player) => {
        socket.data.player = data;
        await service.getSessionRepository().joinSession(data);
        await socket.join(data.player_session);
        const players = await service.getPlayers(data.player_session);
        server.to(data.player_session).emit('session.players', { players });
    });

    socket.on('session.player.kick', async (player: Player) => {
        const sockets = await server.in(socket.data.artRoom).fetchSockets();
        const filteredSockets = sockets.filter((socket) => socket.data.player.player_id == player.player_id);
        filteredSockets.forEach((socket) => socket.emit('session.i.was.kicked'));
    });

    socket.on('session.draw', (data: any) => {
        socket.to(data.sessionId).emit('session.draw', data.drawable);
    });

    socket.on('session.draw.commit', async (data: any) => {
        console.log(data);
        await service.putDrawing(data.turnId, data.drawable);
    });

    socket.on('disconnect', async () => {
        if (!socket.data.artRoom) return;


        await service.getSessionRepository().leaveSession(socket.data.artRoom, socket.data.artPlayerId);

        const sessionInfo = await service.getSession(socket.data.artRoom);
        if (!sessionInfo) return;

        if (sessionInfo.session_owner == socket.data.artPlayerId) {
            const sockets = await server.in(socket.data.artRoom).fetchSockets();
            if (sockets.length == 0) {
                // no one is left in the room, quit
                await service.getSessionRepository().finishSession(socket.data.artRoom);
                return;
            }
            // pick a new session owner & send new info & players
            const players = await service.getPlayers(socket.data.artRoom);
            if (players.length == 0) return;

            await service.getSessionRepository().setOwner(socket.data.artRoom, players[0].player_id);

            const updatedSessionInfo = await service.getSession(socket.data.artRoom);
            const updatedPlayerList = await service.getPlayers(socket.data.artRoom);

            server.to(socket.data.artRoom).emit('session.state', {
                info: updatedSessionInfo,
                players: updatedPlayerList,
            });
        } else {
            const updatedSessionInfo = await service.getSession(socket.data.artRoom);
            const updatedPlayerList = await service.getPlayers(socket.data.artRoom);

            server.to(socket.data.artRoom).emit('session.state', {
                info: updatedSessionInfo,
                players: updatedPlayerList,
            });
        }
    });
}