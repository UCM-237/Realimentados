#include "motor.h"
#include <math.h>

MotorControl motor;

extern TIM_HandleTypeDef htim2; // Timer para encoder
extern TIM_HandleTypeDef htim3; // Timer para PWM

// =================================================================
// Definicion de matrices y ganancias para el controlador de 
// espacio de estados.
// ================================================================
#define TS_DSP 0.01f //Periodo de muestreo del controlador (10ms)
#define VMAX_DSP 12.0f  //Voltaje máximo motor

// Matrices del modelo discretizado (A, B, C)
float32_t Ad_f32[4] = {1.0000f, 0.0000f , 0.0000f, 1.0000f}; // Matriz A (2x2)
float32_t Bd_f32[2] = {0.0000f, 0.0000f}; // Matriz B (2x1)
float32_t Cd_f32[2] = {0.0000f, 0.0000f}; // Matriz C (1x2)    

// Ganancias del controlador y observador de espacio de estados
float32_t Lp_f32[2] = {0.0000f, 0.0000f}; //observador de estado (L)
float32_t Kx_pos_f32[2] = {0.0000f, 0.0000f}; // Ganancia para control de posición
float32_t Kx_vel_f32[2] = {0.0000f, 0.0000f}; // Ganancia para control de velocidad

float32_t Ki_pos_f32 = 0.0000f; // Ganancia integral para control de posición
float32_t Ki_vel_f32 = 0.0000f; // Ganancia integral para control de velocidad

// Objetos (instancias) matrices de CMSIS-DSP
arm_matrix_instance_f32 Ad_mat, Bd_mat, Cd_mat, Lp_mat, Kx_pos_mat, Kx_vel_mat;
arm_matrix_instance_f32 x_hat_mat, y_hat_mat;
arm_matrix_instance_f32 temp1_mat, temp2_mat, temp3_mat;

float32_t y_hat_f32[1] = {0.0f}; 
float32_t temp1_f32[2], temp2_f32[2], temp3_f32[2];


// =================================================================
// INICIALIZACIÓN
// =================================================================
void MotorControl_Init(void){
    // 1. Controles PID posición
    motor.pid_position.Kp = 0.0f;
    motor.pid_position.Ki = 0.0f;
    motor.pid_position.Kd = 0.0f;
    arm_pid_init_f32(&motor.pid_position,1); 
    
    // Controles PID velocidad
    motor.pid_speed.Kp = 0.0f;
    motor.pid_speed.Ki = 0.0f;
    motor.pid_speed.Kd = 0.0f;
    arm_pid_init_f32(&motor.pid_speed,1); 
    
    // 2. Inicializar el estado del motor
    motor.mode = Control_pwm_openloop; 
    motor.posicion_actual = 0;
    motor.posicion_anterior = 0;
    motor.velocidad_actual = 0.0f;
    motor.setpoint_position = 0;
    motor.setpoint_speed = 0.0f;
    motor.pwm_output = 0.0f;

    // 3. Inicializar variables dinámicas espacio de estados
    motor.x_hat[0] = 0.0f; //posición estimada
    motor.x_hat[1] = 0.0f; //velocidad estimada
    motor.x_integral_pos = 0.0f; 
    motor.x_integral_speed = 0.0f; 

    // 4. Vincular matrices CMSIS-DSP
    arm_mat_init_f32(&Ad_mat, 2, 2, Ad_f32);
    arm_mat_init_f32(&Bd_mat, 2, 1, Bd_f32);
    arm_mat_init_f32(&Cd_mat, 1, 2, Cd_f32);
    arm_mat_init_f32(&Lp_mat, 2, 1, Lp_f32);
    arm_mat_init_f32(&Kx_pos_mat, 1, 2, Kx_pos_f32);
    arm_mat_init_f32(&Kx_vel_mat, 1, 2, Kx_vel_f32);
    
    // Matrices temporales para cálculos
    arm_mat_init_f32(&x_hat_mat, 2, 1, motor.x_hat);
    arm_mat_init_f32(&y_hat_mat, 1, 1, y_hat_f32); 
    arm_mat_init_f32(&temp1_mat, 2, 1, temp1_f32);
    arm_mat_init_f32(&temp2_mat, 2, 1, temp2_f32);
    arm_mat_init_f32(&temp3_mat, 2, 1, temp3_f32);
}

// Funciones Setters
void Motor_SetMode(MotorControlMode mode){ motor.mode = mode; }
void Motor_SetPosition(int32_t grados){ motor.setpoint_position = grados; motor.mode = Control_position; }
void Motor_SetSpeed(float32_t grados_por_segundo){ motor.setpoint_speed = grados_por_segundo; motor.mode = Control_speed; }


// ================================================================
// BUCLE PRINCIPAL (Llamado desde main.c cada 10ms por el timer)
// ================================================================
void Motor_update(void){
    
    // 1. LEER EL HARDWARE (Encoder)
    motor.posicion_actual = (int32_t) __HAL_TIM_GET_COUNTER(&htim2);
    int32_t difpos = motor.posicion_actual - motor.posicion_anterior;
    motor.velocidad_actual = difpos * 100.0f; // 10ms = 100Hz
    motor.posicion_anterior = motor.posicion_actual; 
    
    float32_t salida = 0.0f; // Salida PWM (-999 a 999)

    // 2. LÓGICA DE CONTROL SEGÚN EL MODO
    if (motor.mode == Control_position){
        float32_t error_pos = (float32_t)(motor.setpoint_position - motor.posicion_actual);
        if (fabsf(error_pos) <= 1.0f) error_pos = 0.0f; // Banda muerta
        
        salida = arm_pid_f32(&motor.pid_position, error_pos);
        // Saturación a los límites físicos del PWM
        if (salida > 999.0f) salida = 999.0f; 
        if (salida < -999.0f) salida = -999.0f;
        motor.pid_position.state[2] = salida;
        
        if (error_pos == 0.0f) salida = 0.0f; 
    } 
    else if(motor.mode == Control_speed){
        float32_t error_speed = motor.setpoint_speed - motor.velocidad_actual;
        salida = arm_pid_f32(&motor.pid_speed, error_speed);
        // Saturación a los límites físicos del PWM
        if (salida > 999.0f) salida = 999.0f; 
        if (salida < -999.0f) salida = -999.0f;
        motor.pid_speed.state[2] = salida;
    }
    else if(motor.mode == Control_state_space || motor.mode == Control_speed_state_space){
        // --- ESPACIO DE ESTADOS ---
        
        // A) Estimación de salida: y_hat = C * x_hat
        arm_mat_mult_f32(&Cd_mat, &x_hat_mat, &y_hat_mat); 
        float32_t pos_estimada = y_hat_f32[0]; 
        float32_t vel_estimada = motor.x_hat[1]; 
        
        float32_t pos_leida = (float32_t)motor.posicion_actual; 
        float32_t error_obs = pos_leida - pos_estimada; // El error para el observador
        
        float32_t u_ideal_volts = 0.0f; 
        float32_t u_Kx_f32[1]; 
        arm_matrix_instance_f32 u_Kx_mat;
        arm_mat_init_f32(&u_Kx_mat, 1, 1, u_Kx_f32);

        // B) Ley de Control
        if (motor.mode == Control_state_space) {
            // Posición
            float32_t error_seguimiento = pos_estimada - (float32_t)motor.setpoint_position;
            motor.x_integral_pos += error_seguimiento * TS_DSP; 
            
            arm_mat_mult_f32(&Kx_pos_mat, &x_hat_mat, &u_Kx_mat); 
            u_ideal_volts = -u_Kx_f32[0] - (Ki_pos_f32 * motor.x_integral_pos); 
        }
        else {
            // Velocidad
            float32_t error_seguimiento = motor.velocidad_actual - motor.setpoint_speed; 
            motor.x_integral_speed += error_seguimiento * TS_DSP; 
            
            arm_mat_mult_f32(&Kx_vel_mat, &x_hat_mat, &u_Kx_mat); 
            u_ideal_volts = -u_Kx_f32[0] - (Ki_vel_f32 * motor.x_integral_speed); 
        }
            
        // C) Saturación a los límites físicos (+-12V)
        float32_t u_real_volts = u_ideal_volts;
        if (u_real_volts > VMAX_DSP) u_real_volts = VMAX_DSP;
        if (u_real_volts < -VMAX_DSP) u_real_volts = -VMAX_DSP;

        // D) Anti-Windup (Back-Calculation Corregido)
        if (u_real_volts != u_ideal_volts) {
            if (motor.mode == Control_state_space) {
                motor.x_integral_pos += (u_ideal_volts - u_real_volts) / Ki_pos_f32; 
            } else {
                motor.x_integral_speed += (u_ideal_volts - u_real_volts) / Ki_vel_f32; 
            }
        }   

        // E) Actualizar Observador: x_hat = Ad*x_hat + Bd*u_real + Lp*error_obs
        arm_mat_mult_f32(&Ad_mat, &x_hat_mat, &temp1_mat);         // temp1 = Ad * x_hat
        arm_mat_scale_f32(&Bd_mat, u_real_volts, &temp2_mat);      // temp2 = Bd * u_real
        arm_mat_scale_f32(&Lp_mat, error_obs, &temp3_mat);         // temp3 = Lp * error_obs
        
        arm_mat_add_f32(&temp1_mat, &temp2_mat, &x_hat_mat);       // x_hat = temp1 + temp2
        arm_mat_add_f32(&x_hat_mat, &temp3_mat, &x_hat_mat);       // x_hat = x_hat + temp3

        // F) Mapear a salida PWM (-999 a 999)
        salida = (u_real_volts / VMAX_DSP) * 999.0f; 
        
        // Banda muerta de seguridad (solo en posición)
        if (motor.mode == Control_state_space) {
            if (fabsf(pos_estimada - (float32_t)motor.setpoint_position) <= 1.0f && fabsf(vel_estimada) < 1.0f) {
                salida = 0.0f; 
            }
        }
    }
    else{
        // Control manual
        salida = motor.pwm_output;
    }

    // 3. ENVIAR AL HARDWARE (Límites Finales y GPIO)
    
    if (salida > 999.0f) salida = 999.0f;
    if (salida < -999.0f) salida = -999.0f;
    motor.pwm_output = salida;

    if (salida > 0.0f){
        HAL_GPIO_WritePin(GPIOB, GPIO_PIN_3, GPIO_PIN_SET); 
        __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, (uint32_t)salida);
    } 
    else if (salida < 0.0f){
        HAL_GPIO_WritePin(GPIOB, GPIO_PIN_3, GPIO_PIN_RESET); 
        __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, (uint32_t)(-salida));
    }
    else{
        __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 0);
    }
}