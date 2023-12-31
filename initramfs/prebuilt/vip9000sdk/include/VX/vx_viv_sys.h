#ifndef _VX_VIV_SYS_H_
#define _VX_VIV_SYS_H_

#include <VX/vx.h>

#ifdef __cplusplus
extern "C" {
#endif

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

#ifdef __cplusplus
}
#endif


#endif

