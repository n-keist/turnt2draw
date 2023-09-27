import { createServer, Server as HttpServer } from 'http';
import express, { Application } from 'express';
import { Server as SocketServer, Socket as IOSocket } from 'socket.io';
import socketHandler from './app/socket'
import { DrawAppRouter } from './app/routers';
import { DrawDatabase } from './database';
import { SessionService } from './app/service/session.service';
import { SessionRepository } from './app/repository/session.repository';
import { PlayerRepository } from './app/repository/player.repository';
import { TurnRepository } from './app/repository/turn.repository';

export class DrawServer {

    server: HttpServer;

    constructor(private database: DrawDatabase) {
        const app: Application = express();
        this.server = createServer(app);
        const socketServer: SocketServer = new SocketServer(this.server);

        const sessionService = new SessionService(
            new SessionRepository(database),
            new PlayerRepository(database),
            new TurnRepository(database),
            socketServer,
        );

        // configure socket.io
        socketServer.on('connection', (socket: IOSocket) => socketHandler(socketServer, socket, sessionService));

        // configure express
        app.disable('x-powered-by');

        // configure middleware
        app.use(express.json());

        app.use((req, res, next) => {
            console.log(`Request received: ${req.method} ${req.url}`);
            next();
        });

        // configure routers
        const drawappRouter = new DrawAppRouter(database, sessionService);
        app.use('/api', drawappRouter.router);
    }
};