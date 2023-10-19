CREATE TABLE `sessions` (
  `session_id` varchar(24) NOT NULL,
  `session_code` varchar(5) NOT NULL,
  `session_start` datetime NOT NULL DEFAULT current_timestamp(),
  `session_state` enum('waiting','drawing','ended') NOT NULL DEFAULT 'waiting',
  `session_word` varchar(64) DEFAULT NULL,
  `session_max_players` int(2) NOT NULL DEFAULT 5,
  `session_round_count` int(2) NOT NULL DEFAULT 5,
  `session_turn_duration` int(2) NOT NULL DEFAULT 30,
  `session_owner` varchar(64) NOT NULL,
  `session_end` datetime DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  KEY `sessions_session_start_idx` (`session_start`) USING BTREE,
  KEY `sessions_session_end_idx` (`session_end`) USING BTREE,
  KEY `sessions_session_owner_idx` (`session_owner`) USING BTREE
);

CREATE TABLE `players` (
  `player_id` varchar(24) NOT NULL,
  `player_session` varchar(24) NOT NULL,
  `player_displayname` varchar(32) NOT NULL,
  `player_icon` varchar(32) NOT NULL DEFAULT '🩵',
  PRIMARY KEY (`player_id`,`player_session`),
  KEY `player_session` (`player_session`),
  CONSTRAINT `players_ibfk_1` FOREIGN KEY (`player_session`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE
);

CREATE TABLE `drawables` (
  `drawable_turn` varchar(24) NOT NULL,
  `drawable_value` longtext DEFAULT NULL,
  `drawable_timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  KEY `drawables_drawable_timestamp_idx` (`drawable_timestamp`) USING BTREE,
  KEY `drawables_drawable_turn_idx` (`drawable_turn`) USING BTREE
);


CREATE TABLE `turns` (
  `turn_id` varchar(24) NOT NULL,
  `turn_session` varchar(24) NOT NULL,
  `turn_player` varchar(24) NOT NULL,
  `turn_overall` int(11) NOT NULL,
  `turn_skipped` datetime DEFAULT NULL,
  `turn_ended` datetime DEFAULT NULL,
  PRIMARY KEY (`turn_id`),
  KEY `turn_session` (`turn_session`),
  CONSTRAINT `turns_ibfk_1` FOREIGN KEY (`turn_session`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE
);

CREATE TABLE `words` (
  `word_id` varchar(24) NOT NULL,
  `word_value` varchar(64) NOT NULL,
  `word_type` enum('adj','noun','topic') DEFAULT NULL,
  `word_added` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`word_id`),
  KEY `words_word_added_idx` (`word_added`) USING BTREE,
  KEY `words_word_type_idx` (`word_type`) USING BTREE
);