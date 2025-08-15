/*
 * Copyright (C) Vicoretek, Inc - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#ifndef POST_FILTER_H
#define POST_FILTER_H

#ifdef __cplusplus
extern "C"
{
#endif

    extern void postFilter(short *data, int width, int height, const char *config_file);

    extern void invalidFilter(short *data, int width, int height, short min_pix_val, short max_pix_val, short inf_pix_val);
    extern void speckleFilter(short *data, int width, int height, short inf_pix_val, int min_win_size, int max_pix_diff);
    extern void nearestNeighborFilter(short *data, int width, int height, short inf_pix_val, float max_pix_radius);

#ifdef __cplusplus
}
#endif

#endif
