#!/usr/bin/env python3

import pyrad
from pyrad.client import Client
from pyrad.dictionary import Dictionary
import random
import string

# Define the FreeRADIUS database parameters
radius_host = '127.0.0.1'
radius_port = 1812
radius_secret = b'$ecurity$can'
radius_dict = Dictionary("/usr/share/freeradius/dictionary.rfc2865")

# Generate a random username and password
def generate_credentials():
    username = ''.join(random.choices(string.ascii_lowercase, k=8))
    password = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
    return username, password

# Store the user in the FreeRADIUS SQLite database
def store_user(username, password):
    client = Client(server=radius_host, authport=radius_port, secret=radius_secret, dict=radius_dict)
    request = client.CreateCoAPacket()
    request['User-Name'] = username

    # Set the User-Password attribute manually
    request['User-Password'] = password

    client.SendPacket(request)

# Generate credentials and store the user
username, password = generate_credentials()
store_user(username, password)

# Print the generated username and password
print(f"Generated User: {username}")
print(f"Generated Password: {password}")