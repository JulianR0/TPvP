# TPvP
Plugins del antiguo servidor Team DeathMatch de la comunidad Imperium Sven Co-op.
## Que es esto?
Seamos sinceros, todos los servidores PvP que existen alla afuera en Sven Co-op son exactamente iguales sin ninguna diferencia entre ellas. El mundo utiliza siempre 

los mismos sistemas de PvP junto con las "adaptaciones" de los mapas mas jugados que a largo plazo no dicen la gran cosa. Lo que me sorprende de todo esto, es que este 

sistema PvP que siempre existio, presenta defectos y que nadie haya hecho nada en intentar arreglarlos, o bien crear un nuevo sistema que sea el sucesor de este 

antiguo trabajo.

De que defectos estoy hablando? Para empezar, el actual sistema existente tiene un limite de jugadores, si este numero ha de excederse, el sistema ya no tendra 

"espacios disponibles" lo que hara que todos los jugadores futuros tengan la misma *Classify()*. Lo que lleva al segundo defecto, los valores de **IRelationship()** de 

una de estas classify retorna **R_AL** a otra cierta classify especifica, esto significa que existira el caso que un jugador no pueda matar a otro jugador -*y 

viceversa*- ya que el juego los consideradan como aliados, y no existe un friendly fire integrado en Sven Co-op. Y finalmente tercer defecto, algunas classify, por una 

razon que aun desconozco, "rompe" algunas entidades; Algunos jugadores son incapaces de utilizar ciertas entidades del mapa si sus classify tienen un valor especifico, 

el mayor ejemplo serian los *func_tank*, los jugadores que tengan esta classify "extraña" no podran utilizar torretas que los mapas tengan.

Esto significaba que si queria crear un sistema PvP sin estos defectos y sin limite de jugadores. Tendria que renunciar al FFA (Free For All) y hacerlo un DeathMatch 

por equipos, o bien Team DeathMatch, de ahi surgio todo este proyecto. Aun asi, debo dar enfasis a la descripcion de este repositorio: **ANTIGUO SERVIDOR**. El 

servidor Team Deathmatch de Imperium Sven Co-op hoy ya no existe. Tal vez el proximo que tome el puesto podra revivirlo y darle de regreso la gloria que el TDM tenia?

Este proyecto surgio en las primeras actualizaciones de Sven Co-op, lo que significa que para su funcionamiento en aquel entonces, he tenido que mezclar contenido AUN 

MAS MIXTO de lo que normalmente me gustaria hacer. AngelScript y AMX Mod X sigue permaneciendo en el sentido de plugins, pero tambien he tenido que recurrir a map 

scripts. El TPvP utiliza tanto PLUGINS como MAP SCRIPTS para su funcionamiento, y ha permanecido asi desde entonces. Trate de organizar los archivos del repositorio lo 

mejor que pude para que sea lo mas legible posible, espero haber hecho un buen trabajo.
## Porque mezclar tanto AngelScript como AMX Mod X para este sistema?
_Cuantas veces he hecho copypaste y repetido casi lo mismo?_

AngelScript carece de ciertas utilidades especificas que solo el AMX Mod X tiene. No repetire el mismo texto tres veces asi que ire al grano. El proyecto requiere del 

hookeo de comandos y mensajes especificos del motor que solo AMXX provee. Siendo los mas primordiales **register_clcmd* y **register_message* para hookear mensajes 

**SVC_TEMPENTITY**. Los desarrolladores jamas van a implementar tales funciones al AngelScript por razones que no escribire aca ya que se volveria en un "rant".
## Porque mezclar plugins y map scripts?
Antiguamente, era la unica forma de hacer funcionar los scripts de armas en los mapas, ya que en el pasado, no se podian registrar entidades personalizadas en un 

plugin. Hoy en dia es posible pero aun asi decidi dejarlo por separado por razones de comodidad, y no hablo por mi mismo, sino por los jugadores que entren a los 

servidores. Ya veras de lo que estoy hablando.
## Porque "TPvP"?
Ironicamente, el sistema del servidor Team DeathMatch nunca tuvo un nombre oficial como lo consiguieron el SCXPM y/o SDX. Quedandose desde su historia con su nombre 

interno de desarrollador "TPvP". Aunque considerando las situaciones, este nombre interno de TPvP o bien Team DeathMatch son los mejores nombres que este proyecto 

puede tener. Pero ya que estas leyendo esto, seguramente quieras darle un nuevo nombre a este sistema, eh?
## Que ocurrio con el servidor Team DeathMatch?
Antes de los cortes de presopuesto, el servidor tenia su propio alojamiento, lo que le permitio mantenerse abierto en todo momento. En adicion, tambien disponiamos de 

un "FastDL" lo que permitia a los jugadores descargar rapidamente los archivos necesarios para conectarse al servidor. Perdimos ese privilegio y hemos perdido no solo 

el alojamiento de ese servidor, sino que tambien perdimos el FastDL, haciendo las descargas mucho mas lentas.

Y hablando de descargas, recuerdas que dije porque no uni los map scripts en un unico plugin? Por las descargas, si dejase todas las armas en forma de plugins, los 

jugadores tendrian que descargar montones de models, sonidos, sprites, etc; Representando a todas las armas que utilize el servidor, los jugadores de la generacion de 

ahora son extremadamente cortoplacistas, nadie va a esperar tanto tiempo en descargar tantas armas solo para que se use una fraccion de ellas segun el mapa actual del 

servidor, aun menos si ya no disponemos FastDL!

Porque no pedi a mis superiores un espacio extra para montar este servidor?

Bromeas, verdad? No puedo ir a hablar alla arriba y decir: **HOLA QUIERO UN TERCER SERVIDOR KTHXBAI** y esperar que todo marche bien, O bien que no tenga que dar algo 

a cambio como apoyo financiero -*a mi no me va tan bien economicamente!*-. Peor aun pedir dos cosas a la vez al solicitar tambien un FastDL. ISC se volveria una 

comunidad con demasiados privilegios a comparacion del resto de IFPS y no solo es injusto, sino que tambien es aprovecharme de la situacion, es tener demasiado a 

cambio de nada. No corri ese riesgo por temor a perder mi puesto.

_Aunque, si hubiese estado alcoholizado tal vez hubiese corrido tal riesgo... tal vez..._
