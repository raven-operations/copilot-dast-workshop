# 🖼️ Assets del Workshop

Esta carpeta contiene las imágenes referenciadas desde el [README.md](../README.md) principal.

Las imágenes son **placeholders opcionales**. El workshop funciona perfectamente sin ellas — el README simplemente mostrará el texto alternativo si el archivo no existe.

## Imágenes esperadas

| Archivo               | Descripción sugerida                                                        | Uso en README            |
| --------------------- | --------------------------------------------------------------------------- | ------------------------ |
| `header.png`          | Banner del workshop (título + logos: Copilot, ZAP, Docker, Node.js).        | Encabezado principal.    |
| `app-running.png`     | Screenshot de `docker compose ps` mostrando servicios healthy.              | Paso 🚀.                 |
| `zap-report.png`      | Screenshot del reporte HTML de ZAP abierto en el navegador.                 | Paso 🔍 (1.3).           |
| `copilot-analysis.png` | Screenshot de Copilot Chat generando la tabla de vulnerabilidades.         | Paso 🧠 (2.2).           |
| `proxy-headers.png`   | Screenshot de `curl -I` mostrando los security headers tras el proxy.       | Paso 🛡️ (4.4).           |
| `before-after.png`    | Comparativa lado a lado de dos reportes de ZAP.                              | Paso 🔁 (5.3).           |
| `github-actions.png`  | Screenshot de la pestaña Actions con los workflows DAST corriendo.          | Paso 🤖 (6.4).           |

## Cómo generarlas

Podés capturar los screenshots vos mismo mientras seguís el workshop, o pedirle a Copilot Chat que genere descripciones ASCII para reemplazar las imágenes en el README si preferís un formato 100% texto.

**Prompt sugerido para Copilot:**

```text
Reemplazá cada referencia a imagen en #file:../README.md con un bloque de texto ASCII descriptivo (usando caracteres box-drawing como ┌─┐│└─┘) que ilustre lo que la imagen mostraría, para que el workshop se pueda leer completo sin necesidad de screenshots.
```

## Formato recomendado

- Formato: PNG.
- Ancho máximo: 1200 px.
- Tamaño: idealmente < 300 KB por imagen (comprimí con `pngquant` o similar antes de commitear).
