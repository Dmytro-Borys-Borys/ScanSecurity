import qrcode
import pyqrcode
import argparse
import subprocess
import re
import tempfile
from PIL import Image, ImageDraw, ImageFont
from escpos.printer import Usb

def generate_wifi_qrcode(username, password, server, wifi):

    # Create the WiFi network URI
    wifi_uri = f"http://{server}:2050/?username={username}&password={password}"
    print(wifi_uri)

    # Generate the QR code
    qr_code = pyqrcode.create(wifi_uri)

    # Save the QR code as a PNG file
    with tempfile.NamedTemporaryFile(suffix=".png") as temp_file:
        qr_code.png(temp_file.name, scale=5)
        temp_file.seek(0)

        # Open the PNG file using Pillow
        with Image.open(temp_file.name) as img:
            # Get the dimensions of the image
            qr_code_width, qr_code_height = img.size

            # Print the dimensions
            print(f"QR code dimensions: {qr_code_width} pixels (width) x {qr_code_height} pixels (height)")

        
        # Print the QR code using the USB printer
        print_qr_code_file(temp_file.name, username, password, wifi)

def print_qr_code_file(file_path, username, password, wifi):
    # Create a blank canvas with a border
    canvas_width = 580
    canvas_height = 370
    border_width = 3
    canvas = Image.new('RGB', (canvas_width, canvas_height), color='white')
    draw = ImageDraw.Draw(canvas)

    # Draw the border
    border_position = [(border_width, border_width), (canvas_width - border_width, canvas_height - border_width)]
    draw.rectangle(border_position, outline='black', width=border_width)

    # Specify font and size for the text
    header_font_path = 'fonts/Roboto-BlackItalic.ttf'  # Replace with the actual path to the header font file
    label_font_path = 'fonts/Roboto-Medium.ttf'
    monospace_font_path = 'fonts/Ra-Mono.otf'  # Replace with the actual path to the monospace font file

    header_font_size = 50
    header_font = ImageFont.truetype(header_font_path, header_font_size)

    label_font_size = 40
    label_font = ImageFont.truetype(label_font_path, label_font_size)

    monospace_font_size = 36
    monospace_font = ImageFont.truetype(monospace_font_path, monospace_font_size)

    # Position and print the WiFi name on top, centered
    wifi_text = wifi
    wifi_text_width, wifi_text_height = draw.textsize(wifi_text, font=header_font)
    wifi_text_position = ((canvas_width - wifi_text_width) // 2, 15)
    draw.text(wifi_text_position, wifi_text, font=header_font, fill='black')

    # Load and position the QR code image
    qr_code_img = Image.open(file_path)
    # qr_code_img = qr_code_img.resize((285, 285))  # Resize to 285x285 pixels
    qr_code_position = (15, 75)
    canvas.paste(qr_code_img, qr_code_position)

    # Position and print the username and password
    label_position = (315, 120)
    draw.text(label_position, "User:", font=label_font, fill='black')
    draw.text((label_position[0], label_position[1] + label_font_size*3), "Password:", font=label_font, fill='black')

    monospace_text_position = (label_position[0], label_position[1] + label_font_size*1.2)
    draw.text(monospace_text_position, username, font=monospace_font, fill='black')
    draw.text((monospace_text_position[0], monospace_text_position[1] + label_font_size*3), password, font=monospace_font, fill='black')

    # Print the resulting image
    with tempfile.NamedTemporaryFile(suffix=".png") as temp_file:
        canvas.save(temp_file.name)
        vendor_id, product_id = find_usb_printer()

        if vendor_id and product_id:
            printer = Usb(vendor_id, product_id)
            printer.image(temp_file.name)
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
    parser.add_argument("server", help="Server for WiFi connection")
    parser.add_argument("wifi", help="SSID for WiFi connection")
    args = parser.parse_args()

    # Generate the WiFi QR code and print it
    generate_wifi_qrcode(args.username, args.password, args.server, args.wifi)
