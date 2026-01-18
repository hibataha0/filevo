# Overall Description - Product Perspective

## 2. Overall Description

### 2.1 Product Perspective

**FileVO** is a **mobile-based cloud storage application** designed to provide users with a simple and secure way to manage their digital files. The core of FileVO lies in its cloud-based architecture, which enables file uploading, storage, organization, and sharing through a centralized server system.

FileVO operates as a **client-server application**, where the mobile app allows users to interact with their files, while backend services handle data storage, security, and synchronization. The system relies on cloud infrastructure to ensure continuous access to files and efficient data management.

Through its **mobile-oriented design**, FileVO offers users the ability to manage their files anytime and anywhere using an internet connection, making it a practical solution for personal cloud file management.

FileVO is a **new, self-contained product** that is not a follow-on member of an existing product family, nor is it a replacement for existing systems. Instead, FileVO represents an independent, modern solution built from the ground up to address contemporary mobile file management needs.

#### System Architecture Overview

FileVO follows a **client-server architecture** with clear separation between frontend and backend components. The system is designed as a three-tier architecture:

1. **Presentation Tier (Frontend)**: Flutter-based cross-platform applications
2. **Application Tier (Backend)**: Node.js RESTful API server
3. **Data Tier**: MongoDB database and file storage system

#### System Components

The FileVO system consists of the following major components:

##### 2.1.1 Frontend Component (Client Application)

**Technology**: Flutter Framework (Dart)

**Platforms Supported**:
- Android mobile applications
- iOS mobile applications
- Web applications (browser-based)
- Windows desktop applications
- Linux desktop applications
- macOS desktop applications

**Key Responsibilities**:
- User interface presentation and interaction
- User input validation and processing
- File upload/download management
- Local data caching and state management
- Real-time communication via Socket.IO client
- Cross-platform file system access
- Biometric authentication integration
- Theme management (dark/light mode)
- Localization support (Arabic/English)

##### 2.1.2 Backend Component (Server Application)

**Technology**: Node.js with Express.js framework

**Key Responsibilities**:
- RESTful API endpoints for all operations
- User authentication and authorization
- File upload, storage, and retrieval
- Database operations and queries
- File processing and categorization
- AI-powered semantic search processing
- Real-time communication server (Socket.IO)
- Email service integration for notifications
- Virus scanning and file security checks
- Storage quota management

##### 2.1.3 Database Component

**Technology**: MongoDB (NoSQL Document Database)

**Key Responsibilities**:
- User account and profile data storage
- File metadata storage (names, sizes, types, paths, categories)
- Folder structure and hierarchy storage
- Room and collaboration data storage
- Invitation and member management
- Comment and activity tracking
- Storage usage statistics
- Access logs and audit trails

##### 2.1.4 File Storage System

**Technology**: File system storage (local server storage)

**Key Responsibilities**:
- Physical file storage on server
- File organization in directory structures
- File access control and permissions
- File version management
- Backup and recovery mechanisms

#### External Interfaces and Integrations

FileVO integrates with the following external services and systems:

##### 2.1.5 Hugging Face AI Service

**Purpose**: AI-powered semantic search functionality

**Interface**: RESTful API (HTTP/HTTPS)

**Integration Points**:
- File content embedding generation
- Semantic search query processing
- Multi-language support (Arabic/English)

**Data Flow**:
1. Backend sends file content to Hugging Face Inference API
2. Hugging Face returns embeddings (vector representations)
3. Backend stores embeddings in database
4. Search queries are processed using semantic similarity

**Service Location**: External cloud service (Hugging Face platform)

##### 2.1.6 Email Service

**Purpose**: User notifications and email verification

**Interface**: SMTP/Email API

**Functionality**:
- Email verification code delivery
- Account registration confirmations
- Room invitation notifications
- File sharing notifications
- System alerts and updates

**Service Location**: External email service provider

##### 2.1.7 Real-Time Communication (Socket.IO)

**Purpose**: Real-time bidirectional communication

**Interface**: WebSocket protocol (via Socket.IO)

**Functionality**:
- Real-time file update notifications
- Live collaboration updates
- Instant message delivery
- Connection state management

**Architecture**: Socket.IO server embedded in backend, Socket.IO client in frontend

##### 2.1.8 Operating System Integrations

**Platform-Specific Interfaces**:

- **Android**: File system access, biometric authentication (fingerprint/face), camera, storage permissions
- **iOS**: File system access, biometric authentication (Touch ID/Face ID), camera, photo library access
- **Desktop Platforms (Windows/Linux/macOS)**: File system access, native dialogs, system notifications

#### System Boundaries

**What FileVO Includes**:
- Complete file storage and management functionality
- User authentication and authorization
- Collaboration and sharing features
- AI-powered search capabilities
- Cross-platform client applications
- Backend API server
- Database management
- Real-time communication infrastructure

**What FileVO Does NOT Include**:
- Email server infrastructure (uses external service)
- AI model hosting (uses external Hugging Face service)
- Cloud infrastructure (deployed on user-provided infrastructure)
- Content delivery network (CDN) for file distribution
- Third-party payment processing (if storage upgrades are implemented in future)

#### System Context Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         FileVO System                            │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Frontend Layer (Flutter)                    │   │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │   │
│  │  │ Android  │ │   iOS    │ │   Web    │ │ Desktop  │  │   │
│  │  │   App    │ │   App    │ │   App    │ │   Apps   │  │   │
│  │  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘  │   │
│  └───────┼────────────┼────────────┼────────────┼─────────┘   │
│          │            │            │            │              │
│          └────────────┴────────────┴────────────┘              │
│                        │ HTTP/REST API                          │
│                        │ Socket.IO (WebSocket)                  │
│                        ▼                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │          Backend Layer (Node.js/Express)                 │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │   │
│  │  │   API Server │ │ Socket.IO    │ │ File         │    │   │
│  │  │   (REST)     │ │ Server       │ │ Processing   │    │   │
│  │  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘    │   │
│  └─────────┼────────────────┼─────────────────┼────────────┘   │
│            │                │                 │                 │
│            │                │                 │                 │
│  ┌─────────┼────────────────┼─────────────────┼────────────┐   │
│  │         ▼                │                 ▼            │   │
│  │  ┌─────────────┐         │        ┌──────────────┐     │   │
│  │  │  MongoDB    │         │        │ File Storage │     │   │
│  │  │  Database   │         │        │    System    │     │   │
│  │  └─────────────┘         │        └──────────────┘     │   │
│  └──────────────────────────┴──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                             │
                             │ HTTP/HTTPS
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Hugging    │    │    Email     │    │   Operating  │
│    Face      │    │   Service    │    │    Systems   │
│  AI Service  │    │   (SMTP)     │    │  (Platforms) │
└──────────────┘    └──────────────┘    └──────────────┘
   (External)          (External)        (External)
```

#### Component Interaction Flow

**File Upload Flow**:
1. User selects file(s) in Frontend (Flutter app)
2. Frontend sends HTTP POST request with file data to Backend API
3. Backend validates request and stores file in File Storage System
4. Backend creates file metadata record in MongoDB Database
5. Backend initiates background processing (AI embedding generation)
6. Backend sends file metadata response to Frontend
7. Frontend updates UI to display uploaded file

**Search Flow**:
1. User enters search query in Frontend
2. Frontend sends search request to Backend API
3. Backend processes query and queries MongoDB for matching files
4. For semantic search, Backend sends query to Hugging Face API
5. Hugging Face returns semantic search results
6. Backend combines results and sends to Frontend
7. Frontend displays search results to user

**Real-Time Collaboration Flow**:
1. User A shares file in Room via Frontend
2. Frontend sends share request to Backend API
3. Backend updates Room data in MongoDB
4. Backend emits Socket.IO event to all connected Room members
5. User B's Frontend receives Socket.IO event
6. User B's Frontend updates UI to show new shared file

#### Product Independence

FileVO is designed as a **standalone, self-contained system** that:

- **Does not depend on other proprietary systems** for core functionality
- **Can operate independently** without integration with other business systems
- **Provides complete end-to-end functionality** within its own ecosystem
- **Maintains its own user database** and does not rely on external identity providers (though future integration is possible)
- **Manages its own file storage** without dependency on third-party cloud storage services (though can be configured to use cloud storage)

#### Future Integration Possibilities

While FileVO is currently a self-contained system, it is designed with extensibility in mind for potential future integrations:

- **Cloud Storage Providers**: Integration with AWS S3, Google Cloud Storage, Azure Blob Storage
- **Identity Providers**: OAuth integration with Google, Facebook, Microsoft
- **Content Delivery Networks**: CDN integration for faster file delivery
- **Analytics Platforms**: Integration with analytics services for usage tracking
- **Notification Services**: Push notification services (FCM, APNs)

---

In summary, FileVO is a modern, independent file storage and management system built with a clear architectural separation between frontend and backend components, integrating with external services for AI capabilities and email notifications, while maintaining complete functional independence for core file management operations.
