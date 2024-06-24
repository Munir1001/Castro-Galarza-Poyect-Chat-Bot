const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const fastify = require('fastify')({ logger: true });
const axios = require('axios');
const { Sequelize, DataTypes } = require('sequelize');

// Set up WhatsApp client
const client = new Client({
  puppeteer: {
    executablePath: "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  },
  webVersionCache: {
    type: "remote",
    remotePath: 'https://raw.githubusercontent.com/guigo613/alternative-wa-version/main/html/2.2412.54v2.html',
  },
});

client.on('ready', () => {
  console.log('✅ Client is ready!');
});

client.on("qr", (qr) => {
  qrcode.generate(qr, { small: true });
  console.log('📲 Scan the QR code to connect.');
});

client.initialize().catch((err) => {
  console.error("❌ Error initializing client:", err);
});

// Set up database connection
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: 'database.sqlite'
});

// Define Conversation model
const Conversation = sequelize.define('Conversation', {
  sender: {
    type: DataTypes.STRING,
    allowNull: false
  },
  message: {
    type: DataTypes.STRING,
    allowNull: false
  },
  response: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {});

// Initialize database
(async () => {
  await sequelize.sync({ force: true });
  console.log('📦 Database synced');
})();

// Base URL of the Flask service
const FLASK_BASE_URL = "http://127.0.0.1:5000";

const conversationStates = new Map();  // Map to track conversation state

const handleMessage = async (whatsappNumber, userMessage) => {
  let responseMessage = "Hola Munir";

  if (conversationStates.get(whatsappNumber) === 'finished' && userMessage !== 'Hola Munir') {
    return;  // Do not respond if the conversation is marked as finished and the user hasn't said "Hola Munir"
  }

  if (userMessage === 'Hola Munir') {
    conversationStates.set(whatsappNumber, 'active');  // Reset the conversation state
    responseMessage = "🔍 Por favor, ingresa tu número de cédula y te atenderemos de inmediato.🤗";
  } else if (userMessage.match(/^\d{10}$/)) {
    const { data: users } = await axios.get(`${FLASK_BASE_URL}/users`);
    const user = users.find(u => u.cedula === userMessage);
    if (user) {
      responseMessage = `👋 Bienvenido, ${user.name}!\n😉Selecciona una opción:\n1️⃣ Consultar Productos\n2️⃣ Consultar Servicios\n3️⃣ Consultar Venta\n4️⃣ Consultar Inventario\n5️⃣ Finalizar Conversación\n6️⃣ Generar Reportes`;
    } else {
      responseMessage = "👋 Bienvenido!\nSelecciona una opción:\n1️⃣ Consultar Productos\n2️⃣ Consultar Servicios\n3️⃣ Consultar Venta\n4️⃣ Consultar Inventario\n5️⃣ Finalizar Conversación\n6️⃣ Generar Reportes";
    }
  } else if (userMessage.toLowerCase() === 'gracias munir' || userMessage === '5') {
    responseMessage = "🙏 Gracias por usar nuestro servicio. ¡Hasta pronto!";
    conversationStates.set(whatsappNumber, 'finished');  // Mark conversation as finished
  } else {
    switch (userMessage) {
      case '1':
        const { data: products } = await axios.get(`${FLASK_BASE_URL}/products`);
        responseMessage = "🛒 Productos disponibles:\n";
        products.forEach(product => {
          responseMessage += `- ${product.name}: ${product.description}\n`;
        });
        break;
      case '2':
        const { data: services } = await axios.get(`${FLASK_BASE_URL}/services`);
        responseMessage = "🛠️ Servicios disponibles:\n";
        services.forEach(service => {
          responseMessage += `- ${service.user_name} ofrece ${service.product_name} del ${service.start_date} al ${service.end_date}\n`;
        });
        break;
      case '3':
        responseMessage = "📋 Por favor, ingresa los detalles de la venta (cliente, producto, cantidad) separados por comas.";
        conversationStates.set(whatsappNumber, 'esperando_detalles_venta');
        break;
      case '4':
        const { data: inventory } = await axios.get(`${FLASK_BASE_URL}/inventario/consulta`);
        responseMessage = "📦 Inventario:\n";
        inventory.forEach(item => {
          responseMessage += `- ${item.product_name}: ${item.quantity}\n`;
        });
        break;
      case '5':
        responseMessage = "🙏 Gracias por usar nuestro servicio. ¡Hasta pronto!";
        conversationStates.set(whatsappNumber, 'finished');  // Mark conversation as finished
        break;
        case '6':
  responseMessage = "📊 Generando reportes...\n";
  try {
    // Generar el reporte de ventas por fechas
    const response1 = await axios.get(`${FLASK_BASE_URL}/reportes/ventas/fechas`, { responseType: 'arraybuffer' });
    const ventasPorFechasImage = response1.data;

    // Generar el reporte de productos más vendidos
    const response2 = await axios.get(`${FLASK_BASE_URL}/reportes/productos/mas_vendidos`, { responseType: 'arraybuffer' });
    const productosMasVendidosImage = response2.data;

    // Enviar las imágenes de los reportes al usuario
    await client.sendMessage(whatsappNumber, "📊 Reporte de Ventas por Fechas:");
    await client.sendMessage(whatsappNumber, new MessageMedia('image/png', Buffer.from(ventasPorFechasImage).toString('base64'), 'ventas_por_fechas.png'));
    
    await client.sendMessage(whatsappNumber, "📊 Reporte de Productos Más Vendidos:");
    await client.sendMessage(whatsappNumber, new MessageMedia('image/png', Buffer.from(productosMasVendidosImage).toString('base64'), 'productos_mas_vendidos.png'));

    responseMessage += "✅ Reportes generados y enviados.";
  } catch (error) {
    console.error('Error completo:', error);
    if (error.response && error.response.data) {
      responseMessage += "❌ Error al generar los reportes: " + error.response.data;
    } else {
      responseMessage += "❌ Error al generar los reportes: " + error.message;
    }
  }
  break;
      

      default:
        if (conversationStates.get(whatsappNumber) === 'esperando_detalles_venta') {
          // Verificar si el mensaje tiene el formato correcto
          const ventaDetails = userMessage.split(',').map(item => item.trim());
          if (ventaDetails.length === 3) {
            const [cliente, producto, cantidad] = ventaDetails;
            // Realizar la solicitud POST aquí
            try {
              const response = await axios.post(`${FLASK_BASE_URL}/ventas/solicitud`, {
                cliente,
                producto,
                cantidad: parseInt(cantidad)
              });
              responseMessage = response.data.message;
            } catch (error) {
              responseMessage = "Error al realizar la venta: " + error.response.data.message;
            }
            conversationStates.set(whatsappNumber, 'active');
          } else {
            responseMessage = "Formato incorrecto. Por favor, ingresa los detalles de la venta como: Nombre del cliente, Producto, Cantidad";
          }
        } else {
          responseMessage = "🔍 Por favor, ingresa tu número de cédula y te atenderemos de inmediato.🤗";
        }
        break;
    }
  }

  await sendMessage(whatsappNumber, responseMessage);


  // Store the conversation in the database
  try {
    const conversation = await Conversation.create({
      sender: whatsappNumber,
      message: userMessage,
      response: responseMessage
    });
    fastify.log.info(`💾 Conversation #${conversation.id} stored in database`);
  } catch (e) {
    fastify.log.error(`❌ Error storing conversation in database: ${e}`);
  }

  return responseMessage;
};

// Function to send WhatsApp messages
async function sendMessage(number, message) {
  await client.sendMessage(number, message);
}

const messageTimestamps = new Map();
const processedMessages = new Set();

client.on('message_create', async message => {
  const now = Date.now();
  const lastMessageTime = messageTimestamps.get(message.from) || 0;
  if (now - lastMessageTime < 1000) { // 1 segundo de cooldown
    return;
  }
  messageTimestamps.set(message.from, now);

  if (message.fromMe || processedMessages.has(message.id.id)) {
    return;
  }
  processedMessages.add(message.id.id);

  const whatsappNumber = message.from;
  const userMessage = message.body;

  // Handle the message
  await handleMessage(whatsappNumber, userMessage);
});

// Start the Fastify server
const start = async () => {
  try {
    await fastify.listen({ port: 3000 });
    fastify.log.info(`🚀 Server listening at http://localhost:3000`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
