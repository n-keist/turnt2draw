import { Request, Response } from 'express';
import { WordService } from '../service/word.service';

export class WordController {
    constructor(private service: WordService) { }

    getWords = async (request: Request, response: Response) => {
        const { type } = request.query;
        const words: string[] = await this.service.getWordRepository().getWords(type?.toString() ?? 'topic');
        return response.status(200).json(words);
    };
};