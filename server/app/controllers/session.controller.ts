import { Request, Response } from 'express';
import { SessionRepository } from '../repository/session.repository';
import { SessionService } from '../service/session.service';

export class SessionController {

    constructor(private service: SessionService) { }

    findSession = async (request: Request, response: Response) => {
        const session: DBSession | undefined = await this.service.getSessionRepository().findSession(request.params.id);
        if (!session) return response.status(404).end();
        return response.status(200).json(session);
    };

    startSession = async (request: Request, response: Response) => {
        const config: CreateSessionConfig = request.body;
        const sessionId: string | undefined = await this.service.getSessionRepository().createSession(config);
        if (!sessionId) return response.status(500).end();
        return response.status(201).json({ id: sessionId });
    };

    joinSession = async (request: Request, response: Response) => {
        const joined: boolean = await this.service.getSessionRepository().joinSession(request.params.id, request.body.playerId?.toString() || '', request.body.playerDisplayname?.toString() || '');
        return response.status(joined ? 200 : 500).end();
    };

    beginSession = async (request: Request, response: Response) => {
        const sessionId: string = request.params.id;
        if (!sessionId) return response.status(400).json({
            err_code: 'NO_ID'
        });
        const beginResult: string | undefined = await this.service.beginSession(sessionId);
        if (beginResult != undefined) {
            return response.status(500).json({
                err_code: beginResult,
            });
        }
        return response.status(200).end();
    };

};