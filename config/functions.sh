# ===== FUNCIONES =====

# Función: get_full_path
# Descripción: Obtiene la ruta completa de un directorio o archivo.
#
# Parámetros:
#   - path: La ruta del directorio o archivo.
#   - root_path: La ruta raíz para calcular rutas relativas (opcional).

get_full_path() {
  local path="$1"
  local root_path="$2"
  local full_path

  # Comprobar si se proporciona la ruta raíz
  if [[ -n "$root_path" ]]; then
    # Calcular la ruta relativa
    full_path="${path#$root_path/}"
    if [[ "$path" == "$root_path" ]]; then
      full_path="/"
    else
      full_path="/$full_path"
    fi
  else
    # Comprobar si la ruta es ".."
    if [[ "$path" == ".." ]]; then
      # Obtener el directorio padre del directorio actual
      full_path="$(cd "$(dirname "$PWD")" && pwd)"
    else
      # Comprobar si la ruta es relativa o absoluta
      if [[ "$path" == /* ]]; then
        # Ruta absoluta
        full_path="$path"
      else
        # Ruta relativa
        full_path="$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
      fi
    fi
  fi

  echo "$full_path"
}

# Función que la ruta del directorio del script actual.
# Parámetros:
#   - location: la ubicación del script actual.
set_scriptdir() {
    local location="$1"
    echo "$(dirname "$(readlink -f "$location")")"
}

# Intenta cargar un archivo y muestra un mensaje de error si no se encuentra.
# Parámetros:
#   - file: el archivo a cargar.
attempt_to_load() {
    local file="$1"

    # Comprueba si el archivo existe
    if [ ! -f "$file" ]; then
        exit 1 # Termina el script con un código de salida no cero
    fi

    # Continúa con el resto del script si el archivo existe
    source "$file"
}

# Función: create_symbolic_link
# Descripción: Crea un enlace simbólico desde una ruta de destino a una ruta de enlace especificada y cambia el propietario.
#
# Parámetros:
#   - target_path: La ruta de destino del enlace simbólico.
#   - link_path: La ruta del enlace simbólico a crear.
#   - owner: El propietario del enlace simbólico.

create_symbolic_link() {
    local target_path="$1"
    local link_path="$2"
    local owner="$3"

    # Borra el archivo si ya existe
    delete_if_exists "$link_path"

    # Crea un enlace simbólico
    run "sudo ln -s \"$target_path\" \"$link_path\"" "Enlazando: \"$target_path\" -> \"$link_path\""

    # Cambia el dueño del enlace
    change_owner "$owner:$owner" "$link_path"
}

change_owner() {
    local owner="$1"
    local target_path="$2"
    run "sudo chown \"$owner\" \"$target_path\"" "Cambiando dueño: \"$owner\" \"$target_path\""
}

# Función: eliminar_si_existe
# Descripción: Elimina un archivo o directorio si existe.
#
# Parámetros:
#   - file: el archivo o directorio a eliminar.

delete_if_exists() {
    local file="$1"

    if sudo test -d "$file"; then
        # Eliminando directorio
        run "sudo rm -r \"$file\"" "Eliminando directorio: $file"
    fi

    if sudo test -e "$file"; then
        # Eliminando archivo
        run "sudo rm \"$file\"" "Eliminando fichero: $file"
    fi

    if sudo test -L "$file" && ! sudo test -e "$file"; then
        # Eliminando enlace simbólico roto
        run "sudo rm \"$file\"" "Eliminando enlace roto: $file"
    fi
}


# Agrega una línea al archivo /etc/rc.local justo antes de "exit 0".
# Parámetros:
#   - line: la línea a agregar.
add_to_rc_local() {
    local line="$1"
    local file="/etc/rc.local"

    # Comprueba si la línea existe en el archivo
    if grep -qF "$line" "$file"; then
        return
    else
        # Agrega la línea antes de "exit 0" en el archivo
        run "sudo sed -i \"/^exit 0/i $line\" \"$file\"" "Añadiendo \"$line\" al fichero $file"
    fi
}

# Procesa una plantilla.
# Parámetros:
#   - template_path: la ruta de la plantilla a procesar.
process_template() {
    local template_path="$1"
    local template_dir=$(dirname "$template_path")
    local template_name=$(basename "$template_path")
    local output_name="${template_name%.template}"    # Elimina la extensión '.template' del nombre de la plantilla
    local output_path="$template_dir/../$output_name" # Mueve un nivel hacia arriba y construye la ruta de salida

    local template=$(eval "cat \"$template_path\"") # Evalúa y sustituye las variables en la plantilla

    # Elimina el archivo de salida si ya existe
    delete_if_exists "$output_path"

    local processed_template=$(eval "echo \"$template\"") # Evalúa y sustituye las variables en la plantilla
    run "--quiet" "echo '$processed_template' > \"$output_path\"" "Procesando plantilla: \"$template_path\""
}

# Procesa todas las plantillas en el directorio de templates.
process_all_templates() {
    local template_dir="$SCRIPT_DIR/templates"

    # Comprueba si el directorio existe
    if [ ! -d "$template_dir" ]; then
        # echo "Directorio de plantillas no encontrado: $template_dir"
        exit 0
    fi

    # Procesa cada archivo de plantilla
    for template_file in "$template_dir"/*.template; do
        if [ -f "$template_file" ]; then
            process_template "$template_file"
        fi
    done
}

# Función: verify_dependency
# Descripción: Verifica una dependencia y la instala si es necesario.
#
# Parámetros:
#   - command_name: El nombre del comando a verificar.
#   - install_command: El comando para instalar la dependencia.

verify_dependency() {
    local command_name="$1"
    local install_command="$2"

    # Comprueba si el comando está instalado
    run "--quiet" "$command_name" "Comprobando disponibilidad: \"$command_name\""

    if [ $? -ne 0 ]; then
        # Realiza la instalación utilizando el comando proporcionado
        run "$install_command" "Instalando $install_command"
    fi
}



# Función: run
# Descripción: Ejecuta un comando con un spinner si el archivo spinner está disponible, de lo contrario, simplemente ejecuta el comando.
#
# Parámetros:
#   - command: El comando a ejecutar.

run() {
    local spinner_file="$SPINNER"

    # Comprueba si el archivo del spinner existe y es ejecutable
    if [ -x "$spinner_file" ]; then
        "$spinner_file" "$@"
    else
        echo "Archivo del spinner no encontrado o no ejecutable."
        if [ "$1" = "-q" ] || [ "$1" = "--quiet" ]; then
            shift
        fi
        echo "Ejecutando \"$1\""
        eval "$1"
    fi
}

# Función: change_directory
# Descripción: Cambia al directorio especificado y muestra el directorio completo antes de cambiar.
#
# Parámetros:
#   - directory: El directorio al que se desea cambiar.

change_directory() {
    local directory="$1"
    local full_path=$(get_full_path "$(get_full_path "$directory")" "$BASE_DIR")

    if run "cd $directory" "Cambiando al directorio: $full_path"; then
        cd "$directory"
        return 0
    else
        return $?
    fi
}

# Función: test_execute
# Descripción: Verifica si un script es ejecutable.
#
# Parámetros:
#   - script: La ruta completa del script a verificar.

test_execute() {
    local script="$1"
    local script_full="$(get_full_path "$1")"

    if [[ -x "$script_full" ]]; then
        return 0
    else
        return 1
    fi
}

# Función: execute
# Descripción: Ejecuta un archivo ejecutable.
#
# Parámetros:
#   - executable: La ruta completa del archivo ejecutable a ejecutar.

execute() {
    local executable="$1"
    local executable_full="$(get_full_path "$1")"

    if run "--quiet" "file \"$executable_full\" | grep \"executable\"" "Ejecutando: \"$executable_full\""; then
        bash "$executable_full"
    fi
}

# Función: verify_pip_dependency
# Descripción: Verifica una dependencia de pip y la instala si es necesario.
#
# Parámetros:
#   - dependency: El nombre de la dependencia a verificar e instalar.

verify_pip_dependency() {
    local dependency="$1"
    # Comprueba la instalación de la dependencia
    run "--quiet" "pip show $dependency -q" "Comprobando disponibilidad: \"$dependency\""

    if [ $? -ne 0 ]; then
        # Realiza la instalación utilizando el comando proporcionado
        run "pip install $dependency" "Instalando $dependency con pip"
    fi
}

# Función: change_mode
# Descripción: Cambia los permisos de un archivo o directorio.
#
# Parámetros:
#   - mode: Los permisos a establecer.
#   - target: El archivo o directorio al que se le cambiarán los permisos.

change_mode() {
    local mode="$1"
    local target="$2"
    run "sudo chmod $mode $target" "Cambiando permisos: $target"
}


# Función: install_service
# Descripción: Instala un servicio utilizando un archivo de plantilla.
#
# Parámetros:
#   - service_template: La ruta del archivo de plantilla del servicio.
#   - service_file: La ruta del archivo de servicio a crear.
install_service() {
    local service_template="$1"
    local service_file="$2"
    local service_name=$(basename "$service_file")
    create_symbolic_link "$service_template" "$service_file" "root"
    change_mode "644" "$service_file"

    # Recargar la configuración de systemd
    run "sudo systemctl daemon-reload" "recargando systemctl"

    # Habilitar y iniciar el servicio
    run "sudo systemctl enable $service_name" "habilitando servicio $service_name"
    run "sudo systemctl start $service_name" "iniciando servicio $service_name"
}
