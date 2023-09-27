-- -------------------------------------------------------------
-- TablePlus 5.4.0(505)
--
-- https://tableplus.com/
--
-- Database: drawapp
-- Generation Time: 2023-09-18 16:16:28.4110
-- -------------------------------------------------------------


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


CREATE TABLE `drawables` (
  `drawable_id` varchar(24) NOT NULL,
  `drawable_session_id` varchar(24) NOT NULL,
  `drawable_type` enum('freestyle','erase','fill') NOT NULL,
  `drawable_user` varchar(64) NOT NULL,
  `drawable_value` longblob DEFAULT NULL,
  `drawable_timestamp` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`drawable_id`,`drawable_session_id`),
  KEY `drawables_drawable_timestamp_idx` (`drawable_timestamp`) USING BTREE,
  KEY `drawables_drawable_type_idx` (`drawable_type`) USING BTREE,
  KEY `drawables_drawable_session_id_idx` (`drawable_session_id`) USING BTREE,
  CONSTRAINT `drawables_ibfk_1` FOREIGN KEY (`drawable_session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `players` (
  `player_id` varchar(24) NOT NULL,
  `player_session` varchar(24) NOT NULL,
  `player_displayname` varchar(32) NOT NULL,
  PRIMARY KEY (`player_id`,`player_session`),
  KEY `player_session` (`player_session`),
  CONSTRAINT `players_ibfk_1` FOREIGN KEY (`player_session`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `sessions` (
  `session_id` varchar(24) NOT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `words` (
  `word_id` varchar(24) NOT NULL,
  `word_value` varchar(64) NOT NULL,
  `word_type` enum('adj','noun','topic') DEFAULT NULL,
  `word_added` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`word_id`),
  KEY `words_word_added_idx` (`word_added`) USING BTREE,
  KEY `words_word_type_idx` (`word_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;