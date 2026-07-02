# Workshop: GitHub Copilot + OWASP ZAP (DAST)

> Guia general del workshop. Detalla objetivos, agenda y modulos.

## Duracion

2 a 3 horas.

## Publico objetivo

- Desarrolladores.
- Ingenieros DevOps / DevSecOps.
- Personas interesadas en integrar seguridad en su pipeline con ayuda de IA.

## Objetivos de aprendizaje

Al finalizar el workshop, el participante sera capaz de:

1. Levantar una aplicacion vulnerable en un entorno local controlado.
2. Comprender el rol de DAST dentro de un pipeline DevSecOps.
3. Usar GitHub Copilot para acelerar la creacion de configuraciones,
   workflows y remediaciones relacionadas con seguridad.
4. Preparar la base para integrar OWASP ZAP y GitHub Actions.

## Agenda (alto nivel)

| Modulo | Tema                                                     |
| ------ | -------------------------------------------------------- |
| 1      | Introduccion a DevSecOps y DAST.                         |
| 2      | Preparacion del entorno (este laboratorio - etapa 1).    |
| 3      | Integracion de OWASP ZAP (etapa 2).                      |
| 4      | Automatizacion con GitHub Actions (etapa 2).             |
| 5      | Remediacion asistida por GitHub Copilot (etapa 2).       |

## Estado actual del laboratorio

- [x] Etapa 1: aplicacion vulnerable operativa con Docker Compose.
- [x] Etapa 2a: escaneo local con OWASP ZAP (baseline / full).
- [x] Etapa 2b: workflow de GitHub Actions `dast` (baseline / full / schedule).
- [ ] Etapa 2c: remediacion asistida por GitHub Copilot.
- [ ] Etapa 2d: publicacion de SARIF en la pestana Security (opcional).
