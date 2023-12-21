import psycopg2
import psycopg2.extras

def connect():
  conn = psycopg2.connect(
    dbname = 'thewave',
    host = 'localhost',
    user = "postgres",
<<<<<<< HEAD
    password = "mybdduniv",
=======
>>>>>>> 79a1732a0f513065454cb1107b01d767b5c6e02f
    cursor_factory = psycopg2.extras.NamedTupleCursor
  )
  conn.autocommit = True
  return conn


