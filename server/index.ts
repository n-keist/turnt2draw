import { DrawDatabase } from './database';
import { DrawServer } from './server';

const database: DrawDatabase = new DrawDatabase();
const server: DrawServer = new DrawServer(database);

server.server.listen(process.env.PORT || 3000, () => {
    console.log(`Server is running on port ${process.env.PORT || 3000}`);
});