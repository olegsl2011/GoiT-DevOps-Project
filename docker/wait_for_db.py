import os
import time
import psycopg2

host = os.getenv("POSTGRES_HOST", "db")
port = int(os.getenv("POSTGRES_PORT", "5432"))
dbname = os.getenv("POSTGRES_DB", "devops_db")
user = os.getenv("POSTGRES_USER", "devops_user")
password = os.getenv("POSTGRES_PASSWORD", "devops_pass")

timeout = int(os.getenv("DB_WAIT_TIMEOUT", "60"))
start = time.time()

while True:
    try:
        conn = psycopg2.connect(
            host=host, port=port, dbname=dbname, user=user, password=password
        )
        conn.close()
        print("Postgres is ready")
        break
    except Exception as e:
        if time.time() - start > timeout:
            print("Timed out waiting for Postgres")
            raise
        print("Waiting for Postgres...", e)
        time.sleep(1)
