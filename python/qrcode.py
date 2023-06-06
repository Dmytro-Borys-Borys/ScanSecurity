import qrcode
import pyqrcode
import argparse
import subprocess
import re
import tempfile
from PIL import Image, ImageDraw, ImageFont
from escpos.printer import Usb


def resize_image(image, width, height):
    original_width, original_height = image.size

    # Calculate the new dimensions while maintaining the aspect ratio
    width_ratio = width / original_width
    height_ratio = height / original_height

    # Use the smaller scaling factor to ensure the image fits within the desired dimensions
    scaling_factor = min(width_ratio, height_ratio)

    # Calculate the new dimensions based on the scaling factor
    new_width = int(original_width * scaling_factor)
    new_height = int(original_height * scaling_factor)

    # Resize the image using the new dimensions
    resized_image = image.resize((new_width, new_height))

    return resized_image


def generate_wifi_qrcode():
    # Create the WiFi network URI
    wifi_uri = f"http://{args.ap_host}:2050/?u={args.username}&p={args.password}"
    print(wifi_uri)

    # Generate the QR code
    qr_code = pyqrcode.create(wifi_uri)

    # Save the QR code as a PNG file
    with tempfile.NamedTemporaryFile(suffix=".png") as temp_file:
        qr_code.png(temp_file.name, scale=5)
        temp_file.seek(0)

        # Print the QR code using the USB printer
        print_qr_code_file(temp_file.name)


def print_qr_code_file(file_path):
    ancho_maximo = 580
    alto_maximo = 750

    # Definir el contenido del ticket
    sistema_wifi = "Sistema de Acceso WiFi"
    usuario = "Usuario: "
    contrasena = "Password: "
    valido_hasta = "Válido hasta: "
    agradecimiento1 = "Gracias por su visita,"
    agradecimiento2 = "hasta pronto!"

    # Ajustar el tamaño de la fuente
    tamaño_header3 = 40
    tamaño_header4 = 32
    tamaño_parrafo = 24
    tamaño_negrita = 27

    # Crear una imagen en blanco para el ticket
    imagen_ticket = Image.new("RGB", (ancho_maximo, alto_maximo), color="white")
    draw = ImageDraw.Draw(imagen_ticket)

    # Cargar las fuentes
    fuente_header3 = ImageFont.truetype("fonts/Roboto-Black.ttf", tamaño_header3)
    fuente_header4 = ImageFont.truetype("fonts/Roboto-Black.ttf", tamaño_header4)
    fuente_parrafo = ImageFont.truetype("fonts/Roboto-Regular.ttf", tamaño_parrafo)
    fuente_negrita = ImageFont.truetype("fonts/Roboto-Black.ttf", tamaño_negrita)

    # Escribir los elementos en la imagen del ticket
    # Escribir los elementos en la imagen del ticket
    draw.text(
        (
            ((ancho_maximo - draw.textlength(sistema_wifi, font=fuente_header3)) // 2),
            0,
        ),
        sistema_wifi,
        font=fuente_header3,
        fill="black",
    )
    draw.text(
        (
            (
                (ancho_maximo - draw.textlength(args.business_name, font=fuente_header4))
                // 2
            ),
            90,
        ),
        args.business_name,
        font=fuente_header4,
        fill="black",
    )
    draw.text(
        (
            (
                (
                    ancho_maximo
                    - draw.textlength(args.business_address, font=fuente_parrafo)
                )
                // 2
            ),
            130,
        ),
        args.business_address,
        font=fuente_parrafo,
        fill="black",
    )

    # Cargar y ajustar la imagen del logo
    imagen_texto = Image.open(args.business_text)
    imagen_texto = resize_image(imagen_texto, 550, 80)

    imagen_ticket.paste(imagen_texto, ((ancho_maximo - imagen_texto.width) // 2, 180))

    # Load and position the QR code image
    qr_code_img = Image.open(file_path)
    qr_code_img = qr_code_img.resize((285, 285))  # Resize to 285x285 pixels

    # Calculate the center position of the QR code image on the canvas
    qr_code_x = (ancho_maximo - qr_code_img.width) // 2
    qr_code_y = 250

    qr_code_position = (qr_code_x, qr_code_y)
    imagen_ticket.paste(qr_code_img, qr_code_position)

    # Load the additional image
    additional_img = Image.open(args.business_logo)

    # Calculate the dimensions of the additional image
    additional_width, additional_height = additional_img.size

    additional_img = resize_image(additional_img, 80, 80)

    # Calculate the position to paste the additional image
    additional_position_x = (
        qr_code_x + qr_code_img.width // 2 - additional_img.width // 2
    )
    additional_position_y = (
        qr_code_y + qr_code_img.height // 2 - additional_img.height // 2
    )

    # Paste the additional image onto the canvas
    imagen_ticket.paste(
        additional_img,
        (additional_position_x, additional_position_y),
        mask=additional_img,
    )

    # Calculate the total width of key and value texts
    key_width = max(
        draw.textlength(usuario, font=fuente_negrita),
        draw.textlength(contrasena, font=fuente_negrita),
        draw.textlength(valido_hasta, font=fuente_negrita),
    )
    value_width = max(
        draw.textlength(args.username, font=fuente_parrafo),
        draw.textlength(args.password, font=fuente_parrafo),
        draw.textlength(args.password_expiry, font=fuente_parrafo),
    )

    # Calculate the center position
    center_position = ancho_maximo // 2

    # Calculate the positions for key and value texts
    key_position = center_position - key_width - 10
    value_position = center_position + 10

    # Place the key and value texts
    draw.text((key_position, 543), usuario, font=fuente_negrita, fill="black")
    draw.text((value_position, 543), args.username, font=fuente_parrafo, fill="black")

    draw.text((key_position, 588), contrasena, font=fuente_negrita, fill="black")
    draw.text((value_position, 588), args.password, font=fuente_parrafo, fill="black")

    draw.text((key_position, 633), valido_hasta, font=fuente_negrita, fill="black")
    draw.text(
        (value_position, 633), args.password_expiry, font=fuente_parrafo, fill="black"
    )

    draw.line([(0, 677), (ancho_maximo, 677)], fill="black", width=2)

    draw.text(
        (
            (ancho_maximo - draw.textlength(agradecimiento1, font=fuente_negrita))
            // 2,
            690,
        ),
        agradecimiento1,
        font=fuente_parrafo,
        fill="black",
    )
    draw.text(
        (
            (ancho_maximo - draw.textlength(agradecimiento2, font=fuente_negrita))
            // 2,
            720,
        ),
        agradecimiento2,
        font=fuente_parrafo,
        fill="black",
    )

    # Guardar la imagen del ticket en un archivo temporal
    with tempfile.NamedTemporaryFile(suffix=".png") as temp_file:
        imagen_ticket.save(temp_file.name)
        imagen_ticket.save("ticket.png")
        vendor_id, product_id = find_usb_printer()

        if vendor_id and product_id:
            grant_printer_permissions(vendor_id, product_id)
            printer = Usb(vendor_id, product_id)
            printer.image(temp_file.name)
            printer.cut()
        else:
            raise RuntimeError("Printer not found. Make sure it is connected.")
import os

def grant_printer_permissions(vendor_id, product_id):
    # Convert decimal values to hexadecimal and pad with leading zeros if necessary
    vendor_id_hex = hex(vendor_id)[2:].zfill(4)
    product_id_hex = hex(product_id)[2:].zfill(4)

    # Specify the content of the udev rule with hexadecimal values
    udev_rule_content = f'SUBSYSTEM=="usb", ATTRS{{idVendor}}=="{vendor_id_hex}", ATTRS{{idProduct}}=="{product_id_hex}", MODE="0666"'

    # Specify the path to the udev rules directory and file
    udev_rules_dir = "/etc/udev/rules.d"
    udev_rules_file = os.path.join(udev_rules_dir, "scansecurity_printer.rules")

    # Check if the udev rules file already exists
    if os.path.exists(udev_rules_file):
        print(f"The udev rules file {udev_rules_file} already exists.")
    else:
        # Write the udev rule content to a temporary file
        tmp_file_path = "/tmp/scansecurity_printer.rules"

        with open(tmp_file_path, "w") as tmp_file:
            tmp_file.write(udev_rule_content)

        # Use sudo to move the temporary file to the udev rules directory
        subprocess.run(["sudo", "mv", tmp_file_path, udev_rules_file])


        # Reload udevadm rules
        os.system("sudo udevadm control --reload-rules")
        print(f"The udev rules file {udev_rules_file} has been created and udevadm rules reloaded.")


def find_usb_printer():
    # Run lsusb command to get USB device information
    lsusb_output = subprocess.check_output(["lsusb"]).decode("utf-8")

    # Split the output into lines
    lines = lsusb_output.strip().split("\n")

    # Iterate over the lines and find the line containing the keyword "printer"
    for line in lines:
        print(line)
        if "printer" in line.lower():
            # Extract the vendor ID and product ID
            vendor_product_ids = line.split("ID ")[1].split(":")
            vendor_id = int(vendor_product_ids[0], 16)
            product_id = int(vendor_product_ids[1].split(" ")[0], 16)
            return vendor_id, product_id

    # If no printer line is found, raise an exception
    raise Exception("USB printer not found")


if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Generate WiFi QR code")
    parser.add_argument("username", help="Username for WiFi connection")
    parser.add_argument("password", help="Password for WiFi connection")
    parser.add_argument("ap_host", help="Hostname for WiFi connection")
    parser.add_argument("wifi_ssid", help="Password for WiFi connection")
    parser.add_argument("password_expiry", help="Password expiration Date/Time")
    parser.add_argument("business_name", help="Business Name")
    parser.add_argument("business_address", help="Business Address")
    parser.add_argument("business_text", help="Business Text Image")
    parser.add_argument("business_logo", help="Business Logo Image")

    args = parser.parse_args()

    # Generate the WiFi QR code and print it
    generate_wifi_qrcode()
