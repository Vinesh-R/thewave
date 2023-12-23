--
-- PostgreSQL database dump
--

-- Dumped from database version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.10 (Ubuntu 14.10-0ubuntu0.22.04.1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: album; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.album (
    albumid integer NOT NULL,
    titre character varying(100) NOT NULL,
    dateparu date,
    photo character varying(100),
    description text
);


ALTER TABLE public.album OWNER TO postgres;

--
-- Name: album_albumid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.album_albumid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.album_albumid_seq OWNER TO postgres;

--
-- Name: album_albumid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.album_albumid_seq OWNED BY public.album.albumid;


--
-- Name: artiste; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.artiste (
    artid integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    nationalite character varying(100),
    profilepicture character varying(100),
    datedenaissance date,
    datedemort date,
    CONSTRAINT datecheck CHECK (((datedemort IS NULL) OR (datedemort > datedenaissance)))
);


ALTER TABLE public.artiste OWNER TO postgres;

--
-- Name: artiste_artid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.artiste_artid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.artiste_artid_seq OWNER TO postgres;

--
-- Name: artiste_artid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.artiste_artid_seq OWNED BY public.artiste.artid;


--
-- Name: creeralbum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.creeralbum (
    groupeid integer NOT NULL,
    albumid integer NOT NULL,
    musiqueid integer NOT NULL
);


ALTER TABLE public.creeralbum OWNER TO postgres;

--
-- Name: creerplaylist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.creerplaylist (
    pseudonyme character varying(100) NOT NULL,
    playid integer NOT NULL
);


ALTER TABLE public.creerplaylist OWNER TO postgres;

--
-- Name: ecoute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ecoute (
    pseudonyme character varying(100) NOT NULL,
    musiqueid integer NOT NULL
);


ALTER TABLE public.ecoute OWNER TO postgres;

--
-- Name: estconstitue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estconstitue (
    playid integer NOT NULL,
    musiqueid integer NOT NULL
);


ALTER TABLE public.estconstitue OWNER TO postgres;

--
-- Name: groupe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groupe (
    groupeid integer NOT NULL,
    nom character varying(100) NOT NULL,
    datecreation date NOT NULL,
    groupenationalite character varying(100),
    genre character varying(50)[] NOT NULL,
    profile character varying(100)
);


ALTER TABLE public.groupe OWNER TO postgres;

--
-- Name: groupe_groupeid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groupe_groupeid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groupe_groupeid_seq OWNER TO postgres;

--
-- Name: groupe_groupeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groupe_groupeid_seq OWNED BY public.groupe.groupeid;


--
-- Name: joue; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.joue (
    musiqueid integer NOT NULL,
    groupeid integer NOT NULL
);


ALTER TABLE public.joue OWNER TO postgres;

--
-- Name: jouelerole; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jouelerole (
    artid integer NOT NULL,
    groupeid integer NOT NULL,
    dateid integer NOT NULL
);


ALTER TABLE public.jouelerole OWNER TO postgres;

--
-- Name: morceau; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.morceau (
    musiqueid integer NOT NULL,
    titre character varying(100) NOT NULL,
    duree integer NOT NULL,
    parole text NOT NULL,
    cheminfichier character varying(100) NOT NULL,
    photo character varying(100)
);


ALTER TABLE public.morceau OWNER TO postgres;

--
-- Name: morceau_musiqueid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.morceau_musiqueid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.morceau_musiqueid_seq OWNER TO postgres;

--
-- Name: morceau_musiqueid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.morceau_musiqueid_seq OWNED BY public.morceau.musiqueid;


--
-- Name: nbecouteunique; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.nbecouteunique AS
 SELECT e.musiqueid,
    m.titre,
    count(DISTINCT e.pseudonyme) AS ecouteunique
   FROM (public.ecoute e
     JOIN public.morceau m USING (musiqueid))
  GROUP BY e.musiqueid, m.titre;


ALTER TABLE public.nbecouteunique OWNER TO postgres;

--
-- Name: playlist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.playlist (
    playid integer NOT NULL,
    titre character varying(100) NOT NULL,
    description text,
    estpublique boolean NOT NULL
);


ALTER TABLE public.playlist OWNER TO postgres;

--
-- Name: nbpartageplay; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.nbpartageplay AS
 SELECT m.musiqueid,
    m.titre AS morceautitre,
    count(p.playid) AS nombrepartages
   FROM ((public.morceau m
     LEFT JOIN public.estconstitue ep ON ((m.musiqueid = ep.musiqueid)))
     LEFT JOIN public.playlist p ON ((ep.playid = p.playid)))
  WHERE (p.estpublique = true)
  GROUP BY m.musiqueid, m.titre;


ALTER TABLE public.nbpartageplay OWNER TO postgres;

--
-- Name: nbpersonneecoute; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.nbpersonneecoute AS
 SELECT m.musiqueid,
    m.titre AS morceautitre,
    count(e.pseudonyme) AS nombre_ecoutes
   FROM (public.morceau m
     LEFT JOIN public.ecoute e ON ((m.musiqueid = e.musiqueid)))
  GROUP BY m.musiqueid, m.titre;


ALTER TABLE public.nbpersonneecoute OWNER TO postgres;

--
-- Name: participe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.participe (
    musiqueid integer NOT NULL,
    artid integer NOT NULL
);


ALTER TABLE public.participe OWNER TO postgres;

--
-- Name: periode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.periode (
    dateid integer NOT NULL,
    datearrive date NOT NULL,
    datedepart date,
    CONSTRAINT datecheck2 CHECK (((datedepart IS NULL) OR (datedepart >= datearrive)))
);


ALTER TABLE public.periode OWNER TO postgres;

--
-- Name: periode_dateid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.periode_dateid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.periode_dateid_seq OWNER TO postgres;

--
-- Name: periode_dateid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.periode_dateid_seq OWNED BY public.periode.dateid;


--
-- Name: playlist_playid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.playlist_playid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.playlist_playid_seq OWNER TO postgres;

--
-- Name: playlist_playid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.playlist_playid_seq OWNED BY public.playlist.playid;


--
-- Name: suivregroupe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suivregroupe (
    pseudonyme character varying(100) NOT NULL,
    groupeid integer NOT NULL
);


ALTER TABLE public.suivregroupe OWNER TO postgres;

--
-- Name: suivreutilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suivreutilisateur (
    userp character varying(100) NOT NULL,
    usersuivipar character varying(100) NOT NULL
);


ALTER TABLE public.suivreutilisateur OWNER TO postgres;

--
-- Name: utilisateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilisateur (
    pseudonyme character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    dateinscription date DEFAULT CURRENT_DATE NOT NULL,
    motdepasse character(64) NOT NULL,
    profilepicture character varying(100)
);


ALTER TABLE public.utilisateur OWNER TO postgres;

--
-- Name: album albumid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album ALTER COLUMN albumid SET DEFAULT nextval('public.album_albumid_seq'::regclass);


--
-- Name: artiste artid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artiste ALTER COLUMN artid SET DEFAULT nextval('public.artiste_artid_seq'::regclass);


--
-- Name: groupe groupeid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe ALTER COLUMN groupeid SET DEFAULT nextval('public.groupe_groupeid_seq'::regclass);


--
-- Name: morceau musiqueid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.morceau ALTER COLUMN musiqueid SET DEFAULT nextval('public.morceau_musiqueid_seq'::regclass);


--
-- Name: periode dateid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.periode ALTER COLUMN dateid SET DEFAULT nextval('public.periode_dateid_seq'::regclass);


--
-- Name: playlist playid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist ALTER COLUMN playid SET DEFAULT nextval('public.playlist_playid_seq'::regclass);


--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.album (albumid, titre, dateparu, photo, description) FROM stdin;
2	Go	2018-02-10	go.jpg	\N
3	Purpose	2015-10-15	purose.jpg	\N
1	Thank u next	2012-12-17	beyonce	\N
\.


--
-- Data for Name: artiste; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.artiste (artid, nom, prenom, nationalite, profilepicture, datedenaissance, datedemort) FROM stdin;
23	Grande	Ariana	American	ArianaGrande.jpg	1993-05-26	\N
27	Knowles	Beyoncé	American	BeyoncéKnowles.jpg	1981-09-04	\N
29	Robinson	Khalid	American	KhalidRobinson.jpg	1998-02-11	\N
30	Gomez	Selena	American	SelenaGomez.jpg	1992-06-22	\N
31	Eilish	Billie	American	BillieEilish.jpg	2001-12-18	\N
32	Lipa	Dua	British	DuaLipa.jpg	1995-08-22	\N
33	Gaga	Lady	American	LadyGaga.jpg	1986-03-28	\N
34	Swift	Taylor	American	TaylorSwift.jpg	1989-12-13	\N
36	Sheeran	Ed	British	EdSheeran.jpg	1991-02-17	\N
38	Kardashian	Cardi	American	CardiKardashian.jpg	1992-02-11	\N
39	Mathers	Eminem	American	EminemMathers.jpg	1972-10-17	\N
40	Minaj	Nicki	Trinidadian-American	NickiMinaj.jpg	1982-12-08	\N
41	Puth	Charlie	American	CharliePuth.jpg	1991-12-02	\N
42	Bieber	Justin	Canadian	JustinBieber.jpg	1994-03-01	\N
43	Malone	Post	American	PostMalone.jpg	1995-06-04	\N
25	Perry	Katy	Amercian	katy.jpg	1984-10-25	\N
\.


--
-- Data for Name: creeralbum; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.creeralbum (groupeid, albumid, musiqueid) FROM stdin;
1	2	20
1	2	21
1	2	22
1	2	23
1	2	24
3	1	0
3	1	1
3	1	2
3	1	3
3	1	4
2	3	65
2	3	66
2	3	67
2	3	68
2	3	69
\.


--
-- Data for Name: creerplaylist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.creerplaylist (pseudonyme, playid) FROM stdin;
user	4
vinesh	5
\.


--
-- Data for Name: ecoute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ecoute (pseudonyme, musiqueid) FROM stdin;
vinesh	21
vinesh	23
vinesh	16
\.


--
-- Data for Name: estconstitue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estconstitue (playid, musiqueid) FROM stdin;
4	0
4	50
4	69
5	21
5	23
5	16
\.


--
-- Data for Name: groupe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groupe (groupeid, nom, datecreation, groupenationalite, genre, profile) FROM stdin;
1	Billie Eilish	2018-02-20	American	{pop,alt-pop}	billieeilishgroupe.jpg
2	Justin Biber	2018-05-17	American	{rock,pop}	biber.jpg
3	Grande Arina	2012-04-02	American	{pop,alt-pop}	arina.jpg
\.


--
-- Data for Name: joue; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.joue (musiqueid, groupeid) FROM stdin;
20	1
2	3
68	2
\.


--
-- Data for Name: jouelerole; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jouelerole (artid, groupeid, dateid) FROM stdin;
31	1	1
42	2	2
23	3	3
\.


--
-- Data for Name: morceau; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.morceau (musiqueid, titre, duree, parole, cheminfichier, photo) FROM stdin;
0	​thank u, next	223	thought i'd end up with sean but he wasn't a match wrote some songs about ricky now i listen and laugh even almost got married and for pete i'm so thankful wish i could say thank you to malcolm 'cause he was an angel  pre one taught me love one taught me patience and one taught me pain now i'm so amazing say i've loved and i've lost but that's not what i see so look what i got look what you taught me and for that i say   thank you next next thank you next next thank you next i'm so fuckin' grateful for my ex thank you next next thank you next next thank you next next i'm so fuckin'   spend more time with my friends i ain't worried 'bout nothin' plus i met someone else we havin' better discussions i know they say i move on too fast but this one gon' last 'cause her name is ari and i'm so good with that so good with that  pre she taught me love love she taught me patience patience how she handles pain pain that shit's amazing yeah she's amazing i've loved and i've lost yeah yeah but that's not what i see yeah yeah 'cause look what i've found yeah yeah ain't no need for searching and for that i say   thank you next thank you next thank you next thank you next thank you next thank you i'm so fuckin' grateful for my ex thank you next thank you next thank you next said thank you next thank you next next i'm so fuckin' grateful for my ex  post thank you next thank you next thank you next i'm so fuckin'   one day i'll walk down the aisle holding hands with my mama i'll be thanking my dad 'cause she grew from the drama only wanna do it once real bad gon' make that shit last god forbid something happens least this song is a smash song is a smash  pre i've got so much love love got so much patience patience and i've learned from the pain pain i turned out amazing turned out amazing say i've loved and i've lost yeah yeah but that's not what i see yeah yeah 'cause look what i've found yeah yeah ain't no need for searching and for that i say   thank you next thank you next thank you next thank you next thank you next i'm so fuckin' grateful for my ex thank you next thank you next thank you next said thank you next thank you next next i'm so fuckin' grateful for my ex  post thank you next thank you next thank you next yeah yee thank you next thank you next thank you next yeah yee	locale	\N
18	Bad Liar	157	i was walking down the street the other day tryna distract myself but then i see your face oh wait that's someone else tryna play it coy tryna make it disappear but just like the battle of troy there's nothing subtle here in my room there's a king size space bigger than it used to be if you want you can rent that place call me an amenity even if it's in my dreams  pre ooh you're taking up a fraction of my mind ooooh every time i watch you serpentine   oh i'm tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' oh tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' not to think about you no no no no not to think about you no no no no oh i'm tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' oh tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' not to give in to you no no no no not to give in to you no no no no  post with my feelings on fire guess i'm a bad liar   i see how your attention builds it's like looking in a mirror your touch like a happy pill but still all we do is fear what could possibly happen next can we focus on the love paint my kiss across your chest if you're the art i'll be the brush  pre ooh you're taking up a fraction of my mind ooooh every time i watch you serpentine   oh i'm tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' oh tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' not to think about you no no no no not to think about you no no no no oh i'm tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' oh tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' not to give in to you no no no no not to give in to you no no no no  post with my feelings on fire guess i'm a bad liar   and oh baby let's make reality actuality a reality oh baby let's make reality actuality a reality   oh oh i'm tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' oh tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' not to think about you no no no no not to think about you no no no no oh i'm tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' oh tryin' i'm tryin' i'm tryin' i'm tryin' i'm tryin' not to give in to you no no no no not to give in to you no no no no  post with my feelings on fire guess i'm a bad liar	locale	\N
53	Lose Yourself	213	look if you had one shot or one opportunity to seize everything you ever wanted in one moment would you capture it or just let it slip yo   his palms are sweaty knees weak arms are heavy there's vomit on his sweater already mom's spaghetti he's nervous but on the surface he looks calm and ready to drop bombs but he keeps on forgetting what he wrote down the whole crowd goes so loud he opens his mouth but the words won't come out he's choking how everybody's joking now the clock's run out time's up overblaow snap back to reality ope there goes gravity ope there goes rabbit he choked he's so mad but he won't give up that easy no he won't have it he knows his whole back's to these ropes it don't matter he's dope he knows that but he's broke he's so stagnant he knows when he goes back to this mobile home that's when it's back to the lab again yo this old rap shit he better go capture this moment and hope it don't pass him and   you better lose yourself in the music the moment you own it you better never let it go go you only get one shot do not miss your chance to blow this opportunity comes once in a lifetime yo you better lose yourself in the music the moment you own it you better never let it go go you only get one shot do not miss your chance to blow this opportunity comes once in a lifetime yo you better   his soul's escaping through this hole that is gaping this world is mine for the taking make me king as we move toward a new world order a normal life is boring but superstardom's close to postmortem it only grows harder homie grows hotter he blows it's all over these hoes is all on him coasttocoast shows he's known as the globetrotter lonely roads god only knows he's grown farther from home he's no father he goes home and barely knows his own daughter but hold your nose 'cause here goes the cold water these hoes don't want him no mo' he's cold product they moved on to the next schmoe who flows he nosedove and sold nada and so the soap opera is told it unfolds i suppose it's old partner but the beat goes on dadadom dadom dahdah dahdah   you better lose yourself in the music the moment you own it you better never let it go go you only get one shot do not miss your chance to blow this opportunity comes once in a lifetime yo you better lose yourself in the music the moment you own it you better never let it go go you only get one shot do not miss your chance to blow this opportunity comes once in a lifetime yo you better   no more games i'ma change what you call rage tear this motherfuckin' roof off like two dogs caged i was playin' in the beginning the mood all changed i've been chewed up and spit out and booed off stage but i kept rhymin' and stepped right in the next cypher best believe somebody's payin' the pied piper all the pain inside amplified by the fact that i can't get by with my nineto five and i can't provide the right type of life for my family 'cause man these goddamn food stamps don't buy diapers and there's no movie there's no mekhi phifer this is my life and these times are so hard and it's gettin' even harder tryna feed and water my seed plus teetertotter caught up between bein' a father and a prima donna baby mama drama screamin' on her too much for me to wanna stay in one spot another day of monotony's gotten me to the point i'm like a snail i've got to formulate a plot or end up in jail or shot success is my only motherfuckin' optionfailure's not mom i love you but this trailer's got to go i cannot grow old in salem's lot so here i go it's my shot feet fail me not this may be the only opportunity that i got   you better lose yourself in the music the moment you own it you better never let it go go you only get one shot do not miss your chance to blow this opportunity comes once in a lifetime yo you better lose yourself in the music the moment you own it you better never let it go go you only get one shot do not miss your chance to blow this opportunity comes once in a lifetime yo you better   you can do anything you set your mind to man	locale	\N
54	The Monster	187	rihanna i'm friends with the monster that's under my bed get along with the voices inside of my head you're tryin' to save me stop holdin' your breath and you think i'm crazy yeah you think i'm crazy   eminem i wanted the fame but not the cover of newsweek oh well guess beggars can't be choosey wanted to receive attention for my music wanted to be left alone in public excuse me for wantin' my cake and eat it too and wantin' it both ways fame made me a balloon 'cause my ego inflated when i blew see but it was confusing 'cause all i wanted to do's be the bruce lee of loose leaf abused ink used it as a tool when i blew steam whoo hit the lottery oohwee but with what i gave up to get it was bittersweet it was like winnin' a used mink ironic 'cause i think i'm gettin' so huge i need a shrink i'm beginnin' to lose sleep one sheep two sheep goin' coocoo and kooky as kool keith but i'm actually weirder than you think 'cause i'm   rihanna  bebe rexha i'm friends with the monster that's under my bed get along with the voices inside of my head you're tryin' to save me stop holdin' your breath and you think i'm crazy yeah you think i'm crazy well that's nothin' oohoohoohooh oohoohoohooh oohoohoohooh well that's nothin' oohoohoohooh oohoohoohooh oohoohoohooh oohoohoohooh   eminem now i ain't much of a poet but i know somebody once told me to seize the moment and don't squander it 'cause you never know when it all could be over tomorrow so i keep conjurin' sometimes i wonder where these thoughts spawn from yeah ponderin'll do you wonders no wonder you're losin' your mind the way it wanders yodelodelayheehoo i think it went wanderin' off down yonder and stumbled onto jeff vanvonderen 'cause i need an interventionist to intervene between me and this monster and save me from myself and all this conflict 'cause the very thing that i love's killin' me and i can't conquer it my ocd's conkin' me in the head keep knockin' nobody's home i'm sleepwalkin' i'm just relayin' what the voice in my head's sayin' don't shoot the messenger i'm just friends with the   rihanna  bebe rexha i'm friends with the monster that's under my bed get along with the voices inside of my head you're tryin' to save me stop holdin' your breath and you think i'm crazy yeah you think i'm crazy well that's nothin' oohoohoohooh oohoohoohooh oohoohoohooh well that's nothin' oohoohoohooh oohoohoohooh oohoohoohooh oohoohoohooh   eminem call me crazy but i have this vision one day that i'll walk amongst you a regular civilian but until then drums get killed and i'm comin' straight at mc's blood gets spilled and i'll take you back to the days that i'd get on a dre track give every kid who got played that pumpedup feelin' and shit to say back to the kids who played him i ain't here to save the fuckin' children but if one kid out of a hundred million who are goin' through a struggle feels it and relates that's great it's payback russell wilson fallin' way back in the draft turn nothin' into somethin' still can make that straw into gold chump i will spinrumpelstiltskin in a haystack maybe i need a straightjacket face facts i am nuts for real but i'm okay with that it's nothin' i'm still friends with the   rihanna i'm friends with the monster that's under my bed get along with the voices inside of my head you're tryin' to save me stop holdin' your breath and you think i'm crazy yeah you think i'm crazy   rihanna  eminem i'm friends with the monster that's under my bed get along with get along with the voices inside of my head you're tryin' to you're tryin' to save me stop holdin' your breath and you think and you think i'm crazy yeah you think i'm crazy well that's nothin'   rihanna  bebe rexha oohoohoohooh oohoohoohooh oohoohoohooh well that's nothin' oohoohoohooh oohoohoohooh oohoohoohooh oohoohoohooh	locale	\N
55	Only	169	nicki minaj yo i never fucked wayne i never fucked drake on my life man fuck's sake if i did i'd ménage with 'em and let 'em eat my ass like a cupcake my man full he just ate i don't duck nobody but tape yeah that was a setup for a punchline on duct tape wowowoworried  'bout if my butt fake worry 'bout y'all niggas us straight ththese girls are my sons jojon  kate plus eight when i walk in sit up straight i don't give a fuck if i was late dinner with my man on a g5 is my idea of a update huthut one huthut two big titties big butt too fufuck with them real niggas who don't tell niggas what they up to had to show bitches where the top is riring finger where the rock is thethese hoes couldn't test me even if their name was pop quiz bad bitches who i fuck with mamamad bitches we don't fuck with i don't fuck with them chickens unless they last name is cutlet let it soak in like seasoning and tell them bitches blow me lance stephenson   chris brown raise every bottle and cup in the sky sparks in the air like the fourth of july nothing but bad bitches in here tonight oh if you lame and you know it be quiet nothing but real niggas only bad bitches only rich niggas only independent bitches only boss niggas only thick bitches only i got my real niggas here by my side only   drake yeah i never fucked nicki 'cause she got a man but when that's over then i'm first in line and the other day in her maybach i thought goddamn this is the perfect time we had just come from that video you know la traffic how the city slow she was sitting down on that big butt but i was still staring at the titties though yeah lowkey or maybe highkey i been peeped that you like me you know who the fuck you really wanna be with besides me i mean it doesn't take much for us to do this shit quietly i mean she say i'm obsessed with thick women and i agree yeah that's right i like my girls bbw yeah type that wanna suck you dry and then eat some lunch with you yeah so thick that everybody else in the room is so uncomfortable ass on houston texas but the face look just like clair huxtable oh yeah you the man in the city when the mayor fuck with you the nba players fuck with you the badass bitches doing makeup and hair fuck with you oh that's 'cause i believe in something i stand for it and nicki if you ever tryna fuck just give me the headsup so i can plan for it pinkprint ayy   chris brown  drake raise every bottle and cup in the sky ayy sparks in the air like the fourth of july nothing but bad bitches in here tonight oh if you lame and you know it be quiet nothing but real niggas only bad bitches only rich niggas only independent bitches only boss niggas only thick bitches only i got my real niggas here by my side only   lil wayne i never fucked nick' and that's fucked up if i did fuck she'd be fucked up whoever is hittin' ain't hittin' it right 'cause she act like she need dick in her life that's another story i'm no storyteller i piss greatness like goldish yellow all my goons so overzealous i'm from hollygrove the holy mecca calendar say i got money for days i squirm and i shake but i'm stuck in my ways my girlfriend will beat a bitch up if she waved they bet' not fuck with her surfboard surfboard my eyes are so bright i take cover for shade don't have my money take mothers instead you got the hiccups you swallowed the truth then i make you burp boy treat beef like sirloin i'm talkin' 'bout runnin' in houses with army guns so think about your son and daughter rooms got two hoes with me masked up they got smaller guns ain't thinkin' 'bout your son and daughter rooms this shit is crazy my nigga i mean brazy my nigga that money talk i just rephrase it my nigga blood gang take the b off behavior my nigga for reals if you mouth off i blow your face off i mean poppoppop then i take off nigga now you see me nigga now you don't like jamie foxx acting like ray charles sixteen in a clip one in the chamber 7 ward bully with seventeen bullets my story is how i went from poor me to please pour me a drink and celebrate with me   chris brown  lil wayne raise every bottle and cup in the sky sparks in the air like the fourth of july nothing but bad bitches in here tonight oh if you lame and you know it be quiet young mula baby nothing but real niggas only bad bitches only rich niggas only independent bitches only boss niggas only thick bitches only i got my real niggas here by my side only	locale	\N
56	Feeling Myself	244	nicki minaj yo b they ready let's go   beyoncé feelin' myself i'm feelin' myself i'm feelin' my feelin' myself i'm feelin' myself i'm feelin' my feelin' my feelin' myself i'm feelin' myself i'm feelin' my feelin' myself i'm feelin' myself i'm feelin' my   nicki minaj i'm with some hood girls lookin' back at it and a good girl in my tax bracket uh got a black card that'll let saks have it these chanel bags is a bad habit ii do balls dal mavericks my maybach black matted uh bitch never left but i'm back at it and i'm feelin' myself jack rabbit feelin' myself back off 'cause i'm feelin' myself jack off uh he be thinking about me when he whacks off wax on wax off national anthem hats off then i curve that nigga like a bad toss uh lemme get a number two with some mac sauce on the run tour with my mask off   beyoncé i'm feelin' myself i'm feelin' myself i'm feelin' my uh feelin' myself i'm feelin' myself i'm feelin' my feelin' my feelin' myself i'm feelin' myself i'm feelin' my uh feelin' myself i'm feelin' myself i'm feelin' my  post beyoncé changed the game with that digital drop know where you was when that digital popped i stopped the world male or female it make no difference i stop the world world stop carry on   nicki minaj kitty on fleek pretty on fleek uh pretty gang always keep them niggas on geek ridin'ridin' through texas texas feed him for his breakfast uh everytime i whip it i be talkin' so reckless he said damn nicki it's tight i say yeah nigga you right uh he said damn bae you so little but you be really takin' that pipe i said yes daddy i do gimme brain like nyu uh i said teach me nigga teach me all this learnin' here is by you  pre beyoncé i'm whippin' that work he diggin' that work i got it 6 of that real panky full of that bounce baby come get you some of that bounce baby   beyoncé i'm feelin' myself i'm feelin' myself i'm feelin' my uh feelin' myself i'm feelin' myself i'm feelin' my feelin' my feelin' myself i'm feelin' myself i'm feelin' my uh feelin' myself i'm feelin' myself i'm killin' my   nicki minaj  beyoncé nicki minaj  beyoncé cookin' up that base base lookin' like a kilo kilo he just wanna taste taste biggin' up my ego ego ego ego ego ego ego ego ego ego ridin' through texas ridin' through texas ridin' through texas smoke it all off talkin' bout that highgrade baby hold up i can kill your migraine migraine migraine migraine migraine migraine migraine migraine migraine ridin' through texas ridin' through texas ridin' through texas   nicki minaj  beyoncé bitches ain't got punchlines or flow i have both and an empire also keep gettin' gifts from santa claus at the north pole today i'm icy but i'm prayin' for some more snow let that ho ho letlet that ho know he in love he in love with that coco why these bitches don't never be learnin' you bitches will never get what i be earnin' uh i'm still gettin' plaques from my records that's urban ain't gotta rely on top 40 i am a rap legend just go ask the kings of rap who is the queen and things of that nature look at my finger that is a glacier hits like a laser rrr drippin' on that work trippin' off that perc flippin' up my skirt and i be whippin' all that work takin' trips with all them ki's car keys got b's uh stingin' with the queen b and we be whippin' all of that d cause we dope girls we flawless we the poster girls for all this uh we run around with them ballers only real niggas in my call list i'm the big kahuna go let them whores know uh just on this song alone bitch is on her fourth flow   nicki minaj hahaha rrrrrrrrrr you like it don't'chyea snitches laughter young money	locale	\N
57	Barbie Dreams	160	uh mmm kyuh rip to big  classic shit   i'm lookin' for a nigga to give some babies a handful of weezy sprinkle of dave east man i ain't got no type like jxmmi and swae lees but if he can't fuck three times a night peace i tried to fuck 50 for a powerful hour but all that nigga wanna do is talk power for hours bbeat the pussy up make sure it's a ko step your banks up like you're movin' that yayo somebody go and make sure karrueche okay though i heard she think i'm tryna give the coochie to quavo they always wanna beat it up goon up the pussy man maybe i should let him autotune up the pussy all these bow wow challenge niggas lyin' and shit man these fetty wap niggas stay eyein' my shit drake worth a hundred mill he always buyin' me shit but i don't know if the pussy wet or if he cryin' and shit meek still be in my dms i be havin' to duck him i used to pray for times like this faceass when i fuck him man uzi is my baby he ain't takin' a l but he took it literally when i said go to hell used to fuck with young thug i ain't addressin' this shit ccaught him in my dressing room stealin' dresses and shit i used to give this nigga with a lisp tests and shit how you want the puthy can't say your s's and shit uh   dreams of fuckin' one of these little rappers i'm just playin' but i'm sayin' barbie dreams dreams of fuckin' one of these little rappers i'm just playin' but i'm sayin' bbbbarbie dreams dreams of fuckin' one of these little rappers i'm just playin' but i'm sayin' bbbbarbie bbbbarbie dreams dreams of fuckin' one of these little rappers barbie dreams i'm just playin' but i'm sayin'   i remember when i used to have a crush on special ed shoutout desiigner 'cause he made it out of special ed you wanna fuck me you gotta give some special head 'cause this pussy have these niggas on some special meds like mike tyson he was bitin' my shit talkin' 'bout yo why you got these niggas fightin' and shit on the on the real i should make these niggas scrap for the pussy young ma and lady luck get the strap for this pussy uh and i woulda had odell beckham bangin' the cake 'til i saw him hoppin' out of cars dancin' to drake i been a fivestar bitch man word to gotti i'ma do that nigga future dirty word to scottie had to cancel dj khaled boy we ain't speakin' ain't no fat nigga tellin' me what he ain't eatin' yg and the game with the hammer yellin' gang gang this aint what i meant when i said a gang bang tekashi want a ménage i said treway curved him and went the kim and kanye way em cop the barbie dreamhouse then you can play the part ii ain't tryna bust it open in a trailer park   dreams of fuckin' one of these little rappers i'm just playin' but i'm sayin' barbie dreams dreams of fuckin' one of these little rappers i'm just playin' but i'm sayin' bbbbarbie dreams dreams of fuckin' one of these little rappers i'm just playin' but i'm sayin' bbbbarbie bbbbarbie dreams dreams of fuckin' one of these little rappers barbie dreams i'm just playin' but i'm sayin' bbbbarbie dreams barbie dreams i'm just playin' but i'm sayin' bbbbarbie bbbbarbie dreams   you know i'm all 'bout them dollars i be supportin' them scholars i let him give me some brain but he wanted me to ride it so i said fuck it i'm in he wanna cut like a trim and if he act like he know i let him fuck it again i got them bars i'm indicted i'm poppin' i'm uninvited i said just lick on the clitoris nigga don't fuckin' bite it i ride his  in a circle i turn stefan into urkel i go arounds and arounds and i'ma go down in slow motion thethen i pick it up look at it i said daddy come get at it uh yellow brick road he said that i am a wiz at it yeah they want it want it you know i flaunt it flaunt it i'm a trendsetter everything i do they do yeah i put 'em up on it on it dimelo papi papi yo quiero sloppy sloppy i'll give it to you if you beat it up like pacqui pacqui iiii'ma kill 'em with the shoe no ceiling is in the roof and i'm big give me the loot  cylinders in the coupe i get dome with the chrome no tellin' when i'ma shoot i just bang bang bang real killas is in my group gorillas is in my unit vacationin' where it's humid and i shine shine shine got diamonds all in my cubans i'm in la times more than when niggas lootin' and my flow spit crack i think that nigga usin' he done bodied everybody in closing these bitches losin' usin' usin' up a bitch movin' no i ain't stuttered and no i ain't ruben damn a bitch snoozin' shoutout to my jews l'chaim rick rubin big fat titties yes they be protrudin' i be like fuck 'em fuck 'em bring the lube in i be like fuck 'em fuck 'em bring the lube in	locale	\N
58	Truffle Butter	198	maya jane coles you know don't you yeah night of you know don't you yeah night of   drake uh thinkin' out loud i must have a quarter million on me right now hard to make a song 'bout somethin' other than the money two things i'm about it talkin' blunt and staying blunted pretty women are you here are you here right now huh we should all disappear right now look you're gettin' all your friends and you're gettin' in the car and you're comin' to the house are we clear right now huh you see the fleet of all the new things cop cars with the loose change all white like i move things niggas see me rollin' and they mood change like a muhfucka new flow i got a dozen of 'em i don't trust you you a undercover i could probably make some stepsisters fuck each other woo talkin' filets with the truffle butter fresh sheets and towels man she gotta love it yeah they all get what they desire from it what tell them niggas we ain't hidin' from it   maya jane coles you know don't you yeah night of you know don't you yeah night of   nicki minaj yo thinkin' out loud i must have about a milli on me right now and i ain't talkin' about that lil wayne record i'm still the highest sellin' female rapper for the record man this a 65 million single sold i ain't gotta compete with a single soul i'm good with the ballpoint game finger roll ask me how to do it i don't tell a single soul pretty women wassup is you here right now you a standup or is you in your chair right now uhh do you hear me i can't let a wack nigga get near me i might kiss the baddest bitch if you dare me i ain't never need a man to take care of me yo i'm in that big boy bitches can't rent this i floss everyday but i ain't a dentist your whole style and approach i invented and i ain't takin' that back cause i meant it   maya jane coles you know don't you yeah night of you know don't you yeah night of   lil wayne uh thinkin' out loud i could be broke and keep a million dollar smile lol to the bank check in my account bank teller flirtin' after checkin' my account pretty ladies are you here truffle butter on your pussy cuddle buddies on the low you ain't gotta tell your friend that i eat it in the morning cause she gon' say i know can i hit it in the bathroom put your hands on the toilet i'll put one leg on the tub girl this my new dance move i just don't know what to call it but bitch you dancing with the stars i ain't nothin' like your last dude what's his name  not important i brought some cocaine if you snortin' she became a vacuum put it on my dick like carpet suck the white off white chocolate i'm so heartless thoughtless lawless and flawless smallest regardless largest in charge and born in new orleans get killed for jordans skateboard i'm gnarly drake tunechi and barbie you know   maya jane coles you know don't you yeah night of you know don't you yeah night of	locale	\N
1	7 rings	175	yeah breakfast at tiffany's and bottles of bubbles girls with tattoos who like getting in trouble lashes and diamonds atm machines buy myself all of my favorite things yeah been through some bad shit i should be a sad bitch who woulda thought it'd turn me to a savage rather be tied up with calls and not strings write my own checks like i write what i sing yeah yeah  pre my wrist stop watchin' my neck is flossy make big deposits my gloss is poppin' you like my hair gee thanks just bought it i see it i like it i want it i got it yeah   i want it i got it i want it i got it i want it i got it i want it i got it you like my hair gee thanks just bought it i see it i like it i want it i got it yep   wearing a ring but ain't gon' be no mrs bought matching diamonds for six of my bitches i'd rather spoil all my friends with my riches think retail therapy my new addiction whoever said money can't solve your problems must not have had enough money to solve 'em they say which one i say nah i want all of 'em happiness is the same price as redbottoms  pre my smile is beamin' yeah my skin is gleamin' is gleamin' the way it shine i know you've seen it you've seen it i bought a crib just for just for the closet closet both his and hers i want it i got it yeah   i want it i got it i want it i got it i want it i got it i want it i got it baby you like my hair gee thanks just bought it oh yeah i see it i like it i want it i got it yep   yeah my receipts be lookin' like phone numbers if it ain't money then wrong number black card is my business card the way it be settin' the tone for me i don't mean to brag but i be like put it in the bag yeah when you see them racks they stacked up like my ass yeah shoot go from the store to the booth make it all back in one loop gimme the loot never mind i got the juice nothing but net when we shoot look at my neck look at my jet ain't got enough money to pay me respect ain't no budget when i'm on the set if i like it then that's what i get yeah   i want it i got it i want it i got it oh yeah i want it i got it i want it i got it oh yeah yeah you like my hair gee thanks just bought it i see it i like it i want it i got it i see yep	locale	\N
2	​God is a woman	177	you you love it how i move you you love it how i touch you my one when all is said and done you'll believe god is a woman and i i feel it after midnight a feelin' that you can't fight my one it lingers when we're done you'll believe god is a woman   i don't wanna waste no time yeah you ain't got a onetrack mind yeah have it any way you like yeah and i can tell that you know i know how i want it ain't nobody else can relate boy i like that you ain't afraid baby lay me down and let's pray i'm tellin' you the way i like it how i want it  pre yeah and i can be all the things you told me not to be yeah when you try to come for me i keep on flourishing yeah and he see the uniwhen i'm the company it's all in me   you you love it how i move you you love it how i touch you my one when all is said and done you'll believe god is a woman and i i feel it after midnight a feelin' that you can't fight my one it lingers when we're done you'll believe god is a woman   yeah i tell you all the things you should know so baby take my hands save your soul we can make it last take it slow hmm and i can tell that you know i know how i want it yeah but you're different from the rest and boy if you confess you might get blessed see if you deserve what comes next i'm tellin' you the way i like it how i want it  pre yeah and i can be all the things you told me not to be yeah when you try to come for me i keep on flourishing yeah and he see the uniwhen i'm the company it's all in me   you you love it how i move you you love it how i touch you my one when all is said and done you'll believe god is a woman and i i feel it after midnight a feelin' that you can't fight my one it lingers when we're done you'll believe god is a woman   yeah yeah god is a woman yeah yeah god is a woman yeah my one one when all is said and done you'll believe god is a woman you'll believe god god is a woman oh yeah god is a woman yeah one it lingers when we're done you'll believe god is a woman	locale	\N
3	Side To Side	227	ariana grande  nicki minaj i've been here all night ariana i've been here all day nicki minaj and boy  got me walkin' side to side let them hoes know   ariana grande i'm talkin' to ya see you standing over there with your body feeling like i wanna rock with your body and we don't gotta think 'bout nothin' 'bout nothin' i'm comin' at ya 'cause i know you got a bad reputation doesn't matter 'cause you give me temptation and we don't gotta think 'bout nothin' 'bout nothin'  pre ariana grande these friends keep talkin' way too much say i should give you up can't hear them no 'cause i   ariana grande i've been here all night i've been here all day and boy  got me walkin' side to side i've been here all night i've been here all day and boy got me walkin' side to side side to side   ariana grande been tryna hide it baby what's it gonna hurt if they don't know makin' everybody think that we  just as long as you know you got me you got me and boy i got ya 'cause tonight i'm making deals with the devil and i know it's gonna get me in trouble just as long as you know you got me  pre ariana grande these friends keep talkin' way too much say i should give you up can't hear them no 'cause i   ariana grande i've been here all night i've been here all day and boy  got me walkin' side to side side to side i've been here all night been here all night baby i've been here all day been here all day baby and boy  got me walkin' side to side side to side  refrain nicki minaj uh yeah this the new style with the fresh type of flow wrist icicle ride dick bicycle come through yo get you this type of blow if you want a ménage i got a tricycle   nicki minaj all these bitches' flows is my minime body smoking so they call me young nicki chimney rappers in they feelings 'cause they feelin' me uh ii give zero fucks and i got zero chill in me kissing me copped the blue box that say tiffany curry with the shot just tell 'em to call me stephanie gun pop then i make my gum pop i'm the queen of rap young ariana run pop uh  pre ariana grande these friends keep talkin' way too much way too much say i should give em up give em up can't hear them no 'cause i   ariana grande i've been here all night been here all night baby i've been here all day been here all night baby and boy boy  got me walkin' side to side side to side i've been here all night been here all night baby i've been here all day been here all day baby ooh baby and boy no got me walkin' side to side side to side yeaheh yeah yeah yeah  refrain nicki minaj and ariana grande this the new style with the fresh type of flow nah nah baby wrist icicle ride dick bicycle come through yo get you this type of blow if you want a ménage i got a tricycle no eh hey eh eh	locale	\N
4	​​no tears left to cry	250	right now i'm in a state of mind i wanna be in like all the time ain't got no tears left to cry so i'm pickin' it up pickin' it up i'm lovin' i'm livin' i'm pickin' it up i'm pickin' it up pickin' it up yeah i'm lovin' i'm livin' i'm pickin' it up oh yeah  refrain i'm pickin' it up yeah pickin' it up yeah lovin' i'm livin' so we turnin' up yeah we turnin' it up   ain't got no tears in my body i ran out but boy i like it i like it i like it don't matter how what where who tries it we out here vibin' we vibin' we vibin'  pre comin' out even when it's rainin' down can't stop now can't stop so shut your mouth shut your mouth and if you don't know then now you know it babe know it babe yeah   right now i'm in a state of mind i wanna be in like all the time ain't got no tears left to cry so i'm pickin' it up pickin' it up oh yeah i'm lovin' i'm livin' i'm pickin' it up oh i just want you to come with me we're on another mentality ain't got no tears left to cry to cry so i'm pickin' it up pickin' it up oh yeah i'm lovin' i'm livin' i'm pickin' it up  refrain pickin' it up yeah pickin' it up yeah lovin' i'm livin' so we turnin' up we turnin' it up yeah we turnin' it up   they point out the colors in you i see 'em too and boy i like 'em i like 'em i like 'em we're way too fly to partake in all this hate we out here vibin' we vibin' we vibin'  pre comin' out even when it's rainin' down can't stop now can't stop so shut your mouth shut your mouth and if you don't know then now you know it babe know it babe yeah   right now i'm in a state of mind i wanna be in like all the time ain't got no tears left to cry so i'm pickin' it up pickin' it up oh yeah i'm lovin' i'm livin' i'm pickin' it up oh i just want you to come with me we're on another mentality ain't got no tears left to cry to cry so i'm pickin' it up pickin' it up oh yeah i'm lovin' i'm livin' i'm pickin' it up   comin' out even when it's rainin' down can't stop now hmm oh shut your mouth ain't got no tears left to cry ohyeah oh yeah   oh i just want you to come with me with me we're on another mentality ain't got no tears left to cry cry so i'm pickin' it up yeah pickin' it up oh yeah i'm lovin' i'm livin' i'm pickin' it up  refrain pickin' it up pickin' it up lovin' i'm livin' so we turnin' up hmm yeah we turnin' it up	locale	\N
5	Swish Swish	233	refrain they know what is what but they don't know what is what they just strut what the fuck   katy perry a tiger don't lose no sleep don't need opinions from a shellfish or a sheep don't you come for me no not today you're calculated i got your number 'cause you're a joker and i'm a courtside killer queen and you will kiss the ring you best believe  pre katy perry so keep calm honey i'ma stick around for more than a minute get used to it funny my name keeps comin' outcho mouth 'cause i stay winning lay 'em up like   katy perry swish swish bish another one in the basket can't touch this another one in the casket   katy perry your game is tired you should retire you're 'bout cute as an old coupon expired and karma's not a liar she keeps receipts  pre katy perry so keep calm honey i'ma stick around for more than a minute get used to it funny my name keeps comin' outcho mouth 'cause i stay winning lay 'em up like   katy perry swish swish bish another one in the basket can't touch this another one in the casket swish swish bish another one in the basket can't touch this another one in the casket  refrain they know what is what but they don't know what is what katy perry they just know what is what young money but they don't know what is what they just know what is what but they don't know what is what they just strut hahaha yo what the fuck   nicki minaj pink ferragamo sliders on deck silly rap beefs just get me more checks my life is a movie i'm never off set me and my amigos no not offset swish swish aww i got them upset but my shooters'll make 'em dance like dubstep swish swish aww my haters is obsessed 'cause i make m's they get much less don't be tryna double back i already despise you all that fake love you showin' couldn't even disguise you ran when nicki gettin' tan mirror mirror who's the fairest bitch in all the land damn man this bitch is a stan muah muah the generous queen will kiss a fan ass goodbye i'ma be riding by i'ma tell my  biggz yeah that's tha guy a star's a star da ha da ha they never thought the swish god would take it this far get my pimp cup this is pimp shit baby i only rock with queens so i'm makin' hits with katy   katy perry swish swish bish another one in the basket can't touch this another one in the casket  refrain they know what is what do they know but they don't know what is what they just know what is what but they don't know what is what they just know what is what but they don't know what is what they just strut what the	locale	\N
6	Chained to the Rhythm	165	katy perry are we crazy living our lives through a lens trapped in our white picket fence like ornaments so comfortable we're living in a bubble bubble so comfortable we cannot see the trouble trouble aren't you lonely up there in utopia where nothing will ever be enough happily numb so comfortable we're living in a bubble bubble so comfortable we cannot see the trouble trouble  pre katy perry so put your rosecolored glasses on and party on   katy perry turn it up it's your favorite song dance dance dance to the distortion come on turn it up keep it on repeat stumbling around like a wasted zombie yeah we think we're free drink this one is on me we're all chained to the rhythm to the rhythm to the rhythm turn it up it's your favorite song dance dance dance to the distortion come on turn it up keep it on repeat stumbling around like a wasted zombie yeah we think we're free drink this one is on me we're all chained to the rhythm to the rhythm to the rhythm   katy perry are we tone deaf keep sweeping it under the mat thought we could do better than that i hope we can so comfortable we're living in a bubble bubble so comfortable we cannot see the trouble trouble  pre katy perry so put your rosecolored glasses on and party on   katy perry turn it up it's your favorite song dance dance dance to the distortion come on turn it up keep it on repeat stumbling around like a wasted zombie yeah we think we're free drink this one is on me we're all chained to the rhythm to the rhythm to the rhythm turn it up it's your favorite song dance dance dance to the distortion come on turn it up keep it on repeat stumbling around like a wasted zombie yeah we think we're free drink this one is on me we're all chained to the rhythm to the rhythm to the rhythm   skip marley it is my desire break down the walls to connect inspire ay up in your high place liars time is ticking for the empire the truth they feed is feeble as so many times before they greed over the people they stumbling and fumbling and we're about to riot they woke up they woke up the lions woo   katy perry turn it up it's your favorite song dance dance dance to the distortion come on turn it up keep it on repeat stumbling around like a wasted zombie yeah we think we're free drink this one is on me we're all chained to the rhythm to the rhythm to the rhythm   katy perry turn it up turn it up it goes on and on and on it goes on and on and on it goes on and on and on 'cause we're all chained to the rhythm	locale	\N
7	Dark Horse	151	juicy j yeah ya'll know what it is katy perry juicy j uhhuh let's rage   katy perry i knew you were you were gonna come to me and here you are but you better choose carefully 'cause i i'm capable of anything of anything and everything make me your aphrodite make me your one and only but don't make me your enemy enemy your enemy your enemy your enemy   katy perry so you wanna play with magic boy you should know what you're fallin' for baby do you dare to do this 'cause i'm coming at you like a dark horse are you ready for ready for a perfect storm perfect storm 'cause once you're mine once you're mine there's no going back   katy perry mark my words this love will make you levitate like a bird like a bird without a cage we're down to earth if you choose to walk away don't walk away walk away it's in the palm of your hand now baby it's a yes or a no no maybe so just be sure before you give it all to me all to me give it all to me   katy perry so you wanna play with magic boy you should know what you're fallin' for baby do you dare to do this 'cause i'm coming at you like a dark horse are you ready for ready for a perfect storm perfect storm 'cause once you're mine once you're mine there's no going back   juicy j she's a beast i call her karma come back she eat your heart out like jeffrey dahmer woo be careful try not to lead her on shawty's heart is on steroids 'cause her love is so strong you may fall in love when you meet her meet her if you get the chance you better keep her keep her she's sweet as pie but if you break her heart she turn cold as a freezer freezer that fairy tale ending with a knight in shining armor she can be my sleeping beauty i'm gon' put her in a coma woo damn i think i love her shawty's so bad i'm sprung and i don't care she ride me like a roller coaster turn the bedroom into a fair a fair her love is like a drug i was tryna hit it and quit it but lil mama so dope i messed around and got addicted   katy perry so you wanna play with magic boy you should know what you're fallin' for you should know baby do you dare to do this 'cause i'm coming at you like a dark horse like a dark horse are you ready for ready for ready for a perfect storm perfect storm a perfect storm 'cause once you're mine once you're mine there's no going back  produced by max martin and dr luke video directed by matthew cullen	locale	\N
8	Bon Appétit	237	quavo ayy yeah katy perry migos ayy   katy perry 'cause i'm all that you want boy all that you can have boy got me spread like a buffet bon a bon appétit baby appetite for seduction fresh out the oven melt in your mouth kind of lovin' bon a bon appétit baby woo   katy perry looks like you've been starving you've got those hungry eyes woo you could use some sugar 'cause your levels ain't right woo i'm a fivestar michelin a kobe flown in woo you want what i'm cooking boy  pre katy perry let me take you woo under candlelight we can wine and dine a table for two and it's okay woo if you take your time eat with your hands fine i'm on the menu   katy perry 'cause i'm all that you want boy all that you can have boy got me spread like a buffet bon a bon appétit baby appetite for seduction fresh out the oven melt in your mouth kind of lovin' bon a bon appétit baby woo   katy perry  quavo so you want some more well i'm open 4 woo wanna keep you satisfied customer's always right woo hope you've got some room for the world's best cherry pie woo gonna hit that sweet tooth ayy boy  pre katy perry quavo  both let me take you woo under candlelight we can wine and dine a table for two and it's okay woo if you take your time ayy eat with your hands fine yeah i'm on the menu go ahead   katy perry  quavo 'cause i'm all that you want boy all that you want all that you can have boy ayy got me spread like a buffet bon a bon appétit baby bon appétit appetite for seduction fresh out the oven fresh out the oven melt in your mouth kind of lovin' bon appétit baby 'cause i'm all that you want boy all that you can have boy got me spread like a buffet bon a bon appétit baby bon appétit appetite for seduction fresh out the oven melt in your mouth kind of lovin' bon a bon appétit baby quavo   quavo sweet potato pie it'll change your mind change got you running back for seconds running every single night  4 takeoff i'm the one they say can change your life takeoff no waterfall she drippin' wet you like my ice blast she say she want a migo night now i ask her what's the price hold on if she do right told her get whatever you like  5 offset offset i grab her legs and now divide aight make her do a donut when she ride aight looking at the eyes of a dime make you blind in her spine and my diamonds change the climate  6 quavo  katy perry sweet tooth no tooth fairy whipped cream no dairy got her hot light on screaming i'm ready but no horses no carriage   katy perry  quavo 'cause i'm all that you want boy all that you want all that you can have boy oh got me spread like a buffet bon a bon appétit baby eat it up eat it up eat it up appetite for seduction yeah yeah yeah fresh out the oven melt in your mouth kind of lovin' bon a bon appétit baby bon appétit   quavo  katy perry under candlelight yeah woo bon appétit baby	locale	\N
9	Roar	221	i used to bite my tongue and hold my breath scared to rock the boat and make a mess so i sat quietly agreed politely i guess that i forgot i had a choice i let you push me past the breaking point i stood for nothing so i fell for everything  pre you held me down but i got up hey already brushing off the dust you hear my voice your hear that sound like thunder gonna shake the ground you held me down but i got up hey get ready cause i had enough i see it all i see it now   i got the eye of the tiger a fighter dancing through the fire 'cause i am a champion and youre gonna hear me roar louder louder than a lion 'cause i am a champion and youre gonna hear me roar  post oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh youre gonna hear me roar   now im floating like a butterfly stinging like a bee i earned my stripes i went from zero to my own hero  pre you held me down but i got up hey already brushing off the dust you hear my voice you hear that sound like thunder gonna shake the ground you held me down but i got up got up get ready 'cause i've had enough i see it all i see it now   i got the eye of the tiger a fighter dancing through the fire 'cause i am a champion and youre gonna hear me roar louder louder than a lion 'cause i am a champion and youre gonna hear me roar  post oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh youre gonna hear me roar oh oh oh oh oh oh oh oh oh oh oh oh oh oh you'll hear me roar oh oh oh oh oh oh oh youre gonna hear me roar   roar roar roar roar roar   i got the eye of the tiger a fighter dancing through the fire 'cause i am a champion and youre gonna hear me roar oh louder louder than a lion 'cause i am a champion and youre gonna hear me roar  post oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh oh yeah youre gonna hear me roar oh oh oh oh oh oh oh oh oh oh oh oh oh oh you'll hear me roar oh oh oh oh oh oh oh youre gonna hear me roar  video directed by grady hall  mark kudsi produced by dr luke  max martin	locale	\N
10	Young Dumb & Broke	174	so you're still thinking of me just like i know you should i can not give you everything you know i wish i could i'm so high at the moment i'm so caught up in this yeah we're just young dumb and broke but we still got love to give   while we're young dumb young young dumb and broke young dumb young young dumb and broke young dumb young dumb young young dumb and broke young dumb broke high school kids yadadadadadadada yadadadadadada yadadadadadadada young dumb broke high school kids   we have so much in common we argue all the time you always say i'm wrong i'm pretty sure i'm right what's fun about commitment when we have our life to live yeah we're just young dumb and broke but we still got love to give   while we're young dumb young young dumb and broke young dumb young young dumb and broke young dumb young young dumb and broke young dumb broke high school kids yadadadadadadada yadadadadadada yadadadadadadada young dumb broke high school kids   jump and we think  do it all in the name of love love run into sin do it all in the name of fun fun whoaoaoa i'm so high at the moment i'm so caught up in this yeah we're just young dumb and broke but we still got love to give   while we're young dumb young young dumb and broke young dumb young young dumb and broke young dumb young dumb young young dumb and broke young dumb broke high school kids yadadadadadadada yadadadadadada yadadadadadadada young dumb broke high school kids	locale	\N
11	Location	224	send me your location let's focus on communicating 'cause i just need the time and place to come through place to come through send me your location let's ride the vibrations i don't need nothing else but you do not need nothing else but you   at times i wonder why i fool with you but this is new to me this is new to you initially i didn't wanna fall for you gather my attention it was all for you so don't take advantage don't leave my heart damaged i understand that things go a little bit better when you plan it oh so won't   send me your location let's focus on communicating 'cause i just need the time and place to come through send me your location let's ride the vibrations i don't need nothing else but you i don't need nothing else but you   i don't wanna fall in love off of subtweets so let's get personal i got a lot of cool spots that we can go tell me what's the move and i got you i'm only acting like this 'cause i like you just give me the vibe to slide in oh i might make you mine by the night and   send me your location let's focus on communicating 'cause i just need the time and place to come through place to come through send me your location let's ride the vibrations i don't need nothing else but you i don't need nothing else but you   ride ride ride come and vibe with me tonight i don't need nothing else but you i don't need nothing else but you ride ride ride come and vibe with me tonight i don't need nothing else but you nothing else but you do do do do do do oh oh mmm mmm mmm mmm oh oh oh oh oh oh mmm mmm mmm do do do do do do do do do do do do do do do i don't need nothing else but you	locale	\N
12	Better	176	better nothing baby nothing feels better i'm not really drunk i never get that fucked up i'm not i'm so sober   love to see you shine in the night like the diamond you are love to see you shine in the night like the diamond you are i'm good on the side it's alright just hold me in the dark i'm good on the side it's alright just hold me in the dark no one's gotta know what we do hit me up when you're bored no one's gotta know what we do hit me up when you're bored 'cause i live down the street so we meet when you need and it's yours all i hear is   nothing feels better than this nothing feels better nothing feels better than this nothing feels better oh no we don't gotta hide this is what you like i'll admit nothing feels better than this   you say we're just friends but i swear when nobody's around you say we're just friends but i swear when nobody's around you keep my hand around your neck we connect are you feeling it now you keep my hand around your neck we connect are you feeling it now 'cause i am i got so high the other night i swear to god felt my feet lift the ground i got so high the other night i swear to god i felt my feet lift the ground ooh yeah your back against the wall this is all you've been talking about in my ears   nothing feels better than this nothing feels better nothing feels better than this nothing feels better oh no we don't gotta hide this is what you like i admit nothing feels better than this   now left right left right take it back bring it side to side like that like that ayy ooh now left right left right take it back bring it side to side like   nothing feels better than this nothing feels better nothing feels better than this nothing feels better oh no we don't gotta hide this is what you like i admit nothing feels better than this better than this   nothing feels better than this	locale	\N
25	New Rules	214	one one one one one   talkin' in my sleep at night makin' myself crazy out of my mind out of my mind wrote it down and read it out hopin' it would save me too many times too many times  refrain my love he makes me feel like nobody else nobody else but my love he doesn't love me so i tell myself i tell myself  pre one don't pick up the phone you know he's only callin' 'cause he's drunk and alone two don't let him in you'll have to kick him out again three don't be his friend you know you're gonna wake up in his bed in the morning and if you're under him you ain't gettin' over him   i got new rules i count 'em i got new rules i count 'em i gotta tell them to myself i got new rules i count 'em i gotta tell them to myself   i keep pushin' forwards but he keeps pullin' me backwards nowhere to turn no way nowhere to turn no now i'm standin' back from it i finally see the pattern i never learn i never learn  refrain but my love he doesn't love me so i tell myself i tell myself i do i do i do  pre one don't pick up the phone you know he's only callin' 'cause he's drunk and alone two don't let him in you'll have to kick him out again three don't be his friend you know you're gonna wake up in his bed in the morning and if you're under him you ain't gettin' over him   i got new rules i count 'em i got new rules i count 'em i gotta tell them to myself i got new rules i count 'em i gotta tell them to myself   practice makes perfect i'm still tryna learn it by heart i got new rules i count 'em eat sleep and breathe it rehearse and repeat it 'cause i i got new  pre one don't pick up the phone yeah you know he's only callin' 'cause he's drunk and alone alone two don't let him in uhooh you'll have to kick him out again again three don't be his friend you know you're gonna wake up in his bed in the morning and if you're under him you ain't gettin' over him   i got new rules i count 'em i got new rules i count 'em whoaooh whoaooh whoa i gotta tell them to myself i got new rules i count 'em baby you know i count 'em i gotta tell them to myself   don't let him in don't let him in don't don't don't don't don't be his friend don't be his friend don't don't don't don't don't let him in don't let him in don't don't don't don't don't be his friend don't be his friend don't don't don't don't you're gettin' over him	locale	\N
13	Talk	197	can we just talk can we just talk talk about where we're goin' before we get lost lend me your thoughts can't get what we want without knowin' i've never felt like this before i apologize if i'm movin' too far can we just talk can we just talk figure out where we're goin'   yeah started off right i can see it in your eyes i can tell that you're wantin' more what's been on your mind there's no reason we should hide tell me somethin' i ain't heard before  pre oh i've been dreamin' 'bout it and it's you i'm on so stop thinkin' 'bout it   can we just talk can we just talk talk about where we're goin' before we get lost lend me your thoughts yeah can't get what we want without knowin' no i've never felt like this before i apologize if i'm movin' too far can we just talk can we just talk figure out where we're goin'   oh nah penthouse view left some flowers in the room i'll make sure i leave the door unlocked now i'm on the way swear i won't be late i'll be there by five o'clock  pre oh you've been dreamin' 'bout it and i'm what you want so stop thinkin' 'bout it   can we just talk oh can we just talk talk about where we're goin' before we get lost lend me your thoughts can't get what we want without knowin' i've never felt like this before i apologize if i'm movin' too far can we just talk can we just talk figure out where we're goin'   figure out where we're goin'	locale	\N
14	Saved	201	4   the hard part always seems to last forever sometimes i forget that we aren't together deep down in my heart i hope you're doing alright but from time to time i often think of why you aren't mine   but i'll keep your number saved 'cause i hope one day you'll get the sense to call me i'm hoping that you'll say you're missing me the way i'm missing you so i'll keep your number saved 'cause i hope one day i'll get the pride to call you to tell you that no one else is gonna hold you down the way that i do   now i can't say i'll be alright without you and i can't say that i haven't tried to but all your stuff is gone i erased all the pictures from my phone of me and you here's what i'll do   i'll keep your number saved 'cause i hope one day you'll get the sense to call me i'm hoping that you'll say you're missing me the way i'm missing you so i'll keep your number saved 'cause i hope one day i'll get the pride to call you to tell you that no one else is gonna hold you down the way that i do   i hope you think of all the times we shared i hope you'll finally realize i was the only one who cared it's crazy how this love thing seems unfair you won't find a love like mine anywhere   but i'll keep your number saved 'cause i hope one day you'll get the sense to call me i'm hoping that you'll say you're missing me the way i'm missing you so i'll keep your number saved 'cause i hope one day i'll get the pride to call you to tell you that no one else is gonna hold you down the way that i do but i'll keep your number saved 'cause i hope one day you'll get the sense to call me i'm hoping that you'll say you're missing me the way i'm missing you so i'll keep your number saved 'cause i hope one day i'll get the pride to call you to tell you that i'm finally over you i'm finally over you	locale	\N
15	Lose You To Love Me	181	you promised the world and i fell for it i put you first and you adored it set fires to my forest and you let it burn sang offkey in my  'cause it wasn't yours i saw the signs and i ignored it rosecolored glasses all distorted set fire to my purpose and i let it burn you got off on the hurtin' when it wasn't yours yeah  pre we'd always go into it blindly i needed to lose you to find me this dancing was killing me softly i needed to hate you to love me yeah   to love love yeah to love love yeah to love yeah i needed to lose you to love me yeah to love love yeah to love love yeah to love yeah i needed to lose you to love me   i gave my all and they all know it then you tore me down and now it's showing in two months you replaced us like it was easy made me think i deserved it in the thick of healing yeah  pre we'd always go into it blindly i needed to lose you to find me this dancing was killing me softly i needed to hate you to love me yeah   to love love yeah to love love yeah to love yeah i needed to lose you to love me yeah to love love yeah to love love yeah to love yeah i needed to lose you to love me   you promised the world and i fell for it i put you first and you adored it set fires to my forest and you let it burn sang offkey in my    to love love yeah to love love yeah to love yeah i needed to hate you to love me yeah to love love yeah to love love yeah to love yeah i needed to lose you to love me to love love yeah to love love yeah to love yeah   and now the chapter is closed and done to love love yeah to love love yeah to love yeah and now it's goodbye it's goodbye for us	locale	\N
16	Back to You	163	took you like a shot thought that i could chase you with a cold evenin' let a couple years water down how im feelin' about you feelin' about you and every time we talk every single word builds up to this moment and i gotta convince myself i dont want it even though i do even though i do  pre you could break my heart in two but when it heals it beats for you i know it's forward but it's true   i wanna hold you when i'm not supposed to when i'm lyin' close to someone else you're stuck in my head and i can't get you out of it if i could do it all again i know id go back to you  post i know id go back to you oh i know i'd go back to you   we never got it right playin and replayin' old conversations overthinkin' every word and i hate it 'cause its not me 'cause it's not me 'cause it's not me and what's the point in hidin' everybody knows we got unfinished business and i'll regret it if i didn't say this isn't what it could be isn't what it could be  pre you could break my heart in two but when it heals it beats for you i know it's forward but it's true   i wanna hold you when i'm not supposed to when i'm lyin' close to someone else you're stuck in my head and i can't get you out of it if i could do it all again i know i'd go back to you  post i know i'd go back to you i know i'd go back to you i'd go back to you i'd go back to you i know i said i wasn't sure but i'd go back to you i know i'd go back to you   you can break my heart in two but when it heals it beats for you i know it's forward but it's true won't lie i'd go back to you you know my thoughts are runnin' loose it's just a thing you make me do and i could fight but what's the use i know i'd go back to you   i wanna hold you when i'm not supposed to when i'm lyin' close to someone else you're stuck in my head and i can't get you out of it if i could do it all again i know i'd go back to you  post i'll go back to you i'll go back to you i know i'd go back to you i'd go back to you i'd go back to you i know i'd go back to you go back to you go back to you go back to you go back to you go back to you go back to you	locale	\N
17	Fetish	233	selena gomez take it or leave it baby take it or leave it but i know you won't leave it 'cause i know that you need it look in the mirror when i look in the mirror baby i see it clearer why you wanna be nearer  pre selena gomez i'm not surprised i sympathize ah i can't deny your appetite ah   selena gomez you got a fetish for my love i push you out and you come right back don't see a point in blaming you if i were you i'd do me too you got a fetish for my love i push you out and you come right back don't see a point in blaming you if i were you i'd do me too you got a fetish for my love   selena gomez reaching your limit say you're reaching your limit going over your limit but i know you can't quit it something about me got you hooked on my body take you over and under and twisted up like origami  pre selena gomez i'm not surprised i sympathize ah i can't deny your appetite ah   selena gomez you got a fetish for my love i push you out and you come right back don't see a point in blaming you if i were you i'd do me too you got a fetish for my love i push you out and you come right back don't see a point in blaming you if i were you i'd do me too you got a fetish for my love   gucci mane it's gucci the way you walk the way you talk i blame you 'cause it's all your fault you're playin' hard don't turn me off you actin' hard but i know you soft you my fetish i'm so with it all these rumors bein' spreaded might as well go 'head and whip it 'cause they sayin' we already did it call on gucci if you ever need me i'll be south beach in the drop top gleamin' water diamonds aquafina just need you in a blue bikini   selena gomez you got a fetish for my love i push you out and you come right back don't see a point in blaming you if i were you i'd do me too you got a fetish for my love i push you out and you come right back don't see a point in blaming you if i were you i'd do me too you got a fetish for my love	locale	\N
19	Look At Her Now	201	yeah   they fell in love one summer a little too wild for each other shiny 'til it wasn't feels good 'til it doesn't it was her first real lover his too 'til he had another oh god when she found out trust levels went way down  pre of course she was sad but now she's glad she dodged a bullet mm took a few years to soak up the tears but look at her now watch her go   mmmmmm mmmmmm mmmm look at her now watch her go mmmmmm mmmmmm mmmm wow look at her now mmmmmm mmmmmm mmmm look at her now watch her go mmmmmm mmmmmm mmmm wow look at her now  post wow look at her now   fast nights that got him that new life was his problem not saying she was perfect still regrets that moment like that night wasn't wrong wasn't right yeah what a thing to be human what a thing to be human made her more of a woman made her more of a woman  pre of course she was sad but now she's glad she dodged a bullet mm took a few years to soak up the tears but look at her now watch her go   mmmmmm mmmmmm mmmm look at her now watch her go mmmmmm mmmmmm mmmm wow look at her now look at her now mmmmmm mmmmmm mmmm look at her now watch her go mmmmmm mmmmmm mmmm wow look at her now  post ah wow look at her now look at her now look at her now wow look at her now   she knows she'll find love she knows only if she wants it she knows she'll find love she knows she knows she'll find love she knows only if she wants it she knows she'll find love she knows on the up from the way down look at her now watch her go   mmmm look at her now mmmm oh she knows she'll find love she knows she will only if she wants it she knows she'll find love look at her now yeah look at her now she knows she'll find love she knows she will only if she wants it she knows she'll find love wow look at her now	locale	\N
20	​when the party’s over	240	don't you know i'm no good for you i've learned to lose you can't afford to tore my shirt to stop you bleedin' but nothin' ever stops you leavin'   quiet when i'm coming home and i'm on my own i could lie say i like it like that like it like that i could lie say i like it like that like it like that   don't you know too much already i'll only hurt you if you let me call me friend but keep me closer call me back and i'll call you when the party's over   quiet when i'm coming home and i'm on my own and i could lie say i like it like that like it like that yeah i could lie say i like it like that like it like that   but nothin' is better sometimes once we've both said our goodbyes let's just let it go let me let you go   quiet when i'm coming home and i'm on my own i could lie say i like it like that like it like that i could lie say i like it like that like it like that	locale	\N
21	​everything i wanted	241	i had a dream i got everything i wanted not what you'd think and if i'm bein' honest it might've been a nightmare to anyone who might care thought i could fly fly so i stepped off the golden mm nobody cried cried cried cried cried nobody even noticed i saw them standing right there kinda thought they might care might care might care  pre i had a dream i got everything i wanted but when i wake up i see you with me   and you say as long as i'm here no one can hurt you don't wanna lie here but you can learn to if i could change the way that you see yourself you wouldn't wonder why you hear 'they don't deserve you'   i tried to scream but my head was underwater they called me weak like i'm not just somebody's daughter coulda been a nightmare but it felt like they were right there and it feels like yesterday was a year ago but i don't wanna let anybody know 'cause everybody wants something from me now and i don't wanna let 'em down  pre i had a dream i got everything i wanted but when i wake up i see you with me   and you say as long as i'm here no one can hurt you don't wanna lie here but you can learn to if i could change the way that you see yourself you wouldn't wonder why you hear 'they don't deserve you'   if i knew it all then would i do it again would i do it again if they knew what they said would go straight to my head what would they say instead if i knew it all then would i do it again would i do it again if they knew what they said would go straight to my head what would they say instead	locale	\N
22	​bad guy	155	white shirt now red my bloody nose sleepin' you're on your tippy toes creepin' around like no one knows think you're so criminal bruises on both my knees for you don't say thank you or please i do what i want when i'm wanting to my soul so cynical   so you're a tough guy like it really rough guy just can't get enough guy chest always so puffed guy i'm that bad type make your mama sad type make your girlfriend mad tight might seduce your dad type i'm the bad guy duh  post i'm the bad guy   i like it when you take control even if you know that you don't own me i'll let you play the role i'll be your animal my mommy likes to sing along with me but she won't sing this song if she reads all the lyrics she'll pity the men i know   so you're a tough guy like it really rough guy just can't get enough guy chest always so puffed guy i'm that bad type make your mama sad type make your girlfriend mad tight might seduce your dad type i'm the bad guy duh  post i'm the bad guy duh i'm only good at bein' bad bad   i like when you get mad i guess i'm pretty glad that you're alone you said she's scared of me i mean i don't see what she sees but maybe it's 'cause i'm wearing your cologne   i'm a bad guy i'm i'm a bad guy bad guy bad guy i'm a bad	locale	\N
23	​idontwannabeyouanymore	170	don't be that way fall apart twice a day i just wish you could feel what you say show never tell but i know you too well kind of mood that you wish you could sell   if teardrops could be bottled there'd be swimming pools filled by models told a tight dress is what makes you a whore if i love you was a promise would you break it if you're honest tell the mirror what you know she's heard before i don't wanna be you anymore   hands hands getting cold losing feeling is getting old was i made from a broken mold hurt i can't shake we've made every mistake only you know the way that i break   if teardrops could be bottled there'd be swimming pools filled by models told a tight dress is what makes you a whore if i love you was a promise would you break it if you're honest tell the mirror what you know she's heard before i don't wanna be you i don't wanna be you i don't wanna be you anymore	locale	\N
24	​bury a friend	212	mehki raine billie   billie eilish what do you want from me why don't you run from me what are you wondering what do you know why aren't you scared of me why do you care for me when we all fall asleep where do we go   billie eilish  mehki raine come here say it spit it out what is it exactly you're payin' is the amount cleanin' you out am i satisfactory today i'm thinkin' about the things that are deadly the way i'm drinkin' you down like i wanna drown like i wanna end me  refrain billie eilish step on the glass staple your tongue ahh bury a friend try to wake up ahahh cannibal class killing the son ahh bury a friend i wanna end me  pre billie eilish i wanna end me i wanna i wanna i wanna end me i wanna i wanna i wanna   billie eilish what do you want from me why don't you run from me what are you wondering what do you know why aren't you scared of me why do you care for me when we all fall asleep where do we go   billie eilish  mehki raine listen keep you in the dark what had you expected me to make you my art and make you a star and get you connected i'll meet you in the park i'll be calm and collected but we knew right from the start that you'd fall apart 'cause i'm too expensive it's probably somethin' that shouldn't be said out loud honestly i thought that i would be dead by now wow calling security keepin' my head held down bury the hatchet or bury a friend right now   billie eilish  mehki raine the debt i owe gotta sell my soul 'cause i can't say no no i can't say no then my limbs all froze and my eyes won't close and i can't say no i can't say no careful  refrain billie eilish step on the glass staple your tongue ahh bury a friend try to wake up ahahh cannibal class killing the son ahh bury a friend i wanna end me  pre billie eilish i wanna end me i wanna i wanna i wanna end me i wanna i wanna i wanna   billie eilish what do you want from me why don't you run from me what are you wondering what do you know why aren't you scared of me why do you care for me when we all fall asleep where do we go	locale	\N
26	Don’t Start Now	213	if you don't wanna see me   did a full 80 crazy thinking 'bout the way i was did the heartbreak change me maybe but look at where i ended up i'm all good already so moved on it's scary i'm not where you left me at all so  pre if you don't wanna see me dancing with somebody if you wanna believe that anything could stop me   don't show up don't come out don't start caring about me now walk away you know how don't start caring about me now   aren't you the guy who tried to hurt me with the word goodbye though it took some time to survive you i'm better on the other side i'm all good already so moved on it's scary i'm not where you left me at all so  pre if you don't wanna see me dancing with somebody if you wanna believe that anything could stop me don't don't don't   don't show up don't come out don't start caring about me now walk away you know how don't start caring about me now 'bout me now 'bout me   up up don't come out out out don't show up up up don't start now oh up up don't come out out i'm not where you left me at all so  pre if you don't wanna see me dancing with somebody if you wanna believe that anything could stop me   don't show up don't show up don't come out don't come out don't start caring about me now 'bout me now walk away walk away you know how you know how don't start caring about me now so   up up don't come out out out don't show up up up walk away walk away so up up don't come out out out don't show up up up walk away walk away oh	locale	\N
27	IDGAF	220	you call me all friendly tellin' me how much you miss me that's funny i guess you've heard my songs well i'm too busy for your business go find a girl who wants to listen 'cause if you think i was born yesterday you have got me wrong  pre so i cut you off i don't need your love 'cause i already cried enough i've been done i've been movin' on since we said goodbye i cut you off i don't need your love so you can try all you want your time is up i'll tell you why   you say you're sorry but it's too late now so save it get gone shut up 'cause if you think i care about you now well boy i don't give a fuck   i remember that weekend when my best friend caught you creepin' you blamed it all on the alcohol so i made my decision 'cause you made your bed sleep in it play the victim and switch your position i'm through i'm done  pre so i cut you off i don't need your love 'cause i already cried enough i've been done i've been movin' on since we said goodbye i cut you off i don't need your love so you can try all you want your time is up i'll tell you why   you say you're sorry but it's too late now so save it get gone shut up 'cause if you think i care about you now well boy i don't give a fuck  post i see you tryna get to me i see you beggin' on your knees boy i don't give a fuck so stop tryna get to me tch get up off your knees 'cause boy i don't give a fuck   about you no i don't give a damn you keep reminiscin' on when you were my man but i'm over you now you're all in the past you talk all that sweet talk but i ain't comin' back  breakdown cut you off i don't need your love so you can try all you want your time is up i'll tell you why i'll tell you why   you say you're sorry but it's too late now so save it get gone shut up too late now 'cause if you think i care about you now well boy i don't give a fuck boy i don't give a  post i see you tryna get to me i see you beggin' on your knees boy i don't give a fuck so stop tryna get to me get to me tch get up off your knees 'cause boy i don't give a fuck	locale	\N
28	Blow Your Mind (Mwah)	188	i know it's hot i know we've got something that money can't buy fighting in fits biting your lip loving 'til late in the night  pre tell me i'm too crazy you can't tame me can't tame me tell me i have changed but i'm the same me old same me inside hey   if you don't like the way i talk then why am i on your mind if you don't like the way i rock then finish your glass of wine we fight and we argue you'll still love me blind if we don't fuck this whole thing up guaranteed i can blow your mind mwah  post and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah mwah mwah mwah mwah   yeah i'm so bad best that you've had i guess you're diggin' the show open the door you want some more when you wanna leave let me know  pre tell me i'm too crazy you can't tame me can't tame me tell me i have changed but i'm the same me old same me inside hey   if you don't like the way i talk then why am i on your mind if you don't like the way i rock then finish your glass of wine we fight and we argue you'll still love me blind if we don't fuck this whole thing up guaranteed i can blow your mind mwah  post and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah  breakdown and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah hey and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind hey  pre tell me i'm too crazy you can't tame me can't tame me tell me i have changed but i'm the same me old same me inside hey mwah   if you don't like the way i talk then why am i on your mind if you don't like the way i rock then finish your glass of wine we fight and we argue you'll still love me blind if we don't fuck this whole thing up guaranteed i can blow your mind mwah  post and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah and tonight i'm alive ain't no dollar sign guaranteed i can blow your mind mwah	locale	\N
29	Be the One	202	i see the moon i see the moon i see the moon oh when you're looking at the sun i'm not a fool i'm not a fool not a fool no you're not fooling anyone  pre oh but when you're gone when you're gone when you're gone oh baby all the lights go out thinking oh that baby i was wrong i was wrong i was wrong come back to me baby we can work this out   oh baby come on let me get to know you just another chance so that i can show that i won't let you down and run no i won't let you down and run 'cause i could be the one i could be the one i could be the one i could be the one   i see in blue i see in blue i see in blue oh when you see everything in red there is nothing that i wouldn't do for you do for you do for you oh 'cause you got inside my head  pre oh but when you're gone when you're gone when you're gone oh baby all the lights go out thinking oh that baby i was wrong i was wrong i was wrong come back to me baby we can work this out   oh baby come on let me get to know you just another chance so that i can show that i won't let you down and run no i won't let you down and run 'cause i could be the one i could be the one i could be the one   be the one be the one be the one be the one be the one be the one i could be the one be the one be the one be the one be the one be the one be the one i could be the one be the one be the one be the one be the one be the one be the one i could be the one be the one be the one be the one be the one be the one be the one will you be mine   oh baby come on let me get to know you just another chance so that i can show that i won't let you down and run no i won't let you down and run 'cause i could be the one i could be the one i could be the one	locale	\N
30	Do What U Want	208	lady gaga  r kelly yeah oh turn the mic up yeah yeah eh eh eh eh eh eh eh oh eh eh eh eh eh eh eh oh   lady gaga i i feel good i walk alone but then i trip upon myself and i fall i i stand up and then i'm okay but then you print some shit that makes me wanna scream  pre lady gaga so do what you want what you want with my body do what you want don't stop let's party do what you want what you want with my body do what you want what you want with my body write what you want say what you want 'bout me if you're wondering know that i'm not sorry do what you want what you want with my body what you want with my body   lady gaga you can't have my heart and you won't use my mind but do what you want with my body do what you want with my body you cant stop my voice 'cause you don't own my life but do what you want with my body do what you want with my body   r kelly early morning longer nights yeah tom ford private flights yeah crazy schedule fast life i wouldn't trade it in 'cause it's our life but let's slow it down i could be the drink in your cup i could be the green in your blunt your pusher man yeah i got what you want you wanna escape oh all of the crazy shit let go you're the marilyn i'm the president and i love to hear you sing girl  pre  r kelly do what i want do what i want with your body do what i want do what i want with your body back of the club taking shots gettin' naughty no invitations it's a private party do what i want do what i want with your body do what i want do what i want with your body yeah we taking these haters and we roughin' 'em up and we layin the cut like we don't give a fuck   lady gaga  r kelly you can't have my heart and you won't use my mind my mind but do what you want with my body yeah do what you want with my body with your body you cant stop my voice 'cause you don't own my life but do what you want with my body do what you want with my body body   lady gaga sometimes i'm scared i suppose if you ever let me go i would fall apart if you break my heart so just take my body and don't stop the party   lady gaga  r kelly both you can't have my heart and help me now you won't use my mind but do what you want with my body do what you want with my body with your body you cant stop my voice 'cause you don't own my life you but do what you want with my body what i want when i want when i want do what you want with my body   lady gaga do what you want with me what you want with my body do what you want with me what you want with my body world do what you want with me what you want with my body do what you want with me what you want with my body world help me now what you want with my body do what you want with my body do what you want with my body want you want with my body world	locale	\N
31	Always Remember Us This Way	185	that arizona sky burnin' in your eyes you look at me and babe i wanna catch on fire its buried in my soul like california gold you found the light in me that i couldnt find   so when i'm all choked up and i can't find the words every time we say goodbye baby it hurts when the sun goes down and the band won't play i'll always remember us this way   lovers in the night poets tryna write we don't know how to rhyme but damn we try but all i really know you're where i wanna go the part of me that's you will never die   so when i'm all choked up and i can't find the words every time we say goodbye baby it hurts when the sun goes down and the band won't play i'll always remember us this way   oh yeah i don't wanna be just a memory baby yeah hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hoo hooooooooo   so when i'm all choked up and i can't find the words every time we say goodbye baby it hurts when the sun goes down and the band won't play i'll always remember us this way way yeah   when you look at me and the whole world fades i'll always remember us this way   oooh oooh hmmmm oooh oooh hmmmm	locale	\N
32	Bad Romance	166	ohohohohoh ohohohoh ohohoh caught in a bad romance ohohohohoh ohohohoh ohohoh caught in a bad romance raraahahah roma romama gaga ooh lala want your bad romance raraahahah roma romama gaga ooh lala want your bad romance   i want your ugly i want your disease i want your everything as long as its free i want your love love love love i want your love oh ey i want your drama the touch of your hand hey i want your leatherstudded kiss in the sand i want your love love love love i want your love love love love i want your love  pre you know that i want you and you know that i need you i want it bad your bad romance   i want your love and i want your revenge you and me could write a bad romance ohohohohoh i want your love and all your lover's revenge you and me could write a bad romance ohohohohoh ohohohoh ohohoh caught in a bad romance ohohohohoh ohohohoh ohohoh caught in a bad romance  post raraahahah romaromama gaga ooh lala want your bad romance   i want your horror i want your design cause youre a criminal as long as youre mine i want your love love love love i want your love uh i want your psycho your vertigo shtick shtick hey want you in my rear window baby you're sick i want your love love love love i want your love love love love i want your love  pre you know that i want you and you know that i need you 'cause i'm a free bitch baby i want it bad your bad romance   i want your love and i want your revenge you and me could write a bad romance ohohohohoh i want your love and all your lover's revenge you and me could write a bad romance ohohohohoh ohohohoh ohohoh caught in a bad romance ohohohohoh ohohohoh ohohoh caught in a bad romance  post raraahahah romaromama gaga ooh lala want your bad romance raraahahah romaromama gaga ooh lala want your bad romance    walk walk fashion baby work it move that bitch crazy walk walk fashion baby work it move that bitch crazy walk walk fashion baby work it move that bitch crazy walk walk passion baby work it i'm a free bitch baby    i want your love and i want your revenge i want your love i don't wanna be friends je veux ton amour et je veux ta revanche je veux ton amour i don't wanna be friends ohohohohoh ohohohoh ohohoh i want you back no i don't wanna be friends caught in a bad romance i don't wanna be friends want your bad romance caught in a bad romance want your bad romance   i want your love and i want your revenge you and me could write a bad romance ohohohohoh i want your love and all your lover's revenge you and me could write a bad romance ohohohohoh ohohohoh ohohoh want your bad romance caught in a bad romance want your bad romance ohohohohoh ohohohoh ohohoh want your bad romance caught in a bad romance  post raraahahah roma romama gaga ooh lala want your bad romance	locale	\N
33	Sexxx Dreams	194	last night our lovers' quarrel i was thinking about you hurts more than i can say and it was kind of dirty all night and the way that you looked at me help me here it was kind of nasty aah help me here it was kind of trashy 'cause i can't help my mind from going there  pre heard your boyfriend was away this weekend wanna meet at my place heard that we both got nothing to do when i lay in bed i touch myself and think of you   last night damn you were in my sex dreams you were in my doing really nasty things you were in my dreams damn you were in my sex dreams you were in my making love in my sex dreams   we could be caught i just want this to be perfect we're both convicted criminals of thought 'cause i'm broken let's white by the one before glove the bed he was kind of nasty help me here and i feel so trashy 'cause we can't hide the evidence in our heads  pre heard your boyfriend was away this weekend wanna meet at my place heard that we both got nothing to do woo when i lay in bed i touch myself and think of you   last night damn you were in my sex dreams you were in my doing really nasty things you were in my dreams damn you were in my sex dreams you were in my making love in my sex dreams  post don't stop the party making love in my sex dreams let's keep it naughty yeah making love in my sex dreams watch me act a fool making love in my sex dreams tomorrow when i run into you tomorrow when i run into you   you could turn to stone or the color of men petrified by a woman in love as i am when i lay with you i think of him i think of him  spoken interlude i can't believe i'm telling you this but i've had a couple drinks and oh my god   last night damn you were in my sex dreams you were in my doing really nasty things you were in my dreams damn you were in my sex dreams you were in my  post last night don't stop the party damn you were in my sex dreams let's keep it naughty yeah doing really nasty things watch me act a fool damn you were in my sex dreams tomorrow when i run into you making love in my sex dreams	locale	\N
34	I’ll Never Love Again (Extended Version)	154	wish i could i could've said goodbye i would've said what i wanted to maybe even cried for you if i knew it would be the last time i would've broke my heart in two tryin' to save a part of you   don't want to feel another touch don't wanna start another fire don't wanna know another kiss no other name falling off my lips don't wanna to give my heart away to another stranger or let another day begin won't even let the sunlight in no i'll never love again i'll never love again ooouuu ooou oou  oh   when we first met i never thought that i would fall i never thought that i'd find myself lying in your arms and i want to pretend that it's not true oh baby that you're gone 'cause my world keeps turning and turning and turning and i'm not movin' on   don't want to feel another touch don't wanna start another fire don't wanna know another kiss no other name falling off my lips don't wanna give my heart away to another stranger or let another day begin won't even let the sunlight in no i'll never love   i don't wanna know this feeling unless it's you and me i don't wanna waste a moment ooh and i don't wanna give somebody else the better part of me i would rather wait for you hoooo ouuu   don't want to feel another touch don't want to start another fire don't want to know another kiss baby unless they are your lips don't want to give my heart away to another stranger or let another day begin won't even let the sunlight in oooo i'll never love again love again i'll never love again i'll never love again   i won't i won't i swear i can't i wish i could but i just won't i'll never love again i'll never love again who oo oo oo oo hmmm	locale	\N
35	​cardigan	162	vintage tee brand new phone high heels on cobblestones when you are young they assume you know nothing sequin smile black lipstick sensual politics when you are young they assume you know nothing   but i knew you dancin' in your levi's drunk under a streetlight i i knew you hand under my sweatshirt baby kiss it better i  refrain and when i felt like i was an old cardigan under someone's bed you put me on and said i was your favorite   a friend to all is a friend to none chase two girls lose the one when you are young they assume you know nothing   but i knew you playing hideandseek and giving me your weekends i i knew you your heartbeat on the high line once in twenty lifetimes i  refrain and when i felt like i was an old cardigan under someone's bed you put me on and said i was your favorite   to kiss in cars and downtown bars was all we needed you drew stars around my scars but now i'm bleedin'   'cause i knew you steppin' on the last train marked me like a bloodstain i i knew you tried to change the ending peter losing wendy i i knew you leavin' like a father running like water i and when you are young they assume you know nothing   but i knew you'd linger like a tattoo kiss i knew you'd haunt all of my whatifs the smell of smoke would hang around this long 'cause i knew everything when i was young i knew i'd curse you for the longest time chasin' shadows in the grocery line i knew you'd miss me once the thrill expired and you'd be standin' in my front porch light and i knew you'd come back to me you'd come back to me and you'd come back to me and you'd come back  refrain and when i felt like i was an old cardigan under someone's bed you put me on and said i was your favorite	locale	\N
36	​exile	249	justin vernon i can see you standing honey with his arms around your body laughin' but the joke's not funny at all and it took you five whole minutes to pack us up and leave me with it holdin' all this love out here in the hall   justin vernon i think i've seen this film before and i didn't like the ending you're not my homeland anymore so what am i defending now you were my town now i'm in exile seein' you out i think i've seen this film before  post justin vernon ooh ooh ooh   taylor swift i can see you starin' honey like he's just your understudy like you'd get your knuckles bloody for me second third and hundredth chances balancin' on breaking branches those eyes add insult to injury   taylor swift i think i've seen this film before and i didn't like the ending i'm not your problem anymore so who am i offending now you were my crown now i'm in exile seein' you out i think i've seen this film before so i'm leaving out the side door   justin vernon taylor swift  both so step right out there is no amount of crying i can do for you all this time we always walked a very thin line you didn't even hear me out you didn't even hear me out you never gave a warning sign i gave so many signs all this time i never learned to read your mind never learned to read my mind i couldn't turn things around you never turned things around 'cause you never gave a warning sign i gave so many signs so many signs so many signs you didn't even see the signs   taylor swift  justin vernon taylor swift i think i've seen this film before and i didn't like the ending you're not my homeland anymore so what am i defending now you were my town now i'm in exile seein' you out i think i've seen this film before so i'm leavin' out the side door   justin vernon  taylor swift so step right out there is no amount of crying i can do for you all this time we always walked a very thin line you didn't even hear me out didn't even hear me out you never gave a warning sign i gave so many signs all this time i never learned to read your mind never learned to read my mind i couldn't turn things around you never turned things around 'cause you never gave a warning sign i gave so many signs you never gave a warning sign all this time so many times i never learned to read your mind so many signs i couldn't turn things around i couldn't turn things around 'cause you never gave a warning sign you never gave a warning sign you never gave a warning sign ah ah	locale	\N
37	Lover	199	we could leave the christmas lights up 'til january and this is our place we make the rules and there's a dazzling haze a mysterious way about you dear have i known you 0 seconds or 0 years   can i go where you go can we always be this close forever and ever ah take me out and take me home you're my my my my lover   we could let our friends crash in the living room this is our place we make the call and i'm highly suspicious that everyone who sees you wants you i've loved you three summers now honey but i want 'em all   can i go where you go can we always be this close forever and ever ah take me out and take me home forever and ever you're my my my my lover   ladies and gentlemen will you please stand with every  string scar on my hand i take this magnetic force of a man to be my lover my heart's been borrowed and yours has been blue all's well that ends well to end up with you swear to be overdramatic and true to my lover and you'll save all your dirtiest jokes for me and at every table i'll save you a seat lover   can i go where you go can we always be this close forever and ever ah take me out and take me home forever and ever you're my my my my oh you're my my my my darling you're my my my my lover	locale	\N
44	Supermarket Flowers	216	i took the supermarket flowers from the windowsill i threw the day old tea from the cup packed up the photo album matthew had made memories of a life that's been loved took the get well soon cards and stuffed animals poured the old ginger beer down the sink dad always told me don't you cry when you're down but mum there's a tear every time that i blink  pre oh i'm in pieces it's tearing me up but i know a heart that's broke is a heart that's been loved   so i'll sing hallelujah you were an angel in the shape of my mum when i fell down you'd be there holding me up spread your wings as you go when god takes you back he'll say hallelujah you're home   i fluffed the pillows made the beds stacked the chairs up folded your nightgowns neatly in a case john says he'd drive then put his hand on my cheek and wiped a tear from the side of my face  pre i hope that i see the world as you did 'cause i know a life with love is a life that's been lived   so i'll sing hallelujah you were an angel in the shape of my mum when i fell down you'd be there holding me up spread your wings as you go when god takes you back he'll say hallelujah you're home   hallelujah you were an angel in the shape of my mum you got to see the person i have become spread your wings and i know that when god took you back he said hallelujah you're home	locale	\N
38	​the 1	213	i'm doing good i'm on some new shit been saying yes instead of no i thought i saw you at the bus stop i didn't though i hit the ground running each night i hit the sunday matinée you know the greatest films of all time were never made  pre i guess you never know never know and if you wanted me you really should've showed and if you never bleed you're never gonna grow and it's alright now   but we were something don't you think so roaring twenties tossing pennies in the pool and if my wishes came true it would've been you in my defense i have none for never leaving well enough alone but it would've been fun if you would've been the one ooh   i have this dream you're doing cool shit having adventures on your own you meet some woman on the internet and take her home we never painted by the numbers baby but we were making it count you know the greatest loves of all time are over now  pre i guess you never know never know and it's another day waking up alone   but we were something don't you think so roaring twenties tossing pennies in the pool and if my wishes came true it would've been you in my defense i have none for never leaving well enough alone but it would've been fun if you would've been the one   i i i persist and resist the temptation to ask you if one thing had been different would everything be different today   we were something don't you think so rosé flowing with your chosen family and it would've been sweet if it could've been me in my defense i have none for digging up the grave another time but it would've been fun if you would've been the one ooh	locale	\N
39	Look What You Made Me Do	232	i don't like your little games don't like your tilted stage the role you made me play of the fool no i don't like you i don't like your perfect crime how you laugh when you lie you said the gun was mine isn't cool no i don't like you oh  pre but i got smarter i got harder in the nick of time honey i rose up from the dead i do it all the time i've got a list of names and yours is in red underlined i check it once then i check it twice oh   ooh look what you made me do look what you made me do look what you just made me do look what you just made me ooh look what you made me do look what you made me do look what you just made me do look what you just made me do   i don't like your kingdom keys they once belonged to me you asked me for a place to sleep locked me out and threw a feast what the world moves on another day another drama drama but not for me not for me all i think about is karma and then the world moves on but one thing's for sure maybe i got mine but you'll all get yours  pre but i got smarter i got harder in the nick of time honey i rose up from the dead i do it all the time i've got a list of names and yours is in red underlined i check it once then i check it twice oh   ooh look what you made me do look what you made me do look what you just made me do look what you just made me ooh look what you made me do look what you made me do look what you just made me do look what you just made me do   i don't trust nobody and nobody trusts me i'll be the actress starring in your bad dreams i don't trust nobody and nobody trusts me i'll be the actress starring in your bad dreams i don't trust nobody and nobody trusts me i'll be the actress starring in your bad dreams i don't trust nobody and nobody trusts me i'll be the actress starring in your bad dreams ooh look what you made me do look what you made me do look what you just made me do look what you just made me ooh look what you made me do look what you made me do look what you just made me i'm sorry the old taylor can't come to the phone right now why oh 'cause she's dead oh   ooh look what you made me do look what you made me do look what you just made me do look what you just made me ooh look what you made me do look what you made me do look what you just made me do look what you just made me do ooh look what you made me do look what you made me do look what you just made me do look what you just made me ooh look what you made me do look what you made me do look what you just made me do look what you just made me do	locale	\N
40	Shape of You	198	the club isn't the best place to find a lover so the bar is where i go me and my friends at the table doing shots drinking fast and then we talk slow and you come over and start up a conversation with just me and trust me i'll give it a chance now take my hand stop put van the man on the jukebox and then we start to dance and now i'm singing like  pre girl you know i want your love your love was handmade for somebody like me come on now follow my lead i may be crazy don't mind me say boy let's not talk too much grab on my waist and put that body on me come on now follow my lead come come on now follow my lead   i'm in love with the shape of you we push and pull like a magnet do although my heart is falling too i'm in love with your body and last night you were in my room and now my bed sheets smell like you every day discovering something brand new i'm in love with your body ohiohiohiohi i'm in love with your body ohiohiohiohi i'm in love with your body ohiohiohiohi i'm in love with your body every day discovering something brand new i'm in love with the shape of you   one week in we let the story begin we're going out on our first date you and me are thrifty so go all you can eat fill up your bag and i fill up a plate we talk for hours and hours about the sweet and the sour and how your family is doing okay leave and get in a taxi then kiss in the backseat tell the driver make the radio play and i'm singing like  pre girl you know i want your love your love was handmade for somebody like me come on now follow my lead i may be crazy don't mind me say boy let's not talk too much grab on my waist and put that body on me come on now follow my lead come come on now follow my lead   i'm in love with the shape of you we push and pull like a magnet do although my heart is falling too i'm in love with your body and last night you were in my room and now my bed sheets smell like you every day discovering something brand new i'm in love with your body ohiohiohiohi i'm in love with your body ohiohiohiohi i'm in love with your body ohiohiohiohi i'm in love with your body every day discovering something brand new i'm in love with the shape of you   come on be my baby come on come on be my baby come on come on be my baby come on come on be my baby come on come on be my baby come on come on be my baby come on come on be my baby come on come on be my baby come on   i'm in love with the shape of you we push and pull like a magnet do although my heart is falling too i'm in love with your body last night you were in my room and now my bed sheets smell like you every day discovering something brand new i'm in love with your body come on be my baby come on come on be my baby come on i'm in love with your body come on be my baby come on come on be my baby come on i'm in love with your body come on be my baby come on come on be my baby come on i'm in love with your body every day discovering something brand new i'm in love with the shape of you	locale	\N
41	Perfect	173	i found a love for me oh darling just dive right in and follow my lead well i found a girl beautiful and sweet oh i never knew you were the someone waiting for me 'cause we were just kids when we fell in love not knowing what it was i will not give you up this time but darling just kiss me slow your heart is all i own and in your eyes you're holding mine   baby i'm dancing in the dark with you between my arms barefoot on the grass listening to our favourite song when you said you looked a mess i whispered underneath my breath but you heard it darling you look perfect tonight   well i found a woman stronger than anyone i know she shares my dreams i hope that someday i'll share her home i found a love to carry more than just my secrets to carry love to carry children of our own we are still kids but we're so in love fighting against all odds i know we'll be alright this time darling just hold my hand be my girl i'll be your man i see my future in your eyes    baby i'm dancing in the dark with you between my arms barefoot on the grass listening to our favorite song when i saw you in that dress looking so beautiful i don't deserve this darling you look perfect tonight      baby i'm dancing in the dark with you between my arms barefoot on the grass listening to our favorite song i have faith in what i see now i know i have met an angel in person and she looks perfect i don't deserve this you look perfect tonight	locale	\N
42	Castle on the Hill	213	when i was six years old i broke my leg i was running from my brother and his friends and tasted the sweet perfume of the mountain grass i rolled down i was younger then take me back to when i  pre found my heart and broke it here made friends and lost them through the years and i've not seen the roaring fields in so long i know i've grown but i can't wait to go home   i'm on my way driving at 90 down those country lanes singing to tiny dancer and i miss the way you make me feel and it's real we watched the sunset over the castle on the hill   fifteen years old and smoking handrolled cigarettes running from the law through the backfields and getting drunk with my friends had my first kiss on a friday night i don't reckon that i did it right but i was younger then take me back to when  pre we found weekend jobs when we got paid we'd buy cheap spirits and drink them straight me and my friends have not thrown up in so long oh how we've grown but i can't wait to go home   i'm on my way driving at 90 down those country lanes singing to tiny dancer and i miss the way you make me feel and it's real we watched the sunset over the castle on the hill over the castle on the hill over the castle on the hill   one friend left to sell clothes one works down by the coast one had two kids but lives alone one's brother overdosed one's already on his second wife one's just barely getting by but these people raised me and i can't wait to go home   and i'm on my way i still remember these old country lanes when we did not know the answers and i miss the way you make me feel it's real we watched the sunset over the castle on the hill over the castle on the hill over the castle on the hill	locale	\N
43	Happier	239	walking down 9th and park i saw you in another's arm only a month we've been apart you look happier saw you walk inside a bar he said something to make you laugh i saw that both your smiles were twice as wide as ours yeah you look happier you do  prechrous ain't nobody hurt you like i hurt you but ain't nobody love you like i do promise that i will not take it personal baby if you're moving on with someone new   'cause baby you look happier you do my friends told me one day i'll feel it too and until then i'll smile to hide the truth but i know i was happier with you   sat in the corner of the room everything's reminding me of you nursing an empty bottle and telling myself you're happier aren't you  pre  oh ain't nobody hurt you like i hurt you but ain't nobody need you like i do i know that there's others that deserve you but my darling i am still in love with you    but i guess you look happier you do my friends told me one day ill feel it too i could try to smile to hide the truth but i know i was happier with you   cause baby you look happier you do i knew one day youd fall for someone new but if he breaks your heart like lovers do just know that ill be waiting here for you	locale	\N
51	Killshot	150	you sound like a bitch bitch shut the fuck up when your fans become your haters you done fuckin' beard's weird alright you yellin' at the mic fuckin' weird beard you want smoke we doin' this once you yellin' at the mic your beard's weird why you yell at the mic illa  verse rihanna just hit me on a text last night i left hickeys on her neck wait you just dissed me i'm perplexed insult me in a line compliment me on the next damn i'm really sorry you want me to have a heart attack was watchin' 8 mile on my nordictrack realized i forgot to call you back here's that autograph for your daughter i wrote it on a starter cap stan stan son listen man dad isn't mad but how you gonna name yourself after a damn gun and have a manbun the giant's woke eyes open undeniable supplyin' smoke got the fire stoked say you got me in a scope but you grazed me i say one call to interscope and you're swayze your reply got the crowd yelling woo so before you die let's see who can outpetty who with your corny lines slim you're oldow kelly ooh but i'm 45 and i'm still outselling you by 9 i had three albums that had blew now let's talk about somethin' i don't really do go in someone's daughter's mouth stealin' food but you're a fuckin' mole hill now i'ma make a mountain out of you woo ho chill actin' like you put the chrome barrel to my bone marrow gunner bitch you ain't a bow and arrow say you'll run up on me like a phone bill sprayin' lead brrt playin' dead that's the only time you hold still hold up are you eating cereal or oatmeal what the fuck's in the bowl milk wheaties or cheerios 'cause i'm takin' a shit in 'em kelly i need reading material dictionary yo slim your last four albums sucked go back to recovery oh shoot that was three albums ago what do you know oops know your facts before you come at me lil' goof luxury oh you broke bitch yeah i had enough money in '0 to burn it in front of you ho younger me no you the wack me it's funny but so true i'd rather be 80yearold me than 0yearold you 'til i'm hitting old age still can fill a whole page with a 0yearold's rage got more fans than you in your own city lil' kiddy go play feel like i'm babysitting lil tay got the diddy okay so you spent your whole day shootin' a video just to fuckin' dig your own grave got you at your own wake i'm the billy goat you ain't never made a list next to no biggie no jay next to taylor swift and that iggy ho you about to really blow kelly they'll be putting your name next to ja next to benzinodie motherfucker like the last motherfucker sayin' hailie in vain alien brain you satanist yeah my biggest flops are your greatest hits the game's mine again and ain't nothin' changed but the locks so before i slay this bitch i mwah give jade a kiss gotta wake up labor day to this the fuck bein' richshamed by some prick usin' my name for clickbait in a state of bliss 'cause i said his goddamn name now i gotta cock back aim yeah bitch pop champagne to this pop it's your moment this is it as big as you're gonna get so enjoy it had to give you a career to destroy it lethal injection go to sleep six feet deep i'll give you a b for the effort but if i was threefooteleven you'd look up to me and for the record you would suck a dick to fuckin' be me for a second lick a ballsack to get on my channel give your life to be as solidified this mothafuckin' shit is like rambo when he's out of bullets so what good is a fuckin' machine gun when it's outta ammo had enough of this tattedup mumble rapper how the fuck can him and i battle he'll have to fuck kim in my flannel i'll give him my sandals 'cause he knows long as i'm shady he's gon' have to live in my shadow exhausting letting off on my offspring lick a gun barrel bitch get off me you dance around it like a sombrero we can all see you're fuckin' salty 'cause young gerald's ballsdeep inside of halsey your red sweater your black leather you dress better i rap better that a death threat or a love letter little white toothpick thinks it's over a pic i just don't like you prick thanks for dissing me now i had an excuse on the mic to write not alike but really i don't care who's in the right but you're losin' the fight you picked who else want it kellsattempt fails buddenl's fuckin' nails in these coffins as soft as cottonelle killshot i will not fail i'm with the doc still but this idiot's boss pops pills and tells him he's got skills but kells the day you put out a hit's the day diddy admits that he put the hit out that got pac killed ah i'm sick of you bein' wack and still usin' that mothafuckin' autotune so let's talk about it let's talk about it i'm sick of your mumble rap mouth need to get the cock up out it before we can even talk about it talk about it i'm sick of your blonde hair and earrings just 'cause you look in the mirror and think that you're marshall mathers marshall mathers don't mean you are and you're not about it so just leave my dick in your mouth and keep my daughter out it   you fuckin'oh and i'm just playin' diddy you know i love you	locale	\N
52	Godzilla	196	ugh you're a monster   eminem i can swallow a bottle of alcohol and i'll feel like godzilla better hit the deck like the card dealer my whole squad's in here walking around the party a cross between a zombie apocalypse and bbobby the brain heenan which is probably the same reason i wrestle with mania shady's in this bitch i'm posse'd up consider it to cross me a costly mistake if they sleepin' on me the hoes better get insomnia adhd hydroxycut pass the courvoisier hey hey in aa with an ak melee finna set it like a playdate better vacate retreat like a vacay mayday ayy this beat is craycray ray j hahaha laughing all the way to the bank i spray flames they cannot tame or placate the   juice wrld with eminem monster you get in my way i'ma feed you to the monster yeah i'm normal during the day but at night turn to a monster yeah when the moon shines like ice road truckers i look like a villain outta those blockbusters godzilla fire spitter monster blood on the dance floor and on the louis v carpet fire godzilla fire monster blood on the dance floor and on the louis v carpet   eminem i'm just a product of slick rick and onyx told 'em lick the balls had 'em just appalled did so many things that pissed 'em off it's impossible to list 'em all and in the midst of all this i'm in a mental hospital with a crystal ball tryna see will i still be like this tomorrow risperdal voices whisper my fist is balled back up against the wall pencil drawn this is just the song to go ballistic on you just pulled a pistol on a guy with a missile launcher i'm just a loch ness the mythological quick to tell a bitch screw off like a fifth of vodka when you twist the top of the bottle i'm a   juice wrld with eminem monster you get in my way i'ma feed you to the monster yeah i'm normal during the day but at night turn to a monster yeah when the moon shines like ice road truckers i look like a villain outta those blockbusters godzilla fire spitter monster blood on the dance floor and on the louis v carpet fire godzilla fire monster blood on the dance floor and on the louis v carpet   eminem if you never gave a damn ayy raise your hand 'cause i'm about to set trip vacation plans i'm on point like my index is so all you will ever get is the motherfuckin' finger finger prostate exam 'xam how can i have all these fans and perspire like a liar's pants i'm on fire and i got no plans to retire and i'm still the man you admire these chicks are spazzin' out i only get more handsome and flyer i got 'em passin' out like what you do when you hand someone flyers and what goes around comes around just like the blades on the chainsaw 'cause i caught the flack but my dollars stacked right off the bat like a baseball like kid ink bitch i got them racks with so much ease that they call me diddy 'cause i make bands and i call getting cheese a cakewalk cheesecake yeah bitch i'm a player i'm too motherfuckin' stingy for cher won't even lend you an ear ain't even pretending to care but i tell a bitch i'll marry her if she'll bury her face in my genital area the original richard ramirez cristhian rivera 'cause my lyrics never sit well so they wanna give me the chair like a paraplegic and it's scary call it hari kari 'cause e'ry tom and dick and harry carry a merriam motherfuckin' dictionary on 'em swearing up and down they can spit this shit's hilarious it's time to put these bitches in the obituary column we wouldn't see eye to eye with a staring problem get the shaft like a steering column monster trigger happy pack heat but it's black ink evil half of the bad meets evil that means take a back seat take it back to fat beats with a maxi single look at my rap sheet what attracts these people is my 'gangsta bitch' like apache with a catchy jingle i stack chips you barely got a halfeaten cheeto fill 'em with the venom and eliminate 'em other words i minute maid 'em i don't wanna hurt 'em but i did i'm in a fit of rage i'm murderin' again nobody will evade i'm finna kill 'em and dump all their fuckin' bodies in the lake obliterating everything incinerate a renegade i'm here to make anybody who want it with the pen afraid but don't nobody want it but they're gonna get it anyway 'cause i'm beginnin' to feel like i'm mentally ill i'm attila kill or be killed i'm a killer bee the vanilla gorilla you're bringin' the killer within me outta me you don't wanna be the enemy of the demon who entered me and be on the receivin' end of me what stupidity it'd be every bit of me's the epitome of a spitter when i'm in the vicinity motherfucker you better duck or you finna be dead the minute you run into me a hundred percent of you is a fifth of a percent of me i'm 'bout to fuckin' finish you bitch i'm unfadable you wanna battle i'm available i'm blowin' up like an inflatable i'm undebatable i'm unavoidable i'm unevadable i'm on the toilet bowl i got a trailer full of money and i'm paid in full i'm not afraid to pull a   eminem man stop look what i'm plannin' haha	locale	\N
45	WAP	227	cardi b al t mclaran  megan thee stallion whores in this house there's some whores in this house there's some whores in this house there's some whores in this house hol' up i said certified freak seven days a week wetass pussy make that pullout game weak woo ah   cardi b yeah yeah yeah yeah yeah you fuckin' with some wetass pussy bring a bucket and a mop for this wetass pussy give me everything you got for this wetass pussy   cardi b  megan thee stallion beat it up nigga catch a charge extra large and extra hard put this pussy right in your face swipe your nose like a credit card hop on top i wanna ride i do a kegel while it's inside spit in my mouth look in my eyes this pussy is wet come take a dive tie me up like i'm surprised let's roleplay i'll wear a disguise i want you to park that big mack truck right in this little garage make it cream make me scream out in public make a scene i don't cook i don't clean but let me tell you how i got this ring ayy ayy   megan thee stallion gobble me swallow me drip down the side of me yeah quick jump out 'fore you let it get inside of me yeah i tell him where to put it never tell him where i'm 'bout to be huh i'll run down on him 'fore i have a nigga runnin' me pow pow pow talk your shit bite your lip yeah ask for a car while you ride that dick while you ride that dick you really ain't never gotta fuck him for a thang yeah he already made his mind up 'fore he came ayy ah now get your boots and your coat for this wetass pussy ah ah ah he bought a phone just for pictures of this wetass pussy click click click paid my tuition just to kiss me on this wetass pussy mwah mwah mwah now make it rain if you wanna see some wetass pussy yeah yeah   cardi b  megan thee stallion look i need a hard hitter need a deep stroker need a henny drinker need a weed smoker not a garter snake i need a king cobra with a hook in it hope it lean over he got some money then that's where i'm headed pussy a just like his credit he got a beard well i'm tryna wet it i let him taste it now he diabetic i don't wanna spit i wanna gulp i wanna gag i wanna choke i want you to touch that lil' dangly thing that swing in the back of my throat my head game is fire punani dasani it's goin' in dry and it's comin' out soggy i ride on that thing like the cops is behind me yeah ah i spit on his mic and now he tryna sign me woo  4 megan thee stallion your honor i'm a freak bitch handcuffs leashes switch my wig make him feel like he cheatin' put him on his knees give him somethin' to believe in never lost a fight but i'm lookin' for a beatin' ah in the food chain i'm the one that eat ya if he ate my ass he's a bottomfeeder big d stand for big demeanor i could make ya bust before i ever meet ya if it don't hang then he can't bang you can't hurt my feelings but i like pain if he fuck me and ask whose is it when i ride the dick i'ma spell my name ah   cardi b yeah yeah yeah yeah you fuckin' with some wetass pussy bring a bucket and a mop for this wetass pussy give me everything you got for this wetass pussy now from the top make it drop that's some wetass pussy now get a bucket and a mop that's some wetass pussy i'm talkin' wap wap wap that's some wetass pussy macaroni in a pot that's some wetass pussy huh   al t mclaran there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house there's some whores in this house	locale	\N
46	Bodak Yellow	238	ksr it's cardi ayy said i'm the shit they can't fuck with me if they wanted to i don't gotta dance   said lil' bitch you can't fuck with me if you wanted to these expensive these is red bottoms these is bloody shoes hit the store i can get 'em both i don't wanna choose and i'm quick cut a nigga off so don't get comfortable look i don't dance now i make money moves ayy ayy say i don't gotta dance i make money move if i see you and i don't speak that means i don't fuck with you i'm a boss you a worker bitch i make bloody moves   now she say she gon' do what to who let's find out and see cardi b you know where i'm at you know where i be you in the club just to party i'm there i get paid a fee i be in and out them banks so much i know they're tired of me honestly don't give a fuck 'bout who ain't fond of me dropped two mixtapes in six months what bitch working as hard as me i don't bother with these hoes don't let these hoes bother me they see pictures they say goals bitch i'm who they tryna be look i might just chill in some bape i might just chill with your boo i might just feel on your babe my pussy feel like a lake he wanna swim with his face i'm like okay i'll let him get what he want he buy me yves saint laurent and the new whip when i go fast as a horse i got the trunk in the front vroom vroom i'm the hottest in the street know you prolly heard of me got a bag and fixed my teeth hope you hoes know it ain't cheap and i pay my mama bills i ain't got no time to chill think these hoes be mad at me their baby father run a bill   said lil' bitch you can't fuck with me if you wanted to these expensive these is red bottoms these is bloody shoes hit the store i can get 'em both i don't wanna choose and i'm quick cut a nigga off so don't get comfortable look i don't dance now i make money moves say i don't gotta dance i make money moves if i see you and i don't speak that means i don't fuck with you i'm a boss you a worker bitch i make bloody moves   if you a pussy you get popped you a goofy you a opp don't you come around my way you can't hang around my block and i just checked my accounts turns out i'm rich i'm rich i'm rich i put my hand above my hip i bet you dip he dip she dip i say i get the money and go this shit is hot like a stove my pussy glitter is gold tell that lil' bitch play her role i just arrive in a rolls i just came up in a wraith i need to fill up the tank no i need to fill up the safe i need to let all these hoes know that none of their niggas is safe i go to dinner and steak only the real can relate i used to live in the p's now it's a crib with a gate rollie got charms look like frosted flakes had to let these bitches know just in case these hoes forgot i just run and check the mail another check from mona scott   said lil' bitch you can't fuck with me if you wanted to these expensive these is red bottoms these is bloody shoes hit the store i can get 'em both i don't wanna choose and i'm quick cut a nigga off so don't get comfortable look i don't dance now i make money moves say i don't gotta dance i make money move if i see you and i don't speak that means i don't fuck with you i'm a boss you a worker bitch i make bloody moves	locale	\N
47	Bartier Cardi	214	cardi b   savage bardi in a 'rari diamonds all over my body 0 you a fool for this one shinin' all over my body bardi put that lil' bitch on molly bardi bitch on molly cheeze  diamonds all over my body fucked that bitch on molly ksr ask him if i'm 'bout it   cardi b   savage your bitch wanna party with cardi cartier bardi in a 'rari  diamonds all over my body cardi shinin' all over my body my body cardi got your bitch on molly bitch you ain't gang you lame bentley truck lane to lane blow out the brain  i go insane insane i drop a check on the chain fuck up a check in the flame cardi took your man you upset uh cardi got rich they upset yeah from what cardi put the pussy on offset say what cartier cardi b brain on offset  cardi took your man you upset uh cardi got rich they upset yeah  cardi put the pussy on offset cardi cartier cardi b brain on offset who's cardi   cardi b who get this motherfucker started cardi who took your bitch out to party cardi i took your bitch and departed cardi who that be fly as a martian cardi who that on fleek in the cut cardi who got the bricks in the truck cardi them diamonds gon' hit like a bitch on a bitchy ass bitch bitch you a wannabe cardi red bottom mj moonwalk on a bitch moonwalkin' through your clique i'm moonwalkin' in the 6 sticky with the kick moonrocks in this bitch i'm from the motherfuckin' bronx bronx i keep the pump in the trunk trunk bitch if you bad then jump jump might leave your bitch in a slump your back   cardi b   savage your bitch wanna party with cardi cartier bardi in a 'rari  diamonds all over my body cardi shinin' all over my body my body cardi got your bitch on molly bitch you ain't gang you lame bentley truck lane to lane blow out the brain  i go insane insane i drop a check on the chain fuck up a check in the flame cardi took your man you upset uh cardi got rich they upset yeah from what cardi put the pussy on offset say what cartier cardi b brain on offset  cardi took your man you upset uh cardi got rich they upset yeah  cardi put the pussy on offset cardi cartier cardi b brain on offset    savage your bitch wanna party with a savage  saint laurent savage in an aston yeah high end cars and fashion  i don't eat pussy i'm fastin' on god i'm a blood my brother crippin' bitch i'm drippin' ho you trippin' told the waitress i ain't tippin' i like hot sauce on my chicken on god i pulled the rubber off and i put hot sauce on her titties  i'm in a bentley truck she keep on suckin' like it's tinted  all these vvss nigga my sperm worth millions on god the bitch so bad i popped a molly 'fore i hit it     cardi b   savage your bitch wanna party with cardi cartier bardi in a 'rari  diamonds all over my body cardi shinin' all over my body my body cardi got your bitch on molly bitch you ain't gang you lame bentley truck lane to lane blow out the brain  i go insane insane i drop a check on the chain fuck up a check in the flame cardi took your man you upset uh cardi got rich they upset yeah from what cardi put the pussy on offset say what cartier cardi b brain on offset  cardi took your man you upset uh cardi got rich they upset yeah  cardi put the pussy on offset cardi cartier cardi b brain on offset who's cardi   cardi b step in this bitch in givenchy cash fuck up a check in givenchy cash boss out the coupe and them inches i fuck up a bag at the fendi i fuck up a bag in a minute who you know drip like this who you know built like this i'm poppin' shit like a dude pull up to pop at your crew brrrt poppin' at you woo they say you basic i flooded the rollie with diamonds i flooded the patek and bracelet i got your bitch and she naked ice on the cake when i bake it i'm switchin' lanes in the range swap out the dick for the brain swap out your bitch for your main swap out the trap for the fame ice on them cardi b cartier frames bitch   cardi b   savage your bitch wanna party with cardi cartier bardi in a 'rari  diamonds all over my body cardi shinin' all over my body my body cardi got your bitch on molly bitch you ain't gang you lame bentley truck lane to lane blow out the brain  i go insane insane i drop a check on the chain fuck up a check in the flame cardi took your man you upset uh cardi got rich they upset yeah from what cardi put the pussy on offset say what cartier cardi b brain on offset  cardi took your man you upset uh cardi got rich they upset yeah  cardi put the pussy on offset cardi cartier cardi b brain on offset who's cardi	locale	\N
48	Be Careful	247	yeah care for me care for me care for me uh yeah look   i wanna get married like the currys steph and ayesha shit but we more like bellytommy and keisha shit gave you tlc you wanna creep and shit poured out my whole heart to a piece of shit man i thought you would've learned your lesson 'bout likin' pictures not returnin' texts i guess it's fine man i get the message you still stutter after certain questions you keep in contact with certain exes do you though trust me nigga it's cool though said that you was workin' but you out here chasin' culo and putas chillin' poolside livin' two lives i could've did what you did to me to you a few times but if i did decide to slide find a nigga fuck him suck his dick you would've been pissed but that's not my mo i'm not that type of bitch and karma for you is gon' be who you end up with you make me sick nigga   the only man baby i adore i gave you everything what's mine is yours i want you to live your life of course but i hope you get what you dyin' for be careful with me do you know what you doin' whose feelings that you're hurtin' and bruisin' you gon' gain the whole world but is it worth the girl that you're losin' be careful with me yeah it's not a threat it's a warnin' be careful with me yeah my heart is like a package with a fragile label on it be careful with me   care for me care for me always said that you'd be there for me there for me boy you better treat me carefully carefully look   i was here before all of this guess you actin' out now you got an audience tell me where your mind is drop a pin what's the coordinates you might have a fortune but you lose me you still gon' be misfortunate nigga tell me this lust got you this fucked up in the head you want some random bitch up in your bed she don't even know your middle name watch her 'cause she might steal your chain you don't want someone who loves you instead i guess not though it's blatant disrespect you nothin' like the nigga i met talk to me crazy and you quick to forget you even got me trippin' you got me lookin' in the mirror different thinkin' i'm flawed because you inconsistent between a rock and a hard place the mud and the dirt it's gon' hurt me to hate you but lovin' you's worse it all stops so abrupt we started switchin' it up teach me to be like you so i can not give a fuck free to mess with someone else i wish these feelings could melt 'cause you don't care about a thing except your mothafuckin' self you make me sick nigga   the only man baby i adore i gave you everything what's mine is yours i want you to live your life of course but i hope you get what you dyin' for be careful with me do you know what you doin' whose feelings that you're hurtin' and bruisin' you gon' gain the whole world but is it worth the girl that you're losin' be careful with me yeah it's not a threat it's a warnin' be careful with me yeah my heart is like a package with a fragile label on it be careful with me	locale	\N
49	Money	179	look my bitches all bad my niggas all real i ride on his dick in some big tall heels big fat checks big large bills front i'll flip like ten cartwheels cold ass bitch i give broads chills ten different looks and my looks all kill i kiss him in the mouth i feel all grills he eat in the car that's meals on wheels woo   i was born to flex yes diamonds on my neck i like boardin' jets i like mornin' sex woo but nothing in this world that i like more than checks money all i really wanna see is the money i don't really need the d i need the money all a bad bitch need is the money flow i got bands in the coupe coupe bustin' out the roof i got bands in the coupe coupe touch me i'll shoot bow shake a lil ass money get a little bag and take it to the store store money get a little cash money shake it real fast and get a little more money i got bands in the coupe coupe bustin' out the roof i got bands in the coupe brrr bustin' out the roof cardi   i gotta fly i need a jet shit i need room for my legs i got a baby i need some money yeah i need cheese for my egg all y'all bitches in trouble bring brass knuckles to the scuffle i heard that cardi went pop yeah i did go pop pop that's me bustin' they bubble i'm dasani with the drip baby mommy with the clip walk out follie's with a bitch bring a thottie to the whip if she fine or she thick goddamn walkin' past the mirror ooh damn i'm fine fine let a bitch try me boom boom hammer time uh   i was born to flex yes diamonds on my neck i like boardin' jets i like mornin' sex woo but nothing in this world that i like more than checks money all i really wanna see is the money i don't really need the d i need the money all a bad bitch need is the money flow i got bands in the coupe coupe bustin' out the roof i got bands in the coupe coupe touch me i'll shoot bow shake a lil ass money get a little bag and take it to the store store money get a little cash money shake it real fast and get a little more money i got bands in the coupe coupe bustin' out the roof i got bands in the coupe brrr touch me i'll shoot bow   bitch i will pop on your pops your pops bitch i will pop on whoever brrr you know who pop the most shit who the people whose shit not together okay you'da bet cardi a freak freak all my pajamas is leather uh bitch i will black on your ass yeah wakanda forever sweet like a honey bun spit like a tommy gun rollie a one of one come get your mommy some cardi at the tiptop bitch kiss the ring and kick rocks sis mwah jump it down back it up ooh ayy make that nigga put down k i like my niggas dark like d'ussé he gonna eat this ass like soufflé   i was born to flex diamonds on my neck i like boardin' jets i like mornin' sex but nothing in this world that i like more than kulture kulture kulture kulture all i really wanna see is the money i don't really need the d i need the money all a bad bitch need is the kkc woo   money money money money money money money money	locale	\N
50	Rap God	240	look i was gonna go easy on you not to hurt your feelings but i'm only going to get this one chance six minutes six minutes something's wrong i can feel it six minutes slim shady you're on just a feeling i've got like something's about to happen but i don't know what  if that means what i think it means we're in trouble big trouble  and if he is as bananas as you say i'm not taking any chances you are just what the doc ordered   i'm beginnin' to feel like a rap god rap god all my people from the front to the back nod back nod now who thinks their arms are long enough to slap box slap box they said i rap like a robot so call me rapbot   but for me to rap like a computer it must be in my genes i got a laptop in my back pocket my pen'll go off when i halfcock it got a fat knot from that rap profit made a livin' and a killin' off it ever since bill clinton was still in office with monica lewinsky feelin' on his nutsack i'm an mc still as honest but as rude and as indecent as all hell syllables skillaholic kill 'em all with this flippity dippityhippity hiphop you don't really wanna get into a pissin' match with this rappity brat packin' a mac in the back of the ac' backpack rap crap yapyap yacketyyack and at the exact same time i attempt these lyrical acrobat stunts while i'm practicin' that i'll still be able to break a motherfuckin' table over the back of a couple of faggots and crack it in half only realized it was ironic i was signed to aftermath after the fact how could i not blow all i do is drop fbombs feel my wrath of attack rappers are havin' a rough time period here's a maxi pad it's actually disastrously bad for the wack while i'm masterfully constructing this masterpièce   'cause i'm beginnin' to feel like a rap god rap god all my people from the front to the back nod back nod now who thinks their arms are long enough to slap box slap box let me show you maintainin' this shit ain't that hard that hard everybody want the key and the secret to rap immortality like ι have got   well to be truthful the blueprint's simply rage and youthful exuberance everybody loves to root for a nuisance hit the earth like an asteroid did nothing but shoot for the moon since pew mcs get taken to school with this music 'cause i use it as a vehicle to bus the rhyme now i lead a new school full of students me i'm a product of rakim lakim shabazz pac nwa cube hey doc ren yella eazy thank you they got slim inspired enough to one day grow up blow up and be in a position to meet rundmc induct them into the motherfuckin' rock and roll hall of fame even though i'll walk in the church and burst in a ball of flames only hall of fame i'll be inducted in is the alcohol of fame on the wall of shame you fags think it's all a game 'til i walk a flock of flames off a plank and tell me what in the fuck are you thinkin' little gaylookin' boy so gay i can barely say it with a straight face lookin' boy haha you're witnessin' a massoccur like you're watching a church gathering take place lookin' boy oy vey that boy's gaythat's all they say lookin' boy you get a thumbs up pat on the back and a way to go from your label every day lookin' boy hey lookin' boy what you say lookin' boy i get a hell yeah from dre lookin' boy i'ma work for everything i have never asked nobody for shit get outta my face lookin' boy basically boy you're never gonna be capable of keepin' up with the same pace lookin' boy 'cause   i'm beginnin' to feel like a rap god rap god all my people from the front to the back nod back nod the way i'm racin' around the track call me nascar nascar dale earnhardt of the trailer park the white trash god kneel before general zod this planet's kryptonno asgard asgard   so you'll be thor and i'll be odin you rodent i'm omnipotent let off then i'm reloadin' immediately with these bombs i'm totin' and i should not be woken i'm the walkin' dead but i'm just a talkin' head a zombie floatin' but i got your mom deepthroatin' i'm out my ramen noodle we have nothin' in common poodle i'm a doberman pinch yourself in the arm and pay homage pupil it's me my honesty's brutal but it's honestly futile if i don't utilize what i do though for good at least once in a while so i wanna make sure somewhere in this chicken scratch i scribble and doodle enough rhymes to maybe try to help get some people through tough times but i gotta keep a few punchlines just in case 'cause even you unsigned rappers are hungry lookin' at me like it's lunchtime i know there was a time where once i was king of the underground but i still rap like i'm on my pharoahe monch grind so i crunch rhymes but sometimes when you combine appeal with the skin color of mine you get too big and here they come tryin' to censor you like that one line i said on i'm back from the mathers lp  when i tried to say i'll take seven kids from columbine put 'em all in a line add an ak47 a revolver and a 9 see if i get away with it now that i ain't as big as i was but i'm morphin' into an immortal comin' through the portal you're stuck in a time warp from 004 though and i don't know what the fuck that you rhyme for you're pointless as rapunzel with fuckin' cornrows you write normal fuck being normal and i just bought a new raygun from the future just to come and shoot ya like when fabolous made ray j mad 'cause fab said he looked like a fag at mayweather's pad singin' to a man while he played piano man oh man that was a 47 special on the cable channel so ray j went straight to the radio station the very next day hey fab i'ma kill you lyrics comin' at you at supersonic speed jj fad uh summalumma doomalumma you assumin' i'm a human what i gotta do to get it through to you i'm superhuman innovative and i'm made of rubber so that anything you say is ricochetin' off of me and it'll glue to you and i'm devastating more than ever demonstrating how to give a motherfuckin' audience a feeling like it's levitating never fading and i know the haters are forever waiting for the day that they can say i fell off they'll be celebrating 'cause i know the way to get 'em motivated i make elevating music you make elevator music oh he's too mainstream well that's what they do when they get jealous they confuse it it's not hiphop it's pop'cause i found a hella way to fuse it with rock shock rap with doc throw on lose yourself and make 'em lose it i don't know how to make songs like that i don't know what words to use let me know when it occurs to you while i'm rippin' any one of these verses that versus you it's curtains i'm inadvertently hurtin' you how many verses i gotta murder to prove that if you were half as nice your songs you could sacrifice virgins too ugh school flunky pill junkie but look at the accolades these skills brung me full of myself but still hungry i bully myself 'cause i make me do what i put my mind to and i'm a million leagues above you ill when i speak in tongues but it's still tongueincheek fuck you i'm drunk so satan take the fucking wheel i'ma sleep in the front seat bumpin' heavy d and the boyz still chunky but funky but in my head there's something i can feel tugging and struggling angels fight with devils and here's what they want from me they're askin' me to eliminate some of the women hate but if you take into consideration the bitter hatred i have then you may be a little patient and more sympathetic to the situation and understand the discrimination but fuck it life's handin' you lemons make lemonade then but if i can't batter the women how the fuck am i supposed to bake them a cake then don't mistake him for satan it's a fatal mistake if you think i need to be overseas and take a vacation to trip a broad and make her fall on her face and don't be a retardbe a king think not why be a king when you can be a god	locale	\N
59	Chun-Li	221	ayo look like i'm goin' for a swim dunked on 'em now i'm swingin' off the rim bitch ain't comin' off the bench while i'm comin' off the court fully drenched here go some haterade get ya thirst quenched styled on 'em in this burberry trench these birds copy every word every inch but gang gang got the hammer and the wrench brrr i pull up in that quarter milli off the lot oh now she tryna be friends like i forgot show off my diamonds like i'm signed by the roc by the rock ain't pushin' out his babies 'til he buy the rock   ayo i been on bitch you been corn bentley tints on fendi prints on i mean i been storm xmen been formed he keep on dialin' nicki like the prince song iii been on bitch you been corn bentley tints on fendi prints on ayo i been north lara been croft plates say chunli drop the benz off  interlude  oh i get it huh they paintin' me out to be the bad guy well it's the last time you gonna see a bad guy do the rap game like me   i went and copped the chopsticks put it in my bun just to pop shit i'm always in the top shit box seats bitch fuck the gossip how many of them coulda did it with finesse now everybody like she really is the best you play checkers couldn't beat me playin' chess now i'm about to turn around and beat my chest bitch it's king kong yes it's king kong bitch it's king kong this is king kong chinese ink on siamese links on call me  chainz name go ding dong bitch it's king kong yes i'm king kong this is king kong yes miss king kong in my kingdom wit' my timbs on how many championships what six rings on  interlude  they need rappers like me they need rappers like me so they can get on their fucking keyboards and make me the bad guy chunli   ayo i been on bitch you been corn bentley tints on fendi prints on i mean i been storm xmen been formed he keep on dialin' nicki like the prince song iii been on bitch you been corn bentley tints on fendi prints on ayo i been north lara been croft plates say chunli drop the benz off   i come alive i i'm always sky high designer thigh highs it's my lifestyle i come alive i i'm always sky high designer thigh highs it's my lifestyle i need a mai tai so fuckin' scifi give me the password to the fuckin' wifi	locale	\N
60	Attention	165	woahoh hmhmm   you've been runnin' 'round runnin' 'round runnin' 'round throwin' that dirt all on my name 'cause you knew that i knew that i knew that i'd call you up you've been going 'round going 'round going 'round every party in la 'cause you knew that i knew that i knew that i'd be at one oh  pre i know that dress is karma perfume regret you got me thinking 'bout when you were mine ooh and now i'm all up on ya what you expect but you're not coming home with me tonight   you just want attention you don't want my heart maybe you just hate the thought of me with someone new yeah you just want attention i knew from the start you're just making sure i'm never gettin' over you oh   you've been runnin' 'round runnin' 'round runnin' 'round throwin' that dirt all on my name 'cause you knew that i knew that i knew that i'd call you up baby now that we're now that we're now that we're right here standin' face to face you already know 'ready know 'ready know that you won oh  pre i know that dress is karma dress is karma perfume regret yeah you got me thinking 'bout when you were mine ooh you got me thinking 'bout when you were mine and now i'm all up on ya all up on ya what you expect oh baby but you're not coming home with me tonight oh no   you just want attention you don't want my heart maybe you just hate the thought of me with someone new one new yeah you just want attention oh i knew from the start the start you're just making sure i'm never gettin' over you over you oh   what are you doin' to me what are you doin' huh what are you doin' what are you doin' to me what are you doin' huh what are you doin' what are you doin' to me what are you doin' huh what are you doin' what are you doin' to me what are you doin' huh  pre i know that dress is karma perfume regret you got me thinking 'bout when you were mine and now i'm all up on ya what you expect but you're not coming home with me tonight   you just want attention you don't want my heart maybe you just hate the thought of me with someone new yeah you just want attention i knew from the start you're just making sure i'm never gettin' over you over you   what are you doin' to me hey what are you doin' huh what are you doin' love what are you doin' to me what are you doin' huh yeah you just want attention what are you doin' to me i knew from the start what are you doin' huh you're just making sure i'm never gettin' over you what are you doin' to me what are you doin' huh	locale	\N
61	We Don’t Talk Anymore	220	charlie puth we don't talk anymore we don't talk anymore we don't talk anymore like we used to do we don't love anymore what was all of it for oh we don't talk anymore like we used to do   charlie puth i just heard you found the one you've been looking you've been looking for i wish i would have known that wasn't me 'cause even after all this time i still wonder why i can't move on just the way you did so easily  pre charlie puth don't wanna know what kind of dress you're wearing tonight if he's holdin' onto you so tight the way i did before i overdosed should've known your love was a game now i can't get you out of my brain oh it's such a shame   charlie puth that we don't talk anymore we don't talk anymore we don't talk anymore like we used to do we don't love anymore what was all of it for oh we don't talk anymore like we used to do   selena gomez i just hope you're lying next to somebody who knows how to love you like me there must be a good reason that you're gone every now and then i think you might want me to come show up at your door but i'm just too afraid that i'll be wrong  pre selena gomez don't wanna know if you're lookin' into her eyes if she's holdin' onto you so tight the way i did before i overdosed should've known your love was a game now i can't get you out of my brain oh it's such a shame   charlie puth  selena gomez that we don't talk anymore we don't talk anymore we don't talk anymore like we used to do we don't love anymore what was all of it for oh we don't talk anymore like we used to do like we used to do  pre  charlie puth  selena gomez don't wanna know what kind of dress you're wearing tonight if he's giving it to you just right the way i did before i overdosed should've known your love was a game now i can't get you out of my brain oh it's such a shame   charlie puth  selena gomez that we don't talk anymore we don't talk anymore we don't talk anymore like we used to do we don't love anymore what was all of it for oh we don't talk anymore like we used to do   charlie puth  selena gomez both we don't talk anymore oh oh don't wanna know what kind of dress you're wearing tonight if he's holding onto you so tight the way i did before we don't talk anymore oh whoa should've known your love was a game now i can't get you out of my brain oh it's such a shame that we don't talk anymore	locale	\N
62	How Long	241	alright ooh yeah   i'll admit i was wrong what else can i say girl can't you blame my head and not my heart i was drunk i was gone that don't make it right but promise there were no feelings involved mmh  pre she said boy tell me honestly was it real or just for show yeah she said save your apologies baby i just gotta know   how long has this been goin' on you've been creepin' 'round on me while you're callin' me baby how long has this been goin' on you've been actin' so shady shady i've been feelin' it lately baby  post ooooh yeah ooooh encore ooohoohoh   i'll admit it's my fault but you gotta believe me when i say it only happened once mmm i try and i try but you'll never see that you're the only one i wanna love oh yeah  pre she said boy tell me honestly was it real or just for show yeah she said save your apologies baby i just gotta know   how long has this been goin' on you've been creepin' 'round on me while you're callin' me baby how long has this been goin' on you've been actin' so shady i've been feelin' it lately baby  post ooooh yeah ooooh encore ooohoohoh how long has it been goin' on baby ooooh yeah ooooh you gotta go tell me now ooohoohoh  pre she said boy tell me honestly was it real or just for show yeah she said save your apologies baby i just gotta know   how long has this been goin' on and you' been creepin' 'round on me while you're callin' me baby how long has this been goin' on you've been actin' so shady i've been feelin' it lately baby  post ooooh yeah how long has this been goin' on ooh encore you've been creepin' 'round on me ooohoohoh how long has it been goin' on baby oh ooooh how long has this been goin' on ooh encore you gotta go tell me now ooohoohoh you've been actin' so shady i've been feelin' it lately baby	locale	\N
63	Marvin Gaye	214	charlie puth let's marvin gaye and get it on you got the healing that i want just like they say it in the song until the dawn let's marvin gaye and get it on   charlie puth we got this kingsize to ourselves don't have to share with no one else don't keep your secrets to yourself it's kama sutra show and tell yeah  pre charlie puth whoaohohoh there's lovin' in your eyes that pulls me closer oh it pulls me closer it's so subtle it's so subtle i'm in trouble i'm in trouble but i'd love to be in trouble with you   charlie puth with meghan trainor let's marvin gaye and get it on you got the healin' that i want just like they say it in the song until the dawn let's marvin gaye and get it on you've got to give it up to me i'm screaming mercy mercy please just like they say it in the song until the dawn let's marvin gaye and get it on   meghan trainor and when you leave me all alone i'm like a stray without a home i'm like a dog without a bone i just want you for my own i got to have you babe  pre  charlie puth  meghan trainor whoaohohoh there's lovin' in your eyes that pulls me closer oh it pulls me closer it's so subtle it's so subtle i'm in trouble i'm in trouble but i'd rather be in trouble with you   charlie puth with meghan trainor let's marvin gaye and get it on ooh baby got that healing that you want yes like they say it in the songs until the dawn let's marvin gaye and get it on   charlie puth  meghan trainor let's marvin gaye and get it on you got the healin' that i want just like they say it in the song until the dawn let's marvin gaye and get it on babe you've got to give it up to me i'm screaming mercy mercy please just like they say it in the song until the dawn let's marvin gaye and get it on just like they say it in the song until the dawn let's marvin gaye and get it on ooh	locale	\N
64	One Call Away	166	i'm only one call away i'll be there to save the day superman got nothing on me i'm only one call away   call me baby if you need a friend i just wanna give you love c'mon c'mon c'mon reaching out to you so take a chance  pre no matter where you go you know you're not alone   i'm only one call away i'll be there to save the day superman got nothing on me i'm only one call away   come along with me and don't be scared i just wanna set you free c'mon c'mon c'mon you and me can make it anywhere but for now we could stay here for a while hey 'cause you know i just wanna see you smile  pre no matter where you go you know you're not alone   i'm only one call away i'll be there to save the day superman got nothing on me i'm only one call away   and when you're weak i'll be strong i'm gonna keep holding on now don't you worry it won't be long darling and when you feel like hope is gone just run into my arms   i'm only one call away i'll be there to save the day superman got nothing on me i'm only one i'm only one call away i'll be there to save the day superman got nothing on me i'm only one call away   i'm only one call away	locale	\N
65	Love Yourself	210	produced by benny blanco   for all the times that you rained on my parade and all the clubs you get in using my name you think you broke my heart oh girl for goodness sake you think i'm cryin' on my own well i ain't  refrain and i didn't wanna write a song 'cause i didn't want anyone thinking i still care i don't but you still hit my phone up and baby i'll be movin' on and i think you should be somethin' i don't wanna hold back maybe you should know that  pre my mama don't like you and she likes everyone and i never like to admit that i was wrong and i've been so caught up in my job didn't see what's going on but now i know i'm better sleeping on my own   'cause if you like the way you look that much oh baby you should go and love yourself and if you think that i'm still holdin' on to somethin' you should go and love yourself   but when you told me that you hated my friends the only problem was with you and not them and every time you told me my opinion was wrong and tried to make me forget where i came from  refrain and i didn't wanna write a song 'cause i didn't want anyone thinking i still care i don't but you still hit my phone up and baby i'll be movin' on and i think you should be somethin' i don't wanna hold back maybe you should know that  pre my mama don't like you and she likes everyone and i never like to admit that i was wrong and i've been so caught up in my job didn't see what's going on but now i know i'm better sleeping on my own   'cause if you like the way you look that much oh baby you should go and love yourself and if you think that i'm still holdin' on to somethin' you should go and love yourself   for all the times that you made me feel small i fell in love now i feel nothin' at all i never felt so low and i was vulnerable was i a fool to let you break down my walls   'cause if you like the way you look that much oh baby you should go and love yourself and if you think that i'm still holdin' on to somethin' you should go and love yourself 'cause if you like the way you look that much oh baby you should go and love yourself and if you think that i'm still holdin' on to somethin' you should go and love yourself	locale	\N
66	Sorry	185	written by julia michaels justin tranter and justin bieber   you gotta go and get angry at all of my honesty you know i try but i don't do too well with apologies i hope i don't run out of time could someone call a referee 'cause i just need one more shot at forgiveness i know you know that i made those mistakes maybe once or twice by once or twice i mean maybe a couple a hundred times so let me oh let me redeem oh redeem oh myself tonight 'cause i just need one more shot at second chances  pre yeah is it too late now to say sorry 'cause i'm missing more than just your body oh is it too late now to say sorry yeah i know that i let you down is it too late to say i'm sorry now   i'm sorry yeah sorry yeah sorry yeah i know that i let you down is it too late to say i'm sorry now   i'll take every single piece of the blame if you want me to but you know that there is no innocent one in this game for two i'll go i'll go and then you go you go out and spill the truth can we both say the words and forget this  pre yeah is it too late now to say sorry 'cause i'm missing more than just your body oh is it too late now to say sorry yeah i know that i let you down is it too late to say i'm sorry now   i'm not just trying to get you back on me oh no no 'cause i'm missing more than just your body your body oh is it too late now to say sorry yeah i know that i let you down is it too late to say i'm sorry now   i'm sorry yeah sorry oh sorry yeah i know that i let you down is it too late to say i'm sorry now i'm sorry yeah sorry oh sorry yeah i know that i let you down is it too late to say i'm sorry now	locale	\N
67	Yummy	223	yeah you got that yummyyum that yummyyum that yummyyummy yeah you got that yummyyum that yummyyum that yummyyummy say the word on my way yeah babe yeah babe yeah babe any night any day say the word on my way yeah babe yeah babe yeah babe in the mornin' or the late say the word on my way   bona fide stallion ain't in no stable no you stay on the run ain't on the side you're number one yeah every time i come around you get it done  pre fiftyfifty love the way you split it hundred racks help me spend it babe light a match get litty babe that jet set watch the sunset kinda yeah yeah rollin' eyes back in my head make my toes curl yeah yeah   yeah you got that yummyyum that yummyyum that yummyyummy yeah you got that yummyyum that yummyyum that yummyyummy say the word on my way yeah babe yeah babe yeah babe any night any day say the word on my way yeah babe yeah babe yeah babe in the mornin' or the late say the word on my way   standin' up keep me on the rise lost control of myself i'm compromised you're incriminating no disguise and you ain't never runnin' low on supplies  pre fiftyfifty love the way you split it hundred racks help me spend it babe light a match get litty babe that jet set watch the sunset kinda yeah yeah rollin' eyes back in my head make my toes curl yeah yeah   yeah you got that yummyyum that yummyyum that yummyyummy you stay flexin' on me yeah you got that yummyyum yeah yeah that yummyyum that yummyyummy say the word on my way yeah babe yeah babe yeah babe yeah babe any night any day say the word on my way yeah babe yeah babe yeah babe yeah babe in the mornin' or the late say the word on my way   hop in the lambo' i'm on my way drew house slippers on with a smile on my face i'm elated that you are my lady you got the yum yum yum yum you got the yum yumyum woah woahooh   yeah you got that yummyyum that yummyyum that yummyyummy yeah you got that yummyyum that yummyyum that yummyyummy say the word on my way yeah babe yeah babe yeah babe yeah babe any night any day say the word on my way yeah babe yeah babe yeah babe yeah babe in the mornin' or the late say the word on my way	locale	\N
68	As Long as You Love Me	223	justin bieber as long as you love me love me love me love me love me love me love me as long as you love me love me love me love me love me as long as you love me   justin bieber we're under pressure we're under pressure seven billion people in the world tryna fit in tryna fit in keep it together keep it together smile on your face even though your heart is frowning frowning but hey now hey now you know girl you know girl we both know it's a cruel world cruel world but i will but i will take my chances   justin bieber as long as you love me we could be starving we could be homeless we could be broke as long as you love me i'll be your platinum i'll be your silver i'll be your gold as long as you love me love me as long as you love me love me   justin bieber i'll be your soldier i'll be your soldier fighting every second of the day for your dreams girl for your dreams girl i'll be your hova i'll be your hova you could be my destiny's child on the scene girl so don't stress don't stress and don't cry and don't cry oh we don't need no wings to fly wings to fly just take take my hand   justin bieber as long as you love me we could be starving we could be homeless we could be broke as long as you love me i'll be your platinum i'll be your silver i'll be your gold as long as you love me love me as long as you love me love me   big sean whoa whoa big i don't know if this makes sense but you're my hallelujah give me a time and place i'll rendezvous it i'll fly you to it i'll beat you there girl you know i got you us trust a couple things i can't spell without 'u' now we on top of the world world 'cause that's just how we do used to tell me sky's the limit now the sky's our point of view man we stepping out like whoa oh god cameras point and shoot shoot ask me what's my best side i stand back and point at you you you the one that i argue with feel like i need a new girl to be bothered with but the grass ain't always greener on the other side it's green where you water it so i know we got issues baby true true true but i'd rather work on this with you than to go ahead and start with someone new as long as you love me   justin bieber as long as you love me yeah yeah baby we could be starving we could be homeless we could be broke as long as you love me i'll be your platinum platinum i'll be your silver i'll be your gold   justin bieber as long as you love me as long as you love me as long as you love me i'll be your silver i'll be your gold as long as you love me you love me you love me yeah it's all i want baby as long as you love me you love me please don't go as long as you love me as long as you love me as long as you love me yeah as long as you love me love me love me love me love me	locale	\N
69	Baby	228	produced by thedream and tricky stewart   justin bieber oh woah oh woah oh woah   justin bieber you know you love me i know you care just shout whenever and ill be there you want my love you want my heart and we will never ever ever be apart are we an item girl quit playing were just friends what are you saying said there's another and looked right in my eyes my first love broke my heart for the first time and i was like   justin bieber baby baby baby oh like baby baby baby no like baby baby baby no oh thought you'd always be mine mine baby baby baby oh like baby baby baby no like baby baby baby no oh thought youd always be mine mine   justin bieber oh for you i would have done whatever and i just cant believe we ain't together and i wanna play it cool but i'm losing you i'll buy you anything i'll buy you any ring and i'm in pieces baby fix me and just shake me 'til you wake me from this bad dream i'm going down down down down and i just cant believe my first love wont be around and i'm like   justin bieber baby baby baby oh like baby baby baby no like baby baby baby no oh thought youd always be mine mine baby baby baby oh like baby baby baby no like baby baby baby no oh thought youd always be mine mine   ludacris luda when i was  i had my first love there was nobody that compared to my baby and nobody came between us nor could ever come above she had me going crazy oh i was starstruck she woke me up daily dont need no starbucks she made my heart pound and skip a beat when i see her in the street and at school on the playground but i really want to see her on the weekend she knows she's got me dazing cause she was so amazing and now my heart is breaking but i just keep on saying   justin bieber baby baby baby oh like baby baby baby no like baby baby baby no oh thought youd always be mine mine baby baby baby oh like baby baby baby no like baby baby baby no oh thought youd always be mine mine   justin bieber i'm gone yeah yeah yeah now i'm all gone yeah yeah yeah now i'm all gone yeah yeah yeah now i'm all gone gone gone gone i'm gone	locale	\N
70	​​rockstar	198	post malone hahahahaha tank god ayy ayy   post malone i've been fuckin' hoes and poppin' pillies man i feel just like a rockstar star ayy ayy all my brothers got that gas and they always be smokin' like a rasta 'sta fuckin' with me call up on a uzi and show up man them the shottas 'tas when my homies pull up on your block they make that thing go grrratatata ta pow pow pow ayy ayy   post malone switch my whip came back in black i'm startin' sayin' rest in peace to bon scott scott ayy close that door we blowin' smoke she ask me light a fire like i'm morrison 'son ayy act a fool on stage prolly leave my fuckin' show in a cop car car ayy shit was legendary threw a tv out the window of the montage cocaine on the table liquor pourin' don't give a damn dude your girlfriend is a groupie she just tryna get in sayin' i'm with the band ayy ayy now she actin' outta pocket tryna grab up on my pants hundred bitches in my trailer say they ain't got a man and they all brought a friend yeah ayy ayy ayy   post malone i've been fuckin' hoes and poppin' pillies man i feel just like a rockstar star ayy ayy all my brothers got that gas and they always be smokin' like a rasta 'sta fuckin' with me call up on a uzi and show up man them the shottas 'tas when my homies pull up on your block they make that thing go grrratatata ta pow pow pow    savage i've been in the hills fuckin' superstars feelin' like a popstar    drankin' henny bad bitches jumpin' in the pool and they ain't got on no bra bra hit her from the back pullin' on her tracks and now she screamin' out no más yeah yeah yeah they like savage why you got a  car garage and you only got six cars  i ain't with the cakin' how you kiss that kiss that your wifey say i'm lookin' like a whole snack big snack green hundreds in my safe i got old racks old racks la bitches always askin' where the coke at   livin' like a rockstar smash out on a cop car sweeter than a poptart you know you are not hard i done made the hot chart 'member i used to trap hard livin' like a rockstar i'm livin' like a rockstar ayy   post malone   savage i've been fuckin' hoes and poppin' pillies man i feel just like a rockstar star ayy ayy all my brothers got that gas and they always be smokin' like a rasta 'sta yeah yeah yeah yeah fuckin' with me call up on a uzi and show up man them the shottas 'tas when my homies pull up on your block they make that thing go grrratatata ta grrratatatata   post malone star star rockstar rockstar star rockstar rockstar feel just like a rock rockstar rockstar rockstar feel just like a	locale	\N
71	White Iverson	204	double ot i'm a new three   saucin' saucin' i'm saucin' on you i'm swaggin' i'm swaggin' i'm swaggin' ohooh swaggin' i'm ballin' i'm ballin' iverson on you swish ooh ayy watch out watch out watch out yeah that's my shot that's my shot that's my shot yeah spendin' i'm spendin' all my fuckin' pay   i got me some braids and i got me some hoes started rockin' the sleeve i can't ball with no joes you know how i do it concords on my toes this shit is hard ooh i ain't rich yet but you know i ain't broke i i ain't broke i so if i see it i like it buy that from the store i that from the store i i'm with some white girls and they lovin' the coca coca like they ot double ot like i'm kd smokin' og smokin' og and you know me in my s and my gold teeth and my gold teeth bitch i'm smiling bet you see me from the nosebleeds nosebleeds i'm a new three and i change out to my new s to my new s  pre white iverson when i started ballin' i was young you gon' think about me when i'm gone i need that money like the ring i never won i won   saucin' saucin' i'm saucin' on you i'm swaggin' i'm swaggin' i'm swaggin' ohooh i'm ballin' i'm ballin' iverson on you on you on you watch out watch out watch out yeah that's my shot that's my shot that's my shot yeah spendin' i'm spendin' all my fuckin' pay   ooh stoney cigarettes and a headband commas commas in my head man slumped over like a dead man red and black 'bout my bread man i'm the answer never question lace up learn a lesson bitch i'm saucin' wow i do this often don't do no talkin' no my options right when i walk in jump all them jordans ooh i'm ballin' money jumpin' like i'm davis from new orleans or bitch i'm harden i don't miss nothin' fuck practice this shit just happens know y'all can't stand it ayy i have it i never pass it i work my magic high average ball on these bastards it makes me happy it's tragic i make it happen and all y'all shaqtin'  pre white iverson when i started ballin' i was young you gon' think about me when i'm gone i need that money like the ring i never won i won   saucin' saucin' i'm saucin' on you i'm swaggin' i'm swaggin' i'm swaggin' ohooh i'm ballin' i'm ballin' iverson on you watch out watch out watch out yeah that's my shot that's my shot that's my shot yeah spendin' i'm spendin' all my fuckin' pay   oohooh oohooh oohooh oohooh	locale	\N
72	Congratulations	230	post malone mmmmm yeah yeah mmmmm yeah hey   post malone my momma called seen you on tv son said shit done changed ever since we was on i dreamed it all ever since i was young they said i wouldn't be nothing now they always say congratulations uh uh uh worked so hard forgot how to vacation uhhuh they ain't never had the dedication uh uh people hatin' say we changed and look we made it uh uh yeah we made it uh uh uh   post malone they was never friendly yeah now i'm jumping out the bentley yeah and i know i sound dramatic yeah but i know i had to have it yeah for the money i'm a savage yeah i be itching like a addict yeah i'm surrounded twenty bad bitches yeah but they didn't know me last year yeah everyone wanna act like they important yeahyeahyeah yeahyeahyeah but all that mean nothing when i saw my dough yuh yeahyeahyeah yeahyeahyeah everyone countin' on me drop the ball yuh yeahyeahyeah yeahyeahyeah everything custom like i'm at the border yeah yeah if you fuck with winning put your lighters to the sky how could i make cents when i got millions on my mind coming with that bullshit i just put it to the side balling since a baby they could see it in my eyes   post malone  quavo my momma called seen you on tv son said shit done changed ever since we was on i dreamed it all ever since i was young they said i wouldn't be nothing now they always say congratulations congratulations worked so hard forgot how to vacation ooh they ain't never had the dedication uh uh ayy people hatin' say we changed and look we made it uh uh yeah we made it uh uh uh yeah   quavo i was patient yeah oh i was patient ayy ooh now i can scream that we made it we made it now everywhere everywhere i go they say 'gratulation ooh young nigga young nigga graduation yeah i pick up the rock and i ball baby ball i'm looking for someone to call baby brr but right now i got a situation ayy never old benben franklins cash big rings ooh champagne champagne my life is like a ball game ball game but instead i'm in the trap though trap though pot so big call it super bowl super bowl super bowl call the hoes brr get in the rolls skrrt topfloor lifestyle top huncho and post yeah ayy malone ayy i gotta play on my phone ayy you know what i'm on ayy huncho houdini is gone ayy   post malone  quavo my momma called seen you on tv son said shit done changed ever since we was on i dreamed it all ever since i was young they said i wouldn't be nothing now they always say congratulations ayy uh uh uh worked so hard forgot how to vacation uhhuh ooh they ain't never had the dedication ayy uh uh people hatin' say we changed and look we made it yeah  uh uh yeah we made it ayy   hey hey hey hey hey hey hey hey	locale	\N
73	Psycho	182	post malone damn my ap goin' psycho lil' mama bad like michael can't really trust nobody with all this jewelry on you my roof look like a noshow got diamonds by the boatload come with the tony romo for clowns and all the bozos my ap goin' psycho lil' mama bad like michael can't really trust nobody with all this jewelry on you my roof look like a noshow got diamonds by the boatload don't act like you my friend when i'm rollin' through my ends though   post malone you stuck in the friend zone i tell that fourfive the fifth ayy hunnid bands inside my shorts dechino the shit ayy try to stuff it all in but it don't even fit ayy know that i been with the shits ever since a jit ayy i made my first million i'm like shit this is it ayy 0 for a walkthrough man we had that bitch lit ayy had so many bottles gave ugly girl a sip out the window of the benzo we get seen in the rent' and i'm like woah man my neck so goddamn cold diamonds wet my tshirt soaked i got homies let it go oh my money thick won't ever fold she said can i have some to hold and i can't ever tell you no   post malone damn my ap goin' psycho lil' mama bad like michael can't really trust nobody with all this jewelry on you my roof look like a noshow got diamonds by the boatload come with the tony romo for clowns and all the bozos my ap goin' psycho lil' mama bad like michael can't really trust nobody with all this jewelry on you my roof look like a noshow got diamonds by the boatload don't act like you my friend when i'm rollin' through my ends though   ty dolla ign the ap goin' psycho my rollie goin' brazy i'm hittin' lil' mama she wanna have my babies it's fifty on the pinky chain so stanky you should see the whip promise i can take yo' bitch dolla ridin' in an old school chevy it's a drop top boolin' with a thotthot she gon' give me toptop just one switch i can make the ass drop hey ayy take you to the smoke shop we gon' get high ayy we gon' hit rodeo dial up valentino we gon' hit pico take you where i'm from take you to the slums this ain't happen overnight no these diamonds real bright saint laurent jeans still in my vans though all vvs' put you in a necklace girl you look beautiful tonight stars on the roof they matching with the jewelry   post malone damn my ap goin' psycho lil' mama bad like michael can't really trust nobody with all this jewelry on you my roof look like a noshow got diamonds by the boatload come with the tony romo for clowns and all the bozos my ap goin' psycho lil' mama bad like michael can't really trust nobody with all this jewelry on you my roof look like a noshow got diamonds by the boatload don't act like you my friend when i'm rollin' through my ends though	locale	\N
74	I Fall Apart	207	ooh i fall apart ooh yeah mmm yeah   she told me that i'm not enough yeah and she left me with a broken heart yeah she fooled me twice and it's all my fault yeah she cut too deep now she left me scarred yeah now there's so many thoughts goin' through my brain yeah and now i'm takin' these shots like it's novocaine yeah   ooh i fall apart down to my core ooh i fall apart down to my core ooh didn't know it before surprised when you caught me off guard all this damn jewelry i bought you was my shorty i thought   never caught a feelin' this hard harder than the liquor i pour tell me you don't want me no more but i can't let go everybody told me so feelin' like i sold my soul devil in the form of a whore devil in the form of a whore you said it no you said it no you said that shit we'd be together oh   ooh i fall apart down to my core ooh i fall apart down to my core ooh didn't know it before surprised when you caught me off guard all this damn jewelry i bought you was my shorty i thought   ice keep pourin' and the drink keep flowin' try to brush it off but it keep on goin' covered in scars and i can't help showin' whippin' in the foreign and the tears keep rollin' ice keep droppin' and the drink keep flowin' try to brush it off but it keep on goin' all these scars can't help from showin' whippin' in the foreign and the tears keep blowin' yeah   ooh i fall apart down to my core ooh i fall apart down to my core ooh didn't know it before surprised when you caught me off guard all this damn jewelry i bought you was my shorty i thought	locale	\N
\.


--
-- Data for Name: participe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.participe (musiqueid, artid) FROM stdin;
0	23
1	23
2	23
3	23
4	23
5	25
6	25
7	25
8	25
9	25
10	29
11	29
12	29
13	29
14	29
15	30
16	30
17	30
18	30
19	30
20	31
21	31
22	31
23	31
24	31
25	32
26	32
27	32
28	32
29	32
30	33
31	33
32	33
33	33
34	33
35	34
36	34
37	34
38	34
39	34
40	36
41	36
42	36
43	36
44	36
45	38
46	38
47	38
48	38
49	38
50	39
51	39
52	39
53	39
54	39
55	40
56	40
57	40
58	40
59	40
60	41
61	41
62	41
63	41
64	41
65	42
66	42
67	42
68	42
69	42
70	43
71	43
72	43
73	43
74	43
\.


--
-- Data for Name: periode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.periode (dateid, datearrive, datedepart) FROM stdin;
1	2018-02-20	\N
2	2018-05-17	\N
3	2012-04-02	\N
\.


--
-- Data for Name: playlist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.playlist (playid, titre, description, estpublique) FROM stdin;
4	My playlist	Ma playlist preferee\r\n        	t
5	jazz	musique jazz\r\n        	t
\.


--
-- Data for Name: suivregroupe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suivregroupe (pseudonyme, groupeid) FROM stdin;
user	1
user	2
user	3
\.


--
-- Data for Name: suivreutilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suivreutilisateur (userp, usersuivipar) FROM stdin;
vinesh	user
mario	user
\.


--
-- Data for Name: utilisateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilisateur (pseudonyme, email, dateinscription, motdepasse, profilepicture) FROM stdin;
user	user@mail.com	2023-12-17	$2b$12$XQ4mw6nuqj.Gp8jUHGs7iuy7qDghPEhjIxcBAKmAqfMuEpKUouXFO    	\N
vinesh	vinesh@mail.com	2023-12-23	$2b$12$azSSPwzcU275W6i5GYAAsukcqWmGpWmExT4b6sDxbP0JY9c/j595.    	\N
mario	mario@mail.com	2023-12-23	$2b$12$VWevh0q5DvqPcVD7XP20QO6Kv42bTxcrhZlGlsESNoK1gSA8LY1O.    	\N
\.


--
-- Name: album_albumid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.album_albumid_seq', 2, true);


--
-- Name: artiste_artid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.artiste_artid_seq', 43, true);


--
-- Name: groupe_groupeid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groupe_groupeid_seq', 2, true);


--
-- Name: morceau_musiqueid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.morceau_musiqueid_seq', 16, true);


--
-- Name: periode_dateid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.periode_dateid_seq', 2, true);


--
-- Name: playlist_playid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.playlist_playid_seq', 5, true);


--
-- Name: album album_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.album
    ADD CONSTRAINT album_pkey PRIMARY KEY (albumid);


--
-- Name: artiste artiste_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.artiste
    ADD CONSTRAINT artiste_pkey PRIMARY KEY (artid);


--
-- Name: creeralbum creeralbum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creeralbum
    ADD CONSTRAINT creeralbum_pkey PRIMARY KEY (groupeid, albumid, musiqueid);


--
-- Name: creerplaylist creerplaylist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creerplaylist
    ADD CONSTRAINT creerplaylist_pkey PRIMARY KEY (pseudonyme, playid);


--
-- Name: ecoute ecoute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ecoute
    ADD CONSTRAINT ecoute_pkey PRIMARY KEY (pseudonyme, musiqueid);


--
-- Name: estconstitue estconstitue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estconstitue
    ADD CONSTRAINT estconstitue_pkey PRIMARY KEY (playid, musiqueid);


--
-- Name: groupe groupe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groupe
    ADD CONSTRAINT groupe_pkey PRIMARY KEY (groupeid);


--
-- Name: joue joue_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joue
    ADD CONSTRAINT joue_pkey PRIMARY KEY (musiqueid, groupeid);


--
-- Name: jouelerole jouelerole_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jouelerole
    ADD CONSTRAINT jouelerole_pkey PRIMARY KEY (artid, groupeid, dateid);


--
-- Name: morceau morceau_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.morceau
    ADD CONSTRAINT morceau_pkey PRIMARY KEY (musiqueid);


--
-- Name: participe participe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participe
    ADD CONSTRAINT participe_pkey PRIMARY KEY (musiqueid, artid);


--
-- Name: periode periode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.periode
    ADD CONSTRAINT periode_pkey PRIMARY KEY (dateid);


--
-- Name: playlist playlist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.playlist
    ADD CONSTRAINT playlist_pkey PRIMARY KEY (playid);


--
-- Name: suivregroupe suivregroupe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suivregroupe
    ADD CONSTRAINT suivregroupe_pkey PRIMARY KEY (pseudonyme, groupeid);


--
-- Name: suivreutilisateur suivreutilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suivreutilisateur
    ADD CONSTRAINT suivreutilisateur_pkey PRIMARY KEY (userp, usersuivipar);


--
-- Name: utilisateur utilisateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilisateur
    ADD CONSTRAINT utilisateur_pkey PRIMARY KEY (pseudonyme);


--
-- Name: creeralbum creeralbum_albumid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creeralbum
    ADD CONSTRAINT creeralbum_albumid_fkey FOREIGN KEY (albumid) REFERENCES public.album(albumid) ON DELETE CASCADE;


--
-- Name: creeralbum creeralbum_groupeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creeralbum
    ADD CONSTRAINT creeralbum_groupeid_fkey FOREIGN KEY (groupeid) REFERENCES public.groupe(groupeid) ON DELETE CASCADE;


--
-- Name: creeralbum creeralbum_musiqueid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creeralbum
    ADD CONSTRAINT creeralbum_musiqueid_fkey FOREIGN KEY (musiqueid) REFERENCES public.morceau(musiqueid) ON DELETE CASCADE;


--
-- Name: creerplaylist creerplaylist_playid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creerplaylist
    ADD CONSTRAINT creerplaylist_playid_fkey FOREIGN KEY (playid) REFERENCES public.playlist(playid) ON DELETE CASCADE;


--
-- Name: creerplaylist creerplaylist_pseudonyme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.creerplaylist
    ADD CONSTRAINT creerplaylist_pseudonyme_fkey FOREIGN KEY (pseudonyme) REFERENCES public.utilisateur(pseudonyme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ecoute ecoute_musiqueid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ecoute
    ADD CONSTRAINT ecoute_musiqueid_fkey FOREIGN KEY (musiqueid) REFERENCES public.morceau(musiqueid) ON DELETE CASCADE;


--
-- Name: ecoute ecoute_pseudonyme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ecoute
    ADD CONSTRAINT ecoute_pseudonyme_fkey FOREIGN KEY (pseudonyme) REFERENCES public.utilisateur(pseudonyme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: estconstitue estconstitue_musiqueid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estconstitue
    ADD CONSTRAINT estconstitue_musiqueid_fkey FOREIGN KEY (musiqueid) REFERENCES public.morceau(musiqueid) ON DELETE CASCADE;


--
-- Name: estconstitue estconstitue_playid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estconstitue
    ADD CONSTRAINT estconstitue_playid_fkey FOREIGN KEY (playid) REFERENCES public.playlist(playid) ON DELETE CASCADE;


--
-- Name: joue joue_groupeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joue
    ADD CONSTRAINT joue_groupeid_fkey FOREIGN KEY (groupeid) REFERENCES public.groupe(groupeid) ON DELETE CASCADE;


--
-- Name: joue joue_musiqueid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.joue
    ADD CONSTRAINT joue_musiqueid_fkey FOREIGN KEY (musiqueid) REFERENCES public.morceau(musiqueid) ON DELETE CASCADE;


--
-- Name: jouelerole jouelerole_artid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jouelerole
    ADD CONSTRAINT jouelerole_artid_fkey FOREIGN KEY (artid) REFERENCES public.artiste(artid) ON DELETE CASCADE;


--
-- Name: jouelerole jouelerole_dateid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jouelerole
    ADD CONSTRAINT jouelerole_dateid_fkey FOREIGN KEY (dateid) REFERENCES public.periode(dateid) ON DELETE CASCADE;


--
-- Name: jouelerole jouelerole_groupeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jouelerole
    ADD CONSTRAINT jouelerole_groupeid_fkey FOREIGN KEY (groupeid) REFERENCES public.groupe(groupeid) ON DELETE CASCADE;


--
-- Name: participe participe_artid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participe
    ADD CONSTRAINT participe_artid_fkey FOREIGN KEY (artid) REFERENCES public.artiste(artid) ON DELETE CASCADE;


--
-- Name: participe participe_musiqueid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.participe
    ADD CONSTRAINT participe_musiqueid_fkey FOREIGN KEY (musiqueid) REFERENCES public.morceau(musiqueid) ON DELETE CASCADE;


--
-- Name: suivregroupe suivregroupe_groupeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suivregroupe
    ADD CONSTRAINT suivregroupe_groupeid_fkey FOREIGN KEY (groupeid) REFERENCES public.groupe(groupeid) ON DELETE CASCADE;


--
-- Name: suivregroupe suivregroupe_pseudonyme_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suivregroupe
    ADD CONSTRAINT suivregroupe_pseudonyme_fkey FOREIGN KEY (pseudonyme) REFERENCES public.utilisateur(pseudonyme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: suivreutilisateur suivreutilisateur_user1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suivreutilisateur
    ADD CONSTRAINT suivreutilisateur_user1_fkey FOREIGN KEY (userp) REFERENCES public.utilisateur(pseudonyme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: suivreutilisateur suivreutilisateur_usersuivipar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suivreutilisateur
    ADD CONSTRAINT suivreutilisateur_usersuivipar_fkey FOREIGN KEY (usersuivipar) REFERENCES public.utilisateur(pseudonyme) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

