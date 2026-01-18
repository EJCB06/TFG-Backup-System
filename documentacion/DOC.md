# Esta va a ser la documentación en profundidad sobre el proyecto de automatización de Backups para PYMES.

git config --global user.name "ejcb"
git config --global user.email "ejcbinstituto@gmail.com"

¡Claro que sí! Aquí hay una pequeña confusión común: lo que te sale en la captura roja (Please tell me who you are) no es un error de contraseña, es solo que Git no sabe "quién eres" para poner tu nombre en el historial de cambios.

Pero, para responder a tu pregunta real ("que no me pida credenciales todo el rato"), vamos a matar dos pájaros de un tiro con la solución PRO para TFG: Usar claves SSH también para GitHub.

Sigue estos pasos en orden en tu terminal de VS Code (conectado a SRV-PYME-LOCAL):

PASO 1: Arreglar el error de la foto (Identidad)
Esto es solo etiqueta. Ejecuta esto con tus datos reales (aparecerán en el historial de GitHub):

Bash
git config --global user.name "Tu Nombre Real"
git config --global user.email "tu_email@ejemplo.com"
Ahora, si vuelves a hacer git commit -m "empezamos", ya te dejará.

PASO 2: Configurar GitHub para que NO pida contraseña (SSH)
Para sacar el 10, no uses HTTPS (que pide usuario/token a cada rato). Usa SSH. Así tu máquina se autentica sola con una llave.

1. Generar la llave SSH para GitHub en tu máquina virtual: Ejecuta esto y dale a "Enter" a todo (sin contraseña):

ssh-keygen -t ed25519 -C "ejcbinstituto@gmail.com"