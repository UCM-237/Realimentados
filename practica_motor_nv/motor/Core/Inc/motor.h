# ifndef MOTOR_H
# define MOTOR_H
#include "main.h"
#include "arm_math.h" //CMSIS-DSP
typedef enum{
    Control_pwm_openloop, //manual
    Control_position, //PID de posición
    Control_speed, //PID de velocidad
    Control_state_space, //Controlador de espacio de estados posicion
    Control_speed_state_space //Controlador de espacio de estados velocidad
} MotorControlMode;

typedef struct{
    //Modo de control actual
    MotorControlMode mode;
    //PID
    arm_pid_instance_f32 pid_position;
    arm_pid_instance_f32 pid_speed;

    //Controlador de espacio de estados
    float32_t x_hat[2]; //Estado estimado [posición; velocidad]
    float32_t x_integral_pos; //Integral para control de posición
    float32_t x_integral_speed; //Integral para control de velocidad
    //estado del motor
    int32_t posicion_actual;
    int32_t posicion_anterior;
    float32_t velocidad_actual;
    //setpoints
    int32_t setpoint_position;
    float32_t setpoint_speed;
    //Salida PWM
    float32_t pwm_output;
} MotorControl;
extern MotorControl motor; //Estructura global para controlar el motor desde main.c y motor.c
void MotorControl_Init(void);
void Motor_SetMode(MotorControlMode mode);
void Motor_SetPosition(int32_t grados);
void Motor_SetSpeed(float32_t grados_por_segundo);
void Motor_update(void);
# endif