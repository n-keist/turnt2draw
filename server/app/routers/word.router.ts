import express, { Router } from 'express';
import { WordController } from '../controllers/word.controller';
import { WordService } from '../service/word.service';

export class WordRouter {
    router: Router;

    constructor(private service: WordService) {
        this.router = express.Router();
        const wordController = new WordController(this.service);

        this.router.get('/', wordController.getWords);
    }

};