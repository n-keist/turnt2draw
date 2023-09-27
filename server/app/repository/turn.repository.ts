import { nanoid } from 'nanoid';
import { DrawDatabase } from '../../database';

export class TurnRepository {
    constructor(private database: DrawDatabase) { }

    getNextTurn = async (sessionId: string): Promise<DBTurn | undefined> => {
        try {
            const rows: DBTurn[] = await this.database.pool.query(
                'select * from turns where turn_session = ? AND turn_ended is null order by turn_overall asc limit 0,1;',
                [sessionId],
            );
            if (rows.length > 0) return rows.at(0);
        } catch (error) {
            console.error(error);
        }
        return undefined;
    };

    populateTurnsForSession = async (sessionId: string, players: string[], turnCount: number): Promise<void> => {
        let overallTurn = 1;
        for (let i = 0; i < turnCount; i++) {
            for (const player of players) {
                await this.database.pool.execute('INSERT INTO turns (turn_id, turn_session, turn_player, turn_overall) VALUES (?, ?, ?, ?);', [
                    nanoid(24), sessionId, player, overallTurn,
                ]);
                overallTurn += 1;
            }
        }
    };

    markTurnComplete = async (turnId: string): Promise<void> => {
        await this.database.pool.execute('UPDATE turns SET turn_ended = NOW() WHERE turn_id = ?;', [turnId]);
    };
}