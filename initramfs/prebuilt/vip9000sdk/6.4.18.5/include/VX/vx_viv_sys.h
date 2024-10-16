/****************************************************************************
*
*    Copyright 2017 - 2020 Vivante Corporation, Santa Clara, California.
*    All Rights Reserved.
*
*    Permission is hereby granted, free of charge, to any person obtaining
*    a copy of this software and associated documentation files (the
*    'Software'), to deal in the Software without restriction, including
*    without limitation the rights to use, copy, modify, merge, publish,
*    distribute, sub license, and/or sell copies of the Software, and to
*    permit persons to whom the Software is furnished to do so, subject
*    to the following conditions:
*
*    The above copyright notice and this permission notice (including the
*    next paragraph) shall be included in all copies or substantial
*    portions of the Software.
*
*    THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
*    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
*    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
*    IN NO EVENT SHALL VIVANTE AND/OR ITS SUPPLIERS BE LIABLE FOR ANY
*    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
*    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
*    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*****************************************************************************/

#ifndef _VX_VIV_SYS_H_
#define _VX_VIV_SYS_H_

#include <VX/vx.h>

#ifdef  __cplusplus
extern "C" {
#endif

typedef enum _vx_viv_mem_pool_type_e
{
    VX_VIV_MEM_POOL_TYPE_DDR = 0x0,
    VX_VIV_MEM_POOL_TYPE_AXI_SRAM = 0x1,
} vx_viv_mem_pool_type_e;

/*! \brief set clock fscale value to change core and shader frequency.
 * \param [in] coreIndex Global core index to set the specific core clock frequency.
 *                       If the value is 0xFFFFFFFF, all the cores will be set.
 * \param [in] vipFscaleValue Set core frequency scale size. Value can be 64, 32, 16, 8, 4, 2, 1.
 *                       64 means 64/64 full frequency, 1 means 1/64 frequency.
 * \param [in] shaderFscaleValue Set shader frequency scale size. Value can be 64, 32, 16, 8, 4, 2, 1.
 *                       64 means 64/64 full frequency, 1 means 1/64 frequency.
 *
 * \return A <tt>\ref vx_status_e</tt> enumeration.
 * \retval VX_SUCCESS No errors;
 * \retval VX_ERROR_INVAID_PARAMETERS Invalid frequency scale values.
 * \retval VX_FAILURE Failed to change core and shader frequency.
 */
VX_API_ENTRY vx_status VX_API_CALL vxSysSetVipFrequency(
    vx_uint32 coreIndex,
    vx_uint32 vipFscaleValue,
    vx_uint32 shaderFscaleValue
    );

/*! \brief cancel all VIP processing jobs on a device.
 * \param [in] context The reference to the implementation context.
 * \param [in] deviceID bound to graph.
 * \return A <tt>\ref vx_status_e</tt> enumeration.
 * \retval VX_SUCCESS Cancelled all VIP processing job successfully on a device
 *                    and user can check return of vxProcessGraph() to get cancelled status.
 * \retval VX_ERROR_INVAID_PARAMETERS Invalid context reference.
 * \retval VX_ERROR_NOT_SUPPORTED Hardware does not support job cancellation.
 * \retval VX_FAILURE Failed to cancel VIP proccessing job on a device.
 */
VX_API_ENTRY vx_status VX_API_CALL vxSysCancelJob(
    vx_context context,
    vx_uint32  deviceID
    );

#ifdef  __cplusplus
}
#endif


#endif

