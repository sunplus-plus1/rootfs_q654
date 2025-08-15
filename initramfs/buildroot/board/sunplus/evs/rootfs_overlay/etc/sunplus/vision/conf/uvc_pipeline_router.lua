#!/usr/bin/lua
-- flare
-- 分辨率，FPS，pipeline，填入顺序
-- 分辨率：PC端传下来的分辨率 
-- pipeline：对应分辨率下需要应用的pipeline
-- 填入顺序：当pipeline的输出不唯一，需要拼接图像时，并且默认的拼接不符合要求时，可以选择去修改pipeline或者修改填入顺序来调整

--** 
--* 填入顺序，channel的subbuf index，加入uvc buff可以容纳4个图像，VioDataExporter的输出是一个Pack，pack了4个图像，
--* 那么默认填入的顺序就是:vec_sub_buffer[0],vec_sub_buffer[1],vec_sub_buffer[2],vec_sub_buffer[3]
--* 如果需要修改这个填入顺序，可以通过填入优先级进行修改，填入优先是一个二维数组，第一维表示channel，第二维表示subbuf index
--*/

-- 分辨率 | FPS | pipeline | 填入顺序
resolution2pipeline = {
    { {640,480}, {}, "online_stereo_640x480.cfg", {{3}}, ".*" },              -- 填入顺序:3，0，1，2
    { {1280,480}, {}, "online_stereo_640x480.cfg", {{0, 3}}, ".*" },          -- 填入顺序:0，3，1，2
    { {1280,960}, {}, "online_stereo_640x480.cfg", {{1, 2, 0, 3}}, ".*" },    -- 填入顺序:1，2，0，3

    { {1280,720}, {}, "online_stereo_1280x720.cfg", {{3}}, ".*" },
    -- { {1280,720}, {30}, "imgc_bridge_1path_exp.json", {{}}, ".*" },
    { {2560,720}, {}, "online_stereo_1280x720.cfg", {{0, 3}}, ".*" },
    { {2560,1440}, {}, "online_stereo_1280x720.cfg", {{1, 2, 0, 3}}, ".*" },
}

-- For S50
-- Usage: uvc_pipeline_router.lua [sensor_key]
-- Example: uvc_pipeline_router.lua cm6400 or lua uvc_pipeline_router.lua cm6400
if arg ~= nil and #arg ~= 0 then
    for _, item in ipairs(resolution2pipeline) do
        local sensor_key = item[#item]
        if(type(sensor_key) == "string") then 
            local ret = string.match(arg[1], sensor_key)
            if ret ~= nil then
                if #item[2] == 0 then
                    print(item[1][1]..","..item[1][2]..",30"..",yuyv")
                else
                    for _, fps in ipairs(item[2]) do
                        print(item[1][1]..","..item[1][2]..","..fps..",yuyv")
                    end
                end
            end
        end
    end
end