from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
from flask import Flask, request, jsonify
import psycopg2
from psycopg2.extras import RealDictCursor
import matplotlib
matplotlib.use('Agg')  # Uso del backend 'Agg', que no necesita la GUI
import matplotlib.pyplot as plt

app = Flask(__name__)

# Lista para almacenar los números de teléfono de los usuarios registrados
usuarios_registrados = []


# Función para establecer la conexión con la base de datos
def get_db_connection():
    conn = psycopg2.connect(
        host="localhost", database="ChatBot", user="postgres", password="1001"
    )
    return conn


# Ruta para obtener todos los usuarios
@app.route("/users", methods=["GET"])
def get_users():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM users;")
    users = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(users)


@app.route("/products", methods=["GET"])
def get_products():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("SELECT * FROM products;")
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(products)


# Ruta para obtener todos los servicios
@app.route("/services", methods=["GET"])
def get_services():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute(
        """
        SELECT s.id, u.name as user_name, p.name as product_name, s.start_date, s.end_date
        FROM services s
        JOIN users u ON s.user_id = u.id
        JOIN products p ON s.product_id = p.id;
    """
    )
    services = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(services)



# Ruta para recibir solicitudes de información para ventas
@app.route("/ventas/solicitud", methods=["POST"])
def recibir_solicitud_venta():
    data = request.json
    cliente = data.get("cliente")
    producto = data.get("producto")
    cantidad = data.get("cantidad")

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute('SELECT id, quantity FROM inventory WHERE product_id = (SELECT id FROM products WHERE name = %s)', (producto,))
    result = cursor.fetchone()
    
    if result:
        producto_id, stock_disponible = result
        if cantidad <= stock_disponible:
            servicio_disponible = True  # Supongamos que el servicio siempre está disponible

            if servicio_disponible:
                nuevo_stock = stock_disponible - cantidad
                cursor.execute('UPDATE inventory SET quantity = %s WHERE product_id = %s', (nuevo_stock, producto_id))
                conn.commit()

                fecha_hora_venta = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                cursor.execute('INSERT INTO ventas (cliente, producto_id, cantidad, fecha_hora_venta) VALUES (%s, %s, %s, %s)',
                               (cliente, producto_id, cantidad, fecha_hora_venta))
                conn.commit()

                response = {"message": f"✅ Venta realizada: {cantidad} unidades 🛒 de {producto} 📦 vendidas al cliente {cliente} 🤝"}
                status_code = 200
            else:
                response = {"message": "❌ El servicio no está disponible en este momento"}
                status_code = 400
        else:
            response = {"message": f"No hay suficiente stock 📉 disponible para vender {cantidad} unidades 🛒 de {producto} 📦"}
            status_code = 400
    else:
        response = {"message": f"No se encontró el producto {producto} 📦 en la base de datos"}
        status_code = 404

    cursor.close()
    conn.close()

    return jsonify(response), status_code


# Ruta para consultar información de inventario en tiempo real
@app.route("/inventario/consulta", methods=["GET"])
def consultar_inventario():
    # Conectarse a la base de datos
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Consultar la información de inventario
    cursor.execute("SELECT inventory.id, products.name AS product_name, inventory.quantity FROM inventory INNER JOIN products ON inventory.product_id = products.id;")
    inventario = cursor.fetchall()

    # Cerrar cursor y conexión
    cursor.close()
    conn.close()

    # Formatear la respuesta en un diccionario
    response_data = [{"product_name": item['product_name'], "quantity": item['quantity']} for item in inventario]

    return jsonify(response_data), 200



@app.route("/reportes/ventas/fechas", methods=["GET"])
def generar_reporte_ventas_fechas():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("""
        SELECT DATE(fecha_hora_venta) AS fecha, COUNT(*) AS total_ventas
        FROM ventas
        GROUP BY DATE(fecha_hora_venta)
        ORDER BY fecha;
    """)
    ventas_por_fecha = cursor.fetchall()
    cursor.close()
    conn.close()

    fechas = [venta['fecha'].strftime("%Y-%m-%d") for venta in ventas_por_fecha]
    total_ventas = [venta['total_ventas'] for venta in ventas_por_fecha]

    plt.figure(figsize=(12, 6))
    bars = plt.bar(fechas, total_ventas)
    plt.xlabel('Fecha')
    plt.ylabel('Total de Ventas')
    plt.title('Reporte de Ventas por Fechas')
    plt.xticks(rotation=45, ha='right')

    # Añadir las cantidades dentro de las barras
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2., height,
                 f'{height}',
                 ha='center', va='bottom')

    plt.tight_layout()

    nombre_archivo = 'ventas_por_fechas.png'
    plt.savefig(nombre_archivo)
    plt.close()

    with open(nombre_archivo, 'rb') as f:
        imagen = f.read()
    return imagen, 200, {'Content-Type': 'image/png'}



@app.route("/reportes/productos/mas_vendidos", methods=["GET"])
def generar_reporte_productos_mas_vendidos():
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    cursor.execute("""
        SELECT p.name AS product_name, SUM(v.cantidad) AS total_vendido
        FROM ventas v
        JOIN products p ON v.producto_id = p.id
        GROUP BY p.name
        ORDER BY total_vendido DESC
        LIMIT 10;
    """)
    productos_mas_vendidos = cursor.fetchall()
    cursor.close()
    conn.close()

    productos = [producto['product_name'] for producto in productos_mas_vendidos]
    cantidades = [producto['total_vendido'] for producto in productos_mas_vendidos]

    plt.figure(figsize=(12, 6))
    bars = plt.bar(productos, cantidades)
    plt.xlabel('Producto')
    plt.ylabel('Cantidad Total Vendida')
    plt.title('Productos Más Vendidos')
    plt.xticks(rotation=45, ha='right')

    # Añadir las cantidades dentro de las barras
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2., height/2,
                 f'{int(height)}',
                 ha='center', va='center')

    plt.tight_layout()

    nombre_archivo = 'productos_mas_vendidos.png'
    plt.savefig(nombre_archivo)
    plt.close()

    with open(nombre_archivo, 'rb') as f:
        imagen = f.read()
    return imagen, 200, {'Content-Type': 'image/png'}

if __name__ == "__main__":
    app.run(debug=True)
