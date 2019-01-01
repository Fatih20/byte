public class Services.CoverImport : GLib.Object {
    private const int DISCOVERER_TIMEOUT = 5;

    private Gst.PbUtils.Discoverer discoverer;
    private string cover_path;
    private string cache_folder;
    private string cover_folder;

    construct {
        try {
            discoverer = new Gst.PbUtils.Discoverer ((Gst.ClockTime) (DISCOVERER_TIMEOUT * Gst.SECOND));

            cache_folder = GLib.Path.build_filename (GLib.Environment.get_user_cache_dir (), "com.github.alainm23.byte");
            cover_folder = GLib.Path.build_filename (cache_folder, "covers");
        } catch (Error err) {
            critical ("Could not create Gst discoverer object: %s", err.message);
        }
    }

    public void import (Objects.Track track) {
        try {
            cover_path = GLib.Path.build_filename (cover_folder, ("%i.jpg").printf (track.id));

            var info = discoverer.discover_uri (track.path);
            read_info (info);
        } catch (Error err) {
            critical ("Error while importing .. ");
        }
        /*
        new Thread<void*> (null, () => {
            return null;
        });
        */
    }

    private void read_info (Gst.PbUtils.DiscovererInfo info) {
        string uri = info.get_uri ();
        bool gstreamer_discovery_successful = false;
        switch (info.get_result ()) {
            case Gst.PbUtils.DiscovererResult.OK:
                gstreamer_discovery_successful = true;
            break;

            case Gst.PbUtils.DiscovererResult.URI_INVALID:
                warning ("GStreamer could not import '%s': invalid URI.", uri);
            break;

            case Gst.PbUtils.DiscovererResult.ERROR:
                warning ("GStreamer could not import '%s'", uri);
            break;

            case Gst.PbUtils.DiscovererResult.TIMEOUT:
                warning ("GStreamer could not import '%s': Discovery timed out.", uri);
            break;

            case Gst.PbUtils.DiscovererResult.BUSY:
                warning ("GStreamer could not import '%s': Already discovering a file.", uri);
            break;

            case Gst.PbUtils.DiscovererResult.MISSING_PLUGINS:
                warning ("GStreamer could not import '%s': Missing plugins.", uri);

                /**
                 * TODO: handle this gracefully.
                 * After the import finishes, show the plugin-not-found
                 * dialog and rescan the music folder.
                 */
            break;
        }

        if (gstreamer_discovery_successful) {
            Idle.add (() => {
                Gdk.Pixbuf pixbuf = null;
                var tag_list = info.get_tags ();
                var sample = get_cover_sample (tag_list);

                if (sample == null) {
                    tag_list.get_sample_index (Gst.Tags.PREVIEW_IMAGE, 0, out sample);
                }

                if (sample != null) {
                    var buffer = sample.get_buffer ();

                    if (buffer != null) {
                        pixbuf = get_pixbuf_from_buffer (buffer);
                        if (pixbuf != null) {
                            save_cover_pixbuf (pixbuf);
                        }
                    }

                    debug ("Final image buffer is NULL for '%s'", info.get_uri ());
                } else {
                    debug ("Image sample is NULL for '%s'", info.get_uri ());
                }

                return false;
            });
        }
    }

    private Gst.Sample? get_cover_sample (Gst.TagList tag_list) {
        Gst.Sample cover_sample = null;
        Gst.Sample sample;
        for (int i = 0; tag_list.get_sample_index (Gst.Tags.IMAGE, i, out sample); i++) {
            var caps = sample.get_caps ();
            unowned Gst.Structure caps_struct = caps.get_structure (0);
            int image_type = Gst.Tag.ImageType.UNDEFINED;
            caps_struct.get_enum ("image-type", typeof (Gst.Tag.ImageType), out image_type);
            if (image_type == Gst.Tag.ImageType.UNDEFINED && cover_sample == null) {
                cover_sample = sample;
            } else if (image_type == Gst.Tag.ImageType.FRONT_COVER) {
                return sample;
            }
        }

        return cover_sample;
    }

    private Gdk.Pixbuf? get_pixbuf_from_buffer (Gst.Buffer buffer) {
        Gst.MapInfo map_info;

        if (!buffer.map (out map_info, Gst.MapFlags.READ)) {
            warning ("Could not map memory buffer");
            return null;
        }

        Gdk.Pixbuf pix = null;

        try {
            var loader = new Gdk.PixbufLoader ();

            if (loader.write (map_info.data) && loader.close ())
                pix = loader.get_pixbuf ();
        } catch (Error err) {
            warning ("Error processing image data: %s", err.message);
        }

        buffer.unmap (map_info);

        return pix;
    }

    private void save_cover_pixbuf (Gdk.Pixbuf p) {
        Gdk.Pixbuf ? pixbuf = align_and_scale_pixbuf (p, 128);

        try {
            pixbuf.save (cover_path, "jpeg", "quality", "100");
        } catch (Error err) {
            warning (err.message);
        }
    }

    private Gdk.Pixbuf? align_and_scale_pixbuf (Gdk.Pixbuf p, int size) {
        Gdk.Pixbuf ? pixbuf = p;
        if (pixbuf.width != pixbuf.height) {
            if (pixbuf.width > pixbuf.height) {
                int dif = (pixbuf.width - pixbuf.height) / 2;
                pixbuf = new Gdk.Pixbuf.subpixbuf (pixbuf, dif, 0, pixbuf.height, pixbuf.height);
            } else {
                int dif = (pixbuf.height - pixbuf.width) / 2;
                pixbuf = new Gdk.Pixbuf.subpixbuf (pixbuf, 0, dif, pixbuf.width, pixbuf.width);
            }
        }

        pixbuf = pixbuf.scale_simple (size, size, Gdk.InterpType.BILINEAR);

        return pixbuf;
    }
}
