import qrcode
import os
import pyqrcode
import argparse
import subprocess
import re
import tempfile
from PIL import Image, ImageDraw, ImageFont
from escpos.printer import Usb


def resize_image(image, width, height):
    original_width, original_height = image.size

    # Calcular las nuevas dimensiones manteniendo la relación de aspecto
    width_ratio = width / original_width
    height_ratio = height / original_height

    # Utilizar el factor de escala más pequeño para asegurar que la imagen quepa dentro de las dimensiones deseadas
    scaling_factor = min(width_ratio, height_ratio)

    # Calcular las nuevas dimensiones basadas en el factor de escala
    new_width = int(original_width * scaling_factor)
    new_height = int(original_height * scaling_factor)

    # Redimensionar la imagen utilizando las nuevas dimensiones
    resized_image = image.resize((new_width, new_height))

    return resized_image


def generate_wifi_qrcode():
    # Crear la URI de la red WiFi
    wifi_uri = f"http://{args.ap_host}:2050/?u={args.username}&p={args.password}"
    print(wifi_uri)

    # Generar el código QR
    qr_code = pyqrcode.create(wifi_uri)

    # Guardar el código QR como un archivo PNG
    with tempfile.NamedTemporaryFile(suffix=".png") as temp_file:
        qr_code.png(temp_file.name, scale=5)
        temp_file.seek(0)

        # Imprimir el código QR utilizando la impresora USB
        print_qr_code_file(temp_file.name)



def print_qr_code_file(file_path):
    ancho_maximo = 580
    alto_maximo = 750

    # Definir el contenido del ticket
    sistema_wifi = "Sistema de Acceso Wi-Fi"
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
    fuente_header3 = ImageFont.truetype("../fonts/Roboto-Black.ttf", tamaño_header3)
    fuente_header4 = ImageFont.truetype("../fonts/Roboto-Black.ttf", tamaño_header4)
    fuente_parrafo = ImageFont.truetype("../fonts/Roboto-Regular.ttf", tamaño_parrafo)
    fuente_negrita = ImageFont.truetype("../fonts/Roboto-Black.ttf", tamaño_negrita)

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

    # Cargar y posicionar la imagen del código QR
    qr_code_img = Image.open(file_path)
    qr_code_img = qr_code_img.resize((285, 285))  # Redimensionar a 285x285 píxeles

    # Calcular la posición central de la imagen del código QR en el lienzo
    qr_code_x = (ancho_maximo - qr_code_img.width) // 2
    qr_code_y = 250
    qr_code_position = (qr_code_x, qr_code_y)
    imagen_ticket.paste(qr_code_img, qr_code_position)

    # Cargar y ajustar la imagen adicional
    additional_img = Image.open(args.business_logo)
    additional_img = resize_image(additional_img, 80, 80)

    # Calcular la posición para pegar la imagen adicional
    additional_position_x = (
        qr_code_x + qr_code_img.width // 2 - additional_img.width // 2
    )
    additional_position_y = (
        qr_code_y + qr_code_img.height // 2 - additional_img.height // 2
    )

    # Pegar la imagen adicional en el lienzo
    imagen_ticket.paste(
        additional_img,
        (additional_position_x, additional_position_y),
        mask=additional_img,
    )

    # Calcular el ancho total de los textos de clave y valor
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

    # Calcular la posición central
    center_position = ancho_maximo // 2

    # Calcular las posiciones para los textos de clave y valor
    key_position = center_position - key_width - 10
    value_position = center_position + 10

    # Colocar los textos de clave y valor
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


def grant_printer_permissions(vendor_id, product_id):
    # Convertir los valores decimales a hexadecimal y completar con ceros iniciales si es necesario
    vendor_id_hex = hex(vendor_id)[2:].zfill(4)
    product_id_hex = hex(product_id)[2:].zfill(4)

    # Especificar el contenido de la regla udev con valores hexadecimales
    udev_rule_content = f'SUBSYSTEM=="usb", ATTRS{{idVendor}}=="{vendor_id_hex}", ATTRS{{idProduct}}=="{product_id_hex}", MODE="0666"'

    # Especificar la ruta al directorio y archivo de reglas udev
    udev_rules_dir = "/etc/udev/rules.d"
    udev_rules_file = os.path.join(udev_rules_dir, "scansecurity_printer.rules")

    # Verificar si el archivo de reglas udev ya existe
    if os.path.exists(udev_rules_file):
        print(f"El archivo de reglas udev {udev_rules_file} ya existe.")
    else:
        # Escribir el contenido de la regla udev en un archivo temporal
        tmp_file_path = "/tmp/scansecurity_printer.rules"

        with open(tmp_file_path, "w") as tmp_file:
            tmp_file.write(udev_rule_content)

        # Utilizar sudo para mover el archivo temporal al directorio de reglas udev
        subprocess.run(["sudo", "mv", tmp_file_path, udev_rules_file])

        # Recargar las reglas de udevadm
        os.system("sudo udevadm control --reload-rules")
        print(f"Se ha creado el archivo de reglas udev {udev_rules_file} y se han recargado las reglas de udevadm.")



def find_usb_printer():
    # Ejecutar el comando lsusb para obtener información sobre los dispositivos USB
    lsusb_output = subprocess.check_output(["lsusb"]).decode("utf-8")

    # Dividir la salida en líneas
    lines = lsusb_output.strip().split("\n")

    # Iterar sobre las líneas y encontrar la línea que contiene la palabra clave "printer"
    for line in lines:
        print(line)
        if "printer" in line.lower():
            # Extraer el ID del fabricante y el ID del producto
            vendor_product_ids = line.split("ID ")[1].split(":")
            vendor_id = int(vendor_product_ids[0], 16)
            product_id = int(vendor_product_ids[1].split(" ")[0], 16)
            return vendor_id, product_id

    # Si no se encuentra ninguna línea de impresora, lanzar una excepción
    raise Exception("Impresora USB no encontrada")


if __name__ == "__main__":
    # Analizar los argumentos de la línea de comandos
    parser = argparse.ArgumentParser(description="Generar código QR de Wi-Fi")
    parser.add_argument("username", help="Nombre de usuario para la conexión Wi-Fi")
    parser.add_argument("password", help="Contraseña para la conexión Wi-Fi")
    parser.add_argument("ap_host", help="Nombre de host para la conexión Wi-Fi")
    parser.add_argument("wifi_ssid", help="Nombre de la red Wi-Fi")
    parser.add_argument("password_expiry", help="Fecha/Hora de expiración de la contraseña")
    parser.add_argument("business_name", help="Nombre de la empresa")
    parser.add_argument("business_address", help="Dirección de la empresa")
    parser.add_argument("business_text", help="Imagen de texto de la empresa")
    parser.add_argument("business_logo", help="Imagen del logotipo de la empresa")

    args = parser.parse_args()

    # Generar el código QR de Wi-Fi e imprimirlo
    generate_wifi_qrcode()
