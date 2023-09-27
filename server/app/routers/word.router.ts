import express, { Router } from 'express';
import { WordController } from '../controllers/word.controller';
import { DrawDatabase } from '../../database';
import { WordRepository } from '../repository/word.repository';

export class WordRouter {
    router: Router;

    constructor(private database: DrawDatabase) {
        this.router = express.Router();
        const wordRepository = new WordRepository(database);
        const wordController = new WordController(wordRepository);

        this.router.get('/word', wordController.getWords);
    }

};