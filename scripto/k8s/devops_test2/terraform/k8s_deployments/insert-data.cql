USE songbrowser;

/** Albums */
INSERT INTO albums (artist, release_year, album_title, genre, record_label, producer)
VALUES ('Red Hot Chili Peppers', 2002, 'By the Way', 'Funk', 'WMG', {name: 'Warner Music GrouXp', country_code: 'us'});

INSERT INTO albums (artist, release_year, album_title, genre, record_label, producer)
VALUES ('System of a Down', 2005, 'Hypnotize', 'Hard rock', 'American', {name: 'American Records', country_code: 'us'});

INSERT INTO albums (artist, release_year, album_title, genre, record_label, producer)
VALUES ('System of a Down', 2005, 'Mezmerize', 'Hard rock', 'American', {name: 'American Records', country_code: 'us'});

/** Songs by album */
INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 1, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Soldier Side');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 2, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'BYOB');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 3, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Revenga');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 4, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Cigaro');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Hypnotize', 1, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Soldier Side');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Hypnotize', 2, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Attack');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Hypnotize', 3, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Dreaming');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2002, 'By the Way', 1, 'Red Hot Chili Peppers', 'Funk', ['Kiedis', 'Frusciante', 'Flea', 'Smith'], 'By the Way');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2002, 'By the Way', 2, 'Red Hot Chili Peppers', 'Funk', ['Kiedis', 'Frusciante', 'Flea', 'Smith'], 'Universally Speaking');

INSERT INTO songs_by_albums (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2002, 'By the Way', 3, 'Red Hot Chili Peppers', 'Funk', ['Kiedis', 'Frusciante', 'Flea', 'Smith'], 'This Is the Place');

/** Songs by artist */
INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 1, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Soldier Side');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 2, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'BYOB');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 3, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Revenga');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Mezmerize', 4, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Cigaro');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Hypnotize', 1, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Soldier Side');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Hypnotize', 2, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Attack');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2005, 'Hypnotize', 3, 'System of a Down', 'Hard rock', ['Tankian', 'Malakian', 'Odadjian', 'Dolmayan'], 'Dreaming');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2002, 'By the Way', 1, 'Red Hot Chili Peppers', 'Funk', ['Kiedis', 'Frusciante', 'Flea', 'Smith'], 'By the Way');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2002, 'By the Way', 2, 'Red Hot Chili Peppers', 'Funk', ['Kiedis', 'Frusciante', 'Flea', 'Smith'], 'Universally Speaking');

INSERT INTO songs_by_artists (release_year, album_title, track_no, artist, genre, performers, song_title)
VALUES (2002, 'By the Way', 3, 'Red Hot Chili Peppers', 'Funk', ['Kiedis', 'Frusciante', 'Flea', 'Smith'], 'This Is the Place');
