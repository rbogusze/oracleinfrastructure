USE songbrowser;

/** ALBUMS */
/** ***************************************************************** */

SELECT * FROM albums;

/** Select by artist */
SELECT * FROM albums 
  WHERE artist = 'System of a Down';

/** Select by album_title, fulltext search */
SELECT * FROM albums
  WHERE album_title LIKE '%zmer%';

/** Select by genre */
SELECT * FROM albums_by_genre
  WHERE genre = 'Hard rock';

/** SONGS */
/** ***************************************************************** */

/** Select by artist */
SELECT * FROM songs_by_artists 
  WHERE artist = 'System of a Down';

/** Select by album title and release year */
SELECT * FROM songs_by_albums 
  WHERE release_year = 2005 AND album_title = 'Mezmerize';
