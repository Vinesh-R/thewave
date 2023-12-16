from flask import Flask, render_template, request, redirect, url_for, session
from passlib.context import CryptContext

import db


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
        return "<h1>Connection sucess</h1>" # TODO : make redriction to user dashboard
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

@app.route("/userdashboard")
def dashboard() :
    pseudonyme = request.form.get("pseudonyme", None)
    if pseudonyme == None :
        return redirect("/login")

    return ""


if __name__ == '__main__':

    try :
        app.run(debug=True)
    except :
        print("error")
        cur.close()
        dbConn.close()

    cur.close()
    dbConn.close()