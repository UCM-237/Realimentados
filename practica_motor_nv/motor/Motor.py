import serial
import struct
import csv
import sys
import time
import collections
from datetime import datetime
import pyqtgraph as pg
from pyqtgraph.Qt import QtCore, QtWidgets

# --- CONFIGURACIÓN ---
PUERTO = '/dev/ttyACM0'      # ¡Recuerda cambiarlo al tuyo!
BAUDIOS = 115200

class MotorDashboard(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Motor Dashboard")
        self.resize(1100, 700)

        #___ Configuración del puerto serial ___
        try:
            self.serial_port = serial.Serial(PUERTO, BAUDIOS, timeout=0.01)
        except Exception as e:
            print(f"Error al abrir el puerto {PUERTO}: {e}")
            sys.exit(1)
    
        #Datos en bloques de 1000 para la gráfica
        self.time_buffer = collections.deque(maxlen=1000) # Buffer para tiempo
        self.position_buffer = collections.deque(maxlen=1000) # Buffer para posición real medida por el encoder
        self.speed_buffer = collections.deque(maxlen=1000) # Buffer para velocidad real medida por el encoder
        self.speed_est_buffer = collections.deque(maxlen=1000) # Buffer para velocidad estimada por el observador
    
        #___ Variables para guardar los datos en un archivo CSV___
        self.is_recording = False
        self.recorded_data = [] #lista para guardar [Tiempo, PWM, Encoder]
        self.record_start_time = 0.0
        self.current_pwm = 0 #guarda el valor actual del PWM para la columna del CSV
        self.current_dir = 1 #guarda el sentido actual del motor (1 alante o 0 atras))
        #___ Configuración de la interfaz gráfica ___
        main_widget = QtWidgets.QWidget()
        self.setCentralWidget(main_widget)
        layout = QtWidgets.QVBoxLayout(main_widget)

        # A1) Gráfica para mostrar la posición del encoder en tiempo real
        self.plot_pos = pg.PlotWidget(title="Posición del encoder")
        self.plot_pos.showGrid(x=True, y=True)
        self.plot_pos.setLabel('left', 'Posición', units='grados')
        self.plot_pos.setLabel('bottom', 'Tiempo', units='s')
        self.curve_pos = self.plot_pos.plot(pen=pg.mkPen(color='y', width=2))
        layout.addWidget(self.plot_pos) # Añadimos la gráfica de posición arriba

        # A2) Gráfica para mostrar la velocidad en tiempo real
        self.plot_speed = pg.PlotWidget(title="Velocidad del motor")
        self.plot_speed.showGrid(x=True, y=True)
        self.plot_speed.setLabel('left', 'Velocidad', units='grados/s')
        self.plot_speed.setLabel('bottom', 'Tiempo', units='s')
        self.curve_speed = self.plot_speed.plot(pen=pg.mkPen(color='c', width=2)) # Cyan
        self.curve_speed_est = self.plot_speed.plot(pen=pg.mkPen(color='m', width=2, style=QtCore.Qt.DashLine)) # Magenta punteada para velocidad estimada
        layout.addWidget(self.plot_speed) # Añadimos la gráfica de velocidad justo debajo
        #B Controles PWM
        controls = QtWidgets.QHBoxLayout()
        self.spin = QtWidgets.QSpinBox()
        self.spin.setRange(0, 1000)
        self.spin.setPrefix("PWM: ")
        
        self.btn_send = QtWidgets.QPushButton("Enviar PWM")
        self.btn_send.setStyleSheet("background-color: #4caf50; color: white; font-weight: Bold; padding: 10px;")

        #C Botón sentido de giro
        self.btn_dir = QtWidgets.QPushButton("Sentido: Adelante")
        self.btn_dir.setCheckable(True)
        self.btn_dir.setStyleSheet("font-weight: Bold;")
    
        #botón grabación datos
        self.btn_record = QtWidgets.QPushButton("Grabación Datos")
        self.btn_record.setCheckable(True)
        self.btn_record.setStyleSheet("background-color: #f44336; color: white; font-weight: Bold; padding: 10px;")
    
        #botón de reset
        self.btn_cero = QtWidgets.QPushButton("Reset Posición")
        self.btn_cero.setStyleSheet("background-color: #9e9e9e; color: white; font-weight: Bold; padding: 10px;") 
        self.btn_cero.clicked.connect(self.set_zero_position) # Conectar el botón de reset a su función
        
        controls.addWidget(self.spin)
        controls.addWidget(self.btn_send)
        controls.addWidget(self.btn_dir)
        controls.addWidget(self.btn_record)
        controls.addWidget(self.btn_cero)
        layout.addLayout(controls)

        #Controles automáticos (PID y Espacio de Estados)
        auto_controls = QtWidgets.QHBoxLayout()
        
        #Posición
        self.spin_pos = QtWidgets.QSpinBox()
        self.spin_pos.setRange(-3600, 3600) #rango de posición en grados (hasta 10 vueltas completas)
        self.spin_pos.setPrefix("Consigna Posición: ")
        self.spin_pos.setSuffix("°")

        self.bnt_pos = QtWidgets.QPushButton("Ir a posición PID")
        self.bnt_pos.setStyleSheet("background-color: #2196f3; color: white; font-weight: Bold; padding: 10px;")     

        self.bnt_pos_ss = QtWidgets.QPushButton("Ir a posición Espacio de Estados")
        self.bnt_pos_ss.setStyleSheet("background-color: #ff9800; color: white; font-weight: Bold; padding: 10px;") 


        #Velocidad
        self.spin_speed = QtWidgets.QSpinBox()
        self.spin_speed.setRange(-2000, 2000) #rango de velocidad (hay que probarlo para ajustar bien
        self.spin_speed.setPrefix("Consigna Velocidad: ")
        self.spin_speed.setSuffix("°/s")

        self.btn_speed = QtWidgets.QPushButton("Enviar consigna Velocidad")
        self.btn_speed.setStyleSheet("background-color: #9c27b0; color: white; font-weight: Bold; padding: 10px;") 

        self.btn_speed_ss = QtWidgets.QPushButton("Velocidad Espacio de Estados")
        self.btn_speed_ss.setStyleSheet("background-color: #ff9800; color: white; font-weight: Bold; padding: 10px;")
        
        #add to layout
        auto_controls.addWidget(self.spin_pos)
        auto_controls.addWidget(self.bnt_pos)
        auto_controls.addWidget(self.bnt_pos_ss)
        auto_controls.addWidget(self.spin_speed)
        auto_controls.addWidget(self.btn_speed)
        auto_controls.addWidget(self.btn_speed_ss)
        layout.addLayout(auto_controls)

        #Eventos de los botones
        self.btn_send.clicked.connect(self.send_pwm)
        self.btn_dir.toggled.connect(self.toggle_direction)
        self.btn_record.toggled.connect(self.toggle_recording)

        #Eventos de los botones de control automático
        self.bnt_pos.clicked.connect(self.send_position_setpoint)
        self.bnt_pos_ss.clicked.connect(self.send_position_ss)
        self.btn_speed.clicked.connect(self.send_speed_setpoint)
        self.btn_speed_ss.clicked.connect(self.send_speed_ss)
    
        # Temporizador
        self.timer = QtCore.QTimer()
        self.timer.timeout.connect(self.read_serial)
        self.timer.start(10)  # Leer cada 10 ms
        

    def read_serial(self):
        # Ahora esperamos 20 bytes en lugar de 16
        while self.serial_port.in_waiting >= 20:
            paquete = self.serial_port.read(20)
            try:
                # Desempaquetar: ID(int), Tiempo(int), Pos(int), Vel(float), Vel_Est(float)
                id_paquete, valor1, posicion, velocidad, velocidad_est = struct.unpack('<iiiff', paquete)
                
                if id_paquete not in [1, 2]:
                    print(f"¡Desincronizado! ID recibido: {id_paquete}. Vaciando basura...")
                    self.serial_port.read(self.serial_port.in_waiting)
                    return 
                
                if id_paquete == 2:  # Datos de telemetría
                    tiempo = valor1 / 1000.0  # Convertir ms a segundos
                    
                    self.time_buffer.append(tiempo)
                    self.position_buffer.append(posicion)
                    self.speed_buffer.append(velocidad)
                    self.speed_est_buffer.append(velocidad_est) # <--- GUARDAMOS EL NUEVO DATO

                    # Actualizar las gráficas
                    self.curve_pos.setData(list(self.time_buffer), list(self.position_buffer))
                    self.curve_speed.setData(list(self.time_buffer), list(self.speed_buffer))
                    self.curve_speed_est.setData(list(self.time_buffer), list(self.speed_est_buffer)) # <--- DIBUJAMOS LA CURVA ROJA
                    
                    if self.is_recording:
                        pwm_con_signo = self.current_pwm if self.current_dir == 1 else -self.current_pwm
                        # Guardamos también la vel. estimada en el CSV
                        self.recorded_data.append([round(tiempo, 4), pwm_con_signo, posicion, velocidad, velocidad_est]) 
                        
                elif id_paquete == 1:  # Sincronización de dirección
                    self.sync_direction_ui(valor1)
                    
            except struct.error: 
                # Si el paquete no tiene el formato correcto, ignorarlo
                pass
        
    def send_pwm(self):
        self.current_pwm = self.spin.value()
        paquete = struct.pack('<ii', 2, self.current_pwm)  # ID=2 para PWM
        self.serial_port.write(paquete)
        print(f"Enviado PWM: {self.current_pwm}")
    
    # --- comandos PID ----
    def send_position_setpoint(self):
        setpoint_pos = self.spin_pos.value()
        paquete = struct.pack('<ii', 3, setpoint_pos)  # ID=3 para consigna de posición
        self.serial_port.write(paquete)
        print(f"Enviado setpoint posición: {setpoint_pos}°") 

    def send_speed_setpoint(self):
        setpoint_speed = self.spin_speed.value()
        paquete = struct.pack('<ii', 4, setpoint_speed)  # ID=4 para consigna de velocidad
        self.serial_port.write(paquete)
        print(f"Enviado setpoint velocidad: {setpoint_speed}°/s")
    
    # --- comandos Espacio de Estados ---
    def send_position_ss(self):
        setpoint_pos = self.spin_pos.value()
        paquete = struct.pack('<ii', 6, setpoint_pos)  # ID=6 para consigna de posición espacio de estados
        self.serial_port.write(paquete)
        print(f"Enviado setpoint posición (SS): {setpoint_pos}°")
    
    def send_speed_ss(self):
        setpoint_speed = self.spin_speed.value()
        paquete = struct.pack('<ii', 7, setpoint_speed)  # ID=7 para consigna de velocidad espacio de estados
        self.serial_port.write(paquete)
        print(f"Enviado setpoint velocidad (SS): {setpoint_speed}°/s")
    
    def toggle_direction(self):
        """cambia el sentido del motor y actualiza el botón"""
        if self.btn_dir.isChecked():
            self.current_dir = 0  # Atrás
            self.btn_dir.setText("Sentido: Atrás")
            self.btn_dir.setStyleSheet("background-color: #2196f3; color: white; font-weight: Bold; padding: 10px;")
        else:
            self.current_dir = 1  # Adelante
            self.btn_dir.setText("Sentido: Adelante")
            self.btn_dir.setStyleSheet("background-color: #4caf50; color: white; font-weight: Bold; padding: 10px;")
        
        paquete = struct.pack('<ii', 1, self.current_dir)  # ID=1 para dirección
        self.serial_port.write(paquete)
        print(f"Enviado ID:1 (DIR), Valor:{self.current_dir}")

    def sync_direction_ui(self, estado):
        """Sincroniza el botón de dirección con el estado recibido del microcontrolador"""
        self.btn_dir.blockSignals(True)  # Evita que el cambio de estado dispare el evento toggle_direction
        if int(estado) == 0:
            self.current_dir = 0
            self.btn_dir.setChecked(True)
            self.btn_dir.setText("Sentido: Atras")
            self.btn_dir.setStyleSheet("background-color: #2196f3; color: white; font-weight: Bold; padding: 10px;")
        else:
            self.current_dir = 1
            self.btn_dir.setChecked(False)
            self.btn_dir.setText("Sentido: Adelante")
            self.btn_dir.setStyleSheet("background-color: #4caf50; color: white; font-weight: Bold; padding: 10px;")
        self.btn_dir.blockSignals(False)
        print(f"Sincronizado sentido físico: {estado}")
 
        
    def toggle_recording(self):
        """Inicia o detiene la grabación de datos para el CSV"""
        if self.btn_record.isChecked():
            self.recorded_data = []  # Limpiar datos anteriores
            self.is_recording = True
            self.btn_record.setText("Detener y guardar")
            self.btn_record.setStyleSheet("font-weight: Bold;")
        else:
            self.is_recording = False
            self.btn_record.setText("Grabación Datos")
            self.btn_record.setStyleSheet("font-weight: Bold;")
            self.save_csv()
    
    def save_csv(self):
        if not self.recorded_data: return
        nombre = f"registro_motor_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        with open(nombre, 'w', newline='') as f:
            writer = csv.writer(f)
            # Añadimos la columna al final
            writer.writerow(["Tiempo (s)", "PWM (con signo)", "Posición (grados)","Velocidad (grados/s)", "Vel_Estimada (grados/s)"])
            writer.writerows(self.recorded_data)
        print(f"Datos guardados en {nombre}")

    def closeEvent(self, event):
        """Cierra el puerto serial al cerrar la aplicación"""
        if self.serial_port.is_open:
            paquete_parada = struct.pack('<ii', 2, 0) # ID 2 (PWM), Valor 0
            self.serial_port.write(paquete_parada)
            self.serial_port.close()
        event.accept()
    def set_zero_position(self):
        if hasattr(self, 'serial_port') and self.serial_port.is_open:
            try:
                # --- 1. DETENER EL MOTOR PRIMERO ---
                # Mandamos consigna de velocidad 0 al Espacio de Estados (ID=7)
                paquete_stop = struct.pack('<ii', 7, 0) 
                self.serial_port.write(paquete_stop)
                self.spin_speed.setValue(0) # Actualizamos la cajita de la interfaz
                
                # Le damos 100 milisegundos para que el motor frene físicamente
                time.sleep(0.1) 
                
                # --- 2. Enviar la orden al STM32 para resetear el encoder
                paquete = struct.pack('<ii', 5, 0)
                self.serial_port.write(paquete)
                print("¡Motor detenido y Posición reseteada a CERO!")
                
                # --- 3. SINCRONIZAR LA INTERFAZ DE PYTHON ---
                self.time_buffer.clear() 
                self.position_buffer.clear() 
                self.speed_buffer.clear() 
                self.speed_est_buffer.clear() 
                
                self.spin_pos.setValue(0) 
                
            except Exception as e:
                print(f"Error al enviar el comando de cero: {e}")
if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    dashboard = MotorDashboard()
    dashboard.show()
    sys.exit(app.exec_())