"""Module for creating and managing a PostgreSQL database."""

import os

import psycopg2

postgres_host = os.getenv("POSTGRES_HOST")
postgres_port = os.getenv("POSTGRES_PORT")
db_name = os.getenv("DB_NAME")
db_user = os.getenv("DB_USER")
db_password = os.getenv("POSTGRES_PASSWORD")
postgres_admin_user = os.getenv("POSTGRES_ADMIN_USER")
postgres_admin_password = os.getenv("POSTGRES_ADMIN_PASSWORD")
sslmode = os.getenv("POSTGRES_SSLMODE")

CHECK_IF_DB_EXISTS = (
    f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{db_name}';"
)
CREATE_DB = f"CREATE DATABASE {db_name};"
CHECK_IF_USER_EXISTS = f"SELECT 1 FROM pg_catalog.pg_roles WHERE rolname = '{db_user}';"
CREATE_USER = f"CREATE USER {db_user} PASSWORD '{db_password}';"
GRANT_PERMISSIONS = f"GRANT ALL PRIVILEGES ON DATABASE {db_name} TO {db_user};"
GRANT_OWNERSHIP = f"ALTER DATABASE {db_name} OWNER TO {db_user};"

conn = psycopg2.connect(
    database="postgres",
    user=postgres_admin_user,
    password=postgres_admin_password,
    host=postgres_host,
    port=postgres_port,
    sslmode=sslmode,
)

conn.autocommit = True
cursor = conn.cursor()


cursor.execute(CHECK_IF_DB_EXISTS)
exists = cursor.fetchone()
if not exists:
    print("db doesn't exist, creating ...")
    cursor.execute(CREATE_DB)
    print("db created ...")

cursor.execute(CHECK_IF_USER_EXISTS)
exists = cursor.fetchone()
if not exists:
    print("user doesn't exist, creating ...")
    cursor.execute(CREATE_USER)
    print("user created ...")

cursor.execute(GRANT_PERMISSIONS)
cursor.execute(GRANT_OWNERSHIP)
print("permissions were configured")

cursor.close()
conn.close()
