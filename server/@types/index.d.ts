interface CreateSessionConfig {
    id?: string;
    word?: string;
    maxPlayers: number;
    roundCount: number;
    turnDuration: number;
    owner: string;
    ownerDisplayname: string;
}

interface Player {
    player_id: string;
    player_session: string;
    player_displayname: string;
    player_icon: string;
}

interface DBPlayer {
    player_id: string;
    player_session: string;
    player_displayname: string;
}

interface DBSession {
    session_id: string;
    session_start: Date;
    session_state: string;
    session_word?: string;
    session_max_players: number;
    session_round_count: number;
    session_turn_duration: number;
    session_owner: string;
    session_end?: Date;
}

interface DBTurn {
    turn_id: string;
    turn_session: string;
    turn_player: string;
    turn_skipped?: boolean;
    turn_ended?: Date;
}

interface DBDrawing {
    drawable_turnId: string;
    drawable_value: string;
    drawable_timestamp: Date;
}