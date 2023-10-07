import { PlayerRepository } from '../repository/player.repository';
import { SessionRepository } from '../repository/session.repository';
import { TurnRepository } from '../repository/turn.repository';
import { Server as SocketServer } from 'socket.io';

export class SessionService {

    private gameLoop: Map<string, any>;

    constructor(private sessionRepository: SessionRepository, private playerRepository: PlayerRepository, private turnRepository: TurnRepository, private socketServer: SocketServer) {
        this.gameLoop = new Map();
    }

    getSessionRepository = (): SessionRepository => this.sessionRepository;

    getSession = async (sessionId: string): Promise<DBSession | undefined> => {
        const session = await this.sessionRepository.getSession(sessionId);
        return session;
    };

    getPlayers = (sessionId: string): Promise<DBPlayer[]> => {
        return this.playerRepository.getPlayersBySession(sessionId);
    };

    joinRandomSession = async (playerId: string, playerName: string): Promise<string | undefined> => {
        const session = await this.sessionRepository.findRandomSession();
        if (!session) return undefined;
        const joined = await this.sessionRepository.joinSession(session.session_id, playerId, playerName);
        if (joined) return session.session_id;
        return undefined;
    };

    beginSession = async (sessionId: string): Promise<string | undefined> => {

        const sessionInfo = await this.getSession(sessionId);

        if (sessionInfo?.session_state !== 'waiting') {
            return 'TOO_LATE';
        }

        const players = await this.getPlayers(sessionId);

        if (players.length < 2) {
            return 'NOT_ENOUGH_PLAYERS';
        }

        if (sessionInfo == null || players == null) {
            return 'BAD_STATE';
        }

        await this.sessionRepository.beginSession(sessionId);

        const playerIds = players.map((player) => player.player_id);
        await this.turnRepository.populateTurnsForSession(sessionId, playerIds, sessionInfo.session_round_count);

        const updatedSession = await this.getSession(sessionId);
        this.socketServer.to(sessionId).emit('session.state.update', updatedSession);

        await this._handleTurn(sessionId, sessionInfo.session_turn_duration);
    };

    putDrawing = async (turnId: string, drawing: any): Promise<void> => {
        await this.sessionRepository.putDrawing(turnId, drawing);
    };

    getDrawings = async (sessionId: string): Promise<DBDrawing[]> => {
        return await this.sessionRepository.getDrawings(sessionId);
    }

    _handleTurn = async (sessionId: string, turnDuration: number) => {
        const nextTurn: DBTurn | undefined = await this.turnRepository.getNextTurn(sessionId);
        // no more turns, game has ended
        if (nextTurn == null) {
            await this.sessionRepository.finishSession(sessionId);
            this.socketServer.to(sessionId).emit('session.finished');
            return;
        }
        if (this.gameLoop.has(sessionId)) this.gameLoop.delete(sessionId);
        this.socketServer.to(sessionId).emit('session.nextTurn', nextTurn);
        this.gameLoop.set(sessionId, setTimeout(async () => {
            await this.turnRepository.markTurnComplete(nextTurn.turn_id);
            // notify turn ended
            await this._handleTurn(sessionId, turnDuration);
        }, turnDuration * 1000));
    };
}