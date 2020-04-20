ALTER TABLE `items` CHANGE COLUMN `weight` `weight` FLOAT NOT NULL DEFAULT 1;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('coke', 'Coke', 0.01, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('coke_pooch', 'Coke Bundel', 0.05, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('opium', 'Opium', 0.01, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('opium_pooch', 'Opium Bundel', 0.05, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('weed', 'Wiet', 0.01, 0, 1);
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('weed_pooch', 'Wiet Bundel', 0.05, 0, 1);