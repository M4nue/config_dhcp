#!/usr/bin/env bash
#set -x
#Autores: Manuel Rodríguez Curado, Jose Manuel Sierra Aroca, Estabaliz Perez Muñoz, Jose María Oteo Dorado
#Fecha creación: 2025-03-31
#Descripcion del script:Instalación y configura un servidor dhcp

#ZONA DECLARACIÓN DE VARIABLES
paquete="isc-dhcp-server"
#Expresión regular para identificar si una cadena de caracteres es una IP
regexp_ip="^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$"
#Expresión regular confirmar tiempo
regexp_tiempo="^[1-9][0-9]*$"


#ZONA DECLARACIÓN DE FUNCIONES
function f_soy_root(){
  if [[ $UID -eq 0 ]] ;then
    return 0
  else
    return 1
  fi
}

#Insertar funcion f_paquete_instalado
f_instalado2(){
  if f_buscar_paquete $paquete; then
    echo "El paquete ya está instalado."
    return 0
  else
    read -p "¿Quiere instalar $paquete? (yes/no): " opcion
    if [[ "$opcion" == "yes" || "$opcion" == "y" ]]; then
      if f_soy_root && f_hay_conexion; then
        apt install -y "$paquete"
      else
        return 1
      fi
    else
      echo "Instalación cancelada."
      return 1
    fi
  fi
}

#-----

#Insertar funcion f_conexion_internet

function f_conexion_internet(){
  local conexion="8.8.8.8"

  if [[ $(ping -c 1 $conexion) ]] ;then
    return 0
  else
    return 1
  fi
}


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

#f_escribir_cambios(){
#
#}

#f_anexar_datos(){
#
#}


while getopts ":hf:d:l:sn:t:T:" opcion; do
#  echo -e "numeros de argumentos: $# \n valores de los argumentos: $*"
  case $opcion in
    h)echo "Mostrar función de ayuda"
      #echo "Opcion h: $OPTIND" con la variable $OPTIND veremos cual es la siguiente opcion que se ejecutara
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
    :)echo "Error en la opcion $OPTARG se necesita de argumento"
      #FUNCION DE AYUDA
;;
    ?)echo "Error en la sintaxis del comando, revisa la ayuda"
      #FUNCION DE AYUDA
;;
  esac
done



