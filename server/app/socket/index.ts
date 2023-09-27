import { Socket, Server as SocketServer } from 'socket.io';
import { SessionService } from '../service/session.service';

export default (server: SocketServer, socket: Socket, service: SessionService) => {

    socket.on('session.checkIn', async (room: string) => {
        console.log('joining room', room);
        await socket.join(room);
        const players = await service.getPlayers(room);
        server.to(room).emit('session.players', { players });
    });

    socket.on('session.draw', (data: any) => {
        socket.to(data.sessionId).emit('session.draw', data.drawable);
    });

    socket.on('session.draw.commit', async (data: any) => {
        const json = JSON.parse(data);

        await service.putDrawing(json.turnId, json.drawable);
        // TODO: think of a more performant solution
        //const drawings: DBDrawing[] = await service.getDrawings(json.sessionId);
        //socket.to(json.sessionId).emit('session.drawables', drawings);
    });
}