import { DrawDatabase } from '../../database';
import { PlayerRepository } from '../repository/player.repository';
import { SessionRepository } from '../repository/session.repository';
import { TurnRepository } from '../repository/turn.repository';
import { Server as SocketServer } from 'socket.io';

export class SessionService {

    private gameLoop: Map<string, any>;

    private _sessionRepository: SessionRepository;
    private _playerRepository: PlayerRepository;
    private _turnRepository: TurnRepository;

    constructor(private database: DrawDatabase, private socketServer: SocketServer) {
        this.gameLoop = new Map();
        this._sessionRepository = new SessionRepository(this.database);
        this._playerRepository = new PlayerRepository(this.database);
        this._turnRepository = new TurnRepository(this.database);
    }

    getSessionRepository = (): SessionRepository => this._sessionRepository;
    getPlayerRepository = (): PlayerRepository => this._playerRepository;
    getTurnRepository = (): TurnRepository => this._turnRepository;

    getSession = async (sessionId: string): Promise<DBSession | undefined> => {
        const session = await this.getSessionRepository().getSession(sessionId);
        return session;
    };

    getPlayers = (sessionId: string): Promise<Player[]> => {
        return this.getPlayerRepository().getPlayersBySession(sessionId);
    };

    joinRandomSession = async (player: Player): Promise<string | undefined> => {
        const session = await this.getSessionRepository().findRandomSession();

        if (!session) return undefined;

        if (!player.player_session) player.player_session = session.session_id;

        const joined = await this.getSessionRepository().joinSession(player);
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

        await this.getSessionRepository().beginSession(sessionId);

        const playerIds = players.map((player) => player.player_id);
        await this.getTurnRepository().populateTurnsForSession(sessionId, playerIds, sessionInfo.session_round_count);

        const updatedSession = await this.getSession(sessionId);
        this.socketServer.to(sessionId).emit('session.state.update', updatedSession);

        await this._handleTurn(sessionId, sessionInfo.session_turn_duration);
    };

    putDrawing = async (turnId: string, drawing: any): Promise<void> => {
        await this.getSessionRepository().putDrawing(turnId, drawing);
    };

    getDrawings = async (sessionId: string): Promise<DBDrawing[]> => {
        return await this.getSessionRepository().getDrawings(sessionId);
    }

    _handleTurn = async (sessionId: string, turnDuration: number) => {
        const nextTurn: DBTurn | undefined = await this.getTurnRepository().getNextTurn(sessionId);
        // no more turns, game has ended
        if (nextTurn == null) return this._disposeSession(sessionId);
        if (this.gameLoop.has(sessionId)) this.gameLoop.delete(sessionId);
        this.socketServer.to(sessionId).emit('session.nextTurn', nextTurn);
        this.gameLoop.set(sessionId, setTimeout(async () => {
            await this.getTurnRepository().markTurnComplete(nextTurn.turn_id);
            // notify turn ended
            await this._handleTurn(sessionId, turnDuration);
        }, turnDuration * 1000));
    };

    _disposeSession = async (sessionId: string) => {
        const session = this.gameLoop.get(sessionId);
        if (!session) return;
        await this.getSessionRepository().finishSession(sessionId);
        this.socketServer.to(sessionId).emit('session.finished');
        this.gameLoop.delete(sessionId);
    };
}