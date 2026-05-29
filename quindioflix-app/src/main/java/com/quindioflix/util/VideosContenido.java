package com.quindioflix.util;

/**
 * Videos cortos servidos desde el mismo origen (static/videos) para evitar CORS y enlaces rotos.
 */
public final class VideosContenido {

    private static final String[] VIDEOS = {
            "/videos/demo1.mp4",
            "/videos/demo2.mp4",
            "/videos/demo3.mp4",
            "/videos/demo4.mp4"
    };

    private VideosContenido() {
    }

    public static String urlPara(Long idContenido) {
        if (idContenido == null || idContenido < 1) {
            return VIDEOS[0];
        }
        return VIDEOS[(int) ((idContenido - 1) % VIDEOS.length)];
    }

    /** Reemplaza URLs externas antiguas por rutas locales del servidor. */
    public static String normalizar(String urlGuardada, Long idContenido) {
        if (urlGuardada != null && urlGuardada.startsWith("/videos/")) {
            return urlGuardada;
        }
        return urlPara(idContenido);
    }
}
