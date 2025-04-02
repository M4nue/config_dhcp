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


#Insertar funcion f_conexion_internet

function f_conexion_internet(){

        local conexion="8.8.8.8"

        if [[ $(ping -c 2 $conexion) ]] ;then
                return 0
        else
                return 1
        fi
}
