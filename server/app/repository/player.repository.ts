import { DrawDatabase } from '../../database';

export class PlayerRepository {
    constructor(private database: DrawDatabase) { }

    getPlayersBySession = async (sessionId: string): Promise<Player[]> => {
        const rows: Player[] = await this.database.pool.query('SELECT * FROM players WHERE player_session = ?;', [sessionId]);
        return rows;
    }
}