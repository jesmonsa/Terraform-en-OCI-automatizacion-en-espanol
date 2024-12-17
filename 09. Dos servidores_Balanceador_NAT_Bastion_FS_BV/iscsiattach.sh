#!/bin/bash

# Configurar timeout global de 5 minutos
TIMEOUT=300
export SECONDS=0

# Habilitar modo de depuración y manejo de errores
set -x
set -e

# Función de timeout
timeout_handler() {
    echo "Script execution timed out after $TIMEOUT seconds"
    exit 1
}

# Configurar trap para el timeout
trap timeout_handler ALRM
( sleep $TIMEOUT; kill -ALRM $$ ) & TIMEOUT_PID=$!

BASEADDR="169.254.2.2"
addrCount=0

# Verificar y arrancar servicios necesarios
echo "Starting required services..."
sudo systemctl start iscsid || true
sudo systemctl enable iscsid || true

# Función de limpieza
cleanup() {
    kill $TIMEOUT_PID 2>/dev/null || true
    find . -maxdepth 1 -type p -exec rm -f {} \; 2>/dev/null || true
}
trap cleanup EXIT

while [ ${addrCount} -le 1 ] && [ $SECONDS -lt $TIMEOUT ]; do
    CURRADDR=$(echo ${BASEADDR} | awk -F\. '{last=$4+'${addrCount}';print $1"."$2"."$3"."last}')
    echo "Scanning ${CURRADDR} (${SECONDS}s elapsed)"
    
    # Intentar descubrir targets con timeout de 30 segundos
    if ! timeout 30 iscsiadm -m discovery -t st -p ${CURRADDR}:3260 > /tmp/targets.txt 2>/dev/null; then
        echo "No targets found at ${CURRADDR}"
        (( addrCount = addrCount + 1 ))
        continue
    fi
    
    # Procesar cada target encontrado
    while read -r line; do
        target=$(echo $line | awk '{print $2}')
        echo "Processing target: ${target}"
        
        # Verificar si ya está conectado
        if iscsiadm -m session | grep -q "${target}"; then
            echo "Target ${target} already connected"
            continue
        fi
        
        # Intentar conectar el target
        echo "Connecting to target ${target}"
        timeout 30 iscsiadm -m node -o new -T ${target} -p ${CURRADDR}:3260 || continue
        timeout 30 iscsiadm -m node -o update -T ${target} -n node.startup -v automatic || continue
        timeout 30 iscsiadm -m node -T ${target} -p ${CURRADDR}:3260 -l || continue
        
        # Esperar a que el dispositivo aparezca
        echo "Waiting for device to appear..."
        sleep 5
        
    done < /tmp/targets.txt
    
    rm -f /tmp/targets.txt
    (( addrCount = addrCount + 1 ))
done

# Si llegamos aquí sin error, cancelar el timeout
kill $TIMEOUT_PID 2>/dev/null || true

echo "Scan complete after ${SECONDS} seconds"
exit 0
