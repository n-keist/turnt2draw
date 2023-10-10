import { make } from 'simple-body-validator';

export default (data: any) => make(data, {
    'player_id': 'required|string|max:24',
    'player_session': 'sometimes|string|max:24',
    'player_displayname': 'string|required',
    'player_icon': 'string|required'
});