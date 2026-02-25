# 부동산 관리 시스템 (SiRE) 클래스 다이어그램

아래는 시스템의 핵심 도메인 간의 관계를 나타낸 다이어그램입니다.

```mermaid
classDiagram
    %% 클래스 정의
    class Investor {
        +String id
        +String name
        +String email
        +addProperty(Property property)
        +calculateTotalROI() float
    }

    class Property {
        +String propertyId
        +String address
        +float purchasePrice
        +float currentValue
        +updateValue(float newValue)
    }

    class Tenant {
        +String tenantId
        +String name
        +String contactInfo
        +payRent()
    }

    class LeaseContract {
        +String contractId
        +Date startDate
        +Date endDate
        +float monthlyRent
        +terminateContract()
    }

    %% 클래스 간의 관계 정의
    Investor "1" -- "*" Property : owns >
    Property "1" -- "0..1" LeaseContract : has >
    LeaseContract "*" -- "1" Tenant : signed by >