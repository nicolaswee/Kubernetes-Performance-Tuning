# ########################
# # Huge Pages
# ########################
# HugePages optimizes the memory configuration of the Linux operating system
%{ if reserved_huge_pages > 0 }
sysctl -w vm.nr_hugepages=${reserved_huge_pages}
%{ endif }

########################
# TCP Tuning
########################
# 1MB receive and send buffer for each connection
# Maximum Socket Send Buffer
sysctl -w net.core.wmem_max=12582912
# Maximum Socket Receive Buffer
sysctl -w net.core.rmem_max=12582912
# Increase the read-buffer space allocatable
sysctl -w net.ipv4.tcp_rmem="10240 87380 12582912"
# Increase the write-buffer-space allocatable
sysctl -w net.ipv4.tcp_wmem="10240 87380 12582912"
# Enable TCP window scaling
sysctl -w net.ipv4.tcp_window_scaling=1
# Low latency busy poll timeout for poll and select
sysctl -w net.core.busy_poll=70
# Low latency busy poll timeout for socket reads
sysctl -w net.core.busy_read=70
# Restart sysctl
sysctl -p

# Set system.service to use CPU 0
echo "CPUAffinity=0" >> "/etc/systemd/system.conf"
# Restart systemctl
systemctl daemon-reexec
# Restart services
systemctl isolate rescue
systemctl isolate default

# Period of time during which all runnable tasks should be allowed to run at least once
echo 1000000 > /proc/sys/kernel/sched_latency_ns
# Target minimum scheduler period in which a single task will run
echo 500000 > /proc/sys/kernel/sched_min_granularity_ns
# Gives preemption granularity when tasks wake up
echo 500000 > /proc/sys/kernel/sched_wakeup_granularity_ns

########################
# EKS bootstrap
# kubelet config
########################
/etc/eks/bootstrap.sh ${cluster_name} ${kubelet_extra_args}