public class Dialogs.Settings : Gtk.Dialog { 
    public Settings () {
        Object (
            transient_for: Byte.instance.main_window,
            deletable: false,
            resizable: true,
            destroy_with_parent: true
            //window_position: Gtk.WindowPosition.CENTER_ON_PARENT
        );
	}

    construct {
        get_style_context ().add_class ("editor-titlebar");
        set_size_request (550, -1);

        var general_label = new Gtk.Label (_("General"));
        general_label.halign = Gtk.Align.START;
        general_label.get_style_context ().add_class ("h3");
        general_label.get_style_context ().add_class ("font-bold");
        general_label.margin_bottom = 6;
        general_label.margin_start = 6;

        /*
            Dark Mode
        */

        var settings_01_icon = new Gtk.Image ();
        settings_01_icon.gicon = new ThemedIcon ("weather-clear-night-symbolic");
        settings_01_icon.pixel_size = 16;
        settings_01_icon.get_style_context ().add_class ("settings-icon");
        settings_01_icon.valign = Gtk.Align.CENTER;

        var settings_01_label = new Gtk.Label (_("Dark mode"));
        //settings_01_label.get_style_context ().add_class ("h3");
        
        var settings_01_switch = new Gtk.Switch ();
        settings_01_switch.get_style_context ().add_class ("active-switch");
        settings_01_switch.valign = Gtk.Align.CENTER;
        
        var gtk_settings = Gtk.Settings.get_default (); 
        settings_01_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");
        Byte.settings.bind ("dark-mode", settings_01_switch, "active", GLib.SettingsBindFlags.DEFAULT);

        var settings_01_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_01_box.hexpand = true;
        settings_01_box.margin = 6;
        settings_01_box.pack_start (settings_01_icon, false, false, 0);
        settings_01_box.pack_start (settings_01_label, false, false, 6);
        settings_01_box.pack_end (settings_01_switch, false, false, 0);

        /*
            Notifications
        */

        var settings_02_icon = new Gtk.Image ();
        settings_02_icon.gicon = new ThemedIcon ("preferences-system-notifications-symbolic");
        settings_02_icon.pixel_size = 16;
        settings_02_icon.get_style_context ().add_class ("settings-icon");
        settings_02_icon.valign = Gtk.Align.CENTER;

        var settings_02_label = new Gtk.Label (_("Notifications"));
        
        var settings_02_switch = new Gtk.Switch ();
        settings_02_switch.get_style_context ().add_class ("active-switch");
        settings_02_switch.valign = Gtk.Align.CENTER;
        settings_02_switch.active = Byte.settings.get_boolean ("notifications-enabled");

        var settings_02_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_02_box.hexpand = true;
        settings_02_box.margin = 6;
        settings_02_box.pack_start (settings_02_icon, false, false, 0);
        settings_02_box.pack_start (settings_02_label, false, false, 6);
        settings_02_box.pack_end (settings_02_switch, false, false, 0);

        /*
            Background running
        */

        var settings_03_icon = new Gtk.Image ();
        settings_03_icon.gicon = new ThemedIcon ("applications-system-symbolic");
        settings_03_icon.pixel_size = 16;
        settings_03_icon.get_style_context ().add_class ("settings-icon");
        settings_03_icon.valign = Gtk.Align.CENTER;

        var settings_03_label = new Gtk.Label (_("Play in background if closed"));
        
        var settings_03_switch = new Gtk.Switch ();
        settings_03_switch.get_style_context ().add_class ("active-switch");
        settings_03_switch.valign = Gtk.Align.CENTER;
        settings_03_switch.active = Byte.settings.get_boolean ("play-in-background");
        
        var settings_03_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_03_box.hexpand = true;
        settings_03_box.margin = 6;
        settings_03_box.pack_start (settings_03_icon, false, false, 0);
        settings_03_box.pack_start (settings_03_label, false, false, 6);
        settings_03_box.pack_end (settings_03_switch, false, false, 0);

        var general_grid = new Gtk.Grid ();
        general_grid.get_style_context ().add_class ("view");
        general_grid.orientation = Gtk.Orientation.VERTICAL;
        general_grid.row_spacing = 3;
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        general_grid.add (settings_01_box);
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        general_grid.add (settings_02_box);
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        general_grid.add (settings_03_box);
        general_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        var library_label = new Gtk.Label (_("Library"));
        library_label.halign = Gtk.Align.START;
        library_label.get_style_context ().add_class ("h3");
        library_label.get_style_context ().add_class ("font-bold");
        library_label.margin = 6;

        /*
            Library location
        */

        var settings_04_icon = new Gtk.Image ();
        settings_04_icon.gicon = new ThemedIcon ("folder-music-symbolic");
        settings_04_icon.pixel_size = 16;
        settings_04_icon.get_style_context ().add_class ("settings-icon");
        settings_04_icon.valign = Gtk.Align.CENTER;

        var settings_04_label = new Gtk.Label (_("Music folder location"));
        
        var library_filechooser = new Gtk.FileChooserButton (_("Select Music Folder…"), Gtk.FileChooserAction.SELECT_FOLDER);
        
        File library_path = File.new_for_uri (Byte.settings.get_string ("library-location"));
        library_filechooser.set_current_folder (library_path.get_path ());

        var settings_04_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_04_box.hexpand = true;
        settings_04_box.margin = 6;
        settings_04_box.pack_start (settings_04_icon, false, false, 0);
        settings_04_box.pack_start (settings_04_label, false, false, 6);
        settings_04_box.pack_end (library_filechooser, false, false, 0);

        /*
            Sync init 
        */

        var settings_05_icon = new Gtk.Image ();
        settings_05_icon.gicon = new ThemedIcon ("emblem-synchronizing-symbolic");
        settings_05_icon.pixel_size = 16;
        settings_05_icon.get_style_context ().add_class ("settings-icon");
        settings_05_icon.valign = Gtk.Align.CENTER;

        var settings_05_label = new Gtk.Label (_("Sync library on start up"));
        
        var settings_05_switch = new Gtk.Switch ();
        settings_05_switch.get_style_context ().add_class ("active-switch");
        settings_05_switch.valign = Gtk.Align.CENTER;
        settings_05_switch.active = Byte.settings.get_boolean ("sync-files");
        
        var settings_05_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_05_box.hexpand = true;
        settings_05_box.margin = 6;
        settings_05_box.pack_start (settings_05_icon, false, false, 0);
        settings_05_box.pack_start (settings_05_label, false, false, 6);
        settings_05_box.pack_end (settings_05_switch, false, false, 0);

        /*
            Auto download cover
        */
        
        var settings_06_icon = new Gtk.Image ();
        settings_06_icon.gicon = new ThemedIcon ("folder-download-symbolic");
        settings_06_icon.pixel_size = 16;
        settings_06_icon.get_style_context ().add_class ("settings-icon");
        settings_06_icon.valign = Gtk.Align.CENTER;

        var settings_06_label = new Gtk.Label (_("Automatically download covers"));
        
        var settings_06_switch = new Gtk.Switch ();
        settings_06_switch.get_style_context ().add_class ("active-switch");
        settings_06_switch.valign = Gtk.Align.CENTER;
        settings_06_switch.active = Byte.settings.get_boolean ("auto-download-covers");
        
        var settings_06_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_06_box.hexpand = true;
        settings_06_box.margin = 6;
        settings_06_box.pack_start (settings_06_icon, false, false, 0);
        settings_06_box.pack_start (settings_06_label, false, false, 6);
        settings_06_box.pack_end (settings_06_switch, false, false, 0);

        /*
            Save ID3-Tag
        */

        var settings_07_icon = new Gtk.Image ();
        settings_07_icon.gicon = new ThemedIcon ("text-x-generic-symbolic");
        settings_07_icon.pixel_size = 16;
        settings_07_icon.get_style_context ().add_class ("settings-icon");
        settings_07_icon.valign = Gtk.Align.CENTER;

        var settings_07_label = new Gtk.Label (_("Save changes into ID3-Tag"));
        
        var settings_07_switch = new Gtk.Switch ();
        settings_07_switch.get_style_context ().add_class ("active-switch");
        settings_07_switch.valign = Gtk.Align.CENTER;
        settings_07_switch.active = Byte.settings.get_boolean ("save-id3-tags");
        
        var settings_07_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_07_box.hexpand = true;
        settings_07_box.margin = 6;
        settings_07_box.pack_start (settings_07_icon, false, false, 0);
        settings_07_box.pack_start (settings_07_label, false, false, 6);
        settings_07_box.pack_end (settings_07_switch, false, false, 0);

        var library_grid = new Gtk.Grid ();
        library_grid.get_style_context ().add_class ("view");
        library_grid.orientation = Gtk.Orientation.VERTICAL;
        library_grid.row_spacing = 3;
        library_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        library_grid.add (settings_04_box);
        library_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        library_grid.add (settings_05_box);
        library_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        library_grid.add (settings_06_box);
        library_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        library_grid.add (settings_07_box);
        library_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        /*
            Reset
        */

        var settings_08_icon = new Gtk.Image ();
        settings_08_icon.gicon = new ThemedIcon ("user-trash-symbolic");
        settings_08_icon.pixel_size = 16;
        settings_08_icon.get_style_context ().add_class ("settings-icon");
        settings_08_icon.valign = Gtk.Align.CENTER;

        var settings_08_label = new Gtk.Label (_("Reset all library"));
        
        var settings_08_button = new Gtk.Button.with_label ("Reset");
        settings_08_button.valign = Gtk.Align.CENTER;
        
        var settings_08_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        settings_08_box.hexpand = true;
        settings_08_box.margin = 6;
        settings_08_box.margin_top = 3;
        settings_08_box.margin_bottom = 3;
        settings_08_box.pack_start (settings_08_icon, false, false, 0);
        settings_08_box.pack_start (settings_08_label, false, false, 6);
        settings_08_box.pack_end (settings_08_button, false, false, 0);

        var settings_08_grid = new Gtk.Grid ();
        settings_08_grid.margin_top = 12;
        settings_08_grid.get_style_context ().add_class ("view");
        settings_08_grid.orientation = Gtk.Orientation.VERTICAL;
        settings_08_grid.row_spacing = 3;
        settings_08_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        settings_08_grid.add (settings_08_box);
        settings_08_grid.add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

        var main_grid = new Gtk.Grid ();
        main_grid.attach (general_label, 0, 0, 1, 1);
        main_grid.attach (general_grid, 0, 1, 1, 1);
        main_grid.attach (library_label, 0, 2, 1, 1);
        main_grid.attach (library_grid, 0, 3, 1, 1);
        main_grid.attach (settings_08_grid, 0, 4, 1, 1);

        get_content_area ().add (main_grid);

        add_button (_("Close"), Gtk.ResponseType.CLOSE);

        response.connect ((response_id) => {
            destroy (); 
        });

        settings_01_switch.notify["active"].connect (() => { 
            var provider = new Gtk.CssProvider ();
            var colored_css = """
                @define-color colorPrimary %s;
                @define-color textColorPrimary %s;
            """;

            if (settings_01_switch.active) {
                colored_css = colored_css.printf (
                    "@base_color",
                    "#fe2851"
                );
            } else {
                colored_css = colored_css.printf (
                    "#fe2851",
                    "#ffffff"
                );
            }

            try {
                provider.load_from_data (colored_css, colored_css.length);

                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
                return;
            }
        });

        settings_02_switch.notify["active"].connect (() => {
            Byte.settings.set_boolean ("notifications-enabled", settings_02_switch.active);
        });

        settings_03_switch.notify["active"].connect (() => {
            Byte.settings.set_boolean ("play-in-background", settings_03_switch.active);
        });

        settings_05_switch.notify["active"].connect (() => {
            Byte.settings.set_boolean ("sync-files", settings_05_switch.active);
        });

        settings_06_switch.notify["active"].connect (() => {
            Byte.settings.set_boolean ("auto-download-covers", settings_06_switch.active);
        });

        settings_07_switch.notify["active"].connect (() => {
            Byte.settings.set_boolean ("save-id3-tags", settings_07_switch.active);
        });

        library_filechooser.file_set.connect (() => {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                "Set Music Folder?",
                "Are you sure you want to set the music folder to <b>%s</b>?".printf (library_filechooser.get_filename ()),
                "dialog-warning",
                Gtk.ButtonsType.CANCEL
            );

            var set_button = new Gtk.Button.with_label (_("Set Music Folder"));
            set_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (set_button, Gtk.ResponseType.ACCEPT);
            
            message_dialog.show_all ();

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                Byte.settings.set_string ("library-location", library_filechooser.get_uri ());
                Byte.scan_service.scan_local_files (library_filechooser.get_uri ());
            }

            message_dialog.destroy ();
        });

        settings_08_button.clicked.connect (() => {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Are you sure you want to mark as completed this project?"),
                _("This project contains incomplete tasks"),
                "dialog-warning",
                Gtk.ButtonsType.CANCEL
            );

            var remove_button = new Gtk.Button.with_label (_("Mark as Completed"));
            remove_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            message_dialog.add_action_widget (remove_button, Gtk.ResponseType.ACCEPT);

            message_dialog.show_all ();

            if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
                Byte.database.reset_all_library ();
                destroy ();
            }

            message_dialog.destroy ();
        });
    }
}