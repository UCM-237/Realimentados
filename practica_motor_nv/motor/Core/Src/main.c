/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
//#include <stdlib.h>
//#include <string.h>
//#include <stdio.h>
#include <math.h>
#include "motor.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */
//Estructura para enviar datos. Solo creamos una estructura genérica que pueda ser utilizada 
// tanto para enviar la dirección del motor como el tiempo y la posición del encoder 
typedef struct {
  uint32_t id; //ID para identificar el tipo de dato 1 para dirección, 2 para tiempo y posición)
  uint32_t tiempo_ms; //tiempo o direccion dependiendo del ID
  int32_t  posicion; //posición del encoder (solo se utiliza si el ID es 2)
  float32_t velocidad; //velocidad del motor
  float32_t velocidad_est; //velocidad estimada por el observador de espacio de estados
} DatosPck;
typedef struct{
  uint32_t id; //ID para identificar el tipo de dato 1 para dirección, 2 para PWM)
  int32_t valor; //valor del comando (puede ser el valor de PWM o la dirección dependiendo del ID)
} ComandoPck;
/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
TIM_HandleTypeDef htim2;
TIM_HandleTypeDef htim3;
TIM_HandleTypeDef htim4;

UART_HandleTypeDef huart2;

/* USER CODE BEGIN PV */
volatile uint8_t flag_timer = 0;//para resetear el timer cada 10ms
volatile uint8_t flag_boton_pulsado = 0; //para indicar si el botón de usuario ha sido pulsado
ComandoPck rx_data; //Estructura para almacenar el comando recibido por UART
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_TIM3_Init(void);
static void MX_TIM2_Init(void);
static void MX_USART2_UART_Init(void);
static void MX_TIM4_Init(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_TIM3_Init();
  MX_TIM2_Init();
  MX_USART2_UART_Init();
  MX_TIM4_Init();
  /* USER CODE BEGIN 2 */
  MotorControl_Init(); //Inicializar la estructura de control del motor con valores iniciales
  //Iniciar el timer en modo encoder
  HAL_TIM_Encoder_Start(&htim2, TIM_CHANNEL_ALL);
  //Iniciar el timer en modo PWM para controlar la velocidad del motor
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
  //Iniciar el timer para medir el tiempo transcurrido
  HAL_TIM_Base_Start_IT(&htim4); 
  //encender el led para indicar que el sistema está funcionando
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET);
  //Iniciar la recepción de datos por UART en modo interrupción
  HAL_UART_Receive_IT(&huart2, (uint8_t*)&rx_data, sizeof(rx_data));

  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_3, GPIO_PIN_RESET); //Asegurar que el pin PB3 esté apagado al inicio
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7 | GPIO_PIN_10, GPIO_PIN_SET); //Encender los pines PA7 y PA10 para activar los puentes H del motor
  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  static uint8_t contador_telemetria = 0;
  
  while (1)
  {
    if(flag_boton_pulsado){
      flag_boton_pulsado = 0; //Reiniciar el flag para esperar la próxima pulsación
      GPIO_PinState estado_dir = HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_3);//Leer el estado actual del pin PB3 para determinar la dirección del motor
      //Crear un paquete de datos con el estado de la dirección del motor para enviar por UART       
      DatosPck pktdir = {1,(uint32_t)estado_dir,0,0.0f}; //Crear un paquete de datos para enviar la dirección del motor
      HAL_UART_Transmit(&huart2, (uint8_t*)&pktdir, sizeof(pktdir), HAL_MAX_DELAY); //Enviar el paquete de datos por UART
    }
    if(flag_timer){
      flag_timer = 0; //dejar el flag en 0 para esperar la próxima interrupción
      //Crear un paquete de datos con el tiempo transcurrido y la posición del encoder
      Motor_update(); //Actualizar el control del motor y calcular la salida de PWM dependiendo del modo de control actual
      contador_telemetria++;
      if (contador_telemetria >= 1) {
        contador_telemetria = 0; // Reseteamos
        DatosPck pck_envio;
        pck_envio.id = 2; //Asignar un ID específico para el paquete de posición
        pck_envio.tiempo_ms = HAL_GetTick();
        pck_envio.posicion = motor.posicion_actual;
        pck_envio.velocidad = motor.velocidad_actual;
        if (motor.mode == Control_state_space || motor.mode == Control_speed_state_space) {
          pck_envio.velocidad_est = motor.x_hat[1]; //Enviar la velocidad estimada por el observador de espacio de estados
        } else {
          pck_envio.velocidad_est = 0.0f; //Si no estamos en modo espacio de estados, enviar 0 o un valor indicativo
        }
        HAL_UART_Transmit(&huart2, (uint8_t*)&pck_envio, sizeof(pck_envio), 10);
      }
    }
   // __WFI(); //Enter low power mode until an interrupt occurs
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }

  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 100;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief TIM2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM2_Init(void)
{

  /* USER CODE BEGIN TIM2_Init 0 */

  /* USER CODE END TIM2_Init 0 */

  TIM_Encoder_InitTypeDef sConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};

  /* USER CODE BEGIN TIM2_Init 1 */

  /* USER CODE END TIM2_Init 1 */
  htim2.Instance = TIM2;
  htim2.Init.Prescaler = 0;
  htim2.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim2.Init.Period = 4294967295;
  htim2.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim2.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  sConfig.EncoderMode = TIM_ENCODERMODE_TI1;
  sConfig.IC1Polarity = TIM_ICPOLARITY_RISING;
  sConfig.IC1Selection = TIM_ICSELECTION_DIRECTTI;
  sConfig.IC1Prescaler = TIM_ICPSC_DIV1;
  sConfig.IC1Filter = 0;
  sConfig.IC2Polarity = TIM_ICPOLARITY_RISING;
  sConfig.IC2Selection = TIM_ICSELECTION_DIRECTTI;
  sConfig.IC2Prescaler = TIM_ICPSC_DIV1;
  sConfig.IC2Filter = 0;
  if (HAL_TIM_Encoder_Init(&htim2, &sConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim2, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM2_Init 2 */

  /* USER CODE END TIM2_Init 2 */

}

/**
  * @brief TIM3 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM3_Init(void)
{

  /* USER CODE BEGIN TIM3_Init 0 */

  /* USER CODE END TIM3_Init 0 */

  TIM_ClockConfigTypeDef sClockSourceConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};
  TIM_OC_InitTypeDef sConfigOC = {0};

  /* USER CODE BEGIN TIM3_Init 1 */

  /* USER CODE END TIM3_Init 1 */
  htim3.Instance = TIM3;
  htim3.Init.Prescaler = 0;
  htim3.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim3.Init.Period = 1000 - 1;
  htim3.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim3.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  if (HAL_TIM_Base_Init(&htim3) != HAL_OK)
  {
    Error_Handler();
  }
  sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
  if (HAL_TIM_ConfigClockSource(&htim3, &sClockSourceConfig) != HAL_OK)
  {
    Error_Handler();
  }
  if (HAL_TIM_PWM_Init(&htim3) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim3, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sConfigOC.OCMode = TIM_OCMODE_PWM1;
  sConfigOC.Pulse = 0;
  sConfigOC.OCPolarity = TIM_OCPOLARITY_HIGH;
  sConfigOC.OCFastMode = TIM_OCFAST_DISABLE;
  if (HAL_TIM_PWM_ConfigChannel(&htim3, &sConfigOC, TIM_CHANNEL_1) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM3_Init 2 */

  /* USER CODE END TIM3_Init 2 */
  HAL_TIM_MspPostInit(&htim3);

}

/**
  * @brief TIM4 Initialization Function
  * @param None
  * @retval None
  */
static void MX_TIM4_Init(void)
{

  /* USER CODE BEGIN TIM4_Init 0 */

  /* USER CODE END TIM4_Init 0 */

  TIM_ClockConfigTypeDef sClockSourceConfig = {0};
  TIM_MasterConfigTypeDef sMasterConfig = {0};

  /* USER CODE BEGIN TIM4_Init 1 */

  /* USER CODE END TIM4_Init 1 */
  htim4.Instance = TIM4;
  htim4.Init.Prescaler = 1000 -1;
  htim4.Init.CounterMode = TIM_COUNTERMODE_UP;
  htim4.Init.Period = 1000-1;
  htim4.Init.ClockDivision = TIM_CLOCKDIVISION_DIV1;
  htim4.Init.AutoReloadPreload = TIM_AUTORELOAD_PRELOAD_DISABLE;
  if (HAL_TIM_Base_Init(&htim4) != HAL_OK)
  {
    Error_Handler();
  }
  sClockSourceConfig.ClockSource = TIM_CLOCKSOURCE_INTERNAL;
  if (HAL_TIM_ConfigClockSource(&htim4, &sClockSourceConfig) != HAL_OK)
  {
    Error_Handler();
  }
  sMasterConfig.MasterOutputTrigger = TIM_TRGO_RESET;
  sMasterConfig.MasterSlaveMode = TIM_MASTERSLAVEMODE_DISABLE;
  if (HAL_TIMEx_MasterConfigSynchronization(&htim4, &sMasterConfig) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN TIM4_Init 2 */

  /* USER CODE END TIM4_Init 2 */

}

/**
  * @brief USART2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART2_UART_Init(void)
{

  /* USER CODE BEGIN USART2_Init 0 */

  /* USER CODE END USART2_Init 0 */

  /* USER CODE BEGIN USART2_Init 1 */

  /* USER CODE END USART2_Init 1 */
  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart2) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART2_Init 2 */

  /* USER CODE END USART2_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, LD2_Pin|GPIO_PIN_7|GPIO_PIN_10, GPIO_PIN_RESET);

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_3, GPIO_PIN_RESET);

  /*Configure GPIO pin : PC13 */
  GPIO_InitStruct.Pin = GPIO_PIN_13;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pins : LD2_Pin PA7 PA10 */
  GPIO_InitStruct.Pin = LD2_Pin|GPIO_PIN_7|GPIO_PIN_10;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : PB3 */
  GPIO_InitStruct.Pin = GPIO_PIN_3;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(EXTI15_10_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */
//Callback del timer para actualizar el flag cada 10ms
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim){
  if(htim->Instance == TIM4){
    flag_timer = 1;
  }
}
//Callback para el botón de usuario (PC13) para togglear el pin PB3
/*void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin){
  if(GPIO_Pin == GPIO_PIN_13){
    motor.pwm_output = -motor.pwm_output; //Cambiar la dirección del motor 
    // al pulsar el botón (toggle del pin PB3) 
    // y actualizar el valor de PWM para reflejar el cambio de dirección
     //Al cambiar la dirección, también se actualiza el valor de PWM 
     // para que el motor gire en la dirección opuesta con la misma velocidad
     //Si el motor estaba detenido (pwm_output = 0), 
     // al pulsar el botón se activará en una dirección con una 
     // velocidad predeterminada (por ejemplo, 500)
     //ver esto más despacio no se que dice aquí
  }
}*/

// Esta función es llamada automáticamente por la HAL cuando ocurre una interrupción en un pin
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    // Usamos 'static' para que la variable no se borre al salir de la función
    // y recuerde cuándo fue la última vez que pulsamos.
    static uint32_t ultimo_tiempo_pulsacion = 0;
    
    // Obtenemos el tiempo actual del sistema en milisegundos
    uint32_t tiempo_actual = HAL_GetTick(); 

    // Verificamos que la interrupción viene efectivamente de nuestro pin 13 (A13)
    if(GPIO_Pin == GPIO_PIN_13) 
    {
        // ¿Han pasado más de 200 ms desde la última vez?
        if (tiempo_actual - ultimo_tiempo_pulsacion > 200) 
        {
            // ¡Es una pulsación real! Cambiamos el estado del pin PB3 (Dirección)
            motor.pwm_output = -motor.pwm_output;
            
            // Registramos este momento como la última pulsación válida
            ultimo_tiempo_pulsacion = tiempo_actual;
        }
        // Si no han pasado 200 ms, es un rebote y simplemente lo ignoramos.
    }
}

/* USER CODE END 4 */
//Callback para la recepción de datos por UART en modo interrupción
void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart){
  if(huart->Instance == USART2){
    //procesar el comando recibido en rx_data
    //si el ID es 1, modo manual el valor es la dirección del motor
    //Si el ID es 2, modo manualel valor es de PWM para controlar la velocidad del motor
    if(rx_data.id == 1){
      motor.mode = Control_pwm_openloop; //Cambiar el modo de control del motor a manual
      //  (open loop) para controlar la dirección y velocidad manualmente desde UART
      //Procesar la dirección del motor (rx_data.valor)
      if(rx_data.valor == 0){
        //Configurar el motor para girar en una dirección
        motor.pwm_output = -1.0f*fabs(motor.pwm_output); //Establecer un valor de PWM positivo para girar en una dirección
      } else {
        //Configurar el motor para girar en la dirección opuesta
        motor.pwm_output = fabs(motor.pwm_output);
      }
    } 
    else if(rx_data.id == 2){
      //Procesar el valor de PWM (rx_data.valor)
     motor.mode = Control_pwm_openloop; //Asegurar que el modo de control del motor esté en manual (open loop) para controlar la velocidad desde UART
      if (motor.pwm_output <0){
        motor.pwm_output = -(float32_t)rx_data.valor; //Actualizar el valor de PWM para controlar la velocidad del motor en la dirección actual
      }else {
        motor.pwm_output = (float32_t)rx_data.valor; //Actualizar el valor de PWM para controlar la velocidad del motor
      }
   } 
    else if(rx_data.id == 3){
      //Procesar el modo de control (rx_data.valor)
      motor.mode = Control_position; //Cambiar el modo de control a control de posición
      motor.setpoint_position = rx_data.valor; //Actualizar el setpoint de posición del motor
      //  con el valor recibido por UART (grados)
    }
    else if(rx_data.id == 4){
      //Procesar el modo de control (rx_data.valor)
      motor.mode = Control_speed; //Cambiar el modo de control a control de velocidad
      motor.setpoint_speed = (float32_t)rx_data.valor; //Actualizar el setpoint de velocidad del motor
      //  con el valor recibido por UART (grados por segundo)
    }
    else if(rx_data.id == 5){
     //Poner  el contador del encoder a 0
      __HAL_TIM_SET_COUNTER(&htim2, 0);
        motor.posicion_actual = 0; //Actualizar la posición actual del motor en la estructura de control
        motor.posicion_anterior = 0; //Actualizar la posición anterior para el próximo cálculo de velocidad
        motor.velocidad_actual = 0.0f; //Reiniciar la velocidad actual del motor a 0
        motor.pwm_output = 0.0f; //Reiniciar la salida de PWM a 0 para detener el motor

        motor.setpoint_position = 0; //Reiniciar el setpoint de posición a 0
        motor.setpoint_speed = 0.0f; //Reiniciar el setpoint

        arm_pid_init_f32(&motor.pid_position, 1);
        arm_pid_init_f32(&motor.pid_speed, 1);//Reiniciar el controlador PID de velocidad para  

        motor.x_hat[0] = 0.0f; // Resetear la posición estimada del observador a 0
        motor.x_hat[1] = 0.0f; // Resetear la velocidad estimada del observador a 0
      }
    else if(rx_data.id == 6){
      motor.mode = Control_state_space; 
      motor.setpoint_position = rx_data.valor; 
    }
    else if(rx_data.id == 7){
      motor.mode = Control_speed_state_space; 
      motor.setpoint_speed = (float32_t)rx_data.valor; 
    }
    //Reiniciar la recepción de datos por UART en modo interrupción para recibir el próximo comando
    HAL_UART_Receive_IT(&huart2, (uint8_t*)&rx_data, sizeof(rx_data));
  }
}
/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
