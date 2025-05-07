#!/usr/bin/env bash
#set -x
#Autores: Manuel Rodríguez Curado, Jose Manuel Sierra Aroca, Estabaliz Perez Muñoz, Jose María Oteo Dorado
#Fecha creación: 2025-03-31
#Descripcion del script:Instalación y configura un servidor dhcp

#ZONA DECLARACIÓN DE VARIABLES

paquete="isc-dhcp-server"
#Expresión regular para identificar si una cadena de caracteres es una IP
regexp_ip="^(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)$"
regexp_tiempo="^[1-9][0-9]*$" #Expresión regular confirmar tiempo

subnet=false
broadcast=false
network=false
first_ip=false
last_ip=false
router=false
dns=false
default_time=false
max_time=false


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
      if f_hay_conexion; then
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
  if f_archivo_conf; then
    if [[ $(cat /etc/dhcp/dhcpd.conf | grep -Ev "^#|^$") ]]; then
      return 0
    else
      return 1
    fi
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


f_ayuda(){
echo -e "Estructura : bash $0 opciones \n"
echo -e "Descripcion : script para configuracion basica de servidor DHCP \n"
echo -e "Opciones:\n\
\n\
-f \t Primera ip del rango\n\
-l \t Ultima ip del rango\n\
-n \t Mascara de red\n\
-s \t Muestra la configuracion actual\n\
-h \t Muestra la ayuda\n\
-d \t Indicar los DNS\n\
-t \t Indica el tiempo por defecto de la concepcion de la ip\n\
-T \t Tiempo maximo permitido de concepcion de una ip\n\
-r \t Router por defecto\n\
-b \t Direccion de broadcast\n\
-S \t Indica la subnet"
}

echo "bash dhcp.sh -S ip -n Mascara de red -b ip broadcast -r ip -f ip -l ip [argumentos]"

f_archivo_conf(){
  if [ -e "/etc/dhcp/dhcpd.conf" ]; then
    return 0
  else
    echo "El fichero de configuracion no existe"
    return 1
  fi
}

f_anexo_datos() {
  if f_archivo_conf; then
  echo -e "subnet $subnet netmask $network {
\trange $first_ip $last_ip;
\toption routers $router;
\toption broadcast-address $broadcast;
}">>/etc/dhcp/dhcpd.conf
  fi
}



while getopts ":hb:f:d:l:sS:n:t:T:r:" opcion; do
#  echo -e "numeros de argumentos: $# \n valores de los argumentos: $*"
  case $opcion in
    h)echo "Mostrar función de ayuda"
      f_ayuda
      #echo "Opcion h: $OPTIND" con la variable $OPTIND veremos cual es la siguiente opcion que se ejecutara
;;
    d)echo "Indicar los DNS en la configuracion"
      if f_validar_ip $OPTARG; then
        dns=$OPTARG
      fi
;;
    f)echo "la opción f de first (primera) $opcion cuenta con la primera ip la $OPTARG"
      if f_validar_ip $OPTARG; then
        first_ip=$OPTARG
      fi
;;
    l)echo "la opcion l de lasted (ultima) $opcion cuenta con la ultima ip $OPTARG"
      if f_validar_ip $OPTARG; then
        last_ip=$OPTARG
      fi
;;
    s)echo "Opción s de show muestra configuración actual" 
      f_mostrar_configuracion
;;
    n)echo "Opción n de network, se espera parsar una mascara de red en hexadecimal(255.255.255.255)"
      if f_validar_red $OPTARG; then
        network=$OPTARG
      fi
;;
    t)echo "Tiempo por defecto de la concesion de ip en segundos"
      if f_validar_tiempo $OPTARG; then
        default_time=$OPTARG
      fi
;;
    T)echo "Tiempo maximo permitido de concesion de una ip"
      if f_validar_tiempo $OPTARG; then
        max_time=$OPTARG
      fi
;;
    S)echo "La subnet es $OPTARG"
      if f_validar_ip $OPTARG; then
        subnet=$OPTARG
      fi
;;
    b)echo "La direccion de broadcast es $OPTARG"
      if f_validar_ip $OPTARG; then
        broadcast=$OPTARG
      fi
;;
    r) echo "El router por defecto para el dhcp es $OPTARG"
      if f_validar_ip $OPTARG; then
        router=$OPTARG
      fi
;;
    :)echo "Error en la opcion $OPTARG se necesita de argumento"

;;
    ?)echo "Error en la sintaxis del comando, revisa la ayuda"
;;
  esac
done


if f_archivo_conf && f_soy_root; then 
  if f_instalado2; then
    if [[ $subnet == false ]]; then
      echo "La ip de red no esta indicada"
      f_ayuda
      return 1
    else
      if [[ $network == false ]]; then
        echo "La mascara de red no esta indicada"
        f_ayuda
        return 1
      else
        if [[ $first_ip == false || $last_ip == false ]]; then
          echo "La primera o ultima ip del rango no estan indicada"
          f_ayuda
          return 1
        else
          if [[ $broadcast == false ]]; then
            echo "La direccion de broadcast no esta especificada"
            f_ayuda
            return 1
          else
            if [[ $router == false ]]; then
              echo "El router por defecto no ha sido indicado"
              f_ayuda
              return 1
            else
              if [[ $dns != false || $default_time != false || $max_time != false ]]; then
                [[ $dns != false ]]  &&  sed -i "s/option domain-name-servers *;/option domain-name-servers $dns;"
          [[ $default_time != false ]] && $(sed -i "s/default-lease-time [0-9]*/default-lease-time $default_time/" /etc/dhcp/dhcpd.conf)
          [[ $max_time != false ]] && $(sed -i "s/max-lease-time [0-9]*/max-lease-time $max_time/" /etc/dhcp/dhcpd.conf)
                f_anexo_datos
        else
          f_anexo_datos
              fi
            fi
          fi
        fi
      fi
    fi
  fi
  return 1
else
  f_ayuda
fi
