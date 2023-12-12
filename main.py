from flask import Flask, render_template, request, redirect, url_for, session, Blueprint
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


@app.route("/connection")
def connection() :
    return render_template("connection.html")

@app.route("/inscription")
def connection() :
    return render_template("inscription.html")




@app.route("/verifie_mdp", methods = ["POST"])
def check_passwd() :
    pseudonyme = request.form.get("pseudonyme", None)
    mdp = request.form.get("mdp", None)

    if pseudonyme == None or mdp == None :
        return "" # TODO : make redriction to connection page
    
    cur.execute("SELECT mdp FROM utilisateur WHERE pseudonyme = %s",(pseudonyme,))
    hashed = cur.fetchall()[0][0]

    if passwordctx.verify(mdp, hashed) :
        session["pseudonyme"] = pseudonyme
        return "" # TODO : make redriction to user dashboard
    else :
        return "" # TODO : make redriction to connection page



@app.route("/inscrire_user", methods = ["POST"])
def inscrire_user() :
    pseudonyme = request.form.get("pseudonyme", None)
    email = request.form.get("email", None)
    mdp = request.form.get("mdp", None)

    if pseudonyme ==  None or email == None or mdp == None :
        return ""# TODO : make redriction to inscription page
    

    hashed = passwordctx.hash(mdp)
    cur.execute("INSERT INTO utilisateur (email, pseudonyme, mdp) VALUES (%s, %s, %s)", (email, pseudonyme, hashed))

    return "" # TODO : make redriction to connection page


if __name__ == '__main__':
    app.run(debug=True)