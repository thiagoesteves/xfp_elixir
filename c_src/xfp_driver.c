
/****************************************************************************
 * Copyright (C) 2020 by Thiago Esteves.                                    *
 ****************************************************************************/

/**
 * @file    xfp_driver.c
 * @author  Thiago Esteves
 * @date    27 Dec 2019
 * @brief   This file contains functions to read/write data from XFP
 */

#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "erl_comm.h"
#include "xfp_driver.h"

/**
 * @brief The nex information will be a struct with all 
 *        data information to emulate a physical device.
 *        This information is not needed in a real device
 */
#define XFP_MAX_INSTANCES (20)
#define XFP_MAX_REGISTERS (256)

typedef enum
{
  XFP_PIN_MOD_DESEL = 0,
  XFP_PIN_TX_DIS,
  XFP_PIN_RESENCE,
  XFP_PIN_NOT_READY,
  XFP_PIN_RX_LOS,
  XFP_PIN_RESET,
  XFP_PIN_POWERDOWN,
  XFP_MAX_PIN
} xfp_pin_e;

typedef struct
{
  uint8_t pin[XFP_MAX_PIN];
  uint8_t data[XFP_MAX_REGISTERS];
} stub_xfp_info_t;

static stub_xfp_info_t stub_xfp_info[XFP_MAX_INSTANCES];

const uint8_t stub_xfp_default_data[XFP_MAX_REGISTERS] = 
{ /*                    Lower map register                                      */
  0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x06,0x40,0x00,0x00,0x7F,0xFF,0x00,0x00,0xAF,0xC8,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  /*                     Vendor data map                                        */
  0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00, 'V', 'E', 'N', 'D', 'O', 'R', ' ', 'N', 'A', 'M', 'E', ' ',
   ' ', 'X', 'F', 'P',0x00,0x00,0x00,0x20, 'V', 'E', 'N', 'D', 'O', 'R', ' ', 'P',
   'A', 'R', 'T', 'N', 'U', 'M', 'B', 'E', '0', '1',0x66,0x58,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00, 'V', 'E', 'N', 'D', 'O', 'R', ' ', 'S', 'E', 'R', 'I', 'A',
   'L', 'N', 'U', 'M', 'D', 'A', 'T', 'A', 'C', 'O', 'D', 'E',0xFF,0x55,0xFF,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
  0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
};


int open_xfp_driver(char *buf, int *index)
{
  /*TODO: Insert the opening of the driver here */

  /* STUB CODE: Initilise Emulator data for all XFP's */
  for (int i = 0; i < XFP_MAX_INSTANCES; i++) {
    for (int j = 0; j < XFP_MAX_PIN; j++) {
      stub_xfp_info[i].pin[j] = 0x00;
    }
    memcpy(&stub_xfp_info[i].data[0], &stub_xfp_default_data[0], XFP_MAX_REGISTERS);
  }
  return send_answer_string_ulong("ok", XFP_OK);
}

int close_xfp_driver(char *buf, int *index)
{
  /*TODO: Insert the closing of the driver here */
  
  return send_answer_string_ulong("ok", XFP_OK);
}

int read_register(char *buf, int *index)
{
  unsigned long instance, reg;
  uint8_t read_value;
  
  if (ei_decode_ulong(buf, index, &instance) ||
      ei_decode_ulong(buf, index, &reg))
  {
      return XFP_ERROR;
  }

  /*TODO: Insert the reading of the xfp register here */

  /* STUB CODE: Initilise Emulator data for all XFP's */
  read_value = stub_xfp_info[instance].data[reg];

  return send_answer_string_ulong("ok", (uint32_t)read_value);
}

int write_register(char *buf, int *index)
{
  unsigned long instance, reg, value;
  
  if (ei_decode_ulong(buf, index, &instance) ||
      ei_decode_ulong(buf, index, &reg)      ||
      ei_decode_ulong(buf, index, &value))
  {
      return XFP_ERROR;
  }

  /*TODO: Insert the reading of the xfp pin here */

  /* STUB CODE: Initilise Emulator data for all XFP's */
  stub_xfp_info[instance].data[reg] = (uint8_t)value;

  return send_answer_string_ulong("ok", XFP_OK);
}

int read_pin(char *buf, int *index)
{
  unsigned long instance, pin;
  uint8_t pin_state;
  
  if (ei_decode_ulong(buf, index, &instance) ||
      ei_decode_ulong(buf, index, &pin))
  {
      return XFP_ERROR;
  }

  /*TODO: Insert the reading of the xfp pin here */

  /* STUB CODE: Initilise Emulator data for all XFP's */
  pin_state = (unsigned long)stub_xfp_info[instance].pin[pin];

  return send_answer_string_ulong("ok", (uint32_t)pin_state);
}

int write_pin(char *buf, int *index)
{
  unsigned long instance, pin, value;
  
  if (ei_decode_ulong(buf, index, &instance) ||
      ei_decode_ulong(buf, index, &pin)      ||
      ei_decode_ulong(buf, index, &value))
  {
      return XFP_ERROR;
  }

  /*TODO: Insert the reading of the xfp pin here */

  /* STUB CODE: Initilise Emulator data for all XFP's */
  stub_xfp_info[instance].pin[pin] = (uint8_t)value;

  return send_answer_string_ulong("ok", XFP_OK);
}