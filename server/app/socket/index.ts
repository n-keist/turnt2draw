import { Socket, Server as SocketServer } from 'socket.io';
import { SessionService } from '../service/session.service';

export default (server: SocketServer, socket: Socket, service: SessionService) => {

    socket.on('session.checkIn', async (data: any) => {
        socket.data.artRoom = data.room;
        socket.data.artPlayerId = data.playerId;

        await socket.join(data.room);
        const players = await service.getPlayers(data.room);
        server.to(data.room).emit('session.players', { players });
    });

    socket.on('session.draw', (data: any) => {
        socket.to(data.sessionId).emit('session.draw', data.drawable);
    });

    socket.on('session.draw.commit', async (data: any) => {
        const json = JSON.parse(data);

        await service.putDrawing(json.turnId, json.drawable);
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