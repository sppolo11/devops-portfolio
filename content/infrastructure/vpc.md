---
title: AWS Network
description: Terraform을 이용한 EKS 네트워크 기반 구성
---

# AWS Network

EKS 클러스터 생성 전 AWS VPC와 Subnet 등 기본 네트워크를 Terraform으로 구성함.

기존에 AWS 콘솔에서 직접 구성했던 네트워크 환경을 이번에는 Terraform 코드로 관리하고,
필요할 때 동일한 환경을 다시 생성할 수 있도록 하는 것을 목표로 함

## 구성

- VPC: `10.0.0.0/16`
- Availability Zone: `ap-northeast-2a`, `ap-northeast-2c`
- Public Subnet: 2개
- Private Subnet: 2개
- Internet Gateway
- NAT Gateway (1개)
- Public Route Table
- Private Route Table

### Network

| AZ              | Type    | CIDR           |
| --------------- | ------- | -------------- |
| ap-northeast-2a | Public  | `10.0.1.0/24`  |
| ap-northeast-2c | Public  | `10.0.2.0/24`  |
| ap-northeast-2a | Private | `10.0.11.0/24` |
| ap-northeast-2c | Private | `10.0.12.0/24` |

Public Subnet은 Internet Gateway을 통해 외부와 통신하도록 구성했다.

Private Subnet은 외부에서 직접 접근할 수 없도록 분리하고, 외부 통신이 필요한 경우 NAT Gateway를 통해 나가도록 구성함.


## ALB를 고려한 Subnet 구성

AWS Load Balancer Controller를 사용할 것을 고려해 Subnet에 Kubernetes용 태그를 추가했다.

Public Subnet:

`kubernetes.io/role/elb = 1`

Private Subnet:

`kubernetes.io/role/internal-elb = 1`

Internet-facing Load Balancer와 Internal Load Balancer가 사용할 Subnet을 구분하기 위한 설정이다.

## NAT Gateway

NAT Gateway는 `ap-northeast-2a`의 Public Subnet에 1개만 생성했다.

두 Private Subnet은 동일한 Private Route Table을 사용하며 기본 경로를 NAT Gateway로 설정했다.

```0.0.0.0/0 -> NAT Gateway```

실제 운영 환경에서 고가용성이 필요한 경우에는 AZ별 NAT Gateway 구성을 고려할 수 있지만, 현재 환경에서는 비용을 고려해 단일 NAT Gateway로 구성했다.

## Terraform

Terraform으로 관리하는 리소스는 다음과 같다.

- `aws_vpc`
- `aws_subnet`
- `aws_internet_gateway`
- ```aws_nat_gateway```
- ```aws_eip```
- `aws_route_table`
- `aws_route_table_association`

코드: `terraform/aws/vpc.tf`  [Terraform VPC 코드](https://github.com/sppolo11/devops-portfolio/blob/main/terraform/aws/vpc.tf)

아직 Terraform state 파일은 로컬에서만 관리하고 Git 저장소에서는 제외했다.

## 확인

`terraform plan`으로 생성될 리소스를 먼저 확인한 뒤 실제 AWS 환경에 적용했다.

    Plan: 14 to add, 0 to change, 0 to destroy.

AWS Console에서 다음 항목을 확인했다.

- VPC 및 Public/Private Subnet 생성
    
- Internet Gateway 연결
    
- NAT Gateway 및 Elastic IP 생성
    
- Public Route Table의 `0.0.0.0/0 → Internet Gateway` 경로
    
- Private Route Table의 `0.0.0.0/0 → NAT Gateway` 경로
    
- 두 Private Subnet의 Private Route Table 연결
    
- Public/Private Subnet의 Kubernetes 태그