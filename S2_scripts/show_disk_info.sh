# !/bin/bash

# Nombre: show_disk_info.sh
# Autores: Bernat Boscá, Albert Canellas, German Telmo Eizaguirre
# 13-05-2019 V 1.0
# 
# Muestra al usuario que lo ejecuta el espacio de disco que ocupa
# su directorio HOME.
# 
# Decisiones de diseño:
# Mostramos el espacio de disco en MB.
# 

echo "> Ocupación de disco de $HOME: $(du -s $HOME | cut -f1) M <"
exit 0
