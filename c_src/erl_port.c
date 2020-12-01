
/****************************************************************************
 * Copyright (C) 2020 by Thiago Esteves.                                    *
 ****************************************************************************/

/**
 * @file    erl_port.c
 * @author  Thiago Esteves
 * @date    27 Dec 2019
 * @brief   This file contains the application that is going to handle all
 *          the messages from xfp gen_server  
 */

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/select.h>
#include <string.h>
#include <ei.h>
#include "erl_comm.h"
#include "xfp_driver.h"

#define MAX_FUN_NAME_SIZE (40)

/**
 * @brief Interface struct to improve process_command
 */
typedef struct
{
  char fun_name[MAX_FUN_NAME_SIZE];
  int (*function)(char *, int *);
} xfp_interface_t;

xfp_interface_t xfp_interface[] =
{
  { "open_xfp_driver" , open_xfp_driver  },
  { "close_xfp_driver", close_xfp_driver },
  { "read_register"   , read_register    },
  { "write_register"  , write_register   },
  { "read_pin"        , read_pin         },
  { "write_pin"       , write_pin        },
};

#define NUM_XFP_FUN (sizeof(xfp_interface)/sizeof(xfp_interface_t))

static int process_command(const char *command, char *buf, int *index)
{
  for (unsigned int i=0; i<NUM_XFP_FUN; i++)
  {
    if (!strcmp(xfp_interface[i].fun_name, command))
    {
      return xfp_interface[i].function(buf, index);
    }
  }

  /* In case the command is unknown, return error */
  send_answer_string_ulong("error", 0);

  return(0);
}

int main()
{
  /* variables for erlang interface */
  int   index, version, arity;
  int   size = BUFFER_SIZE;
  int   cmdpos=0, result;
  char  *inbuf = NULL;
  char  command[MAXATOMLEN];

  /* varables for pselect */
  int maxfd=0, retval=0;
  fd_set readfds;

  /* Watch stdin (fd 0) to see when it has input. */
  FD_ZERO(&readfds);
  FD_SET(0, &readfds);

  inbuf = (char*) malloc(size);
  if (inbuf == NULL) {
      perror("malloc()");
      exit(1);
  }
  
  while ((retval = select(maxfd + 1, &readfds, NULL, NULL, NULL)) >= 0)
  {
    if (FD_ISSET(0, &readfds))
    {
      memset(inbuf, 0, size);
      index = 0;
      result = read_cmd(&inbuf, &size, &cmdpos);

      if (result == 0) {
          free(inbuf);
          exit(1);
      } else if (result < 0) {
        /* exit(1); */
      } else if (result == 1) {
      } else {

        /* must add two(2) to inbuf pointer to skip message length header */
        if (ei_decode_version(inbuf+TUPLE_HEADER_SIZE, &index, &version) ||
            ei_decode_tuple_header(inbuf+TUPLE_HEADER_SIZE, &index, &arity) ||
            ei_decode_atom(inbuf+TUPLE_HEADER_SIZE, &index, command))
        {
          free(inbuf);
          exit(4);
        }

        process_command(command, inbuf+TUPLE_HEADER_SIZE, &index);

        /* reset position of inbuf */
        cmdpos = 0;
      }
    }
  }
  free(inbuf);
  exit(10);
}