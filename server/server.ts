import { createServer, Server as HttpServer } from 'http';
import express, { Application } from 'express';
import morgan from 'morgan';
import { Server as SocketServer, Socket as IOSocket } from 'socket.io';
import socketHandler from './app/socket'
import { DrawAppRouter } from './app/routers';
import { DrawDatabase } from './database';
import { SessionService } from './app/service/session.service';
import { WordService } from './app/service/word.service';
import tokenMiddleware from './app/middleware/token.middleware';

export class DrawServer {

    server: HttpServer;
    socketServer: SocketServer;

    constructor(private database: DrawDatabase) {
        const app: Application = express();
        this.server = createServer(app);
        this.socketServer = new SocketServer(this.server);

        const wordService = new WordService(this.database);

        const sessionService = new SessionService(
            this.database,
            this.socketServer,
        );

        // configure socket.io
        this.socketServer.use((socket, next) => {
            const { token } = socket.handshake.auth;
            if (!token) return next(new Error('NO_TOKEN'));
            if (token !== process.env.TOKEN) return next(new Error('INVALID_TOKEN'));
            return next();
        });

        this.socketServer.on('connection', (socket: IOSocket) => socketHandler(this.socketServer, socket, sessionService));

        // configure express
        app.disable('x-powered-by');

        // configure json parsing
        app.use(express.json());

        app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

        // configure auth
        app.use(tokenMiddleware);

        // configure routers
        const drawappRouter = new DrawAppRouter(wordService, sessionService);
        app.use('/api', drawappRouter.router);
    }
};