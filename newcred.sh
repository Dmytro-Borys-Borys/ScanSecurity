#!/bin/sh

DATABASE_FILE="/home/dima/proyecto/freeradius.db"
DEFAULT_LOGIN_LEN=8
DEFAULT_PASSWORD_LEN=10

# Generate a random 8-character login
login=$(cat /dev/urandom | tr -dc 'a-z' | fold -w $DEFAULT_LOGIN_LEN | head -n 1)

# Generate a random 10-character password
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $DEFAULT_PASSWORD_LEN | head -n 1)

sqlite_sql() {
	echo $(sqlite3 "$DATABASE_FILE" "$1")
}



# Check if username is already taken.
matches=$(sqlite_sql "SELECT COUNT(*) FROM radcheck WHERE username='$username';")
if [ $matches -gt 0 ]; then
    echo "Username $login already taken."
    exit 1
else
    echo "Username $login is available."
fi

# Now calculate the NTLM-hash of the given password.
hash=$(smbencrypt "$password" 2> /dev/null | cut -f 2)

echo "$login $password $hash"

# Now insert the user into the database.
sqlite_sql "INSERT INTO radcheck (username,attribute,op,value) VALUES ('$login','NT-Password',':=','$hash');"

python3 qrcode.py $login $password