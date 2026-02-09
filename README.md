# Final DevOps Project (AWS + Terraform): VPC / EKS / RDS / ECR / Jenkins / Argo CD / Prometheus / Grafana

Цей репозиторій містить Terraform-інфраструктуру та CI/CD пайплайн для розгортання Django застосунку в AWS на Kubernetes (EKS) з GitOps через Argo CD та моніторингом через Prometheus/Grafana.

## Архітектура

- **VPC**: public + private subnets, IGW, NAT, routing
- **EKS**: кластер + node group, базові аддони
- **RDS**: PostgreSQL/MySQL або Aurora (через `use_aurora`)
- **ECR**: репозиторій для Docker image
- **Jenkins**: CI (build → push image в ECR)
- **Argo CD**: CD / GitOps (Helm chart `charts/django-app`)
- **Monitoring**: `kube-prometheus-stack` (Prometheus, Alertmanager, Grafana), (опційно) metrics-server

---

## Вимоги / prerequisites

### Інструменти локально
- Terraform `>= 1.0` (перевірено: `Terraform v1.14.4`)
- AWS CLI v2 (перевірено: `aws-cli/2.32.x`)
- kubectl (перевірено: `v1.34.x`)
- Helm (перевірено: `v4.x`)
- (опційно) `yq` для редагування YAML, або `sed` (див. приклади нижче)

### AWS доступ
- Налаштовані креденшели в `~/.aws/credentials` або через env vars.
- **Важливо:** Terraform в цьому проєкті використовує регіон з `var.aws_region` (за замовчуванням `us-west-2`).  
  Якщо у вас в `aws configure` стоїть інший регіон — це ОК, але Terraform все одно піде в `us-west-2`, якщо не перевизначити змінну.

Перевірка доступу:
```bash
aws sts get-caller-identity

Крок 0 — Terraform init

terraform fmt -recursive
terraform validate
terraform init

Створити S3 bucket + DynamoDB table локальним стейтом

terraform apply -target=module.s3_backend
terraform init -migrate-state

Крок 1 — розгортання інфраструктури (VPC/ECR/EKS/RDS)

terraform apply -target=module.vpc -target=module.ecr -target=module.eks -target=module.rds
Після створення EKS — оновити kubeconfig:
aws eks --region us-west-2 update-kubeconfig --name goit-devops-project-eks-cluster
kubectl get nodes

Крок 2 — Jenkins / Argo CD / Monitoring

terraform apply -target=module.jenkins -target=module.argo_cd -target=module.monitoring
Після поетапного apply бажано виконати:
terraform plan
terraform apply

Перевірка ресурсів (Kubernetes)

admin@Olegs-MacBook-Pro GoiT-DevOps-Project % kubectl port-forward -n jenkins svc/jenkins 8080:80

Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080
Handling connection for 8080

admin@Olegs-MacBook-Pro GoiT-DevOps-Project % kubectl port-forward svc/argocd-server 8081:443 -n argocd

Forwarding from 127.0.0.1:8081 -> 8080
Forwarding from [::1]:8081 -> 8080
Handling connection for 8081
Handling connection for 8081
Handling connection for 8081
Handling connection for 8081
Handling connection for 8081
Handling connection for 8081
Handling connection for 8081

admin@Olegs-MacBook-Pro GoiT-DevOps-Project % kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000
Handling connection for 3000
Handling connection for 3000
Handling connection for 3000

admin@Olegs-MacBook-Pro GoiT-DevOps-Project % kubectl get all -n monitoring

NAME                                                            READY   STATUS    RESTARTS   AGE
pod/alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          25m
pod/kube-prometheus-stack-grafana-8648dfd5fb-8t5wz              3/3     Running   0          25m
pod/kube-prometheus-stack-kube-state-metrics-777fd46ffb-cn5rf   1/1     Running   0          25m
pod/kube-prometheus-stack-operator-65896fd55c-wqllv             1/1     Running   0          25m
pod/kube-prometheus-stack-prometheus-node-exporter-nmp9x        1/1     Running   0          25m
pod/kube-prometheus-stack-prometheus-node-exporter-smz94        1/1     Running   0          25m
pod/kube-prometheus-stack-prometheus-node-exporter-sqcz7        1/1     Running   0          25m
pod/kube-prometheus-stack-prometheus-node-exporter-zvvxz        1/1     Running   0          25m
pod/prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          25m

NAME                                                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/alertmanager-operated                            ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   25m
service/kube-prometheus-stack-alertmanager               ClusterIP   172.20.191.213   <none>        9093/TCP,8080/TCP            25m
service/kube-prometheus-stack-grafana                    ClusterIP   172.20.130.27    <none>        80/TCP                       25m
service/kube-prometheus-stack-kube-state-metrics         ClusterIP   172.20.37.198    <none>        8080/TCP                     25m
service/kube-prometheus-stack-operator                   ClusterIP   172.20.232.59    <none>        443/TCP                      25m
service/kube-prometheus-stack-prometheus                 ClusterIP   172.20.120.93    <none>        9090/TCP,8080/TCP            25m
service/kube-prometheus-stack-prometheus-node-exporter   ClusterIP   172.20.61.234    <none>        9100/TCP                     25m
service/prometheus-operated                              ClusterIP   None             <none>        9090/TCP                     25m

NAME                                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/kube-prometheus-stack-prometheus-node-exporter   4         4         4       4            4           kubernetes.io/os=linux   25m

NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kube-prometheus-stack-grafana              1/1     1            1           25m
deployment.apps/kube-prometheus-stack-kube-state-metrics   1/1     1            1           25m
deployment.apps/kube-prometheus-stack-operator             1/1     1            1           25m

NAME                                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/kube-prometheus-stack-grafana-8648dfd5fb              1         1         1       25m
replicaset.apps/kube-prometheus-stack-kube-state-metrics-777fd46ffb   1         1         1       25m
replicaset.apps/kube-prometheus-stack-operator-65896fd55c             1         1         1       25m

NAME                                                               READY   AGE
statefulset.apps/alertmanager-kube-prometheus-stack-alertmanager   1/1     25m
statefulset.apps/prometheus-kube-prometheus-stack-prometheus       1/1     25m
admin@Olegs-MacBook-Pro GoiT-DevOps-Project % kubectl get svc -n monitoring

NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                            ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   25m
kube-prometheus-stack-alertmanager               ClusterIP   172.20.191.213   <none>        9093/TCP,8080/TCP            25m
kube-prometheus-stack-grafana                    ClusterIP   172.20.130.27    <none>        80/TCP                       25m
kube-prometheus-stack-kube-state-metrics         ClusterIP   172.20.37.198    <none>        8080/TCP                     25m
kube-prometheus-stack-operator                   ClusterIP   172.20.232.59    <none>        443/TCP                      25m
kube-prometheus-stack-prometheus                 ClusterIP   172.20.120.93    <none>        9090/TCP,8080/TCP            25m
kube-prometheus-stack-prometheus-node-exporter   ClusterIP   172.20.61.234    <none>        9100/TCP                     25m
prometheus-operated                              ClusterIP   None             <none>        9090/TCP                     25m

admin@Olegs-MacBook-Pro GoiT-DevOps-Project % kubectl get svc -n monitoring

NAME                                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                            ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   49m
kube-prometheus-stack-alertmanager               ClusterIP   172.20.191.213   <none>        9093/TCP,8080/TCP            49m
kube-prometheus-stack-grafana                    ClusterIP   172.20.130.27    <none>        80/TCP                       49m
kube-prometheus-stack-kube-state-metrics         ClusterIP   172.20.37.198    <none>        8080/TCP                     49m
kube-prometheus-stack-operator                   ClusterIP   172.20.232.59    <none>        443/TCP                      49m
kube-prometheus-stack-prometheus                 ClusterIP   172.20.120.93    <none>        9090/TCP,8080/TCP            49m
kube-prometheus-stack-prometheus-node-exporter   ClusterIP   172.20.61.234    <none>        9100/TCP                     49m
prometheus-operated                              ClusterIP   None             <none>        9090/TCP                     49m
admin@Olegs-MacBook-Pro GoiT-DevOps-Project % 

Як повністю видалити інфраструктуру і не отримати рахунок 💸
1) Terraform destroy
terraform destroy

2) Якщо backend bucket з Versioning — потрібно видалити ВСІ версії

Інакше delete-bucket поверне BucketNotEmpty.

BUCKET="terraform-state-bucket-<your-name>"

# видалити всі версії
aws s3api list-object-versions --bucket "$BUCKET" --output json \
| jq -r '.Versions[]? | "\(.Key) \(.VersionId)"' \
| while read -r key vid; do
    aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$vid"
  done

# видалити delete markers
aws s3api list-object-versions --bucket "$BUCKET" --output json \
| jq -r '.DeleteMarkers[]? | "\(.Key) \(.VersionId)"' \
| while read -r key vid; do
    aws s3api delete-object --bucket "$BUCKET" --key "$key" --version-id "$vid"
  done

# видалити bucket
aws s3api delete-bucket --bucket "$BUCKET" --region us-west-2
DynamoDB lock table:
aws dynamodb delete-table --table-name terraform-locks --region us-west-2
