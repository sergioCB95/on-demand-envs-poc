# On Demand Environments PoC

## Descripción

El objetivo de esta prueba de concepto es ver cómo de sencillo es gestionar la infraestructura de un proyecto de forma que se puedan crear entornos de desarrollo/dev y preproducción/staging bajo demanda. 

De esta forma, el equipo en vez de contar con un conjunto de entornos estático (e.g. development -> staging -> production), pueden crear y destruir entornos dependiendo de las necesidades puntuales de este. 

Por ejemplo, en el caso de que dos features quieran ser probadas, pero no puedan ser desplegadas en el entorno de dev a la vez, se podrán crear dos entornos independientes y desplegar cada feature en uno de ellos.

Como herramientas para montar esto, vamos a partir usando simplemente Terraform, para gestionar la infraestructura y más adelante puede que metamos otras herramientas para simplificar y automatizar el proceso 

## Estructura

El proyecto consta de las siguientes carpetas:
 - **front**: proyecto de front básico que usa el framework [NextJS](https://nextjs.org/). Contiene la infraestructura básica para desplegar esta app.
 - **back**: proyecto de back básico que usa el framework [NestJS](https://nestjs.com/). Contiene la infraestructura básica para desplegar esta app.
 - **core**: infraestructura compartida por los proyectos.


