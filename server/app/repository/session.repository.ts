import { DrawDatabase } from '../../database';
import { nanoid } from 'nanoid';

export class SessionRepository {
    constructor(private database: DrawDatabase) { }

    getSession = async (sessionId: string): Promise<DBSession | undefined> => {
        const rows: any[] = await this.database.pool.query(
            'SELECT * FROM sessions WHERE session_id = ?;',
            [sessionId],
        );
        if (rows.length === 0) return undefined;
        return rows[0];
    };

    findSession = async (sessionId: string): Promise<DBSession | undefined> => {
        const rows: any[] = await this.database.pool.query(
            'SELECT * FROM sessions WHERE session_id = ? AND session_end IS NULL AND session_state = ?;',
            [sessionId, 'waiting'],
        );
        if (rows.length === 0) return undefined;
        return rows[0];
    };

    findRandomSession = async (): Promise<DBSession | undefined> => {
        const rows: DBSession[] = await this.database.pool.query('select * from sessions where session_state = ? order by rand() limit 1', ['waiting']);
        if (rows.length == 0) return undefined;
        return rows[0];
    };

    createSession = async (config: CreateSessionConfig): Promise<string | undefined> => {
        try {
            const rows: any[] = await this.database.pool.query(
                'INSERT INTO sessions (session_id, session_owner, session_word, session_max_players, session_round_count, session_turn_duration) VALUES (?, ?, ?, ?, ?, ?) RETURNING session_id;',
                [config.id || nanoid(24), config.owner, config.word, config.maxPlayers, config.roundCount, config.turnDuration],
            );
            await this.database.pool.execute('INSERT INTO players (player_id, player_session, player_displayname) VALUES (?, ?, ?);', [config.owner, rows[0]['session_id'], config.ownerDisplayname]);
            return rows[0]['session_id'];
        } catch (error) {
            console.error(error);
            return undefined;
        }
    };

    setOwner = async (sessionId: string, playerId: string): Promise<void> => {
        await this.database.pool.execute('UPDATE sessions SET session_owner = ? WHERE session_id = ?;', [
            playerId, sessionId,
        ]);
    };

    joinSession = async (sessionId: string, playerId: string, playerDisplayname: string): Promise<boolean> => {
        try {
            const sessionQuery: DBSession[] = await this.database.pool.query(
                'SELECT * FROM sessions WHERE session_id = ?;',
                [sessionId]
            );
            if (sessionQuery.length === 0) return false;

            const playerCountQuery: any[] = await this.database.pool.query(
                'SELECT COUNT(*) AS player_count FROM players WHERE player_session = ?;',
                [sessionId],
            );
            const count = playerCountQuery[0].player_count;

            if (count >= sessionQuery[0].session_max_players) return false;

            await this.database.pool.execute('INSERT INTO players (player_id, player_session, player_displayname) VALUES (?, ?, ?);', [playerId, sessionId, playerDisplayname]);
            return true;
        } catch (error) {
            console.error(error);
            return false;
        }
    };

    leaveSession = async (sessionId: string, playerId: string) => {
        await this.database.pool.execute('DELETE FROM players WHERE player_id = ? AND player_session = ?;', [
            playerId, sessionId,
        ]);
    };

    beginSession = async (sessionId: string) => {
        await this.database.pool.execute('UPDATE sessions SET session_state = ? WHERE session_id = ?;', [
            'drawing', sessionId
        ]);
    };

    finishSession = async (sessionId: string) => {
        await this.database.pool.execute('UPDATE sessions SET session_state = ? WHERE session_id = ?;', [
            'ended', sessionId
        ]);
    };

    putDrawing = async (turnId: string, drawing: any) => {
        console.log(drawing);
        await this.database.pool.execute('INSERT INTO `drawables` (drawable_turn, drawable_value) VALUES (?, ?);', [
            turnId, JSON.stringify(drawing),
        ]);
    };

    getDrawings = async (sessionId: string): Promise<DBDrawing[]> => {
        const rows = await this.database.pool.query('SELECT*FROM drawables WHERE drawable_turn in(SELECT turn_id FROM turns WHERE turn_session=?)', [
            sessionId,
        ]);
        console.log(rows.length);
        return rows;
    };
};