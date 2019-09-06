CREATE KEYSPACE IF NOT EXISTS songbrowser WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};

CREATE TYPE IF NOT EXISTS songbrowser.producer (
  name          TEXT,
  country_code  TEXT  
);

CREATE TABLE IF NOT EXISTS songbrowser.albums (
  album_title    VARCHAR,
  artist         VARCHAR,
  genre          VARCHAR,
  producer       producer,
  record_label   VARCHAR,
  release_year   INT,
  PRIMARY KEY ((artist), release_year, album_title)
);

CREATE TABLE IF NOT EXISTS songbrowser.songs_by_albums (
  album_title    VARCHAR,
  artist         VARCHAR,
  genre          VARCHAR,
  performers     LIST<VARCHAR>,
  release_year   INT,
  song_title     VARCHAR,
  track_no       INT,
  PRIMARY KEY ((release_year, album_title), track_no)
);

CREATE TABLE IF NOT EXISTS songbrowser.songs_by_artists (
  album_title    VARCHAR,
  artist         VARCHAR,
  genre          VARCHAR,
  performers     LIST<VARCHAR>,
  release_year   INT,
  song_title     VARCHAR,
  track_no       INT,
  PRIMARY KEY ((artist), release_year, album_title, track_no)
);

CREATE CUSTOM INDEX IF NOT EXISTS album_album_title_partial ON songbrowser.albums (album_title) USING 'org.apache.cassandra.index.sasi.SASIIndex'
  WITH OPTIONS = { 'mode': 'CONTAINS' };

CREATE MATERIALIZED VIEW IF NOT EXISTS songbrowser.albums_by_genre AS
  SELECT album_title, release_year, artist, genre
  FROM songbrowser.albums
  WHERE album_title IS NOT NULL and release_year IS NOT NULL and artist IS NOT NULL and genre IS NOT NULL
  PRIMARY KEY ((genre), release_year, artist, album_title);

