#!/usr/bin/env bash
#Autores: Manuel Rodríguez Curado, Jose Manuel Sierra Aroca, Estabaliz Perez Muñoz, Jose María Oteo Dorado
#Fecha creación: 2025-03-31
#Descripcion del script:Instalación y configura un servidor dhcp
#ZONA DECLARACIÓN DE VARIABLES
v_paquete_dhcp="isc-dhcp-server"
#ZONA DECLARACIÓN DE FUNCIONES

#Insertar funcion f_soy_root

function f_soyroot1(){

        if [[ $UID -eq 0 ]] ;then
                return 0
        else
                return 1
        fi
}

#Insertar funcion f_paquete_instalado
f_instalado2(){
  read -p "Introduce el nombre del paquete" paquete

  if f_buscar_paquete "paquete"; then
    echo "El paquete ya está instalado."
    return 0
  else
    read -p "¿Quiere instalar $paquete? (yes/no): " opcion
    if [[ "$opcion" == "yes" ]]; then
      if f_hay_conexion; then
        echo "Conexión a internet detectada. Instalando $paquete..."
        sudo apt install -y "$paquete"
      else
        echo "No tienes acceso a internet. No se puede instalar el paquete."
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

        if [[ $(ping -c 2 $conexion) ]] ;then
                return 0
        else
                return 1
        fi
}
