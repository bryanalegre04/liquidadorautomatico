# Liquidación de Inventario

Página web (un solo archivo `index.html`) para calcular las liquidaciones de inventario de los camiones a partir del PDF **"Acuerdo de liquidación de inventario"**.

## Funciones

- Importa uno o varios PDF (arrastrar y soltar) y separa **Productos**, **Bloqueados** y **Vacíos** (trae vs. pide).
- Guarda las liquidaciones **por periodo (mes)**.
- Calcula el saldo de envases en S/ (Botella, Caja Plast, Bot). Los precios se pueden editar.
- Muestra un resumen de cada liquidación y del periodo, por conductor, con botón **Copiar resumen**.
- Exporta a **Excel (.xlsx)**, con respaldo y restauración en JSON.
- **Supabase**: datos compartidos en tiempo real, modo lectura para los demás y registro de actividad.

## Publicar en GitHub Pages

1. Sube el contenido de esta carpeta a un repositorio.
2. Ve a **Settings → Pages → Source: Deploy from a branch**, elige `main` y la carpeta `/ (root)`, y guarda.
3. La página quedará en `https://<tu-usuario>.github.io/<repositorio>/`.

> Si el repositorio es **público**, cualquiera puede ver el código. Solo puede editar datos quien tenga usuario en Supabase.

## Configurar Supabase

1. En **SQL Editor**, ejecuta `supabase/supabase_liquidaciones.sql`.
2. En **Authentication → Users → Add user**, crea los usuarios que podrán subir.
3. En **Authentication → Sign In / Providers**, desactiva **Allow new users to sign up**.
4. En **Project Settings → API**, copia la **Project URL** y la **anon public key**. Tienes dos opciones:
   - Pegarlas en `index.html` dentro de `SUPABASE_CONFIG` (busca `SUPABASE_CONFIG = {`). Así todos quedan conectados automáticamente.
   - O ingresarlas desde el botón **⚙️ Conexión** de la página. Solo queda guardado en ese navegador.

> Nunca pongas la clave `service_role` en el archivo.

## Notas

- El lector de PDF (pdf.js) y el generador de Excel (ExcelJS) van incluidos dentro del archivo.
- La conexión a Supabase usa `@supabase/supabase-js@2.45.4` desde jsDelivr, así que necesita internet. Sin internet, la página funciona con los datos guardados en ese equipo.
