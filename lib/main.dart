import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Importa la biblioteca para gráficos
import 'mqtt_service.dart'; // Importa el servicio MQTT

void main() {
  runApp(const MyApp()); // Llama a runApp para iniciar la aplicación
}

// MyApp es un widget Stateless que define la estructura general de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Fluid Level Chart App', // Título de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema principal de la aplicación
      ),
      home:
          const FluidLevelChartScreen(), // Define FluidLevelChartScreen como la pantalla principal
    );
  }
}

// FluidLevelChartScreen es un StatefulWidget que mostrará el gráfico de barras de nivel de fluidos
class FluidLevelChartScreen extends StatefulWidget {
  const FluidLevelChartScreen({super.key});

  @override
  FluidLevelChartScreenState createState() =>
      FluidLevelChartScreenState(); // Crea el estado asociado a este widget
}

// _FluidLevelChartScreenState contiene el estado del widget FluidLevelChartScreen
class FluidLevelChartScreenState extends State<FluidLevelChartScreen> {
  late MqttService _mqttService; // Declaración del servicio MQTT
  final List<FluidLevelData> _data =
      []; // Lista para almacenar los datos de nivel de fluidos
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    super.initState();
    // Inicializa el servicio MQTT con el broker y el clientId
    _mqttService = MqttService('broker.emqx.io', '');
    // Escucha el stream de nivel de fluidos y actualiza el estado cuando llegue un nuevo valor
    _mqttService.getFluidLevelStream().listen((fluidLevel) {
      setState(() {
        _data.add(FluidLevelData(
            DateTime.now(), fluidLevel)); // Añade los nuevos datos a la lista
        // Limita el número de puntos en el gráfico a 20
        if (_data.length > 20) {
          _data.removeAt(0);
        }
        _chartSeriesController.updateDataSource(
            addedDataIndex: _data.length - 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Fluid Level Chart'), // Título de la barra de la aplicación
      ),
      body: Center(
        // Contenedor principal de la pantalla
        child: SfCartesianChart(
          // Widget para mostrar el gráfico de barras
          primaryXAxis: DateTimeAxis(), // Configura el eje X como eje de tiempo
          series: <ColumnSeries<FluidLevelData, DateTime>>[
            ColumnSeries<FluidLevelData, DateTime>(
              onRendererCreated: (ChartSeriesController controller) {
                _chartSeriesController = controller;
              },
              dataSource: _data, // Define la fuente de datos para el gráfico
              xValueMapper: (FluidLevelData data, _) =>
                  data.time, // Mapea los valores de X
              yValueMapper: (FluidLevelData data, _) =>
                  data.fluidLevel, // Mapea los valores de Y
            )
          ],
        ),
      ),
    );
  }
}

// Clase para representar los datos de nivel de fluidos
class FluidLevelData {
  FluidLevelData(this.time, this.fluidLevel);
  final DateTime time; // Tiempo en el que se recibió el nivel de fluidos
  final double fluidLevel; // Valor del nivel de fluidos
}
