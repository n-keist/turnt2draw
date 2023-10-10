import { Request, Response } from 'express';
import { SessionService } from '../service/session.service';
import userValidator from '../validators/user.validator';

export class SessionController {

    constructor(private service: SessionService) { }

    findSession = async (request: Request, response: Response) => {
        const session: DBSession | undefined = await this.service.getSessionRepository().findSession(request.params.id);
        if (!session) return response.status(404).end();
        return response.status(200).json(session);
    };

    findById = async (request: Request, response: Response) => {
        if (!request.query.code) return response.status(400).end();
        const { code } = request.query;
        const session: DBSession | undefined = await this.service.getSessionRepository().findSessionByCode(code as string);
        if (session == undefined) return response.status(404).end();
        return response.status(200).json(session);
    };

    createSession = async (request: Request, response: Response) => {
        const config: CreateSessionConfig = request.body;
        const sessionId: string | undefined = await this.service.getSessionRepository().createSession(config);
        if (!sessionId) return response.status(500).end();
        return response.status(201).json({ id: sessionId });
    };

    joinSession = async (request: Request, response: Response) => {
        if (!userValidator(request.body).validate()) {
            return response.status(400).end();
        }
        let player: Player = request.body;
        if (!player.player_session) player.player_session = request.params['id'];
        const joined: boolean = await this.service.getSessionRepository().joinSession(player);
        return response.status(joined ? 200 : 500).end();
    };

    joinRandomSession = async (request: Request, response: Response) => {
        if (!userValidator(request.body).validate()) {
            return response.status(400).end();
        }
        const player: Player = request.body;

        const joined: string | undefined = await this.service.joinRandomSession(player);
        return response.status(joined ? 200 : 404).json({ sessionId: joined });
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