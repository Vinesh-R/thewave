from flask import Flask, render_template, request, redirect, url_for, session, send_file
from passlib.context import CryptContext
import random

import db
from utils import listmanip


app = Flask(__name__)
app.secret_key = "oEd8i22KwNT77gocB3ckAEs7reHtGRCCU9ElAGzTNk"

dbConn = db.connect()
cur = dbConn.cursor()

passwordctx = CryptContext(schemes=['bcrypt'])


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
    return send_file("./static/asserts/poster.jpg")


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
    Musiques =listmanip.split_list(Musiques, 4)
    
    return render_template("userdashboard.html", musiques = Musiques)


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

    cur.execute("INSERT INTO Ecoute VALUES (%s, %s) ON CONFLICT DO NOTHING", (pseudonyme, mid)) #ajoute au historique
    
    return render_template("musique.html", titre = infos[1], photo = infos[2], id = infos[0])



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
                    nbecoute = nbecoutunique, nbpartage = nombrepartage, artistes = artistes, groupes = groupes)


    

if __name__ == '__main__':

    try :
        app.run(debug=True)
    except :
        print("error")
        cur.close()
        dbConn.close()

    cur.close()
    dbConn.close()