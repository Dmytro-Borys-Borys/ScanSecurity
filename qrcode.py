import qrcode
import pyqrcode
import argparse
import subprocess
import re
import tempfile

from escpos.printer import Usb

def generate_wifi_qrcode(username, password):
    # WiFi network information
    ssid = "ScanSecurity"  # Replace with your WiFi SSID
    security = "WPA2-EAP"  # Replace with your WiFi security type (WPA, WEP, etc.)
    method = "PWD"
    method2 = "MSCHAPV2"

    # Create the WiFi network URI
    wifi_uri = f"WIFI:T:{security}S:{ssid};E:{method};PH2:{method2};A:anon;I:{username};P:{password};;"
    print(wifi_uri)

    # Generate the QR code
    qr_code = pyqrcode.create(wifi_uri)

    # Save the QR code as a PNG file
    with tempfile.NamedTemporaryFile(suffix=".png") as temp_file:
        qr_code.png(temp_file.name, scale=5)
        temp_file.seek(0)
        
        # Print the QR code using the USB printer
        print_qr_code_file(temp_file.name, username, password)

def print_qr_code_file(file_path, username, password):
    # Print the QR code and login/password using the USB printer
    vendor_id, product_id = find_usb_printer()

    if vendor_id and product_id:
        printer = Usb(vendor_id, product_id)
        printer.set(align='center')  # Set alignment to center
        printer.image(file_path)  # Print the QR code
        printer.text('\n')  # Move to the next line
        printer.text(f"Login: {username}\n")  # Print the login
        printer.text(f"Password: {password}\n")  # Print the password
        printer.cut()
    else:
        raise RuntimeError("Printer not found. Make sure it is connected.")


def find_usb_printer():
    # Run lsusb command to get USB device information
    lsusb_output = subprocess.check_output(['lsusb']).decode('utf-8')

    # Split the output into lines
    lines = lsusb_output.strip().split('\n')

    # Iterate over the lines and find the line containing the keyword "printer"
    for line in lines:
        print(line)
        if 'printer' in line.lower():
            # Extract the vendor ID and product ID
            vendor_product_ids = line.split('ID ')[1].split(':')
            vendor_id = int(vendor_product_ids[0], 16)
            product_id = int(vendor_product_ids[1].split(' ')[0], 16)
            return vendor_id, product_id

    # If no printer line is found, raise an exception
    raise Exception("USB printer not found")


if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Generate WiFi QR code")
    parser.add_argument("username", help="Username for WiFi connection")
    parser.add_argument("password", help="Password for WiFi connection")
    args = parser.parse_args()

    # Generate the WiFi QR code and print it
    generate_wifi_qrcode(args.username, args.password)
