
# turn2draw

A turn based mobile drawing game, written in Flutter.
Backend is written in TypeScript and run by Bun!


### Video Demo:
[![Video Demo](http://img.youtube.com/vi/MJphHHy8tWo/0.jpg)](https://www.youtube.com/watch?v=MJphHHy8tWo "Video Title")

## Run Locally

Clone the project

```bash
  git clone https://github.com/n-keist/turnt2draw
```

Go to the project directory

```bash
  cd turnt2draw
```

### Run & Configure Database

A docker-compose file is included in the project, but it can also be run on a separate MySQL Server.

Launch Docker-Compose SQL Server

```bash
  docker-compose up
```

### Run & Configure Server

In case you need to change the port which the server is running on, check the `.env` file.

Install server dependencies

```bash
  cd server && bun install
```

Start the server

```bash
  bun run index.ts
```


**server environment variables**

|Variable Name| Default Value |
|-------------|---------------|
|`TOKEN`|`TEST_TOKEN`|
|`PORT`|`3000`|
|`DB_HOST`|`localhost`|
|`DB_PORT`|`3306`|
|`DB_USER`|`root`|
|`DB_PASSWORD`|`example`|
|`DB_NAME`|`drawapp`|
|`DB_CONNECTION_LIMIT`|`5`|

### Run the app itself

Install app dependencies

```bash
  cd turn2draw && flutter pub get
```

running

```bash
  flutter run
```


**client environment variables**

|Variable Name| Default Value |
|-------------|---------------|
|`BASE_URL`|`http://localhost:3000/`|
|`TOKEN`|`TEST_TOKEN`|


**make sure client and server token match!**
