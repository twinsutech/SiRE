# 부동산 관리 시스템 (SiRE) 클래스 다이어그램

아래는 시스템의 핵심 도메인 간의 관계를 나타낸 다이어그램입니다.

# SiRE 프로젝트 클래스 다이어그램

```mermaid
classDiagram
    direction TB

    %% Core Layer: Database & Infrastructure
    namespace Core_Database {
        class AppDatabase {
            <<Drift>>
            +buildings
            +units
            +transactions
            +transactionImages
            +categories
        }
        class DatabaseProvider {
            <<Riverpod>>
            +watchDatabase()
        }
        class Tables {
            <<Schema>>
            +Buildings
            +Units
            +Transactions
        }
    }

    %% Core Layer: Purchase & Localization
    namespace Core_Services {
        class LocalizationProvider {
            <<Riverpod>>
            +currentLang
            +translate(key)
        }
        class PurchaseProvider {
            <<Riverpod>>
            +isPro
            +purchaseStatus
        }
        class IAPService {
            <<Service>>
            +initialize()
            +buyProduct()
        }
    }

    %% Features Layer: Property Management
    namespace Feature_Property {
        class PropertyProvider {
            <<Riverpod>>
            +buildingsList
            +unitsByBuilding
        }
        class PropertyScreen {
            <<UI>>
        }
        class RoomDetailScreen {
            <<UI>>
        }
    }

    %% Features Layer: Ledger & Transactions
    namespace Feature_Ledger {
        class LedgerProvider {
            <<Riverpod>>
            +transactionsList
            +monthlySummary
        }
        class UnpaidProvider {
            <<Riverpod>>
            +unpaidUnitsList
        }
        class LedgerScreen {
            <<UI>>
        }
        class AddTransactionSheet {
            <<UI/Dialog>>
        }
    }

    %% Features Layer: Reports
    namespace Feature_Reports {
        class ReportsProvider {
            <<Riverpod>>
            +annualStats
            +monthlyTrend
        }
        class ExcelExportService {
            <<Service>>
            +exportToExcel()
        }
        class ReportsScreen {
            <<UI>>
        }
    }

    %% App Structure
    namespace App_Shell {
        class Main {
            +main()
        }
        class App {
            +build()
        }
        class MainScreen {
            <<UI/BottomNav>>
            +Dashboard
            +Ledger
            +Property
            +Reports
            +Settings
        }
    }

    %% Relationships
    Main --> App : Initializes
    App --> MainScreen : Root
    MainScreen --> DashboardScreen : Tab
    MainScreen --> LedgerScreen : Tab
    MainScreen --> PropertyScreen : Tab
    MainScreen --> ReportsScreen : Tab
    
    %% Data Flow
    DatabaseProvider ..> AppDatabase : Provides
    AppDatabase o-- Tables : Defines
    
    PropertyProvider --> DatabaseProvider : Uses DB
    LedgerProvider --> DatabaseProvider : Uses DB
    ReportsProvider --> DatabaseProvider : Uses DB
    
    LedgerScreen ..> LedgerProvider : Watches
    PropertyScreen ..> PropertyProvider : Watches
    ReportsScreen ..> ReportsProvider : Watches
    
    ReportsScreen --> ExcelExportService : Triggers
    
    AddTransactionSheet --> LedgerProvider : Updates
    AddTransactionSheet --> PropertyProvider : Fetch Units
    
    PurchaseProvider --> IAPService : Communicates
    MainScreen ..> PurchaseProvider : Checks Pro Status
    ReportsScreen ..> PurchaseProvider : Restricted Features