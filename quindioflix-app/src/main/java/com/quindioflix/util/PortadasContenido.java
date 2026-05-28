package com.quindioflix.util;

import java.util.Map;

/**
 * URLs de portada fijas por titulo (no dependen de red externa dinamica).
 */
public final class PortadasContenido {

    private static final String DEFAULT = "https://picsum.photos/seed/quindioflix-default/300/169";

    private static final Map<Long, String> POR_ID = Map.ofEntries(
            Map.entry(1L, "https://picsum.photos/seed/qf-guardian/300/169"),
            Map.entry(2L, "https://picsum.photos/seed/qf-digital/300/169"),
            Map.entry(3L, "https://picsum.photos/seed/qf-cafe/300/169"),
            Map.entry(4L, "https://picsum.photos/seed/qf-tango/300/169"),
            Map.entry(5L, "https://picsum.photos/seed/qf-bio/300/169"),
            Map.entry(6L, "https://picsum.photos/seed/qf-rojo/300/169"),
            Map.entry(7L, "https://picsum.photos/seed/qf-herencia/300/169"),
            Map.entry(8L, "https://picsum.photos/seed/qf-vuelo/300/169"),
            Map.entry(9L, "https://picsum.photos/seed/qf-cocora/300/169"),
            Map.entry(10L, "https://picsum.photos/seed/qf-voces/300/169"),
            Map.entry(11L, "https://picsum.photos/seed/qf-sombras/300/169"),
            Map.entry(12L, "https://picsum.photos/seed/qf-startup/300/169")
    );

    private PortadasContenido() {
    }

    public static String urlPara(Long idContenido) {
        if (idContenido == null) {
            return DEFAULT;
        }
        return POR_ID.getOrDefault(idContenido, "https://picsum.photos/seed/qf-" + idContenido + "/300/169");
    }
}
