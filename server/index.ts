import { DrawDatabase } from './database';
import { DrawServer } from './server';

import setup_task from './task_populate_db';

const database: DrawDatabase = new DrawDatabase();
const server: DrawServer = new DrawServer(database);

const file = Bun.file('.setup');
if (!(await file.exists())) {
    const schemaFile = Bun.file('schema.sql');
    const text = (await schemaFile.text()).replaceAll('\n', '');

    text.split(';').forEach(async (query) => await database.pool.execute(query, []));

    await setup_task.getAdjectives(database);
    await setup_task.getNouns(database);
    await setup_task.getTopics(database);

    await Bun.write(file, 'yes indeed.');
    console.log('initial setup completed.');
}


server.server.listen(process.env.PORT || 3000, () => {
    console.log(`Server is running on port ${process.env.PORT || 3000}`);
});