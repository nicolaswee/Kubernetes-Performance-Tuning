# Links to configurations used

## Huge Pages
HugePages configuration allows a Pod to access memory pages larger than the Linux kernel's default memory page size, which is usually 4 KB. Used by memory-intensive applications.

https://kubernetes.io/docs/tasks/manage-hugepages/scheduling-hugepages/
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: huge-pages-example
spec:
  containers:
  - name: example
    image: fedora:latest
    command:
    - sleep
    - inf
    volumeMounts:
    - mountPath: /hugepages-2Mi
      name: hugepage-2mi
    - mountPath: /hugepages-1Gi
      name: hugepage-1gi
    resources:
      limits:
        hugepages-2Mi: 100Mi
        hugepages-1Gi: 2Gi
        memory: 100Mi
      requests:
        memory: 100Mi
  volumes:
  - name: hugepage-2mi
    emptyDir:
      medium: HugePages-2Mi
  - name: hugepage-1gi
    emptyDir:
      medium: HugePages-1Gi
```


## kube-reserved
kube-reserved is meant to capture resource reservation for kubernetes system daemons like the kubelet, container runtime, node problem detector, etc.

https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/

## system-reserved
system-reserved is meant to capture resource reservation for OS system daemons like sshd, udev, etc. system-reserved should reserve memory for the kernel too since kernel memory is not accounted to pods in Kubernetes at this time.

https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/


## feature_gates
CPUManager: Enable container level CPU affinity support
CPUManagerPolicyOptions: Allow fine-tuning of CPUManager policies.

https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/

```
additional_feature_gates = {
    "CPUManager" : true,
    "CPUManagerPolicyOptions": true
}
```

## cpu-manager-policy
https://kubernetes.io/docs/tasks/administer-cluster/cpu-management-policies/

To enabled `full-pcpus-only`

If the full-pcpus-only policy option is specified, the static policy will always allocate full physical cores

```
cpu_manager_policy = "static"
cpu_managey_policy_options = {
    "full-pcpus-only" : true
}
```