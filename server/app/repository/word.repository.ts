import { DrawDatabase } from '../../database';

export class WordRepository {
    constructor(private database: DrawDatabase) { }

    getWords = async (type: string = 'topic'): Promise<string[]> => {
        const rows: any[] = await this.database.pool.query(
            'SELECT * FROM words where word_type = ? ORDER BY word_added ASC;',
            [type],
        );
        return rows.map((row: any) => row['word_value']);
    };
};