# Sistemas Operativos: TP1 #  
**Grupo 4**  
  
**Autores:**  
- **Manuel Longo - 102425** 
- **Federico Burman - 104112**   
- **Agustín More - 102914**  
- **Daniel Alejandro Lovera López - 103442**

## Guía de ejecución rápida

Guía para el desarrollo (no necesariamente va a quedar en el informe final)

```sh
# Desde .../Grupo4 como referencia, no debería importar
# desde dónde se ejecuta
bash sisop/sotp1.sh
source sisop/soinit.sh
# Acá debería estar corriendo el sistema
# Para detenerlo
bash bin/frenotp1.sh
# Para volver a arrancarlo
bash bin/arrancotp1.sh
# bin o la carpeta que se haya elegido en la instalación
# más genérico $DIRBIN
```

## Acceso ##
1. Haga click en **[acceso](https://github.com/DanieLovera/sistemas_operativos_tp1)** para dirigirse al repositorio digital de github que contiene los archivos de descarga.  

## Descarga del Sistema ##
  
### Opción 1 ###
1. Hacer click en la pestaña code.
2. Descargar el zip.
3. Descomprimir el zip.
4. Automaticamente en su directorio actual encontrara los siguientes archivos/directorios descargados:  
    - Grupo4
        - imagenes_enunciado
        - misdatos
        - mispruebas
        - original
        - sisop
        - tp1datos
        - README.md
        - TP1_enunciado.md
  
### Opción 2 ###
1. Abra una nueva sesión en un terminal de Linux con interprete bash.
2. Navegue hacia un directorio en donde desee se descarguen los archivos del repositorio.
3. Ingrese el comando ```git clone https://github.com/DanieLovera/sistemas_operativos_tp1.git``` para descargar el sistema.
4. Automaticamente en su directorio actual encontrara los siguientes archivos/directorios descargados:  
    - Grupo4
        - imagenes_enunciado
        - misdatos
        - mispruebas
        - original
        - sisop
        - tp1datos
        - README.md
        - TP1_enunciado.md

## Instalación del Sistema ##
1. Navegue hacia el directorio sisop  
    1.1 Ingrese el comando ```cd Grupo4/sisop```
2. Inicie la instalación del sistema ejecutando el script ***sotp1.sh***  
    2.1 Ingrese el comando ```bash sotp1.sh```
3. Siga las instrucciones que aparecen en pantalla para completar la instalación.  
    3.1 Ingrese los nombres de los directorios solicitados en pantalla.  
  
      - El nombre ingresado debe encontrarse en una ruta válida dentro del directorio Grupo4.  
      - No se aceptarán directorios que no existan previamente, por ejemplo: ./sisop/nuevo_directorio
      - No se aceptaran directorios con guiones, o espacios en blanco. Los siguientes ejemplos aplican:
        1. directorio-entrada
        2. directorio entrada  
  
    3.2 Confirme la instalacion.  
      - En caso de ingresar SI, terminará el proceso de instalación.  
      - En caso de ingresar NO, debe volver a completar los nombres de los directorios requeridos por el  
        paso 3.1  
4. Una vez realizada la instalación encontrará los directorios que fueron solicitados en el paso 3.1, y
   en el directorio sisop un archivo de nombre ```sotp1.conf``` que contiene las rutas a los mismos. Además encontrara archivos de extension .log que
   registran información sobre los procesos que se llevan a cabo en el sistema.
   
## Reparación del Sistema ##  
1. Navegue hacia el directorio sisop.
2. Ejecute el script ***sotp1.sh***  
    2.1 Ingrese el comando ```bash sotp1.sh```
3. Siga las instrucciones que aparecen en pantalla para completar la reparación.  
    3.1 Si el sistema se encuentra dañado se presentara un resumen con las rutas en donde se depositarán los archivos que puedan ser reparados.  
    3.2 Confirme la reparación para comenzar el proceso.  
    3.3 El sistema le mostrará por pantalla los archivos que fueron reparados en caso de una  
        reparación exitosa o el motivo y las instrucciones para realizar una reparación manual en caso fallido.  
   
4. Una vez finalizada la reparación el sistema sera restaurado a como se instalo originalmente, y se
   agrega al archivo de configuración ```sotp1.conf``` la fecha, hora y el usuario que realizo la reparación.  

## Ejecución del Sistema ##
1. Navegue hacia el directorio sisop.
2. Ejecute el script de instalación ***sotp1.sh***
  2.1 Ingrese el comando ```bash sotp1.sh```
3. Inicialice el sistema.  
  3.1 Ingrese el comando ```source soinit.sh```
4. Con el sistema inicializado:  
  4.1 Mueva el/los archivo/s que requiera procesar del directorio tp1datos hacia el directorio
      de entrada que indicó previamente en la instalación.
5. Frene el tp para culminar el proceso.  
  5.1 Ejecute el script en ./bin/frenotp1.sh
6. Para volver a ejecutar el sistema llame al script freno tp1.
  6.1 Ejecute el script en ./bin/arrancotp1.sh
