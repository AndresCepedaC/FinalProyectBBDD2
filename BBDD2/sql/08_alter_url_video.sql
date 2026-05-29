-- =====================================================
-- Migracion: columna url_video en CONTENIDO (si ya existia la BD)
-- Ejecutar una sola vez sobre esquemas creados antes de esta columna
-- =====================================================

ALTER TABLE CONTENIDO ADD url_video VARCHAR2(500);

COMMENT ON COLUMN CONTENIDO.url_video IS 'URL del archivo de video (MP4) para reproduccion en la plataforma';

-- Asignar videos de demostracion a contenido existente
BEGIN
  FOR i IN (SELECT id_contenido FROM CONTENIDO) LOOP
    UPDATE CONTENIDO SET url_video = CASE MOD(i.id_contenido, 4)
      WHEN 0 THEN '/videos/demo1.mp4'
      WHEN 1 THEN '/videos/demo2.mp4'
      WHEN 2 THEN '/videos/demo3.mp4'
      ELSE '/videos/demo4.mp4'
    END
    WHERE id_contenido = i.id_contenido AND url_video IS NULL;
  END LOOP;
  COMMIT;
END;
/
