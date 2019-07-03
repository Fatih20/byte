public class Views.Home : Gtk.EventBox {
    private Gtk.ListBox tracks_listbox;
    public signal void go_albums_view ();
    public signal void go_tracks_view ();
    public signal void go_artists_view ();
    public signal void go_radios_view ();
    public signal void go_playlists_view ();
    public signal void go_favorites_view ();

    private Gee.ArrayList<Objects.Track?> all_tracks;

    public Home () {}

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        get_style_context ().add_class (Granite.STYLE_CLASS_WELCOME);
        get_style_context ().add_class ("w-round");

        all_tracks = Byte.database.get_tracks_recently_added ();

        // Spinner loading
        var loading_spinner = new Gtk.Spinner ();
        loading_spinner.active = true;
        loading_spinner.start ();

        var loading_label = new Gtk.Label (_("Sync library…"));

        var loading_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        loading_box.halign = Gtk.Align.CENTER;
        loading_box.hexpand = true;
        loading_box.margin = 6;
        loading_box.add (loading_spinner);
        loading_box.add (loading_label);

        var loading_revealer = new Gtk.Revealer ();
        loading_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        loading_revealer.add (loading_box);
        loading_revealer.reveal_child = false;

        var library_label = new Gtk.Label ("<b>%s</b>".printf (_("Library")));
        library_label.get_style_context ().add_class ("font-bold");
        library_label.get_style_context ().add_class ("h3");
        library_label.margin_start = 12;
        library_label.margin_top = 9;
        library_label.halign =Gtk.Align.START;
        library_label.use_markup = true;
        
        var recently_added_label = new Gtk.Label ("<b>%s</b>".printf (_("Recently added")));
        recently_added_label.get_style_context ().add_class ("font-bold");
        recently_added_label.get_style_context ().add_class ("h3");
        recently_added_label.margin_start = 12;
        recently_added_label.halign =Gtk.Align.START;
        recently_added_label.use_markup = true;

        var playlists_button = new Widgets.HomeButton (_("Playlists"), "playlist-symbolic");
        var albums_button = new Widgets.HomeButton (_("Albums"), "planner-album-symbolic");
        var songs_button = new Widgets.HomeButton (_("Songs"), "planner-track-symbolic");
        var artists_button = new Widgets.HomeButton ("Artists", "planner-artist-symbolic");
        var radios_button = new Widgets.HomeButton ("Radios", "planner-radio-symbolic");
        var favorites_button = new Widgets.HomeButton ("Favorites", "planner-favorite-symbolic");

        tracks_listbox = new Gtk.ListBox ();
        tracks_listbox.expand = true;

        var tracks_scrolled = new Gtk.ScrolledWindow (null, null);
        tracks_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        tracks_scrolled.expand = true;
        tracks_scrolled.margin_start = 6;
        tracks_scrolled.margin_top = 6;
        tracks_scrolled.margin_bottom = 3;
        tracks_scrolled.add (tracks_listbox);

        var items_grid = new Gtk.Grid ();
        items_grid.row_spacing = 12;
        items_grid.column_spacing = 12;
        items_grid.margin = 12;
        items_grid.column_homogeneous = true;
        items_grid.row_homogeneous = true;
        items_grid.attach (songs_button,     0, 0, 1, 1);
        items_grid.attach (playlists_button,    1, 0, 1, 1);
        items_grid.attach (albums_button, 0, 1, 1, 1);
        items_grid.attach (artists_button, 1, 1, 1, 1);
        items_grid.attach (favorites_button,    0, 2, 1, 1);
        items_grid.attach (radios_button,   1, 2, 1, 1);

        var library_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        library_box.vexpand = true;
        library_box.hexpand = false;
        library_box.pack_start (loading_revealer, false, false, 0);
        library_box.pack_start (library_label, false, false, 0);
        library_box.pack_start (items_grid, false, false, 0);
        library_box.pack_start (recently_added_label, false, false, 0);
        library_box.pack_start (tracks_scrolled, true, true, 0);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.pack_start (library_box, true, true, 0);

        add (main_box);
        add_all_tracks ();

        albums_button.clicked.connect (() => {
            go_albums_view ();
        });

        songs_button.clicked.connect (() => {
            go_tracks_view ();
        });

        artists_button.clicked.connect (() => {
            go_artists_view ();
        });

        radios_button.clicked.connect (() => {
            go_radios_view ();
        });

        playlists_button.clicked.connect (() => {
            go_playlists_view ();
        });

        favorites_button.clicked.connect (() => {
            go_favorites_view ();
        });

        tracks_listbox.row_activated.connect ((row) => {
            var item = row as Widgets.TrackRow;
            
            Byte.utils.set_items (
                all_tracks,
                Byte.settings.get_boolean ("shuffle-mode"),
                item.track
            );
        });

        Byte.database.adden_new_track.connect ((track) => {
            Idle.add (() => {
                var row = new Widgets.TrackRow (track);
                tracks_listbox.insert (row, 0);
                all_tracks.insert (0, track);
                tracks_listbox.show_all ();

                print ("Size: %i\n".printf (all_tracks.size));

                if (all_tracks.size > 100) {
                    all_tracks.remove_at (100);
                    var _row = tracks_listbox.get_row_at_index (100);
                    _row.destroy ();
                }

                return false;
            });
        });
    }

    public void add_all_tracks () {
        foreach (var track in all_tracks) {
            var row = new Widgets.TrackRow (track);

            tracks_listbox.add (row);
            tracks_listbox.show_all ();
        }
    }
}