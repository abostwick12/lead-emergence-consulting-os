-- The preceding migration adds consulting_os to PostgREST's exposed schemas.
-- Reload both configuration and the schema cache so newly exposed tables are
-- immediately addressable through the Data API.
notify pgrst, 'reload config';
notify pgrst, 'reload schema';
