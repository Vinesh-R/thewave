import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    dbname = '',
    host = 'sqletud.u-pem.fr',
    password = '',
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn


