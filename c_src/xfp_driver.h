/****************************************************************************
 * Copyright (C) 2020 by Thiago Esteves.                                    *
 ****************************************************************************/

/**
 * @file    xfp_driver.h
 * @author  Thiago Esteves
 * @date    27 Dec 2019
 * @brief   This file contains functions to read and write messages from
 *          and to the xfp gen_server
 */

#ifndef XFP_C_SRC_XFP_DRIVER_H
#define XFP_C_SRC_XFP_DRIVER_H

/**
 * @brief Error defines
 */

#define XFP_OK    (0)
#define XFP_ERROR (-1)

/** @brief This function opens the driver that will handle the xfp transactions
 *
 * @return  < 0 on error
 *         == 0 on success
 */
int open_xfp_driver(char *buf, int *index);

/** @brief This function closes the driver that will handle the xfp transactions
 *
 * @return  < 0 on error
 *         == 0 on success
 */
int close_xfp_driver(char *buf, int *index);

/** @brief Read XFP register, this function expects 2 arguments from Xfp 
 *         driver in Erlang:
 *         @param Instance Xfp instance
 *         @param Register Register to read
 *
 * @return  < 0 on error
 *         == 0 on success
 */
int read_register(char *buf, int *index);

/** @brief Write at XFP register, this function expects 3 arguments from Xfp 
 *         driver in Erlang:
 *         @param Instance Xfp instance
 *         @param Register Register to write
 *         @param Value Value to write
 *
 * @return  < 0 on error
 *         == 0 on success
 */
int write_register(char *buf, int *index);

/** @brief Read XFP pin, this function expects 2 arguments from Xfp 
 *         driver in Erlang:
 *         @param Instance Xfp instance
 *         @param Pin Pin to read
 *
 * @return  < 0 on error
 *         == 0 on success
 */
int read_pin(char *buf, int *index);

/** @brief Write at XFP pin, this function expects 3 arguments from Xfp 
 *         driver in Erlang:
 *         @param Instance Xfp instance
 *         @param Pin Pin to write
 *         @param Value Value to write
 *
 * @return  < 0 on error
 *         == 0 on success
 */
int write_pin(char *buf, int *index);

#endif /* XFP_C_SRC_XFP_DRIVER_H */