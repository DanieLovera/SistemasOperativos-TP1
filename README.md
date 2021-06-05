# Sistemas Operativos: TP1 #  
**Grupo 4**  
  
**Autores:**  
- **Manuel Longo - 102425** 
- **Federico Burman - 104112**   
- **Agustin More** (CORREGIR)  
- **Daniel Alejandro Lovera López - 103442**

## Acceso ##
1. Haga click en **[acceso](https://github.com/DanieLovera/sistemas_operativos_tp1)** para dirigirse al repositorio digital de github que contiene los archivos de descarga.  

## Descarga del Sistema ##
1. Abra una nueva sesión en un terminal de Linux con interprete bash.
2. Navegue hacia un directorio en donde desee se descarguen los archivos del repositorio.
3. Ingrese el comando ```git clone https://github.com/DanieLovera/sistemas_operativos_tp1.git``` para descargar el sistema.
4. Automaticamente en su directorio actual encontrara los siguientes archivos/directorios descargados:  
    - Grupo4
        - misdatos
        - mispruebas
        - original
        - sisop
        - tp1datos
    - README.md 

## Instalación del Sistema ##
1. Navegue hacia el directorio sisop  
    1.1 Ingrese el comando ```cd Grupo4/sisop```
2. Inicie la instalación del sistema ejecutando el script ***sotp1.sh***  
    2.1 Ingrese el comando ```bash sotp1.sh```
3. Siga las instrucciones que aparecen en pantalla para completar la instalación.  
    3.1 Ingrese los nombres de los directorios solicitados en pantalla.  
  
      - El nombre ingresado debe encontrarse en una ruta válida dentro del directorio Grupo4.  
      - No se aceptarán directorios que no existan previamente, por ejemplo: ./sisop/nuevo_directorio  
  
    3.2 Confirme la instalacion.  
      - En caso de ingresar SI, terminará el proceso de instalación.  
      - En caso de ingresar NO, debe volver a completar los nombres de los directorios requeridos por el  
        paso 3.1  
4. Una vez realizada la instalación encontrará los directorios que fueron solicitados en el paso 3.1, y
   en el directorio actual un archivo de nombre ```sotp1.conf``` que contiene las rutas a los mismos.
   
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
