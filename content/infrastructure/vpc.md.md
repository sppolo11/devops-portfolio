
## Terraform 을 이용한 AWS VPC 구성

### 1. 구성 목적
	AWS EKS 환경 구성 전 VPC를 terraform으로 구성


#### 2. Architecture
```
   Internet
      │
      ▼
   Internet Gateway
      │
   platform-vpc (10.0.0.0/16)
      │
      ├─ AZ 2a
      │   ├─ Public  10.0.1.0/24
      │   └─ Private 10.0.11.0/24
      │
      └─ AZ 2c
          ├─ Public  10.0.2.0/24
          └─ Private 10.0.12.0/24
```

#### 3. 설계
- 2개 AZ 사용하여 
- Public / Private 서브넷 분리
-  추후 ALB 배치 대비 Subnet tag 추가
-  EKS Worker Node는 Private Subnet에 배치 예정

#### 4. Terraform
- AWS Provider
- VPC
- Subnet
- Internet Gateway
- Route Table

#### 5. 검증
```
   terraform plan
   Plan: 9 to add, 0 to change, 0 to destroy
```

```
terraform apply 
실제 AWS 리소스 생성확인
```

