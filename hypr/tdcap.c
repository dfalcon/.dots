#define _GNU_SOURCE
#include <dlfcn.h>
#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

XImage* XGetImage(Display* display, Drawable drawable,
                  int x, int y, unsigned int width, unsigned int height,
                  unsigned long plane_mask, int format) {
    static XImage* (*real)(Display*, Drawable, int, int,
                           unsigned int, unsigned int, unsigned long, int);
    if (!real) real = dlsym(RTLD_NEXT, "XGetImage");

    XImage* img = real(display, drawable, x, y, width, height, plane_mask, format);
    if (!img) return img;

    Window root = DefaultRootWindow(display);

    /* log every call for debugging */
    FILE* log = fopen("/tmp/tdcap_debug.log", "a");
    if (log) {
        fprintf(log, "XGetImage: drawable=%lu root=%lu w=%u h=%u bpp=%d match=%d\n",
                (unsigned long)drawable, (unsigned long)root,
                width, height, img->bits_per_pixel, drawable == root);
        fclose(log);
    }

    if (drawable != root || width < 200 || height < 200) return img;

    const char* wd = getenv("WAYLAND_DISPLAY");
    if (!wd) return img;

    pid_t pid = getpid();
    char png[80], raw[80], cmd[512];
    snprintf(png, sizeof(png), "/tmp/.tdgrim_%d.png", pid);
    snprintf(raw, sizeof(raw), "/tmp/.tdgrim_%d.raw", pid);

    snprintf(cmd, sizeof(cmd), "grim -t png '%s' 2>/dev/null", png);
    int rc1 = system(cmd);

    const char* fmt = (img->bits_per_pixel == 32) ? "BGRA" : "BGR";
    snprintf(cmd, sizeof(cmd),
        "convert '%s' -resize %ux%u! -depth 8 %s:'%s' 2>/dev/null",
        png, width, height, fmt, raw);
    int rc2 = system(cmd);

    FILE* log2 = fopen("/tmp/tdcap_debug.log", "a");
    if (log2) {
        fprintf(log2, "  -> grim rc=%d convert rc=%d fmt=%s\n", rc1, rc2, fmt);
        fclose(log2);
    }

    if (rc2 == 0) {
        FILE* f = fopen(raw, "rb");
        if (f) {
            fread(img->data, 1, (size_t)img->bytes_per_line * height, f);
            fclose(f);
        }
    }

    unlink(png); unlink(raw);
    return img;
}
