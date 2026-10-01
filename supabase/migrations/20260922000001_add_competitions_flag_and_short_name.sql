-- Add flag and short_name columns to public.competitions
ALTER TABLE public.competitions 
ADD COLUMN IF NOT EXISTS flag text DEFAULT '🏆',
ADD COLUMN IF NOT EXISTS short_name text;

-- Backfill flags and short names for core competitions
UPDATE public.competitions SET flag = '🇪🇸', short_name = 'La Liga' WHERE id = '1';
UPDATE public.competitions SET flag = '🏴󠁧󠁢󠁥󠁮󠁧󠁿', short_name = 'Premier League' WHERE id = '10';
UPDATE public.competitions SET flag = '🇮🇹', short_name = 'Serie A' WHERE id = '7';
UPDATE public.competitions SET flag = '🇩🇪', short_name = 'Bundesliga' WHERE id = '8';
UPDATE public.competitions SET flag = '🇫🇷', short_name = 'Ligue 1' WHERE id = '16';
UPDATE public.competitions SET flag = '⭐', short_name = 'UCL' WHERE id = '107';
UPDATE public.competitions SET flag = '🟠', short_name = 'UEL' WHERE id = '117';
UPDATE public.competitions SET flag = '🟢', short_name = 'UECL' WHERE id = '2492';
