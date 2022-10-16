CREATE DATABASE softuni_imdb;
USE softuni_imdb;

-- 1. Table Design
CREATE TABLE countries
(
    id        INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(30) NOT NULL UNIQUE,
    continent VARCHAR(30) NOT NULL,
    currency  VARCHAR(5)  NOT NULL
);

CREATE TABLE genres
(
    id   INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE actors
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    birthdate  DATE        NOT NULL,
    height     INT,
    awards     INT,
    country_id INT         NOT NULL,
    CONSTRAINT fk_actors_countries FOREIGN KEY (country_id) REFERENCES countries (id)
);

CREATE TABLE movies_additional_info
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    rating        DEC(10, 2)  NOT NULL,
    runtime       INT         NOT NULL,
    picture_url   VARCHAR(80) NOT NULL,
    budget        DEC(10, 2),
    release_date  DATE        NOT NULL,
    has_subtitles TINYINT(1),
    description   TEXT
);

CREATE TABLE movies
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(70) NOT NULL UNIQUE,
    country_id    INT         NOT NULL,
    movie_info_id INT         NOT NULL UNIQUE,
    CONSTRAINT fk_movies_countries
        FOREIGN KEY (country_id) REFERENCES countries (id),
    CONSTRAINT fk_movies_movie_info
        FOREIGN KEY (movie_info_id) REFERENCES movies_additional_info (id)
);

CREATE TABLE movies_actors
(
    movie_id INT,
    actor_id INT,
    KEY pk_movies_actors (movie_id, actor_id),
    CONSTRAINT fk_movie_actors_movies
        FOREIGN KEY (movie_id) REFERENCES movies (id),
    CONSTRAINT fk_movie_actors_actors
        FOREIGN KEY (actor_id) REFERENCES actors (id)
);

CREATE TABLE genres_movies
(
    genre_id INT,
    movie_id INT,
    KEY pk_genres_movies (genre_id, movie_id),
    CONSTRAINT fk_genre_movie_movies
        FOREIGN KEY (movie_id) REFERENCES movies (id),
    CONSTRAINT fk_genre_movie_genres
        FOREIGN KEY (genre_id) REFERENCES genres (id)
);

-- 02.	Insert
INSERT INTO actors (first_name, last_name, birthdate, height, awards, country_id)
SELECT REVERSE(first_name),
       REVERSE(last_name),
       DATE_SUB(birthdate, INTERVAL 2 DAY),
       height + 10,
       country_id,
       3
FROM actors
WHERE id <= 10;

-- 3. UPDATE
UPDATE movies_additional_info
SET runtime = runtime - 10
WHERE id BETWEEN 15 AND 25;

-- 3. Delete
DELETE c
FROM countries c
         LEFT JOIN movies m on c.id = m.country_id
WHERE m.country_id IS NULL;

-- v2
DELETE
FROM countries
WHERE id NOT IN (SELECT country_id FROM movies);

-- 05. Countries
SELECT *
FROM countries
ORDER BY currency DESC, id;

-- 06.	Old movies
SELECT m.id, m.title, mai.runtime, mai.budget, mai.release_date
FROM movies m
         JOIN movies_additional_info mai on mai.id = m.movie_info_id
WHERE YEAR(mai.release_date) BETWEEN 1996 AND 1999
ORDER BY mai.runtime, m.id
LIMIT 20;

-- 07.	Movie casting
SELECT CONCAT(first_name, ' ', last_name),
       CONCAT(REVERSE(last_name), LENGTH(last_name), '@cast.com') `email`,
       2022 - YEAR(birthdate) as                                  `age`,
       height
FROM actors
WHERE id NOT IN (SELECT actor_id FROM movies_actors)
ORDER BY height;

-- 08.	International festival
SELECT c.name, COUNT(m.id)
FROM countries c
         JOIN movies m on c.id = m.country_id
GROUP BY c.name
HAVING COUNT(m.id) >= 7
ORDER BY c.name DESC;

-- 09. Rating system
SELECT m.title,
       (CASE
            WHEN mai.rating <= 4 THEN 'poor'
            WHEN mai.rating <= 7 THEN 'good'
            ELSE 'excellent'
           END) as                               `rating`,
       IF(mai.has_subtitles = 1, 'english', '-') `subtitles`,
       mai.budget
FROM movies m
         JOIN movies_additional_info mai on mai.id = m.movie_info_id
ORDER BY mai.budget DESC;

-- 10.	History movies
DROP FUNCTION udf_actor_history_movies_count;
DELIMITER $$
CREATE FUNCTION udf_actor_history_movies_count(full_name VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE history_movies_count INT;
    SET history_movies_count := (SELECT COUNT(*)
                                 FROM actors a
                                          JOIN movies_actors ma on a.id = ma.actor_id
                                          JOIN genres_movies gm on ma.movie_id = gm.movie_id
                                          JOIN genres g on g.id = gm.genre_id
                                 WHERE g.name = 'History'
                                   AND CONCAT(a.first_name, ' ', a.last_name) = full_name);
    RETURN history_movies_count;
END$$

SELECT udf_actor_history_movies_count('Stephan Lundberg') AS 'history_movies';
SELECT udf_actor_history_movies_count('Jared Di Batista') AS 'history_movies';

-- 11.	Movie awards
CREATE PROCEDURE udp_award_movie(movie_title VARCHAR(50))
BEGIN
    UPDATE actors a JOIN movies_actors ma on a.id = ma.actor_id
        JOIN movies m on m.id = ma.movie_id
        JOIN movies m2 on m2.id = ma.movie_id
    SET a.awards = a.awards + 1
    WHERE m.title = movie_title;
END$$

CALL udp_award_movie('Tea For Two');