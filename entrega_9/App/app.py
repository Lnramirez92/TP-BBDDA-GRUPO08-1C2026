"""
================================================================================================
UNIVERSIDAD: Universidad Nacional de La Matanza (UNLaM)
ASIGNATURA: 3641 - Bases de Datos Aplicada
GRUPO: 08
INTEGRANTES: Kevin Maykel Valverde Pinedo, Maximo Carabajal, Nicolás Veliz Fandiño, Leonardo Nicolas Ramirez
FECHA: Junio 2026
OBJETIVO/DESCRIPCION: Entrega 9.3 - Aplicación sencilla en Python (Flask) para realizar
operaciones ABM (Alta, Baja, Modificación) sobre la tabla GestionParques.Parque.

La aplicación NO accede directamente a las tablas: toda operación de escritura se realiza
a través de los Stored Procedures ya existentes en la base de datos
(GestionParques.Parque_Alta, Parque_Modificar, Parque_Baja), respetando la consigna de que
ninguna operación ABM debe tocar las tablas directamente.
================================================================================================
"""

from flask import Flask, render_template, request, redirect, url_for, flash
import pyodbc

app = Flask(__name__)
app.secret_key = "parques-nacionales-unlam-2026"

# ================================================================================================
# CONFIGURACIÓN DE CONEXIÓN
# Ajustar según el entorno local. Usar Windows Auth (Trusted_Connection) es lo más común
# cuando se trabaja contra una instancia local de SQL Server Express.
# ================================================================================================
DB_CONFIG = {
    "DRIVER": "{ODBC Driver 17 for SQL Server}",
    "SERVER": "DESKTOP-RJUE5H3\\SQLEXPRESS",   # nombre de tu instancia (doble backslash en Python)
    "DATABASE": "ParquesNacionales",
    "USE_WINDOWS_AUTH": True,        # True = autenticación de Windows, False = usuario/contraseña SQL
    "UID": "usr_admin",                     # solo se usa si USE_WINDOWS_AUTH = False
    "PWD": "Admin2026",         # solo se usa si USE_WINDOWS_AUTH = False
}


def get_connection():
    if DB_CONFIG["USE_WINDOWS_AUTH"]:
        conn_str = (
            f"DRIVER={DB_CONFIG['DRIVER']};"
            f"SERVER={DB_CONFIG['SERVER']};"
            f"DATABASE={DB_CONFIG['DATABASE']};"
            f"Trusted_Connection=yes;"
        )
    else:
        conn_str = (
            f"DRIVER={DB_CONFIG['DRIVER']};"
            f"SERVER={DB_CONFIG['SERVER']};"
            f"DATABASE={DB_CONFIG['DATABASE']};"
            f"UID={DB_CONFIG['UID']};"
            f"PWD={DB_CONFIG['PWD']};"
        )
    conn_str += "TrustServerCertificate=yes;"
    return pyodbc.connect(conn_str)


# ================================================================================================
# RUTAS
# ================================================================================================

@app.route("/")
def index():
    """Lista todos los parques (incluye tipo de parque para mostrar la descripción)."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT p.id_parque, p.nombre, p.ubicacion, p.superficie,
               tp.descripcion AS tipo_parque, p.activo
        FROM GestionParques.Parque p
        JOIN GestionParques.Tipo_Parque tp ON p.id_tipo_parque = tp.id_tipo_parque
        ORDER BY p.id_parque
    """)
    parques = cursor.fetchall()

    cursor.execute("SELECT id_tipo_parque, descripcion FROM GestionParques.Tipo_Parque")
    tipos = cursor.fetchall()

    conn.close()
    return render_template("index.html", parques=parques, tipos=tipos)


@app.route("/parque/alta", methods=["POST"])
def parque_alta():
    """Da de alta un parque ejecutando el SP GestionParques.Parque_Alta."""
    nombre = request.form["nombre"]
    ubicacion = request.form["ubicacion"]
    superficie = request.form["superficie"]
    id_tipo_parque = request.form["id_tipo_parque"]

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "EXEC GestionParques.Parque_Alta ?, ?, ?, ?",
            nombre, ubicacion, superficie, id_tipo_parque
        )
        conn.commit()
        flash(f"Parque '{nombre}' creado correctamente.", "success")
    except pyodbc.Error as e:
        # El mensaje del THROW del SP llega aquí; se muestra tal cual al usuario
        flash(f"Error al crear el parque: {extraer_mensaje_error(e)}", "danger")
    finally:
        conn.close()

    return redirect(url_for("index"))


@app.route("/parque/modificar", methods=["POST"])
def parque_modificar():
    """Modifica un parque ejecutando el SP GestionParques.Parque_Modificar."""
    id_parque = request.form["id_parque"]
    nombre = request.form["nombre"]
    ubicacion = request.form["ubicacion"]
    superficie = request.form["superficie"]
    id_tipo_parque = request.form["id_tipo_parque"]

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            "EXEC GestionParques.Parque_Modificar ?, ?, ?, ?, ?",
            id_parque, nombre, ubicacion, superficie, id_tipo_parque
        )
        conn.commit()
        flash(f"Parque actualizado correctamente.", "success")
    except pyodbc.Error as e:
        flash(f"Error al modificar el parque: {extraer_mensaje_error(e)}", "danger")
    finally:
        conn.close()

    return redirect(url_for("index"))


@app.route("/parque/baja/<int:id_parque>", methods=["POST"])
def parque_baja(id_parque):
    """Da de baja (lógica) un parque ejecutando el SP GestionParques.Parque_Baja."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("EXEC GestionParques.Parque_Baja ?", id_parque)
        conn.commit()
        flash("Parque dado de baja correctamente.", "success")
    except pyodbc.Error as e:
        flash(f"Error al dar de baja el parque: {extraer_mensaje_error(e)}", "danger")
    finally:
        conn.close()

    return redirect(url_for("index"))


def extraer_mensaje_error(error: pyodbc.Error) -> str:
    """Extrae el mensaje legible que viene del THROW del SP, descartando metadatos de ODBC."""
    mensaje = str(error)
    # El mensaje del THROW suele venir luego del último corchete ']'
    if "]" in mensaje:
        mensaje = mensaje.split("]")[-1]
    return mensaje.strip()


if __name__ == "__main__":
    app.run(debug=True, port=5000)