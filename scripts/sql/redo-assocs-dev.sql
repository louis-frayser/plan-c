set search_path=plan_c;
create or replace procedure redo_assocs_dev()
language plpgsql
as $$

begin
-- stored procedure body
TRUNCATE TABLE assocs_dev;
INSERT INTO assocs_dev (SELECT * from assocs);
PERFORM setval('assocs_dev_id_seq',
   COALESCE((SELECT MAX(id)+1 FROM assocs_dev),1),
   false);
end; $$
