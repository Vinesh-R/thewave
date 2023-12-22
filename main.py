from flask import Flask, render_template, request, redirect, url_for, session, send_file, jsonify
from passlib.context import CryptContext
import random
import psycopg2
import db
import utils


app = Flask(__name__)
app.secret_key = "oEd8i22KwNT77gocB3ckAEs7reHtGRCCU9ElAGzTNk"

dbConn = db.connect()
cur = dbConn.cursor()

passwordctx = CryptContext(schemes=['bcrypt'])

def format_duration(seconds):
    minutes, seconds = divmod(seconds, 60)
    return "{:02}:{:02}".format(int(minutes), int(seconds))


app.jinja_env.filters['format_duration'] = format_duration


@app.route("/")
def acceuille() :
    return render_template("accueil.html")


@app.route("/login")
def connection() :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme != None :
        return redirect("/userdashboard")
    
    return render_template("login.html")


@app.route("/signup")
def inscrire() :
    return render_template("signup.html")


@app.route("/verifie_mdp", methods = ["POST"])
def check_passwd() :
    pseudonyme = request.form.get("pseudonyme", None)
    mdp = request.form.get("password", None)

    if pseudonyme == None or mdp == None :
        return redirect("/login?error=1")
    
    cur.execute("SELECT motdepasse FROM utilisateur WHERE pseudonyme = %s",(pseudonyme,))
    hashed = cur.fetchall()[0][0]
    hashed = hashed.strip()

    if passwordctx.verify(mdp, hashed) :
        session["pseudonyme"] = pseudonyme
        return redirect("/userdashboard")
    else :
        return redirect("/login?error=1")


@app.route("/inscrire_user", methods = ["POST"])
def inscrire_user() :
    pseudonyme = request.form.get("pseudonyme", None)
    email = request.form.get("email", None)
    mdp = request.form.get("password", None)

    if pseudonyme ==  None or email == None or mdp == None :
        return redirect('/signup')
    
    hashed = passwordctx.hash(mdp)
    cur.execute("INSERT INTO utilisateur (email, pseudonyme, motdepasse) VALUES (%s, %s, %s)", (email, pseudonyme, hashed))

    return redirect("/login")


@app.route("/get_image/<categorie>/<nom>")
def envoie_image(categorie, nom) :

    if categorie == "musique" :
        return send_file("./static/asserts/music.jpg")
    elif categorie == "artiste" :
        return send_file("./static/asserts/artist.png")
    elif categorie == "album" : 
        return send_file("./static/asserts/album.jpg")
    elif categorie == "groupe" :
        return send_file("./static/asserts/groupe.png")
    elif categorie == "playlist" :
        return send_file("./static/asserts/playlist_poster.jpg")


@app.route("/userdashboard")
def dashboard() :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")
    
    cur.execute("""SELECT musiqueId, titre, photo FROM Morceau 
                NATURAL JOIN 
                (SELECT MusiqueId FROM Participe WHERE artId IN 
                    (SELECT DISTINCT Participe.artID FROM Ecoute NATURAL JOIN Participe
                    WHERE Ecoute.pseudonyme = %s)
                ) AS Ms
                 LIMIT 10""", (pseudonyme,))
    
    Musiques = cur.fetchall()

    if len(Musiques) == 0:
        cur.execute("SELECT musiqueId, titre, photo FROM Morceau LIMIT 10")
        Musiques = cur.fetchall()

    random.shuffle(Musiques)
    Musiques =utils.split_list(Musiques, 4)
    
    return render_template("userdashboard.html", musiques = Musiques, pseudonyme = pseudonyme)


@app.route("/morceau/<int:mid>")
def morceau(mid) :

    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT musiqueId, titre, photo FROM Morceau WHERE musiqueId = %s", (mid,))
    infos = cur.fetchall()

    if len(infos) == 0 :
        return redirect("/userdashboard")

    infos = infos[0]

    cur.execute("SELECT playid, titre FROM playlist NATURAL JOIN creerplaylist WHERE pseudonyme = %s", (pseudonyme,))
    playlists = cur.fetchall()

    cur.execute("SELECT playid FROM estconstitue WHERE musiqueid = %s", (mid,))
    isincluded = utils.tuple2list(cur.fetchall())

    cur.execute("INSERT INTO Ecoute VALUES (%s, %s) ON CONFLICT DO NOTHING", (pseudonyme, mid)) #ajoute au historique

    
    return render_template("musique.html", titre = infos[1], photo = infos[2], id = infos[0], 
                           pseudonyme = pseudonyme, playlists=playlists, isincluded=isincluded)



@app.route("/information_morceau/<int:mid>")
def info_musique(mid) :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")
    
    cur.execute("SELECT musiqueId, titre, duree, photo, parole FROM Morceau WHERE musiqueId = %s", (mid,))
    musiqueinfos = cur.fetchall()

    if len(musiqueinfos) == 0 :
        return redirect("/userdashboard")
    
    musiqueinfos = musiqueinfos[0]

    cur.execute("SELECT ecouteunique FROM nbecouteunique WHERE musiqueid = %s", (mid,))
    nbecoutunique = cur.fetchall()

    cur.execute("SELECT nombrepartages FROM nbpartageplay WHERE musiqueid = %s", (mid,))
    nombrepartage = cur.fetchall()

    if len(nbecoutunique) == 0 :
        nbecoutunique = 0
    else :
        nbecoutunique = nbecoutunique[0][0]

    if len(nombrepartage) == 0 :
        nombrepartage = 0
    else :
        nombrepartage = nombrepartage[0][0]
    
    cur.execute("select artid, nom ||' '|| prenom FROM artiste NATURAL JOIN participe WHERE musiqueid = %s", (mid,))
    artistes = cur.fetchall()

    cur.execute("select groupeid, nom FROM groupe NATURAL JOIN joue WHERE musiqueid = %s", (mid, ))
    groupes = cur.fetchall()

    return render_template("musique_information.html", id=musiqueinfos[0], titre = musiqueinfos[1], 
                    duree = musiqueinfos[2], photo = musiqueinfos[3], parole = musiqueinfos[4],
                    nbecoute = nbecoutunique, nbpartage = nombrepartage, artistes = artistes, groupes = groupes, 
                    pseudonyme = pseudonyme)


@app.route("/recherche")
def rechercher() :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")
    
    mot = request.args.get("mot", None)
    filtre = request.args.get("filtre", None)

    if mot == None :
        mot = ""
    else :
        mot = "%"+mot+"%"
    
    if filtre == None or filtre == "morceau" :
        cur.execute("SELECT musiqueId, titre, photo, duree FROM Morceau WHERE titre LIKE %s", (mot,))

    elif filtre == "artiste" :
        cur.execute("""SELECT artid, nom ||' '|| prenom, profilepicture FROM artiste 
                    WHERE nom LIKE %s OR prenom LIKE %s""", (mot, mot))
    
    elif filtre == "groupe" :
        cur.execute("SELECT groupeid, nom, profile FROM groupe WHERE nom LIKE %s", (mot,))
    
    elif filtre == "playlist" :
        cur.execute("SELECT playid, titre FROM playlist WHERE titre LIKE %s", (mot,))
    
    elif filtre == "album" :
        cur.execute("SELECT albumid, titre, photo FROM album WHERE titre LIKE %s", (mot,))

    result = cur.fetchall()

    return render_template("resultat.html", result=result, f = filtre, pseudonyme = pseudonyme)


@app.route("/album/<int:alid>")
def album(alid) :

    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")
    
    cur.execute("""SELECT album.titre, groupe.nom, groupe.groupeid description, dateparu, album.albumid
                FROM album 
                NATURAL JOIN creeralbum 
                NATURAL JOIN groupe WHERE album.albumid = %s;""", (alid,))
    
    infos = cur.fetchall()[0]
    
    cur.execute("""SELECT musiqueid, titre, duree 
                FROM morceau
                NATURAL JOIN creeralbum WHERE albumid = %s""", (alid,))
    
    musique = cur.fetchall()

    return render_template("album.html", infos = infos, musique = musique, pseudonyme = pseudonyme)



@app.route("/info_groupe/<int:gid>")
def info_groupe(gid) :

    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")

    cur.execute("""SELECT * FROM groupe WHERE groupeid = %s""", (gid,))
    infos = cur.fetchall()[0]
    genre = str(infos[4]).replace("[","").replace("]","").replace("'","")

    cur.execute("""SELECT artid, nom||' '||prenom, datearrive 
                FROM artiste 
                NATURAL JOIN jouelerole 
                NATURAL JOIN periode 
                WHERE groupeid = %s AND datedepart IS NULL;""", (gid,))
    artiste = cur.fetchall()

    cur.execute("""SELECT albumid, titre 
                    FROM album 
                    natural join creeralbum WHERE groupeid = %s;""", (gid,))
    album = cur.fetchall()

    cur.execute("""SELECT musiqueid, titre 
                        FROM morceau 
                        natural join joue WHERE groupeid = %s;""", (gid,))
    musique = cur.fetchall()

    cur.execute("""SELECT nom||' '||prenom, datearrive , datedepart
            FROM artiste 
            NATURAL JOIN jouelerole 
            NATURAL JOIN periode 
            WHERE groupeid = %s AND datedepart IS NOT NULL;""", (gid,))
    
    historique = cur.fetchall()

    cur.execute("SELECT * from suivregroupe WHERE groupeid = %s AND pseudonyme = %s", (gid, pseudonyme))
    if len(cur.fetchall()) == 0:
        url = "/suivre_groupe"
        wrd = "Follow"
    else :
        url = "/unfollow_groupe"
        wrd = "Unfollow"

    cur.execute("SELECT * from suivregroupe WHERE groupeid = %s", (gid,))
    nbsuivi = len(cur.fetchall())

    
    return render_template("groupe_profile.html", infos=infos, artiste=artiste, album=album, 
                           musique=musique, historique=historique, genre=genre, 
                           pseudonyme = pseudonyme, url = url, wrd = wrd, nbsuivi = nbsuivi)


@app.route("/suivre_groupe", methods = ["POST"])
def suivre_groupe() :
    pseudonyme = session.get("pseudonyme", None)
    gid = request.form.get("groupeid", None)

    if pseudonyme == None :
        return redirect(f"/info_groupe/{gid}")

    cur.execute("INSERT INTO suivregroupe VALUES (%s, %s) ON CONFLICT DO NOTHING", (pseudonyme, gid))

    return redirect(f"/info_groupe/{gid}")


@app.route("/unfollow_groupe", methods = ["POST"])
def unfollow_groupe() :
    pseudonyme = session.get("pseudonyme", None)
    gid = request.form.get("groupeid", None)

    if pseudonyme == None :
        return redirect(f"/info_groupe/{gid}")

    cur.execute("DELETE FROM suivregroupe WHERE pseudonyme = %s AND groupeid = %s", (pseudonyme, gid))

    return redirect(f"/info_groupe/{gid}")
    

@app.route("/verifie_mdp_new", methods = ["POST"])
def check_passwd_new() :
    mdp = request.form.get("password", None)
    user = session.get("pseudonyme", None)

    cur.execute("SELECT motdepasse FROM utilisateur WHERE pseudonyme = %s",(user,))
    hashed = cur.fetchall()[0][0]
    hashed = hashed.strip()

    if passwordctx.verify(mdp, hashed) :
        newmdp = request.form.get("new_password", None)
        newname = request.form.get("pseudonyme", None)
        newmail = request.form.get("email", None)
        if newmdp == "" or newmdp == None:
            cur.execute("UPDATE utilisateur SET pseudonyme = %s, email = %s WHERE pseudonyme = %s", (newname, newmail, user))
        else :
            hashed = passwordctx.hash(newmdp)
            cur.execute("UPDATE utilisateur SET motdepasse = %s, pseudonyme = %s, email = %s WHERE pseudonyme = %s", (hashed, newname, newmail, user))
    
        session["pseudonyme"] = newname
        return redirect("/userprofile")
    else :
        return redirect("/userprofile")

    
@app.route("/userprofile")
def profil() :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")
    
    cur.execute("SELECT pseudonyme, email, profilepicture, dateinscription FROM Utilisateur WHERE pseudonyme = %s", (pseudonyme,))
    infos = cur.fetchall()[0]

    return render_template("profileutilisateur.html",pseudonyme = pseudonyme, email = infos[1], pfp = infos[2], date = infos[3])


@app.route("/save_playlist/<int:mid>", methods = ["POST"])
def save_playlist(mid) :

    data = request.get_json()

    for playid, ischecked in data.items() :
        if ischecked :
            cur.execute("INSERT INTO estconstitue VALUES (%s, %s) ON CONFLICT DO NOTHING", (playid, mid))
        else :
            cur.execute("DELETE FROM estconstitue WHERE playid = %s AND musiqueid = %s", (playid, mid))

    return ""

@app.route("/deconnecter", methods =["GET"])
def deconnecter() :
    session.clear()
    return redirect("/login")


@app.route("/playlist")
def playlistpage() :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT * FROM creerplaylist natural join playlist WHERE pseudonyme = %s", (pseudonyme,))
    playlists = cur.fetchall()
    return render_template("creergerer_playlist.html", playlists=playlists, pseudonyme=pseudonyme)


@app.route('/delete_playlist', methods=['POST'])
def delete_playlist():
    try:
        data = request.get_json()
        playlist_id = data.get('playlistId')

        cur.execute('DELETE FROM playlist WHERE playid = %s', (playlist_id,))

        return jsonify({'success': True})

    except psycopg2.Error as e:
        print('Database error:', e)
        connection.rollback()
        return jsonify({'success': False, 'error': 'Database error'})

    except Exception as e:
        print('Error:', e)
        return jsonify({'success': False, 'error': 'An error occurred'})


@app.route("/creerplaylist", methods = ["POST"])
def playlist() :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")
    
    public = request.form.get("estpublique", None)

    if public == "prive" :
        public = False
    else :
        public = True

    description = request.form.get("description", None)
    titre = request.form.get("titre", None)
    if titre == None or description == None or public == None :
        return redirect("/userdashboard")

    cur.execute("INSERT INTO playlist(titre,description,estpublique) VALUES (%s, %s,%s)", (titre, description, public,))
    cur.execute("select playid from playlist where titre = %s", (titre,))
    playid = cur.fetchall()[0][0]
    cur.execute("INSERT INTO creerplaylist VALUES(%s, %s)", (pseudonyme, playid,))

    return redirect("/playlist")


@app.route("/gerer_playlist/<int:playid>")
def gerer_playlist(playid) :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT * FROM playlist WHERE playid = %s", (playid,))

    playlist = cur.fetchall()[0]

    cur.execute("SELECT musiqueid, titre FROM estconstitue NATURAL JOIN morceau WHERE playid = %s", (playid,))
    musiques = cur.fetchall()

    return render_template("gerer_playlist.html", infos=playlist, musiques=musiques, pseudonyme=pseudonyme)


@app.route("/modifier_playlist", methods = ["POST"])
def modifier_playlist() :
    playid = request.form.get("playid", None)
    titre = request.form.get("titre", None)
    estpublique = request.form.get("estpublique", None)
    desp = request.form.get("description", None)

    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")

    #verification si la playlist appartient au user
    cur.execute("SELECT playid FROM creerplaylist WHERE playid = %s AND pseudonyme = %s", (playid, pseudonyme))
    if len(cur.fetchall()) == 0 :
        return redirect("/userdashboard")

    if estpublique == "publique" :
        estpublique = True
    else :
        estpublique = False

    cur.execute("UPDATE playlist SET titre=%s, description=%s, estpublique=%s", (titre, desp, estpublique))

    return redirect(f"/gerer_playlist/{playid}")

@app.route("/show_playlist/<int:playid>")
def show_playlist(playid) :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")
    
    cur.execute("SELECT titre, description, estpublique FROM playlist WHERE playid = %s", (playid,))
    infos = cur.fetchall()[0]

    if not infos[2]  :
        return redirect("/userdashboard")


    cur.execute("SELECT pseudonyme FROM utilisateur NATURAL JOIN creerplaylist WHERE playid = %s",(playid,))
    user = cur.fetchall()[0][0]


    cur.execute("SELECT musiqueid, titre FROM morceau NATURAL JOIN estconstitue WHERE playid = %s", (playid,))
    musique = cur.fetchall()

    return render_template("show_playlist.html", infos=infos, musique=musique, pseudonyme=pseudonyme, user=user)


@app.route("/liste_suivi")
def liste_suivi() :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT userp FROM suivreutilisateur WHERE usersuivipar = %s", (pseudonyme, ))
    users = utils.tuple2list(cur.fetchall())

    cur.execute("SELECT groupeid, nom FROM groupe NATURAL JOIN suivregroupe WHERE pseudonyme = %s", (pseudonyme,))
    grps = cur.fetchall()
    print(grps, users)

    return render_template("liste_suivi.html", users = users, groupes = grps)


@app.route("/artiste/<int:artid>")
def info_artiste(artid) :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect(f"/login")

    cur.execute("SELECT * from artiste WHERE artid=%s", (artid,))
    infos = cur.fetchall()[0]

    cur.execute("SELECT musiqueid, titre from morceau NATURAL JOIN participe WHERE artid = %s", (artid,))
    morceaux = cur.fetchall()

    return render_template("artiste_profile.html", infos=infos, musique=morceaux)


@app.route("/explorer")
def explorer() :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT musiqueid, titre, photo FROM morceau LIMIT 10")
    musiques = cur.fetchall()
    random.shuffle(musiques)
    musiques =utils.split_list(musiques, 4)
    return render_template("explorer.html", musiques=musiques, pseudonyme=pseudonyme)


@app.route("/otheruser/<string:otheruser>")
def otheruser(otheruser) :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT pseudonyme, email, dateinscription, profilepicture FROM Utilisateur WHERE pseudonyme = %s", (otheruser,))
    infos = cur.fetchall()[0]

    cur.execute("select titre, count(musiqueid) from creerplaylist natural join playlist left join estconstitue on playlist.playid = estconstitue.playid  where pseudonyme = %s AND estpublique = %s group by titre", (otheruser,True))
    playlists = cur.fetchall()

    cur.execute("select usersuivipar from suivreutilisateur where userp = %s", (otheruser, ))
    suivipar = utils.tuple2list(cur.fetchall())
    nbsuivi = len(suivipar)

    if pseudonyme in suivipar :
        url = "/unfollow_user"
        wrd = "Unfollow"
    else :
        url = "/follow_user"
        wrd = "Follow"

    cur.execute("select ")
    return render_template("otheruser_profile.html", infos=infos, playlists=playlists, 
                           pseudonyme=pseudonyme, nbsuivi=nbsuivi,
                           url=url, wrd=wrd)


@app.route("/follow_user", methods=["POST"])
def follow_user() :
    pseudonyme = session.get("pseudonyme", None)
    otheruser = request.form.get("otheruser", None)
    cur.execute("INSERT INTO suivreutilisateur VALUES(%s, %s)", (otheruser, pseudonyme))
    return redirect(f"/otheruser/{otheruser}")

@app.route("/unfollow_user", methods=["POST"])
def unfollow_user() :
    pseudonyme = session.get("pseudonyme", None)
    otheruser = request.form.get("otheruser", None)
    cur.execute("DELETE FROM suivreutilisateur WHERE userp=%s AND usersuivipar=%s", (otheruser, pseudonyme))
    return redirect(f"/otheruser/{otheruser}")

@app.route("/historique")
def historique() :
    pseudonyme = session.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")

    cur.execute("SELECT musiqueid, titre, duree, photo FROM morceau NATURAL JOIN ecoute WHERE pseudonyme = %s", (pseudonyme,))
    musiques = cur.fetchall()
    return render_template("historique.html", musiques=musiques, pseudonyme=pseudonyme)

@app.route("/efface_historique", methods = ["POST"])
def efface_historique() :
    pseudonyme = session.get("pseudonyme", None)

    if pseudonyme == None :
        return redirect("/login")
    
    cur.execute("DELETE FROM ecoute WHERE pseudonyme = %s", (pseudonyme, ))

    return redirect("/historique")

if __name__ == '__main__':

    try :
        app.run(debug=True)
    except :
        cur.close()
        dbConn.close()
    finally :
        cur.close()
        dbConn.close()