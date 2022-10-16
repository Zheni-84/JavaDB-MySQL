DROP DATABASE IF EXISTS fsd;
CREATE DATABASE fsd;
USE fsd;

-- 01. Table Design

CREATE TABLE countries
(
    id     INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(45) NOT NULL
);


CREATE TABLE towns
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    `name`     VARCHAR(45) NOT NULL,
    country_id INT         NOT NULL,
    CONSTRAINT fk_town_country
        FOREIGN KEY (country_id)
            REFERENCES countries (id)
);

CREATE TABLE skills_data
(
    id        INT PRIMARY KEY AUTO_INCREMENT,
    dribbling INT DEFAULT 0,
    pace      INT DEFAULT 0,
    passing   INT DEFAULT 0,
    shooting  INT DEFAULT 0,
    speed     INT DEFAULT 0,
    strength  INT DEFAULT 0
);

CREATE TABLE stadiums
(
    id       INT PRIMARY KEY AUTO_INCREMENT,
    `name`   VARCHAR(45) NOT NULL,
    capacity INT         NOT NULL,
    town_id  INT         NOT NULL,
    CONSTRAINT fk_stadium_town
        FOREIGN KEY (town_id)
            REFERENCES towns (id)
);

CREATE TABLE teams
(
    id          INT PRIMARY KEY AUTO_INCREMENT,
    `name`      VARCHAR(45) NOT NULL,
    established DATE        NOT NULL,
    fan_base    BIGINT(20)  NOT NULL DEFAULT 0,
    stadium_id  INT         NOT NULL,
    CONSTRAINT fk_team_stadium
        FOREIGN KEY (stadium_id)
            REFERENCES stadiums (id)
);

CREATE TABLE coaches
(
    id          INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(10)    NOT NULL,
    last_name   VARCHAR(20)    NOT NULL,
    salary      DECIMAL(10, 2) NOT NULL DEFAULT 0,
    coach_level INT            NOT NULL DEFAULT 0
);

CREATE TABLE players
(
    id             INT PRIMARY KEY AUTO_INCREMENT,
    first_name     VARCHAR(10)    NOT NULL,
    last_name      VARCHAR(20)    NOT NULL,
    age            INT            NOT NULL,
    position       CHAR(1)        NOT NULL,
    salary         DECIMAL(10, 2) NOT NULL DEFAULT 0,
    hire_date      DATETIME,
    skills_data_id INT            NOT NULL,
    team_id        INT,
    CONSTRAINT fk_player_skill
        FOREIGN KEY (skills_data_id)
            REFERENCES skills_data (id),
    CONSTRAINT fk_player_team
        FOREIGN KEY (team_id)
            REFERENCES teams (id)
);

CREATE TABLE players_coaches
(
    player_id INT NOT NULL,
    coach_id  INT NOT NULL,
    PRIMARY KEY (player_id, coach_id),
    CONSTRAINT fk_player_coaches
        FOREIGN KEY (coach_id)
            REFERENCES coaches (id),
    CONSTRAINT fk_coach_players
        FOREIGN KEY (player_id)
            REFERENCES players (id)
);

-- 02. Insert
INSERT INTO coaches(first_name, last_name, salary, coach_level)
SELECT first_name, last_name, salary, char_length(first_name) as coach_level
FROM players
WHERE age >= 45;

-- 03. Update
UPDATE coaches c
    JOIN players_coaches pc ON pc.coach_id = c.id -- train at least one player
SET c.coach_level = c.coach_level + 1
-- WHERE LEFT(c.first_name, 1) = 'A';
WHERE c.first_name LIKE 'A%';

-- 04. Delete
DELETE
FROM players
WHERE age >= 45;

-- 05. Players
SELECT first_name, age, salary
FROM players
ORDER BY salary DESC;

-- 06. Young offense players without contract
SELECT p.id,
       CONCAT_WS(' ', first_name, last_name) AS full_name,
       age,
       position,
       hire_date
FROM players p
         JOIN skills_data sd ON sd.id = p.skills_data_id
WHERE age < 23
  AND position = 'A'
  AND hire_date IS NULL
  AND sd.strength > 50
ORDER BY p.salary, p.age;

-- 07. Detail info for all teams
SELECT t.name AS   team_name,
       t.established,
       t.fan_base,
       COUNT(p.id) count_of_players
FROM teams t
         LEFT JOIN players p ON p.team_id = t.id
GROUP BY team_name, t.established, t.fan_base
ORDER BY count_of_players DESC, t.fan_base DESC;

-- 08. The fastest player by towns
SELECT MAX(sd.speed) max_speed,
       t.name        town_name
FROM towns t
         LEFT JOIN stadiums s ON s.town_id = t.id
         LEFT JOIN teams te ON te.stadium_id = s.id
         LEFT JOIN players p ON p.team_id = te.id
         LEFT JOIN skills_data sd ON p.skills_data_id = sd.id
WHERE te.`name` <> 'Devify'
GROUP BY town_name
ORDER BY max_speed DESC, town_name;

-- 09. Total salaries and players by country
SELECT c.`name`,
       COUNT(p.id)   total_count_of_players,
       SUM(p.salary) total_sum_of_salaries
FROM countries c
         LEFT JOIN towns t ON t.country_id = c.id
         LEFT JOIN stadiums s ON s.town_id = t.id
         LEFT JOIN teams te ON te.stadium_id = s.id
         LEFT JOIN players p ON p.team_id = te.id
GROUP BY c.`name`
ORDER BY total_count_of_players DESC, c.`name`;

-- 10. Find all players that play on stadium
DROP function IF EXISTS `udf_stadium_players_count`;

DELIMITER $$
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
    RETURNS INTEGER
    DETERMINISTIC
BEGIN
    RETURN (SELECT COUNT(p.id)
            FROM stadiums as s
                     LEFT JOIN teams as te ON te.stadium_id = s.id
                     LEFT JOIN players as p ON p.team_id = te.id
            WHERE s.`name` = stadium_name);
END$$
DELIMITER ;
SELECT udf_stadium_players_count('Jaxworks') as `count`;
SELECT udf_stadium_players_count('Linklinks') as `count`;

-- 11. Find good playmaker by teams
DROP procedure IF EXISTS `udp_find_playmaker`;

DELIMITER $$
CREATE PROCEDURE `udp_find_playmaker`(min_dribble_points INT, team_name VARCHAR(45))
BEGIN
    SELECT CONCAT_WS(' ', first_name, last_name) full_name,
           p.age,
           p.salary,
           sd.dribbling,
           sd.speed,
           t.`name`                              team_name
    FROM players as p
             JOIN skills_data sd ON p.skills_data_id = sd.id
             JOIN teams t ON p.team_id = t.id
    WHERE t.`name` = team_name
      AND sd.dribbling > min_dribble_points
      AND sd.speed > (SELECT AVG(speed)
                      FROM skills_data)
    ORDER BY sd.speed DESC
    LIMIT 1;
END$$

DELIMITER ;
CALL udp_find_playmaker(33, 'Skyble');