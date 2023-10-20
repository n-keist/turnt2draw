import { make } from 'simple-body-validator';

export default (data: any) => make(data, {
    'id': 'sometimes|string|size:24',
    'word': 'sometimes|string',
    'maxPlayers': 'integer|required|max:99|min:2',
    'roundCount': 'integer|required|max:99|min:2',
    'turnDuration': 'integer|required|max:120|min:10',
    'owner': 'string|required|size:24'
});