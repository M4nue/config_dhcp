#/bin/bash
#Expresión regular para identificar si una cadena de caracteres es una IP
#set -x
regexp_ip="^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$"

#Expresión regular confirmar tiempo
regexp_tiempo="^[1-9][0-9]*$"

f_validar_ip(){
  if [[ $1 =~ $regexp_ip ]]; then
    echo "ip valida"
    return 0
  else
    echo "ip invalida"
    return 1
  fi
}

f_validar_red(){
  if [[ $1 =~ $regexp_ip ]]; then
    echo "ip de red valida"
    return 0
  else
    echo "ip de red invalida"
    return 1
  fi
}

f_mostrar_configuracion(){
  if [[ $(cat /etc/dhcpd.conf | grep -Ev "^#|^$") ]]; then
    return 0
  else
    echo "Fallo al encontrar el archivo"
    return 1
  fi
}

f_validar_tiempo(){
  if [[ $1 =~ ($regexp_tiempo) ]]; then
    echo "tiempo valida"
    return 0
  else
    echo "tiempo invalido"
    return 1
  fi
}

while getopts "hf:l:sn:t:T:" opcion; do
  case $opcion in
    h)echo "Mostrar función de ayuda"
;;
    d)echo "Indicar los DNS en la configuracion"
      f_validar_ip $OPTARG
;;
    f)echo "la opción f de first (primera) $opcion cuenta con la primera ip la $OPTARG"
      f_validar_ip $OPTARG
;;
    l)echo "la opcion l de lasted (ultima) $opcion cuenta con la ultima ip $OPTARG"
      f_validar_ip $OPTARG
;;
    s)echo "Opción s de show muestra configuración actual" 
      f_mostrar_configuracion
;;
    n)echo "Opción n de network, se espera parsar una mascara de red en hexadecimal(255.255.255.255)"
      f_validar_red $OPTARG
;;
    t)echo "Tiempo por defecto de la concesion de ip en segundos"
      f_validar_tiempo $OPTARG
;;
    T)echo "Tiempo maximo permitido de concesion de una ip"
       f_validar_tiempo $OPTARG
;;
    ?)echo "Error en la sintaxis del comando, revisa la ayuda"
;;
  esac
done



