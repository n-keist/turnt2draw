import { nanoid } from 'nanoid';
import { DrawDatabase } from './database';

// this is a list of topics generated by chatgpt
import { topics } from './topics';

const getAdjectives = async (database: DrawDatabase) => {
    const response = await fetch('https://raw.githubusercontent.com/dariusk/corpora/master/data/words/adjs.json');
    const result: any = await response.json();
    const adjectives = result.adjs;
    const adjectivesToDb = adjectives.map((adj: string) => [nanoid(24), adj.toLowerCase(), 'adj']);
    await database.pool.execute('DELETE FROM words WHERE word_type = "adj";');
    for (const adj of adjectivesToDb) {
        await database.pool.execute(
            'INSERT INTO words (word_id, word_value, word_type) VALUES (?, ?, ?);',
            adj,
        );
    }
};

const getNouns = async (database: DrawDatabase) => {
    const response = await fetch('https://raw.githubusercontent.com/dariusk/corpora/master/data/words/nouns.json');
    const result: any = await response.json();
    const adjectives = result.nouns;
    const adjectivesToDb = adjectives.map((noun: string) => [nanoid(24), noun.toLowerCase(), 'noun']);
    await database.pool.execute('DELETE FROM words WHERE word_type = "noun";');
    for (const adj of adjectivesToDb) {
        await database.pool.execute(
            'INSERT INTO words (word_id, word_value, word_type) VALUES (?, ?, ?);',
            adj,
        );
    }
};

const getTopics = async (database: DrawDatabase) => {
    await database.pool.execute('DELETE FROM words WHERE word_type = "topic";');
    for (const topic of topics.topics) {
        await database.pool.execute(
            'INSERT INTO words (word_id, word_value, word_type) VALUES (?, ?, ?);',
            [nanoid(24), topic, 'topic'],
        );
    }
};

export default { getTopics, getNouns, getAdjectives };