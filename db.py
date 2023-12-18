import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    dbname = 'mario.lepage_db',
    host = 'sqletud.u-pem.fr',
    password = "09082003Ken",
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  kcjbddjhcbdhc
  conn.autocommit = True
  return conn


