import { DrawDatabase } from '../../database';
import { WordRepository } from '../repository/word.repository';

export class WordService {

    private _wordRepository: WordRepository;

    constructor(private database: DrawDatabase) {
        this._wordRepository = new WordRepository(this.database);
    }

    getWordRepository = (): WordRepository => this._wordRepository;
};