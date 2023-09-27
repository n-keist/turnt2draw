import { Pool, createPool } from 'mariadb';

export class DrawDatabase {

    pool: Pool;

    constructor() {
        this.pool = createPool({
            host: process.env.DB_HOST || 'localhost',
            port: parseInt(process.env.DB_PORT || '3306'),
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || 'example',
            database: process.env.DB_NAME || 'drawapp',
            connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT || '5'),
        });
    }


};