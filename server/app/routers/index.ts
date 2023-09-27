import express, { Router } from 'express';
import { WordRouter } from './word.router';
import { DrawDatabase } from '../../database';
import { SessionRouter } from './session.router';
import { SessionService } from '../service/session.service';

export class DrawAppRouter {

    router: Router;

    constructor(private database: DrawDatabase, private service: SessionService) {
        this.router = express.Router();

        const wordRouter = new WordRouter(database);
        const sessionRouter = new SessionRouter(service);
        this.router.use('/words', wordRouter.router);
        this.router.use('/session', sessionRouter.router);
    }
};