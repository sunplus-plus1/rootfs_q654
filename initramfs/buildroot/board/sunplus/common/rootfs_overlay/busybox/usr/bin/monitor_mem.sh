#!/bin/bash

need_drop_cache()
{
        total_mem=$(free -m | awk 'NR==2{print $2}')
        cache_mem=$(free -m | awk 'NR==2{print $6}')

        cache_percent=$(awk "BEGIN {printf \"%.0f\", $cache_mem / $total_mem * 100}")

        if [ $cache_percent -ge 30 ]; then
                echo "Buffer/cache usage exceeds 30% of total memory"
                echo 3 > /proc/sys/vm/drop_caches
        fi
}

change_oom_score_adj()
{
        pid=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $2}')
        rss=$(ps aux --sort=-%mem | head -n 2 | tail -n 1 | awk '{print $6}')

        p_oom_score_adj=$(cat /proc/$pid/oom_score_adj)
        if [ $p_oom_score_adj -lt 0 ]; then
                echo $pid "oom_score_adj < 0"
                echo 0 > /proc/$pid/oom_score_adj
        fi
}

while [ true ]; do
        need_drop_cache
        change_oom_score_adj
        sleep 60
done
