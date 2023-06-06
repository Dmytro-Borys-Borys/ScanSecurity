
# Cargando settings generales
set_scriptdir "$BASH_SOURCE"
source "$BASH_SOURCE/../config/config.txt"

verify_dependency "pip" "sudo apt install python3-pip -y"
pip install pyqrcode
pip install escpos

