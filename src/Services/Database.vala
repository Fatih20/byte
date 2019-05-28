public class Services.Database : GLib.Object {
    private Sqlite.Database db;
    private string db_path;

    public signal void adden_new_track (Objects.Track track);

    public signal void added_new_artist (Objects.Artist artist);
    public signal void added_new_album (Objects.Album album);
    public Database (bool skip_tables = false) {
        int rc = 0;
        db_path = Environment.get_home_dir () + "/.local/share/com.github.alainm23.byte/database.db";

        if (!skip_tables) {
            if (create_tables () != Sqlite.OK) {
                stderr.printf ("Error creating db table: %d, %s\n", rc, db.errmsg ());
                Gtk.main_quit ();
            }
        }

        rc = Sqlite.Database.open (db_path, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }
    }

    private int create_tables () {
        int rc;

        rc = Sqlite.Database.open (db_path, out db);

        if (rc != Sqlite.OK) {
            stderr.printf ("Can't open database: %d, %s\n", rc, db.errmsg ());
            Gtk.main_quit ();
        }

        rc = db.exec ("CREATE TABLE IF NOT EXISTS artists (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "name           TEXT    NOT NULL," +
            "CONSTRAINT unique_artist UNIQUE (name))", null, null);
        debug ("Table artists created");

        rc = db.exec ("CREATE TABLE IF NOT EXISTS albums (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "artist_id      INT     NOT NULL," + 
            "year           INT     NOT NULL," +
            "title          TEXT    NOT NULL," +
            "genre          TEXT    NOT NULL," +
            "CONSTRAINT unique_album UNIQUE (artist_id, title)," +
            "FOREIGN KEY (artist_id) REFERENCES artists (id) ON DELETE CASCADE)", null, null);
        debug ("Table albums created");

        rc = db.exec ("CREATE TABLE IF NOT EXISTS tracks (" +
            "id             INTEGER PRIMARY KEY AUTOINCREMENT," +
            "album_id       INT     NOT NULL," +
            "path           TEXT    NOT NULL," +
            "title          TEXT    NOT NULL," +
            "track          INT     NOT NULL," +
            "disc           INT     NOT NULL," +
            "duration       INT     NOT NULL," +
            "CONSTRAINT unique_track UNIQUE (path)," +
            "FOREIGN KEY (album_id) REFERENCES albums (id) ON DELETE CASCADE)", null, null);
        debug ("Table trackS created");

        rc = db.exec ("PRAGMA foreign_keys = ON;");

        return rc;
    }

    public bool music_file_exists (string uri) {
        bool file_exists = false;
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks WHERE path = ?", -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, uri);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            file_exists = stmt.column_int (0) > 0;
        }

        return file_exists;
    }

    public bool is_database_empty () {
        bool empty = false;
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks", -1, out stmt);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            empty = stmt.column_int (0) <= 0;
        }

        return empty;
    }

    public int get_id_if_artist_exists (Objects.Artist artist) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT COUNT (*) FROM artists WHERE name = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, artist.name);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            if (stmt.column_int (0) > 0) {
                stmt.reset ();

                sql = """
                    SELECT id FROM artists WHERE name = ?;
                """;

                res = db.prepare_v2 (sql, -1, out stmt);
                assert (res == Sqlite.OK);

                res = stmt.bind_text (1, artist.name);
                assert (res == Sqlite.OK);

                if (stmt.step () == Sqlite.ROW) {
                    return stmt.column_int (0);
                } else {
                    warning ("Error: %d: %s", db.errcode (), db.errmsg ());
                    return 0;
                }
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int insert_artist_if_not_exists (Objects.Artist artist) {
        Sqlite.Statement stmt;
        string sql;
        int id;

        id = get_id_if_artist_exists (artist);
        if (id == 0) {
            sql = """
                INSERT OR IGNORE INTO artists (name) VALUES (?);
            """;
            
            int res = db.prepare_v2 (sql, -1, out stmt);
            assert (res == Sqlite.OK);

            res = stmt.bind_text (1, artist.name);
            assert (res == Sqlite.OK);
            
            if (stmt.step () != Sqlite.DONE) {
                warning ("Error: %d: %s", db.errcode (), db.errmsg ());
            }

            artist.id = get_id_if_artist_exists (artist);
            added_new_artist (artist);

            return artist.id;
        } else {
            return id;
        }
    }

    public int get_id_if_album_exists (Objects.Album album) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            SELECT COUNT (*) FROM albums WHERE title = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, album.title);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            if (stmt.column_int (0) > 0) {
                stmt.reset ();

                sql = """
                    SELECT id FROM albums WHERE title = ?;
                """;

                res = db.prepare_v2 (sql, -1, out stmt);
                assert (res == Sqlite.OK);

                res = stmt.bind_text (1, album.title);
                assert (res == Sqlite.OK);

                if (stmt.step () == Sqlite.ROW) {
                    return stmt.column_int (0);
                } else {
                    warning ("Error: %d: %s", db.errcode (), db.errmsg ());
                    return 0;
                }
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    public int insert_album_if_not_exists (Objects.Album album) {
        Sqlite.Statement stmt;
        string sql;
        int id;

        id = get_id_if_album_exists (album);
        if (id == 0) {
            sql = """
                INSERT OR IGNORE INTO albums (artist_id, year, title, genre) VALUES (?, ?, ?, ?);
            """;
            
            int res = db.prepare_v2 (sql, -1, out stmt);
            assert (res == Sqlite.OK);

            res = stmt.bind_int (1, album.artist_id);
            assert (res == Sqlite.OK);

            res = stmt.bind_int (2, album.year);
            assert (res == Sqlite.OK);

            res = stmt.bind_text (3, album.title);
            assert (res == Sqlite.OK);

            res = stmt.bind_text (4, album.genre);
            assert (res == Sqlite.OK);
            
            if (stmt.step () != Sqlite.DONE) {
                warning ("Error: %d: %s", db.errcode (), db.errmsg ());
            }

            album.id = get_id_if_album_exists (album);
            added_new_album (album);

            return album.id;
        } else {
            return id;
        }
    }

    public void insert_track (Objects.Track track) {
        Sqlite.Statement stmt;
        string sql;
        int res;

        sql = """
            INSERT OR IGNORE INTO tracks (album_id, path, title, track, disc, duration)
            VALUES (?, ?, ?, ?, ?, ?);
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (1, track.album_id);
        assert (res == Sqlite.OK);
        
        res = stmt.bind_text (2, track.path);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (3, track.title);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (4, track.track);
        assert (res == Sqlite.OK);

        res = stmt.bind_int (5, track.disc);
        assert (res == Sqlite.OK);

        res = stmt.bind_int64 (6, (int64) track.duration);
        assert (res == Sqlite.OK);

        if (stmt.step () != Sqlite.DONE) {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }
        stmt.reset ();

        sql = """
            SELECT id FROM tracks WHERE path = ?;
        """;

        res = db.prepare_v2 (sql, -1, out stmt);
        assert (res == Sqlite.OK);

        res = stmt.bind_text (1, track.path);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            track.id = stmt.column_int (0);
            stdout.printf ("Track ID: %d - %s\n", track.id, track.title);

            Byte.cover_import.import (track);
            
            adden_new_track (track);
        } else {
            warning ("Error: %d: %s", db.errcode (), db.errmsg ());
        }

        stmt.reset ();
    }

    public Gee.ArrayList<Objects.Track?> get_all_tracks () {
        /*
        Sqlite.Statement stmt;

        int res = db.prepare_v2 ("SELECT * FROM tracks",
            -1, out stmt);
        assert (res == Sqlite.OK);

        var all = new Gee.ArrayList<Objects.Track?> ();

        while ((res = stmt.step()) == Sqlite.ROW) {
            var track = new Objects.Track ();

            track.id = stmt.column_int (0);
            track.path = stmt.column_text (1);
            track.title = stmt.column_text (2);
            track.artist = stmt.column_text (3);
            track.genre = stmt.column_text (4);
            track.year = stmt.column_int (5);
            track.lyrics = stmt.column_text (6);
            track.duration = stmt.column_int64 (7);
            track.album = stmt.column_text (8);

            all.add (track);
        }

        return all;
        */
        var all = new Gee.ArrayList<Objects.Track?> ();
        return all;
    }

    public int get_tracks_number () {
        /*
        Sqlite.Statement stmt;
        int c = 0;

        int res = db.prepare_v2 ("SELECT COUNT (*) FROM tracks",
            -1, out stmt);
        assert (res == Sqlite.OK);

        if (stmt.step () == Sqlite.ROW) {
            c = stmt.column_int (0);
        }

        return c;
        */

        return 0;
    }
}
