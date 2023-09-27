import { Request, Response } from 'express';
import { WordRepository } from '../repository/word.repository';

export class WordController {
    constructor(private repository: WordRepository) { }

    getWords = async (request: Request, response: Response) => {
        const words: string[] = await this.repository.getWords(request.query.type?.toString() ?? 'topic');
        return response.status(200).json(words);
    };
};