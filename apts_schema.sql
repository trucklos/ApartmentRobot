CREATE TABLE `apts` (
  `title` varchar(764) NOT NULL,
  `url` varchar(1024) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `bd` tinyint(4) DEFAULT NULL,
  `time_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `price` (`price`,`title`,`bd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
