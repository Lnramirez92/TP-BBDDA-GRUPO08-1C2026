# ABM Parques — Entrega 9.3

Aplicación Flask para ABM sobre `GestionParques.Parque`, vía los SPs `Parque_Alta`,
`Parque_Modificar` y `Parque_Baja`.

## Instalación

```bash
pip install flask pyodbc
```

## Configuración

Editar `DB_CONFIG` en `app.py`:

```python
DB_CONFIG = {
    "DRIVER": "{ODBC Driver 17 for SQL Server}",
    "SERVER": "NOMBRE_PC\\SQLEXPRESS",
    "DATABASE": "ParquesNacionales",
    "USE_WINDOWS_AUTH": True,   # False si usás usuario/contraseña SQL
    "UID": "sa",
    "PWD": "TuPasswordAqui",
}
```

## Ejecución

```bash
python app.py
```

Abrir: http://localhost:5000

(La carpeta `templates/` con `index.html` debe estar junto a `app.py`)
