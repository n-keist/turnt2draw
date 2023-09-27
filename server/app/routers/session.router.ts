import express, { Router } from 'express';
import { DrawDatabase } from '../../database';
import { SessionController } from '../controllers/session.controller';
import { SessionRepository } from '../repository/session.repository';
import { SessionService } from '../service/session.service';

export class SessionRouter {

    router: Router;

    constructor(private service: SessionService) {
        this.router = express.Router();

        const controller: SessionController = new SessionController(service);

        this.router.get('/:id', controller.findSession);
        this.router.post('/', controller.startSession);
        this.router.get('/:id/begin', controller.beginSession);
        this.router.put('/:id/join', controller.joinSession);
    }
};