SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


CREATE TABLE `admins` (
  `adminid` char(23) NOT NULL DEFAULT 'uuid_short();',
  `userid` char(23) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `superadmin` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `app_config` (
  `setting` char(26) NOT NULL,
  `value` varchar(12000) NOT NULL,
  `sortorder` int(5) DEFAULT NULL,
  `category` varchar(25) NOT NULL,
  `type` varchar(15) NOT NULL,
  `description` varchar(140) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cookies` (
  `cookieid` char(23) NOT NULL,
  `userid` char(23) NOT NULL,
  `tokenid` char(25) NOT NULL,
  `expired` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `deleted_members` (
  `id` char(23) NOT NULL,
  `username` varchar(65) NOT NULL DEFAULT '',
  `password` varchar(65) NOT NULL DEFAULT '',
  `email` varchar(65) NOT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  `admin` tinyint(1) NOT NULL DEFAULT 0,
  `mod_timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `files` (
  `id` int(11) NOT NULL,
  `name` varchar(535) NOT NULL,
  `filename` varchar(535) NOT NULL,
  `hash` varchar(535) NOT NULL,
  `coins` int(11) DEFAULT NULL,
  `upvotes` int(11) NOT NULL,
  `downvotes` int(11) NOT NULL,
  `downloads` int(11) NOT NULL,
  `downloaders` mediumtext NOT NULL,
  `username` varchar(535) NOT NULL,
  `userid` char(23) NOT NULL,
  `date` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `login_attempts` (
  `ID` int(11) NOT NULL,
  `Username` varchar(65) DEFAULT NULL,
  `IP` varchar(20) NOT NULL,
  `Attempts` int(11) NOT NULL,
  `LastLogin` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mail_log` (
  `id` int(11) NOT NULL,
  `type` varchar(45) NOT NULL DEFAULT 'generic',
  `status` varchar(45) DEFAULT NULL,
  `recipient` varchar(5000) DEFAULT NULL,
  `response` mediumtext NOT NULL,
  `isread` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `members` (
  `id` char(23) NOT NULL,
  `username` varchar(65) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(65) NOT NULL DEFAULT '',
  `coins` int(11) NOT NULL,
  `downloads` int(10) NOT NULL,
  `shared` int(11) NOT NULL,
  `banned` int(1) NOT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  `admin` tinyint(1) NOT NULL DEFAULT 0,
  `beta` int(1) NOT NULL,
  `mod_timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER $$
CREATE TRIGGER `add_admin` AFTER INSERT ON `members` FOR EACH ROW BEGIN IF (NEW.admin = 1) THEN  INSERT INTO admins (adminid, userid, active, superadmin ) VALUES (uuid_short(), NEW.id, 1, 0 ); END IF; END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `add_admin_beforeUpdate` BEFORE UPDATE ON `members` FOR EACH ROW BEGIN set @s = (SELECT superadmin from admins where userid = NEW.id); set @a = (SELECT adminid from admins where userid = NEW.id); IF (NEW.admin = 1 && isnull(@a)) THEN INSERT INTO admins ( adminid, userid, active, superadmin ) VALUES ( uuid_short(), NEW.id, 1, 0 ); ELSEIF (NEW.admin = 0) THEN IF (@s = 0) THEN DELETE FROM admins WHERE userid = NEW.id and superadmin = 0; ELSEIF (@s = 1) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cannot delete superadmin'; END IF; END IF; END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `move_to_deleted_members` AFTER DELETE ON `members` FOR EACH ROW BEGIN DELETE FROM deleted_members WHERE deleted_members.id = OLD.id; UPDATE admins SET active = '0' where admins.userid = OLD.id;  INSERT INTO deleted_members ( id, username, password, email, verified, admin) VALUES ( OLD.id, OLD.username, OLD.password, OLD.email, OLD.verified, OLD.admin ); END
$$
DELIMITER ;


CREATE TABLE `member_info` (
  `userid` char(23) NOT NULL,
  `firstname` varchar(45) NOT NULL,
  `lastname` varchar(55) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address1` varchar(45) DEFAULT NULL,
  `address2` varchar(45) DEFAULT NULL,
  `city` varchar(45) DEFAULT NULL,
  `state` varchar(30) DEFAULT NULL,
  `country` varchar(45) DEFAULT NULL,
  `bio` varchar(20000) DEFAULT NULL,
  `userimage` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `regcodes` (
  `id` int(11) NOT NULL,
  `code` varchar(535) NOT NULL,
  `uses` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `tokens` (
  `tokenid` char(25) NOT NULL,
  `userid` char(23) NOT NULL,
  `expired` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `votes` (
  `id` int(255) NOT NULL,
  `username` varchar(256) NOT NULL,
  `fileid` int(255) NOT NULL,
  `vote` varchar(256) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


ALTER TABLE `admins`
  ADD PRIMARY KEY (`adminid`,`userid`),
  ADD UNIQUE KEY `adminid_UNIQUE` (`adminid`),
  ADD UNIQUE KEY `userid_UNIQUE` (`userid`);


ALTER TABLE `app_config`
  ADD PRIMARY KEY (`setting`),
  ADD UNIQUE KEY `setting_UNIQUE` (`setting`);


ALTER TABLE `cookies`
  ADD PRIMARY KEY (`userid`);

ALTER TABLE `deleted_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id_UNIQUE` (`id`);

ALTER TABLE `files`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`ID`);

ALTER TABLE `mail_log`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username_UNIQUE` (`username`),
  ADD UNIQUE KEY `id_UNIQUE` (`id`),
  ADD UNIQUE KEY `email_UNIQUE` (`email`);

ALTER TABLE `member_info`
  ADD UNIQUE KEY `userid_UNIQUE` (`userid`),
  ADD KEY `fk_userid_idx` (`userid`);

ALTER TABLE `regcodes`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tokens`
  ADD PRIMARY KEY (`tokenid`),
  ADD UNIQUE KEY `tokenid_UNIQUE` (`tokenid`),
  ADD UNIQUE KEY `userid_UNIQUE` (`userid`);

ALTER TABLE `votes`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `files`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

ALTER TABLE `login_attempts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=160;

ALTER TABLE `mail_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=198;

ALTER TABLE `regcodes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `votes`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

ALTER TABLE `admins`
  ADD CONSTRAINT `fk_userid_admins` FOREIGN KEY (`userid`) REFERENCES `members` (`id`) ON UPDATE CASCADE;

ALTER TABLE `cookies`
  ADD CONSTRAINT `userid` FOREIGN KEY (`userid`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `member_info`
  ADD CONSTRAINT `fk_userid` FOREIGN KEY (`userid`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `tokens`
  ADD CONSTRAINT `userid_t` FOREIGN KEY (`userid`) REFERENCES `members` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
