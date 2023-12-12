import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    dbname = 'vinesh.rengassamy_db',
    host = 'sqletud.u-pem.fr',
    password = 'masterhk',
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn


