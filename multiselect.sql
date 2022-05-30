--1. количество исполнителей в каждом жанре;
SELECT g.name genre, COUNT(s.singer_id) count_singers FROM genre g
LEFT JOIN singer_genre s ON g.id = s.genre_id
GROUP BY g.name;

--2. количество треков, вошедших в альбомы 2019-2020 годов;
SELECT COUNT(t.id) FROM track t
RIGHT JOIN album a ON t.album_id = a.id
WHERE release BETWEEN 2019 AND 2020;

--3. средняя продолжительность треков по каждому альбому;
SELECT a.name album, AVG(t.duration) avg_duration FROM track t
RIGHT JOIN album a ON t.album_id = a.id
GROUP BY a.name;

--4. все исполнители, которые не выпустили альбомы в 2020 году;
SELECT name FROM singer 
WHERE name NOT IN (
	SELECT s.name FROM singer s 
	LEFT JOIN singer_album sa ON s.id = sa.singer_id
	LEFT JOIN album a ON sa.album_id = a.id
	WHERE release = 2020
	);

--5. названия сборников, в которых присутствует конкретный исполнитель (выберите сами);
SELECT DISTINCT c.name FROM collection c 
JOIN collection_track ct ON c.id = ct.collection_id
JOIN track t ON ct.track_id = t.id
JOIN album a ON t.album_id = a.id
JOIN singer_album sa ON a.id = sa.album_id
JOIN singer s  ON sa.singer_id = s.id
WHERE s.name iLIKE '%%Pilot%%';

--6. название альбомов, в которых присутствуют исполнители более 1 жанра;
SELECT DISTINCT a.name FROM album a 
JOIN singer_album sa  ON a.id = sa.album_id
WHERE sa.singer_id IN (
	SELECT singer_id FROM (
		SELECT sg.singer_id, COUNT(sg.genre_id) FROM singer_genre sg
		GROUP BY sg.singer_id
		HAVING COUNT(sg.genre_id)>1
		) subtable
	);

--7. наименование треков, которые не входят в сборники;
SELECT name FROM track t 
WHERE id NOT IN (
	SELECT DISTINCT track_id FROM collection_track);

--8. исполнителя(-ей), написавшего самый короткий по продолжительности трек (теоретически таких треков может быть несколько);
SELECT DISTINCT s.name FROM singer s 
JOIN singer_album sa ON s.id = sa.singer_id
WHERE album_id IN (
	SELECT album_id FROM track
	WHERE duration = (
		SELECT MIN(duration) FROM track
		)
	);

--9. название альбомов, содержащих наименьшее количество треков.
DROP TABLE IF exists subtable;
SELECT a.name, COUNT(t.id) amount INTO subtable FROM album a
JOIN track t ON a.id = t.album_id
GROUP BY a.name; 
SELECT * FROM subtable
WHERE amount = (
	SELECT MIN(amount) FROM subtable
	);
	