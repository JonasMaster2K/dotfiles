#!/usr/bin/env python3
"""
SVG Symbolic Icon Fixer
Converts Inkscape/Papirus style="opacity:X;fill:currentColor"
to opacity="X" fill="currentColor" for GTK4 symbolic icon parser.
"""

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib
import re
import os

def fix_svg(content):
    # style="opacity:X;fill:currentColor" → opacity="X" fill="currentColor"
    content = re.sub(
        r'style="opacity:([^;\"]+);fill:currentColor"',
        r'opacity="\1" fill="currentColor"',
        content
    )
    # style="fill:currentColor" → fill="currentColor"
    content = re.sub(
        r'style="fill:currentColor"',
        r'fill="currentColor"',
        content
    )
    # Add viewBox if missing
    if 'viewBox' not in content:
        w = re.search(r'width="(\d+)"', content)
        h = re.search(r'height="(\d+)"', content)
        if w and h:
            vb = f'viewBox="0 0 {w.group(1)} {h.group(1)}"'
            content = re.sub(r'(<svg\b[^>]*)(>)', lambda m: m.group(1) + ' ' + vb + m.group(2), content, count=1)
    # Remove KDE ColorScheme defs
    content = re.sub(r'\s*<defs[^>]*>\s*<style[^>]*id="current-color-scheme"[^>]*>.*?</style>\s*</defs>', '', content, flags=re.DOTALL)
    # Remove class="ColorScheme-*" attributes
    content = re.sub(r'\s*class="[^"]*ColorScheme[^"]*"', '', content)
    # Remove standalone="no"
    content = re.sub(r'\s*standalone="no"', '', content)
    # Remove xmlns:svg duplicate namespace
    content = re.sub(r'\s*xmlns:svg="[^"]*"', '', content)
    # Remove id attributes from defs/path (optional but clean)
    # content = re.sub(r'\s*id="[^"]*"', '', content)
    return content

class App(Gtk.Window):
    def __init__(self):
        super().__init__(title="SVG Icon Fixer")
        self.set_default_size(700, 600)
        self.set_border_width(0)

        # Dark theme
        css = b"""
        window { background-color: #1e1e2e; }
        .header { background-color: #181825; padding: 16px 20px; border-bottom: 1px solid #313244; }
        .title { color: #cdd6f4; font-size: 16px; font-weight: bold; font-family: monospace; }
        .subtitle { color: #6c7086; font-size: 11px; font-family: monospace; }
        .btn-open { background-color: #89b4fa; color: #1e1e2e; border: none; border-radius: 6px; padding: 8px 16px; font-weight: bold; font-family: monospace; }
        .btn-open:hover { background-color: #b4d0ff; }
        .btn-fix { background-color: #a6e3a1; color: #1e1e2e; border: none; border-radius: 6px; padding: 8px 16px; font-weight: bold; font-family: monospace; }
        .btn-fix:hover { background-color: #c9f0c5; }
        .btn-fix:disabled { background-color: #313244; color: #585b70; }
        .btn-save { background-color: #f38ba8; color: #1e1e2e; border: none; border-radius: 6px; padding: 8px 16px; font-weight: bold; font-family: monospace; }
        .btn-save:hover { background-color: #f7a8be; }
        .btn-save:disabled { background-color: #313244; color: #585b70; }
        .filepath { color: #89b4fa; font-family: monospace; font-size: 11px; padding: 8px 20px; background-color: #181825; border-bottom: 1px solid #313244; }
        .status-ok { color: #a6e3a1; font-family: monospace; font-size: 11px; padding: 4px 20px; }
        .status-err { color: #f38ba8; font-family: monospace; font-size: 11px; padding: 4px 20px; }
        textview { background-color: #181825; color: #cdd6f4; font-family: monospace; font-size: 12px; }
        textview text { background-color: #181825; color: #cdd6f4; }
        scrolledwindow { border: 1px solid #313244; margin: 8px 16px; border-radius: 4px; }
        .label-before { color: #f9e2af; font-family: monospace; font-size: 11px; padding: 6px 20px 2px 20px; }
        .label-after { color: #a6e3a1; font-family: monospace; font-size: 11px; padding: 6px 20px 2px 20px; }
        """
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.filepath = None
        self.fixed_content = None

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.add(vbox)

        # Header
        header = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        header.get_style_context().add_class("header")
        title = Gtk.Label(label="SVG Symbolic Icon Fixer")
        title.set_xalign(0)
        title.get_style_context().add_class("title")
        subtitle = Gtk.Label(label="Fixes Papirus/Inkscape SVGs for GTK4 symbolic icon parser")
        subtitle.set_xalign(0)
        subtitle.get_style_context().add_class("subtitle")
        header.pack_start(title, False, False, 0)
        header.pack_start(subtitle, False, False, 4)
        vbox.pack_start(header, False, False, 0)

        # Notebook (tabs)
        notebook = Gtk.Notebook()
        notebook.set_margin_top(8)
        notebook.set_margin_bottom(4)
        notebook.set_margin_start(8)
        notebook.set_margin_end(8)
        vbox.pack_start(notebook, True, True, 0)

        # ── Tab 1: Single file ──
        tab1 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        self.filepath_label = Gtk.Label(label="No file loaded")
        self.filepath_label.set_xalign(0)
        self.filepath_label.get_style_context().add_class("filepath")
        tab1.pack_start(self.filepath_label, False, False, 0)

        btnbox = Gtk.Box(spacing=8)
        btnbox.set_border_width(10)

        btn_open = Gtk.Button(label="Open SVG")
        btn_open.get_style_context().add_class("btn-open")
        btn_open.connect("clicked", self.on_open)
        btnbox.pack_start(btn_open, False, False, 0)

        self.btn_fix = Gtk.Button(label="Fix SVG")
        self.btn_fix.get_style_context().add_class("btn-fix")
        self.btn_fix.connect("clicked", self.on_fix)
        self.btn_fix.set_sensitive(False)
        btnbox.pack_start(self.btn_fix, False, False, 0)

        self.btn_save = Gtk.Button(label="Save (overwrite)")
        self.btn_save.get_style_context().add_class("btn-save")
        self.btn_save.connect("clicked", self.on_save)
        self.btn_save.set_sensitive(False)
        btnbox.pack_start(self.btn_save, False, False, 0)

        self.status_label = Gtk.Label(label="")
        self.status_label.set_xalign(0)
        btnbox.pack_start(self.status_label, False, False, 8)
        tab1.pack_start(btnbox, False, False, 0)

        lbl_before = Gtk.Label(label="BEFORE")
        lbl_before.set_xalign(0)
        lbl_before.get_style_context().add_class("label-before")
        tab1.pack_start(lbl_before, False, False, 0)

        scroll_before = Gtk.ScrolledWindow()
        self.text_before = Gtk.TextView()
        self.text_before.set_editable(False)
        self.text_before.set_monospace(True)
        scroll_before.add(self.text_before)
        tab1.pack_start(scroll_before, True, True, 0)

        lbl_after = Gtk.Label(label="AFTER (preview)")
        lbl_after.set_xalign(0)
        lbl_after.get_style_context().add_class("label-after")
        tab1.pack_start(lbl_after, False, False, 0)

        scroll_after = Gtk.ScrolledWindow()
        self.text_after = Gtk.TextView()
        self.text_after.set_editable(False)
        self.text_after.set_monospace(True)
        scroll_after.add(self.text_after)
        tab1.pack_start(scroll_after, True, True, 0)

        notebook.append_page(tab1, Gtk.Label(label="Single File"))

        # ── Tab 2: Folder batch ──
        tab2 = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)

        dir_row = Gtk.Box(spacing=8)
        dir_row.set_border_width(10)
        self.dir_label = Gtk.Label(label="No folder selected")
        self.dir_label.set_xalign(0)
        self.dir_label.get_style_context().add_class("filepath")
        self.dir_label.set_hexpand(True)

        btn_dir = Gtk.Button(label="Choose Folder")
        btn_dir.get_style_context().add_class("btn-open")
        btn_dir.connect("clicked", self.on_choose_dir)

        self.chk_recursive = Gtk.CheckButton(label="Recursive")
        self.chk_recursive.set_active(True)
        self.chk_recursive.get_style_context().add_class("subtitle")

        self.chk_symbolic = Gtk.CheckButton(label="Rename → -symbolic")
        self.chk_symbolic.set_active(False)
        self.chk_symbolic.get_style_context().add_class("subtitle")

        dir_row.pack_start(btn_dir, False, False, 0)
        dir_row.pack_start(self.chk_recursive, False, False, 0)
        dir_row.pack_start(self.chk_symbolic, False, False, 0)
        dir_row.pack_start(self.dir_label, True, True, 0)
        tab2.pack_start(dir_row, False, False, 0)

        btn_row = Gtk.Box(spacing=8)
        btn_row.set_margin_start(10)
        btn_row.set_margin_bottom(6)

        self.btn_batch = Gtk.Button(label="Fix All SVGs")
        self.btn_batch.get_style_context().add_class("btn-fix")
        self.btn_batch.connect("clicked", self.on_batch_fix)
        self.btn_batch.set_sensitive(False)
        btn_row.pack_start(self.btn_batch, False, False, 0)

        self.batch_status = Gtk.Label(label="")
        self.batch_status.set_xalign(0)
        self.batch_status.get_style_context().add_class("status-ok")
        btn_row.pack_start(self.batch_status, False, False, 8)
        tab2.pack_start(btn_row, False, False, 0)

        scroll_log = Gtk.ScrolledWindow()
        self.log_view = Gtk.TextView()
        self.log_view.set_editable(False)
        self.log_view.set_monospace(True)
        scroll_log.add(self.log_view)
        tab2.pack_start(scroll_log, True, True, 0)

        notebook.append_page(tab2, Gtk.Label(label="Batch Folder"))

        self.batch_dir = None
        self.show_all()

    def on_choose_dir(self, btn):
        dialog = Gtk.FileChooserDialog(
            title="Choose Folder", parent=self,
            action=Gtk.FileChooserAction.SELECT_FOLDER
        )
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
                           Gtk.STOCK_OPEN, Gtk.ResponseType.OK)
        if dialog.run() == Gtk.ResponseType.OK:
            self.batch_dir = dialog.get_filename()
            self.dir_label.set_text(self.batch_dir)
            self.btn_batch.set_sensitive(True)
            svgs = self._find_svgs(self.batch_dir)
            self.batch_status.set_text(f"{len(svgs)} SVG files found")
        dialog.destroy()

    def _find_svgs(self, folder):
        svgs = []
        if self.chk_recursive.get_active():
            for root, _, files in os.walk(folder):
                for f in files:
                    if f.endswith(".svg"):
                        svgs.append(os.path.join(root, f))
        else:
            for f in os.listdir(folder):
                if f.endswith(".svg"):
                    svgs.append(os.path.join(folder, f))
        return svgs

    def on_batch_fix(self, btn):
        svgs = self._find_svgs(self.batch_dir)
        changed = 0
        skipped = 0
        log = []
        for path in svgs:
            try:
                with open(path, "r", encoding="utf-8") as f:
                    original = f.read()
                fixed = fix_svg(original)
                if fixed != original:
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(fixed)
                    changed += 1
                    log.append(f"✓ {os.path.relpath(path, self.batch_dir)}")
                else:
                    skipped += 1
                # Rename to -symbolic if checkbox active
                if self.chk_symbolic.get_active():
                    fname = os.path.basename(path)
                    if not fname.endswith("-symbolic.svg"):
                        newname = fname.replace(".svg", "-symbolic.svg")
                        newpath = os.path.join(os.path.dirname(path), newname)
                        os.rename(path, newpath)
                        log.append(f"  → {newname}")
            except Exception as e:
                log.append(f"✗ {os.path.relpath(path, self.batch_dir)}: {e}")
        summary = f"Done: {changed} fixed, {skipped} unchanged"
        self.batch_status.set_text(summary)
        log.insert(0, summary)
        log.insert(1, "─" * 40)
        self.log_view.get_buffer().set_text("\n".join(log))

    def on_open(self, btn):
        dialog = Gtk.FileChooserDialog(
            title="Open SVG", parent=self,
            action=Gtk.FileChooserAction.OPEN
        )
        dialog.add_buttons(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
                           Gtk.STOCK_OPEN, Gtk.ResponseType.OK)
        ffilter = Gtk.FileFilter()
        ffilter.set_name("SVG files")
        ffilter.add_pattern("*.svg")
        dialog.add_filter(ffilter)

        if dialog.run() == Gtk.ResponseType.OK:
            self.filepath = dialog.get_filename()
            self.filepath_label.set_text(self.filepath)
            with open(self.filepath, "r") as f:
                content = f.read()
            self.text_before.get_buffer().set_text(content)
            self.text_after.get_buffer().set_text("")
            self.fixed_content = None
            self.btn_fix.set_sensitive(True)
            self.btn_save.set_sensitive(False)
            self.set_status("", None)
        dialog.destroy()

    def on_fix(self, btn):
        buf = self.text_before.get_buffer()
        content = buf.get_text(buf.get_start_iter(), buf.get_end_iter(), True)
        self.fixed_content = fix_svg(content)
        self.text_after.get_buffer().set_text(self.fixed_content)
        if self.fixed_content != content:
            self.set_status("✓ Changes found – ready to save", "ok")
        else:
            self.set_status("No changes needed", "ok")
        self.btn_save.set_sensitive(True)

    def on_save(self, btn):
        with open(self.filepath, "w") as f:
            f.write(self.fixed_content)
        self.set_status(f"✓ Saved: {os.path.basename(self.filepath)}", "ok")

    def set_status(self, msg, kind):
        self.status_label.set_text(msg)
        ctx = self.status_label.get_style_context()
        ctx.remove_class("status-ok")
        ctx.remove_class("status-err")
        if kind == "ok":
            ctx.add_class("status-ok")
        elif kind == "err":
            ctx.add_class("status-err")

app = App()
app.connect("destroy", Gtk.main_quit)
Gtk.main()