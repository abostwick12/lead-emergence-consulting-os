-- Consultant-private prospect notes remain service-role only. RLS adds
-- defense in depth without introducing any client-facing policy.
alter table consulting_private.prospect_notes enable row level security;
