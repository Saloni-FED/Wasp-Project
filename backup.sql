--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'expired',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.archive (
    id uuid NOT NULL,
    name text NOT NULL,
    priority integer NOT NULL,
    data jsonb,
    state pgboss.job_state NOT NULL,
    retrylimit integer NOT NULL,
    retrycount integer NOT NULL,
    retrydelay integer NOT NULL,
    retrybackoff boolean NOT NULL,
    startafter timestamp with time zone NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval NOT NULL,
    createdon timestamp with time zone NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone NOT NULL,
    on_complete boolean NOT NULL,
    output jsonb,
    archivedon timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.archive OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retrylimit integer DEFAULT 0 NOT NULL,
    retrycount integer DEFAULT 0 NOT NULL,
    retrydelay integer DEFAULT 0 NOT NULL,
    retrybackoff boolean DEFAULT false NOT NULL,
    startafter timestamp with time zone DEFAULT now() NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval DEFAULT '00:15:00'::interval NOT NULL,
    createdon timestamp with time zone DEFAULT now() NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone DEFAULT (now() + '14 days'::interval) NOT NULL,
    on_complete boolean DEFAULT false NOT NULL,
    output jsonb
);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    maintained_on timestamp with time zone,
    cron_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- Name: Auth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Auth" (
    id text NOT NULL,
    "userId" text
);


ALTER TABLE public."Auth" OWNER TO postgres;

--
-- Name: AuthIdentity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AuthIdentity" (
    "providerName" text NOT NULL,
    "providerUserId" text NOT NULL,
    "providerData" text DEFAULT '{}'::text NOT NULL,
    "authId" text NOT NULL
);


ALTER TABLE public."AuthIdentity" OWNER TO postgres;

--
-- Name: ContactFormMessage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ContactFormMessage" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    content text NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "repliedAt" timestamp(3) without time zone
);


ALTER TABLE public."ContactFormMessage" OWNER TO postgres;

--
-- Name: CsvFile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CsvFile" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "fileName" text NOT NULL,
    "originalName" text NOT NULL,
    "uploadedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "columnHeaders" text[],
    "rowCount" integer NOT NULL
);


ALTER TABLE public."CsvFile" OWNER TO postgres;

--
-- Name: CsvRow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CsvRow" (
    id text NOT NULL,
    "csvFileId" text NOT NULL,
    "rowData" jsonb NOT NULL,
    "rowIndex" integer NOT NULL
);


ALTER TABLE public."CsvRow" OWNER TO postgres;

--
-- Name: DailyStats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DailyStats" (
    id integer NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "totalViews" integer DEFAULT 0 NOT NULL,
    "prevDayViewsChangePercent" text DEFAULT '0'::text NOT NULL,
    "userCount" integer DEFAULT 0 NOT NULL,
    "paidUserCount" integer DEFAULT 0 NOT NULL,
    "userDelta" integer DEFAULT 0 NOT NULL,
    "paidUserDelta" integer DEFAULT 0 NOT NULL,
    "totalRevenue" double precision DEFAULT 0 NOT NULL,
    "totalProfit" double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public."DailyStats" OWNER TO postgres;

--
-- Name: DailyStats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DailyStats_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DailyStats_id_seq" OWNER TO postgres;

--
-- Name: DailyStats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DailyStats_id_seq" OWNED BY public."DailyStats".id;


--
-- Name: File; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."File" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    key text NOT NULL,
    "uploadUrl" text NOT NULL
);


ALTER TABLE public."File" OWNER TO postgres;

--
-- Name: GptResponse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."GptResponse" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL,
    content text NOT NULL
);


ALTER TABLE public."GptResponse" OWNER TO postgres;

--
-- Name: Logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Logs" (
    id integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    message text NOT NULL,
    level text NOT NULL
);


ALTER TABLE public."Logs" OWNER TO postgres;

--
-- Name: Logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Logs_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Logs_id_seq" OWNER TO postgres;

--
-- Name: Logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Logs_id_seq" OWNED BY public."Logs".id;


--
-- Name: PageViewSource; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PageViewSource" (
    name text NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "dailyStatsId" integer,
    visitors integer NOT NULL
);


ALTER TABLE public."PageViewSource" OWNER TO postgres;

--
-- Name: Session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Session" (
    id text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "userId" text NOT NULL
);


ALTER TABLE public."Session" OWNER TO postgres;

--
-- Name: Task; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Task" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "userId" text NOT NULL,
    description text NOT NULL,
    "time" text DEFAULT '1'::text NOT NULL,
    "isDone" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Task" OWNER TO postgres;

--
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."User" (
    id text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    email text,
    username text,
    "isAdmin" boolean DEFAULT false NOT NULL,
    "paymentProcessorUserId" text,
    "lemonSqueezyCustomerPortalUrl" text,
    "subscriptionStatus" text,
    "subscriptionPlan" text,
    "datePaid" timestamp(3) without time zone,
    credits integer DEFAULT 3 NOT NULL
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Name: DailyStats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DailyStats" ALTER COLUMN id SET DEFAULT nextval('public."DailyStats_id_seq"'::regclass);


--
-- Name: Logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs" ALTER COLUMN id SET DEFAULT nextval('public."Logs_id_seq"'::regclass);


--
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
12f9b231-9b3f-4110-aa30-1019337f9361	__pgboss__cron	0	\N	created	2	0	0	f	2025-06-03 15:28:01.359346+00	\N	\N	2025-06-03 15:28:00	00:15:00	2025-06-03 15:27:03.359346+00	\N	2025-06-03 15:29:01.359346+00	f	\N	2025-06-03 15:33:22.279847+00
66306834-8290-426e-a869-8e1b31c3d9ad	__pgboss__cron	0	\N	created	2	0	0	f	2025-06-03 15:38:01.824588+00	\N	\N	2025-06-03 15:38:00	00:15:00	2025-06-03 15:37:04.824588+00	\N	2025-06-03 15:39:01.824588+00	f	\N	2025-06-03 16:10:05.528688+00
40b38b9d-30cc-4655-8a02-3cf83721b30e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:37:20.615276+00	2025-06-03 14:37:20.624525+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:37:20.615276+00	2025-06-03 14:37:20.640333+00	2025-06-03 14:45:20.615276+00	f	\N	2025-06-04 03:28:58.797335+00
82bfe862-2dba-4c62-97ce-6b485bb3ebe7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:56:01.407689+00	2025-06-03 14:56:02.316718+00	\N	2025-06-03 14:56:00	00:15:00	2025-06-03 14:55:03.407689+00	2025-06-03 14:56:02.336428+00	2025-06-03 14:57:01.407689+00	f	\N	2025-06-04 03:28:58.797335+00
c6e29ef1-2206-45b3-86e7-378ad581fe1b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:56:03.985332+00	2025-06-03 14:56:09.874883+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:54:03.985332+00	2025-06-03 14:56:09.892824+00	2025-06-03 15:04:03.985332+00	f	\N	2025-06-04 03:28:58.797335+00
9d78d9b5-52a2-4dde-a1f0-0b8a40f77c25	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:37:20.651638+00	2025-06-03 14:37:24.638483+00	\N	2025-06-03 14:37:00	00:15:00	2025-06-03 14:37:20.651638+00	2025-06-03 14:37:24.678375+00	2025-06-03 14:38:20.651638+00	f	\N	2025-06-04 03:28:58.797335+00
7e7a0e8d-25a8-49cb-826b-e2445bdc9751	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:38:01.673852+00	2025-06-03 14:38:03.160203+00	\N	2025-06-03 14:38:00	00:15:00	2025-06-03 14:37:24.673852+00	2025-06-03 14:38:03.199373+00	2025-06-03 14:39:01.673852+00	f	\N	2025-06-04 03:28:58.797335+00
8b397bcb-2ff1-4d71-9d73-8cb4afe7951f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:57:01.333091+00	2025-06-03 14:57:03.86673+00	\N	2025-06-03 14:57:00	00:15:00	2025-06-03 14:56:02.333091+00	2025-06-03 14:57:03.8892+00	2025-06-03 14:58:01.333091+00	f	\N	2025-06-04 03:28:58.797335+00
e4794785-6f63-42af-bea4-e72ead02a5f7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:39:01.193533+00	2025-06-03 14:39:04.402777+00	\N	2025-06-03 14:39:00	00:15:00	2025-06-03 14:38:03.193533+00	2025-06-03 14:39:04.427491+00	2025-06-03 14:40:01.193533+00	f	\N	2025-06-04 03:28:58.797335+00
301427d8-81ff-4fef-9059-bb357036178b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:39:20.644952+00	2025-06-03 14:39:25.573208+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:37:20.644952+00	2025-06-03 14:39:25.592442+00	2025-06-03 14:47:20.644952+00	f	\N	2025-06-04 03:28:58.797335+00
bede9b2f-c61e-4011-9976-d612ae0dc3ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:58:01.885667+00	2025-06-03 14:58:02.796418+00	\N	2025-06-03 14:58:00	00:15:00	2025-06-03 14:57:03.885667+00	2025-06-03 14:58:02.817356+00	2025-06-03 14:59:01.885667+00	f	\N	2025-06-04 03:28:58.797335+00
96d7c69a-aff8-4607-b735-0c99bd27bfb8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:58:09.898529+00	2025-06-03 14:58:15.79415+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:56:09.898529+00	2025-06-03 14:58:15.810776+00	2025-06-03 15:06:09.898529+00	f	\N	2025-06-04 03:28:58.797335+00
15264b34-8d8a-409b-ac6f-867bcc6ee4a0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:40:01.424647+00	2025-06-03 14:40:02.855732+00	\N	2025-06-03 14:40:00	00:15:00	2025-06-03 14:39:04.424647+00	2025-06-03 14:40:02.888408+00	2025-06-03 14:41:01.424647+00	f	\N	2025-06-04 03:28:58.797335+00
37a2e1d2-90c6-4fc7-8de7-b3a710f1f66b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:41:01.883344+00	2025-06-03 14:41:05.639694+00	\N	2025-06-03 14:41:00	00:15:00	2025-06-03 14:40:02.883344+00	2025-06-03 14:41:05.676556+00	2025-06-03 14:42:01.883344+00	f	\N	2025-06-04 03:28:58.797335+00
701a8053-02f1-4c11-b7e4-a742e47e5659	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:41:25.59694+00	2025-06-03 14:41:30.91012+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:39:25.59694+00	2025-06-03 14:41:30.92823+00	2025-06-03 14:49:25.59694+00	f	\N	2025-06-04 03:28:58.797335+00
f7dbd28f-df83-4ae1-8b28-a2fd4a02c85d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:59:01.81206+00	2025-06-03 14:59:01.828413+00	\N	2025-06-03 14:59:00	00:15:00	2025-06-03 14:58:02.81206+00	2025-06-03 14:59:01.843288+00	2025-06-03 15:00:01.81206+00	f	\N	2025-06-04 03:28:58.797335+00
26cf38a2-5e5f-40f7-ad27-26d400d5ab30	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:42:01.67123+00	2025-06-03 14:42:04.436358+00	\N	2025-06-03 14:42:00	00:15:00	2025-06-03 14:41:05.67123+00	2025-06-03 14:42:04.466679+00	2025-06-03 14:43:01.67123+00	f	\N	2025-06-04 03:28:58.797335+00
effe8a0a-40b1-400d-be6b-85834ae3467b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:00:01.840647+00	2025-06-03 15:00:04.839556+00	\N	2025-06-03 15:00:00	00:15:00	2025-06-03 14:59:01.840647+00	2025-06-03 15:00:04.867411+00	2025-06-03 15:01:01.840647+00	f	\N	2025-06-04 03:28:58.797335+00
7b6b285f-e9b7-42e0-b71b-38723642b8ea	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:43:01.462803+00	2025-06-03 14:43:03.04321+00	\N	2025-06-03 14:43:00	00:15:00	2025-06-03 14:42:04.462803+00	2025-06-03 14:43:03.068949+00	2025-06-03 14:44:01.462803+00	f	\N	2025-06-04 03:28:58.797335+00
19df1849-7498-435b-b741-d1370a80b557	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:43:30.934316+00	2025-06-03 14:43:36.441186+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:41:30.934316+00	2025-06-03 14:43:36.452817+00	2025-06-03 14:51:30.934316+00	f	\N	2025-06-04 03:28:58.797335+00
650fe50c-64ae-477b-a260-44924f8bded6	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-06-03T14:37:20.710Z", "updated_on": "2025-06-03T14:37:20.710Z"}	completed	0	0	0	f	2025-06-03 15:00:04.853929+00	2025-06-03 15:00:08.841621+00	dailyStatsJob	2025-06-03 15:00:00	00:15:00	2025-06-03 15:00:04.853929+00	2025-06-03 15:00:08.856599+00	2025-06-17 15:00:04.853929+00	f	\N	2025-06-04 03:28:58.797335+00
3a11ba16-59fd-4e13-836b-20807f35f427	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:44:01.065097+00	2025-06-03 14:44:04.609692+00	\N	2025-06-03 14:44:00	00:15:00	2025-06-03 14:43:03.065097+00	2025-06-03 14:44:04.641774+00	2025-06-03 14:45:01.065097+00	f	\N	2025-06-04 03:28:58.797335+00
d0063678-b3ec-4996-808b-84eb12080860	dailyStatsJob	0	\N	completed	0	0	0	f	2025-06-03 15:00:08.850684+00	2025-06-03 15:00:08.978872+00	\N	\N	00:15:00	2025-06-03 15:00:08.850684+00	2025-06-03 15:00:09.384729+00	2025-06-17 15:00:08.850684+00	f	\N	2025-06-04 03:28:58.797335+00
1ceb6043-e262-4288-a2d2-d3623f80d6bf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:45:01.636061+00	2025-06-03 14:45:03.497011+00	\N	2025-06-03 14:45:00	00:15:00	2025-06-03 14:44:04.636061+00	2025-06-03 14:45:03.532487+00	2025-06-03 14:46:01.636061+00	f	\N	2025-06-04 03:28:58.797335+00
d20fe013-b677-442f-9372-5c9548e20ca5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:00:15.81534+00	2025-06-03 15:00:20.322323+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:58:15.81534+00	2025-06-03 15:00:20.336892+00	2025-06-03 15:08:15.81534+00	f	\N	2025-06-04 03:28:58.797335+00
f76c7ca3-edc6-4bcd-8761-f3cdb1eeb104	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:45:36.458018+00	2025-06-03 14:45:40.856461+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:43:36.458018+00	2025-06-03 14:45:40.872027+00	2025-06-03 14:53:36.458018+00	f	\N	2025-06-04 03:28:58.797335+00
55cab3c5-4b72-4b15-a48e-81d2bece8486	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:46:01.526858+00	2025-06-03 14:46:02.665716+00	\N	2025-06-03 14:46:00	00:15:00	2025-06-03 14:45:03.526858+00	2025-06-03 14:46:02.694518+00	2025-06-03 14:47:01.526858+00	f	\N	2025-06-04 03:28:58.797335+00
b27f8a3b-8afa-41fd-9379-5b687eb498da	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:01:01.863435+00	2025-06-03 15:01:03.916686+00	\N	2025-06-03 15:01:00	00:15:00	2025-06-03 15:00:04.863435+00	2025-06-03 15:01:03.936085+00	2025-06-03 15:02:01.863435+00	f	\N	2025-06-04 03:28:58.797335+00
e1ab39e6-de64-49f1-8da7-7cff909ec64b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:47:01.689182+00	2025-06-03 14:47:02.050498+00	\N	2025-06-03 14:47:00	00:15:00	2025-06-03 14:46:02.689182+00	2025-06-03 14:47:02.078483+00	2025-06-03 14:48:01.689182+00	f	\N	2025-06-04 03:28:58.797335+00
022fa017-e497-4dec-b458-41cae170f02a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:47:40.877411+00	2025-06-03 14:47:47.413781+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:45:40.877411+00	2025-06-03 14:47:47.427226+00	2025-06-03 14:55:40.877411+00	f	\N	2025-06-04 03:28:58.797335+00
e1966087-7364-4812-9f00-00101de56a62	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:02:01.930155+00	2025-06-03 15:02:05.414266+00	\N	2025-06-03 15:02:00	00:15:00	2025-06-03 15:01:03.930155+00	2025-06-03 15:02:05.438124+00	2025-06-03 15:03:01.930155+00	f	\N	2025-06-04 03:28:58.797335+00
f6a1248e-e17b-47f4-8c70-351833f132b9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:02:20.342475+00	2025-06-03 15:02:26.344711+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:00:20.342475+00	2025-06-03 15:02:26.361392+00	2025-06-03 15:10:20.342475+00	f	\N	2025-06-04 03:28:58.797335+00
e197ffd3-4d93-4522-9ac2-7801713dc33a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:48:01.073771+00	2025-06-03 14:48:03.6771+00	\N	2025-06-03 14:48:00	00:15:00	2025-06-03 14:47:02.073771+00	2025-06-03 14:48:03.706312+00	2025-06-03 14:49:01.073771+00	f	\N	2025-06-04 03:28:58.797335+00
ce2170a5-1981-432d-9930-99a6e8e5ea0d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:49:01.701147+00	2025-06-03 14:49:02.82522+00	\N	2025-06-03 14:49:00	00:15:00	2025-06-03 14:48:03.701147+00	2025-06-03 14:49:02.854791+00	2025-06-03 14:50:01.701147+00	f	\N	2025-06-04 03:28:58.797335+00
9e22e7f8-dca5-4359-8d65-6ed2a2b8846f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:49:47.430187+00	2025-06-03 14:49:53.546913+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:47:47.430187+00	2025-06-03 14:49:53.555982+00	2025-06-03 14:57:47.430187+00	f	\N	2025-06-04 03:28:58.797335+00
85f03e1f-a753-492d-84ac-d037726907f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:03:01.433077+00	2025-06-03 15:03:04.459545+00	\N	2025-06-03 15:03:00	00:15:00	2025-06-03 15:02:05.433077+00	2025-06-03 15:03:04.487525+00	2025-06-03 15:04:01.433077+00	f	\N	2025-06-04 03:28:58.797335+00
a790db19-2f70-4a05-be8a-fea216873ad3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:50:01.849924+00	2025-06-03 14:50:01.857498+00	\N	2025-06-03 14:50:00	00:15:00	2025-06-03 14:49:02.849924+00	2025-06-03 14:50:01.881976+00	2025-06-03 14:51:01.849924+00	f	\N	2025-06-04 03:28:58.797335+00
6848bdb8-b4b5-4f16-92de-b80e05ee60bc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:04:26.366409+00	2025-06-03 15:04:32.42907+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:02:26.366409+00	2025-06-03 15:04:32.44161+00	2025-06-03 15:12:26.366409+00	f	\N	2025-06-04 03:28:58.797335+00
44d5d669-80ea-45e1-87d7-eba324690c22	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:51:01.877418+00	2025-06-03 14:51:04.945477+00	\N	2025-06-03 14:51:00	00:15:00	2025-06-03 14:50:01.877418+00	2025-06-03 14:51:04.980934+00	2025-06-03 14:52:01.877418+00	f	\N	2025-06-04 03:28:58.797335+00
91b03e18-29d6-408d-a167-3451a317adc9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:51:53.560284+00	2025-06-03 14:51:58.109106+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:49:53.560284+00	2025-06-03 14:51:58.126629+00	2025-06-03 14:59:53.560284+00	f	\N	2025-06-04 03:28:58.797335+00
53f1cf01-83b7-464a-8d6f-72844ceb417b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:07:01.197947+00	2025-06-03 15:07:03.37324+00	\N	2025-06-03 15:07:00	00:15:00	2025-06-03 15:06:04.197947+00	2025-06-03 15:07:03.394224+00	2025-06-03 15:08:01.197947+00	f	\N	2025-06-04 03:28:58.797335+00
a9eff1b6-75e7-4781-8d57-fde483778284	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:52:01.976498+00	2025-06-03 14:52:04.074671+00	\N	2025-06-03 14:52:00	00:15:00	2025-06-03 14:51:04.976498+00	2025-06-03 14:52:04.096905+00	2025-06-03 14:53:01.976498+00	f	\N	2025-06-04 03:28:58.797335+00
7ddfa599-fe2e-4361-8330-c02041eaedda	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:53:01.09305+00	2025-06-03 14:53:01.42515+00	\N	2025-06-03 14:53:00	00:15:00	2025-06-03 14:52:04.09305+00	2025-06-03 14:53:01.463007+00	2025-06-03 14:54:01.09305+00	f	\N	2025-06-04 03:28:58.797335+00
2a519dd6-bee6-44b4-80cd-3558a2b23430	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 14:53:58.131017+00	2025-06-03 14:54:03.964344+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 14:51:58.131017+00	2025-06-03 14:54:03.979787+00	2025-06-03 15:01:58.131017+00	f	\N	2025-06-04 03:28:58.797335+00
9cd7d2a8-a128-4968-b2c0-447c4037c5b3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:54:01.452122+00	2025-06-03 14:54:04.372532+00	\N	2025-06-03 14:54:00	00:15:00	2025-06-03 14:53:01.452122+00	2025-06-03 14:54:04.395761+00	2025-06-03 14:55:01.452122+00	f	\N	2025-06-04 03:28:58.797335+00
8024e3bc-0072-4da8-b00d-6f28522419cc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 14:55:01.987993+00	2025-06-03 14:55:03.385953+00	\N	2025-06-03 14:55:00	00:15:00	2025-06-03 14:54:03.987993+00	2025-06-03 14:55:03.417928+00	2025-06-03 14:56:01.987993+00	f	\N	2025-06-04 03:28:58.797335+00
4a3f5c44-52f6-4066-96c7-97a52c5b7e6a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:04:01.482338+00	2025-06-03 15:04:03.470766+00	\N	2025-06-03 15:04:00	00:15:00	2025-06-03 15:03:04.482338+00	2025-06-03 15:04:03.492471+00	2025-06-03 15:05:01.482338+00	f	\N	2025-06-04 03:28:58.797335+00
48aa0fb9-19d3-4810-99aa-6dd1c68d2267	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:05:01.487462+00	2025-06-03 15:05:02.622701+00	\N	2025-06-03 15:05:00	00:15:00	2025-06-03 15:04:03.487462+00	2025-06-03 15:05:02.651311+00	2025-06-03 15:06:01.487462+00	f	\N	2025-06-04 03:28:58.797335+00
ab22a05f-8343-4f6e-9ae5-21f5e00e2362	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:06:01.645344+00	2025-06-03 15:06:04.179807+00	\N	2025-06-03 15:06:00	00:15:00	2025-06-03 15:05:02.645344+00	2025-06-03 15:06:04.203083+00	2025-06-03 15:07:01.645344+00	f	\N	2025-06-04 03:28:58.797335+00
3a8c9dbe-df67-4d27-963d-163aa930422d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:18:55.667041+00	2025-06-03 15:19:00.788583+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:16:55.667041+00	2025-06-03 15:19:00.802012+00	2025-06-03 15:26:55.667041+00	f	\N	2025-06-04 03:28:58.797335+00
140d2a19-b7da-4633-9526-b3a85ce48d73	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:19:01.245119+00	2025-06-03 15:19:01.806302+00	\N	2025-06-03 15:19:00	00:15:00	2025-06-03 15:18:03.245119+00	2025-06-03 15:19:01.825377+00	2025-06-03 15:20:01.245119+00	f	\N	2025-06-04 03:28:58.797335+00
0c08f82a-2f3c-45f7-b74c-a347b97b7f02	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:09:01.080844+00	2025-06-03 15:09:02.020153+00	\N	2025-06-03 15:09:00	00:15:00	2025-06-03 15:08:05.080844+00	2025-06-03 15:09:02.038179+00	2025-06-03 15:10:01.080844+00	f	\N	2025-06-04 03:28:58.797335+00
be980c7b-37db-49c0-af2b-224bad3f6174	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:10:01.035097+00	2025-06-03 15:10:02.959354+00	\N	2025-06-03 15:10:00	00:15:00	2025-06-03 15:09:02.035097+00	2025-06-03 15:10:02.974157+00	2025-06-03 15:11:01.035097+00	f	\N	2025-06-04 03:28:58.797335+00
027d450b-549f-42ec-867e-2ebc950426f9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:10:41.242337+00	2025-06-03 15:10:43.195473+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:08:41.242337+00	2025-06-03 15:10:43.206732+00	2025-06-03 15:18:41.242337+00	f	\N	2025-06-04 03:28:58.797335+00
f3115216-a4d2-433c-80be-5c19740f5908	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:20:01.822915+00	2025-06-03 15:20:04.963648+00	\N	2025-06-03 15:20:00	00:15:00	2025-06-03 15:19:01.822915+00	2025-06-03 15:20:04.978841+00	2025-06-03 15:21:01.822915+00	f	\N	2025-06-04 03:28:58.797335+00
2c3ec05c-4362-4c89-a029-1cab23201c5d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:21:01.309503+00	2025-06-03 15:21:02.635389+00	\N	2025-06-03 15:21:00	00:15:00	2025-06-03 15:20:02.309503+00	2025-06-03 15:21:02.652956+00	2025-06-03 15:22:01.309503+00	f	\N	2025-06-04 03:28:58.797335+00
8448cad9-8ebe-489e-a082-9d4901c63f56	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:22:01.649416+00	2025-06-03 15:22:01.850649+00	\N	2025-06-03 15:22:00	00:15:00	2025-06-03 15:21:02.649416+00	2025-06-03 15:22:01.869264+00	2025-06-03 15:23:01.649416+00	f	\N	2025-06-04 03:28:58.797335+00
3a40a106-a88e-4576-a4c1-901402dceb96	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:25:11.944128+00	2025-06-03 15:25:17.756546+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:23:11.944128+00	2025-06-03 15:25:17.877097+00	2025-06-03 15:33:11.944128+00	f	\N	2025-06-04 03:28:58.797335+00
2941a393-ff56-4ea2-920b-c29393d4ebfb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:26:01.385387+00	2025-06-03 15:26:04.440117+00	\N	2025-06-03 15:26:00	00:15:00	2025-06-03 15:25:05.385387+00	2025-06-03 15:26:04.451372+00	2025-06-03 15:27:01.385387+00	f	\N	2025-06-04 03:28:58.797335+00
14f322bb-d1c6-4a02-9036-5dd88b3e501e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:27:17.881187+00	2025-06-03 15:27:23.630843+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:25:17.881187+00	2025-06-03 15:27:23.636967+00	2025-06-03 15:35:17.881187+00	f	\N	2025-06-04 03:28:58.797335+00
3ce7ae98-304e-44a9-9b70-ca9aef630616	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:06:32.447925+00	2025-06-03 15:06:37.080319+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:04:32.447925+00	2025-06-03 15:06:37.228762+00	2025-06-03 15:14:32.447925+00	f	\N	2025-06-04 03:28:58.797335+00
ec3a146d-585b-4ba8-9442-e5982304c8f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:16:01.103787+00	2025-06-03 15:16:02.276655+00	\N	2025-06-03 15:16:00	00:15:00	2025-06-03 15:15:05.103787+00	2025-06-03 15:16:02.28706+00	2025-06-03 15:17:01.103787+00	f	\N	2025-06-04 03:28:58.797335+00
0ad58954-ea27-46ff-8cfe-8adfff5bdfd1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:16:50.970282+00	2025-06-03 15:16:55.658276+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:14:50.970282+00	2025-06-03 15:16:55.665664+00	2025-06-03 15:24:50.970282+00	f	\N	2025-06-04 03:28:58.797335+00
563e7008-c0d3-429f-92f4-ec23d682f30e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:08:01.390356+00	2025-06-03 15:08:05.054224+00	\N	2025-06-03 15:08:00	00:15:00	2025-06-03 15:07:03.390356+00	2025-06-03 15:08:05.086006+00	2025-06-03 15:09:01.390356+00	f	\N	2025-06-04 03:28:58.797335+00
60824541-40e9-45a2-a514-d63882706b14	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:08:37.234601+00	2025-06-03 15:08:41.225494+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:06:37.234601+00	2025-06-03 15:08:41.230624+00	2025-06-03 15:16:37.234601+00	f	\N	2025-06-04 03:28:58.797335+00
e2dee194-b57f-4edd-bad7-8cb8ea1a249a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:17:01.284112+00	2025-06-03 15:17:04.627275+00	\N	2025-06-03 15:17:00	00:15:00	2025-06-03 15:16:02.284112+00	2025-06-03 15:17:04.639001+00	2025-06-03 15:18:01.284112+00	f	\N	2025-06-04 03:28:58.797335+00
6a72279a-d456-461f-ba00-0c25ff0cde4e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:18:01.636963+00	2025-06-03 15:18:03.230794+00	\N	2025-06-03 15:18:00	00:15:00	2025-06-03 15:17:04.636963+00	2025-06-03 15:18:03.248514+00	2025-06-03 15:19:01.636963+00	f	\N	2025-06-04 03:28:58.797335+00
c1a2b697-f11a-48ac-b358-e593f3abb666	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:11:01.970394+00	2025-06-03 15:11:04.036359+00	\N	2025-06-03 15:11:00	00:15:00	2025-06-03 15:10:02.970394+00	2025-06-03 15:11:04.052189+00	2025-06-03 15:12:01.970394+00	f	\N	2025-06-04 03:28:58.797335+00
811854b0-5601-4ed9-8f75-5619ef5d72f7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:12:01.048854+00	2025-06-03 15:12:02.13957+00	\N	2025-06-03 15:12:00	00:15:00	2025-06-03 15:11:04.048854+00	2025-06-03 15:12:02.148985+00	2025-06-03 15:13:01.048854+00	f	\N	2025-06-04 03:28:58.797335+00
0881cce7-20e5-44b6-b994-53908db9918d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:21:00.805482+00	2025-06-03 15:21:05.579375+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:19:00.805482+00	2025-06-03 15:21:05.589805+00	2025-06-03 15:29:00.805482+00	f	\N	2025-06-04 03:28:58.797335+00
f7217e77-f8e0-4287-a6a0-4bb310f384b2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:12:43.209107+00	2025-06-03 15:12:46.401784+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:10:43.209107+00	2025-06-03 15:12:46.41641+00	2025-06-03 15:20:43.209107+00	f	\N	2025-06-04 03:28:58.797335+00
0bc11d42-b6e3-41ad-8641-67129bc6a40e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:13:01.14697+00	2025-06-03 15:13:04.345193+00	\N	2025-06-03 15:13:00	00:15:00	2025-06-03 15:12:02.14697+00	2025-06-03 15:13:04.356161+00	2025-06-03 15:14:01.14697+00	f	\N	2025-06-04 03:28:58.797335+00
1c4ec5be-2925-417c-8f47-04a80da6eee5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:23:01.865942+00	2025-06-03 15:23:05.033512+00	\N	2025-06-03 15:23:00	00:15:00	2025-06-03 15:22:01.865942+00	2025-06-03 15:23:05.043508+00	2025-06-03 15:24:01.865942+00	f	\N	2025-06-04 03:28:58.797335+00
bfc31a8d-d19e-4fae-b152-89cd17547b4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:14:01.353532+00	2025-06-03 15:14:02.655306+00	\N	2025-06-03 15:14:00	00:15:00	2025-06-03 15:13:04.353532+00	2025-06-03 15:14:02.674032+00	2025-06-03 15:15:01.353532+00	f	\N	2025-06-04 03:28:58.797335+00
a06b3be3-f600-4165-be6b-e1810d9d4252	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:14:46.420075+00	2025-06-03 15:14:50.962524+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:12:46.420075+00	2025-06-03 15:14:50.968608+00	2025-06-03 15:22:46.420075+00	f	\N	2025-06-04 03:28:58.797335+00
0caf1b9e-84d4-4105-b2cb-108dea79ab44	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:23:05.591712+00	2025-06-03 15:23:11.938967+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:21:05.591712+00	2025-06-03 15:23:11.942464+00	2025-06-03 15:31:05.591712+00	f	\N	2025-06-04 03:28:58.797335+00
1b37485d-c596-47d2-94a4-2cf733437b8b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:15:01.671366+00	2025-06-03 15:15:05.095398+00	\N	2025-06-03 15:15:00	00:15:00	2025-06-03 15:14:02.671366+00	2025-06-03 15:15:05.105922+00	2025-06-03 15:16:01.671366+00	f	\N	2025-06-04 03:28:58.797335+00
2a0aa825-bc88-4680-841d-b5ffbd496118	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:24:01.041391+00	2025-06-03 15:24:03.826992+00	\N	2025-06-03 15:24:00	00:15:00	2025-06-03 15:23:05.041391+00	2025-06-03 15:24:03.842108+00	2025-06-03 15:25:01.041391+00	f	\N	2025-06-04 03:28:58.797335+00
aeca6780-3afa-4da3-b33d-b0bd8fbc2b3a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:25:01.83945+00	2025-06-03 15:25:05.377006+00	\N	2025-06-03 15:25:00	00:15:00	2025-06-03 15:24:03.83945+00	2025-06-03 15:25:05.388502+00	2025-06-03 15:26:01.83945+00	f	\N	2025-06-04 03:28:58.797335+00
192f315f-f2c6-40ad-a5cc-2ed5fcf37882	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:27:01.448945+00	2025-06-03 15:27:03.346897+00	\N	2025-06-03 15:27:00	00:15:00	2025-06-03 15:26:04.448945+00	2025-06-03 15:27:03.361749+00	2025-06-03 15:28:01.448945+00	f	\N	2025-06-04 03:28:58.797335+00
4355b348-3b66-43a4-a166-d306687d88b4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:13:01.607392+00	2025-06-03 16:13:02.242149+00	\N	2025-06-03 16:13:00	00:15:00	2025-06-03 16:12:04.607392+00	2025-06-03 16:13:02.258556+00	2025-06-03 16:14:01.607392+00	f	\N	2025-06-04 14:28:58.257204+00
ef32dd28-b672-4b16-8a56-f147686490cb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:14:01.255346+00	2025-06-03 16:14:01.779121+00	\N	2025-06-03 16:14:00	00:15:00	2025-06-03 16:13:02.255346+00	2025-06-03 16:14:01.824189+00	2025-06-03 16:15:01.255346+00	f	\N	2025-06-04 14:28:58.257204+00
0d3fc831-1e7a-4878-b8c7-df19ff495cd5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:15:01.800524+00	2025-06-03 16:15:05.231139+00	\N	2025-06-03 16:15:00	00:15:00	2025-06-03 16:14:01.800524+00	2025-06-03 16:15:05.250371+00	2025-06-03 16:16:01.800524+00	f	\N	2025-06-04 14:28:58.257204+00
493ab87a-5cab-4ab8-bd26-53bce7c4629b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:17:01.701882+00	2025-06-03 16:17:02.429948+00	\N	2025-06-03 16:17:00	00:15:00	2025-06-03 16:16:04.701882+00	2025-06-03 16:17:02.443139+00	2025-06-03 16:18:01.701882+00	f	\N	2025-06-04 14:28:58.257204+00
f3d113c4-b0e7-45c5-9c7f-7877ca2ec897	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:18:01.439982+00	2025-06-03 16:18:01.875562+00	\N	2025-06-03 16:18:00	00:15:00	2025-06-03 16:17:02.439982+00	2025-06-03 16:18:01.886347+00	2025-06-03 16:19:01.439982+00	f	\N	2025-06-04 14:28:58.257204+00
0f55c6b6-8927-4711-8474-f9b8a52c2c49	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:20:01.502094+00	2025-06-03 16:20:04.689242+00	\N	2025-06-03 16:20:00	00:15:00	2025-06-03 16:19:05.502094+00	2025-06-03 16:20:04.710484+00	2025-06-03 16:21:01.502094+00	f	\N	2025-06-04 14:28:58.257204+00
16bea687-3490-4245-b663-9ca3cd276a08	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:33:22.266039+00	2025-06-03 15:33:22.272658+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:33:22.266039+00	2025-06-03 15:33:22.289602+00	2025-06-03 15:41:22.266039+00	f	\N	2025-06-04 14:28:58.257204+00
341006d9-adab-4a5e-955b-28c346d00631	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:20:31.368663+00	2025-06-03 16:20:38.187952+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:18:31.368663+00	2025-06-03 16:20:38.197635+00	2025-06-03 16:28:31.368663+00	f	\N	2025-06-04 14:28:58.257204+00
b7cc60b4-0b5d-448a-805c-71880b4e818d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:35:22.292762+00	2025-06-03 15:35:28.198322+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:33:22.292762+00	2025-06-03 15:35:28.215438+00	2025-06-03 15:43:22.292762+00	f	\N	2025-06-04 14:28:58.257204+00
7dc83bcd-3247-491a-a897-071669aaa818	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:22:01.184+00	2025-06-03 16:22:01.892749+00	\N	2025-06-03 16:22:00	00:15:00	2025-06-03 16:21:04.184+00	2025-06-03 16:22:01.906881+00	2025-06-03 16:23:01.184+00	f	\N	2025-06-04 14:28:58.257204+00
0bb97c70-be4e-4bdc-8f5f-aebae1e3bb53	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:36:01.819976+00	2025-06-03 15:36:05.798708+00	\N	2025-06-03 15:36:00	00:15:00	2025-06-03 15:35:02.819976+00	2025-06-03 15:36:05.828692+00	2025-06-03 15:37:01.819976+00	f	\N	2025-06-04 14:28:58.257204+00
c9650a2f-bfe0-4e00-9efc-7172ef95345b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:37:01.823653+00	2025-06-03 15:37:04.798245+00	\N	2025-06-03 15:37:00	00:15:00	2025-06-03 15:36:05.823653+00	2025-06-03 15:37:04.829365+00	2025-06-03 15:38:01.823653+00	f	\N	2025-06-04 14:28:58.257204+00
f341c642-03e0-4bf6-9ad0-1678eb417521	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:22:38.200541+00	2025-06-03 16:22:43.340556+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:20:38.200541+00	2025-06-03 16:22:43.348746+00	2025-06-03 16:30:38.200541+00	f	\N	2025-06-04 14:28:58.257204+00
b6efa091-5f09-4ac7-ac4b-960063f22dc8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:10:05.538753+00	2025-06-03 16:10:09.53271+00	\N	2025-06-03 16:10:00	00:15:00	2025-06-03 16:10:05.538753+00	2025-06-03 16:10:09.552712+00	2025-06-03 16:11:05.538753+00	f	\N	2025-06-04 14:28:58.257204+00
ccaca461-5e82-4916-8e20-95be6273af91	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:24:01.361728+00	2025-06-03 16:24:04.800906+00	\N	2025-06-03 16:24:00	00:15:00	2025-06-03 16:23:05.361728+00	2025-06-03 16:24:04.816646+00	2025-06-03 16:25:01.361728+00	f	\N	2025-06-04 14:28:58.257204+00
0e9a306e-f313-43cd-bc6a-52661bf83df9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:12:01.187033+00	2025-06-03 16:12:04.589959+00	\N	2025-06-03 16:12:00	00:15:00	2025-06-03 16:11:05.187033+00	2025-06-03 16:12:04.609935+00	2025-06-03 16:13:01.187033+00	f	\N	2025-06-04 14:28:58.257204+00
1f9aa19a-c01e-4914-827d-51633b998065	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:27:01.047752+00	2025-06-03 16:27:01.369418+00	\N	2025-06-03 16:27:00	00:15:00	2025-06-03 16:26:02.047752+00	2025-06-03 16:27:01.379732+00	2025-06-03 16:28:01.047752+00	f	\N	2025-06-04 14:28:58.257204+00
890476c1-3173-427f-961c-595ae78fb5e7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:28:01.377447+00	2025-06-03 16:28:04.826066+00	\N	2025-06-03 16:28:00	00:15:00	2025-06-03 16:27:01.377447+00	2025-06-03 16:28:04.842308+00	2025-06-03 16:29:01.377447+00	f	\N	2025-06-04 14:28:58.257204+00
21ab869b-8937-43e6-bbf9-bd3537aebfb9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:14:12.550472+00	2025-06-03 16:14:19.391782+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:12:12.550472+00	2025-06-03 16:14:19.39834+00	2025-06-03 16:22:12.550472+00	f	\N	2025-06-04 14:28:58.257204+00
5b6b9bc3-4ffb-4878-8d8a-2c0f7e89d7f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:16:01.248109+00	2025-06-03 16:16:04.690957+00	\N	2025-06-03 16:16:00	00:15:00	2025-06-03 16:15:05.248109+00	2025-06-03 16:16:04.704212+00	2025-06-03 16:17:01.248109+00	f	\N	2025-06-04 14:28:58.257204+00
5cea694e-29f9-4e75-af69-23e104f0ccb8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:16:19.400178+00	2025-06-03 16:16:24.547953+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:14:19.400178+00	2025-06-03 16:16:24.562081+00	2025-06-03 16:24:19.400178+00	f	\N	2025-06-04 14:28:58.257204+00
04d3cfb8-4809-47d6-97d0-f113f1b2db41	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:18:24.564735+00	2025-06-03 16:18:31.357448+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:16:24.564735+00	2025-06-03 16:18:31.367115+00	2025-06-03 16:26:24.564735+00	f	\N	2025-06-04 14:28:58.257204+00
b86df807-2e9a-4a75-b97f-00e5037a27a9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:19:01.884518+00	2025-06-03 16:19:05.489923+00	\N	2025-06-03 16:19:00	00:15:00	2025-06-03 16:18:01.884518+00	2025-06-03 16:19:05.504019+00	2025-06-03 16:20:01.884518+00	f	\N	2025-06-04 14:28:58.257204+00
6357ae64-f943-42ea-bfc2-69ca60db5088	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:21:01.707952+00	2025-06-03 16:21:04.173197+00	\N	2025-06-03 16:21:00	00:15:00	2025-06-03 16:20:04.707952+00	2025-06-03 16:21:04.185906+00	2025-06-03 16:22:01.707952+00	f	\N	2025-06-04 14:28:58.257204+00
3b12f0fc-1db0-45ad-b309-4526ba3fd2cf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:23:01.903438+00	2025-06-03 16:23:05.341276+00	\N	2025-06-03 16:23:00	00:15:00	2025-06-03 16:22:01.903438+00	2025-06-03 16:23:05.365099+00	2025-06-03 16:24:01.903438+00	f	\N	2025-06-04 14:28:58.257204+00
d4671a3b-20dd-4db6-8e45-eb8e4f997db8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:24:45.070858+00	2025-06-03 16:24:48.56135+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:22:45.070858+00	2025-06-03 16:24:48.573856+00	2025-06-03 16:32:45.070858+00	f	\N	2025-06-04 14:28:58.257204+00
742e8332-daed-449f-be5a-8f2a5c69e1e0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:33:22.295278+00	2025-06-03 15:33:26.285488+00	\N	2025-06-03 15:33:00	00:15:00	2025-06-03 15:33:22.295278+00	2025-06-03 15:33:26.325809+00	2025-06-03 15:34:22.295278+00	f	\N	2025-06-04 14:28:58.257204+00
4def9a90-8c5f-449e-a166-6ac73c5a9f1b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:34:01.320513+00	2025-06-03 15:34:03.799412+00	\N	2025-06-03 15:34:00	00:15:00	2025-06-03 15:33:26.320513+00	2025-06-03 15:34:03.840133+00	2025-06-03 15:35:01.320513+00	f	\N	2025-06-04 14:28:58.257204+00
daaebd1f-da1d-4cd4-a93e-af1dead0bb1c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 15:35:01.834808+00	2025-06-03 15:35:02.787534+00	\N	2025-06-03 15:35:00	00:15:00	2025-06-03 15:34:03.834808+00	2025-06-03 15:35:02.825019+00	2025-06-03 15:36:01.834808+00	f	\N	2025-06-04 14:28:58.257204+00
82388c20-e4b4-4a0e-b097-658f59d14eb9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:25:01.814328+00	2025-06-03 16:25:04.330571+00	\N	2025-06-03 16:25:00	00:15:00	2025-06-03 16:24:04.814328+00	2025-06-03 16:25:04.344251+00	2025-06-03 16:26:01.814328+00	f	\N	2025-06-04 14:28:58.257204+00
c8d8e9e1-9b03-4b2e-aa5c-bbc97d0bca00	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:26:01.342767+00	2025-06-03 16:26:02.032506+00	\N	2025-06-03 16:26:00	00:15:00	2025-06-03 16:25:04.342767+00	2025-06-03 16:26:02.051481+00	2025-06-03 16:27:01.342767+00	f	\N	2025-06-04 14:28:58.257204+00
d2e1acc5-c108-4732-ba50-a034e4ba4a21	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 15:37:28.220493+00	2025-06-03 15:37:34.175196+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 15:35:28.220493+00	2025-06-03 15:37:34.193347+00	2025-06-03 15:45:28.220493+00	f	\N	2025-06-04 14:28:58.257204+00
32aba7d0-809a-41ec-b9f8-bf5ccc6d779f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:26:48.57678+00	2025-06-03 16:26:55.291114+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:24:48.57678+00	2025-06-03 16:26:55.306034+00	2025-06-03 16:34:48.57678+00	f	\N	2025-06-04 14:28:58.257204+00
56f88114-4f99-425e-bb5f-96b4b8690811	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:10:05.518291+00	2025-06-03 16:10:05.522437+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:10:05.518291+00	2025-06-03 16:10:05.534205+00	2025-06-03 16:18:05.518291+00	f	\N	2025-06-04 14:28:58.257204+00
8478ab59-90a2-4457-a69f-0b913a05479f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:11:01.550022+00	2025-06-03 16:11:05.175915+00	\N	2025-06-03 16:11:00	00:15:00	2025-06-03 16:10:09.550022+00	2025-06-03 16:11:05.189541+00	2025-06-03 16:12:01.550022+00	f	\N	2025-06-04 14:28:58.257204+00
33dc6e2e-1681-4c62-a604-93ae40674aed	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:12:05.536423+00	2025-06-03 16:12:12.533865+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:10:05.536423+00	2025-06-03 16:12:12.548065+00	2025-06-03 16:20:05.536423+00	f	\N	2025-06-04 14:28:58.257204+00
16a0ff02-960a-4c8c-a97b-9b53b469cf4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 16:29:01.839866+00	2025-06-03 23:13:39.691604+00	\N	2025-06-03 16:29:00	00:15:00	2025-06-03 16:28:04.839866+00	2025-06-03 23:13:39.708095+00	2025-06-03 16:30:01.839866+00	f	\N	2025-06-04 14:28:58.257204+00
36ecac2d-1b5f-4ed1-aed3-c8031cd57118	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 23:13:39.704211+00	2025-06-03 23:13:43.69223+00	\N	2025-06-03 23:13:00	00:15:00	2025-06-03 23:13:39.704211+00	2025-06-03 23:13:43.709825+00	2025-06-03 23:14:39.704211+00	f	\N	2025-06-04 14:28:58.257204+00
d660af0f-77b4-4fbb-8bf3-a2b3d5821a67	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-03 23:14:01.701463+00	2025-06-04 03:28:23.296553+00	\N	2025-06-03 23:14:00	00:15:00	2025-06-03 23:13:43.701463+00	2025-06-04 03:28:23.320584+00	2025-06-03 23:15:01.701463+00	f	\N	2025-06-04 15:29:59.338499+00
0cd85032-9d1a-47ed-83e6-4af402d54e4d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 03:28:23.307718+00	2025-06-04 03:28:27.297349+00	\N	2025-06-04 03:28:00	00:15:00	2025-06-04 03:28:23.307718+00	2025-06-04 03:28:27.319836+00	2025-06-04 03:29:23.307718+00	f	\N	2025-06-04 15:29:59.338499+00
ccc7383c-6901-4e99-9e7c-0666fad2b6c7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-03 16:28:55.309921+00	2025-06-04 03:28:58.777504+00	__pgboss__maintenance	\N	00:15:00	2025-06-03 16:26:55.309921+00	2025-06-04 03:28:58.841242+00	2025-06-03 16:36:55.309921+00	f	\N	2025-06-04 15:29:59.338499+00
24f0c9a4-be5d-41e6-93be-6e0c50669f79	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 03:29:01.313686+00	2025-06-04 03:29:01.38547+00	\N	2025-06-04 03:29:00	00:15:00	2025-06-04 03:28:27.313686+00	2025-06-04 03:29:01.450668+00	2025-06-04 03:30:01.313686+00	f	\N	2025-06-04 15:29:59.338499+00
315226aa-8e2f-4668-961b-40528a01dbe0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 03:30:01.430837+00	2025-06-04 03:30:02.476515+00	\N	2025-06-04 03:30:00	00:15:00	2025-06-04 03:29:01.430837+00	2025-06-04 03:30:02.494472+00	2025-06-04 03:31:01.430837+00	f	\N	2025-06-04 15:32:59.327656+00
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output) FROM stdin;
f3a20076-3f73-41bd-86ac-ca1f504a19b7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:30:58.309487+00	2025-06-04 14:31:58.243384+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:28:58.309487+00	2025-06-04 14:31:58.261337+00	2025-06-04 14:38:58.309487+00	f	\N
6785843b-d714-4f01-952a-1de84e4eec2a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:52:01.070731+00	2025-06-04 14:52:04.123973+00	\N	2025-06-04 14:52:00	00:15:00	2025-06-04 14:51:04.070731+00	2025-06-04 14:52:04.139492+00	2025-06-04 14:53:01.070731+00	f	\N
4e5dd50d-6808-406d-a903-462560968da8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 03:31:01.596779+00	2025-06-04 14:28:58.244258+00	\N	2025-06-04 03:31:00	00:15:00	2025-06-04 03:30:01.596779+00	2025-06-04 14:28:58.254589+00	2025-06-04 03:32:01.596779+00	f	\N
6454825b-0c69-44de-9f01-0a18aaa2a57c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:28:58.205057+00	2025-06-04 14:28:58.23031+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:28:58.205057+00	2025-06-04 14:28:58.304633+00	2025-06-04 14:36:58.205057+00	f	\N
3a1d6411-cdb5-431d-865b-7362da5ae9d3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:13:59.301063+00	2025-06-04 15:14:59.29528+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:11:59.301063+00	2025-06-04 15:14:59.309373+00	2025-06-04 15:21:59.301063+00	f	\N
2af7bd29-c956-4c60-abef-9938e85e4ba7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:32:01.355004+00	2025-06-04 14:32:02.380833+00	\N	2025-06-04 14:32:00	00:15:00	2025-06-04 14:31:02.355004+00	2025-06-04 14:32:02.414064+00	2025-06-04 14:33:01.355004+00	f	\N
c06a05e7-5f90-4987-90ee-4b818558453d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:30:01.281128+00	2025-06-04 14:30:02.292155+00	\N	2025-06-04 14:30:00	00:15:00	2025-06-04 14:29:06.281128+00	2025-06-04 14:30:02.331017+00	2025-06-04 14:31:01.281128+00	f	\N
26d57fce-1629-4847-a50a-98ed9558fe05	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:54:01.176393+00	2025-06-04 14:54:04.209104+00	\N	2025-06-04 14:54:00	00:15:00	2025-06-04 14:53:04.176393+00	2025-06-04 14:54:04.229763+00	2025-06-04 14:55:01.176393+00	f	\N
591a5219-d80a-45b1-9bdc-ccce0d7029bb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:31:01.326729+00	2025-06-04 14:31:02.324816+00	\N	2025-06-04 14:31:00	00:15:00	2025-06-04 14:30:02.326729+00	2025-06-04 14:31:02.359597+00	2025-06-04 14:32:01.326729+00	f	\N
266c27d8-d6da-4e7f-85e3-dc45e0795f50	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:33:01.408643+00	2025-06-04 14:33:02.415564+00	\N	2025-06-04 14:33:00	00:15:00	2025-06-04 14:32:02.408643+00	2025-06-04 14:33:02.454463+00	2025-06-04 14:34:01.408643+00	f	\N
5785761c-cff8-4566-a405-346afcb7eed9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:53:51.851631+00	2025-06-04 14:54:51.838714+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:51:51.851631+00	2025-06-04 14:54:51.849688+00	2025-06-04 15:01:51.851631+00	f	\N
55379fcf-f078-430c-a2d8-13df283f192b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:22:01.421653+00	2025-06-04 15:22:04.448789+00	\N	2025-06-04 15:22:00	00:15:00	2025-06-04 15:21:04.421653+00	2025-06-04 15:22:04.470663+00	2025-06-04 15:23:01.421653+00	f	\N
a6bda93c-3b93-4ee6-9a43-ade80d4f8ecd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:34:01.448873+00	2025-06-04 14:34:02.456495+00	\N	2025-06-04 14:34:00	00:15:00	2025-06-04 14:33:02.448873+00	2025-06-04 14:34:02.489555+00	2025-06-04 14:35:01.448873+00	f	\N
d8892ac4-cfee-4067-8aa0-f5d9140582ea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:33:58.266971+00	2025-06-04 14:34:58.248833+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:31:58.266971+00	2025-06-04 14:34:58.266854+00	2025-06-04 14:41:58.266971+00	f	\N
9e77cf6a-a449-4d54-ab8c-90e2953be3c4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:55:01.226539+00	2025-06-04 14:55:04.23628+00	\N	2025-06-04 14:55:00	00:15:00	2025-06-04 14:54:04.226539+00	2025-06-04 14:55:04.254015+00	2025-06-04 14:56:01.226539+00	f	\N
3d7606a5-002f-4940-b99f-958eb1cfd5de	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:22:59.320405+00	2025-06-04 15:23:59.313627+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:20:59.320405+00	2025-06-04 15:23:59.326876+00	2025-06-04 15:30:59.320405+00	f	\N
383a6642-bbdb-4a30-b2a9-9ab163a792aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:35:01.484331+00	2025-06-04 14:35:02.491657+00	\N	2025-06-04 14:35:00	00:15:00	2025-06-04 14:34:02.484331+00	2025-06-04 14:35:02.524973+00	2025-06-04 14:36:01.484331+00	f	\N
ffc06057-fd78-41a0-b05c-e4c0cade538a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:58:57.558236+00	2025-06-04 14:58:57.563661+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:58:57.558236+00	2025-06-04 14:58:57.578176+00	2025-06-04 15:06:57.558236+00	f	\N
6ff03ec7-d6b8-4551-ae94-efa18a50d015	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:36:58.271984+00	2025-06-04 14:37:58.256093+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:34:58.271984+00	2025-06-04 14:37:58.276863+00	2025-06-04 14:44:58.271984+00	f	\N
6922b24f-a3ce-4303-a65a-5975ce969b49	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:25:01.523696+00	2025-06-04 15:25:04.546466+00	\N	2025-06-04 15:25:00	00:15:00	2025-06-04 15:24:04.523696+00	2025-06-04 15:25:04.563595+00	2025-06-04 15:26:01.523696+00	f	\N
951d0633-82d4-47d1-8803-29c83ce292ab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:38:01.701816+00	2025-06-04 14:38:02.745185+00	\N	2025-06-04 14:38:00	00:15:00	2025-06-04 14:37:02.701816+00	2025-06-04 14:38:02.774435+00	2025-06-04 14:39:01.701816+00	f	\N
c3768dfe-3024-4e5f-9547-f2e29e96f74d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:39:01.769885+00	2025-06-04 14:39:02.796777+00	\N	2025-06-04 14:39:00	00:15:00	2025-06-04 14:38:02.769885+00	2025-06-04 14:39:02.821229+00	2025-06-04 14:40:01.769885+00	f	\N
a8540cf0-2263-4c8d-9235-4d00f3cecf6b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:27:01.606203+00	2025-06-04 15:27:04.649272+00	\N	2025-06-04 15:27:00	00:15:00	2025-06-04 15:26:04.606203+00	2025-06-04 15:27:04.667916+00	2025-06-04 15:28:01.606203+00	f	\N
314200f9-9855-4a33-8ee6-e3b1ab215572	__pgboss__send-it	0	{"cron": "0 * * * *", "data": null, "name": "dailyStatsJob", "options": {}, "timezone": "UTC", "created_on": "2025-06-03T14:37:20.710Z", "updated_on": "2025-06-04T14:58:57.598Z"}	completed	0	0	0	f	2025-06-04 15:00:01.609544+00	2025-06-04 15:00:05.612823+00	dailyStatsJob	2025-06-04 15:00:00	00:15:00	2025-06-04 15:00:01.609544+00	2025-06-04 15:00:05.624398+00	2025-06-18 15:00:01.609544+00	f	\N
1bb6e949-8dd1-4417-888c-7fecb4588596	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:40:01.816389+00	2025-06-04 14:40:02.844188+00	\N	2025-06-04 14:40:00	00:15:00	2025-06-04 14:39:02.816389+00	2025-06-04 14:40:02.867509+00	2025-06-04 14:41:01.816389+00	f	\N
caafe74b-bf80-4304-9af0-7f4d47c9bb3f	dailyStatsJob	0	\N	completed	0	0	0	f	2025-06-04 15:00:05.620564+00	2025-06-04 15:00:05.626774+00	\N	\N	00:15:00	2025-06-04 15:00:05.620564+00	2025-06-04 15:00:05.983261+00	2025-06-18 15:00:05.620564+00	f	\N
0d809b35-cd4d-4f3f-8474-c528d74859f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:41:01.863046+00	2025-06-04 14:41:02.956455+00	\N	2025-06-04 14:41:00	00:15:00	2025-06-04 14:40:02.863046+00	2025-06-04 14:41:02.98549+00	2025-06-04 14:42:01.863046+00	f	\N
2ef52b5e-09ec-410a-8eba-04d6d0cc5605	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:41:58.331915+00	2025-06-04 14:42:58.314609+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:39:58.331915+00	2025-06-04 14:42:58.334174+00	2025-06-04 14:49:58.331915+00	f	\N
43cd48c5-3976-471d-a921-66127ba3c158	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:01:01.613805+00	2025-06-04 15:01:03.506805+00	\N	2025-06-04 15:01:00	00:15:00	2025-06-04 15:00:01.613805+00	2025-06-04 15:01:03.52469+00	2025-06-04 15:02:01.613805+00	f	\N
586a3b57-92ed-47ce-9d01-e1c21b341cf4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:44:01.131745+00	2025-06-04 14:44:03.133249+00	\N	2025-06-04 14:44:00	00:15:00	2025-06-04 14:43:03.131745+00	2025-06-04 14:44:03.165314+00	2025-06-04 14:45:01.131745+00	f	\N
1e2fe122-40f6-4e10-8d41-33e862e97c14	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:02:01.521664+00	2025-06-04 15:02:03.537378+00	\N	2025-06-04 15:02:00	00:15:00	2025-06-04 15:01:03.521664+00	2025-06-04 15:02:03.559402+00	2025-06-04 15:03:01.521664+00	f	\N
573df4fd-a1cd-41ee-8916-4ead02c1ce51	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:46:01.169471+00	2025-06-04 14:46:03.82414+00	\N	2025-06-04 14:46:00	00:15:00	2025-06-04 14:45:03.169471+00	2025-06-04 14:46:03.860274+00	2025-06-04 14:47:01.169471+00	f	\N
088665b3-b61b-4cc3-a220-7d29bc24d58f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:31:01.904757+00	2025-06-04 15:31:04.908705+00	\N	2025-06-04 15:31:00	00:15:00	2025-06-04 15:30:04.904757+00	2025-06-04 15:31:04.921506+00	2025-06-04 15:32:01.904757+00	f	\N
65554719-d8b6-436f-813a-7227f3a4623a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:48:01.865245+00	2025-06-04 14:48:03.888489+00	\N	2025-06-04 14:48:00	00:15:00	2025-06-04 14:47:03.865245+00	2025-06-04 14:48:03.90416+00	2025-06-04 14:49:01.865245+00	f	\N
94822556-0d2f-4295-8216-34eda1147bbe	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:02:59.246363+00	2025-06-04 15:02:59.24978+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:02:59.246363+00	2025-06-04 15:02:59.262178+00	2025-06-04 15:10:59.246363+00	f	\N
d85e9c53-6be2-4e16-ae10-4ba9298c59e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:32:01.919749+00	2025-06-04 15:32:04.98835+00	\N	2025-06-04 15:32:00	00:15:00	2025-06-04 15:31:04.919749+00	2025-06-04 15:32:05.002625+00	2025-06-04 15:33:01.919749+00	f	\N
0fc5142c-3a16-4aa1-98e0-7eefe9d6c22a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:50:01.956964+00	2025-06-04 14:50:04.012387+00	\N	2025-06-04 14:50:00	00:15:00	2025-06-04 14:49:03.956964+00	2025-06-04 14:50:04.031251+00	2025-06-04 14:51:01.956964+00	f	\N
82a681f9-7af8-47a6-97f7-f0bfbce5e0fc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:31:59.374466+00	2025-06-04 15:32:59.321403+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:29:59.374466+00	2025-06-04 15:32:59.333124+00	2025-06-04 15:39:59.374466+00	f	\N
b7bdfc47-9684-4751-8a3d-16e7c8d535b6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:51:01.028935+00	2025-06-04 14:51:04.056246+00	\N	2025-06-04 14:51:00	00:15:00	2025-06-04 14:50:04.028935+00	2025-06-04 14:51:04.074141+00	2025-06-04 14:52:01.028935+00	f	\N
d89cf6ac-e2d5-4aa5-9c04-8581f61b16a8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:04:59.265789+00	2025-06-04 15:05:59.280231+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:02:59.265789+00	2025-06-04 15:05:59.29754+00	2025-06-04 15:12:59.265789+00	f	\N
1fa86581-6793-42b9-910d-5d3ebadab210	__pgboss__maintenance	0	\N	created	0	0	0	f	2025-06-04 15:34:59.334952+00	\N	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:32:59.334952+00	\N	2025-06-04 15:42:59.334952+00	f	\N
ba12e024-1f4b-4049-818c-52842be3fc63	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:06:01.417169+00	2025-06-04 15:06:03.559576+00	\N	2025-06-04 15:06:00	00:15:00	2025-06-04 15:05:03.417169+00	2025-06-04 15:06:03.57826+00	2025-06-04 15:07:01.417169+00	f	\N
f7187530-e4ef-473c-91b8-90bd899560bd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:33:01.999937+00	2025-06-04 15:33:05.041364+00	\N	2025-06-04 15:33:00	00:15:00	2025-06-04 15:32:04.999937+00	2025-06-04 15:33:05.057958+00	2025-06-04 15:34:01.999937+00	f	\N
108b8443-1658-4625-8231-49b64400bffb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:34:01.055095+00	2025-06-04 15:34:01.157512+00	\N	2025-06-04 15:34:00	00:15:00	2025-06-04 15:33:05.055095+00	2025-06-04 15:34:01.174605+00	2025-06-04 15:35:01.055095+00	f	\N
2f69e3eb-84d1-41c1-80f9-e1d59c8f252b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:50:51.858313+00	2025-06-04 14:51:51.837408+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:48:51.858313+00	2025-06-04 14:51:51.849664+00	2025-06-04 14:58:51.858313+00	f	\N
beec6eb7-d614-462d-9da9-41e7679c7f20	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:10:59.297381+00	2025-06-04 15:11:59.288004+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:08:59.297381+00	2025-06-04 15:11:59.298426+00	2025-06-04 15:18:59.297381+00	f	\N
9afaabbd-04e3-433a-a537-8ff529716fab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:28:58.260807+00	2025-06-04 14:29:02.246028+00	\N	2025-06-04 14:28:00	00:15:00	2025-06-04 14:28:58.260807+00	2025-06-04 14:29:02.285346+00	2025-06-04 14:29:58.260807+00	f	\N
1c391a56-ea5c-4ebb-beaf-9a45b49e4914	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:36:01.51936+00	2025-06-04 14:36:02.573466+00	\N	2025-06-04 14:36:00	00:15:00	2025-06-04 14:35:02.51936+00	2025-06-04 14:36:02.604213+00	2025-06-04 14:37:01.51936+00	f	\N
8ff907ad-d915-47c2-b16b-2147712cf35d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:37:01.597258+00	2025-06-04 14:37:02.672398+00	\N	2025-06-04 14:37:00	00:15:00	2025-06-04 14:36:02.597258+00	2025-06-04 14:37:02.706331+00	2025-06-04 14:38:01.597258+00	f	\N
b0f31273-82b9-4a83-9da4-7ed100e3a970	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:53:01.137284+00	2025-06-04 14:53:04.162437+00	\N	2025-06-04 14:53:00	00:15:00	2025-06-04 14:52:04.137284+00	2025-06-04 14:53:04.179175+00	2025-06-04 14:54:01.137284+00	f	\N
2123a58a-31b5-43d7-90d6-ca2abe60c94d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:39:58.282663+00	2025-06-04 14:39:58.310264+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:37:58.282663+00	2025-06-04 14:39:58.326553+00	2025-06-04 14:47:58.282663+00	f	\N
5ea49607-767f-4de2-b355-7b02172fadd8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:12:01.840141+00	2025-06-04 15:12:03.85049+00	\N	2025-06-04 15:12:00	00:15:00	2025-06-04 15:11:03.840141+00	2025-06-04 15:12:03.871548+00	2025-06-04 15:13:01.840141+00	f	\N
03f7e706-e5fd-49fb-96af-fe7e1fafc4fe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:56:01.25097+00	2025-06-04 14:56:04.282314+00	\N	2025-06-04 14:56:00	00:15:00	2025-06-04 14:55:04.25097+00	2025-06-04 14:56:04.296594+00	2025-06-04 14:57:01.25097+00	f	\N
069e2db0-66e8-4557-9b84-a65950b4b483	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:45:01.159845+00	2025-06-04 14:45:03.129501+00	\N	2025-06-04 14:45:00	00:15:00	2025-06-04 14:44:03.159845+00	2025-06-04 14:45:03.174468+00	2025-06-04 14:46:01.159845+00	f	\N
c90de101-ee10-4e1d-98f5-1b369ad83408	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:45:51.796928+00	2025-06-04 14:45:51.802076+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:45:51.796928+00	2025-06-04 14:45:51.815726+00	2025-06-04 14:53:51.796928+00	f	\N
f1250ceb-0eaa-4119-a338-b0420449ec0d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:13:01.867864+00	2025-06-04 15:13:03.884865+00	\N	2025-06-04 15:13:00	00:15:00	2025-06-04 15:12:03.867864+00	2025-06-04 15:13:03.900077+00	2025-06-04 15:14:01.867864+00	f	\N
629109a6-a897-4578-9150-fedd9bcf1ac4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:59:01.582738+00	2025-06-04 14:59:05.572851+00	\N	2025-06-04 14:59:00	00:15:00	2025-06-04 14:58:57.582738+00	2025-06-04 14:59:05.591081+00	2025-06-04 15:00:01.582738+00	f	\N
e9d54d7a-67fe-4d27-8a9d-632aca36bc25	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:47:51.819564+00	2025-06-04 14:48:51.807222+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:45:51.819564+00	2025-06-04 14:48:51.846211+00	2025-06-04 14:55:51.819564+00	f	\N
8f5b94b9-52af-4878-bcd5-8ad388cb4f62	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:14:01.897319+00	2025-06-04 15:14:03.925667+00	\N	2025-06-04 15:14:00	00:15:00	2025-06-04 15:13:03.897319+00	2025-06-04 15:14:03.939763+00	2025-06-04 15:15:01.897319+00	f	\N
1bf5b1f6-9434-4d3e-ad02-026ae0c2efc2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:00:01.589492+00	2025-06-04 15:00:01.605532+00	\N	2025-06-04 15:00:00	00:15:00	2025-06-04 14:59:05.589492+00	2025-06-04 15:00:01.61526+00	2025-06-04 15:01:01.589492+00	f	\N
7fd025d9-a32f-48e0-a378-72d4ed191782	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:49:01.901646+00	2025-06-04 14:49:03.918934+00	\N	2025-06-04 14:49:00	00:15:00	2025-06-04 14:48:03.901646+00	2025-06-04 14:49:03.973577+00	2025-06-04 14:50:01.901646+00	f	\N
47cfe6b6-05d6-4791-bbdf-2caf631c075e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:03:01.555685+00	2025-06-04 15:03:03.260078+00	\N	2025-06-04 15:03:00	00:15:00	2025-06-04 15:02:03.555685+00	2025-06-04 15:03:03.28037+00	2025-06-04 15:04:01.555685+00	f	\N
f22ddd65-c416-42a6-a804-c7c68cc53cb2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:16:01.048442+00	2025-06-04 15:16:04.082836+00	\N	2025-06-04 15:16:00	00:15:00	2025-06-04 15:15:04.048442+00	2025-06-04 15:16:04.097674+00	2025-06-04 15:17:01.048442+00	f	\N
2a641985-00ca-4da1-aef4-462dd74b4a5e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:04:01.277124+00	2025-06-04 15:04:03.360294+00	\N	2025-06-04 15:04:00	00:15:00	2025-06-04 15:03:03.277124+00	2025-06-04 15:04:03.381471+00	2025-06-04 15:05:01.277124+00	f	\N
0e0422eb-e3a1-4536-ae9c-b403b0a451ac	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:16:59.312259+00	2025-06-04 15:17:59.299062+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:14:59.312259+00	2025-06-04 15:17:59.312649+00	2025-06-04 15:24:59.312259+00	f	\N
64836318-1557-4699-8c80-69e704bf5f18	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:07:01.575694+00	2025-06-04 15:07:03.659672+00	\N	2025-06-04 15:07:00	00:15:00	2025-06-04 15:06:03.575694+00	2025-06-04 15:07:03.678574+00	2025-06-04 15:08:01.575694+00	f	\N
2dda00d8-324a-4112-916e-45bcd72e4a5d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:18:01.169982+00	2025-06-04 15:18:04.222674+00	\N	2025-06-04 15:18:00	00:15:00	2025-06-04 15:17:04.169982+00	2025-06-04 15:18:04.238949+00	2025-06-04 15:19:01.169982+00	f	\N
91ab2c35-ce9e-401f-b626-bedec9b32ed7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:08:01.676226+00	2025-06-04 15:08:03.709518+00	\N	2025-06-04 15:08:00	00:15:00	2025-06-04 15:07:03.676226+00	2025-06-04 15:08:03.721208+00	2025-06-04 15:09:01.676226+00	f	\N
9709b3a3-7164-4af9-86cc-459c0adfb776	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:07:59.301685+00	2025-06-04 15:08:59.284785+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:05:59.301685+00	2025-06-04 15:08:59.294417+00	2025-06-04 15:15:59.301685+00	f	\N
22853788-c390-43da-8c5b-163f6f99fbab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:20:01.305237+00	2025-06-04 15:20:04.343832+00	\N	2025-06-04 15:20:00	00:15:00	2025-06-04 15:19:04.305237+00	2025-06-04 15:20:04.361541+00	2025-06-04 15:21:01.305237+00	f	\N
19611003-d55f-4da8-b7f3-10fbaed7f2c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:23:01.467655+00	2025-06-04 15:23:04.476636+00	\N	2025-06-04 15:23:00	00:15:00	2025-06-04 15:22:04.467655+00	2025-06-04 15:23:04.497651+00	2025-06-04 15:24:01.467655+00	f	\N
b6603a8e-4338-47a2-b2d3-91d2b608d09e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:24:01.494718+00	2025-06-04 15:24:04.511263+00	\N	2025-06-04 15:24:00	00:15:00	2025-06-04 15:23:04.494718+00	2025-06-04 15:24:04.526019+00	2025-06-04 15:25:01.494718+00	f	\N
a1dd9ced-f4f4-4d9a-a346-f7770d8fc745	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:26:01.560861+00	2025-06-04 15:26:04.592448+00	\N	2025-06-04 15:26:00	00:15:00	2025-06-04 15:25:04.560861+00	2025-06-04 15:26:04.609038+00	2025-06-04 15:27:01.560861+00	f	\N
b38daae7-f26b-4c74-a637-3aa2c38c4eaa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:25:59.32948+00	2025-06-04 15:26:59.315736+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:23:59.32948+00	2025-06-04 15:26:59.326423+00	2025-06-04 15:33:59.32948+00	f	\N
c7942fda-e9e4-471a-948d-f9bf9c597317	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:28:01.664583+00	2025-06-04 15:28:04.719732+00	\N	2025-06-04 15:28:00	00:15:00	2025-06-04 15:27:04.664583+00	2025-06-04 15:28:04.736499+00	2025-06-04 15:29:01.664583+00	f	\N
5bfdba84-c521-4f15-96b1-d05a955605d5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:29:01.733793+00	2025-06-04 15:29:04.814927+00	\N	2025-06-04 15:29:00	00:15:00	2025-06-04 15:28:04.733793+00	2025-06-04 15:29:04.835077+00	2025-06-04 15:30:01.733793+00	f	\N
4374d948-d06f-46fe-b36c-ca148ee67278	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:28:59.327963+00	2025-06-04 15:29:59.319805+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:26:59.327963+00	2025-06-04 15:29:59.36269+00	2025-06-04 15:36:59.327963+00	f	\N
7c11cf1f-9952-4763-8473-c61414c11ce4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:30:01.831448+00	2025-06-04 15:30:04.872572+00	\N	2025-06-04 15:30:00	00:15:00	2025-06-04 15:29:04.831448+00	2025-06-04 15:30:04.91455+00	2025-06-04 15:31:01.831448+00	f	\N
453e581d-5ff2-4837-a5e9-b15eab5d7aa6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:15:01.937301+00	2025-06-04 15:15:04.032673+00	\N	2025-06-04 15:15:00	00:15:00	2025-06-04 15:14:03.937301+00	2025-06-04 15:15:04.050671+00	2025-06-04 15:16:01.937301+00	f	\N
73068c46-5704-4891-86cf-1f050fbe19f7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:42:01.980034+00	2025-06-04 14:42:03.052026+00	\N	2025-06-04 14:42:00	00:15:00	2025-06-04 14:41:02.980034+00	2025-06-04 14:42:03.101267+00	2025-06-04 14:43:01.980034+00	f	\N
f714440f-21c7-4702-93a3-89f858b0642a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:29:02.280321+00	2025-06-04 14:29:06.249996+00	\N	2025-06-04 14:29:00	00:15:00	2025-06-04 14:29:02.280321+00	2025-06-04 14:29:06.28617+00	2025-06-04 14:30:02.280321+00	f	\N
84b7765f-82d0-4af3-814f-e38db4bb3a1d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:57:01.29406+00	2025-06-04 14:57:04.318928+00	\N	2025-06-04 14:57:00	00:15:00	2025-06-04 14:56:04.29406+00	2025-06-04 14:57:04.341329+00	2025-06-04 14:58:01.29406+00	f	\N
2847745a-1dbb-4836-906c-0b54de0649a5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:43:01.081873+00	2025-06-04 14:43:03.104956+00	\N	2025-06-04 14:43:00	00:15:00	2025-06-04 14:42:03.081873+00	2025-06-04 14:43:03.136467+00	2025-06-04 14:44:01.081873+00	f	\N
49540590-bd7a-46f0-8ea2-f1d83e883622	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:58:01.337763+00	2025-06-04 14:58:57.570509+00	\N	2025-06-04 14:58:00	00:15:00	2025-06-04 14:57:04.337763+00	2025-06-04 14:58:57.576519+00	2025-06-04 14:59:01.337763+00	f	\N
9114b8f0-2a1d-4642-9c2d-72100329967f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 14:44:15.029676+00	2025-06-04 14:44:15.03725+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 14:44:15.029676+00	2025-06-04 14:44:15.056051+00	2025-06-04 14:52:15.029676+00	f	\N
43918630-1c82-49a8-8da2-3f5c47594c3d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:17:01.093858+00	2025-06-04 15:17:04.158073+00	\N	2025-06-04 15:17:00	00:15:00	2025-06-04 15:16:04.093858+00	2025-06-04 15:17:04.173264+00	2025-06-04 15:18:01.093858+00	f	\N
236e987a-6aa4-4f50-a7c5-3ac3375e7cf4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:00:43.476661+00	2025-06-04 15:00:43.480166+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:00:43.476661+00	2025-06-04 15:00:43.49013+00	2025-06-04 15:08:43.476661+00	f	\N
15e76d26-84fc-4115-8a06-31567dc3f88b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 14:47:01.856089+00	2025-06-04 14:47:03.851631+00	\N	2025-06-04 14:47:00	00:15:00	2025-06-04 14:46:03.856089+00	2025-06-04 14:47:03.867346+00	2025-06-04 14:48:01.856089+00	f	\N
f0f2d49d-a843-4638-9071-d2d705395176	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:02:40.018635+00	2025-06-04 15:02:40.024137+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:02:40.018635+00	2025-06-04 15:02:40.0436+00	2025-06-04 15:10:40.018635+00	f	\N
729274ee-f43c-4592-a535-c9412cd5900c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:19:01.23599+00	2025-06-04 15:19:04.285878+00	\N	2025-06-04 15:19:00	00:15:00	2025-06-04 15:18:04.23599+00	2025-06-04 15:19:04.308871+00	2025-06-04 15:20:01.23599+00	f	\N
a902e016-0e3d-43c0-8588-c633920d0496	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:05:01.3778+00	2025-06-04 15:05:03.402878+00	\N	2025-06-04 15:05:00	00:15:00	2025-06-04 15:04:03.3778+00	2025-06-04 15:05:03.419899+00	2025-06-04 15:06:01.3778+00	f	\N
c0942f93-3ff8-4a45-a56b-0dd6e54aeffd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-06-04 15:19:59.314948+00	2025-06-04 15:20:59.310956+00	__pgboss__maintenance	\N	00:15:00	2025-06-04 15:17:59.314948+00	2025-06-04 15:20:59.318168+00	2025-06-04 15:27:59.314948+00	f	\N
03e5b9db-36ad-48bc-a22a-60ff9ca3eaad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:21:01.358211+00	2025-06-04 15:21:04.404742+00	\N	2025-06-04 15:21:00	00:15:00	2025-06-04 15:20:04.358211+00	2025-06-04 15:21:04.424432+00	2025-06-04 15:22:01.358211+00	f	\N
0f995b27-4ba7-47e3-8126-abba7e46fcfe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:09:01.718464+00	2025-06-04 15:09:03.769117+00	\N	2025-06-04 15:09:00	00:15:00	2025-06-04 15:08:03.718464+00	2025-06-04 15:09:03.781373+00	2025-06-04 15:10:01.718464+00	f	\N
545d6e10-6756-4763-9458-75129dfb775d	__pgboss__cron	0	\N	created	2	0	0	f	2025-06-04 15:35:01.170298+00	\N	\N	2025-06-04 15:35:00	00:15:00	2025-06-04 15:34:01.170298+00	\N	2025-06-04 15:36:01.170298+00	f	\N
ac4c12e4-c9e7-4971-a3be-af8c020cd398	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:10:01.77961+00	2025-06-04 15:10:03.80004+00	\N	2025-06-04 15:10:00	00:15:00	2025-06-04 15:09:03.77961+00	2025-06-04 15:10:03.813825+00	2025-06-04 15:11:01.77961+00	f	\N
076bdeef-5881-4939-a10e-cc6bddb8dd33	__pgboss__cron	0	\N	completed	2	0	0	f	2025-06-04 15:11:01.812265+00	2025-06-04 15:11:03.827723+00	\N	2025-06-04 15:11:00	00:15:00	2025-06-04 15:10:03.812265+00	2025-06-04 15:11:03.843245+00	2025-06-04 15:12:01.812265+00	f	\N
\.


--
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
dailyStatsJob	0 * * * *	UTC	\N	{}	2025-06-03 14:37:20.710135+00	2025-06-04 15:02:59.289242+00
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, maintained_on, cron_on) FROM stdin;
20	2025-06-04 15:32:59.331342+00	2025-06-04 15:34:01.165986+00
\.


--
-- Data for Name: Auth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Auth" (id, "userId") FROM stdin;
3526883b-2532-4ff9-a87f-bc84e6873317	84238d9c-20f4-43a2-b3f3-58b895212c35
f792829c-58b3-4a82-954d-6194ffb50acd	04f753a2-050b-4d2f-b04e-1ac6d19c76bc
5efa91c5-3a2a-45d8-9361-1918a89fea7c	311e7835-7bf7-43d0-b850-e48c6c0a0e2e
\.


--
-- Data for Name: AuthIdentity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AuthIdentity" ("providerName", "providerUserId", "providerData", "authId") FROM stdin;
email	salonipandey014@gmail.com	{"hashedPassword":"$argon2id$v=19$m=19456,t=2,p=1$c9p79Vtew6qVddMcZ0fl+Q$8g34P/xZJm5ZMWR1znksqTfDApY5/HBoXocOkPY5ceI","isEmailVerified":false,"emailVerificationSentAt":"2025-06-03T14:39:34.864Z","passwordResetSentAt":"2025-06-03T14:41:05.474Z"}	3526883b-2532-4ff9-a87f-bc84e6873317
email	test@gmail.com	{"hashedPassword":"$argon2id$v=19$m=19456,t=2,p=1$koJ8/MAEW+EegmjgqYFv2A$fbfnWrnINFtqPYehQy5+wi7vQSbRU54fMWQy3YsPlC8","isEmailVerified":false,"emailVerificationSentAt":"2025-06-04T14:47:48.759Z","passwordResetSentAt":null}	f792829c-58b3-4a82-954d-6194ffb50acd
email	kunal@gmail.com	{"hashedPassword":"$argon2id$v=19$m=19456,t=2,p=1$XPP7ihNkEl/7Jd2tPNXQ5g$Hz+IACwRow27hiSnG5b1B5r6bJQSTvhEJAYEkAxdM7o","isEmailVerified":false,"emailVerificationSentAt":"2025-06-04T15:12:59.018Z","passwordResetSentAt":null}	5efa91c5-3a2a-45d8-9361-1918a89fea7c
\.


--
-- Data for Name: ContactFormMessage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ContactFormMessage" (id, "createdAt", "userId", content, "isRead", "repliedAt") FROM stdin;
\.


--
-- Data for Name: CsvFile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CsvFile" (id, "userId", "fileName", "originalName", "uploadedAt", "columnHeaders", "rowCount") FROM stdin;
\.


--
-- Data for Name: CsvRow; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."CsvRow" (id, "csvFileId", "rowData", "rowIndex") FROM stdin;
\.


--
-- Data for Name: DailyStats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DailyStats" (id, date, "totalViews", "prevDayViewsChangePercent", "userCount", "paidUserCount", "userDelta", "paidUserDelta", "totalRevenue", "totalProfit") FROM stdin;
\.


--
-- Data for Name: File; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."File" (id, "createdAt", "userId", name, type, key, "uploadUrl") FROM stdin;
\.


--
-- Data for Name: GptResponse; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."GptResponse" (id, "createdAt", "updatedAt", "userId", content) FROM stdin;
\.


--
-- Data for Name: Logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Logs" (id, "createdAt", message, level) FROM stdin;
1	2025-06-03 15:00:09.377	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
2	2025-06-04 15:00:05.973	Error calculating daily stats: Invalid API Key provided: sk_test_...	job-error
\.


--
-- Data for Name: PageViewSource; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."PageViewSource" (name, date, "dailyStatsId", visitors) FROM stdin;
\.


--
-- Data for Name: Session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Session" (id, "expiresAt", "userId") FROM stdin;
\.


--
-- Data for Name: Task; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Task" (id, "createdAt", "userId", description, "time", "isDone") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (id, "createdAt", email, username, "isAdmin", "paymentProcessorUserId", "lemonSqueezyCustomerPortalUrl", "subscriptionStatus", "subscriptionPlan", "datePaid", credits) FROM stdin;
84238d9c-20f4-43a2-b3f3-58b895212c35	2025-06-03 14:39:34.846	salonipandey014@gmail.com	salonipandey014@gmail.com	f	\N	\N	\N	\N	\N	3
04f753a2-050b-4d2f-b04e-1ac6d19c76bc	2025-06-04 14:47:48.753	test@gmail.com	test@gmail.com	f	\N	\N	\N	\N	\N	3
311e7835-7bf7-43d0-b850-e48c6c0a0e2e	2025-06-04 15:12:59.012	kunal@gmail.com	kunal@gmail.com	f	\N	\N	\N	\N	\N	3
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
2cddbd33-93cd-4c0f-bf8e-33057b0186e3	7139fddc5f6a4fb4994c549fd58f2ac8e170e183ba90c3314331e7a7bfe86ca2	2025-06-03 14:35:40.711863+00	20250603143540_init	\N	\N	2025-06-03 14:35:40.477519+00	1
3c7fe1e6-ae97-48e6-a3b1-3766276e1462	f73f238bb0c20aae149479ec37b6948394d236cacbd16675e301897d50651383	2025-06-03 15:32:22.003612+00	20250603153221_init_csv_schema	\N	\N	2025-06-03 15:32:21.953344+00	1
\.


--
-- Name: DailyStats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DailyStats_id_seq"', 1, false);


--
-- Name: Logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Logs_id_seq"', 2, true);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name);


--
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- Name: AuthIdentity AuthIdentity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuthIdentity"
    ADD CONSTRAINT "AuthIdentity_pkey" PRIMARY KEY ("providerName", "providerUserId");


--
-- Name: Auth Auth_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Auth"
    ADD CONSTRAINT "Auth_pkey" PRIMARY KEY (id);


--
-- Name: ContactFormMessage ContactFormMessage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactFormMessage"
    ADD CONSTRAINT "ContactFormMessage_pkey" PRIMARY KEY (id);


--
-- Name: CsvFile CsvFile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CsvFile"
    ADD CONSTRAINT "CsvFile_pkey" PRIMARY KEY (id);


--
-- Name: CsvRow CsvRow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CsvRow"
    ADD CONSTRAINT "CsvRow_pkey" PRIMARY KEY (id);


--
-- Name: DailyStats DailyStats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DailyStats"
    ADD CONSTRAINT "DailyStats_pkey" PRIMARY KEY (id);


--
-- Name: File File_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."File"
    ADD CONSTRAINT "File_pkey" PRIMARY KEY (id);


--
-- Name: GptResponse GptResponse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GptResponse"
    ADD CONSTRAINT "GptResponse_pkey" PRIMARY KEY (id);


--
-- Name: Logs Logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Logs"
    ADD CONSTRAINT "Logs_pkey" PRIMARY KEY (id);


--
-- Name: PageViewSource PageViewSource_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PageViewSource"
    ADD CONSTRAINT "PageViewSource_pkey" PRIMARY KEY (date, name);


--
-- Name: Session Session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_pkey" PRIMARY KEY (id);


--
-- Name: Task Task_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: archive_archivedon_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_archivedon_idx ON pgboss.archive USING btree (archivedon);


--
-- Name: archive_id_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_id_idx ON pgboss.archive USING btree (id);


--
-- Name: job_fetch; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_fetch ON pgboss.job USING btree (name text_pattern_ops, startafter) WHERE (state < 'active'::pgboss.job_state);


--
-- Name: job_name; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_name ON pgboss.job USING btree (name text_pattern_ops);


--
-- Name: job_singleton_queue; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singleton_queue ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'active'::pgboss.job_state) AND (singletonon IS NULL) AND (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text));


--
-- Name: job_singletonkey; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkey ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'completed'::pgboss.job_state) AND (singletonon IS NULL) AND (NOT (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text)));


--
-- Name: job_singletonkeyon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkeyon ON pgboss.job USING btree (name, singletonon, singletonkey) WHERE (state < 'expired'::pgboss.job_state);


--
-- Name: job_singletonon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonon ON pgboss.job USING btree (name, singletonon) WHERE ((state < 'expired'::pgboss.job_state) AND (singletonkey IS NULL));


--
-- Name: Auth_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Auth_userId_key" ON public."Auth" USING btree ("userId");


--
-- Name: DailyStats_date_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "DailyStats_date_key" ON public."DailyStats" USING btree (date);


--
-- Name: Session_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Session_id_key" ON public."Session" USING btree (id);


--
-- Name: Session_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Session_userId_idx" ON public."Session" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_paymentProcessorUserId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_paymentProcessorUserId_key" ON public."User" USING btree ("paymentProcessorUserId");


--
-- Name: User_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_username_key" ON public."User" USING btree (username);


--
-- Name: AuthIdentity AuthIdentity_authId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AuthIdentity"
    ADD CONSTRAINT "AuthIdentity_authId_fkey" FOREIGN KEY ("authId") REFERENCES public."Auth"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Auth Auth_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Auth"
    ADD CONSTRAINT "Auth_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ContactFormMessage ContactFormMessage_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ContactFormMessage"
    ADD CONSTRAINT "ContactFormMessage_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CsvFile CsvFile_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CsvFile"
    ADD CONSTRAINT "CsvFile_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CsvRow CsvRow_csvFileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CsvRow"
    ADD CONSTRAINT "CsvRow_csvFileId_fkey" FOREIGN KEY ("csvFileId") REFERENCES public."CsvFile"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: File File_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."File"
    ADD CONSTRAINT "File_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: GptResponse GptResponse_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."GptResponse"
    ADD CONSTRAINT "GptResponse_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: PageViewSource PageViewSource_dailyStatsId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PageViewSource"
    ADD CONSTRAINT "PageViewSource_dailyStatsId_fkey" FOREIGN KEY ("dailyStatsId") REFERENCES public."DailyStats"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Session Session_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Session"
    ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."Auth"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Task Task_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Task"
    ADD CONSTRAINT "Task_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

