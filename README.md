# TPvP
Plugins del antiguo servidor Team DeathMatch de la comunidad Imperium Sven Co-op.
## Que es esto?
Seamos sinceros, todos los servidores PvP que existen alla afuera en Sven Co-op son exactamente iguales sin ninguna diferencia entre ellas. El mundo utiliza siempre los mismos sistemas de PvP junto con las "adaptaciones" de los mapas mas jugados que a largo plazo no dicen la gran cosa. Lo que me sorprende de todo esto, es que este sistema PvP que siempre existio, presenta defectos y que nadie haya hecho nada en intentar arreglarlos, o bien crear un nuevo sistema que sea el sucesor de este antiguo trabajo.

De que defectos estoy hablando? Para empezar, el actual sistema existente tiene un limite de jugadores, si este numero ha de excederse, el sistema ya no tendra "espacios disponibles" lo que hara que todos los jugadores futuros tengan la misma **Classify()**. Lo que lleva al segundo defecto, los valores de **IRelationship()** de una de estas classify retorna **R_AL** a otra cierta classify especifica, esto significa que existira el caso que un jugador no pueda matar a otro jugador -*y viceversa*- ya que el juego los consideradan como aliados, y no existe un friendly fire integrado en Sven Co-op. Y finalmente tercer defecto, algunas classify, por una razon que aun desconozco, "rompe" algunas entidades; Algunos jugadores son incapaces de utilizar ciertas entidades del mapa si sus classify tienen un valor especifico, el mayor ejemplo serian los *func_tank*, los jugadores que tengan esta classify "extraña" no podran utilizar torretas que los mapas tengan.

Esto significaba que si queria crear un sistema PvP sin estos defectos y sin limite de jugadores. Tendria que renunciar al FFA (Free For All) y hacerlo un DeathMatch por equipos, o bien Team DeathMatch, de ahi surgio todo este proyecto. Aun asi, debo dar enfasis a la descripcion de este repositorio: **ANTIGUO SERVIDOR**. El servidor Team Deathmatch de Imperium Sven Co-op hoy ya no existe. Tal vez el proximo que tome el puesto podra revivirlo y darle de regreso la gloria que el TDM tenia?

Este proyecto surgio en las primeras actualizaciones de Sven Co-op, lo que significa que para su funcionamiento en aquel entonces, he tenido que mezclar contenido AUN MAS MIXTO de lo que normalmente me gustaria hacer. AngelScript y AMX Mod X sigue permaneciendo en el sentido de plugins, pero tambien he tenido que recurrir a map scripts. El TPvP utiliza tanto PLUGINS como MAP SCRIPTS para su funcionamiento, y ha permanecido asi desde entonces. Trate de organizar los archivos del repositorio lo mejor que pude para que sea lo mas legible posible, espero haber hecho un buen trabajo.
## Porque mezclar tanto AngelScript como AMX Mod X para este sistema?
~~Cuantas veces he hecho copypaste y repetido casi lo mismo?~~

AngelScript carece de ciertas utilidades especificas que solo el AMX Mod X tiene. No repetire el mismo texto tres veces asi que ire al grano. El proyecto requiere del hookeo de comandos y mensajes especificos del motor que solo AMXX provee. Siendo los mas primordiales **register_clcmd** y *register_message* para hookear mensajes **SVC_TEMPENTITY**. Los desarrolladores jamas van a implementar tales funciones al AngelScript por razones que no escribire aca ya que se volveria en un "rant".
## Porque mezclar plugins y map scripts?
Antiguamente, era la unica forma de hacer funcionar los scripts de armas en los mapas, ya que en el pasado, no se podian registrar entidades personalizadas en un plugin. Hoy en dia es posible pero aun asi decidi dejarlo por separado por razones de comodidad, y no hablo por mi mismo, sino por los jugadores que entren a los servidores. Ya veras de lo que estoy hablando.
## Que ocurrio con el servidor Team DeathMatch?
Antes de los cortes de presopuesto, el servidor tenia su propio alojamiento, lo que le permitio mantenerse abierto en todo momento. En adicion, tambien disponiamos de un "FastDL" lo que permitia a los jugadores descargar rapidamente los archivos necesarios para conectarse al servidor. Perdimos ese privilegio y hemos perdido no solo el alojamiento de ese servidor, sino que tambien perdimos el FastDL, haciendo las descargas mucho mas lentas.

Y hablando de descargas, recuerdas que dije porque no uni los map scripts en un unico plugin? Por las descargas, si dejase todas las armas en forma de plugins, los jugadores tendrian que descargar montones de models, sonidos, sprites, etc; Representando a todas las armas que utilize el servidor, los jugadores de la generacion de ahora son extremadamente cortoplacistas, nadie va a esperar tanto tiempo en descargar tantas armas solo para que se use una fraccion de ellas segun el mapa actual del servidor, aun menos si ya no disponemos FastDL!

Porque no pedi a mis superiores un espacio extra para montar este servidor?

Bromeas, verdad? No puedo ir a hablar alla arriba y decir: **HOLA QUIERO UN TERCER SERVIDOR KTHXBAI** y esperar que todo marche bien, O bien que no tenga que dar algo a cambio como apoyo financiero -*a mi no me va tan bien economicamente!*-. Peor aun pedir dos cosas a la vez al solicitar tambien un FastDL. ISC se volveria una comunidad con demasiados privilegios a comparacion del resto de IFPS y no solo es injusto, sino que tambien es aprovecharme de la situacion, es tener demasiado a cambio de nada. No corri ese riesgo por temor a perder mi puesto.

~~Aunque, si hubiese estado alcoholizado tal vez hubiese corrido tal riesgo... tal vez...~~
## Archivos del proyecto
Vale, esto es complejo. Vayamos por partes, vamos primero a los plugins, que es sencillo.

Los archivos plugins son:

1. **TPvP.as**
   - Este es el plugin TPvP principal. La mayoria de sus funciones se encuentran aqui y son independientes, si los plugins adicionales no pueden correr, el TPvP puede aun seguir ejecutandose para los jugadores, aunque con funcionabilidad limitada.
2. **TPvP_Helper.sma**
   - Este plugin provee un pequeño impulso a las funciones faltantes que el TPvP utiliza en ciertos mapas. Primordialmente mapas DMC que utilizan su propio sistema de armadura.
3. **GHW_Custom_Nextmap.sma**
   - Tal como su nombre lo indica, este es el plugin RTV original de GHW, modificado para su uso en el proyecto. Sus diferencias son limitaciones en el "nominate", y avisar al plugin principal cuando un mapa finaliza. Algo sumamente util para que los jugadores puedan subir de nivel.

Los archivos map scripts son mayoria, con una aclaracion; Todas las armas disponen de scripts adicionales para que sus funcionamientos sean lo mas identicos posibles a sus mods originales. Estos archivos son:

1. **-carpeta- cs16**
   - Scripts de todas las armas Counter-Strike, en adicion a la C4, y la armadura del mod. Dentro de esta carpeta tambien se encuentra el script principal para usarse en mapas de categoria **cs_**.
2. **-carpeta- dmc_weapons**
   - Scripts de todas las armas DeathMatch Classic, en adicion a la armadura del mod.
3. **-carpeta- dod_weapons**
   - Scripts de todas las armas Day of Defeat, en adicion a una entidad personalida imitando los Puntos de Control de tal mod.
4. **-carpeta- hl_weapons**
   - Scripts de todas las armas clasicas del Half-Life.
5. **-carpeta- hlsp**
   - Scripts para complementar los mapas de la categoria HL. Contienen los cargadores clasicos de vida/armadura.
6. **-carpeta- hq2_weapons**
   - Scripts de armas del mod HalfQuake: Amen.
7. **-carpeta- misc_weapons**
   - Scripts de armas miscelaneas de uso especifico.
8. **IM.as**
   - Script para usarse en mapas de categoria **aim_ig_**.
9. **TPvP_DMCMap.as**
   - Script para usarse en mapas de categoria **dmc_**.
10. **TPvP_DODMap.as**
    - Script para usarse en mapas de categoria **dod_**.
11. **TPvP_FUNMap01.as**
    - Script de sistema que se usa en el mapa **fun_hide_n_seek** y **fun_hide_n_seek2**.
12. **TPvP_FUNMap02.as**
    - Script de sistema que se usa en el mapa **fun_big_city2**.
13. **TPvP_FUNMap03.as**
    - Script de sistema que se usa en el mapa **fun_clue_3**.
14. **TPvP_FUNMap04.as**
    - Script de sistema que se usa en el mapa **fun_big_city**.
15. **TPvP_FUNMap05.as**
    - Script de sistema que se usa en el mapa **fun_darkmines**.
16. **TPvP_FUNMap06.as**
    - Script de sistema que se usa en el mapa **fun_hq2_phoenix**.
17. **TPvP_HLMap.as**
    - Script para usarse en mapas de categoria **hl_**.
18. **TPvP_SCMap.as**
    - **DELETED** | Este script es un viejo remanente de la antigua categoria de mapas **sc_** que nunca pudo ver la luz del dia.
19. **UTIL_GetDefaultShellInfo.as**
    - Script auxiliar utilizado por las armas CS y DoD.
## Una nota sobre los archivos
El proyecto solamente contendra el codigo fuente, no provere de los sonidos/models/sprites o cualquier otro archivo adicional que el proyecto utiliza en su codigo. Y solicito que por favor se mantenga asi, aunque estoy abierto a negociar esta regla.

Si decides compilar y utilizar los codigos para tu propio uso tendras que inventar sus propios archivos adicionales que el proyecto utilize, o bien desactivarlos por completo.
## Instrucciones de compilacion/instalacion
Compilar todo el proyecto no es tan dificil como parece. Aun asi, ten en cuenta la siguiente advertencia:

Los **map scripts** son **delicados**: Todos los scripts de este tipo estan entrelazos entre si, lo que significa que si la compilacion de uno de estos scripts falla, **_todos los demas scripts tambien fallaran_**. Asegurate que no haya errores de codigo!

#### Para compilar la seccion de plugins

### Plugins AngelScript (Extension .as):
Para compilar estos plugins solo basta con subir los nuevos archivos al servidor, cuya ubicacion es **svencoop/scripts/plugins**. Hecho eso se debe editar el archivo **default_plugins.txt** ubicado en la carpeta **svencoop** BASE. Y agregar nuestro plugin a la lista, esto solo se hace una vez, y estas nuevas entradas en la lista se deben ver de la siguiente manera:

```
"plugin"
{
  "name" "TDM"
  "script" "TPvP"
}
```
Finalmente, vamos a la consola del servidor y escribimos el comando **as_reloadplugin "TDM"** para recompilar el plugin. -*Es posible que sea necesario cambiar el mapa para que la compilacion se lleve a cabo*-. Si solamente recompilar el plugin de esta lista, resubimos el archivo y escribimos nuevamente el mismo comando en la consola del servidor.

Dare enfasis a las palabras **consola del servidor**, si estas usando un dedicado escribir los comandos "asinomas" no tendra efecto alguno, deberas escribir los comandos desde **RCON** para que sean enviados al servidor.

Si la compilacion falla, los errores seran mostrados en la consola o bien en los logs del servidor, ubicado en **svencoop/logs/Angelscript** para su facil acceso.

**_IMPORTANTE_**
El proyecto no guardara ningun dato inicialmente hasta que sus carpeta de almacenamiento esten creada y haya acceso de lectura/escritura en ella. Ve a la carpeta **svencoop/scripts/plugins/store** y crea el siguientes directorio cuyo proposito es el siguiente:

- **tdm_data**: Niveles, Creditos, y otros datos de los jugadores. De suma importancia para el plugin principal.

### Plugins AMXX (Extension .sma):
El codigo de estos plugins fue escrito en AMXX 1.8.3 (Ahora 1.9). Debes descargar/instalar esas versiones experimentales del AMXX para poder compilarlos.

Hecho eso, copiamos nuestros archivos .sma a **addons/amxmodx/scripting**. Ahora, debemos ejecutar una linea de comandos en el simbolo de sistema. Asegurate que la terminal este apuntando al directorio mencionado anteriormente y ejecuta el siguiente comando: **amxxpc.exe TPvP_Helper.sma** y luego **amxxpc.exe GHW_Custom_Nextmap.sma**. Si la compilacion es existosa, el programa creara su ficheros compilados con extension **.amxx**. Estos nuevos archivos son subidos al servidor, en **addons/amxmodx/plugins**. Finalmente agregamos estos nuevos plugins a la lista de plugins AMXX, cuyo archivo de configuracion **plugins.ini** se encuentra en **addons/amxmodx/config**. Solo nos vamos al final del fichero y agregamos dos lineas, que seran TPvP_Helper.amxx y GHW_Custom_Nextmap.amxx. Hecho! Si queremos recompilar los plugins solo modificamos el archivo .sma, compilamos y copiamos el nuevo archivo .amxx al servidor. -*Todos los cambios que realizemos solo tomaran efecto al cambiar de mapa*-.

Si no queremos utilizar el simbolo del sistema puedes crear un archivo **.bat** para simplificar la tarea. Que puede armarse de la manera siguiente: Crea un archivo .bat en **addons/amxmodx/scripting**, edita su contenido y agrega las siguientes lineas:

```
@echo off
amxxpc.exe TPvP_Helper.sma
amxxpc.exe GHW_Custom_Nextmap.sma
pause
```

Cuando quieras recompilar los plugins, copia los nuevos .sma a la carpeta, ejecuta el .bat, y si la compilacion es exitosa tendras tus nuevos .amxx para utilizar.

Lamentablemente si las compilaciones fallan, estos no son exportados a un archivo .log el cual poder inspeccionar, deberas leer la ventana de la terminal para identificar y corregir fallos que se presenten. No obstante, si tienes buen conocimiento de los archivos .bat puedes editar las lineas y exportar manualmente el proceso de compilacion a un archivo para que sus errores sean legibles ahi.

#### Para compilar la seccion de map scripts

Copia todos los archivos y carpetas a **svencoop/scripts/maps**, luego dirijite a la carpeta **configs/maps** de este repositorio. Segun la categoria de mapas que se quiera jugar se deben utilizar diferentes scripts. Por ejemplo, para la categoria HL, crea una copia de las plantillas **hl_!template.cfg** y **hl_!template_skl.cfg** y luego dale el nombre del mapa a estos nuevos archivos. Para nuestro ejemplo: **hl_crossfire.cfg** y **hl_crossfire_skl.cfg**.

Notaras como al final de uno de los archivos se encuentra la directiva **map_script TPVP_HLMap.as**. Este es el script de los mapas HL que se encargara de sus armas y demas codigos adicionales, la compilacion ocurrira automaticamente cuando el mapa se ejecute en el servidor. Si la compilacion es exitosa, todo listo! Si la compilacion falla, notaras que no empiezas con armas, la falta de armas debe ser tu primera señal de una compilacion fallida; Recuerda la advertencia anterior, si un map script falla, todo lo demas fallara. Afortunadamente, los map scripts tambien muestran sus errores de compilacion en el mismo directorio de registros, asi que puedes ir a **svencoop/logs/Angelscript** para revisar que ha sucedido.
# Finalizando
Habra muchos scripts y codigos diferentes en este proyecto pero no dejes que eso te asuste. Se que puedes hacer un buen trabajo.

Good luck, and have fun!
