
# Cargando settings generales
source "$(dirname "$(readlink -f "$BASH_SOURCE")")/../config/config.txt"
set_scriptdir "$BASH_SOURCE"

verify_dependency "pip" "sudo apt install python3-pip -y"
pip install pyqrcode
pip install escpos

