import express, { Router } from 'express';
import { WordRouter } from './word.router';
import { SessionRouter } from './session.router';
import { SessionService } from '../service/session.service';
import { WordService } from '../service/word.service';

export class DrawAppRouter {

    router: Router;

    constructor(private wordService: WordService, private sessionService: SessionService) {
        this.router = express.Router();

        const wordRouter = new WordRouter(this.wordService);
        const sessionRouter = new SessionRouter(this.sessionService);
        this.router.use('/words', wordRouter.router);
        this.router.use('/session', sessionRouter.router);
    }
};