CREATE SCHEMA IF NOT EXISTS plan_c;

CREATE TABLE IF NOT EXISTS plan_c.assocs_dev(
      id  SERIAL PRIMARY KEY,
category  character varying(20) not null,
activity  character varying(25) not null,
duration  interval minute       not null,
   ctime  timestamp DEFAULT LOCALTIMESTAMP not null,
   stime  timestamp DEFAULT LOCALTIMESTAMP not null,
    usr  character varying(20) not null
);
